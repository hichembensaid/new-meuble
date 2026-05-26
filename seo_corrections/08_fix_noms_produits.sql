-- ============================================================
-- CORRECTION 8 : Nettoyage des noms de produits
-- - Noms en TOUT MAJUSCULES (mauvaise pratique SEO)
-- - Noms trop courts ou cryptiques
-- - Fautes d'orthographe détectées
-- ============================================================

USE meuble2_db;

-- -----------------------------------------------------------------
-- 8.1 Corriger les fautes d'orthographe dans les noms de catégories
-- -----------------------------------------------------------------

-- "Jardain" → "Jardin"
UPDATE ps_category_lang
SET name = 'Meuble de Jardin'
WHERE id_category = 53 AND id_lang = 1 AND name LIKE '%Jardain%';

-- -----------------------------------------------------------------
-- 8.2 Corriger les noms de produits avec fautes connues
-- -----------------------------------------------------------------

-- "CHAMBRE A COUCHE VICTORIA" → manque le 'R'
UPDATE ps_product_lang
SET name = 'CHAMBRE À COUCHER VICTORIA'
WHERE id_product = 419 AND id_lang = 1;

-- "Chaise ARCHITECTE confort avec dos" → référence doublon avec 592
-- id 203 et 592 ont le même nom mais URLs différentes → OK

-- "BUREAU COMPTOIRE" → devrait être COMPTOIR
UPDATE ps_product_lang
SET name = 'BUREAU COMPTOIR'
WHERE id_product = 103 AND id_lang = 1;

-- "TABLE PAILLASE" → PAILLASSE
UPDATE ps_product_lang
SET name = 'TABLE PAILLASSE'
WHERE id_product = 88 AND id_lang = 1;

-- "TABLE VINTAGECompact" → espacer
UPDATE ps_product_lang
SET name = 'TABLE VINTAGE Compact',
    link_rewrite = 'table-vintage-compact'
WHERE id_product = 439 AND id_lang = 1;

-- "ME U1 Astro" → nom trop cryptique, peu SEO-friendly
UPDATE ps_product_lang
SET name = 'Meuble Entrée Astro U1'
WHERE id_product = 320 AND id_lang = 1;

-- "Salle a manger Scondinave blenz" → "Scandinave"
UPDATE ps_product_lang
SET name = 'Salle à Manger Scandinave Blenz 6 Places',
    link_rewrite = 'salle-a-manger-scandinave-blenz-6-places'
WHERE id_product = 594 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 8.3 Corriger les apostrophes typographiques dans les NOMS
--     (déjà couvert en script 01 mais double check catégories)
-- -----------------------------------------------------------------
UPDATE ps_category_lang
SET name = REPLACE(name, CHAR(226,128,153), "'")
WHERE id_lang = 1 AND name LIKE CONCAT('%', CHAR(226,128,153), '%');

-- -----------------------------------------------------------------
-- 8.4 Produit 636 : nom "Mécanisme Basculant Simple Commande" 
--     avec link_rewrite "chaise-ergonomique-seoul-eco" ← FAUX !
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET link_rewrite = 'mecanisme-basculant-simple-commande'
WHERE id_product = 636 AND id_lang = 1;

-- Vérification
SELECT id_product, name, link_rewrite FROM ps_product_lang 
WHERE id_lang = 1 
ORDER BY id_product 
LIMIT 10;
