"""Convert images to simulator .mem, show/reference-check simulator output.
Requires: python -m pip install pillow
Usage:
 python image_tools.py prepare my_photo.jpg
 python image_tools.py show
 python image_tools.py check
"""
from pathlib import Path
import sys
from PIL import Image, ImageDraw

BASE = Path(__file__).resolve().parent
SIZE = 128
WEIGHTS_BLUR = [1,2,1,2,4,2,1,2,1]
WEIGHTS_EDGE = [-1,0,1,-2,0,2,-1,0,1]

def make_sample():
    im=Image.new('L',(SIZE,SIZE),15)
    d=ImageDraw.Draw(im)
    d.rectangle((4,4,14,25),fill=225)
    d.ellipse((17,5,29,17),fill=175)
    d.line((16,22,29,29),fill=255,width=3)
    im.save(BASE/'sample_image.png')
    return im

def prepare(path=None):
    im = Image.open(path) if path else make_sample()
    im = im.convert('L').resize((SIZE,SIZE),Image.Resampling.BILINEAR)
    im.save(BASE/'input_preview.png')
    (BASE/'input_image.mem').write_text(''.join(f'{v:02x}\n' for v in im.getdata()))
    print('Prepared input_image.mem and input_preview.png ({SIZE}x{SIZE})')

def reference(mode):
    data=list(Image.open(BASE/'input_preview.png').convert('L').getdata())
    out=[]
    weights=WEIGHTS_BLUR if mode=='blur' else WEIGHTS_EDGE
    for row in range(SIZE-2):
        for col in range(SIZE-2):
            val=sum(data[(row+k//3)*SIZE+col+k%3]*w for k,w in enumerate(weights))
            val=val//16 if mode=='blur' else abs(val)//4
            out.append(max(0,min(255,val)))
    return out

def show(check=False):
    for mode in ('blur','edge'):
        f=BASE/f'{mode}_output.mem'
        if not f.exists():
            print(f'Missing {f.name}. Copy it from the simulator working directory.')
            continue
        nums=[int(s,16) for s in f.read_text().split()]
        if len(nums)!=(SIZE-2)**2:
            raise ValueError(f'{f.name}: expected {(SIZE-2)**2} values, found {len(nums)}')
        im=Image.new('L',(SIZE-2,SIZE-2)); im.putdata(nums)
        im.resize((480,480),Image.Resampling.NEAREST).save(BASE/f'{mode}_output.png')
        print(f'Saved {mode}_output.png')
        if check:
            expected=reference(mode)
            n=sum(a!=b for a,b in zip(nums,expected))
            print(f'{mode}: {n} mismatched pixels / {(SIZE-2)**2}', 'PASS' if n==0 else 'FAIL')

if __name__=='__main__':
    cmd=sys.argv[1] if len(sys.argv)>1 else 'prepare'
    if cmd=='prepare':prepare(sys.argv[2] if len(sys.argv)>2 else None)
    elif cmd=='show':show()
    elif cmd=='check':show(True)
    else:raise SystemExit('prepare [image], show, or check')
