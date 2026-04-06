// Approx FX → SAR (indicative, 2026). Update via remote config in production.
const Map<String, double> kFx = {
  'SAR': 1.0,
  'USD': 3.75,
  'EUR': 4.05,
  'AED': 1.02,
  'GBP': 4.75,
  'CNY': 0.52,
};

class Category {
  final String key;
  final String en;
  final String ar;
  final double duty; // %
  const Category(this.key, this.en, this.ar, this.duty);
}

// Indicative ZATCA Integrated Tariff rates (2026). For estimation only.
const List<Category> kCategories = [
  Category('general',     'General goods',              'بضائع عامة',              5),
  Category('electronics', 'Electronics & appliances',   'إلكترونيات وأجهزة',       5),
  Category('clothing',    'Clothing & textiles',        'ملابس ومنسوجات',          12),
  Category('shoes',       'Footwear',                   'أحذية',                   12),
  Category('cosmetics',   'Cosmetics & perfumes',       'مستحضرات تجميل وعطور',    6.5),
  Category('furniture',   'Furniture',                  'أثاث',                    12),
  Category('toys',        'Toys & games',               'ألعاب',                   5),
  Category('auto',        'Auto parts',                 'قطع غيار سيارات',         5),
  Category('food',        'Processed food',             'مواد غذائية مصنعة',       5),
  Category('tobacco',     'Tobacco products',           'منتجات التبغ',            100),
  Category('building',    'Building materials (steel)', 'مواد بناء (حديد)',        20),
  Category('chemicals',   'Chemicals',                  'مواد كيميائية',           6.5),
  Category('books',       'Books & printed matter',     'كتب ومطبوعات',            0),
  Category('medical',     'Medical equipment',          'معدات طبية',              0),
];
