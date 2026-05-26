-- ============================================================
-- CORRECTION 9 : Optimisation du robots.txt et config SEO
-- Ce script corrige les configurations PrestaShop côté base
-- ============================================================

USE meuble2_db;

-- -----------------------------------------------------------------
-- 9.1 SSL : à activer sur la production (lart-du-meuble.tn)
--     Laisser à 0 en local, mais scripter la mise à jour prod
-- -----------------------------------------------------------------
-- Sur PROD uniquement :
-- UPDATE ps_configuration SET value='1' WHERE name='PS_SSL_ENABLED';
-- UPDATE ps_configuration SET value='1' WHERE name='PS_SSL_ENABLED_EVERYWHERE';

-- -----------------------------------------------------------------
-- 9.2 Redirections canoniques : déjà à 1 (bon)
-- -----------------------------------------------------------------
-- PS_CANONICAL_REDIRECT = 1 ← OK

-- -----------------------------------------------------------------
-- 9.3 URLs simplifiées : déjà activées (bon)
-- -----------------------------------------------------------------
-- PS_REWRITING_SETTINGS = 1 ← OK

-- -----------------------------------------------------------------
-- 9.4 Vérifier la configuration du nom de la boutique
-- -----------------------------------------------------------------
UPDATE ps_configuration 
SET value = 'L\'art du meuble Radès'
WHERE name = 'PS_SHOP_NAME';

-- -----------------------------------------------------------------
-- 9.5 Configurer le domaine de production (à faire AVANT mise en prod)
-- -----------------------------------------------------------------
-- UPDATE ps_configuration SET value='www.lart-du-meuble.tn' WHERE name='PS_SHOP_DOMAIN';
-- UPDATE ps_configuration SET value='www.lart-du-meuble.tn' WHERE name='PS_SHOP_DOMAIN_SSL';

-- -----------------------------------------------------------------
-- 9.6 Générer le sitemap XML : s'assurer que le module gsitemap est actif
-- -----------------------------------------------------------------
SELECT name, active, version FROM ps_module WHERE name = 'gsitemap';
-- Si inactif, activer via BO : Modules → gsitemap → Activer

-- -----------------------------------------------------------------
-- 9.7 Configurer les priorités du sitemap (déjà OK mais vérifier)
-- -----------------------------------------------------------------
SELECT name, value FROM ps_configuration WHERE name LIKE 'GSITEMAP%';

-- Vérifier que le sitemap est bien soumis à Google Search Console
-- URL du sitemap : https://www.lart-du-meuble.tn/fr/sitemap.xml

-- -----------------------------------------------------------------
-- 9.8 Vérifier la configuration de la langue
-- -----------------------------------------------------------------
SELECT id_lang, iso_code, language_code, active, is_rtl 
FROM ps_lang;
-- fr-fr est correct pour la Tunisie francophone
-- Si vous ajoutez l'arabe plus tard, ajouter ar-tn

-- -----------------------------------------------------------------
-- 9.9 Rapport final de santé SEO
-- -----------------------------------------------------------------
SELECT 
  'Produits totaux' as metrique, COUNT(*) as valeur FROM ps_product WHERE active=1
UNION ALL
SELECT 'Sans meta_title', COUNT(*) FROM ps_product_lang WHERE id_lang=1 AND (meta_title='' OR meta_title IS NULL)
UNION ALL
SELECT 'Sans meta_description', COUNT(*) FROM ps_product_lang WHERE id_lang=1 AND (meta_description='' OR meta_description IS NULL)
UNION ALL
SELECT 'Meta_title > 70 chars', COUNT(*) FROM ps_product_lang WHERE id_lang=1 AND LENGTH(meta_title) > 70
UNION ALL
SELECT 'Meta_desc > 160 chars', COUNT(*) FROM ps_product_lang WHERE id_lang=1 AND LENGTH(meta_description) > 160
UNION ALL
SELECT 'H1 dans desc courte', COUNT(*) FROM ps_product_lang WHERE id_lang=1 AND description_short LIKE '%<h1%'
UNION ALL
SELECT 'URL tiret final', COUNT(*) FROM ps_product_lang WHERE id_lang=1 AND link_rewrite REGEXP '-$'
UNION ALL
SELECT 'URL tiret debut', COUNT(*) FROM ps_product_lang WHERE id_lang=1 AND link_rewrite REGEXP '^-'
UNION ALL
SELECT 'URLs en doublon', COUNT(*) FROM (SELECT link_rewrite, COUNT(*) as n FROM ps_product_lang WHERE id_lang=1 GROUP BY link_rewrite HAVING n > 1) t;
