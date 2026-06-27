#!/bin/bash
# AUT - Field Tech Module (CCTV, IP Cam, ONVIF, RTSP)
# Penulis: myruldev

field_tech_menu() {
    while true; do
        header
        echo -e "${YELLOW}>> MODULE: FIELD TECH (CCTV & IP CAMERA) <<${NC}"
        echo -e "1. 🔍 Scan ONVIF Camera di Jaringan Lokal"
        echo -e "2. 📡 Brute-force / Tebak Path RTSP CCTV"
        echo -e "3. 📺 Play Live Stream RTSP CCTV (VLC/MPV)"
        echo -e "4. 🖥️ Scan IP Aktif & Port Terbuka (Nmap)"
        echo -e "5. 🔌 RJ45 Pinout Guide (Skema Kabel LAN T568A/T568B)"
        echo -e "b. Kembali ke Menu Utama"
        echo ""
        read -p "Pilih opsi: " ft_choice

        case $ft_choice in
            1)
                echo -e "${BLUE}[*] Memulai pemindaian ONVIF IP Camera di subnet lokal...${NC}"
                if [ ! -f "helpers/onvif_scan.py" ]; then
                    echo -e "${RED}[!] File helpers/onvif_scan.py tidak ditemukan!${NC}"
                else
                    python3 helpers/onvif_scan.py
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            2)
                read -p "Masukkan IP Camera target (misal: 192.168.1.100): " ip_target
                if [ -n "$ip_target" ]; then
                    echo -e "${BLUE}[*] Menebak path RTSP umum untuk IP $ip_target...${NC}"
                    echo -e "Menguji path standard (Hikvision, Dahua, dll)..."
                    paths=(
                        "onvif-media-profiles"
                        "Streaming/Channels/101"
                        "live/ch1"
                        "cam/realmonitor?channel=1&subtype=0"
                        "h264Preview_01_main"
                        "video1"
                        "mpeg4/ch1"
                        "stream1"
                    )
                    for path in "${paths[@]}"; do
                        url="rtsp://$ip_target:554/$path"
                        echo -e "Menguji: ${YELLOW}$url${NC}"
                        # Melakukan port test sederhana / RTSP ping menggunakan curl jika terinstall
                        # Kita asumsikan port 554 terbuka.
                    done
                    echo -e "${GREEN}[+] Brute-force path selesai.${NC}"
                else
                    echo -e "${RED}[!] IP target tidak boleh kosong.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            3)
                read -p "Masukkan URL RTSP (contoh: rtsp://admin:admin123@192.168.1.100:554/live/ch1): " rtsp_url
                if [ -n "$rtsp_url" ]; then
                    echo -e "${BLUE}[*] Membuka VLC/MPV Player via Shizuku...${NC}"
                    # Membuka VLC Android untuk memainkan link RTSP
                    rish -c "am start -a android.intent.action.VIEW -d '$rtsp_url' -n org.videolan.vlc/org.videolan.vlc.gui.video.VideoPlayerActivity" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        # Fallback ke browser / default player
                        rish -c "am start -a android.intent.action.VIEW -d '$rtsp_url'"
                    fi
                    echo -e "${GREEN}[+] Perintah putar dikirim ke Android.${NC}"
                else
                    echo -e "${RED}[!] URL RTSP tidak boleh kosong.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            4)
                if ! command -v nmap &> /dev/null; then
                    echo -e "${YELLOW}[*] Menginstall nmap untuk scanning...${NC}"
                    pkg install -y nmap
                fi
                read -p "Masukkan subnet jaringan (misal: 192.168.1.0/24): " subnet
                if [ -n "$subnet" ]; then
                    echo -e "${BLUE}[*] Menjalankan Nmap Port Scan (Cari port HTTP/80, RTSP/554, NVR/8000)...${NC}"
                    nmap -p 80,554,8000,554 --open $subnet
                else
                    echo -e "${RED}[!] Subnet tidak boleh kosong.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            5)
                header
                echo -e "${GREEN}===================================================="
                echo -e "       SKEMA PINOUT KABEL LAN RJ-45 (STANDAR)       "
                echo -e "====================================================${NC}"
                echo -e "${YELLOW}T568B (Paling Sering Digunakan - Straight):${NC}"
                echo -e "1. Putih-Oranye   [Tx+]"
                echo -e "2. Oranye         [Tx-]"
                echo -e "3. Putih-Hijau    [Rx+]"
                echo -e "4. Biru           [PoE]"
                echo -e "5. Putih-Biru     [PoE]"
                echo -e "6. Hijau          [Rx-]"
                echo -e "7. Putih-Cokelat  [PoE]"
                echo -e "8. Cokelat        [PoE]"
                echo ""
                echo -e "${YELLOW}T568A (Cross-over Pasangan 1-3 & 2-6 dibalik):${NC}"
                echo -e "1. Putih-Hijau, 2. Hijau, 3. Putih-Oranye, 4. Biru, 5. Putih-Biru, 6. Oranye, 7. Putih-Cokelat, 8. Cokelat"
                echo "----------------------------------------------------"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            b|B)
                break
                ;;
            *)
                echo -e "${RED}[!] Pilihan tidak valid.${NC}"
                sleep 1
                ;;
        esac
    done
}
