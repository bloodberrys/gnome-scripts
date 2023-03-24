#import os library
import os
# Import
import time
from deep_translator import GoogleTranslator
from deep_translator import MyMemoryTranslator
from deep_translator import LingueeTranslator

#function readDirectoryFiles that takes two arguments
def readDirectoryFiles(folder, scriptFolder):

    #loop over the files in the directory
    for filename in os.listdir(folder):

        #print each filename
        print(f'File Name: {filename}')
        filename_edited = folder + "\\" + filename
        print(f'File Name: {filename_edited}')
        result_translated = split_string(filename_edited)

        #save the content in the scriptFolder
        with open(os.path.join(scriptFolder, filename), 'w', encoding='utf-8') as f:

            #write the content to a new file
            f.write(result_translated)
            f.close()

        #print message
        print(f'File {filename} Saved!')

def translator(string):
    proxies_example = {
        "http": "137.184.100.135:80",  # example: 34.195.196.27:8080
        "http": "143.42.138.176:80",  # example: 34.195.196.27:8080
        "http": "3.143.37.255:80",  # example: 34.195.196.27:8080
        "http": "3.12.178.169:80",  # example: 34.195.196.27:8080
        "http": "35.209.198.222:80",  # example: 34.195.196.27:8080
        "http": "162.223.94.163:80",  # example: 34.195.196.27:8080
        "http": "137.184.242.126:80",  # example: 34.195.196.27:8080
        "http": "169.55.89.6:80",  # example: 34.195.196.27:8080
        "http": "68.188.59.198:80",  # example: 34.195.196.27:8080
    }
    contentTranslated = GoogleTranslator(source='zh-CN', target='en', proxies=proxies_example).translate(string)
    # Sleep 2 secs
    # time.sleep(0.1)
    return contentTranslated


def split_string(filename):
    file = open(filename, 'r', encoding='utf-8')
    string = file.read()
    file.close()
    # array to get 5000 chunks
    splitted_list = []
    result_text = ''
    contentTranslated = ''
    n = 2000

    print(len(string))
    # if the string length is more than 5000 characters
    if len(string) > n:
        # split it into chunks of 5000 characters
        split_str = [string[i:i+n] for i in range(0, len(string), n)]

        # loop through the contents of split_str and write each element to a separate file
        for i, element in enumerate(split_str):
            # translate here
            contentTranslated = translator(element)

            # assign in array
            splitted_list.append(f'{contentTranslated}')


        # merge all the strings back into single var
        result_text = ''.join(splitted_list)

    # if the string length is less than 5000 characters
    else:
        # translate here
        result_text = translator(string)

    return result_text

#define the main function
def main():

    #define the folder and scriptFolder
    folder = "asset_files"
    scriptFolder = "results"

    #call the function
    readDirectoryFiles(folder, scriptFolder)

    #print message
    print('Done!')

#call main function
if __name__ == '__main__':
    main()