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

$sql = "SELECT m.name, m.active, COUNT(hm.id_module) AS hook_count
          FROM ps_module m
          LEFT JOIN ps_hook_module hm ON hm.id_module = m.id_module
          WHERE m.name REGEXP '^(ybc_|ets_)'
              OR m.name = 'pleasewait'
          GROUP BY m.id_module, m.name, m.active
          ORDER BY m.active DESC, m.name";

$rows = $pdo->query($sql)->fetchAll();

if ($rows === []) {
    echo "No risky modules found.\n";
    exit(0);
}

echo "name | active | hooks\n";
foreach ($rows as $r) {
    echo sprintf("%s | %s | %s\n", $r['name'], $r['active'], $r['hook_count']);
}
