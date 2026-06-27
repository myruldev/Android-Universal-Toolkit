#!/bin/bash
# AUT - Experimental & System Tools Module
# Penulis: myruldev

experimental_menu() {
    while true; do
        header
        section "Experimental & System Scaling"
        item "1" "Ubah Resolusi Layar (wm size)"
        item "2" "Ubah Kerapatan Layar (wm density / DPI)"
        item "3" "Buka Pengaturan Tersembunyi"
        item "4" "Reset Resolusi & DPI ke Bawaan"
        back_item
        ask_choice

        case $REPLY_CHOICE in
            1) exp_change_resolution ;;
            2) exp_change_dpi ;;
            3) exp_hidden_settings ;;
            4) exp_reset_display ;;
            0) break ;;
            *) invalid_choice ;;
        esac
    done
}

exp_change_resolution() {
    echo ""
    msg_warn "Mengubah resolusi bisa membuat tampilan kacau jika tidak didukung."
    echo -e "  Resolusi saat ini: $(sh_run 'wm size')"
    read -rp "  Resolusi baru (contoh: 720x1280 / 1080x1920): " res
    if [ -n "$res" ]; then
        sh_run "wm size $res"
        msg_ok "Resolusi diubah ke $res."
    else
        msg_err "Input tidak boleh kosong."
    fi
    pause
}

exp_change_dpi() {
    echo ""
    msg_warn "Mengubah DPI bisa membuat UI terlalu besar/kecil."
    echo -e "  DPI saat ini: $(sh_run 'wm density')"
    read -rp "  DPI baru (contoh: 320, 360, 440): " dpi
    if [ -n "$dpi" ]; then
        sh_run "wm density $dpi"
        msg_ok "DPI diubah ke $dpi."
    else
        msg_err "Input tidak boleh kosong."
    fi
    pause
}

exp_hidden_settings() {
    header
    section "Pengaturan Tersembunyi"
    item "1" "Notification Log (Riwayat Notifikasi)"
    item "2" "Bandwidth Control"
    item "3" "Developer Options"
    back_item
    ask_choice
    case $REPLY_CHOICE in
        1) sh_run "am start -n com.android.settings/.Settings\$NotificationStationActivity" 2>/dev/null ;;
        2) sh_run "am start -n com.android.settings/.Settings\$BandwidthcontrolSettingsActivity" 2>/dev/null ;;
        3) sh_run "am start -n com.android.settings/.Settings\$DevelopmentSettingsDashboardActivity" 2>/dev/null ;;
        0) return ;;
        *) invalid_choice ;;
    esac
}

exp_reset_display() {
    echo ""
    msg_info "Mereset resolusi dan DPI ke bawaan pabrik..."
    sh_run "wm size reset"
    sh_run "wm density reset"
    msg_ok "Layar kembali normal."
    pause
}
