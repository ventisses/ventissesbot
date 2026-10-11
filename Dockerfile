FROM python:3.10-slim

# Sistem paketlerini ve resmi depodaki telegram-bot-api'yi doğrudan kuruyoruz (404 hatası sonsuza kadar biter)
RUN apt-get update && apt-get install -y \
    telegram-bot-api \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 10000

# Yerel API sunucusunu ve botu aynı anda başlatıyoruz
CMD telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local & python bot.py
