_RSPAMD_UPSTREAM = ('127.0.0.1', 11334)
_RSPAMD_HOP_RESPONSE = frozenset({
    'connection', 'transfer-encoding', 'keep-alive', 'proxy-authenticate',
    'proxy-authorization', 'te', 'trailers', 'upgrade', 'content-encoding',
})


@csrf_exempt
def rspamd_ui_proxy(request, subpath=None):
    """Reverse-proxy Rspamd controller UI (localhost:11334) for logged-in admins only."""
    try:
        userID = request.session['userID']
        currentACL = ACLManager.loadedACL(userID)
        if currentACL['admin'] != 1:
            return ACLManager.loadError()
    except KeyError:
        return redirect(loadLoginPage)

    if mailUtilities.checkIfRspamdInstalled() != 1:
        return HttpResponse(
            'Rspamd is not installed.',
            status=503,
            content_type='text/plain; charset=utf-8',
        )

    proxy_base = request.build_absolute_uri('/emailPremium/Rspamd/ui').rstrip('/')
    path = '/'
    if subpath:
        path = '/' + subpath.lstrip('/')
    q = request.META.get('QUERY_STRING', '')
    if q:
        full_path = path + '?' + q
    else:
        full_path = path

    forward_method = request.method
    if forward_method == 'HEAD':
        forward_method = 'GET'

    body = None
    if forward_method in ('POST', 'PUT', 'PATCH', 'DELETE'):
        body = request.body

    headers = {}
    acc = request.META.get('HTTP_ACCEPT')
    if acc:
        headers['Accept'] = acc
    al = request.META.get('HTTP_ACCEPT_LANGUAGE')
    if al:
        headers['Accept-Language'] = al
    ua = request.META.get('HTTP_USER_AGENT')
    if ua:
        headers['User-Agent'] = ua
    auth = request.META.get('HTTP_AUTHORIZATION')
    if auth:
        headers['Authorization'] = auth
    ct = request.META.get('CONTENT_TYPE')
    if ct and forward_method in ('POST', 'PUT', 'PATCH'):
        headers['Content-Type'] = ct
    cookie = request.META.get('HTTP_COOKIE')
    if cookie:
        headers['Cookie'] = cookie
    xhr = request.META.get('HTTP_X_REQUESTED_WITH')
    if xhr:
        headers['X-Requested-With'] = xhr

    conn = None
    try:
        conn = http.client.HTTPConnection(
            _RSPAMD_UPSTREAM[0], _RSPAMD_UPSTREAM[1], timeout=120,
        )
        conn.request(forward_method, full_path, body=body, headers=headers)
        upstream = conn.getresponse()
        data = upstream.read()
        status = upstream.status
    except (ConnectionRefusedError, OSError, http.client.HTTPException) as _e:
        logging.CyberCPLogFileWriter.writeToFile(
            'rspamd_ui_proxy upstream error: %s' % (type(_e).__name__,),
        )
        return HttpResponse(
            'Could not reach Rspamd on 127.0.0.1:11334. Is rspamd running?',
            status=502,
            content_type='text/plain; charset=utf-8',
        )
    finally:
        if conn is not None:
            try:
                conn.close()
            except Exception:
                pass

    if request.method == 'HEAD':
        out = HttpResponse(status=status)
        data = b''

    else:
        out = HttpResponse(data, status=status)

    for hdr, val in upstream.getheaders():
        key = hdr.lower()
        if key in _RSPAMD_HOP_RESPONSE:
            continue
        if key == 'location':
            val = _rewrite_rspamd_location(val, proxy_base)
        if request.method == 'HEAD' and key == 'content-length':
            continue
        out[hdr] = val

    return out


def _rewrite_rspamd_location(location, proxy_base):
    if not location:
        return location
    if location.startswith('http://127.0.0.1:11334'):
        return proxy_base + location[len('http://127.0.0.1:11334'):]
    if location.startswith('http://[::1]:11334'):
        return proxy_base + location[len('http://[::1]:11334'):]
    if location.startswith('/') and not location.startswith('//'):
        return proxy_base + location
    return location

