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

$modules = [
    'ets_mailchimpsync',
    'ets_megamenu',
    'ets_multilayerslider',
    'ets_purchasetogether',
    'ets_reviewticker',
    'pleasewait',
    'ybc_blog_free',
    'ybc_manufacturer',
    'ybc_newsletter',
    'ybc_productimagehover',
    'ybc_specificprices',
    'ybc_themeconfig',
    'ybc_widget',
];

$in = implode(',', array_fill(0, count($modules), '?'));

$pdo->beginTransaction();

$beforeStmt = $pdo->prepare("SELECT name, active FROM ps_module WHERE name IN ($in) ORDER BY name");
$beforeStmt->execute($modules);
$before = $beforeStmt->fetchAll();

$upd = $pdo->prepare("UPDATE ps_module SET active = 0 WHERE name IN ($in)");
$upd->execute($modules);

$afterStmt = $pdo->prepare("SELECT name, active FROM ps_module WHERE name IN ($in) ORDER BY name");
$afterStmt->execute($modules);
$after = $afterStmt->fetchAll();

$pdo->commit();

echo "Before:\n";
foreach ($before as $row) {
    echo $row['name'] . ' => ' . $row['active'] . "\n";
}

echo "\nAfter:\n";
foreach ($after as $row) {
    echo $row['name'] . ' => ' . $row['active'] . "\n";
}
