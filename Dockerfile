FROM python:3.10-slim

# Gerekli sistem paketlerini ve telegram-bot-api bağımlılıklarını yüklüyoruz
RUN apt-get update && apt-get install -y \
    git \
    make \
    cmake \
    g++ \
    libssl-dev \
    zlib1g-dev \
    libgraphengine-dev \
    libsqlite3-dev \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Yerel Telegram Bot API sunucusunu resmi deposundan derleyip kuruyoruz (2GB limit desteği için)
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git /tmp/telegram-bot-api \
    && cd /tmp/telegram-bot-api \
    && mkdir build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build . --target install \
    && rm -rf /tmp/telegram-bot-api

# Çalışma dizinini ayarlıyoruz
WORKDIR /app

# Proje dosyalarını kopyalıyoruz
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Render'ın kullandığı port (10000) ve Flask için gerekli ortam
EXPOSE 10000

# Hem yerel Bot API sunucusunu (arka planda) hem de Flask botunu aynı anda başlatan komut
CMD telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local & python bot.py
