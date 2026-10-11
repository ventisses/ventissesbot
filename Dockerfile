# Aşama 1: Kaynaktan Derleme (Harici indirme yok, yüzde yüz güvenli)
FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    make \
    cmake \
    g++ \
    libssl-dev \
    zlib1g-dev \
    gperf \
    pkg-config

RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git /app/telegram-bot-api
WORKDIR /app/telegram-bot-api/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && cmake --build . --target telegram-bot-api

# Aşama 2: Çalıştırma Ortamı (Python + Derlenen Tertemiz Binary)
FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    libssl3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Derlenen binary'yi güvenli bir şekilde kopyalıyoruz
COPY --from=builder /app/telegram-bot-api/build/telegram-bot-api /usr/local/bin/telegram-bot-api

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 10000

# Yerel API sunucusunu ve botu aynı anda başlatıyoruz
CMD telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local & python bot.py
