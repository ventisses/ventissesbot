#!/bin/bash

echo "🚀 Yerel Telegram Bot API Sunucusu başlatılıyor..."
telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local &

# Sunucunun kendine gelmesi için 3 saniye bekliyoruz
sleep 3

echo "🤖 Python botu başlatılıyor..."
python bot.py
