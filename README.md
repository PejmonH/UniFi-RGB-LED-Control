# UniFi-RGB-LED-Control

Control UniFi Access Point LED color and brightness directly over SSH by writing to
`/proc/ubnt_ledbar`.

This project provides a small, dependency-free shell script that lets you set
custom RGB colors and optional brightness levels on UniFi APs without using the
UniFi UI.

---

## Why This Exists

UniFi exposes LED control via kernel interfaces on the AP itself, but:

- The UniFi UI does not allow arbitrary RGB values or at times fails to push color changes
- Brightness changes reset LED color
- There is no native way to automatically set both

This script handles those quirks and provides a simple, repeatable interface for
direct LED control.

It can also be paired with tools like
[homebridge-dummy](https://github.com/mpatfield/homebridge-dummy) to enable LED
control from Apple HomeKit. By mapping HomeKit switches to shell commands exposed
by `homebridge-dummy` (via its `commandOn` and `commandOff` parameters), UniFi AP LEDs can be toggled
or recolored directly from HomeKit automations.

---

## Features

- 🎨 Set custom RGB LED colors
- 🔆 Optional brightness control (preserves color when omitted)
- 🔐 SSH key-based authentication (no passwords)
- ⚡ Single SSH invocation per update
- 🧩 Works with multiple APs via IP or SSH host aliases 

---

## Requirements

- UniFi Access Point with SSH enabled
- SSH access to the AP user (default is often `ubnt` or a custom user)
- SSH public key installed on the AP (via UniFi Console or `authorized_keys`)
- Access to:
  - `/proc/ubnt_ledbar/custom_color`
  - `/proc/ubnt_ledbar/brightness`

---

## Installation

1. Copy the script to your controller host (CloudKey, Homebridge, or Linux box)
2. Make it executable:

~~~bash
chmod +x change-ap-led
~~~

3. Ensure your SSH key is available on the controller host and installed on the AP
   (via UniFi Console → SSH Authentication Keys or `authorized_keys`).

4. (Optional) Symlink the script into your PATH for convenience:

~~~bash
sudo ln -s /home/homebridge/change-ap-led /usr/local/bin/change-ap-led
~~~

---

## Usage

~~~bash
change-ap-led <IP-or-HostAlias> <R> <G> <B> [BRIGHTNESS]
~~~

### Examples

Set warmish white at 75% brightness:

~~~bash
change-ap-led 10.0.10.107 239 108 0 75
~~~

Change color only (leave brightness unchanged):

~~~bash
change-ap-led 10.0.10.108 0 255 0
~~~

Using an SSH host alias:

~~~bash
change-ap-led ubnt-ap1 0 0 255
~~~

---

## Brightness Behavior (Important)

On UniFi APs, writing to the brightness interface resets the LED color to the
default blue.

To avoid visible flashing:

- Brightness is always applied **first**
- Color is applied immediately afterward
- If brightness is omitted, it is **not touched**

This allows safe live color updates without unwanted resets.

---

## SSH Configuration (Recommended)

Using SSH host aliases simplifies multi-AP setups.

Example `~/.ssh/config`:

~~~ssh
Host ubnt-ap1
    HostName 10.0.10.107
    User arasaka
    IdentityFile ~/.ssh/ap_led_key
    StrictHostKeyChecking no

Host ubnt-ap2
    HostName 10.0.10.108
    User arasaka
    IdentityFile ~/.ssh/ap_led_key
    StrictHostKeyChecking no
~~~

With this in place, you can reference APs by name instead of IP.

---

## HomeKit / Homebridge Integration

This script works well with `homebridge-dummy` to expose UniFi AP LEDs as HomeKit
accessories.

Example `commandOn` / `commandOff` mappings:

~~~json
{
  "accessory": "DummySwitch",
  "name": "Office AP LED (Warm White) - Dimmed",
  "commandOn": "/home/homebridge/change-ap-led ubnt-ap1 239 108 0 75",
  "commandOff": "/home/homebridge/change-ap-led ubnt-ap1 0 0 0"
}
~~~

~~~json
{
  "accessory": "DummySwitch",
  "name": "Living Room AP LED (Cool White - Bright)",
  "commandOn": "/home/homebridge/change-ap-led 10.0.10.108 255 255 126 255",
  "commandOff": "/home/homebridge/change-ap-led 10.0.10.108 0 0 0"
}
~~~

This allows LED color or state changes to be triggered from:

- HomeKit automations
- Scenes
- Siri voice commands

In my case, I skipped adding `commandOff`, utilizing a `groupName`, and have each button actting as a toggle that `autoReset` to visual state off in HomeKit, including a button with a commandOn that turns off the LEDs. 

---

## Security Notes

- This project assumes SSH **key-based authentication**
- Private keys should have strict permissions (`600`)
- Avoid hardcoding passwords in scripts
- Consider restricting SSH access on APs to trusted hosts only

---

## Compatibility Notes

- This relies on UniFi internal kernel interfaces
- Behavior may change with firmware updates
- If you installed the SSH keys directly yourself on the APs vs using the UniFi Console to push them, they will likely get erased with AP firmware updates
- May not work on all RGB UniFi AP models.
- Tested on UniFi APs exposing `/proc/ubnt_ledbar` (FlexHD and Beacon HD, in my case)

---

## Disclaimer

This is an **unofficial** project and is not supported by Ubiquiti. 
Use at your own risk.
