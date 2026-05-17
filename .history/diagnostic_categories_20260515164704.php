<?php
/**
 * Script de diagnostic pour les catégories PrestaShop
 * Vérifie pourquoi le bloc catégories est vide
 */

// Configuration de la base de données
$host = '127.0.0.1';
$port = '3307';
$dbname = 'meuble2_db';
$user = 'root';
$password = '';
$prefix = 'ps_';

// Connexion à la base de données
try {
    $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=================================================================\n";
    echo "DIAGNOSTIC DES CATÉGORIES PRESTASHOP\n";
    echo "=================================================================\n\n";
    
    // 1. Vérifier PS_HOME_CATEGORY
    echo "1. Configuration PS_HOME_CATEGORY:\n";
    echo "-----------------------------------\n";
    $stmt = $pdo->query("SELECT value FROM {$prefix}configuration WHERE name = 'PS_HOME_CATEGORY'");
    $homeCategory = $stmt->fetchColumn();
    echo "ID de la catégorie HOME: $homeCategory\n\n";
    
    // 2. Vérifier PS_ROOT_CATEGORY
    echo "2. Configuration PS_ROOT_CATEGORY:\n";
    echo "-----------------------------------\n";
    $stmt = $pdo->query("SELECT value FROM {$prefix}configuration WHERE name = 'PS_ROOT_CATEGORY'");
    $rootCategory = $stmt->fetchColumn();
    echo "ID de la catégorie ROOT: $rootCategory\n\n";
    
    // 3. Vérifier les paramètres BLOCK_CATEG
    echo "3. Paramètres du module BLOCK_CATEG:\n";
    echo "-------------------------------------\n";
    $stmt = $pdo->query("SELECT name, value FROM {$prefix}configuration WHERE name LIKE 'BLOCK_CATEG%' ORDER BY name");
    $blockParams = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (empty($blockParams)) {
        echo "⚠️  PROBLÈME: Aucun paramètre BLOCK_CATEG trouvé!\n";
        echo "   Le module n'a pas été configuré correctement.\n\n";
    } else {
        foreach ($blockParams as $param) {
            echo "  {$param['name']}: {$param['value']}\n";
        }
        echo "\n";
    }
    
    // 4. Informations sur la catégorie HOME
    echo "4. Détails de la catégorie HOME (ID: $homeCategory):\n";
    echo "----------------------------------------------------\n";
    $stmt = $pdo->prepare("
        SELECT 
            c.id_category,
            c.id_parent,
            c.level_depth,
            c.active,
            c.nleft,
            c.nright,
            cl.name,
            cl.link_rewrite
        FROM {$prefix}category c
        LEFT JOIN {$prefix}category_lang cl ON (c.id_category = cl.id_category AND cl.id_lang = 1)
        WHERE c.id_category = ?
    ");
    $stmt->execute([$homeCategory]);
    $home = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($home) {
        echo "  Nom: {$home['name']}\n";
        echo "  Active: " . ($home['active'] ? "OUI ✓" : "NON ✗") . "\n";
        echo "  Niveau: {$home['level_depth']}\n";
        echo "  Parent: {$home['id_parent']}\n";
        echo "  nleft: {$home['nleft']}, nright: {$home['nright']}\n\n";
    } else {
        echo "⚠️  ERREUR: Catégorie HOME introuvable!\n\n";
    }
    
    // 5. Compter les enfants directs de la catégorie HOME
    echo "5. Enfants DIRECTS de la catégorie HOME:\n";
    echo "----------------------------------------\n";
    $stmt = $pdo->prepare("
        SELECT 
            c.id_category,
            c.active,
            c.level_depth,
            cl.name,
            cl.link_rewrite,
            (SELECT COUNT(*) FROM {$prefix}category c2 WHERE c2.id_parent = c.id_category) as nb_children
        FROM {$prefix}category c
        LEFT JOIN {$prefix}category_lang cl ON (c.id_category = cl.id_category AND cl.id_lang = 1)
        WHERE c.id_parent = ?
        ORDER BY c.position
    ");
    $stmt->execute([$homeCategory]);
    $children = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($children)) {
        echo "❌ PROBLÈME TROUVÉ: La catégorie HOME n'a AUCUN enfant!\n";
        echo "   C'est pourquoi le bloc catégories est vide.\n\n";
    } else {
        echo "Nombre d'enfants: " . count($children) . "\n\n";
        foreach ($children as $child) {
            $activeIcon = $child['active'] ? "✓" : "✗";
            echo "  [{$activeIcon}] ID: {$child['id_category']} - {$child['name']} ({$child['nb_children']} sous-catégories)\n";
        }
        echo "\n";
    }
    
    // 6. Vérifier TOUTES les catégories actives
    echo "6. TOUTES les catégories actives de la base:\n";
    echo "--------------------------------------------\n";
    $stmt = $pdo->query("
        SELECT 
            c.id_category,
            c.id_parent,
            c.level_depth,
            c.active,
            cl.name,
            (SELECT COUNT(*) FROM {$prefix}category c2 WHERE c2.id_parent = c.id_category) as nb_children
        FROM {$prefix}category c
        LEFT JOIN {$prefix}category_lang cl ON (c.id_category = cl.id_category AND cl.id_lang = 1)
        WHERE c.active = 1 AND c.id_category != 1
        ORDER BY c.level_depth, c.position
    ");
    $allCategories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Nombre total de catégories actives: " . count($allCategories) . "\n\n";
    foreach ($allCategories as $cat) {
        $indent = str_repeat("  ", $cat['level_depth']);
        echo "{$indent}ID: {$cat['id_category']} (parent: {$cat['id_parent']}) - {$cat['name']} ({$cat['nb_children']} enfants)\n";
    }
    echo "\n";
    
    // 7. Vérifier l'association avec la boutique
    echo "7. Catégories associées à la boutique:\n";
    echo "--------------------------------------\n";
    $stmt = $pdo->query("
        SELECT 
            cs.id_category,
            cs.id_shop,
            cl.name
        FROM {$prefix}category_shop cs
        INNER JOIN {$prefix}category_lang cl ON (cs.id_category = cl.id_category AND cl.id_lang = 1)
        WHERE cs.id_category IN (
            SELECT id_category FROM {$prefix}category WHERE id_parent = $homeCategory
        )
        ORDER BY cs.id_shop, cs.position
    ");
    $shopCategories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($shopCategories)) {
        echo "⚠️  PROBLÈME: Les catégories ne sont pas associées à une boutique!\n\n";
    } else {
        echo "Nombre de catégories dans la boutique: " . count($shopCategories) . "\n\n";
        foreach ($shopCategories as $shopCat) {
            echo "  Shop {$shopCat['id_shop']} - ID: {$shopCat['id_category']} - {$shopCat['name']}\n";
        }
        echo "\n";
    }
    
    // 8. DIAGNOSTIC FINAL
    echo "=================================================================\n";
    echo "DIAGNOSTIC FINAL:\n";
    echo "=================================================================\n";
    
    $problems = [];
    
    if (empty($blockParams)) {
        $problems[] = "⚠️  Le module ps_categorytree_mod n'est pas configuré (paramètres BLOCK_CATEG manquants)";
    }
    
    if (empty($children)) {
        $problems[] = "❌ CAUSE PRINCIPALE: La catégorie HOME (ID: $homeCategory) n'a AUCUNE sous-catégorie!";
    } else {
        $activeChildren = array_filter($children, function($c) { return $c['active'] == 1; });
        if (empty($activeChildren)) {
            $problems[] = "⚠️  Aucune sous-catégorie de HOME n'est active";
        }
    }
    
    if (empty($shopCategories)) {
        $problems[] = "⚠️  Les catégories ne sont pas associées à la boutique";
    }
    
    if (empty($problems)) {
        echo "✓ Aucun problème détecté avec la structure des catégories.\n";
        echo "  Le problème vient probablement du cache ou de la configuration du template.\n";
    } else {
        echo "PROBLÈMES DÉTECTÉS:\n\n";
        foreach ($problems as $i => $problem) {
            echo ($i + 1) . ". $problem\n";
        }
    }
    
    echo "\n";
    
    // 9. RECOMMANDATIONS
    echo "=================================================================\n";
    echo "RECOMMANDATIONS:\n";
    echo "=================================================================\n";
    
    if (empty($children)) {
        echo "➤ VOUS DEVEZ CRÉER DES CATÉGORIES!\n";
        echo "  1. Allez dans: Catalogue > Catégories\n";
        echo "  2. Créez de nouvelles catégories sous la catégorie '$homeCategory'\n";
        echo "  3. Activez-les et associez-les à votre boutique\n\n";
    }
    
    if (empty($blockParams)) {
        echo "➤ CONFIGUREZ LE MODULE:\n";
        echo "  1. Allez dans: Modules > Gestionnaire de modules\n";
        echo "  2. Recherchez 'Category tree links mod'\n";
        echo "  3. Cliquez sur 'Configurer'\n";
        echo "  4. Définissez Maximum depth = 4\n";
        echo "  5. Sauvegardez\n\n";
    }
    
    echo "➤ VIDEZ LE CACHE:\n";
    echo "  Paramètres avancés > Performances > Vider le cache\n\n";
    
} catch (PDOException $e) {
    echo "ERREUR DE CONNEXION: " . $e->getMessage() . "\n";
    exit(1);
}
