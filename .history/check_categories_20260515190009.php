<?php
require_once 'config/config.inc.php';

$categories = Category::getCategories(1, true, false);

echo "<h2>Structure des catégories</h2>";
echo "<pre>";

function displayCategories($cats, $depth = 0) {
    foreach ($cats as $cat) {
        $indent = str_repeat('  ', $depth);
        $hasChildren = isset($cat['children']) && !empty($cat['children']);
        echo $indent . "- ID: " . $cat['id_category'] . " | " . $cat['name'];
        echo " | Children: " . ($hasChildren ? count($cat['children']) : '0') . "\n";
        
        if ($hasChildren) {
            displayCategories($cat['children'], $depth + 1);
        }
    }
}

displayCategories($categories);

echo "</pre>";

// Vérifier aussi le module
echo "<h2>Données du module ps_categorytree_mod</h2>";
echo "<pre>";
$sql = "SELECT * FROM " . _DB_PREFIX_ . "category WHERE active = 1 AND id_parent IN (2) ORDER BY position";
$result = Db::getInstance()->executeS($sql);
print_r($result);
echo "</pre>";
