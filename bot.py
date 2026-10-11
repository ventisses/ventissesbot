import os
import yt_dlp
import telebot
import imageio_ffmpeg
from flask import Flask, request

TOKEN = "8998161287:AAHpHc-vf3xrN6HzzZaQtlTZvhQ7eqvcd8c"

# Yerel Bot Sunucusu adresi (2 GB sınırını kaldıran ayar)
telebot.apihelper.API_URL = "http://127.0.0.1:8081/bot{0}/{1}"

bot = telebot.TeleBot(TOKEN)
app = Flask(__name__)

MAX_FILE_SIZE = 2 * 1024 * 1024 * 1024  # 2 GB Sınırı

def get_apple_music_metadata(apple_url):
    try:
        clean_url = apple_url.split("?")[0]
        parts = clean_url.split("/")
        if len(parts) > 0:
            for part in reversed(parts):
                if part and not part.isdigit() and len(part) > 2 and part != "album" and part != "song" and "music.apple.com" not in part:
                    return part.replace("-", " ").title()
        return None
    except Exception as e:
        print(f"URL Çözümleme Hatası: {e}")
        return None

def download_media(query_or_url, is_audio=False):
    if not os.path.exists("downloads"):
        os.makedirs("downloads")
        
    ffmpeg_path = imageio_ffmpeg.get_ffmpeg_exe()

    ydl_opts = {
        'outtmpl': 'downloads/%(id)s.%(ext)s',
        'ffmpeg_location': ffmpeg_path,
        'quiet': True,
        'noplaylist': True,
        'geo_bypass': True,
        'nocheckcertificate': True,
        'extractor_args': {'youtube': {'player_client': ['android', 'web']}},
    }

    if is_audio:
        ydl_opts.update({
            'format': 'bestaudio/best',
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'mp3',
                'preferredquality': '192',
            }],
        })
    else:
        ydl_opts.update({
            'format': 'bestvideo[height<=1080]+bestaudio/best[height<=1080]/best',
        })

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        try:
            info = ydl.extract_info(query_or_url, download=True)
            if 'entries' in info:
                info = info['entries'][0]
            filename = ydl.prepare_filename(info)
            
            if is_audio:
                filename = filename.rsplit('.', 1)[0] + '.mp3'

            if os.path.exists(filename):
                return filename
            return None
        except Exception as e:
            print(f"🔴 İndirme Hatası Detayı: {e}")
            return None

@bot.message_handler(commands=['start'])
def start_handler(message):
    bot.reply_to(
        message,
        "Selam! 🚀 Render üzerinde 2 GB modunda 7/24 aktif çalışıyorum!\n\n"
        "• **Apple Music linki:** MP3 ses dosyası,\n"
        "• **YouTube linki / Arama:** Yüksek kalitede video dosyası gönderilir."
    )

@bot.message_handler(func=lambda message: True)
def universal_handler(message):
    text = message.text.strip()
    if not text:
        return

    status_msg = bot.reply_to(message, "🔍 İstek işleniyor...")
    
    target_query = text
    is_audio = False

    if "music.apple.com" in text:
        bot.edit_message_text("🎵 Apple Music bağlantısı çözümleniyor...", message.chat.id, status_msg.message_id)
        song_name = get_apple_music_metadata(text)
        
        if song_name:
            target_query = f"ytsearch1:{song_name} audio"
            is_audio = True
            bot.edit_message_text(f"📥 '{song_name}' indiriliyor...", message.chat.id, status_msg.message_id)
        else:
            target_query = text
            is_audio = True

    elif text.startswith("http://") or text.startswith("https://"):
        bot.edit_message_text("📥 YouTube videosu indiriliyor...", message.chat.id, status_msg.message_id)
        is_audio = False
    else:
        bot.edit_message_text("📥 YouTube'da aranıp indiriliyor...", message.chat.id, status_msg.message_id)
        target_query = f"ytsearch1:{text}"
        is_audio = False

    file_path = download_media(target_query, is_audio=is_audio)
    
    if file_path and os.path.exists(file_path):
        file_size = os.path.getsize(file_path)
        
        if file_size > MAX_FILE_SIZE:
            bot.edit_message_text("❌ İndirilen dosya 2 GB sınırını aşıyor.", message.chat.id, status_msg.message_id)
            os.remove(file_path)
            return

        bot.edit_message_text("📤 Dosya yerel sunucu üzerinden Telegram'a yükleniyor...", message.chat.id, status_msg.message_id)
        with open(file_path, 'rb') as media_file:
            if is_audio:
                bot.send_audio(message.chat.id, media_file)
            else:
                bot.send_video(message.chat.id, media_file)
        bot.delete_message(message.chat.id, status_msg.message_id)
        os.remove(file_path)
    else:
        bot.edit_message_text("❌ İndirme başarısız oldu.", message.chat.id, status_msg.message_id)

@app.route("/webhook", methods=["POST"])
def webhook():
    json_string = request.get_data().decode("utf-8")
    update = telebot.types.Update.de_json(json_string)
    bot.process_new_updates([update])
    return "!", 200

@app.route("/")
def index():
    return "Bot ve Yerel Sunucu aktif!", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
