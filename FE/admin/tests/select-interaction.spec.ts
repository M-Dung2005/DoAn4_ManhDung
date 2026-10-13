import { test, expect } from '@playwright/test';
import { mockApi } from './fixtures';

for (const reducedMotion of ['reduce', 'no-preference'] as const) {
  test(`dropdown options remain clickable and close correctly (${reducedMotion})`, async ({ page }) => {
    await page.emulateMedia({ reducedMotion });
    await mockApi(page);
    await page.route('**/api/danh-muc', route => route.fulfill({ json: { success: true, data: [
      { ma_danh_muc: 8, ten_danh_muc: 'Gia dụng', trang_thai: 1 },
      { ma_danh_muc: 9, ten_danh_muc: 'Thời trang', trang_thai: 1 },
    ] } }));
    await page.goto('/products');
    await page.getByRole('combobox', { name: 'Lọc danh mục' }).click();
    const option = page.locator('.ant-select-dropdown:visible .ant-select-item-option').filter({ hasText: 'Thời trang' });
    await option.click({ timeout: 4000 });
    await expect(page.locator('.ant-select-dropdown:visible')).toHaveCount(0);
    await expect(page.locator('.ant-select').filter({ has: page.getByRole('combobox', { name: 'Lọc danh mục' }) })).toContainText('Thời trang');
    await page.getByRole('combobox', { name: 'Lọc thương hiệu' }).click();
    await page.locator('.ant-select-dropdown:visible .ant-select-item-option').filter({ hasText: 'Thương hiệu mẫu' }).click({ timeout: 4000 });
    await expect(page.locator('.ant-select-dropdown:visible')).toHaveCount(0);
    await page.getByRole('button', { name: 'Sửa sản phẩm', exact: true }).click();
    await page.locator('.ant-select').filter({ has: page.getByLabel('Trạng thái', { exact: true }) }).click();
    await page.getByTitle('Ngừng bán', { exact: true }).click({ timeout: 4000 });
    await expect(page.locator('.ant-select-dropdown:visible')).toHaveCount(0);
    await expect(page.getByRole('dialog')).toContainText('Ngừng bán');
  });
}

test('category and specification group dropdowns work with reduced motion', async ({ page }) => {
  await page.emulateMedia({ reducedMotion: 'reduce' });
  await mockApi(page);
  await page.route('**/api/danh-muc', route => route.fulfill({ json: { success: true, data: [
    { ma_danh_muc: 8, ten_danh_muc: 'Gia dụng', trang_thai: 1 },
    { ma_danh_muc: 9, ten_danh_muc: 'Thời trang', trang_thai: 1 },
  ] } }));
  await page.route('**/api/thong-so/nhom', route => route.fulfill({ json: { success: true, data: [
    { ma_nhom_thong_so: 1, ten_nhom_thong_so: 'Thuộc tính sản phẩm', trang_thai: 1 },
  ] } }));
  await page.route('**/api/thong-so', route => route.fulfill({ json: { success: true, data: [] } }));
  await page.goto('/category-specifications');
  await page.locator('.ant-tabs-tabpane-active .ant-select').first().click();
  await page.getByTitle('Thời trang', { exact: true }).last().click({ timeout: 4000 });
  await expect(page).toHaveURL(/category=9/);
  await expect(page.locator('.ant-select-dropdown:visible')).toHaveCount(0);
  await page.getByRole('tab', { name: 'Thư viện Thuộc tính sản phẩm' }).click();
  await page.locator('.ant-tabs-tabpane-active .ant-select').click();
  await page.getByTitle('Thuộc tính sản phẩm', { exact: true }).last().click({ timeout: 4000 });
  await expect(page.locator('.ant-tabs-tabpane-active .ant-select')).toContainText('Thuộc tính sản phẩm');
  await expect(page.locator('.ant-select-dropdown:visible')).toHaveCount(0);
  // Preference changes while the app is running must also update Ant Design motion.
  await page.emulateMedia({ reducedMotion: 'no-preference' });
  await page.locator('.ant-tabs-tabpane-active .ant-select').click();
  await page.getByTitle('Tất cả các nhóm', { exact: true }).last().click({ timeout: 4000 });
  await expect(page.locator('.ant-select-dropdown:visible')).toHaveCount(0);
});
