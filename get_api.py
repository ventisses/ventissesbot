import json
import urllib.request

url = "https://api.github.com/repos/tdlib/telegram-bot-api/releases/latest"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
try:
  with urllib.request.urlopen(req) as response:
    data = json.loads(response.read().decode())
  download_url = next(
      asset["browser_download_url"]
      for asset in data["assets"]
      if "ubuntu-20.04.tar.gz" in asset["name"]
  )
  print("İndiriliyor:", download_url)
  urllib.request.urlretrieve(download_url, "bot-api.tar.gz")
except Exception as e:
  print("Hata:", e)
  exit(1)
