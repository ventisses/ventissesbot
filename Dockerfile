FROM python:3.10-slim

RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Telegram Bot API 7.8.0 resmi binary sürümü
RUN wget https://github.com/tdlib/telegram-bot-api/releases/download/v7.8.0/telegram-bot-api-ubuntu-20.04.tar.gz \
    && tar -xzf telegram-bot-api-ubuntu-20.04.tar.gz \
    && mv bin/telegram-bot-api /usr/local/bin/ \
    && rm -rf telegram-bot-api-ubuntu-20.04.tar.gz bin

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 10000

CMD telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local & python bot.py
