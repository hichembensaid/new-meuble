-- Script SQL pour configurer le module ps_categorytree_mod
-- Exécutez ce script dans phpMyAdmin si la configuration ne fonctionne pas

-- Définir la profondeur maximale à 4 niveaux
INSERT INTO ps_configuration (name, value, date_add, date_upd) 
VALUES ('BLOCK_CATEG_MAX_DEPTH', '4', NOW(), NOW())
ON DUPLICATE KEY UPDATE value = '4', date_upd = NOW();

-- Définir la catégorie racine (1 = catégorie courante)
INSERT INTO ps_configuration (name, value, date_add, date_upd) 
VALUES ('BLOCK_CATEG_ROOT_CATEGORY', '0', NOW(), NOW())
ON DUPLICATE KEY UPDATE value = '0', date_upd = NOW();

-- Tri par position (0) ou par nom (1)
INSERT INTO ps_configuration (name, value, date_add, date_upd) 
VALUES ('BLOCK_CATEG_SORT', '0', NOW(), NOW())
ON DUPLICATE KEY UPDATE value = '0', date_upd = NOW();

-- Ordre de tri : croissant (0) ou décroissant (1)
INSERT INTO ps_configuration (name, value, date_add, date_upd) 
VALUES ('BLOCK_CATEG_SORT_WAY', '0', NOW(), NOW())
ON DUPLICATE KEY UPDATE value = '0', date_upd = NOW();

-- Vérifier les valeurs
SELECT * FROM ps_configuration WHERE name LIKE 'BLOCK_CATEG%';
