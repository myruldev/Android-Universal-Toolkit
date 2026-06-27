#!/bin/bash
# AUT - Performance Module
# Penulis: myruldev

performance_menu() {
    while true; do
        header
        section "Performance Optimizer"
        item "1" "Speed Up Apps (Compile Dexopt Speed)"
        item "2" "Extreme Doze Mode (Force Idle)"
        item "3" "Lock Refresh Rate (90Hz / 120Hz)"
        item "4" "Trim Memory & Drop Caches"
        back_item
        ask_choice

        case $REPLY_CHOICE in
            1)
                echo ""
                msg_info "Mengoptimalkan semua aplikasi (Dexopt Speed)..."
                msg_info "Menjalankan: cmd package compile -m speed -a"
                sh_run "cmd package compile -m speed -a"
                msg_ok "Semua aplikasi telah dikompilasi secara AOT."
                pause
                ;;
            2)
                echo ""
                msg_info "Memaksa perangkat masuk Aggressive Doze Mode..."
                sh_run "dumpsys deviceidle force-idle"
                msg_ok "Mode hemat daya ekstrem diaktifkan."
                pause
                ;;
            3)
                echo ""
                echo -e "  Pilih refresh rate:"
                item "1" "90 Hz"
                item "2" "120 Hz"
                ask_choice
                case $REPLY_CHOICE in
                    1)
                        sh_run "settings put system peak_refresh_rate 90.0"
                        sh_run "settings put system min_refresh_rate 90.0"
                        msg_ok "Refresh rate dikunci di 90 Hz."
                        ;;
                    2)
                        sh_run "settings put system peak_refresh_rate 120.0"
                        sh_run "settings put system min_refresh_rate 120.0"
                        msg_ok "Refresh rate dikunci di 120 Hz."
                        ;;
                    *) msg_err "Pilihan tidak valid." ;;
                esac
                pause
                ;;
            4)
                echo ""
                msg_info "Membersihkan cache memori RAM perangkat..."
                sh_run "am kill-all"
                msg_ok "Cache memori dibersihkan, RAM dibebaskan."
                pause
                ;;
            0) break ;;
            *) invalid_choice ;;
        esac
    done
}
