<?php
require_once dirname(__FILE__) . '/../../config/config.inc.php';

// Vérifier le hook customcategories
$sql = "SELECT hm.id_hook, h.name as hook_name, m.name as module_name, hm.position
        FROM " . _DB_PREFIX_ . "hook_module hm
        INNER JOIN " . _DB_PREFIX_ . "hook h ON h.id_hook = hm.id_hook
        INNER JOIN " . _DB_PREFIX_ . "module m ON m.id_module = hm.id_module
        WHERE h.name = 'customcategories'";

echo "=== Hook customcategories actuel ===\n";
$results = Db::getInstance()->executeS($sql);
if ($results) {
    foreach ($results as $row) {
        echo "Hook: {$row['hook_name']}, Module: {$row['module_name']}, Position: {$row['position']}\n";
    }
} else {
    echo "Aucun module connecté à customcategories\n";
}

// Obtenir les IDs nécessaires
$id_hook = Db::getInstance()->getValue("SELECT id_hook FROM " . _DB_PREFIX_ . "hook WHERE name = 'customcategories'");
$id_module_old = Db::getInstance()->getValue("SELECT id_module FROM " . _DB_PREFIX_ . "module WHERE name = 'ps_categorytree_mod'");
$id_module_new = Db::getInstance()->getValue("SELECT id_module FROM " . _DB_PREFIX_ . "module WHERE name = 'ps_categorytree'");

echo "\n=== IDs ===\n";
echo "Hook customcategories: " . ($id_hook ?: 'NOT FOUND') . "\n";
echo "Module ps_categorytree_mod: " . ($id_module_old ?: 'NOT FOUND') . "\n";
echo "Module ps_categorytree: " . ($id_module_new ?: 'NOT FOUND') . "\n";

if ($id_hook && $id_module_new) {
    echo "\n=== Connexion ps_categorytree au hook customcategories ===\n";
    
    // Supprimer l'ancienne connexion si elle existe
    if ($id_module_old) {
        Db::getInstance()->delete('hook_module', "id_hook = $id_hook AND id_module = $id_module_old");
        echo "✓ Ancienne connexion supprimée\n";
    }
    
    // Ajouter la nouvelle connexion
    $result = Db::getInstance()->insert('hook_module', [
        'id_module' => $id_module_new,
        'id_hook' => $id_hook,
        'position' => 1
    ]);
    
    if ($result) {
        echo "✓ ps_categorytree connecté au hook customcategories\n";
    }
} else {
    echo "\n⚠ Impossible de connecter le module (hook ou module manquant)\n";
}
