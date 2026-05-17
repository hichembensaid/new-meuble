<?php
require 'init.php';
$db = Db::getInstance();

$res = $db->executeS('
    SELECT h.name, hm.id_module 
    FROM ps_hook h 
    LEFT JOIN ps_hook_module hm ON h.id_hook = hm.id_hook 
    LEFT JOIN ps_module m ON hm.id_module = m.id_module AND m.name = "quickorder" 
    WHERE h.name IN ("displayProductActions", "displayProductListFunctionalButtons", "displayFooter", "displayProductListReviews")
    ORDER BY h.name
');

foreach ($res as $r) {
    echo $r['name'] . ' => module_id=' . ($r['id_module'] ?: 'NON ENREGISTRÉ') . "\n";
}

// Aussi enregistrer displayProductActions maintenant si besoin
$module = Module::getInstanceByName('quickorder');
if ($module) {
    echo "\nModule quickorder trouvé. Enregistrement du hook displayProductActions...\n";
    $result = $module->registerHook('displayProductActions');
    echo $result ? "OK - Hook enregistré !\n" : "ERREUR lors de l'enregistrement\n";
} else {
    echo "Module quickorder non trouvé!\n";
}
