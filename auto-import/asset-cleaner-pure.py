import xml.etree.ElementTree as ET

# parse the XML file
tree = ET.parse('assetslocation/apk/textassets.xml')
root = tree.getroot()

# find the Asset elements with Container values containing "pure/table/"
for asset in root.findall('Asset'):
    if 'pure/table/' in asset.find('Container').text:
        # remove the target Asset element
        root.remove(asset)

# serialize the modified XML tree back into a file
tree.write('assetslocation/apk/updated_textassets.xml', encoding='utf-8')