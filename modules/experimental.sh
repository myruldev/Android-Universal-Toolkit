#!/bin/bash
# AUT - Experimental & System Tools Module
# Penulis: myruldev

experimental_menu() {
    while true; do
        header
        echo -e "${YELLOW}>> MODULE: EXPERIMENTAL & SYSTEM TOOLS <<${NC}"
        echo -e "1. 🖥️ Ubah Resolusi Layar (wm size)"
        echo -e "2. 📐 Ubah Kerapatan Layar (wm density / DPI)"
        echo -e "3. 🔓 Buka Menu Pengaturan Tersembunyi (Hidden Settings)"
        echo -e "4. 🔄 Reset Resolusi & DPI ke Bawaan Pabrik"
        echo -e "b. Kembali ke Menu Utama"
        echo ""
        read -p "Pilih opsi: " exp_choice

        case $exp_choice in
            1)
                echo -e "${RED}[!] Perhatian: Mengubah resolusi bisa menyebabkan tampilan kacau jika tidak didukung.${NC}"
                echo -e "Resolusi saat ini: $(rish -c 'wm size')"
                read -p "Masukkan resolusi baru (contoh: 720x1280 atau 1080x1920): " res
                if [ -n "$res" ]; then
                    rish -c "wm size $res"
                    echo -e "${GREEN}[+] Resolusi diubah ke $res.${NC}"
                else
                    echo -e "${RED}[!] Input tidak boleh kosong.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            2)
                echo -e "${RED}[!] Perhatian: Mengubah DPI bisa membuat UI terlalu besar/kecil.${NC}"
                echo -e "DPI saat ini: $(rish -c 'wm density')"
                read -p "Masukkan DPI baru (contoh: 320, 360, 440): " dpi
                if [ -n "$dpi" ]; then
                    rish -c "wm density $dpi"
                    echo -e "${GREEN}[+] DPI diubah ke $dpi.${NC}"
                else
                    echo -e "${RED}[!] Input tidak boleh kosong.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            3)
                header
                echo -e "${YELLOW}>> BUKA PENGATURAN TERSEMBUNYI <<${NC}"
                echo -e "1. Notification Log (Riwayat Notifikasi)"
                echo -e "2. Bandwidth Control"
                echo -e "3. Developer Options (Opsi Pengembang)"
                echo -e "b. Kembali"
                read -p "Pilih opsi: " hide_opt
                case $hide_opt in
                    1) rish -c "am start -n com.android.settings/.Settings\$NotificationStationActivity" 2>/dev/null ;;
                    2) rish -c "am start -n com.android.settings/.Settings\$BandwidthcontrolSettingsActivity" 2>/dev/null ;;
                    3) rish -c "am start -n com.android.settings/.Settings\$DevelopmentSettingsDashboardActivity" 2>/dev/null ;;
                    *) ;;
                esac
                ;;
            4)
                echo -e "${BLUE}[*] Meriset resolusi dan DPI ke default pabrik...${NC}"
                rish -c "wm size reset"
                rish -c "wm density reset"
                echo -e "${GREEN}[+] Sukses! Layar kembali normal.${NC}"
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
