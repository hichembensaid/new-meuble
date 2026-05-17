<?php

declare(strict_types=1);

$parameters = require __DIR__ . '/../../app/config/parameters.php';
$db = $parameters['parameters'];

$pdo = new PDO(
    sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        $db['database_host'],
        $db['database_port'],
        $db['database_name']
    ),
    $db['database_user'],
    $db['database_password'],
    [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]
);

function printRows(PDO $pdo, string $title, string $sql): void
{
    echo "\n=== {$title} ===\n";
    $rows = $pdo->query($sql)->fetchAll();
    if ($rows === []) {
        echo "(no rows)\n";
        return;
    }

    $headers = array_keys($rows[0]);
    echo implode(' | ', $headers) . "\n";

    foreach ($rows as $row) {
        $vals = [];
        foreach ($headers as $h) {
            $vals[] = (string)($row[$h] ?? 'NULL');
        }
        echo implode(' | ', $vals) . "\n";
    }
}

printRows(
    $pdo,
    'Menu-related configuration',
    "SELECT name,id_shop_group,id_shop,LEFT(COALESCE(value,'NULL'),400) AS val
     FROM ps_configuration
     WHERE name LIKE 'PS_MAINMENU%'
        OR name LIKE 'BLOCKTOPMENU%'
          OR name LIKE 'MOD_BLOCKTOPMENU%'
        OR name LIKE 'PS_%TOPMENU%'
     ORDER BY name, id_shop_group, id_shop"
);

printRows(
    $pdo,
    'Categories level 1 active',
    "SELECT c.id_category, cl.name, c.active
     FROM ps_category c
     JOIN ps_category_lang cl ON cl.id_category = c.id_category AND cl.id_lang = 1 AND cl.id_shop = 1
     WHERE c.id_parent = 2
     ORDER BY c.position"
);

printRows(
    $pdo,
    'Category-group permissions for top categories',
    "SELECT c.id_category, cl.name, COUNT(cg.id_group) AS groups_count
    FROM ps_category c
    JOIN ps_category_lang cl ON cl.id_category = c.id_category AND cl.id_lang = 1 AND cl.id_shop = 1
    LEFT JOIN ps_category_group cg ON cg.id_category = c.id_category
    WHERE c.id_parent = 2
    GROUP BY c.id_category, cl.name
    ORDER BY c.position"
);

printRows(
    $pdo,
    'Category-shop links for top categories',
    "SELECT c.id_category, cl.name, COUNT(cs.id_shop) AS shops_count
    FROM ps_category c
    JOIN ps_category_lang cl ON cl.id_category = c.id_category AND cl.id_lang = 1 AND cl.id_shop = 1
    LEFT JOIN ps_category_shop cs ON cs.id_category = c.id_category
    WHERE c.id_parent = 2
    GROUP BY c.id_category, cl.name
    ORDER BY c.position"
);

printRows(
    $pdo,
    'ps_mainmenu module status',
    "SELECT id_module,name,active FROM ps_module WHERE name='ps_mainmenu'"
);

printRows(
    $pdo,
    'ps_mainmenu on displayTop',
    "SELECT hm.id_hook, hm.id_module, hm.position
     FROM ps_hook h
     JOIN ps_hook_module hm ON hm.id_hook = h.id_hook
     JOIN ps_module m ON m.id_module = hm.id_module
     WHERE h.name='displayTop' AND m.name='ps_mainmenu'"
);

printRows(
    $pdo,
    'All hooks for ps_mainmenu',
    "SELECT h.name AS hook_name, hm.id_shop, hm.position
    FROM ps_hook h
    JOIN ps_hook_module hm ON hm.id_hook = h.id_hook
    JOIN ps_module m ON m.id_module = hm.id_module
    WHERE m.name='ps_mainmenu'
    ORDER BY h.name, hm.id_shop"
);
