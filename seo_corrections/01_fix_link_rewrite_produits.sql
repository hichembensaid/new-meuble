-- ============================================================
-- CORRECTION 1 : Nettoyage des link_rewrite produits
-- - Suppression tirets en début et fin
-- - Correction noms avec espace en début (cause du tiret initial)
-- - Correction apostrophe typographique (U+2019)
-- ============================================================

USE meuble2_db;

-- -----------------------------------------------------------------
-- 1.1 Corriger les noms de produits avec espace en début
--     → cause directe des link_rewrite commençant par '-'
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET name = TRIM(name)
WHERE id_lang = 1 AND name LIKE ' %';

-- -----------------------------------------------------------------
-- 1.2 Remplacer l'apostrophe typographique ' (U+2019 = 0xE2 0x80 0x99)
--     par une apostrophe standard dans les noms produits
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET name = REPLACE(name, CHAR(226,128,153), "'")
WHERE id_lang = 1 AND name LIKE CONCAT('%', CHAR(226,128,153), '%');

-- -----------------------------------------------------------------
-- 1.3 Supprimer les tirets en FIN de link_rewrite (produits)
--     Appliqué de façon récursive pour les doubles tirets finaux
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET link_rewrite = TRIM(TRAILING '-' FROM link_rewrite)
WHERE id_lang = 1 AND link_rewrite REGEXP '-$';

-- Repasser une 2e fois si double tiret final
UPDATE ps_product_lang
SET link_rewrite = TRIM(TRAILING '-' FROM link_rewrite)
WHERE id_lang = 1 AND link_rewrite REGEXP '-$';

-- -----------------------------------------------------------------
-- 1.4 Supprimer les tirets en DÉBUT de link_rewrite (produits)
--     Causés par les espaces en début de nom (corrigés en 1.1)
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET link_rewrite = TRIM(LEADING '-' FROM link_rewrite)
WHERE id_lang = 1 AND link_rewrite REGEXP '^-';

-- -----------------------------------------------------------------
-- 1.5 Corrections manuelles des link_rewrite invalides ou trop génériques
--     qui correspondent à plusieurs produits différents
-- -----------------------------------------------------------------

-- Produit 281 : QUANTUM (espace en début de nom corrigé en 1.1, 
--               regenerer le link_rewrite)
UPDATE ps_product_lang
SET link_rewrite = 'quantum-siege-de-bureau-ergonomique-tissu-filet'
WHERE id_product = 281 AND id_lang = 1;

-- Produit 501 : Oreiller
UPDATE ps_product_lang
SET link_rewrite = 'oreiller-polycoton-70x50cm-850gr'
WHERE id_product = 501 AND id_lang = 1;

-- Produit 553 : SEDAN HD
UPDATE ps_product_lang
SET link_rewrite = 'chaise-de-bureau-sedan-hd'
WHERE id_product = 553 AND id_lang = 1;

-- Produit 554 : SEDAN BD
UPDATE ps_product_lang
SET link_rewrite = 'chaise-de-bureau-sedan-bd'
WHERE id_product = 554 AND id_lang = 1;

-- Produit 558 : Ariel Mesh
UPDATE ps_product_lang
SET link_rewrite = 'chaise-de-bureau-ariel-mesh'
WHERE id_product = 558 AND id_lang = 1;

-- Produit 560 : COSTA Mesh
UPDATE ps_product_lang
SET link_rewrite = 'chaise-de-bureau-costa-mesh'
WHERE id_product = 560 AND id_lang = 1;

-- Vérification finale
SELECT id_product, name, link_rewrite 
FROM ps_product_lang 
WHERE id_lang = 1 
  AND (link_rewrite REGEXP '^-' OR link_rewrite REGEXP '-$')
ORDER BY id_product;
