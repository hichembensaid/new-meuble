USE meuble2_db;

-- H1 avec attributs de classe (copie depuis WooCommerce / ancien CMS)
-- Pattern : <h1 class="...">  et  </h1>

-- Description courte
UPDATE ps_product_lang
SET description_short = REGEXP_REPLACE(description_short, '<h1[^>]*>', '<strong>')
WHERE id_lang = 1 AND description_short REGEXP '<h1[^>]+>';

UPDATE ps_product_lang
SET description_short = REPLACE(description_short, '</h1>', '</strong>')
WHERE id_lang = 1 AND description_short LIKE '%</h1>%';

-- Description longue
UPDATE ps_product_lang
SET description = REGEXP_REPLACE(description, '<h1[^>]*>', '<strong>')
WHERE id_lang = 1 AND description REGEXP '<h1[^>]+>';

UPDATE ps_product_lang
SET description = REPLACE(description, '</h1>', '</strong>')
WHERE id_lang = 1 AND description LIKE '%</h1>%';

-- Vérification finale
SELECT COUNT(*) as h1_restants_desc_courte FROM ps_product_lang WHERE id_lang=1 AND description_short LIKE '%<h1%';
SELECT COUNT(*) as h1_restants_desc_longue FROM ps_product_lang WHERE id_lang=1 AND description LIKE '%<h1%';
