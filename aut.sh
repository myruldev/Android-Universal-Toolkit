#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#               Android Universal Toolkit (AUT) - Main Launcher
# ==============================================================================
# Penulis     : myruldev
# Website     : www.myrul.dev
# Facebook    : facebook.com/myruldev
# Deskripsi   : Launcher menu interaktif modular untuk AUT.
# Persyaratan : Termux, Shizuku (rish aktif), Python 3 (fitur AI & CCTV).
# ==============================================================================

# --- Versi Aplikasi ---
VERSION="v1.0.0"

# --- Identitas Project ---
APP_NAME="Android Universal Toolkit (AUT)"
APP_WEBSITE="www.myrul.dev"
APP_FACEBOOK="facebook.com/myruldev"

# --- Palet Warna (ANSI) - minimalis & konsisten ---
C_BORDER='\033[0;36m'   # cyan   - bingkai
C_TITLE='\033[1;37m'    # putih  - judul section
C_NUM='\033[0;32m'      # hijau  - nomor menu
C_DIM='\033[0;90m'      # abu    - pemisah & petunjuk
C_OK='\033[0;32m'       # hijau  - sukses
C_ERR='\033[0;31m'      # merah  - error
C_WARN='\033[0;33m'     # kuning - peringatan
C_INFO='\033[0;34m'     # biru   - info proses
C_ACCENT='\033[0;36m'   # cyan   - penekanan
NC='\033[0m'            # reset

# Kompatibilitas warna lama (dipakai sebagian referensi/README)
GREEN="$C_OK"; RED="$C_ERR"; YELLOW="$C_WARN"; BLUE="$C_INFO"; CYAN="$C_ACCENT"; MAGENTA='\033[0;35m'

# --- Direktori Kerja ---
AUT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$AUT_DIR" || exit 1

# ==============================================================================
#  Helper Tampilan (UI) - dipakai bersama oleh seluruh modul
# ==============================================================================
BOX_WIDTH=50

# Garis horizontal sepanjang lebar bingkai bagian dalam.
_hline() { printf '─%.0s' $(seq 1 $((BOX_WIDTH - 2))); }

# Baris teks rata tengah di dalam bingkai.
_box_center() {
    local text="$1" inner=$((BOX_WIDTH - 2)) len=${#1} pad rpad
    pad=$(((inner - len) / 2)); rpad=$((inner - len - pad))
    printf "${C_BORDER}│${NC}%*s%s%*s${C_BORDER}│${NC}\n" "$pad" "" "$text" "$rpad" ""
}

# Baris teks rata kiri di dalam bingkai.
_box_left() {
    local text="$1" inner=$((BOX_WIDTH - 4))
    printf "${C_BORDER}│${NC}  %-*s${C_BORDER}│${NC}\n" "$((inner))" "$text"
}

# Logo ASCII (wordmark "AUT") - dipakai pada banner utama.
logo() {
    echo -e "${C_ACCENT}"
    echo "             █████  ██   ██ ████████ "
    echo "            ██   ██ ██   ██    ██    "
    echo "            ███████ ██   ██    ██    "
    echo "            ██   ██ ██   ██    ██    "
    echo "            ██   ██  █████     ██    "
    echo -e "${NC}"
}

# Header ringkas - dipakai di seluruh submenu agar tidak terlalu padat.
header() {
    clear
    local line; line=$(_hline)
    echo -e "${C_BORDER}┌${line}┐${NC}"
    _box_center "$APP_NAME"
    echo -e "${C_BORDER}├${line}┤${NC}"
    _box_left "Website  : $APP_WEBSITE"
    _box_left "Facebook : $APP_FACEBOOK"
    echo -e "${C_BORDER}└${line}┘${NC}"
    echo ""
}

# Banner penuh dengan logo ASCII - dipakai di splash & menu utama.
banner() {
    clear
    logo
    local line; line=$(_hline)
    echo -e "${C_BORDER}┌${line}┐${NC}"
    _box_center "$APP_NAME"
    _box_center "$VERSION"
    echo -e "${C_BORDER}├${line}┤${NC}"
    _box_left "Website  : $APP_WEBSITE"
    _box_left "Facebook : $APP_FACEBOOK"
    echo -e "${C_BORDER}└${line}┘${NC}"
    echo ""
}

# Animasi loading (spinner braille). Pemakaian: loading "Pesan" [siklus]
loading() {
    local msg="$1" cycles="${2:-12}" i
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    for ((i = 0; i < cycles; i++)); do
        printf "\r  ${C_ACCENT}%s${NC} %s" "${frames[i % 10]}" "$msg"
        sleep 0.08
    done
    printf "\r  ${C_OK}[+]${NC} %s\n" "$msg"
}

# Splash pembuka beranimasi saat aplikasi pertama dijalankan.
splash() {
    banner
    loading "Memuat modul AUT" 10
    loading "Memeriksa lingkungan Termux" 10
    loading "Menyiapkan antarmuka" 10
    sleep 0.2
}

# Judul sebuah section/menu beserta garis bawah.
section() {
    local title="$1" u
    u=$(printf '─%.0s' $(seq 1 ${#title}))
    echo -e "  ${C_TITLE}${title}${NC}"
    echo -e "  ${C_DIM}${u}${NC}"
    echo ""
}

# Satu baris item menu: nomor + label.
item() { printf "  ${C_NUM}%2s${NC}  %s\n" "$1" "$2"; }

# Item "kembali" standar untuk seluruh submenu.
back_item() { echo ""; item "0" "Kembali ke Menu Utama"; }

# Pesan status berformat seragam.
msg_ok()   { echo -e "  ${C_OK}[+]${NC} $1"; }
msg_err()  { echo -e "  ${C_ERR}[!]${NC} $1"; }
msg_warn() { echo -e "  ${C_WARN}[*]${NC} $1"; }
msg_info() { echo -e "  ${C_INFO}[*]${NC} $1"; }

# Jeda sebelum kembali ke menu.
pause() { echo ""; read -rp "  Tekan Enter untuk melanjutkan..." _; }

# Prompt pilihan yang konsisten. Hasil ada di variabel global REPLY_CHOICE.
ask_choice() { echo ""; read -rp "  Pilih opsi: " REPLY_CHOICE; }

# Pesan pilihan tidak valid.
invalid_choice() { msg_err "Pilihan tidak valid."; sleep 1; }

# Konfirmasi ya/tidak. Mengembalikan 0 jika pengguna setuju.
confirm() {
    local ans
    read -rp "  $1 (y/n): " ans
    [[ "$ans" == "y" || "$ans" == "Y" ]]
}

# Pembaruan nilai pada config/config.conf secara aman (escape karakter khusus).
update_config() {
    local key="$1" val="$2" esc
    esc=$(printf '%s' "$val" | sed -e 's/[\\&|]/\\&/g')
    if grep -q "^${key}=" config/config.conf; then
        sed -i "s|^${key}=.*|${key}=\"${esc}\"|" config/config.conf
    else
        echo "${key}=\"${val}\"" >> config/config.conf
    fi
}

# Jalankan perintah via Shizuku (rish). Memudahkan pemeliharaan.
sh_run() { rish -c "$1"; }

# ==============================================================================
#  Load Konfigurasi & Modul
# ==============================================================================
if [ -f "config/config.conf" ]; then
    source config/config.conf
else
    msg_err "File konfigurasi config/config.conf tidak ditemukan!"
    exit 1
fi

modules=(
    "modules/performance.sh"
    "modules/security.sh"
    "modules/network.sh"
    "modules/field_tech.sh"
    "modules/diagnostics.sh"
    "modules/experimental.sh"
    "modules/emergency.sh"
)

for mod in "${modules[@]}"; do
    if [ -f "$mod" ]; then
        source "$mod"
    else
        msg_err "Modul $mod tidak ditemukan!"
        exit 1
    fi
done

# ==============================================================================
#  Pemeriksaan Shizuku (rish)
# ==============================================================================
check_shizuku() {
    if ! command -v rish &> /dev/null; then
        header
        section "Pemeriksaan Shizuku"
        msg_err "'rish' (Shizuku shell) tidak terdeteksi di PATH Termux."
        msg_warn "Pastikan aplikasi Shizuku sudah aktif di perangkat Anda."
        msg_warn "Jalankan script pembantu Shizuku di Termux untuk mendaftarkan rish."
        echo ""
        if ! confirm "Lanjut tanpa Shizuku? (sebagian menu tidak berfungsi)"; then
            exit 1
        fi
    else
        if ! rish -c "echo -n" 2>/dev/null; then
            header
            section "Pemeriksaan Shizuku"
            msg_err "Shizuku terpasang tapi belum memberi izin akses ke Termux."
            msg_warn "Buka aplikasi Shizuku dan pastikan Termux dicentang 'Izinkan'."
            exit 1
        fi
    fi
}

# ==============================================================================
#  Menu AI Assistant
# ==============================================================================
ai_menu() {
    header
    section "AI Technical Assistant"
    if [ -z "$OPENROUTER_API_KEY" ]; then
        msg_err "API Key OpenRouter belum diatur."
        msg_info "Atur terlebih dahulu melalui menu Settings (9)."
        pause
        return
    fi

    echo -e "  Ketik pertanyaan untuk AI Assistant."
    echo -e "  ${C_DIM}Contoh: Bagaimana cara setting router bridge?${NC}"
    echo ""
    read -rp "  Pertanyaan: " ai_prompt
    if [ -n "$ai_prompt" ]; then
        echo ""
        msg_info "Menghubungi OpenRouter (${AI_MODEL})..."
        echo -e "  ${C_DIM}$(_hline)${NC}"
        python3 helpers/ai_helper.py "$ai_prompt"
        echo -e "  ${C_DIM}$(_hline)${NC}"
    fi
    pause
}

# ==============================================================================
#  Cek Update
# ==============================================================================
_fetch_remote_version() {
    curl -s --connect-timeout "$1" \
        "https://raw.githubusercontent.com/myruldev/Android-Universal-Toolkit/main/aut.sh" \
        2>/dev/null | grep -oE '^VERSION="v[0-9]+\.[0-9]+\.[0-9]+"' | cut -d'"' -f2
}

check_update() {
    local silent=$1

    if [ "$silent" = "true" ]; then
        command -v curl &>/dev/null || return
        local remote_ver; remote_ver=$(_fetch_remote_version 2)
        if [ -n "$remote_ver" ] && [ "$remote_ver" != "$VERSION" ]; then
            echo -e "  ${C_WARN}Update tersedia: ${C_OK}${remote_ver}${C_WARN} (saat ini: ${VERSION})${NC}"
            echo -e "  ${C_DIM}Pilih menu 9 -> opsi 4 untuk memperbarui.${NC}"
            echo ""
            sleep 2
        fi
        return
    fi

    header
    section "Cek Update Aplikasi"
    msg_info "Memeriksa pembaruan dari repositori GitHub..."
    if ! command -v curl &>/dev/null; then
        msg_err "'curl' tidak ditemukan. Install dengan: pkg install curl"
        pause
        return
    fi

    local remote_ver; remote_ver=$(_fetch_remote_version 4)
    echo ""
    if [ -z "$remote_ver" ]; then
        msg_err "Gagal mendapatkan informasi versi terbaru."
        msg_warn "Pastikan koneksi internet aktif dan repositori online."
    elif [ "$remote_ver" != "$VERSION" ]; then
        msg_ok "Terhubung ke repositori."
        echo ""
        echo -e "  Versi terbaru   : ${C_OK}${remote_ver}${NC}"
        echo -e "  Versi Anda      : ${C_WARN}${VERSION}${NC}"
        echo ""
        msg_info "Cara update:"
        echo -e "  ${C_DIM}1.${NC} Keluar dari aplikasi (0)."
        echo -e "  ${C_DIM}2.${NC} Jalankan di Termux:"
        echo -e "     ${C_ACCENT}curl -L -o AUT.zip https://github.com/myruldev/Android-Universal-Toolkit/archive/refs/heads/main.zip && unzip -o AUT.zip && rm AUT.zip${NC}"
    else
        msg_ok "Anda sudah menggunakan versi terbaru ($VERSION)."
    fi
    pause
}

# ==============================================================================
#  Menu Settings / Konfigurasi
# ==============================================================================
settings_menu() {
    while true; do
        header
        section "Settings / Konfigurasi"
        item "1" "Atur API Key OpenRouter"
        item "2" "Ganti Model AI (${AI_MODEL})"
        item "3" "Lihat Konfigurasi Saat Ini"
        item "4" "Cek Update Aplikasi (GitHub)"
        back_item
        ask_choice

        case $REPLY_CHOICE in
            1)
                echo ""
                echo -e "  API Key saat ini: ${C_WARN}${OPENROUTER_API_KEY:0:8}...${NC}"
                read -rp "  Masukkan API Key OpenRouter baru: " new_key
                if [ -n "$new_key" ]; then
                    update_config "OPENROUTER_API_KEY" "$new_key"
                    OPENROUTER_API_KEY="$new_key"
                    msg_ok "API Key berhasil diperbarui."
                fi
                sleep 1.5
                ;;
            2)
                echo ""
                echo -e "  Model saat ini: ${C_WARN}${AI_MODEL}${NC}"
                echo ""
                echo -e "  Pilih preset model:"
                item "1" "Gemini 2.0 Flash (gratis & cepat)"
                item "2" "Llama 3 8B Instruct (gratis & cerdas)"
                item "3" "Input nama model kustom"
                ask_choice
                local new_model=""
                case $REPLY_CHOICE in
                    1) new_model="google/gemini-2.0-flash-exp:free" ;;
                    2) new_model="meta-llama/llama-3-8b-instruct:free" ;;
                    3) read -rp "  Nama model OpenRouter lengkap: " new_model ;;
                esac
                if [ -n "$new_model" ]; then
                    update_config "AI_MODEL" "$new_model"
                    AI_MODEL="$new_model"
                    msg_ok "Model AI diubah ke $new_model."
                fi
                sleep 1.5
                ;;
            3)
                header
                section "Konfigurasi Saat Ini"
                while IFS= read -r line; do
                    [ -n "$line" ] && echo "  $line"
                done < config/config.conf
                pause
                ;;
            4) check_update "false" ;;
            0) break ;;
            *) invalid_choice ;;
        esac
    done
}

# ==============================================================================
#  Menu Utama
# ==============================================================================
main_menu() {
    while true; do
        banner
        section "Menu Utama"
        item "1" "Performance Optimizer"
        item "2" "Security, App Manager & Debloat"
        item "3" "Network & WiFi Tools"
        item "4" "Field Tech Tools (CCTV / IP Camera)"
        item "5" "Diagnostics, System Info & Logcat"
        item "6" "Experimental & System Scaling"
        item "7" "Emergency & Recovery Mode"
        item "8" "Ask AI Assistant (OpenRouter)"
        item "9" "Settings / Konfigurasi"
        echo ""
        item "0" "Keluar"
        ask_choice

        case $REPLY_CHOICE in
            1) performance_menu ;;
            2) security_menu ;;
            3) network_menu ;;
            4) field_tech_menu ;;
            5) diagnostics_menu ;;
            6) experimental_menu ;;
            7) emergency_menu ;;
            8) ai_menu ;;
            9) settings_menu ;;
            0)
                echo ""
                msg_ok "Terima kasih telah menggunakan AUT."
                exit 0
                ;;
            *) invalid_choice ;;
        esac
    done
}

# ==============================================================================
#  Mulai Aplikasi
# ==============================================================================
splash
check_shizuku
check_update "true"
main_menu
