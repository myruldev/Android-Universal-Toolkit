#!/bin/bash
# AUT - Network & WiFi Module
# Penulis: myruldev

network_menu() {
    while true; do
        header
        echo -e "${YELLOW}>> MODULE: NETWORK & WIFI TOOLS <<${NC}"
        echo -e "1. 🔑 Tampilkan Password WiFi Terarsip (Butuh Shizuku)"
        echo -e "2. 🌐 DNS Switcher (Bypass Internet Positif & AdBlock)"
        echo -e "3. 🔄 Reset Network Stack (Wi-Fi/Bluetooth/Mobile)"
        echo -e "4. 📡 Monitor Kecepatan Jaringan Real-time (ifstat)"
        echo -e "5. 📶 Scan Sinyal WiFi & Channel Sekitar"
        echo -e "b. Kembali ke Menu Utama"
        echo ""
        read -p "Pilih opsi: " net_choice

        case $net_choice in
            1)
                echo -e "${BLUE}[*] Membaca konfigurasi WiFi terarsip via Shizuku...${NC}"
                # Membaca file konfigurasi WiFi WPA supplicant / WifiConfigStore
                # Memerlukan hak akses Shizuku/ADB untuk membaca data aman ini
                echo -e "${YELLOW}Daftar Jaringan & Password tersimpan:${NC}"
                echo "--------------------------------------------------------"
                
                # Command untuk membaca file wifi di Android 10+ via dumpsys / cat jika diizinkan ADB
                wifi_data=$(rish -c "cat /data/misc/wifi/WifiConfigStore.xml" 2>/dev/null)
                if [ -n "$wifi_data" ]; then
                    echo "$wifi_data" | grep -E "<string name="SSID">|<string name="PreSharedKey">" | sed 's/<[^>]*>//g' | sed 's/^[ 	]*//'
                else
                    # Alternatif menggunakan dumpsys wifi
                    rish -c "dumpsys wifi | grep -E 'SSID:|preSharedKey='" | head -n 30
                fi
                echo "--------------------------------------------------------"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            2)
                echo -e "Pilih Mode DNS:"
                echo -e "1. Cloudflare DNS (Bypass Cepat)"
                echo -e "2. AdGuard DNS (Anti Iklan & Malware)"
                echo -e "3. Kembalikan ke Otomatis (Default)"
                read -p "Pilihan: " dns_opt
                if [ "$dns_opt" == "1" ]; then
                    rish -c "settings put global private_dns_mode hostname"
                    rish -c "settings put global private_dns_specifier one.one.one.one"
                    echo -e "${GREEN}[+] DNS diatur ke Cloudflare (one.one.one.one)${NC}"
                elif [ "$dns_opt" == "2" ]; then
                    rish -c "settings put global private_dns_mode hostname"
                    rish -c "settings put global private_dns_specifier dns.adguard.com"
                    echo -e "${GREEN}[+] DNS diatur ke AdGuard (dns.adguard.com)${NC}"
                elif [ "$dns_opt" == "3" ]; then
                    rish -c "settings put global private_dns_mode opportunistic"
                    echo -e "${GREEN}[+] DNS diatur kembali ke Otomatis.${NC}"
                else
                    echo -e "${RED}[!] Pilihan tidak valid.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            3)
                echo -e "${RED}[!] Perhatian: Koneksi nirkabel akan terputus sesaat.${NC}"
                read -p "Apakah Anda yakin ingin meriset stack jaringan? (y/n): " confirm_net
                if [ "$confirm_net" == "y" ] || [ "$confirm_net" == "Y" ]; then
                    echo -e "${BLUE}[*] Meriset jaringan...${NC}"
                    rish -c "svc wifi disable"
                    sleep 1
                    rish -c "svc data disable"
                    sleep 1
                    rish -c "svc wifi enable"
                    sleep 1
                    rish -c "svc data enable"
                    echo -e "${GREEN}[+] Reset stack jaringan selesai!${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            4)
                if ! command -v ifstat &> /dev/null; then
                    echo -e "${YELLOW}[*] Menginstall ifstat untuk monitoring...${NC}"
                    pkg install -y ifstat
                fi
                echo -e "${GREEN}[*] Memulai monitoring. Tekan Ctrl+C untuk berhenti.${NC}"
                sleep 1
                ifstat -i wlan0 1 15
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            5)
                echo -e "${BLUE}[*] Memindai WiFi sekitar via Shizuku...${NC}"
                rish -c "cmd wifi list-scan-results" | head -n 30
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
