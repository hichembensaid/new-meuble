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

function q(PDO $pdo, string $title, string $sql): void
{
    echo "\n=== {$title} ===\n";
    $rows = $pdo->query($sql)->fetchAll();
    if ($rows === []) {
        echo "(no rows)\n";
        return;
    }
    $headers = array_keys($rows[0]);
    echo implode(' | ', $headers) . "\n";
    foreach ($rows as $r) {
        $vals = [];
        foreach ($headers as $h) {
            $vals[] = (string)($r[$h] ?? 'NULL');
        }
        echo implode(' | ', $vals) . "\n";
    }
}

q($pdo, 'Shop URLs', "SELECT id_shop_url,id_shop,domain,domain_ssl,physical_uri,virtual_uri,main,active FROM ps_shop_url ORDER BY id_shop_url");

q($pdo, 'Home category (id 2)', "SELECT c.id_category,c.id_parent,c.active,cl.name FROM ps_category c LEFT JOIN ps_category_lang cl ON cl.id_category=c.id_category AND cl.id_lang=1 AND cl.id_shop=1 WHERE c.id_category=2");

q($pdo, 'Active products in Home category 2', "SELECT COUNT(*) AS cnt FROM ps_category_product cp JOIN ps_product_shop ps ON ps.id_product=cp.id_product AND ps.id_shop=1 WHERE cp.id_category=2 AND ps.active=1");

q($pdo, 'displayHome hooked modules', "SELECT hm.position,m.name,m.active FROM ps_hook h JOIN ps_hook_module hm ON hm.id_hook=h.id_hook JOIN ps_module m ON m.id_module=hm.id_module WHERE h.name='displayHome' ORDER BY hm.position");

q($pdo, 'displayTop hooked modules', "SELECT hm.position,m.name,m.active FROM ps_hook h JOIN ps_hook_module hm ON hm.id_hook=h.id_hook JOIN ps_module m ON m.id_module=hm.id_module WHERE h.name='displayTop' ORDER BY hm.position");

q($pdo, 'Configuration key quick check', "SELECT name,id_shop_group,id_shop,LEFT(COALESCE(value,'NULL'),120) AS val FROM ps_configuration WHERE name IN ('PS_REWRITING_SETTINGS','PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL','PS_SHOP_URI') OR name LIKE 'PS_ROUTE_%' ORDER BY name,id_shop_group,id_shop");
