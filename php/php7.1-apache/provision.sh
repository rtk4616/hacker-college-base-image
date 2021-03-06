#!/bin/bash
#
# Hacker College: Provisioning script for Web-based Images

# We want the provision script to fail as soon as there are any errors
set -e

function log() {
  echo "[+] $@"
}

function error_log() {
  RED='\033[0;31m'
  NORMAL='\033[0m'
  echo -e "${RED}[!] $1 ${NORMAL}"
}

function ok_log() {
  GREEN='\033[0;32m'
  NORMAL='\033[0m'
  echo -e "${GREEN}[+] $1 ${NORMAL}"
}

# Default values
WEB_PATH="/var/www/html"
CHALLENGE_PATH="/tmp/data"

if [[ ! -f "$CHALLENGE_PATH" ]]; then
    error_log "ENOENT: $CHALLENGE_PATH not found."
    log "Sleeping for 5 seconds."
    sleep 5
    exit 1
else
    log "Checking \"$CHALLENGE_PATH\"'s filetype..."
    case $(file --mime-type -b "$CHALLENGE_PATH") in
        application/x-tar)
            tar -xf "$CHALLENGE_PATH" -C "$WEB_PATH"
            ;;
        application/gzip)
            tar -zxf "$CHALLENGE_PATH" -C "$WEB_PATH"
            ;;
        application/x-bzip2)
            tar -jxf "$CHALLENGE_PATH" -C "$WEB_PATH"
            ;;
        application/x-xz)
            tar -Jxf "$CHALLENGE_PATH" -C "$WEB_PATH"
            ;;
        application/zip)
            unzip "$CHALLENGE_PATH" -d "$WEB_PATH"
            ;;
        application/x-rar)
            7z x "$CHALLENGE_PATH" -o"$WEB_PATH"
            ;;
        application/x-7z-compressed)
            7z x "$CHALLENGE_PATH" -o"$WEB_PATH"
            ;;
        *)
            error_log "Currently not supported. Sorry..."
            exit 1
            ;;
    esac
    cd "$WEB_PATH" && chown -R www-data:www-data *
    ok_log "Provisioning is ready!"
    apache2-foreground
fi
