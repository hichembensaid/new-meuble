-- Migration ciblée PrestaShop 1.6.1.24 -> 8.0.1
-- Portée: catégories, produits, prix, taxes, URLs SEO/friendly
-- Hypothèse: le dump legacy est importé dans la base `legacy_ps16`.

SET NAMES utf8mb4;
SET sql_safe_updates = 0;

-- Pré-contrôles
SELECT 'target_db' AS k, DATABASE() AS v;
SELECT 'legacy_db_exists' AS k, COUNT(*) AS v
FROM information_schema.schemata
WHERE schema_name = 'legacy_ps16';

SET @old_fk_checks = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

-- ============================================================
-- 1) Mapping IDs Taxes (sans collision)
-- ============================================================
DROP TEMPORARY TABLE IF EXISTS _mig_tax_group_map;
CREATE TEMPORARY TABLE _mig_tax_group_map (
  old_id INT UNSIGNED PRIMARY KEY,
  new_id INT UNSIGNED NOT NULL UNIQUE
);

DROP TEMPORARY TABLE IF EXISTS _mig_tax_map;
CREATE TEMPORARY TABLE _mig_tax_map (
  old_id INT UNSIGNED PRIMARY KEY,
  new_id INT UNSIGNED NOT NULL UNIQUE
);

SET @tax_group_offset = (SELECT COALESCE(MAX(id_tax_rules_group), 0) FROM ps_tax_rules_group);
INSERT INTO _mig_tax_group_map(old_id, new_id)
SELECT id_tax_rules_group, @tax_group_offset + ROW_NUMBER() OVER (ORDER BY id_tax_rules_group)
FROM legacy_ps16.ps_tax_rules_group;

SET @tax_offset = (SELECT COALESCE(MAX(id_tax), 0) FROM ps_tax);
INSERT INTO _mig_tax_map(old_id, new_id)
SELECT id_tax, @tax_offset + ROW_NUMBER() OVER (ORDER BY id_tax)
FROM legacy_ps16.ps_tax;

INSERT INTO ps_tax (id_tax, rate, active, deleted)
SELECT tm.new_id, t.rate, t.active, t.deleted
FROM legacy_ps16.ps_tax t
JOIN _mig_tax_map tm ON tm.old_id = t.id_tax;

INSERT INTO ps_tax_lang (id_tax, id_lang, name)
SELECT tm.new_id, 1, tl.name
FROM legacy_ps16.ps_tax_lang tl
JOIN _mig_tax_map tm ON tm.old_id = tl.id_tax
WHERE tl.id_lang = 2;

INSERT INTO ps_tax_rules_group (id_tax_rules_group, name, active, deleted, date_add, date_upd)
SELECT gm.new_id,
       LEFT(CONCAT('[LEGACY16] ', g.name), 50),
       g.active,
       g.deleted,
       COALESCE(NULLIF(g.date_add, '0000-00-00 00:00:00'), NOW()),
       COALESCE(NULLIF(g.date_upd, '0000-00-00 00:00:00'), NOW())
FROM legacy_ps16.ps_tax_rules_group g
JOIN _mig_tax_group_map gm ON gm.old_id = g.id_tax_rules_group;

INSERT INTO ps_tax_rule
(id_tax_rule, id_tax_rules_group, id_country, id_state, zipcode_from, zipcode_to, id_tax, behavior, description)
SELECT r.id_tax_rule + 1000000,
       gm.new_id,
       r.id_country,
       r.id_state,
       r.zipcode_from,
       r.zipcode_to,
       tm.new_id,
       r.behavior,
       r.description
FROM legacy_ps16.ps_tax_rule r
JOIN _mig_tax_group_map gm ON gm.old_id = r.id_tax_rules_group
JOIN _mig_tax_map tm ON tm.old_id = r.id_tax;

INSERT INTO ps_tax_rules_group_shop (id_tax_rules_group, id_shop)
SELECT new_id, 1
FROM _mig_tax_group_map;

-- ============================================================
-- 2) Catégories
-- ============================================================
INSERT INTO ps_category
(id_category, id_parent, id_shop_default, level_depth, nleft, nright, active, date_add, date_upd, position, is_root_category)
SELECT c.id_category,
       c.id_parent,
       c.id_shop_default,
       c.level_depth,
       c.nleft,
       c.nright,
       c.active,
       COALESCE(NULLIF(c.date_add, '0000-00-00 00:00:00'), NOW()),
       COALESCE(NULLIF(c.date_upd, '0000-00-00 00:00:00'), NOW()),
       c.position,
       c.is_root_category
FROM legacy_ps16.ps_category c
WHERE c.id_category > 2
ON DUPLICATE KEY UPDATE
  id_parent = VALUES(id_parent),
  id_shop_default = VALUES(id_shop_default),
  level_depth = VALUES(level_depth),
  nleft = VALUES(nleft),
  nright = VALUES(nright),
  active = VALUES(active),
  date_upd = VALUES(date_upd),
  position = VALUES(position),
  is_root_category = VALUES(is_root_category);

INSERT INTO ps_category_shop (id_category, id_shop, position)
SELECT cs.id_category, 1, cs.position
FROM legacy_ps16.ps_category_shop cs
WHERE cs.id_shop = 1 AND cs.id_category > 2
ON DUPLICATE KEY UPDATE position = VALUES(position);

INSERT INTO ps_category_lang
(id_category, id_shop, id_lang, name, description, additional_description, link_rewrite, meta_title, meta_keywords, meta_description)
SELECT cl.id_category,
       1,
       1,
       cl.name,
       cl.description,
       NULL,
       cl.link_rewrite,
       cl.meta_title,
       cl.meta_keywords,
       cl.meta_description
FROM legacy_ps16.ps_category_lang cl
WHERE cl.id_lang = 2
  AND cl.id_shop = 1
  AND cl.id_category > 2
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  additional_description = VALUES(additional_description),
  link_rewrite = VALUES(link_rewrite),
  meta_title = VALUES(meta_title),
  meta_keywords = VALUES(meta_keywords),
  meta_description = VALUES(meta_description);

-- Permissions de catégories pour groupes clients (évite menu vide)
INSERT IGNORE INTO ps_category_group (id_category, id_group)
SELECT cg.id_category, cg.id_group
FROM legacy_ps16.ps_category_group cg
JOIN ps_category c ON c.id_category = cg.id_category
WHERE c.id_category > 2;

-- Fallback: si la source n'a pas de droits, accorder groupes 1/2/3
INSERT IGNORE INTO ps_category_group (id_category, id_group)
SELECT c.id_category, g.id_group
FROM ps_category c
JOIN ps_group g ON g.id_group IN (1, 2, 3)
WHERE c.id_category > 2;

-- ============================================================
-- 3) Produits + prix + SEO produits
-- ============================================================
INSERT INTO ps_product
(id_product, id_supplier, id_manufacturer, id_category_default, id_shop_default, id_tax_rules_group,
 on_sale, online_only, ean13, upc, ecotax, quantity, minimal_quantity, price, wholesale_price, unity,
 unit_price_ratio, additional_shipping_cost, reference, supplier_reference, location, width, height, depth, weight,
 out_of_stock, quantity_discount, customizable, uploadable_files, text_fields, active, redirect_type, id_type_redirected,
 available_for_order, available_date, `condition`, show_price, indexed, visibility, cache_is_pack, cache_has_attachments,
 is_virtual, cache_default_attribute, date_add, date_upd, advanced_stock_management, pack_stock_type, state, product_type)
SELECT p.id_product,
       p.id_supplier,
       p.id_manufacturer,
       p.id_category_default,
       p.id_shop_default,
       gm.new_id,
       p.on_sale,
       p.online_only,
       p.ean13,
       p.upc,
       p.ecotax,
       p.quantity,
       p.minimal_quantity,
       p.price,
       p.wholesale_price,
       p.unity,
       p.unit_price_ratio,
       p.additional_shipping_cost,
       p.reference,
       p.supplier_reference,
       COALESCE(p.location, ''),
       p.width,
       p.height,
       p.depth,
       p.weight,
       p.out_of_stock,
       p.quantity_discount,
       p.customizable,
       p.uploadable_files,
       p.text_fields,
       p.active,
       CASE p.redirect_type
         WHEN '301' THEN '301-product'
         WHEN '302' THEN '302-product'
         WHEN '404' THEN '404'
         ELSE '404'
       END,
       p.id_product_redirected,
       p.available_for_order,
       NULLIF(p.available_date, '0000-00-00'),
       p.`condition`,
       p.show_price,
       p.indexed,
       p.visibility,
       p.cache_is_pack,
       p.cache_has_attachments,
       p.is_virtual,
       p.cache_default_attribute,
       COALESCE(NULLIF(p.date_add, '0000-00-00 00:00:00'), NOW()),
       COALESCE(NULLIF(p.date_upd, '0000-00-00 00:00:00'), NOW()),
       p.advanced_stock_management,
       3,
       1,
       'standard'
FROM legacy_ps16.ps_product p
JOIN _mig_tax_group_map gm ON gm.old_id = p.id_tax_rules_group
ON DUPLICATE KEY UPDATE
  id_supplier = VALUES(id_supplier),
  id_manufacturer = VALUES(id_manufacturer),
  id_category_default = VALUES(id_category_default),
  id_tax_rules_group = VALUES(id_tax_rules_group),
  price = VALUES(price),
  wholesale_price = VALUES(wholesale_price),
  reference = VALUES(reference),
  active = VALUES(active),
  date_upd = VALUES(date_upd);

INSERT INTO ps_product_shop
(id_product, id_shop, id_category_default, id_tax_rules_group, on_sale, online_only, ecotax, minimal_quantity,
 price, wholesale_price, unity, unit_price_ratio, additional_shipping_cost, customizable, uploadable_files, text_fields,
 active, redirect_type, id_type_redirected, available_for_order, available_date, show_condition, `condition`, show_price, indexed,
 visibility, cache_default_attribute, advanced_stock_management, date_add, date_upd, pack_stock_type)
SELECT ps.id_product,
       1,
       ps.id_category_default,
       gm.new_id,
       ps.on_sale,
       ps.online_only,
       ps.ecotax,
       ps.minimal_quantity,
       ps.price,
       ps.wholesale_price,
       ps.unity,
       ps.unit_price_ratio,
       ps.additional_shipping_cost,
       ps.customizable,
       ps.uploadable_files,
       ps.text_fields,
       ps.active,
       CASE ps.redirect_type
         WHEN '301' THEN '301-product'
         WHEN '302' THEN '302-product'
         WHEN '404' THEN '404'
         ELSE '404'
       END,
       ps.id_product_redirected,
       ps.available_for_order,
       NULLIF(ps.available_date, '0000-00-00'),
       1,
       ps.`condition`,
       ps.show_price,
       ps.indexed,
       ps.visibility,
       ps.cache_default_attribute,
       ps.advanced_stock_management,
       COALESCE(NULLIF(ps.date_add, '0000-00-00 00:00:00'), NOW()),
       COALESCE(NULLIF(ps.date_upd, '0000-00-00 00:00:00'), NOW()),
       3
FROM legacy_ps16.ps_product_shop ps
JOIN _mig_tax_group_map gm ON gm.old_id = ps.id_tax_rules_group
ON DUPLICATE KEY UPDATE
  id_category_default = VALUES(id_category_default),
  id_tax_rules_group = VALUES(id_tax_rules_group),
  price = VALUES(price),
  wholesale_price = VALUES(wholesale_price),
  active = VALUES(active),
  date_upd = VALUES(date_upd);

INSERT INTO ps_product_lang
(id_product, id_shop, id_lang, description, description_short, link_rewrite, meta_description, meta_keywords, meta_title, name, available_now, available_later, delivery_in_stock, delivery_out_stock)
SELECT pl.id_product,
       1,
       1,
       pl.description,
       pl.description_short,
       pl.link_rewrite,
       pl.meta_description,
       pl.meta_keywords,
       pl.meta_title,
       pl.name,
       pl.available_now,
       pl.available_later,
       NULL,
       NULL
FROM legacy_ps16.ps_product_lang pl
WHERE pl.id_lang = 2
  AND pl.id_shop = 1
ON DUPLICATE KEY UPDATE
  description = VALUES(description),
  description_short = VALUES(description_short),
  link_rewrite = VALUES(link_rewrite),
  meta_description = VALUES(meta_description),
  meta_keywords = VALUES(meta_keywords),
  meta_title = VALUES(meta_title),
  name = VALUES(name),
  available_now = VALUES(available_now),
  available_later = VALUES(available_later);

-- ============================================================
-- 3-bis) Images produits (métadonnées DB)
-- IMPORTANT: les fichiers physiques doivent être copiés dans img/p
-- ============================================================
INSERT INTO ps_image (id_image, id_product, position, cover)
SELECT i.id_image,
       i.id_product,
       i.position,
       i.cover
FROM legacy_ps16.ps_image i
JOIN ps_product p ON p.id_product = i.id_product
ON DUPLICATE KEY UPDATE
  id_product = VALUES(id_product),
  position = VALUES(position),
  cover = VALUES(cover);

INSERT INTO ps_image_lang (id_image, id_lang, legend)
SELECT il.id_image,
       1,
       il.legend
FROM legacy_ps16.ps_image_lang il
JOIN ps_image i ON i.id_image = il.id_image
WHERE il.id_lang = 2
ON DUPLICATE KEY UPDATE
  legend = VALUES(legend);

INSERT INTO ps_image_shop (id_product, id_image, id_shop, cover)
SELECT i.id_product,
       ishop.id_image,
       1,
       ishop.cover
FROM legacy_ps16.ps_image_shop ishop
JOIN legacy_ps16.ps_image i ON i.id_image = ishop.id_image
JOIN ps_image ti ON ti.id_image = ishop.id_image
WHERE ishop.id_shop = 1
ON DUPLICATE KEY UPDATE
  id_product = VALUES(id_product),
  cover = VALUES(cover);

INSERT INTO ps_category_product (id_category, id_product, position)
SELECT cp.id_category, cp.id_product, cp.position
FROM legacy_ps16.ps_category_product cp
JOIN ps_category c ON c.id_category = cp.id_category
JOIN ps_product p ON p.id_product = cp.id_product
ON DUPLICATE KEY UPDATE position = VALUES(position);

INSERT INTO ps_specific_price
(id_specific_price, id_specific_price_rule, id_cart, id_product, id_shop, id_shop_group, id_currency, id_country, id_group, id_customer, id_product_attribute, price, from_quantity, reduction, reduction_tax, reduction_type, `from`, `to`)
SELECT sp.id_specific_price,
       sp.id_specific_price_rule,
       sp.id_cart,
       sp.id_product,
       sp.id_shop,
       sp.id_shop_group,
       sp.id_currency,
       sp.id_country,
       sp.id_group,
       sp.id_customer,
       sp.id_product_attribute,
       sp.price,
       sp.from_quantity,
       sp.reduction,
       sp.reduction_tax,
       sp.reduction_type,
       COALESCE(NULLIF(sp.`from`, '0000-00-00 00:00:00'), '1970-01-01 00:00:00'),
       COALESCE(NULLIF(sp.`to`, '0000-00-00 00:00:00'), '2099-12-31 23:59:59')
FROM legacy_ps16.ps_specific_price sp
JOIN ps_product p ON p.id_product = sp.id_product
ON DUPLICATE KEY UPDATE
  price = VALUES(price),
  reduction = VALUES(reduction),
  reduction_type = VALUES(reduction_type),
  `from` = VALUES(`from`),
  `to` = VALUES(`to`);

-- ============================================================
-- 4) SEO / Friendly URLs
-- ============================================================
INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
SELECT c.id_shop_group,
       c.id_shop,
       c.name,
       c.value,
       COALESCE(NULLIF(c.date_add, '0000-00-00 00:00:00'), NOW()),
       COALESCE(NULLIF(c.date_upd, '0000-00-00 00:00:00'), NOW())
FROM legacy_ps16.ps_configuration c
WHERE c.name IN ('PS_REWRITING_SETTINGS', 'PS_CANONICAL_REDIRECT')
ON DUPLICATE KEY UPDATE
  value = VALUES(value),
  date_upd = VALUES(date_upd);

INSERT INTO ps_meta_lang (id_meta, id_shop, id_lang, title, description, keywords, url_rewrite)
SELECT ml.id_meta,
       1,
       1,
       ml.title,
       ml.description,
       ml.keywords,
       ml.url_rewrite
FROM legacy_ps16.ps_meta_lang ml
JOIN ps_meta m ON m.id_meta = ml.id_meta
WHERE ml.id_lang = 2
  AND ml.id_shop = 1
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  description = VALUES(description),
  keywords = VALUES(keywords),
  url_rewrite = VALUES(url_rewrite);

-- Optionnel: reprendre l'URL de boutique legacy
-- UPDATE ps_shop_url su
-- JOIN legacy_ps16.ps_shop_url ls ON ls.id_shop = su.id_shop
-- SET su.domain = ls.domain,
--     su.domain_ssl = ls.domain_ssl,
--     su.physical_uri = ls.physical_uri,
--     su.virtual_uri = ls.virtual_uri,
--     su.main = ls.main,
--     su.active = ls.active
-- WHERE su.id_shop = 1;

-- ============================================================
-- 5) AUTO_INCREMENT + fin transaction
-- ============================================================
SET @next_category = (SELECT COALESCE(MAX(id_category), 0) + 1 FROM ps_category);
SET @next_product = (SELECT COALESCE(MAX(id_product), 0) + 1 FROM ps_product);
SET @next_image = (SELECT COALESCE(MAX(id_image), 0) + 1 FROM ps_image);
SET @next_sp = (SELECT COALESCE(MAX(id_specific_price), 0) + 1 FROM ps_specific_price);

SET @sql := CONCAT('ALTER TABLE ps_category AUTO_INCREMENT = ', @next_category);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := CONCAT('ALTER TABLE ps_product AUTO_INCREMENT = ', @next_product);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := CONCAT('ALTER TABLE ps_image AUTO_INCREMENT = ', @next_image);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := CONCAT('ALTER TABLE ps_specific_price AUTO_INCREMENT = ', @next_sp);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

COMMIT;
SET FOREIGN_KEY_CHECKS = @old_fk_checks;
