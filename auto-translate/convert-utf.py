import os;
import sys;
from Npp import notepad

filePathSrc="C:\\Users\\User\\Documents\\GitHub\\gnome-scripts\\auto-translate\\asset_files"
for root, dirs, files in os.walk(filePathSrc):
    for fn in files:
      if fn[-4:] == '.txt' or fn[-4:] == '.csv':
        notepad.open(root + "\\" + fn)
        console.write(root + "\\" + fn + "\r\n")
        notepad.runMenuCommand("Encoding", "Convert to UTF-8")
        notepad.save()
        notepad.close()