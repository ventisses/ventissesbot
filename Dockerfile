FROM python:3.10-slim

# Sistem gereksinimleri (wget ve unzip)
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Hazır telegram-bot-api binary dosyasını doğrudan Telegram'ın resmi kaynaklarından indiriyoruz (Sıfırdan derleme yok, anında kurulur!)
RUN wget https://github.com/tdlib/telegram-bot-api/releases/latest/download/telegram-bot-api-ubuntu-20.04.tar.gz \
    && tar -xzf telegram-bot-api-ubuntu-20.04.tar.gz \
    && mv bin/telegram-bot-api /usr/local/bin/ \
    && rm -rf telegram-bot-api-ubuntu-20.04.tar.gz bin

# Python bağımlılıkları
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 10000

# Yerel API sunucusunu ve botu aynı anda başlatıyoruz
CMD telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local & python bot.py
