#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# AI Helper untuk Android Universal Toolkit (AUT) menggunakan OpenRouter API
# Penulis: myruldev

import sys
import json
import urllib.request
import urllib.error

CONFIG_PATH = "config/config.conf"
API_URL = "https://openrouter.ai/api/v1/chat/completions"
DEFAULT_MODEL = "google/gemini-2.0-flash-exp:free"

SYSTEM_PROMPT = (
    "Anda adalah AI Technical Assistant bawaan Android Universal Toolkit (AUT), dibuat oleh myruldev. "
    "Anda pakar Android, jaringan, CCTV, Linux/Termux, dan Shizuku. "
    "Bantu pengguna (terutama teknisi lapangan) menyelesaikan masalah teknis, "
    "menganalisis logcat, memberikan pinout kabel, atau perintah Shizuku/ADB yang tepat. "
    "Jawab dalam Bahasa Indonesia yang santai, praktis, dan mudah dipahami di lapangan."
)


def load_config():
    api_key, model = "", DEFAULT_MODEL
    try:
        with open(CONFIG_PATH, "r") as f:
            for line in f:
                if line.startswith("OPENROUTER_API_KEY="):
                    api_key = line.split("=", 1)[1].strip().strip('"').strip("'")
                elif line.startswith("AI_MODEL="):
                    model = line.split("=", 1)[1].strip().strip('"').strip("'")
    except OSError:
        pass
    return api_key, model


def ask_ai(prompt, context=""):
    api_key, model = load_config()
    if not api_key:
        print("[!] API Key OpenRouter belum diatur di config/config.conf")
        sys.exit(1)

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://github.com/myruldev/Android-Universal-Toolkit",
        "X-Title": "Android Universal Toolkit",
    }

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    if context:
        messages.append({"role": "system", "content": "Konteks sistem / Logcat:\n" + context})
    messages.append({"role": "user", "content": prompt})

    data = json.dumps({"model": model, "messages": messages}).encode("utf-8")
    req = urllib.request.Request(API_URL, data=data, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            print(res_data["choices"][0]["message"]["content"])
    except urllib.error.HTTPError as e:
        print(f"[!] Error HTTP {e.code}: {e.read().decode('utf-8', errors='ignore')}")
    except Exception as e:
        print(f"[!] Gagal menghubungi OpenRouter: {e}")


def main():
    if len(sys.argv) < 2:
        print("Penggunaan: python3 ai_helper.py <prompt> [context_file]")
        sys.exit(1)

    prompt = sys.argv[1]
    context = ""
    if len(sys.argv) > 2:
        try:
            with open(sys.argv[2], "r") as cf:
                context = cf.read()
        except OSError:
            pass
    ask_ai(prompt, context)


if __name__ == "__main__":
    main()
