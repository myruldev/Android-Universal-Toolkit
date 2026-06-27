#!/bin/bash
# AUT - Security & Debloat Module
# Penulis: myruldev

security_menu() {
    while true; do
        header
        section "Security, App Manager & Debloat"
        item "1" "Audit Aplikasi Berisiko Tinggi (Kamera & Lokasi)"
        item "2" "Cabut Izin Sensitif Secara Paksa"
        item "3" "Jalankan Debloater (Xiaomi / Universal)"
        item "4" "Freezer (Bekukan Aplikasi)"
        item "5" "Cairkan Aplikasi yang Dibekukan"
        back_item
        ask_choice

        case $REPLY_CHOICE in
            1)
                echo ""
                msg_info "Memeriksa aplikasi dengan izin tingkat tinggi..."
                echo ""
                echo -e "  ${C_TITLE}Aplikasi dengan izin Kamera${NC}"
                sh_run "pm list packages -g android.permission.CAMERA" \
                    | sed 's/^package://' | sed 's/^/    /' | head -n 15
                echo ""
                echo -e "  ${C_TITLE}Aplikasi dengan izin Lokasi${NC}"
                sh_run "pm list packages -g android.permission.ACCESS_FINE_LOCATION" \
                    | sed 's/^package://' | sed 's/^/    /' | head -n 15
                pause
                ;;
            2)
                echo ""
                read -rp "  Nama paket (contoh: com.facebook.katana): " pkg
                read -rp "  Izin yang dicabut (contoh: android.permission.CAMERA): " perm
                if [ -n "$pkg" ] && [ -n "$perm" ]; then
                    echo ""
                    msg_info "Mencabut izin ${perm} dari ${pkg}..."
                    sh_run "pm revoke $pkg $perm"
                    msg_ok "Izin berhasil dicabut."
                else
                    msg_err "Paket dan izin tidak boleh kosong."
                fi
                pause
                ;;
            3)
                echo ""
                msg_info "Mencari modul debloater eksternal..."
                if [ -f "../Android-Universal-Debloat/aud.sh" ]; then
                    bash ../Android-Universal-Debloat/aud.sh
                elif [ -f "../MiDebloat-Remover/mdr.sh" ]; then
                    bash ../MiDebloat-Remover/mdr.sh
                else
                    msg_err "Debloater eksternal tidak terdeteksi."
                    echo -e "  ${C_DIM}Unduh: https://github.com/myruldev/Android-Universal-Debloat${NC}"
                fi
                pause
                ;;
            4)
                echo ""
                read -rp "  Nama paket yang ingin dibekukan: " pkg
                if [ -n "$pkg" ]; then
                    sh_run "pm disable-user --user 0 $pkg"
                    msg_ok "Aplikasi $pkg berhasil dibekukan."
                else
                    msg_err "Nama paket tidak boleh kosong."
                fi
                pause
                ;;
            5)
                echo ""
                read -rp "  Nama paket yang ingin dicairkan: " pkg
                if [ -n "$pkg" ]; then
                    sh_run "pm enable $pkg"
                    msg_ok "Aplikasi $pkg berhasil diaktifkan kembali."
                else
                    msg_err "Nama paket tidak boleh kosong."
                fi
                pause
                ;;
            0) break ;;
            *) invalid_choice ;;
        esac
    done
}
