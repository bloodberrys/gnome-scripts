import pyautogui
import os
import time
import xml.etree.ElementTree as ET

# os.startfile("C:\\Users\\User\\Documents\\GitHub\\gnome-scripts\\auto-import\\UABE\\64bit\\AssetBundleExtractor.exe")
# time.sleep(2)

def click_file(clickType="double", file_path="", center=False, duration=0, add_left=0, add_top=0):
    time.sleep(duration)
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
        print(f"[FIND POSITION], position found at: left={left}, top={top}")

    else:
        print("File not found on the screen.")
        exit(1)

    return left, top

# list asset_files
folder = "asset_files"
asset_xml = "assetslocation/apk/textassets.xml"

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

    print("[GET ASSET BUNDLE]\n")
    click_file(clickType="double", duration=0.1, file_path="imagelocate/APK_AB_DATA.png")

    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.press('tab')
    print(f'[PROCESS] Assetbundle Name: {source_filename}\n')
    pyautogui.typewrite(f'{source_filename}')
    pyautogui.press('enter')

    click_file(clickType="double", file_path="imagelocate/TEXTAS.png",add_left=-290, add_top=10)
    click_file(clickType="double", file_path="imagelocate/PLUGIN.png", center=True)
    click_file(clickType="double", file_path="imagelocate/IMPORT_TXT.png", center=True)
    click_file(clickType="double", file_path="imagelocate/ASSET_FILES.png")

    print("[IMPORT] Importing asset file\n")
    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.press('tab')
    print(filename)
    pyautogui.typewrite(f'{filename}')
    pyautogui.press('enter')

    click_file(clickType="double", file_path="imagelocate/OK.png", center=True)
    pyautogui.press('enter')

    print(f"[SAVE] Saving new assetbundle {filename}")
    click_file(clickType="double", file_path="imagelocate/RESULTS.png", center=True)
    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.press('enter')



