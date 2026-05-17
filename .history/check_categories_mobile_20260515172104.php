<?php
/**
 * Script pour vérifier que les catégories sont bien accessibles
 */

require_once(dirname(__FILE__).'/config/config.inc.php');

echo "<h2>Vérification des catégories pour le menu mobile</h2>";

// Vérifier si le module est actif
$module = Module::getInstanceByName('ps_categorytree_mod');
if (!$module || !$module->active) {
    echo "<p style='color: red;'>❌ Le module ps_categorytree_mod n'est pas actif!</p>";
    exit;
}

echo "<p style='color: green;'>✅ Module ps_categorytree_mod actif</p>";

// Obtenir les catégories
$categories = $module->getCategories();
echo "<h3>Catégories trouvées:</h3>";
echo "<pre>";
print_r($categories);
echo "</pre>";

// Vérifier le rendu HTML
echo "<h3>Test du template:</h3>";
$context = Context::getContext();
$context->smarty->assign('categories_custom', $categories);

try {
    $html = $context->smarty->fetch('module:ps_categorytree_mod/views/templates/hook/customcategories.tpl');
    echo "<p style='color: green;'>✅ Template compilé avec succès</p>";
    echo "<h4>HTML généré (bloc mobile):</h4>";
    
    // Extraire juste le bloc mobile
    if (preg_match('/<div class="block-categories-custom-mobile[^>]*>(.*?)<\/div>\s*$/s', $html, $matches)) {
        echo "<textarea style='width: 100%; height: 300px;'>";
        echo htmlspecialchars($matches[0]);
        echo "</textarea>";
    } else {
        echo "<p style='color: orange;'>⚠️ Bloc mobile non trouvé dans le HTML</p>";
        echo "<textarea style='width: 100%; height: 300px;'>";
        echo htmlspecialchars($html);
        echo "</textarea>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Erreur de compilation du template: " . $e->getMessage() . "</p>";
}
