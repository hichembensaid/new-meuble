-- ============================================================
-- CORRECTION 5 : Optimisation des Meta Titles et Descriptions
-- ============================================================

USE meuble2_db;

-- -----------------------------------------------------------------
-- 5.1 Corriger les meta_title vides → utiliser le nom du produit
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET meta_title = name
WHERE id_lang = 1 AND (meta_title = '' OR meta_title IS NULL);

-- -----------------------------------------------------------------
-- 5.2 Corriger les meta_description vides → utiliser description_short
--     (en nettoyant les balises HTML)
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET meta_description = SUBSTRING(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        description_short,
        '<p>', ''), '</p>', ''), '<br />', ' '), '<br>', ' '), '<h1>', ''),
    1, 155)
WHERE id_lang = 1 AND (meta_description = '' OR meta_description IS NULL)
  AND (description_short IS NOT NULL AND description_short != '');

-- -----------------------------------------------------------------
-- 5.3 Tronquer les meta_title trop longs (> 70 caractères)
--     Règle : garder 60 chars + " | L'art du meuble"  
-- -----------------------------------------------------------------
-- ATTENTION : Vérifier avant d'appliquer massivement
-- Voici les cas les plus urgents (> 75 chars) :

UPDATE ps_product_lang
SET meta_title = CONCAT(SUBSTRING(meta_title, 1, 55), ' | L\'art du meuble')
WHERE id_lang = 1 AND LENGTH(meta_title) > 75;

-- -----------------------------------------------------------------
-- 5.4 Tronquer les meta_description trop longues (> 160 caractères)
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET meta_description = CONCAT(SUBSTRING(meta_description, 1, 155), '...')
WHERE id_lang = 1 AND LENGTH(meta_description) > 160;

-- -----------------------------------------------------------------
-- 5.5 Corriger les apostrophes corrompues dans meta_title et meta_description
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET meta_title = REPLACE(meta_title, CHAR(226,128,153), "'"),
    meta_description = REPLACE(meta_description, CHAR(226,128,153), "'")
WHERE id_lang = 1 
  AND (meta_title LIKE CONCAT('%', CHAR(226,128,153), '%') 
    OR meta_description LIKE CONCAT('%', CHAR(226,128,153), '%'));

-- -----------------------------------------------------------------
-- 5.6 Optimiser la meta de la page index (homepage)
--     → Titre bien mais url_rewrite vide = normal pour la homepage
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'L\'art du meuble Radès | Meubles Tunisie - Bureautique, Maison',
    ml.description = 'Découvrez L\'art du meuble Radès : séjours, chambres à coucher, salles à manger, bureautique, cuisines et solutions de rangement en Tunisie.'
WHERE m.page = 'index' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 5.7 Corriger la meta de la page category (générique)
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Catégorie | L\'art du meuble Radès',
    ml.description = 'Parcourez nos catégories de meubles : chambre, salon, bureau, cuisine et plus - L\'art du meuble Radès, Tunisie.'
WHERE m.page = 'category' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 5.8 Corriger la meta de la page product (générique)
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Produit | L\'art du meuble Radès',
    ml.description = 'Découvrez nos produits de qualité - L\'art du meuble Radès, Tunisie.'
WHERE m.page = 'product' AND ml.id_lang = 1;

-- Vérification
SELECT COUNT(*) as encore_vides_title FROM ps_product_lang WHERE id_lang=1 AND (meta_title='' OR meta_title IS NULL);
SELECT COUNT(*) as encore_vides_desc FROM ps_product_lang WHERE id_lang=1 AND (meta_description='' OR meta_description IS NULL);
SELECT COUNT(*) as encore_trop_longs FROM ps_product_lang WHERE id_lang=1 AND LENGTH(meta_title) > 70;
