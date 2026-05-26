-- ============================================================
-- CORRECTION 6 : Suppression des balises H1 dans les descriptions
--
-- Une balise <h1> dans la description produit entre en conflit
-- avec le H1 de la page (le nom du produit) → problème SEO grave
-- Google peut pénaliser ou ignorer le contenu dupliqué en H1
-- ============================================================

USE meuble2_db;

-- -----------------------------------------------------------------
-- 6.1 Remplacer <h1> et </h1> par <strong> et </strong>
--     dans description_short
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET description_short = REPLACE(REPLACE(description_short, '<h1>', '<strong>'), '</h1>', '</strong>')
WHERE id_lang = 1 AND description_short LIKE '%<h1%';

-- -----------------------------------------------------------------
-- 6.2 Même correction dans la description longue
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET description = REPLACE(REPLACE(description, '<h1>', '<strong>'), '</h1>', '</strong>')
WHERE id_lang = 1 AND description LIKE '%<h1%';

-- -----------------------------------------------------------------
-- 6.3 Remplacer aussi <H1> majuscule (au cas où)
-- -----------------------------------------------------------------
UPDATE ps_product_lang
SET description_short = REPLACE(REPLACE(description_short, '<H1>', '<strong>'), '</H1>', '</strong>'),
    description = REPLACE(REPLACE(description, '<H1>', '<strong>'), '</H1>', '</strong>')
WHERE id_lang = 1 
  AND (description_short LIKE '%<H1%' OR description LIKE '%<H1%');

-- -----------------------------------------------------------------
-- 6.4 Vérifier si des <h2> abusifs existent aussi dans description_short
-- -----------------------------------------------------------------
SELECT COUNT(*) as h2_in_desc_courte 
FROM ps_product_lang 
WHERE id_lang = 1 AND description_short LIKE '%<h2%';

-- Vérification
SELECT COUNT(*) as h1_restants_desc_courte FROM ps_product_lang WHERE id_lang=1 AND description_short LIKE '%<h1%';
SELECT COUNT(*) as h1_restants_desc_longue FROM ps_product_lang WHERE id_lang=1 AND description LIKE '%<h1%';
