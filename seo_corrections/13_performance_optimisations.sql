-- ============================================================
-- OPTIMISATIONS PERFORMANCE PRESTASHOP
-- Exécuter sur meuble2_db
-- ============================================================

-- 1. Combinaison + minification CSS (réduit les requêtes HTTP)
UPDATE ps_configuration SET value = 1 WHERE name = 'PS_CSS_THEME_CACHE';

-- 2. Combinaison + minification JS
UPDATE ps_configuration SET value = 1 WHERE name = 'PS_JS_THEME_CACHE';

-- 3. Chargement JS différé (defer) — les scripts ne bloquent plus le rendu HTML
UPDATE ps_configuration SET value = 1 WHERE name = 'PS_JS_DEFER';

-- 4. Cache des templates Smarty (évite recompilation à chaque requête)
-- Note : sera activé via le vrai cache PS plus tard, on prépare ici
-- UPDATE ps_configuration SET value = 1 WHERE name = 'PS_SMARTY_CACHE';

-- 5. Désactiver l'affichage des erreurs en production
UPDATE ps_configuration SET value = 0 WHERE name = 'PS_SHOW_ALL_MODULES';

-- Vérification
SELECT name, value FROM ps_configuration
WHERE name IN ('PS_CSS_THEME_CACHE','PS_JS_THEME_CACHE','PS_JS_DEFER','PS_SMARTY_CACHE')
ORDER BY name;
