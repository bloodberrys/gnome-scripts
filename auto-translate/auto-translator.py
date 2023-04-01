import os
import time
from deep_translator import GoogleTranslator
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import random
import requests
import signal
import time
import re
import csv

def sigterm_handler(signum, frame):
    # Remove the file here
    os.remove("proxy_used.txt")
    exit(0)

def keyboard_interrupt_handler(signal, frame):
    # Remove the file here
    time.sleep(2)
    os.remove("proxy_used.txt")
    exit(0)

# Register the signal handler function for SIGTERM
signal.signal(signal.SIGTERM, sigterm_handler)
signal.signal(signal.SIGINT, keyboard_interrupt_handler)

def readDirectoryFiles(folder, scriptFolder):
    for filename in os.listdir(folder):
        print(f'File Name: {filename}')
        filename_edited = os.path.join(folder, filename)
        print(f'File Name: {filename_edited}')
        result_translated = chunk_string(filename_edited)
        with open(os.path.join(scriptFolder, filename), 'w', encoding='utf-8') as f:
            f.write(result_translated)
        print(f'File {filename} Saved!\n')

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

def chunk_string(filename):

    n = 2000
    
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
        chunks = [content[i:i+n] for i in range(0, len(content), n)]
        with ThreadPoolExecutor(max_workers=8) as executor:
            futures = [executor.submit(translator, chunk) for chunk in chunks]
            translated_chunks = [f.result() for f in futures]
        result_text = ''.join(translated_chunks)

    return result_text




def main():
    folder = "asset_files"
    scriptFolder = "results"
    readDirectoryFiles(folder, scriptFolder)
    os.remove('proxy_used.txt')
    print('Done!')



if __name__ == '__main__':
    main()
