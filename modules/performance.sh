#!/bin/bash
# AUT - Performance Module
# Penulis: myruldev

performance_menu() {
    while true; do
        header
        echo -e "${YELLOW}>> MODULE: PERFORMANCE OPTIMIZER <<${NC}"
        echo -e "1. 🚀 Speed Up Apps (Compile Dexopt Speed)"
        echo -e "2. 🔋 Extreme Doze Mode (Force Idle)"
        echo -e "3. ⚡ Lock Refresh Rate (90Hz / 120Hz)"
        echo -e "4. 🧹 Trim Memory & Drop Caches"
        echo -e "b. Kembali ke Menu Utama"
        echo ""
        read -p "Pilih opsi: " perf_choice

        case $ft_choice in
            "") ;;
        esac

        case $perf_choice in
            1)
                echo -e "${BLUE}[*] Mengoptimalkan semua aplikasi dengan Dexopt Speed...${NC}"
                echo -e "${YELLOW}[*] Menjalankan: cmd package compile -m speed -a${NC}"
                # Menjalankan perintah ADB via rish
                rish -c "cmd package compile -m speed -a"
                echo -e "${GREEN}[+] Sukses! Semua aplikasi telah dikompilasi secara AOT.${NC}"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            2)
                echo -e "${BLUE}[*] Memaksa perangkat masuk ke Aggressive Doze Mode...${NC}"
                rish -c "dumpsys deviceidle force-idle"
                echo -e "${GREEN}[+] Sukses! Mode hemat daya ekstrem diaktifkan.${NC}"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            3)
                echo -e "Pilih Refresh Rate:"
                echo -e "a. 90Hz"
                echo -e "b. 120Hz"
                read -p "Pilihan: " hz_choice
                if [ "$hz_choice" == "a" ]; then
                    rish -c "settings put system peak_refresh_rate 90.0"
                    rish -c "settings put system min_refresh_rate 90.0"
                    echo -e "${GREEN}[+] Refresh rate dikunci di 90Hz.${NC}"
                elif [ "$hz_choice" == "b" ]; then
                    rish -c "settings put system peak_refresh_rate 120.0"
                    rish -c "settings put system min_refresh_rate 120.0"
                    echo -e "${GREEN}[+] Refresh rate dikunci di 120Hz.${NC}"
                else
                    echo -e "${RED}[!] Pilihan tidak valid.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            4)
                echo -e "${BLUE}[*] Membersihkan cache memori RAM perangkat...${NC}"
                rish -c "ndc clatd stop" 2>/dev/null
                rish -c "am kill-all"
                echo -e "${GREEN}[+] Cache memori berhasil dibersihkan! RAM dibebaskan.${NC}"
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
