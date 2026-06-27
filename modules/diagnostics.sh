#!/bin/bash
# AUT - Diagnostics Module
# Penulis: myruldev

diagnostics_menu() {
    while true; do
        header
        section "Diagnostics, System Info & Logcat"
        item "1" "Device Info (Hardware & Partisi)"
        item "2" "Monitor Suhu CPU (Thermal Health)"
        item "3" "Live Logcat Stream (Level Error)"
        item "4" "Analisis Logcat dengan AI (OpenRouter)"
        back_item
        ask_choice

        case $REPLY_CHOICE in
            1) diag_device_info ;;
            2) diag_thermal ;;
            3) diag_logcat ;;
            4) diag_logcat_ai ;;
            0) break ;;
            *) invalid_choice ;;
        esac
    done
}

diag_device_info() {
    header
    section "Device Info"
    printf "    %-16s: %s\n" "Model"          "$(sh_run 'getprop ro.product.model')"
    printf "    %-16s: Android %s (SDK %s)\n" "Sistem Operasi" \
        "$(sh_run 'getprop ro.build.version.release')" \
        "$(sh_run 'getprop ro.build.version.sdk')"
    printf "    %-16s: %s / %s\n" "Merek / Pabrik" \
        "$(sh_run 'getprop ro.product.brand')" \
        "$(sh_run 'getprop ro.product.manufacturer')"
    printf "    %-16s: %s\n" "Security Patch" "$(sh_run 'getprop ro.build.version.security_patch')"
    printf "    %-16s: %s\n" "Arsitektur CPU" "$(sh_run 'getprop ro.product.cpu.abi')"
    echo ""
    echo -e "  ${C_TITLE}Penyimpanan / Partisi${NC}"
    sh_run "df -h /data /storage/emulated" 2>/dev/null | sed 's/^/    /'
    pause
}

diag_thermal() {
    echo ""
    msg_info "Membaca sensor termal (Ctrl+C untuk berhenti)..."
    sleep 1
    local i temp temp_c
    for i in $(seq 1 10); do
        header
        section "Live Temperature Monitor"
        temp=$(sh_run "cat /sys/class/thermal/thermal_zone*/temp" 2>/dev/null | head -n 1)
        if [ -n "$temp" ] && [ "$temp" -eq "$temp" ] 2>/dev/null; then
            temp_c=$((temp / 1000))
            echo -e "    Suhu CPU: ${C_ACCENT}${temp_c}°C${NC}"
            if [ "$temp_c" -gt 45 ]; then
                msg_warn "Thermal throttling aktif, perangkat terlalu panas."
            else
                msg_ok "Suhu normal."
            fi
        else
            # Fallback ke suhu baterai (nilai dumpsys = derajat x10).
            local batt
            batt=$(sh_run "dumpsys battery" 2>/dev/null | grep -i temperature | grep -oE '[0-9]+' | head -n 1)
            if [ -n "$batt" ]; then
                echo -e "    Suhu Baterai: ${C_ACCENT}$((batt / 10))°C${NC}"
            else
                echo "    Data sensor termal tidak tersedia."
            fi
        fi
        sleep 1.5
    done
    pause
}

diag_logcat() {
    echo ""
    msg_info "Memulai Logcat Stream level Error (Ctrl+C untuk berhenti)..."
    sleep 1
    sh_run "logcat *:E"
}

diag_logcat_ai() {
    echo ""
    msg_info "Mengambil 100 baris terakhir logcat error..."
    local tmpf
    tmpf=$(mktemp 2>/dev/null) || tmpf="$AUT_DIR/.aut_logcat.tmp"

    sh_run "logcat -d *:E" 2>/dev/null | tail -n 100 > "$tmpf"
    if [ ! -s "$tmpf" ]; then
        logcat -d *:E 2>/dev/null | tail -n 100 > "$tmpf"
    fi

    if [ ! -s "$tmpf" ]; then
        msg_err "Tidak ada data logcat yang dapat diambil."
        rm -f "$tmpf"
        pause
        return
    fi

    msg_ok "Logcat berhasil diambil."
    msg_info "Mengirim data ke AI OpenRouter untuk dianalisis..."
    echo -e "  ${C_DIM}$(_hline)${NC}"
    python3 helpers/ai_helper.py \
        "Analisis logcat berikut. Jelaskan ringkas error yang terjadi, penyebabnya, dan solusi perbaikannya." \
        "$tmpf"
    echo -e "  ${C_DIM}$(_hline)${NC}"
    rm -f "$tmpf"
    pause
}
