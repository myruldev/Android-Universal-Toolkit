#!/bin/bash
# AUT - Emergency & Recovery Module
# Penulis: myruldev

emergency_menu() {
    while true; do
        header
        section "Emergency & Recovery Mode"
        item "1" "Safe Mode Boot (Paksa Boot ke Safe Mode)"
        item "2" "Soft Reboot SystemUI (Atasi Layar Beku)"
        item "3" "Force Stop Semua Aplikasi User"
        item "4" "Clear Cache & Data Aplikasi Tertentu"
        back_item
        ask_choice

        case $REPLY_CHOICE in
            1) emerg_safe_mode ;;
            2) emerg_restart_systemui ;;
            3) emerg_force_stop_all ;;
            4) emerg_clear_app ;;
            0) break ;;
            *) invalid_choice ;;
        esac
    done
}

emerg_safe_mode() {
    echo ""
    msg_warn "Perangkat akan reboot dan masuk ke Safe Mode."
    if confirm "Yakin ingin melanjutkan?"; then
        echo ""
        msg_info "Mengatur properti safe mode dan reboot..."
        sh_run "setprop persist.sys.safemode 1"
        sh_run "reboot"
    fi
    pause
}

emerg_restart_systemui() {
    echo ""
    msg_info "Me-restart System UI (layar akan berkedip sesaat)..."
    sh_run "pkill -f com.android.systemui"
    msg_ok "System UI berhasil di-restart."
    pause
}

emerg_force_stop_all() {
    echo ""
    msg_info "Menghentikan paksa semua aplikasi pihak ketiga..."
    echo ""
    local packages pkg
    packages=$(sh_run "pm list packages -3" 2>/dev/null | cut -d':' -f2)
    if [ -z "$packages" ]; then
        msg_err "Tidak ada aplikasi pihak ketiga yang terbaca."
        pause
        return
    fi
    for pkg in $packages; do
        echo -e "    ${C_DIM}force-stop${NC} $pkg"
        sh_run "am force-stop $pkg"
    done
    msg_ok "Semua aplikasi pihak ketiga telah dihentikan."
    pause
}

emerg_clear_app() {
    echo ""
    read -rp "  Nama paket yang ingin dibersihkan (contoh: com.instagram.android): " pkg
    if [ -z "$pkg" ]; then
        msg_err "Nama paket tidak boleh kosong."
        pause
        return
    fi
    msg_warn "Tindakan ini menghapus semua data & akun di aplikasi tersebut."
    if confirm "Lanjutkan?"; then
        echo ""
        msg_info "Membersihkan data $pkg..."
        sh_run "pm clear $pkg"
        msg_ok "Data aplikasi berhasil dikosongkan."
    fi
    pause
}
