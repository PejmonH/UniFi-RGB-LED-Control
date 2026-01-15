#!/bin/sh
#
# change-ap-led.sh
#
# Control UniFi Access Point LED color and (optionally) brightness via SSH.
#
# This script connects to a UniFi AP and writes directly to:
#   /proc/ubnt_ledbar/custom_color
#   /proc/ubnt_ledbar/brightness
#
# Notes:
# - Brightness is optional. If omitted, the current brightness is preserved.
# - Setting brightness resets the LED color on UniFi APs, so brightness is
#   always applied first, followed immediately by the color.
# - Requires SSH key-based authentication.
#
# ---------------------------------------------------------------------------
# Usage:
#   change-ap-led <IP> <R> <G> <B> [BRIGHTNESS]
#
# Examples:
#   change-ap-led 10.0.10.107 239 76 0 75   # Orange at 75% brightness
#   change-ap-led 10.0.10.108 0 255 0       # Green, leave brightness unchanged
# ---------------------------------------------------------------------------

AP_USER="arasaka"
KEYFILE="/home/homebridge/.ssh/ap_led_key"

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------
if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <IP> <R> <G> <B> [BRIGHTNESS]"
  exit 1
fi

AP_HOST="$1"
R="$2"
G="$3"
B="$4"
BRIGHTNESS="$5"

# ---------------------------------------------------------------------------
# Execute LED update
# ---------------------------------------------------------------------------
if [ -n "$BRIGHTNESS" ]; then
  # Apply brightness first (prevents color reset issues)
  ssh -i "$KEYFILE" -o StrictHostKeyChecking=no \
    "$AP_USER@$AP_HOST" \
    "echo -n $BRIGHTNESS > /proc/ubnt_ledbar/brightness; \
     echo -n $R,$G,$B > /proc/ubnt_ledbar/custom_color"
else
  # Update color only
  ssh -i "$KEYFILE" -o StrictHostKeyChecking=no \
    "$AP_USER@$AP_HOST" \
    "echo -n $R,$G,$B > /proc/ubnt_ledbar/custom_color"
fi
