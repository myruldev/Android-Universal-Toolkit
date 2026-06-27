#!/bin/bash
# AUT - Diagnostics Module
# Penulis: myruldev

diagnostics_menu() {
    while true; do
        header
        echo -e "${YELLOW}>> MODULE: DIAGNOSTICS & SYSTEM INFO <<${NC}"
        echo -e "1. 📱 Tampilkan Detail Informasi Perangkat (HW & Partisi)"
        echo -e "2. 🌡️ Monitor Suhu CPU (Thermal Health)"
        echo -e "3. 📋 Live Logcat Stream (Monitor Error System)"
        echo -e "4. 🤖 Analisis Logcat Terakhir menggunakan AI OpenRouter"
        echo -e "b. Kembali ke Menu Utama"
        echo ""
        read -p "Pilih opsi: " diag_choice

        case $diag_choice in
            1)
                header
                echo -e "${YELLOW}[*] Detail Informasi Sistem Perangkat:${NC}"
                echo "--------------------------------------------------------"
                echo -e "${BLUE}Model Perangkat:${NC} $(rish -c 'getprop ro.product.model')"
                echo -e "${BLUE}Sistem Operasi :${NC} Android $(rish -c 'getprop ro.build.version.release') (SDK $(rish -c 'getprop ro.build.version.sdk'))"
                echo -e "${BLUE}Merek & Pabrik :${NC} $(rish -c 'getprop ro.product.brand') / $(rish -c 'getprop ro.product.manufacturer')"
                echo -e "${BLUE}Security Patch :${NC} $(rish -c 'getprop ro.build.version.security_patch')"
                echo -e "${BLUE}Arsitektur CPU :${NC} $(rish -c 'getprop ro.product.cpu.abi')"
                echo "--------------------------------------------------------"
                echo -e "${YELLOW}[*] Penggunaan Penyimpanan / Partisi:${NC}"
                rish -c "df -h /data /storage/emulated"
                echo "--------------------------------------------------------"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            2)
                echo -e "${BLUE}[*] Membaca sensor termal CPU (Tekan Ctrl+C untuk berhenti)...${NC}"
                sleep 1
                for i in {1..10}; do
                    clear
                    header
                    echo -e "${YELLOW}>> LIVE TEMPERATURE MONITOR <<${NC}"
                    echo "--------------------------------------------------------"
                    # Mencari info thermal dari android sysfs
                    temp=$(rish -c "cat /sys/class/thermal/thermal_zone*/temp" 2>/dev/null | head -n 1)
                    if [ -n "$temp" ]; then
                        # Biasanya suhu dikali 1000, misal 41000 = 41C
                        temp_c=$((temp / 1000))
                        echo -e "Suhu CPU Utama: ${RED}${temp_c}°C${NC}"
                        if [ $temp_c -gt 45 ]; then
                            echo -e "${RED}[!] Peringatan: Thermal Throttling Aktif! HP Terlalu Panas.${NC}"
                        else
                            echo -e "${GREEN}[+] Suhu Normal.${NC}"
                        fi
                    else
                        # Alternatif menggunakan dumpsys battery
                        rish -c "dumpsys battery | grep temperature" | sed 's/temperature:/Suhu Baterai:/' | awk '{print $1 " " $2/10 "°C"}'
                    fi
                    echo "--------------------------------------------------------"
                    sleep 1.5
                done
                read -p "Selesai. Tekan Enter untuk melanjutkan..."
                ;;
            3)
                echo -e "${YELLOW}[*] Memulai Logcat Stream. Tekan Ctrl+C untuk berhenti.${NC}"
                sleep 1
                rish -c "logcat *:E" # Hanya tampilkan level Error ke atas
                ;;
            4)
                echo -e "${BLUE}[*] Mengambil 100 baris terakhir logcat error...${NC}"
                rish -c "logcat -d *:E | tail -n 100" > /mnt/work/Android-Universal-Toolkit/logcat_temp.txt 2>/dev/null
                if [ ! -s "/mnt/work/Android-Universal-Toolkit/logcat_temp.txt" ]; then
                    # Jika di dalam termux non-root
                    logcat -d *:E | tail -n 100 > /mnt/work/Android-Universal-Toolkit/logcat_temp.txt 2>/dev/null
                fi
                echo -e "${GREEN}[+] Logcat berhasil diambil.${NC}"
                echo -e "${BLUE}[*] Mengirim data ke AI OpenRouter untuk dianalisis...${NC}"
                python3 helpers/ai_helper.py "Tolong analisis file logcat berikut dan berikan penjelasan ringkas mengenai error yang terjadi, penyebabnya, serta solusi perbaikannya." "/mnt/work/Android-Universal-Toolkit/logcat_temp.txt"
                rm -f /mnt/work/Android-Universal-Toolkit/logcat_temp.txt
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
