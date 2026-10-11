FROM python:3.10-slim

# Sistem bağımlılıklarını ve curl yükleyelim
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Çalışma dizini
WORKDIR /app

# Python bağımlılıklarını yükle
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Bot kodlarını ve dosyaları kopyala
COPY . .

# Render'ın dinamik port ataması için ortam değişkeni ve başlatma komutu
CMD python bot.py