#!/bin/bash
# AUT - Network & WiFi Module
# Penulis: myruldev

network_menu() {
    while true; do
        header
        section "Network & WiFi Tools"
        item "1" "Tampilkan Password WiFi Tersimpan (Butuh Shizuku)"
        item "2" "DNS Switcher (Cloudflare / AdGuard / Otomatis)"
        item "3" "Reset Network Stack (WiFi / Bluetooth / Mobile)"
        item "4" "Monitor Kecepatan Jaringan (ifstat)"
        item "5" "Scan Sinyal WiFi Sekitar"
        back_item
        ask_choice

        case $REPLY_CHOICE in
            1) network_show_wifi ;;
            2) network_dns_switcher ;;
            3) network_reset_stack ;;
            4) network_monitor ;;
            5) network_scan ;;
            0) break ;;
            *) invalid_choice ;;
        esac
    done
}

# Tampilkan info koneksi aktif + daftar password tersimpan (ringkas).
network_show_wifi() {
    echo ""
    msg_info "Membaca informasi WiFi via Shizuku..."
    echo ""

    echo -e "  ${C_TITLE}Koneksi WiFi Aktif${NC}"
    local dump; dump=$(sh_run "dumpsys wifi" 2>/dev/null)
    if [ -n "$dump" ]; then
        echo "$dump" | python3 helpers/wifi_parse.py current
    else
        echo "  Tidak dapat membaca status WiFi."
    fi
    echo ""

    echo -e "  ${C_TITLE}Jaringan Tersimpan${NC}"
    local store; store=$(sh_run "cat /data/misc/wifi/WifiConfigStore.xml" 2>/dev/null)
    if [ -n "$store" ]; then
        echo "$store" | python3 helpers/wifi_parse.py saved
    else
        echo "  Tidak dapat membaca file konfigurasi WiFi (izin tidak mencukupi)."
    fi
    pause
}

network_dns_switcher() {
    echo ""
    echo -e "  Pilih mode DNS:"
    item "1" "Cloudflare (one.one.one.one)"
    item "2" "AdGuard (dns.adguard.com)"
    item "3" "Kembalikan ke Otomatis"
    ask_choice
    case $REPLY_CHOICE in
        1)
            sh_run "settings put global private_dns_mode hostname"
            sh_run "settings put global private_dns_specifier one.one.one.one"
            msg_ok "DNS diatur ke Cloudflare."
            ;;
        2)
            sh_run "settings put global private_dns_mode hostname"
            sh_run "settings put global private_dns_specifier dns.adguard.com"
            msg_ok "DNS diatur ke AdGuard."
            ;;
        3)
            sh_run "settings put global private_dns_mode opportunistic"
            msg_ok "DNS dikembalikan ke Otomatis."
            ;;
        *) msg_err "Pilihan tidak valid." ;;
    esac
    pause
}

network_reset_stack() {
    echo ""
    msg_warn "Koneksi nirkabel akan terputus sesaat."
    if confirm "Yakin ingin mereset stack jaringan?"; then
        echo ""
        msg_info "Mereset jaringan..."
        sh_run "svc wifi disable"; sleep 1
        sh_run "svc data disable"; sleep 1
        sh_run "svc wifi enable";  sleep 1
        sh_run "svc data enable"
        msg_ok "Reset stack jaringan selesai."
    fi
    pause
}

network_monitor() {
    echo ""
    if ! command -v ifstat &> /dev/null; then
        msg_warn "Menginstall ifstat untuk monitoring..."
        pkg install -y ifstat
    fi
    msg_info "Memulai monitoring (Ctrl+C untuk berhenti)..."
    sleep 1
    ifstat -i wlan0 1 15
    pause
}

network_scan() {
    echo ""
    msg_info "Memindai jaringan WiFi sekitar via Shizuku..."
    echo ""
    sh_run "cmd wifi list-scan-results" 2>/dev/null | head -n 30
    pause
}
