import pyautogui
import os
import time
import xml.etree.ElementTree as ET

def find_ab_filename(cab_name):
    keyword = bytes(cab_name,encoding="latin1")  # ask the user for keyword, use raw_input() on Python 2.x
    file_result = None
    root_dir = "D:\\DragonNestHurricane\\project\\assets\Raw\\assetbundleOfficial-extracted"  # path to the root directory to search
    for root, dirs, files in os.walk(root_dir, onerror=None):  # walk the root dir
        for filename in files:  # iterate over the files in the current dir
            file_path = os.path.join(root, filename)  # build the file path
            try:
                with open(file_path, "rb") as f:  # open the file for reading
                    # read the file line by line
                    for line in f:  # use: for i, line in enumerate(f) if you need line numbers
                        try:
                            line = line.decode("latin1")  # try to decode the contents to utf
                        except ValueError:  # decoding failed, skip the line
                            continue
                        if keyword in bytes(line,encoding="latin1"):  # if the keyword exists on the current line...
                            print(f"FOUND! {file_path}")
                            file_result = file_path  # print the file path
                            break  # no need to iterate over the rest of the file
            except (IOError, OSError):  # ignore read and permission errors
                pass
    return file_result

# tes = "cf280a610f1605fe437f9d01cd304e70"
# find_ab_filename(tes)

def click_file(clickType="double", file_path="", center=False, duration=0, add_left=0, add_top=0):
    # time.sleep(duration)
    left, top = find_file_position(file_path, center=center)
    pyautogui.moveTo(left+add_left, top+add_top, duration=0, tween=pyautogui.easeInOutQuad)
    if clickType == "single":
        pyautogui.click()
    elif clickType == "double":
        pyautogui.doubleClick()

    return left, top

def find_file_position(file_path,center=False):
    # Get the coordinates of the file on the screen
    file_location = None
    
    max_attempts = 5
    for attempt in range(max_attempts):
        print(f'[Find Location] Attempt {attempt}')
        print(f'Primary File check: {file_path}')

        file_location = pyautogui.locateOnScreen(file_path, grayscale=True)
        filename, file_extension = os.path.splitext(file_path)
        if file_location == None and os.path.exists("imagelocate/"+os.path.basename(filename)+str(2)+file_extension):
            print(f'Secondary File check: {"imagelocate/"+os.path.basename(filename)+str(2)+file_extension}')
            file_location = pyautogui.locateOnScreen("imagelocate/"+os.path.basename(filename)+str(2)+file_extension, grayscale=True)
            pass

        print(file_location)
        if file_location is not None:
            break

    if center == True:
        file_location = pyautogui.center(file_location)

    # Click the file if it is found
    if file_location is not None:
        # print(file_location)

        # Extract the left and top values from the location tuple
        if center == True:
            left, top = file_location.x, file_location.y
        else:
            left, top = file_location.left, file_location.top

        # Print the results
        print(f"[FIND POSITION], position found at: left={left}, top={top}\n")

    else:
        print("File not found on the screen.")
        exit(1)

    return left, top

# list asset_files
folder = "asset_files_ab"
asset_xml = "assetslocation/ab/textassets.xml"

#loop over the files in the directory
for filename in os.listdir(folder):
    left, top = click_file(clickType="double", file_path="imagelocate/UABE.png", duration=0, add_left=-10, add_top=35)
    pyautogui.moveTo(left-10, top+55, duration=0, tween=pyautogui.easeInOutQuad)
    pyautogui.click()

    # get assetbundle from filename location mapping xml
    tree = ET.parse(asset_xml)
    # Get the root element
    root = tree.getroot()

    # Find the Asset element with the specified Name
    name_input = os.path.splitext(filename)[0]
    asset = None
    for a in root.findall('Asset'):
        if a.find('Name').text == name_input:
            asset = a
            break

    # Extract the Source element and print its text
    if asset is not None:
        source = asset.find('Source').text
    else:
        print(f"No asset found with Name '{name_input}'")

    source_filename = os.path.basename(source)

    print(source_filename)
    source_filename = find_ab_filename(source_filename)
    source_filename = os.path.basename(source_filename)

    print(f"[GET ASSET BUNDLE] {source_filename}\n")
    click_file(clickType="double", file_path="imagelocate/AB_DATA.png", center=True)

    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.press('tab')
    print(f'[PROCESS] Assetbundle Name: {source_filename}\n\n')
    pyautogui.typewrite(f'{source_filename}')
    pyautogui.press('enter')

    click_file(clickType="double", file_path="imagelocate/INFO.png", center=True)
    click_file(clickType="double", file_path="imagelocate/TEXTAS.png",add_left=-290, add_top=10)
    click_file(clickType="double", file_path="imagelocate/PLUGIN.png", center=True)
    click_file(clickType="double", file_path="imagelocate/IMPORT_TXT.png", center=True)
    click_file(clickType="double", file_path="imagelocate/ASSET_FILES_AB.png", center=True)

    print("[IMPORT] Importing asset file\n\n")
    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.press('tab')
    print(filename)
    pyautogui.typewrite(f'{filename}')
    pyautogui.press('enter')

    click_file(clickType="double", file_path="imagelocate/OK.png", center=True)
    pyautogui.press('enter')

    left, top = click_file(clickType="double", file_path="imagelocate/UABE.png", duration=0, add_left=-10, add_top=35)
    click_file(clickType="double", file_path="imagelocate/SAVE_AB.png", center=True)

    print(f"[SAVE] Saving new assetbundle {filename}\n\n")
    click_file(clickType="double", file_path="imagelocate/RESULTS_AB.png", center=True)
    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.typewrite(f'{os.path.splitext(source_filename)[0]}.ab')
    pyautogui.press('enter')



