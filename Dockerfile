FROM eternnoir/telegram-bot-api:latest

# Alpine tabanlı bu imaja Python ve pip kuruyoruz
RUN apk add --no-cache python3 py3-pip bash

WORKDIR /app

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 10000

# Resmi hazır sunucu giriş noktasını sıfırlayıp kendi komutumuzla çalıştırıyoruz
ENTRYPOINT []
CMD telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local & python3 bot.py
