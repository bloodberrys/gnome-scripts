import cv2
import pytesseract
from PIL import Image, ImageDraw, ImageFont
import os
from deep_translator import GoogleTranslator
import random
import requests


os.environ['TESSDATA_PREFIX'] = 'C:/Program Files/Tesseract-OCR/tessdata'

def get_proxy():
    try:
        with open('proxy_used.txt', 'r') as f:
            proxies = f.read().strip().split('\n')
    except FileNotFoundError:
        url = "https://proxylist.geonode.com/api/proxy-list?limit=50&page=1&sort_by=lastChecked&sort_type=desc&protocols=http"
        response = requests.get(url)
        proxy_list = response.json()['data']
        http_proxies = [proxy['ip'] + ':' + proxy['port'] for proxy in proxy_list if 'http' in proxy['protocols']]
        proxies = http_proxies
        with open('proxy_used.txt', 'w') as f:
            f.write('\n'.join(proxies))
    return proxies

def translator(string):
    proxy = random.choice(get_proxy())
    proxies = {"http": proxy}
    contentTranslated = GoogleTranslator(source='zh-CN', target='en', proxies=proxies).translate(string)
    return contentTranslated

# Load the image
img = cv2.imread('image.png')

pytesseract.pytesseract.tesseract_cmd = 'C:/Program Files/Tesseract-OCR/tesseract.exe'  # your path may be different

# Preprocess the image
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
_, thresh = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY)
blur = cv2.medianBlur(thresh, 3)

# Perform OCR
tessdata_dir_config = '--tessdata-dir "C:/Program Files/Tesseract-OCR/tessdata"'
text = pytesseract.image_to_string(Image.fromarray(blur), lang='chi_sim', config=tessdata_dir_config).replace(' ', '')


# Translate the text
translated_text = translator(text)

print(text)
print(translated_text)
text = translated_text

# Create a new image for the text
text_img = Image.new('RGB', (img.shape[1], img.shape[0]), color=(255, 255, 255))

# Calculate the text size based on the OCR output
draw = ImageDraw.Draw(text_img)
font_size = 50
while True:
    font = ImageFont.truetype('GameFont.ttf', size=font_size)
    text_bbox = draw.textbbox((10, 10), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]

    if text_width < img.shape[1] - 20 and text_height < img.shape[0] - 20:
        break
    font_size -= 1

# Add the text to the image
draw.text((10, 10), text, fill=(0, 0, 0), font=font)

# Save the image with the replicated text
text_img.save('replicated_text.png')