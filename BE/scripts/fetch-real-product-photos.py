"""Download real source photos, normalize file format, reject duplicates, and make review sheets.
Requires Pillow and ImageHash. Does not generate or alter product appearance.
"""
import concurrent.futures, hashlib, io, json, pathlib, threading, urllib.request
from PIL import Image, ImageOps, ImageDraw
import imagehash

root = pathlib.Path('uploads/smartshop/real-photos')
plan = json.loads((root / 'plan.json').read_text(encoding='utf-8'))
lock = threading.Lock()
used_urls, used_sha, used_phash, results = set(), set(), [], []

def process(product):
    target = root / (product['code'] + '.jpg')
    cached = root / (product['code'] + '.json')
    if target.exists() and cached.exists():
        result = json.loads(cached.read_text(encoding='utf-8'))
        data = target.read_bytes()
        picture = Image.open(io.BytesIO(data)).convert('RGB')
        sha = hashlib.sha256(data).hexdigest()
        phash = imagehash.phash(picture)
        with lock:
            if result['type'] == product['type'] and sha not in used_sha and all(phash - old > 2 for old in used_phash):
                used_sha.add(sha); used_phash.append(phash); used_urls.add(result['url']); results.append(result)
                return
    failures = []
    for candidate in product['candidates']:
        url = candidate['url']
        with lock:
            if url in used_urls: continue
        try:
            request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(request, timeout=15) as response:
                data = response.read(15 * 1024 * 1024 + 1)
            if len(data) > 15 * 1024 * 1024: raise ValueError('Image too large')
            picture = ImageOps.exif_transpose(Image.open(io.BytesIO(data)))
            if min(picture.size) < 160: raise ValueError('Image too small')
            if picture.mode != 'RGB':
                background = Image.new('RGB', picture.size, 'white')
                if 'A' in picture.getbands(): background.paste(picture, mask=picture.getchannel('A'))
                else: background.paste(picture.convert('RGB'))
                picture = background
            picture.thumbnail((1000, 1000))
            buffer = io.BytesIO(); picture.save(buffer, 'JPEG', quality=90)
            output = buffer.getvalue()
            sha = hashlib.sha256(output).hexdigest(); phash = imagehash.phash(picture)
            with lock:
                if url in used_urls or sha in used_sha or any(phash - old <= 2 for old in used_phash): continue
                used_urls.add(url); used_sha.add(sha); used_phash.append(phash)
                result = {**{k: v for k, v in product.items() if k != 'candidates'}, **candidate, 'sha256': sha, 'phash': str(phash), 'path': '/uploads/smartshop/real-photos/' + target.name}
                target.write_bytes(output)
                cached.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
                results.append(result)
            print('READY:', product['code'], product['type'], flush=True)
            return
        except Exception as error:
            failures.append(str(error)[:80])
    print('FAILED:', product['code'], product['type'], failures[-3:], flush=True)

with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
    list(executor.map(process, plan))
results.sort(key=lambda p: p['code'])
(root / 'manifest.json').write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding='utf-8')
for ci in range(9):
    products = [p for p in results if p['categoryIndex'] == ci]
    sheet = Image.new('RGB', (1000, ((len(products) + 3) // 4) * 240), '#eef2ff')
    draw = ImageDraw.Draw(sheet)
    for i, product in enumerate(products):
        picture = Image.open(root / (product['code'] + '.jpg'))
        picture.thumbnail((230, 200))
        x, y = (i % 4) * 250, (i // 4) * 240
        sheet.paste(picture, (x + (250 - picture.width)//2, y + (205 - picture.height)//2))
        draw.text((x + 10, y + 210), product['code'] + ' ' + product['type'], fill='black')
    sheet.save(root / ('review-' + str(ci + 1) + '.jpg'))
print('Downloaded unique photos:', len(results), '/', len(plan), flush=True)
if len(results) != len(plan): raise SystemExit(1)
