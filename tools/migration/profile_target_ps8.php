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

$tables = [
    'ps_category',
    'ps_category_lang',
    'ps_category_product',
    'ps_product',
    'ps_product_lang',
    'ps_product_shop',
    'ps_specific_price',
    'ps_tax',
    'ps_tax_rule',
    'ps_tax_rules_group',
    'ps_meta_lang',
];

foreach ($tables as $table) {
    $count = (int) $pdo->query("SELECT COUNT(*) FROM `{$table}`")->fetchColumn();
    $pk = $pdo->query("SHOW KEYS FROM `{$table}` WHERE Key_name = 'PRIMARY'")->fetchAll();
    $firstPk = $pk[0]['Column_name'] ?? null;
    $maxPk = null;
    if ($firstPk !== null) {
        $maxPk = $pdo->query("SELECT MAX(`{$firstPk}`) FROM `{$table}`")->fetchColumn();
    }

    echo sprintf("%s | rows=%d | pk=%s | max_pk=%s\n", $table, $count, $firstPk ?? '-', (string)($maxPk ?? 'NULL'));
}

echo "\n-- Langues --\n";
foreach ($pdo->query("SELECT id_lang, name, iso_code, language_code, locale, active FROM ps_lang ORDER BY id_lang") as $row) {
    echo implode(' | ', [
        $row['id_lang'],
        $row['name'],
        $row['iso_code'],
        $row['language_code'],
        $row['locale'],
        $row['active'],
    ]) . "\n";
}

echo "\n-- Categories de base --\n";
$sql = "SELECT c.id_category, c.id_parent, c.is_root_category, cl.name, cl.link_rewrite
        FROM ps_category c
        LEFT JOIN ps_category_lang cl ON cl.id_category = c.id_category AND cl.id_lang = 1 AND cl.id_shop = 1
        WHERE c.id_category IN (1,2)
        ORDER BY c.id_category";
foreach ($pdo->query($sql) as $row) {
    echo implode(' | ', [
        $row['id_category'],
        $row['id_parent'],
        $row['is_root_category'],
        $row['name'],
        $row['link_rewrite'],
    ]) . "\n";
}
