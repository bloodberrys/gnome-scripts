import pyautogui
import os
import time
import xml.etree.ElementTree as ET
import cv2
import pathlib
import mmap

def find_ab_filename(cab_name):
    start_time = time.time()
    keyword = cab_name.encode("latin1")
    root_dir = pathlib.Path("D:/DragonNestHurricane/project/assets/Raw/assetbundleOfficial-extracted")
    file_result = None

    for file_path in root_dir.glob("**/*"):
        if file_path.is_file():
            try:
                with open(file_path, "rb") as f:
                    with mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ) as mm:
                        if mm.find(keyword) != -1:
                            print(f"FOUND! {file_path}")
                            file_result = str(file_path)
                            break
            except (IOError, OSError):
                pass
        if file_result:
            break
    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"Elapsed time: {elapsed_time:.2f} seconds")
    return file_result

def click_file(clickType="double", file_path="", center=False, duration=0, add_left=0, add_top=0):
    time.sleep(duration)
    left, top = find_file_position(file_path, center=center)
    pyautogui.moveTo(left+add_left, top+add_top, duration=0, tween=pyautogui.easeInOutQuad)
    if clickType == "single":
        pyautogui.click()
    elif clickType == "double":
        pyautogui.doubleClick()

    return left, top

def find_file_position(file_path, center=False):
    # Load the image and preprocess it
    img = cv2.imread(file_path)

    # Get the coordinates of the file on the screen
    file_location = None
    grayscale = False
    confidence = 0.99
    
    max_attempts = 10
    for attempt in range(max_attempts):
        print(f'[Find Location] Attempt {attempt}')
        print(f'Primary File check: {file_path}')

        file_location = pyautogui.locateOnScreen(img, grayscale=grayscale, confidence=confidence)
        filename, file_extension = os.path.splitext(file_path)
        if file_location is None and os.path.exists("imagelocate/"+os.path.basename(filename)+str(2)+file_extension):
            print(f'Secondary File check: {"imagelocate/"+os.path.basename(filename)+str(2)+file_extension}')
            img2 = cv2.imread("imagelocate/"+os.path.basename(filename)+str(2)+file_extension)
            file_location = pyautogui.locateOnScreen(img2, grayscale=grayscale, confidence=confidence)
            pass

        print(file_location)
        if file_location is not None:
            break

    if center:
        file_location = pyautogui.center(file_location)

    # Click the file if it is found
    if file_location is not None:
        # Extract the left and top values from the location tuple
        if center:
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

    click_file(clickType="single", file_path="imagelocate/OK.png", center=True)
    pyautogui.press('enter')
    pyautogui.press('enter')

    left, top = click_file(clickType="single", file_path="imagelocate/UABE.png", duration=0, add_left=-10, add_top=35)
    click_file(clickType="single", file_path="imagelocate/SAVE_AB.png", center=True)

    print(f"[SAVE] Saving new assetbundle {filename}\n\n")
    time.sleep(0.2)
    click_file(clickType="double", file_path="imagelocate/RESULTS_AB.png", center=True)
    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.press('tab')
    pyautogui.typewrite(f'{os.path.splitext(source_filename)[0]}.ab')
    pyautogui.press('enter')


