<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Menu Mobile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .info { background: #e8f4f8; padding: 15px; margin: 10px 0; border-left: 4px solid #0066cc; }
        .error { background: #ffeaea; padding: 15px; margin: 10px 0; border-left: 4px solid #cc0000; }
        .success { background: #e8f8e8; padding: 15px; margin: 10px 0; border-left: 4px solid #00cc00; }
        pre { background: #f5f5f5; padding: 10px; overflow-x: auto; }
        code { background: #f5f5f5; padding: 2px 5px; }
    </style>
</head>
<body>
    <h1>Test du Menu Mobile des Catégories</h1>

<?php
require_once(dirname(__FILE__).'/config/config.inc.php');

echo "<div class='info'><strong>Étape 1:</strong> Vérification du module</div>";

$module = Module::getInstanceByName('ps_categorytree_mod');
if (!$module || !$module->active) {
    echo "<div class='error'>❌ Le module ps_categorytree_mod n'est pas actif!</div>";
    exit;
}

echo "<div class='success'>✅ Module ps_categorytree_mod actif</div>";

echo "<div class='info'><strong>Étape 2:</strong> Recherche du hook customcategories</div>";

// Vérifier si le hook existe
$hooks = Hook::getHooks();
$customcategoriesHook = null;
foreach ($hooks as $hook) {
    if ($hook['name'] === 'customcategories') {
        $customcategoriesHook = $hook;
        break;
    }
}

if ($customcategoriesHook) {
    echo "<div class='success'>✅ Hook 'customcategories' trouvé (ID: {$customcategoriesHook['id']})</div>";
} else {
    echo "<div class='error'>❌ Hook 'customcategories' non trouvé!</div>";
}

// Vérifier si le module est accroché au hook
$sql = 'SELECT * FROM '._DB_PREFIX_.'hook_module 
        WHERE id_module = '.(int)$module->id.' 
        AND id_hook IN (SELECT id_hook FROM '._DB_PREFIX_.'hook WHERE name = "customcategories")';
$hookModule = Db::getInstance()->getRow($sql);

if ($hookModule) {
    echo "<div class='success'>✅ Module accroché au hook customcategories</div>";
} else {
    echo "<div class='error'>❌ Module NON accroché au hook customcategories!</div>";
}

echo "<div class='info'><strong>Étape 3:</strong> Exécution du hook</div>";

try {
    $context = Context::getContext();
    $result = Hook::exec('customcategories');
    
    if (empty($result)) {
        echo "<div class='error'>❌ Le hook customcategories retourne du contenu vide!</div>";
    } else {
        echo "<div class='success'>✅ Le hook customcategories retourne du contenu (".strlen($result)." caractères)</div>";
        
        // Chercher le bloc mobile
        if (strpos($result, 'mobile-categories-block') !== false) {
            echo "<div class='success'>✅ Bloc 'mobile-categories-block' présent dans le résultat</div>";
            
            // Extraire et afficher le bloc mobile
            if (preg_match('/<div[^>]*id="mobile-categories-block"[^>]*>.*?<\/div>\s*$/s', $result, $matches)) {
                echo "<h3>HTML du bloc mobile:</h3>";
                echo "<pre>".htmlspecialchars($matches[0])."</pre>";
                
                // Compter les catégories
                $catCount = substr_count($matches[0], 'category-top-menu-list');
                echo "<div class='info'>Nombre d'éléments 'category-top-menu-list' trouvés: $catCount</div>";
            }
        } else {
            echo "<div class='error'>❌ Bloc 'mobile-categories-block' NON trouvé dans le résultat</div>";
        }
        
        echo "<h3>HTML complet retourné par le hook:</h3>";
        echo "<textarea style='width: 100%; height: 400px;'>".htmlspecialchars($result)."</textarea>";
    }
} catch (Exception $e) {
    echo "<div class='error'>❌ Erreur lors de l'exécution du hook: " . $e->getMessage() . "</div>";
}

echo "<div class='info'><strong>Étape 4:</strong> Test du template directement</div>";

// Simuler les données du module
$smarty = $context->smarty;

// Récupérer les catégories via reflection (car la méthode est privée)
$reflection = new ReflectionClass($module);
$method = $reflection->getMethod('getCategories');
$method->setAccessible(true);
$categories = $method->invoke($module);

echo "<div class='info'>Nombre de catégories racine: ".count($categories['children'])."</div>";

$smarty->assign('categories_custom', $categories);

try {
    $html = $smarty->fetch('module:ps_categorytree_mod/views/templates/hook/customcategories.tpl');
    echo "<div class='success'>✅ Template compilé avec succès</div>";
    
    echo "<h3>HTML généré par le template:</h3>";
    echo "<textarea style='width: 100%; height: 400px;'>".htmlspecialchars($html)."</textarea>";
    
    if (strpos($html, 'mobile-categories-block') !== false) {
        echo "<div class='success'>✅ Le template génère bien le bloc mobile</div>";
    } else {
        echo "<div class='error'>❌ Le template ne génère PAS le bloc mobile</div>";
    }
    
} catch (Exception $e) {
    echo "<div class='error'>❌ Erreur de compilation: " . $e->getMessage() . "</div>";
}

?>

<h2>Actions recommandées:</h2>
<ul>
    <li>Videz le cache: <code>rm -rf var/cache/dev/smarty/compile/*</code></li>
    <li>Vérifiez que le fichier <code>modules/ps_categorytree_mod/views/templates/hook/customcategories.tpl</code> existe</li>
    <li>Vérifiez que le module est bien accroché au hook dans le back-office: Design > Positions > customcategories</li>
</ul>

</body>
</html>
