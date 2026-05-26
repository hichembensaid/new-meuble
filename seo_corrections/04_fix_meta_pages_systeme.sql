-- ============================================================
-- CORRECTION 4 : Réparation des méta pages système (ps_meta_lang)
-- Les titres et URLs sont complètement mélangés suite à la
-- migration PrestaShop 1.6 → 1.7
-- ============================================================

USE meuble2_db;

-- Sauvegarder l'état actuel avant correction
CREATE TABLE IF NOT EXISTS ps_meta_lang_backup_seo AS SELECT * FROM ps_meta_lang;

-- Helper : récupérer les id_meta par page
-- SELECT id_meta, page FROM ps_meta ORDER BY page;

-- -----------------------------------------------------------------
-- 4.1 Page "cart" : doit avoir titre "Panier" et url "panier"
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Panier', ml.url_rewrite = 'panier'
WHERE m.page = 'cart' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.2 Page "discount" : doit avoir titre "Réductions" et url "reductions"
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Réductions', ml.url_rewrite = 'reductions'
WHERE m.page = 'discount' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.3 Page "history" : historique des commandes
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Historique des commandes', ml.url_rewrite = 'historique-commandes'
WHERE m.page = 'history' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.4 Page "identity" : informations personnelles
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Mes informations', ml.url_rewrite = 'mes-informations'
WHERE m.page = 'identity' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.5 Page "my-account" : mon compte
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Mon compte', ml.url_rewrite = 'mon-compte'
WHERE m.page = 'my-account' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.6 Page "order" : commander (pas "Search" !)
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Commander', ml.url_rewrite = 'commande'
WHERE m.page = 'order' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.7 Page "order-follow" : suivi de commande
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Suivi de commande', ml.url_rewrite = 'suivi-commande'
WHERE m.page = 'order-follow' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.8 Page "order-slip" : avoirs
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Avoirs', ml.url_rewrite = 'avoirs'
WHERE m.page = 'order-slip' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.9 Page "search" : recherche (pas "Nos Magasins" !)
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Recherche', ml.url_rewrite = 'recherche',
    ml.description = 'Rechercher parmi nos meubles et accessoires'
WHERE m.page = 'search' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.10 Page "stores" : nos magasins (pas "Order" !)
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Nos Magasins', ml.url_rewrite = 'nos-magasins'
WHERE m.page = 'stores' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.11 Page "registration" : inscription (pas "Cart" !)
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.title = 'Inscription', ml.url_rewrite = 'inscription'
WHERE m.page = 'registration' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.12 Page "new-products" : aligner l'url sur la prod (new-products)
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.url_rewrite = 'nouveaux-produits'
WHERE m.page = 'new-products' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.13 Page "best-sales" : aligner
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.url_rewrite = 'meilleures-ventes'
WHERE m.page = 'best-sales' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.14 Page "prices-drop" : promotions
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.url_rewrite = 'promotions'
WHERE m.page = 'prices-drop' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.15 Page "index" : ajouter l'url_rewrite manquant
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.url_rewrite = ''  -- La homepage n'a pas d'url_rewrite, c'est normal
WHERE m.page = 'index' AND ml.id_lang = 1;

-- -----------------------------------------------------------------
-- 4.16 Page "sitemap" : corriger la description en français
-- -----------------------------------------------------------------
UPDATE ps_meta_lang ml
JOIN ps_meta m ON ml.id_meta = m.id_meta
SET ml.description = 'Plan du site - L\'art du meuble rades'
WHERE m.page = 'sitemap' AND ml.id_lang = 1;

-- Vérification finale
SELECT m.page, ml.title, ml.url_rewrite, ml.description 
FROM ps_meta m
JOIN ps_meta_lang ml ON m.id_meta = ml.id_meta AND ml.id_lang = 1
ORDER BY m.page;
