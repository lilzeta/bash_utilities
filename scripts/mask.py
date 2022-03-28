from PIL import Image
import numpy as np
import os
import json
import sys 


def fix_masks(out_dir):
    #out_dir='/media/zi/x8/rsr/frames/wep' # 20113578
    for parent in sorted(os.listdir(out_dir)):
        full=out_dir + "/" + parent
        if os.path.isdir(full):
            print(parent)

            # load info json
            jf=open(out_dir + "/"  + parent + '.info')
            info=json.load(jf)
            print(info['fr'])

            last=False
            i = 1
            for f in sorted(os.listdir(full)):
                image_path = full + "/" + f
                name=os.path.splitext(f)[0]
                #out_path = full + "/" + name + ".jpg"
                out_path = full + "/" + name + ".png"
                if os.path.isfile(image_path):
                    img = Image.open(image_path)
                    if last and len(img.split()) > 3:
                        if str(i) in info['offsets']:
                            x = int(info['offsets'][str(i)]["x"])
                            y = int(info['offsets'][str(i)]["y"])
                        else:
                            x = 0
                            y = 0
                        last.paste(img, (x, y), mask = img.split()[3])                 
                    else:
                        last = img 
                    # last.save(out_path, "JPEG", quality = 100) # try jpeg
                    last.save(out_path, "PNG")
                    os.remove(image_path)
                i+=1
        print("qq")
        # img = Image.open(mask)
        # bg = Image.open(bg)
        # bg.paste(img, (0, 0), img)
        # bg.save(bg)

if __name__ == "__main__":
    print(sys.argv[1])
    fix_masks(sys.argv[1])