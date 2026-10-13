import test from 'node:test';
import assert from 'node:assert/strict';
import { expandedCatalog } from '../database/smartshop-expanded-catalog.mjs';
import { specificationsForVariant } from '../database/smartshop-variant-specifications.mjs';

test('catalog variants expose selectable individual options instead of the product alternative list', () => {
  for (const product of expandedCatalog.flatMap(category => category.products)) {
    const specifications = Object.entries(product.specs).map(([name, value], i) => ({ ma_thong_so: i + 1, ten_thong_so: name, gia_tri: value }));
    const original = structuredClone(specifications);
    const options = product.variants.map(variant => specificationsForVariant(specifications, variant.name));
    const choices = options.map(specs => specs.find(s => s.ten_thong_so === 'Màu sắc / phiên bản').gia_tri);
    const sizes = options.map(specs => specs.find(s => s.ten_thong_so === 'Kích cỡ')?.gia_tri);
    // Different SKU names must have distinguishable color/version or size choices.
    assert.equal(new Set(options.map((_, i) => `${choices[i]}:${sizes[i] || ''}`)).size, product.variants.length, product.code);
    assert.deepEqual(specifications, original, 'Product-level alternatives stay unchanged');
  }
});

test('watch strap colors and clothing sizes are separate choices', () => {
  const watch = expandedCatalog.flatMap(c => c.products).find(p => p.code === 'SS-0310');
  const spec = [{ ten_thong_so: 'Màu sắc / phiên bản', gia_tri: watch.specs['Màu sắc / phiên bản'] }];
  assert.deepEqual(watch.variants.map(v => specificationsForVariant(spec, v.name)[0].gia_tri), ['Dây trắng', 'Dây hồng']);
  const specs = [{ ten_thong_so: 'Màu sắc / phiên bản', gia_tri: 'Trắng / M / Trắng / L' }, { ten_thong_so: 'Kích cỡ', gia_tri: 'M / L' }];
  assert.deepEqual(specificationsForVariant(specs, 'Trắng / L').map(s => s.gia_tri), ['Trắng', 'L']);
});
