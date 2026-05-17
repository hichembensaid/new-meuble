-- ===================================================================
-- DIAGNOSTIC COMPLET DES CATÉGORIES PRESTASHOP
-- Base de données: meuble2_db
-- Préfixe: ps_
-- ===================================================================

-- 1. Vérifier la valeur de PS_HOME_CATEGORY
SELECT 'Configuration PS_HOME_CATEGORY:' as info, value as id_home_category 
FROM ps_configuration 
WHERE name = 'PS_HOME_CATEGORY';

-- 2. Vérifier la valeur de PS_ROOT_CATEGORY
SELECT 'Configuration PS_ROOT_CATEGORY:' as info, value as id_root_category 
FROM ps_configuration 
WHERE name = 'PS_ROOT_CATEGORY';

-- 3. Vérifier les paramètres du module BLOCK_CATEG
SELECT name, value 
FROM ps_configuration 
WHERE name LIKE 'BLOCK_CATEG%'
ORDER BY name;

-- 4. Afficher TOUTES les catégories de la base
SELECT 
    c.id_category,
    c.id_parent,
    c.level_depth,
    c.active,
    c.nleft,
    c.nright,
    cl.name as category_name,
    cl.link_rewrite,
    (SELECT COUNT(*) FROM ps_category c2 WHERE c2.id_parent = c.id_category) as nb_children
FROM ps_category c
LEFT JOIN ps_category_lang cl ON (c.id_category = cl.id_category AND cl.id_lang = 1)
ORDER BY c.level_depth ASC, c.id_parent ASC, c.position ASC;

-- 5. Vérifier spécifiquement la catégorie HOME et ses enfants directs
SELECT 
    'CATÉGORIE HOME:' as type,
    c.id_category,
    c.id_parent,
    c.level_depth,
    c.active,
    cl.name as category_name,
    cl.link_rewrite
FROM ps_category c
LEFT JOIN ps_category_lang cl ON (c.id_category = cl.id_category AND cl.id_lang = 1)
WHERE c.id_category = (SELECT value FROM ps_configuration WHERE name = 'PS_HOME_CATEGORY')

UNION ALL

SELECT 
    'ENFANTS DE HOME:' as type,
    c.id_category,
    c.id_parent,
    c.level_depth,
    c.active,
    cl.name as category_name,
    cl.link_rewrite
FROM ps_category c
LEFT JOIN ps_category_lang cl ON (c.id_category = cl.id_category AND cl.id_lang = 1)
WHERE c.id_parent = (SELECT value FROM ps_configuration WHERE name = 'PS_HOME_CATEGORY')
ORDER BY type DESC, id_category ASC;

-- 6. Vérifier les catégories associées à la boutique
SELECT 
    c.id_category,
    c.id_parent,
    c.active,
    cl.name as category_name,
    cs.id_shop,
    cs.position
FROM ps_category c
INNER JOIN ps_category_lang cl ON (c.id_category = cl.id_category AND cl.id_lang = 1)
INNER JOIN ps_category_shop cs ON (cs.id_category = c.id_category)
WHERE c.active = 1
AND c.id_category != 1
ORDER BY cs.id_shop, c.level_depth, cs.position;

-- 7. Vérifier les groupes de clients associés aux catégories
SELECT 
    cg.id_category,
    cl.name as category_name,
    cg.id_group,
    gl.name as group_name
FROM ps_category_group cg
INNER JOIN ps_category_lang cl ON (cg.id_category = cl.id_category AND cl.id_lang = 1)
INNER JOIN ps_group_lang gl ON (cg.id_group = gl.id_group AND gl.id_lang = 1)
WHERE cg.id_category IN (
    SELECT id_category 
    FROM ps_category 
    WHERE active = 1 
    AND id_parent = (SELECT value FROM ps_configuration WHERE name = 'PS_HOME_CATEGORY')
)
ORDER BY cg.id_category, cg.id_group;

-- 8. Compter les catégories actives par niveau
SELECT 
    level_depth,
    COUNT(*) as nb_categories,
    COUNT(CASE WHEN active = 1 THEN 1 END) as nb_active,
    COUNT(CASE WHEN active = 0 THEN 1 END) as nb_inactive
FROM ps_category
GROUP BY level_depth
ORDER BY level_depth;
