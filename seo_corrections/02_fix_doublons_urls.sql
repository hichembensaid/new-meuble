-- ============================================================
-- CORRECTION 2 : Résolution des doublons d'URLs (duplicate content)
-- ============================================================

USE meuble2_db;

-- -----------------------------------------------------------------
-- 2.1 CHAMBRE À COUCHER KINDA (3 produits avec même URL !)
--     IDs : 529, 530, 531
--     → Différencier par couleur/variante
-- -----------------------------------------------------------------
-- Vérifier d'abord les différences entre ces 3 produits :
SELECT p.id_product, pl.name, pl.link_rewrite, pa.reference,
       GROUP_CONCAT(DISTINCT av.name ORDER BY av.name SEPARATOR ', ') as variantes
FROM ps_product p
JOIN ps_product_lang pl ON p.id_product = pl.id_product AND pl.id_lang = 1
JOIN ps_product_attribute pa ON p.id_product = pa.id_product
JOIN ps_product_attribute_combination pac ON pa.id_product_attribute = pac.id_product_attribute
JOIN ps_attribute_lang av ON pac.id_attribute = av.id_attribute AND av.id_lang = 1
WHERE p.id_product IN (529, 530, 531)
GROUP BY p.id_product;

-- Mise à jour (adapter selon variantes réelles)
UPDATE ps_product_lang SET link_rewrite = 'chambre-a-coucher-kinda-blanc'
WHERE id_product = 529 AND id_lang = 1;

UPDATE ps_product_lang SET link_rewrite = 'chambre-a-coucher-kinda-gris'
WHERE id_product = 530 AND id_lang = 1;

UPDATE ps_product_lang SET link_rewrite = 'chambre-a-coucher-kinda-noyer'
WHERE id_product = 531 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 2.2 Bureau Standard stratifié à tiroirs (IDs : 212 et 634)
-- -----------------------------------------------------------------
UPDATE ps_product_lang SET link_rewrite = 'bureau-standard-stratifie-a-tiroirs-2'
WHERE id_product = 634 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 2.3 Chaise ERGO Avec Accoudoir vs Chaise BRIO (IDs : 157 et 561)
--     → Le 561 est "Chaise Secrétaire BRIO" : URL complètement fausse !
-- -----------------------------------------------------------------
UPDATE ps_product_lang 
SET link_rewrite = 'chaise-secretaire-brio-hd-sans-accoudoirs',
    name = 'Chaise Secrétaire BRIO Haut Dossier SANS Accoudoirs'
WHERE id_product = 561 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 2.4 Chaise VEGA avec têtière (IDs : 712 et 713)
-- -----------------------------------------------------------------
UPDATE ps_product_lang SET link_rewrite = 'chaise-vega-avec-tetiere-tissu'
WHERE id_product = 712 AND id_lang = 1;

UPDATE ps_product_lang SET link_rewrite = 'chaise-vega-avec-tetiere-cuir'
WHERE id_product = 713 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 2.5 Porte Chaussure Stratifie (IDs : 26 et 27)
-- -----------------------------------------------------------------
UPDATE ps_product_lang SET link_rewrite = 'porte-chaussure-stratifie-pm'
WHERE id_product = 26 AND id_lang = 1;

UPDATE ps_product_lang SET link_rewrite = 'porte-chaussure-stratifie-gm'
WHERE id_product = 27 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 2.6 Salle à manger royal bois blenz 6 places (IDs : 605 et 646)
-- -----------------------------------------------------------------
UPDATE ps_product_lang SET link_rewrite = 'salle-a-manger-royal-bois-blenz-6-places-rectangle'
WHERE id_product = 605 AND id_lang = 1;

UPDATE ps_product_lang SET link_rewrite = 'salle-a-manger-royal-bois-blenz-6-places-ronde'
WHERE id_product = 646 AND id_lang = 1;

-- -----------------------------------------------------------------
-- 2.7 Vérin fauteuil (IDs : 697 et 701)
-- -----------------------------------------------------------------
UPDATE ps_product_lang SET link_rewrite = 'verin-metal-chrome-rechange-fauteuil-bureau'
WHERE id_product = 697 AND id_lang = 1;
-- (701 garde 'verin-de-rechange-pour-fauteuil-de-bureau')

-- Vérification : plus aucun doublon
SELECT link_rewrite, COUNT(*) as nb, GROUP_CONCAT(id_product) as ids
FROM ps_product_lang 
WHERE id_lang = 1 
GROUP BY link_rewrite 
HAVING COUNT(*) > 1;
