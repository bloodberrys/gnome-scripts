import cv2
import pytesseract
from PIL import Image
from deep_translator import GoogleTranslator

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

# Preprocess the image
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
_, thresh = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY)
blur = cv2.medianBlur(thresh, 3)

# Perform OCR
text = pytesseract.image_to_string(Image.fromarray(blur), lang='chi_sim')

# Translate the text
translated_text = translator(text)

print(translated_text)
