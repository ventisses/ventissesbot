FROM python:3.10-slim

RUN apt-get update && apt-get install -y wget curl unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# İndirme işlemini harici python dosyasıyla yapıyoruz (Dockerfile çökmesini engeller)
RUN python3 get_api.py \
    && tar -xzf bot-api.tar.gz \
    && mv bin/telegram-bot-api /usr/local/bin/ \
    && rm -rf bot-api.tar.gz bin

EXPOSE 10000

CMD telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local & python bot.py
