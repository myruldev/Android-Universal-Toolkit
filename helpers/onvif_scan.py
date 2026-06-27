#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Pemindai ONVIF IP Camera Sederhana menggunakan SSDP Discovery
# Penulis: myruldev & Tabbit (2026)

import socket
import re

def discover_onvif_cameras():
    print("[*] Mengirimkan broadcast SSDP untuk mendeteksi perangkat ONVIF...")
    
    # SSDP Discovery message untuk perangkat ONVIF/Network Video Transmitter
    ssdp_msg = (
        'M-SEARCH * HTTP/1.1
'
        'HOST: 239.255.255.250:1900
'
        'MAN: "ssdp:discover"
'
        'MX: 2
'
        'ST: urn:schemas-xmlsoap-org:device:NetworkVideoTransmitter:1
'
        '
'
    )

    # Inisialisasi socket UDP
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.settimeout(3.0)
    
    cameras = []
    try:
        # Kirim multicast SSDP ke grup standard 239.255.255.250
        sock.sendto(ssdp_msg.encode('utf-8'), ('239.255.255.250', 1900))
        
        while True:
            try:
                data, addr = sock.recvfrom(2048)
                response = data.decode('utf-8', errors='ignore')
                ip = addr[0]
                
                if ip not in [c['ip'] for c in cameras]:
                    # Ekstrak lokasi / detail ONVIF endpoint
                    location = ""
                    loc_match = re.search(r'LOCATION:\s*(.*)', response, re.IGNORECASE)
                    if loc_match:
                        location = loc_match.group(1).strip()
                    
                    cameras.append({'ip': ip, 'location': location})
                    print(f"[+] Ditemukan perangkat ONVIF di IP: {ip}")
            except socket.timeout:
                break
    except Exception as e:
        print(f"[!] Terjadi kesalahan saat scanning: {str(e)}")
    finally:
        sock.close()
        
    return cameras

if __name__ == "__main__":
    found_cams = discover_onvif_cameras()
    print("
--------------------------------------------------------")
    print(f"Total kamera ONVIF yang terdeteksi: {len(found_cams)}")
    if found_cams:
        for idx, cam in enumerate(found_cams, 1):
            print(f"{idx}. IP: {cam['ip']}")
            if cam['location']:
                print(f"   Endpoint: {cam['location']}")
    else:
        print("[*] Tidak ada kamera ONVIF yang merespon SSDP broadcast.")
        print("[*] Tips: Pastikan HP Anda terhubung ke jaringan Wi-Fi yang sama dengan CCTV/NVR.")
    print("--------------------------------------------------------")
