#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Pemindai ONVIF IP Camera sederhana via SSDP Discovery
# Penulis: myruldev

import re
import socket

SSDP_ADDR = "239.255.255.250"
SSDP_PORT = 1900
SSDP_MSG = (
    "M-SEARCH * HTTP/1.1\r\n"
    "HOST: 239.255.255.250:1900\r\n"
    'MAN: "ssdp:discover"\r\n'
    "MX: 2\r\n"
    "ST: urn:schemas-xmlsoap-org:device:NetworkVideoTransmitter:1\r\n"
    "\r\n"
)


def discover_onvif_cameras(timeout=3.0):
    print("[*] Mengirim broadcast SSDP untuk mendeteksi perangkat ONVIF...")
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.settimeout(timeout)

    cameras = []
    seen = set()
    try:
        sock.sendto(SSDP_MSG.encode("utf-8"), (SSDP_ADDR, SSDP_PORT))
        while True:
            try:
                data, addr = sock.recvfrom(2048)
            except socket.timeout:
                break
            ip = addr[0]
            if ip in seen:
                continue
            seen.add(ip)
            response = data.decode("utf-8", errors="ignore")
            loc = re.search(r"LOCATION:\s*(.*)", response, re.IGNORECASE)
            cameras.append({"ip": ip, "location": loc.group(1).strip() if loc else ""})
            print(f"[+] Ditemukan perangkat ONVIF: {ip}")
    except Exception as e:
        print(f"[!] Terjadi kesalahan saat scanning: {e}")
    finally:
        sock.close()
    return cameras


def main():
    cams = discover_onvif_cameras()
    print("--------------------------------------------------------")
    print(f"Total kamera ONVIF terdeteksi: {len(cams)}")
    if cams:
        for idx, cam in enumerate(cams, 1):
            print(f"{idx}. IP: {cam['ip']}")
            if cam["location"]:
                print(f"   Endpoint: {cam['location']}")
    else:
        print("[*] Tidak ada kamera ONVIF yang merespon SSDP broadcast.")
        print("[*] Tips: pastikan HP terhubung ke Wi-Fi yang sama dengan CCTV/NVR.")
    print("--------------------------------------------------------")


if __name__ == "__main__":
    main()
