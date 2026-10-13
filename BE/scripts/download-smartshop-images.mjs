import { mkdir, writeFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { productPhotos } from '../database/smartshop-product-photos.mjs';

const directory = 'uploads/smartshop/real-photos';
await mkdir(directory, { recursive: true });
const plan = Object.values(productPhotos).map(photo => ({ ...photo, candidates: [{ url: photo.url, title: photo.title, page: photo.page, sourceTitle: photo.sourceTitle }] }));
await writeFile(`${directory}/plan.json`, JSON.stringify(plan, null, 2));
// Retailer sources use several formats. Normalize to JPEG and compare image content.
const result = spawnSync(process.env.PYTHON_BIN || 'python', ['scripts/fetch-real-product-photos.py'], { stdio: 'inherit', windowsHide: true });
if (result.error) throw new Error('Install Python, Pillow and ImageHash before downloading product photos.');
if (result.status !== 0) process.exitCode = 1;
