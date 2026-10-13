import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { expandedCatalog } from '../database/smartshop-expanded-catalog.mjs';
const pools = { ...JSON.parse(await readFile('database/product-photo-candidates.json', 'utf8')), ...JSON.parse(await readFile('database/product-photo-extra-candidates.json', 'utf8')) };
const types = [
  ['phones','phones','chargers30','cases','phones','phones','chargers','chargers20','cases','cases','phones'],
  ['laptops_dell','laptops_lenovo','keyboards','mice','laptops','laptops_dell','keyboards','keyboards','mice','mice','laptops_lenovo'],
  ['headphones','headphones','speakers','watches','headphones','headphones','speakers','speakers','watches','watches','headphones'],
  ['tshirts','shirts','denimjackets','jeans','tshirts','tshirts','shirts','shirts','denimjackets','jeans','jeans'],
  ['sneakers','sneakers','backpacks','totes','sneakers','sneakers','sneakers','backpacks','backpacks','totes','totes'],
  ['serums','creams','cleansers','shampoos','serums','serums','creams','creams','cleansers','shampoos','shampoos'],
  ['lamps','realchairs','thermos','planters','lamps','lamps','realchairs','realchairs','thermos','planters'],
  ['yogamats','dumbbells','basketball_single','sportbottles','yogamats','yogamats','dumbbells','dumbbells','basketball_single','sportbottles'],
  ['notebooks','books','pencils','notebook_single','notebooks','notebook_single','books','books','pencils','notebook_single'],
];
const preferences = {
  phones:[5,8,9,10,11,6,7,0], laptops:[5,9,10], laptops_dell:[0,6,7,8], laptops_lenovo:[0,8,11,1],
  chargers:[9,7,11,8,0], chargers20:[0,9,6,2], chargers30:[0,1,2,11], cases:[7,0,10,2,5,6],
  keyboards:[0,1,2,8,3], mice:[0,4,5,9,2], headphones:[0,1,6,9,3,4], speakers:[0,2,6,7,10], watches:[0,3,6,1,5,7],
  tshirts:[0,7,5,1,3], shirts:[0,2,3,7,8], denimjackets:[0,3,4,5], jeans:[3,7,6,11,4],
  sneakers:[1,5,6,8,9,2,3], backpacks:[0,3,5,6,10], totes:[0,3,9,8,11],
  serums:[0,1,4,8,3], creams:[0,3,4,6,7,8], cleansers:[0,1,11,3], shampoos:[0,2,3,5,6,7],
  lamps:[0,2,10,6,11], realchairs:[0,1,2,4,5,7], thermos:[0,3,6,7,8], planters:[0,9,2,3,11],
  yogamats:[0,2,3,6,4], dumbbells:[1,2,6,4,5], basketball_single:[0,2,4,7], sportbottles:[4,6,10,3,2],
  notebooks:[1,6,8,4,5], notebook_single:[0,4,10,3,11], books:[0,6,10,2,3], pencils:[0,5,8,11],
  phones_samsung:[0,1,2], phones_xiaomi:[3,0,2], shirts_beige:[0,3,2,4], dumbbells2:[0,1,3], dumbbells3:[0,1,3], dumbbells5:[0,4,5],
};
const overrides = { 'SS-0105':'phones_samsung', 'SS-0111':'phones_xiaomi', 'SS-0402':'shirts_beige', 'SS-0408':'shirts_beige', 'SS-0802':'dumbbells2', 'SS-0807':'dumbbells3', 'SS-0808':'dumbbells5' };
const offsets = new Map();
const plan = expandedCatalog.flatMap((category, ci) => category.products.map((product, pi) => {
  const type = overrides[product.code] || types[ci][pi];
  const pool = pools[type];
  const order = [...(preferences[type] || []), ...pool.map((_, i) => i)].filter((v, i, a) => a.indexOf(v) === i);
  const n = offsets.get(type) || 0; offsets.set(type, n + 1);
  const rotated = [...order.slice(n), ...order.slice(0, n)];
  const candidates = rotated.map(i => pool[i]).filter(p => p && !/rawpixel|depositphotos|dreamstime|shutterstock|istockphoto|freepik/.test(p.url));
  return { code: product.code, name: product.name, category: category.name, categoryIndex: ci, type, candidates };
}));
await mkdir('uploads/smartshop/real-photos', { recursive: true });
await writeFile('uploads/smartshop/real-photos/plan.json', JSON.stringify(plan, null, 2));
console.log(`Prepared photo plan: ${plan.length} products.`);
