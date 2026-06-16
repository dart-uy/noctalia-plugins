# Hotspot plugin

Share your internet via Hotspot (a.k.a Access Point).
Offers shortcut and a customizable widget for Noctalia Shell v5.

Dependencies (on arch btw):
- NetworkManager
* dnsmasq
+ wireless-regdb

> [!IMPORTANT]
> Noctalia plugin API is on active development and things would break
> eventually. So, enable auto-update for this repository when adding
> to noctalia plugins list.

## Configuration

First, go to plugin settings and set ***device*** field to your wifi card. Run `ip link` if you don't know what is your device.
Set SSID and Password fields too to begin with and it should work.

Add a shortcut or widget and toggle it.

### 5GHz
To enable 5GHz first set regdomain to US `iw reg set US` (can use your
country code as well, and it is recommended) this reconfigure your
wifi card and will let you set new frequencies such those used
by 5GHz. Reboot your system to apply changes.

Check if regdomain changed with `iw reg get`.

If does not change check [this](https://wiki.archlinux.org/title/Network_configuration/Wireless#Respecting_the_regulatory_domain) arch wiki, it should help!

Now, check if you have frequencies used by 5GHz enabled with `iw list | grep -A 20 "Frequencies"`. They should appear without **No IR**.

Go to plugin settings and change 2.4GHz to 5GHz, set channel to one
that you have enabled (and preferable wihout radar detection) and channel width to 80MHz for full speed. That's all!

If hotspot is *on* it'll be restarted as you change some setting.

### Wireless Repeater Mode

> [!CAUTION]
> This step can cause kernel panics so be careful
> and check if your card is compatible.
> Usually this happends with old ones.
> Link: [Arch:Talk](https://wiki.archlinux.org/title/Talk:Software_access_point#c-Warshipper-20240116182500-Two_interfaces_on_same_card) [Kernel](https://github.com/lakinduakash/linux-wifi-hotspot/blob/75f48a929bd336b3f6ddf2b158a21e76505e19d4/src/scripts/create_ap#L296)

Configuration above only works with wired/ethernet connections and
using your wifi card as client and access point at the same time
needs some steps.

First, disconnect your actual connection and hotspot before creating virtual interfaces. Disable the plugin also.

Delete your hotspot connection `nmcli connection delete Hotspot`, if created.

Create virtual interface with `iw dev YOURDEVICE interface add YOURDEVICE_ap type __ap addr 12:34:56:78:ab:ce`. You can generate a random MAC address with [macchanger](https://wiki.archlinux.org/title/MAC_address_spoofing#macchanger) but that should work.

Check if you have soft block with `rfkill list`, unblock it with `rfkill unblock wifi`.
Mark the virtual interface as UP with `ip link set YOURDEVICE_ap up`.
Go to plugin settings and change device to your new virtual interface.

And DONE!
Take up your connection and the plugin.

# Future!

Will be adding some features and automatization as it goes.
- Let repeater mode less painful
+ Get clients connected (IP, MAC)
* More widget customization
