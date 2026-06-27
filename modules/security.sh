#!/bin/bash
# AUT - Security & Debloat Module
# Penulis: myruldev

security_menu() {
    while true; do
        header
        echo -e "${YELLOW}>> MODULE: SECURITY & DEBLOAT <<${NC}"
        echo -e "1. 🔍 Audit Aplikasi Berisiko Tinggi (Mic, Kamera, Lokasi)"
        echo -e "2. 🚫 Cabut Izin Sensitif Secara Paksa"
        echo -e "3. 🧹 Jalankan Debloater Xiaomi/Universal"
        echo -e "4. ❄️ Freezer (Bekukan Aplikasi Latar Belakang)"
        echo -e "5. 🔥 Cairkan Aplikasi yang Dibekukan"
        echo -e "b. Kembali ke Menu Utama"
        echo ""
        read -p "Pilih opsi: " sec_choice

        case $sec_choice in
            1)
                echo -e "${BLUE}[*] Memeriksa aplikasi dengan izin tingkat tinggi...${NC}"
                echo -e "${YELLOW}Aplikasi yang memiliki izin KAMERA:${NC}"
                rish -c "pm list packages -g android.permission.CAMERA" | head -n 15
                echo ""
                echo -e "${YELLOW}Aplikasi yang memiliki izin LOKASI:${NC}"
                rish -c "pm list packages -g android.permission.ACCESS_FINE_LOCATION" | head -n 15
                echo ""
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            2)
                read -p "Masukkan nama paket aplikasi (contoh: com.facebook.katana): " pkg
                read -p "Masukkan izin yang ingin dicabut (contoh: android.permission.CAMERA): " perm
                if [ -n "$pkg" ] && [ -n "$perm" ]; then
                    echo -e "${BLUE}[*] Mencabut izin ${perm} dari paket ${pkg}...${NC}"
                    rish -c "pm revoke $pkg $perm"
                    echo -e "${GREEN}[+] Sukses! Izin berhasil dicabut secara paksa.${NC}"
                else
                    echo -e "${RED}[!] Paket atau izin tidak boleh kosong.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            3)
                echo -e "${BLUE}[*] Membuka modul debloater eksternal...${NC}"
                # Deteksi otomatis repo debloater terinstall
                if [ -f "../Android-Universal-Debloat/aud.sh" ]; then
                    bash ../Android-Universal-Debloat/aud.sh
                elif [ -f "../MiDebloat-Remover/mdr.sh" ]; then
                    bash ../MiDebloat-Remover/mdr.sh
                else
                    echo -e "${RED}[!] Debloater eksternal tidak terdeteksi di folder terdekat.${NC}"
                    echo -e "Unduh tool di: https://github.com/myruldev/Android-Universal-Debloat"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            4)
                read -p "Masukkan nama paket aplikasi yang ingin dibekukan: " pkg
                if [ -n "$pkg" ]; then
                    rish -c "pm disable-user --user 0 $pkg"
                    echo -e "${GREEN}[+] Sukses! Aplikasi $pkg berhasil dibekukan.${NC}"
                else
                    echo -e "${RED}[!] Nama paket tidak valid.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            5)
                read -p "Masukkan nama paket aplikasi yang ingin dicairkan: " pkg
                if [ -n "$pkg" ]; then
                    rish -c "pm enable $pkg"
                    echo -e "${GREEN}[+] Sukses! Aplikasi $pkg berhasil diaktifkan kembali.${NC}"
                else
                    echo -e "${RED}[!] Nama paket tidak valid.${NC}"
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
