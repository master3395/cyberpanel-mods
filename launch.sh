#!/bin/bash

# CyberPanel Mods Launcher
# Simple launcher script for the master menu

echo "🚀 Launching CyberPanel Mods Master Menu..."
echo ""

# Check if menu script exists
if [[ -f "cyberpanel-mods-menu.sh" ]]; then
    bash cyberpanel-mods-menu.sh
else
    echo "❌ Menu script not found!"
    echo "Please ensure you're in the cyberpanel-mods directory"
    echo "and the cyberpanel-mods-menu.sh file exists"
    exit 1
fi
