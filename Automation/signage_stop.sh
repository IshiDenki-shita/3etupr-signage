#!/bin/bash

# Chromiumプロセスの停止
if pkill -f "chromium.*--kiosk"; then
    echo "$(date): SUCCESS - Chromium stopped"
else
    echo "$(date): FAILED - Chromium not found or could not be stopped"
fi

# Flaskサーバープロセスの停止
if pkill -f "python app.py"; then
    echo "$(date): SUCCESS - Flask server stopped"
else
    echo "$(date): FAILED - Flask server not found or could not be stopped"
fi