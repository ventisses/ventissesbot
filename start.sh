#!/bin/bash

echo "🚀 Yerel Telegram Bot API Sunucusu başlatılıyor..."
# Arka plana (&) atmadan, doğrudan logları görebilmek için çalıştırıyoruz veya hata çıktısını görecek şekilde ayarlıyoruz
telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local &

# Sunucunun kendine gelmesi için 3 saniye bekleyelim
sleep 3

echo "🤖 Python botu başlatılıyor..."
python bot.py
