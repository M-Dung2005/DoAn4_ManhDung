// Product-level attributes may list alternatives. A variant stores its own choice.
export function specificationsForVariant(specifications, variantName) {
  const parts = variantName.split('/').map(value => value.trim());
  return specifications.map(spec => {
    if (spec.ten_thong_so === 'Màu sắc / phiên bản') return { ...spec, gia_tri: parts[0] };
    if (spec.ten_thong_so === 'Kích cỡ' && parts.length > 1) return { ...spec, gia_tri: parts.at(-1) };
    return { ...spec };
  });
}
