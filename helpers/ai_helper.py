#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# AI Helper untuk Android Universal Toolkit menggunakan OpenRouter API
# Penulis: myruldev & Tabbit (2026)

import sys
import json
import urllib.request
import urllib.error

def load_config():
    api_key = ""
    model = "google/gemini-2.0-flash-exp:free"
    try:
        with open("config/config.conf", "r") as f:
            for line in f:
                if line.startswith("OPENROUTER_API_KEY="):
                    api_key = line.split("=")[1].strip().strip('"').strip("'")
                elif line.startswith("AI_MODEL="):
                    model = line.split("=")[1].strip().strip('"').strip("'")
    except Exception:
        pass
    return api_key, model

def ask_ai(prompt, context=""):
    api_key, model = load_config()
    if not api_key:
        print("[!] Error: API Key OpenRouter belum diatur di config/config.conf")
        sys.exit(1)

    url = "https://openrouter.ai/api/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://github.com/myruldev/Android-Universal-Toolkit",
        "X-Title": "Android Universal Toolkit"
    }

    system_prompt = (
        "Anda adalah AI Technical Assistant bawaan dari Android Universal Toolkit (AUT), dibuat oleh myruldev. "
        "Anda adalah pakar Android, jaringan, CCTV, Linux/Termux, dan Shizuku. "
        "Tugas Anda adalah membantu pengguna (terutama teknisi lapangan) untuk menyelesaikan masalah teknis, "
        "menganalisis logcat, memberikan pinout kabel, atau perintah bash Android Shizuku/ADB yang tepat. "
        "Berikan jawaban dalam Bahasa Indonesia yang santai, praktis, teknis, dan mudah dipahami di lapangan."
    )

    messages = [
        {"role": "system", "content": system_prompt}
    ]
    if context:
        messages.append({"role": "system", "content": f"Konteks sistem / Logcat saat ini:
{context}"})
    messages.append({"role": "user", "content": prompt})

    data = {
        "model": model,
        "messages": messages
    }

    req = urllib.request.Request(url, data=json.dumps(data).encode("utf-8"), headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            answer = res_data["choices"][0]["message"]["content"]
            print(answer)
    except urllib.error.HTTPError as e:
        print(f"[!] Error HTTP {e.code}: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"[!] Gagal menghubungi OpenRouter: {str(e)}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Penggunaan: python3 ai_helper.py <prompt> [context_file]")
        sys.exit(1)

    prompt = sys.argv[1]
    context = ""
    if len(sys.argv) > 2:
        try:
            with open(sys.argv[2], "r") as cf:
                context = f.read()
        except Exception:
            pass
    ask_ai(prompt, context)
