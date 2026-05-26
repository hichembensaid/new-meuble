-- ============================================================
-- OPTIMISATION 10 : Meta des catégories manquantes ou trop courtes
-- ============================================================

USE meuble2_db;

-- Catégorie 54 : Eléments de cuisine (NULL title et desc)
UPDATE ps_category_lang SET
  meta_title = 'Eléments de cuisine - Meubles de cuisine Tunisie',
  meta_description = 'Découvrez nos éléments de cuisine : caissons, plans de travail, façades. L\'art du meuble Radès, fabrication et vente de meubles en Tunisie.'
WHERE id_category = 54 AND id_lang = 1;

-- Catégorie 72 : Armoire (NULL title et desc)
UPDATE ps_category_lang SET
  meta_title = 'Armoires et rangements - L\'art du meuble Radès',
  meta_description = 'Armoires 2 portes, portes coulissantes, armoires stratifiées. Large choix de solutions de rangement - L\'art du meuble Radès Tunisie.'
WHERE id_category = 72 AND id_lang = 1;

-- Catégorie 77 : Call center (NULL title)
UPDATE ps_category_lang SET
  meta_title = 'Mobilier Call Center - Bureaux et postes de travail'
WHERE id_category = 77 AND id_lang = 1;

-- Catégorie 53 : Meuble de Jardin (meta_title trop long = 85 chars)
UPDATE ps_category_lang SET
  meta_title = 'Mobilier de Jardin - Salons et tables extérieur Tunisie'
WHERE id_category = 53 AND id_lang = 1;

-- Catégorie 48 : Salons massif (meta_description > 160)
UPDATE ps_category_lang SET
  meta_description = CONCAT(SUBSTRING(meta_description, 1, 157), '...')
WHERE id_category = 48 AND id_lang = 1 AND CHAR_LENGTH(meta_description) > 160;

-- Catégorie 50 : Tables (meta_description > 160)
UPDATE ps_category_lang SET
  meta_description = CONCAT(SUBSTRING(meta_description, 1, 157), '...')
WHERE id_category = 50 AND id_lang = 1 AND CHAR_LENGTH(meta_description) > 160;

-- Catégorie 58, 59, 60 : Bureaux (meta_description > 160)
UPDATE ps_category_lang SET
  meta_description = CONCAT(SUBSTRING(meta_description, 1, 157), '...')
WHERE id_category IN (58,59,60) AND id_lang = 1 AND CHAR_LENGTH(meta_description) > 160;

-- Catégorie 63 : Table Basse (meta_description > 160)
UPDATE ps_category_lang SET
  meta_description = CONCAT(SUBSTRING(meta_description, 1, 157), '...')
WHERE id_category = 63 AND id_lang = 1 AND CHAR_LENGTH(meta_description) > 160;

-- Catégorie 64 : Table Cuisine (meta_description > 160)
UPDATE ps_category_lang SET
  meta_description = CONCAT(SUBSTRING(meta_description, 1, 157), '...')
WHERE id_category = 64 AND id_lang = 1 AND CHAR_LENGTH(meta_description) > 160;

-- Vérification
SELECT id_category, name, CHAR_LENGTH(meta_title) as t_len, CHAR_LENGTH(meta_description) as d_len
FROM ps_category_lang WHERE id_lang=1 AND id_category > 2
  AND (meta_title IS NULL OR meta_description IS NULL OR CHAR_LENGTH(meta_title) > 70 OR CHAR_LENGTH(meta_description) > 160);
