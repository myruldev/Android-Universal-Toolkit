#!/bin/bash
# AUT - Field Tech Module (CCTV, IP Cam, ONVIF, RTSP)
# Penulis: myruldev

field_tech_menu() {
    while true; do
        header
        section "Field Tech Tools (CCTV / IP Camera)"
        item "1" "Scan ONVIF Camera di Jaringan Lokal"
        item "2" "Tebak Path RTSP CCTV (Hikvision, Dahua, dll)"
        item "3" "Play Live Stream RTSP (VLC / MPV)"
        item "4" "Scan IP & Port Terbuka (Nmap)"
        item "5" "RJ45 Pinout Guide (T568A / T568B)"
        back_item
        ask_choice

        case $REPLY_CHOICE in
            1) field_scan_onvif ;;
            2) field_guess_rtsp ;;
            3) field_play_rtsp ;;
            4) field_scan_ports ;;
            5) field_rj45_guide ;;
            0) break ;;
            *) invalid_choice ;;
        esac
    done
}

field_scan_onvif() {
    echo ""
    msg_info "Memulai pemindaian ONVIF IP Camera di subnet lokal..."
    echo ""
    if [ ! -f "helpers/onvif_scan.py" ]; then
        msg_err "File helpers/onvif_scan.py tidak ditemukan."
    else
        python3 helpers/onvif_scan.py
    fi
    pause
}

field_guess_rtsp() {
    echo ""
    read -rp "  IP Camera target (contoh: 192.168.1.100): " ip_target
    if [ -z "$ip_target" ]; then
        msg_err "IP target tidak boleh kosong."
        pause
        return
    fi

    echo ""
    msg_info "Daftar path RTSP umum untuk $ip_target:"
    echo ""
    local paths=(
        "Streaming/Channels/101"
        "cam/realmonitor?channel=1&subtype=0"
        "live/ch1"
        "h264Preview_01_main"
        "video1"
        "mpeg4/ch1"
        "stream1"
    )
    for path in "${paths[@]}"; do
        echo -e "    ${C_ACCENT}rtsp://$ip_target:554/$path${NC}"
    done
    echo ""
    echo -e "  ${C_DIM}Salin salah satu URL lalu uji lewat menu Play Live Stream.${NC}"
    pause
}

field_play_rtsp() {
    echo ""
    read -rp "  URL RTSP (contoh: rtsp://admin:admin@192.168.1.100:554/live/ch1): " rtsp_url
    if [ -z "$rtsp_url" ]; then
        msg_err "URL RTSP tidak boleh kosong."
        pause
        return
    fi
    echo ""
    msg_info "Membuka player via Shizuku..."
    if ! sh_run "am start -a android.intent.action.VIEW -d '$rtsp_url' -n org.videolan.vlc/org.videolan.vlc.gui.video.VideoPlayerActivity" 2>/dev/null; then
        # Fallback ke player default sistem.
        sh_run "am start -a android.intent.action.VIEW -d '$rtsp_url'"
    fi
    msg_ok "Perintah putar dikirim ke perangkat."
    pause
}

field_scan_ports() {
    echo ""
    if ! command -v nmap &> /dev/null; then
        msg_warn "Menginstall nmap untuk scanning..."
        pkg install -y nmap
    fi
    read -rp "  Subnet jaringan (contoh: 192.168.1.0/24): " subnet
    if [ -z "$subnet" ]; then
        msg_err "Subnet tidak boleh kosong."
        pause
        return
    fi
    echo ""
    msg_info "Menjalankan Nmap (port 80, 554, 8000)..."
    nmap -p 80,554,8000 --open "$subnet"
    pause
}

field_rj45_guide() {
    header
    section "RJ45 Pinout Guide"
    echo -e "  ${C_TITLE}T568B (Straight - paling umum)${NC}"
    printf "    %s  %-16s%s\n" "1" "Putih-Oranye" "[Tx+]"
    printf "    %s  %-16s%s\n" "2" "Oranye"       "[Tx-]"
    printf "    %s  %-16s%s\n" "3" "Putih-Hijau"  "[Rx+]"
    printf "    %s  %-16s%s\n" "4" "Biru"         "[PoE]"
    printf "    %s  %-16s%s\n" "5" "Putih-Biru"   "[PoE]"
    printf "    %s  %-16s%s\n" "6" "Hijau"        "[Rx-]"
    printf "    %s  %-16s%s\n" "7" "Putih-Cokelat" "[PoE]"
    printf "    %s  %-16s%s\n" "8" "Cokelat"      "[PoE]"
    echo ""
    echo -e "  ${C_TITLE}T568A (Cross-over: pasangan 1-3 & 2-6 ditukar)${NC}"
    printf "    %s  %s\n" "1" "Putih-Hijau"
    printf "    %s  %s\n" "2" "Hijau"
    printf "    %s  %s\n" "3" "Putih-Oranye"
    printf "    %s  %s\n" "6" "Oranye"
    echo -e "  ${C_DIM}Pin 4,5,7,8 sama dengan T568B.${NC}"
    pause
}
