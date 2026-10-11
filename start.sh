#!/bin/bash

# Arka planda yerel Telegram Bot API sunucusunu başlatıyoruz (Port 8081)
telegram-bot-api --api-id=${API_ID} --api-hash=${API_HASH} --local &

# Python botunu başlatıyoruz
python bot.py
