<?php

declare(strict_types=1);

$root = dirname(__DIR__, 2);
$dumpPath = $root . '/old_db_prestashop 1_6_1_24.sql';

if (!is_file($dumpPath)) {
    fwrite(STDERR, "Dump introuvable: {$dumpPath}\n");
    exit(1);
}

$parameters = require $root . '/app/config/parameters.php';
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
    'ps_category_shop',
    'ps_category_product',
    'ps_product',
    'ps_product_lang',
    'ps_product_shop',
    'ps_specific_price',
    'ps_tax',
    'ps_tax_lang',
    'ps_tax_rule',
    'ps_tax_rules_group',
    'ps_tax_rules_group_shop',
    'ps_meta',
    'ps_meta_lang',
    'ps_configuration',
    'ps_shop_url',
    'ps_lang',
];

$content = file_get_contents($dumpPath);
if ($content === false) {
    fwrite(STDERR, "Impossible de lire le dump.\n");
    exit(1);
}

$legacy = [];
foreach ($tables as $table) {
    $pattern = '/CREATE TABLE `'.preg_quote($table, '/').'` \((.*?)\) ENGINE=/si';
    if (!preg_match($pattern, $content, $match)) {
        $legacy[$table] = null;
        continue;
    }

    $columns = [];
    $lines = preg_split('/\R/', $match[1]) ?: [];
    foreach ($lines as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] !== '`') {
            continue;
        }
        if (preg_match('/^`([^`]+)`\s+([^,]+),?$/', $line, $m)) {
            $columns[$m[1]] = trim($m[2]);
        }
    }

    $legacy[$table] = $columns;
}

$target = [];
foreach ($tables as $table) {
    try {
        $stmt = $pdo->query("SHOW COLUMNS FROM `{$table}`");
        $columns = [];
        foreach ($stmt as $row) {
            $columns[$row['Field']] = strtolower($row['Type']) . ' ' . ($row['Null'] === 'NO' ? 'NOT NULL' : 'NULL');
        }
        $target[$table] = $columns;
    } catch (Throwable $e) {
        $target[$table] = null;
    }
}

foreach ($tables as $table) {
    echo "\n=== {$table} ===\n";

    if ($legacy[$table] === null) {
        echo "- Legacy: table introuvable dans le dump\n";
        continue;
    }

    if ($target[$table] === null) {
        echo "- Target: table introuvable dans PS8\n";
        continue;
    }

    $legacyCols = array_keys($legacy[$table]);
    $targetCols = array_keys($target[$table]);

    $missingInTarget = array_values(array_diff($legacyCols, $targetCols));
    $newInTarget = array_values(array_diff($targetCols, $legacyCols));

    echo '- Colonnes legacy: '.count($legacyCols)."\n";
    echo '- Colonnes target: '.count($targetCols)."\n";

    if ($missingInTarget) {
        echo '- Absentes en PS8: '.implode(', ', $missingInTarget)."\n";
    } else {
        echo "- Absentes en PS8: aucune\n";
    }

    if ($newInTarget) {
        echo '- Nouvelles en PS8: '.implode(', ', $newInTarget)."\n";
    } else {
        echo "- Nouvelles en PS8: aucune\n";
    }
}
