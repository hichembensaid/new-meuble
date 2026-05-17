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

$tables = ['ps_image', 'ps_image_lang', 'ps_image_shop', 'ps_product_shop'];

foreach ($tables as $table) {
    echo "=== {$table} ===\n";

    $stmt = $pdo->query("SHOW COLUMNS FROM `{$table}`");
    foreach ($stmt as $row) {
        printf(
            "%s|%s|%s|%s|%s\n",
            $row['Field'],
            $row['Type'],
            $row['Null'],
            $row['Key'],
            (string)($row['Default'] ?? 'NULL')
        );
    }

    echo "\n";
}
