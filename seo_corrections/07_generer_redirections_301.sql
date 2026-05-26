-- ============================================================
-- CORRECTION 7 : Génération du fichier de redirections 301
-- pour la migration PROD → NOUVEAU SITE
--
-- OBLIGATOIRE avant la mise en production !
-- Ces 213 redirections préservent le jus SEO des URLs indexées
-- ============================================================

-- Ce script génère les lignes .htaccess à copier-coller

USE meuble2_db;

-- -----------------------------------------------------------------
-- 7.1 Générer les redirections 301 pour les PRODUITS
--     Format : Redirect 301 /fr/old-url /fr/new-url
-- -----------------------------------------------------------------
SELECT 
  CONCAT(
    'RewriteRule ^fr/', p_old.link_rewrite, 
    '-[0-9]+\\.html$ /fr/', p_new.link_rewrite, 
    '-', n.id_product, 
    '.html [R=301,L]'
  ) as htaccess_rule,
  p_old.link_rewrite as url_prod,
  p_new.link_rewrite as url_new,
  n.id_product
FROM meuble2_db.ps_product_lang n
JOIN old_db_meuble.ps_product_lang p_new ON n.id_product = p_new.id_product AND p_new.id_lang = 1
JOIN old_db_meuble.ps_product_lang p_old ON n.id_product = p_old.id_product AND p_old.id_lang = 1
WHERE n.id_lang = 1 
  AND n.link_rewrite != p_old.link_rewrite
ORDER BY n.id_product;

-- -----------------------------------------------------------------
-- 7.2 Génération format RedirectMatch Apache (plus simple)
-- -----------------------------------------------------------------
SELECT 
  CONCAT(
    'RedirectMatch 301 ^/fr/', p_old.link_rewrite, 
    '-([0-9]+)\\.html$ /fr/', p_new.link_rewrite, 
    '-$1.html'
  ) as redirect_rule
FROM meuble2_db.ps_product_lang n
JOIN old_db_meuble.ps_product_lang p_new ON n.id_product = p_new.id_product AND p_new.id_lang = 1
JOIN old_db_meuble.ps_product_lang p_old ON n.id_product = p_old.id_product AND p_old.id_lang = 1
WHERE n.id_lang = 1 
  AND n.link_rewrite != p_old.link_rewrite
ORDER BY n.id_product;

-- -----------------------------------------------------------------
-- 7.3 Redirections pour les CATÉGORIES modifiées
-- -----------------------------------------------------------------
SELECT 
  CONCAT(
    'RedirectMatch 301 ^/fr/', cl_old.link_rewrite, 
    '-([0-9]+)/?$ /fr/', cl_new.link_rewrite, 
    '-$1/'
  ) as redirect_rule,
  cl_old.link_rewrite as url_prod,
  cl_new.link_rewrite as url_new
FROM meuble2_db.ps_category_lang cl_new
JOIN old_db_meuble.ps_category_lang cl_old ON cl_new.id_category = cl_old.id_category AND cl_old.id_lang = 1
WHERE cl_new.id_lang = 1 
  AND cl_new.link_rewrite != cl_old.link_rewrite
  AND cl_new.id_category > 2;
