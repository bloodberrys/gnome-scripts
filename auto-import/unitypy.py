import UnityPy
import os

def unpack_all_assets(source_folder : str, destination_folder : str):
    # iterate over all files in source folder
    for root, dirs, files in os.walk(source_folder):
        for file_name in files:
            # generate file_path
            file_path = os.path.join(root, file_name)
            # load that file via UnityPy.load
            env = UnityPy.load(file_path)
            print(env.objects)
            for obj in env.objects:
                
                if obj.type.name == "TextAsset":
                    # export asset
                    data = obj.read()
                    with open(os.path.join(destination_folder, data.name), "wb") as f:
                        f.write(bytes(data.script))
                    # create asset bundle
                    bundle_name = os.path.splitext(data.name)[0] + ".assetbundle"
                    bundle_path = os.path.join(destination_folder, bundle_name)
                    bundle = UnityPy.AssetBundle()
                    bundle.add(obj)
                    bundle.save(bundle_path)


unpack_all_assets('C:\\Users\\User\\Documents\\GitHub\\gnome-scripts\\auto-import\\results', 'C:\\Users\\User\\Documents\\GitHub\\gnome-scripts\\auto-import\\results_ab')