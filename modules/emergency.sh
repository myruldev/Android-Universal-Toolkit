#!/bin/bash
# AUT - Emergency & Recovery Module
# Penulis: myruldev

emergency_menu() {
    while true; do
        header
        echo -e "${YELLOW}>> MODULE: EMERGENCY & RECOVERY <<${NC}"
        echo -e "1. 🚨 Safe Mode Boot (Paksa Boot ke Safe Mode)"
        echo -e "2. 🔄 Soft Reboot SystemUI (Mengatasi Layar Beku/Glitch)"
        echo -e "3. 🧹 Force Stop Semua Aplikasi User (Bebaskan RAM Darurat)"
        echo -e "4. 💣 Clear All Cache & Data Aplikasi Tertentu"
        echo -e "b. Kembali ke Menu Utama"
        echo ""
        read -p "Pilih opsi: " emerg_choice

        case $emerg_choice in
            1)
                echo -e "${RED}[!] HP akan reboot dan masuk ke Safe Mode.${NC}"
                read -p "Apakah Anda yakin? (y/n): " confirm_safe
                if [ "$confirm_safe" == "y" ] || [ "$confirm_safe" == "Y" ]; then
                    echo -e "${BLUE}[*] Mengatur properti boot safe mode dan rebooting...${NC}"
                    rish -c "setprop persist.sys.safemode 1"
                    rish -c "reboot"
                fi
                ;;
            2)
                echo -e "${BLUE}[*] Me-restart System UI (Layar akan berkedip sesaat)...${NC}"
                # Membunuh proses SystemUI, Android otomatis akan me-launching ulang
                rish -c "pkill -f com.android.systemui"
                echo -e "${GREEN}[+] System UI berhasil di-restart.${NC}"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            3)
                echo -e "${BLUE}[*] Menghentikan paksa semua proses latar belakang aplikasi pihak ketiga...${NC}"
                # Mendapatkan semua paket user dan melakukan force-stop
                packages=$(rish -c "pm list packages -3" | cut -d':' -f2)
                for pkg in $packages; do
                    echo -e "Force-stopping: ${YELLOW}$pkg${NC}"
                    rish -c "am force-stop $pkg"
                done
                echo -e "${GREEN}[+] Sukses! Semua aplikasi pihak ketiga telah dihentikan.${NC}"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            4)
                read -p "Masukkan nama paket aplikasi yang ingin dibersihkan (contoh: com.instagram.android): " pkg
                if [ -n "$pkg" ]; then
                    echo -e "${RED}[!] Tindakan ini akan menghapus semua data & akun di aplikasi tersebut!${NC}"
                    read -p "Lanjutkan? (y/n): " confirm_clear
                    if [ "$confirm_clear" == "y" ] || [ "$confirm_clear" == "Y" ]; then
                        echo -e "${BLUE}[*] Membersihkan data $pkg...${NC}"
                        rish -c "pm clear $pkg"
                        echo -e "${GREEN}[+] Sukses! Data aplikasi berhasil dikosongkan.${NC}"
                    fi
                else
                    echo -e "${RED}[!] Nama paket tidak boleh kosong.${NC}"
                fi
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
