-- ============================================================
-- CORRECTION 3 : Réparation des URLs de catégories
-- ============================================================

USE meuble2_db;

-- -----------------------------------------------------------------
-- 3.1 Catégorie 44 : "Chambres D'enfant"
--     URL new : 'chambres-d-enfant-'  →  supprimer le tiret final
-- -----------------------------------------------------------------
UPDATE ps_category_lang
SET link_rewrite = 'chambres-d-enfant'
WHERE id_category = 44 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 3.2 Catégorie 67 : "Chaise Cuisine et Jardin"
--     URL new : 'chaise-cuisine-et-jardin-'  →  supprimer tiret final
-- -----------------------------------------------------------------
UPDATE ps_category_lang
SET link_rewrite = 'chaise-cuisine-et-jardin'
WHERE id_category = 67 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 3.3 Catégorie 53 : "Meuble de Jardain" (+ faute d'orthographe !)
--     URL prod : 'dressing'  →  URL new : 'meuble-de-jardin'
--     Note: si cette catégorie était indexée comme 'dressing', 
--     prévoir une redirection 301
-- -----------------------------------------------------------------
UPDATE ps_category_lang
SET link_rewrite = 'meuble-de-jardin',
    name = 'Meuble de Jardin'
WHERE id_category = 53 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 3.4 Catégorie 55 : "Séjour Banquet" 
--     URL : 'sejour-banquet-'  →  supprimer tiret final
-- -----------------------------------------------------------------
UPDATE ps_category_lang
SET link_rewrite = 'sejour-banquet'
WHERE id_category = 55 AND id_lang = 1;

-- Vérification
SELECT id_category, name, link_rewrite 
FROM ps_category_lang 
WHERE id_lang = 1 
  AND (link_rewrite REGEXP '-$' OR link_rewrite REGEXP '^-');
