-- Vérifications post-migration PS 1.6 -> PS8

-- 1) Volumétrie globale
SELECT 'ps_category' AS t, COUNT(*) AS rows_cnt FROM ps_category
UNION ALL SELECT 'ps_category_lang', COUNT(*) FROM ps_category_lang
UNION ALL SELECT 'ps_category_product', COUNT(*) FROM ps_category_product
UNION ALL SELECT 'ps_product', COUNT(*) FROM ps_product
UNION ALL SELECT 'ps_product_lang', COUNT(*) FROM ps_product_lang
UNION ALL SELECT 'ps_product_shop', COUNT(*) FROM ps_product_shop
UNION ALL SELECT 'ps_image', COUNT(*) FROM ps_image
UNION ALL SELECT 'ps_image_lang', COUNT(*) FROM ps_image_lang
UNION ALL SELECT 'ps_image_shop', COUNT(*) FROM ps_image_shop
UNION ALL SELECT 'ps_specific_price', COUNT(*) FROM ps_specific_price
UNION ALL SELECT 'ps_tax', COUNT(*) FROM ps_tax
UNION ALL SELECT 'ps_tax_rule', COUNT(*) FROM ps_tax_rule
UNION ALL SELECT 'ps_tax_rules_group', COUNT(*) FROM ps_tax_rules_group
UNION ALL SELECT 'ps_meta_lang', COUNT(*) FROM ps_meta_lang;

-- 2) Contrôle langue FR unique en target
SELECT id_lang, name, iso_code, language_code, locale, active
FROM ps_lang
ORDER BY id_lang;

-- 3) Produits sans langue FR
SELECT p.id_product
FROM ps_product p
LEFT JOIN ps_product_lang pl
  ON pl.id_product = p.id_product AND pl.id_lang = 1 AND pl.id_shop = 1
WHERE pl.id_product IS NULL
LIMIT 50;

-- 4) Produits sans catégorie par défaut valide
SELECT p.id_product, p.id_category_default
FROM ps_product p
LEFT JOIN ps_category c ON c.id_category = p.id_category_default
WHERE c.id_category IS NULL
LIMIT 50;

-- 5) Catégories avec parent manquant
SELECT c.id_category, c.id_parent
FROM ps_category c
LEFT JOIN ps_category p ON p.id_category = c.id_parent
WHERE c.id_category > 2
  AND c.id_parent <> 0
  AND p.id_category IS NULL
LIMIT 50;

-- 6) Friendly URLs vides
SELECT 'category' AS entity, id_category AS id_entity
FROM ps_category_lang
WHERE id_lang = 1 AND id_shop = 1 AND (link_rewrite IS NULL OR link_rewrite = '')
UNION ALL
SELECT 'product', id_product
FROM ps_product_lang
WHERE id_lang = 1 AND id_shop = 1 AND (link_rewrite IS NULL OR link_rewrite = '')
LIMIT 50;

-- 7) Règles de taxes orphelines
SELECT tr.id_tax_rule, tr.id_tax_rules_group, tr.id_tax
FROM ps_tax_rule tr
LEFT JOIN ps_tax_rules_group trg ON trg.id_tax_rules_group = tr.id_tax_rules_group
LEFT JOIN ps_tax t ON t.id_tax = tr.id_tax
WHERE trg.id_tax_rules_group IS NULL OR t.id_tax IS NULL
LIMIT 50;

-- 8) Contrôle rapide des routes SEO
SELECT name, value
FROM ps_configuration
WHERE name IN ('PS_REWRITING_SETTINGS', 'PS_CANONICAL_REDIRECT', 'PS_SHOP_DOMAIN', 'PS_SHOP_DOMAIN_SSL', 'PS_SHOP_URI')
   OR name LIKE 'PS_ROUTE_%'
ORDER BY name;

-- 9) Images orphelines
SELECT i.id_image, i.id_product
FROM ps_image i
LEFT JOIN ps_product p ON p.id_product = i.id_product
WHERE p.id_product IS NULL
LIMIT 50;

-- 10) Images sans ligne shop
SELECT i.id_image, i.id_product
FROM ps_image i
LEFT JOIN ps_image_shop ish
  ON ish.id_image = i.id_image AND ish.id_shop = 1
WHERE ish.id_image IS NULL
LIMIT 50;

-- 11) Images sans légende FR
SELECT i.id_image
FROM ps_image i
LEFT JOIN ps_image_lang il
  ON il.id_image = i.id_image AND il.id_lang = 1
WHERE il.id_image IS NULL
LIMIT 50;

-- 12) Produits sans image de couverture
SELECT p.id_product
FROM ps_product p
LEFT JOIN ps_image_shop ish
  ON ish.id_product = p.id_product
 AND ish.id_shop = 1
 AND ish.cover = 1
WHERE ish.id_image IS NULL
LIMIT 50;
