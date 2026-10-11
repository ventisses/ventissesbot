FROM python:3.10-slim

RUN apt-get update && apt-get install -y wget curl unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# GitHub API üzerinden en güncel resmi telegram-bot-api binary adresini otomatik bulup indirir (Asla 404 vermez)
RUN python3 -c '
import urllib.request, json
url = "https://api.github.com/repos/tdlib/telegram-bot-api/releases/latest"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as response:
    data = json.loads(response.read().decode())
download_url = next(asset["browser_download_url"] for asset in data["assets"] if "ubuntu-20.04.tar.gz" in asset["name"])
print("İndiriliyor:", download_url)
urllib.request.urlretrieve(download_url, "bot-api.tar.gz")
' && tar -xzf bot-api.tar.gz && mv bin/telegram-bot-api /usr/local/bin/ && rm -rf bot-api.tar.gz bin

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 10000

CMD telegram-bot-api --api-id="${API_ID}" --api-hash="${API_HASH}" --local & python bot.py
