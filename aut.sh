#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#             ANDROID UNIVERSAL TOOLKIT (AUT) - MAIN LAUNCHER
# ==============================================================================
# Penulis: myruldev & Tabbit (2026)
# Deskripsi: Script utama untuk meluncurkan menu interaktif modular AUT.
# Persyaratan: Termux, Shizuku (rish aktif), Python3 (untuk fitur AI & CCTV)
# ==============================================================================

# --- Versi Aplikasi ---
VERSION="v1.0.0"

# --- Warna & Estetika (ANSI Colors) ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# --- Direktori Kerja ---
AUT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$AUT_DIR"

# --- Load Konfigurasi ---
if [ -f "config/config.conf" ]; then
    source config/config.conf
else
    echo -e "${RED}[!] File konfigurasi config/config.conf tidak ditemukan!${NC}"
    exit 1
fi

# --- Load Modul ---
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
        echo -e "${RED}[!] Error: Modul $mod tidak ditemukan!${NC}"
        exit 1
    fi
done

# --- Cek Shizuku (rish) ---
check_shizuku() {
    if ! command -v rish &> /dev/null; then
        echo -e "${RED}[!] Error: 'rish' (Shizuku shell) tidak terdeteksi di PATH Termux Anda.${NC}"
        echo -e "${YELLOW}[*] Petunjuk: Pastikan aplikasi Shizuku sudah aktif di HP Anda.${NC}"
        echo -e "${YELLOW}[*] Jalankan script pembantu Shizuku di Termux untuk mendaftarkan rish.${NC}"
        echo ""
        read -p "Apakah ingin melanjutkan tanpa Shizuku? Beberapa menu tidak akan berfungsi. (y/n): " force_run
        if [ "$force_run" != "y" ] && [ "$force_run" != "Y" ]; then
            exit 1
        fi
    else
        # Tes apakah rish bisa berjalan
        rish -c "echo -n" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "${RED}[!] Error: Shizuku terinstall tapi tidak memberikan izin akses ke Termux.${NC}"
            echo -e "${YELLOW}[*] Buka aplikasi Shizuku di HP Anda dan pastikan Termux dicentang 'Izinkan'.${NC}"
            exit 1
        fi
    fi
}

# --- Header Banner ---
header() {
    clear
    echo -e "${GREEN}┌────────────────────────────────────────────────────────┐"
    echo -e "│            ANDROID UNIVERSAL TOOLKIT (AUT)             │"
    echo -e "│                Created by: myruldev                    │"
    echo -e "│                    Tahun: 2026                         │"
    echo -e "└────────────────────────────────────────────────────────┘${NC}"
}

# --- Menu Utama ---
main_menu() {
    while true; do
        header
        echo -e "Selamat datang, ${CYAN}Amirul Mukminin${NC}! Silakan pilih menu di bawah:"
        echo ""
        echo -e "  ${GREEN}[1]${NC} 🚀 Performance Optimizer"
        echo -e "  ${GREEN}[2]${NC} 🛡️ Security, App Manager & Debloat"
        echo -e "  ${GREEN}[3]${NC} 📡 Network & WiFi Tools"
        echo -e "  ${GREEN}[4]${NC} 🎥 Field Tech Tools (CCTV / IP Camera)"
        echo -e "  ${GREEN}[5]${NC} 🔍 Diagnostics, System Info & Logcat"
        echo -e "  ${GREEN}[6]${NC} 🧪 Experimental & System Scaling"
        echo -e "  ${GREEN}[7]${NC} 🚨 Emergency & Recovery Mode"
        echo -e "  ${GREEN}[8]${NC} 🤖 Ask AI Assistant (OpenRouter)"
        echo -e "  ${GREEN}[9]${NC} ⚙️ Settings / Konfigurasi"
        echo -e "  ${GREEN}[0]${NC} 🚪 Keluar (Exit)"
        echo ""
        read -p "Pilih menu [0-9]: " choice

        case $choice in
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
                echo -e "${YELLOW}Terima kasih telah menggunakan AUT. Sampai jumpa di lapangan, bro! 🚀${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}[!] Pilihan tidak valid!${NC}"
                sleep 1 
                ;;
        esac
    done
}

# --- Menu AI Assistant ---
ai_menu() {
    header
    echo -e "${YELLOW}>> MODULE: AI TECHNICAL ASSISTANT <<${NC}"
    echo ""
    # Cek apakah API key sudah diisi
    if [ -z "$OPENROUTER_API_KEY" ]; then
        echo -e "${RED}[!] API Key OpenRouter belum diatur di config/config.conf.${NC}"
        echo -e "Silakan isi API Key Anda terlebih dahulu lewat Menu Settings [9]."
        echo ""
        read -p "Tekan Enter untuk kembali..."
        return
    fi

    echo -e "Ketik pertanyaan Anda ke AI Assistant (Contoh: 'Bagaimana cara setting router bridge?'):"
    read -p "Pertanyaan: " ai_prompt
    if [ -n "$ai_prompt" ]; then
        echo ""
        echo -e "${BLUE}[*] Menghubungi OpenRouter AI (${AI_MODEL})...${NC}"
        echo "--------------------------------------------------------"
        python3 helpers/ai_helper.py "$ai_prompt"
        echo "--------------------------------------------------------"
    fi
    read -p "Tekan Enter untuk kembali..."
}

# --- Cek Update ---
check_update() {
    local silent=$1
    if [ "$silent" = "true" ]; then
        if command -v curl &>/dev/null; then
            local remote_ver=$(curl -s --connect-timeout 2 "https://raw.githubusercontent.com/myruldev/Android-Universal-Toolkit/main/aut.sh" | grep -oE '^VERSION="v[0-9]+\.[0-9]+\.[0-9]+"' | cut -d'"' -f2 2>/dev/null)
            if [ -n "$remote_ver" ] && [ "$remote_ver" != "$VERSION" ]; then
                echo -e "${YELLOW}┌────────────────────────────────────────────────────────┐${NC}"
                echo -e "${YELLOW}│  📢 UPDATE TERSEDIA: ${GREEN}${remote_ver}${YELLOW} (Milik Anda: ${RED}${VERSION}${YELLOW})       │${NC}"
                echo -e "${YELLOW}│  Pilih Menu [9] -> Opsi [4] untuk mengupdate langsung!  │${NC}"
                echo -e "${YELLOW}└────────────────────────────────────────────────────────┘${NC}"
                sleep 2
            fi
        fi
    else
        header
        echo -e "${YELLOW}>> CEK UPDATE APLIKASI <<${NC}"
        echo ""
        echo -e "${BLUE}[*] Memeriksa pembaruan dari repositori GitHub...${NC}"
        if ! command -v curl &>/dev/null; then
            echo -e "${RED}[!] Error: 'curl' tidak ditemukan. Silakan install dengan: pkg install curl${NC}"
            read -p "Tekan Enter untuk melanjutkan..."
            return
        fi
        
        local remote_ver=$(curl -s --connect-timeout 4 "https://raw.githubusercontent.com/myruldev/Android-Universal-Toolkit/main/aut.sh" | grep -oE '^VERSION="v[0-9]+\.[0-9]+\.[0-9]+"' | cut -d'"' -f2 2>/dev/null)
        if [ -z "$remote_ver" ]; then
            # Coba ambil dari README
            remote_ver=$(curl -s --connect-timeout 4 "https://raw.githubusercontent.com/myruldev/Android-Universal-Toolkit/main/README.md" | grep -oE "ANDROID UNIVERSAL TOOLKIT \(AUT\) v[0-9]+\.[0-9]+\.[0-9]+" | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | head -n 1 2>/dev/null)
        fi
        
        if [ -n "$remote_ver" ]; then
            if [ "$remote_ver" != "$VERSION" ]; then
                echo -e "${GREEN}[+] Hubungan sukses!${NC}"
                echo ""
                echo -e "${YELLOW}[!] Versi Baru Tersedia: ${GREEN}${remote_ver}${NC}"
                echo -e "${YELLOW}[!] Versi Anda Saat Ini: ${RED}${VERSION}${NC}"
                echo ""
                echo -e "${BLUE}[*] Cara Update:${NC}"
                echo -e "    1. Keluar dari script (${YELLOW}0${NC})"
                echo -e "    2. Jalankan perintah auto-update di Termux:"
                echo -e "       ${CYAN}curl -L -o AUT.zip https://github.com/myruldev/Android-Universal-Toolkit/archive/refs/heads/main.zip && unzip -o AUT.zip && rm AUT.zip${NC}"
                echo ""
            else
                echo -e "${GREEN}[+] Anda sudah menggunakan versi terbaru ($VERSION). Mantap, bro! 😎${NC}"
            fi
        else
            echo -e "${RED}[!] Gagal mendapatkan informasi versi terbaru.${NC}"
            echo -e "${YELLOW}[*] Pastikan koneksi internet Anda aktif dan repositori online.${NC}"
        fi
        echo ""
        read -p "Tekan Enter untuk kembali..."
    fi
}

# --- Menu Settings / Konfigurasi ---
settings_menu() {
    while true; do
        header
        echo -e "${YELLOW}>> MENU SETTINGS / KONFIGURASI <<${NC}"
        echo ""
        echo -e "1. 🔑 Atur API Key OpenRouter"
        echo -e "2. 🤖 Ganti Model AI (${AI_MODEL})"
        echo -e "3. 📂 Lihat Konfigurasi Saat Ini"
        echo -e "4. 🔄 Cek Update Aplikasi (GitHub)"
        echo -e "b. Kembali ke Menu Utama"
        echo ""
        read -p "Pilih opsi: " set_choice

        case $hide_opt in
            "") ;;
        esac

        case $set_choice in
            1)
                echo -e "API Key saat ini: ${YELLOW}${OPENROUTER_API_KEY:0:8}...${NC}"
                read -p "Masukkan API Key OpenRouter baru: " new_key
                if [ -n "$new_key" ]; then
                    # Ganti baris di config file
                    sed -i "s/OPENROUTER_API_KEY=.*/OPENROUTER_API_KEY="$new_key"/" config/config.conf
                    OPENROUTER_API_KEY="$new_key"
                    echo -e "${GREEN}[+] API Key berhasil diperbarui!${NC}"
                fi
                sleep 1.5
                ;;
            2)
                echo -e "Model saat ini: ${YELLOW}${AI_MODEL}${NC}"
                echo "Pilih model preset:"
                echo "1. Gemini 2.0 Flash (Gratis & Cepat)"
                echo "2. Llama 3 8B Instruct (Gratis & Cerdas)"
                echo "3. Input nama model kustom secara manual"
                read -p "Pilih [1-3]: " m_choice
                if [ "$m_choice" == "1" ]; then
                    new_model="google/gemini-2.0-flash-exp:free"
                elif [ "$m_choice" == "2" ]; then
                    new_model="meta-llama/llama-3-8b-instruct:free"
                elif [ "$m_choice" == "3" ]; then
                    read -p "Masukkan nama model OpenRouter lengkap: " new_model
                fi

                if [ -n "$new_model" ]; then
                    sed -i "s|AI_MODEL=.*|AI_MODEL="$new_model"|" config/config.conf
                    AI_MODEL="$new_model"
                    echo -e "${GREEN}[+] Model AI berhasil diubah ke $new_model!${NC}"
                fi
                sleep 1.5
                ;;
            3)
                header
                echo -e "${YELLOW}>> KONFIGURASI SAAT INI <<${NC}"
                cat config/config.conf
                echo "--------------------------------------------------------"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            4)
                check_update "false"
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

# --- Mulai Aplikasi ---
check_shizuku
check_update "true"
main_menu
