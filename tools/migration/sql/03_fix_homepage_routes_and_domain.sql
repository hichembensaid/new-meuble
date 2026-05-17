-- Correctif post-migration: éviter home vide liée aux routes/domaine importés
-- Cible locale: meuble2.localhost

START TRANSACTION;

-- 1) Supprimer les routes legacy potentiellement nulles/invalides
DELETE FROM ps_configuration
WHERE name LIKE 'PS_ROUTE_%';

-- 2) Nettoyer les clés de domaine/URI et ne garder qu'une valeur locale
DELETE FROM ps_configuration
WHERE name IN ('PS_SHOP_DOMAIN', 'PS_SHOP_DOMAIN_SSL', 'PS_SHOP_URI');

INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
VALUES
(NULL, NULL, 'PS_SHOP_DOMAIN', 'meuble2.localhost', NOW(), NOW()),
(NULL, NULL, 'PS_SHOP_DOMAIN_SSL', 'meuble2.localhost', NOW(), NOW()),
(NULL, NULL, 'PS_SHOP_URI', '/', NOW(), NOW())
ON DUPLICATE KEY UPDATE
value = VALUES(value),
date_upd = VALUES(date_upd);

-- 3) Friendly URLs ON / canonical ON
DELETE FROM ps_configuration
WHERE name IN ('PS_REWRITING_SETTINGS', 'PS_CANONICAL_REDIRECT');

INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
VALUES
(NULL, NULL, 'PS_REWRITING_SETTINGS', '1', NOW(), NOW()),
(NULL, NULL, 'PS_CANONICAL_REDIRECT', '1', NOW(), NOW())
ON DUPLICATE KEY UPDATE
value = VALUES(value),
date_upd = VALUES(date_upd);

COMMIT;
