#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Parser informasi WiFi untuk Android Universal Toolkit (AUT)
# Penulis: myruldev
#
# Penggunaan:
#   dumpsys wifi      | python3 wifi_parse.py current
#   cat ...Store.xml  | python3 wifi_parse.py saved
#
# Tujuan: meringkas output mentah dumpsys/XML menjadi informasi penting saja.

import re
import sys
import xml.etree.ElementTree as ET

SECURITY_MAP = {
    "0": "Open",
    "1": "WEP",
    "2": "WPA/WPA2 PSK",
    "3": "EAP",
    "4": "WPA3 SAE",
    "5": "OWE",
    "6": "WAPI PSK",
    "7": "WAPI CERT",
}


def _search(pattern, text, group=1, flags=0):
    m = re.search(pattern, text, flags)
    return m.group(group).strip() if m else None


def show_current(text):
    """Ringkas informasi koneksi WiFi aktif dari output `dumpsys wifi`."""
    ssid = _search(r'SSID:\s*"?([^",\n]+)"?', text)
    if ssid in (None, "<unknown ssid>", "<none>"):
        print("  Tidak ada koneksi WiFi aktif yang terdeteksi.")
        return

    bssid = _search(r"BSSID:\s*([0-9a-fA-F:]{17})", text)
    rssi = _search(r"RSSI:\s*(-?\d+)", text)
    link = _search(r"(?<![TR]x )Link speed:\s*(\d+)\s*Mbps", text)
    freq = _search(r"Frequency:\s*(\d+)\s*MHz", text)
    ip = _search(r"IP:\s*/?([\d.]+)", text)
    sec = _search(r"Security type:\s*(\d+)", text)
    sec = SECURITY_MAP.get(sec, sec) if sec else None

    band = None
    if freq:
        f = int(freq)
        band = "2.4 GHz" if f < 3000 else ("5 GHz" if f < 5925 else "6 GHz")

    rows = [
        ("SSID", ssid),
        ("Security", sec),
        ("IP Address", ip),
        ("BSSID", bssid),
        ("Signal (RSSI)", f"{rssi} dBm" if rssi else None),
        ("Link Speed", f"{link} Mbps" if link else None),
        ("Frequency", f"{freq} MHz ({band})" if freq and band else (f"{freq} MHz" if freq else None)),
    ]
    for label, value in rows:
        if value:
            print(f"    {label:<14}: {value}")


def show_saved(xml_text):
    """Ringkas daftar jaringan tersimpan + password dari WifiConfigStore.xml."""
    try:
        root = ET.fromstring(xml_text)
    except ET.ParseError:
        print("  Gagal membaca data konfigurasi WiFi (format tidak dikenali).")
        return

    count = 0
    for net in root.iter("Network"):
        fields = {}
        for el in net.iter():
            name = el.attrib.get("name")
            if not name:
                continue
            if el.tag == "null":
                fields[name] = None
            elif el.text is not None:
                fields[name] = el.text.strip().strip('"')

        ssid = fields.get("SSID")
        if not ssid:
            continue

        psk = fields.get("PreSharedKey")
        wep = fields.get("WEPKeys")
        if psk:
            security, password = "WPA/WPA2 PSK", psk
        elif wep:
            security, password = "WEP", wep
        else:
            security, password = "Open", "(tanpa password)"

        count += 1
        print(f"    {count}. {ssid}")
        print(f"       Password : {password}")
        print(f"       Security : {security}")

    if count == 0:
        print("  Tidak ada jaringan WiFi tersimpan yang dapat dibaca.")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "current"
    data = sys.stdin.read()
    if mode == "saved":
        show_saved(data)
    else:
        show_current(data)


if __name__ == "__main__":
    main()
