<?php

declare(strict_types=1);

$url = $argv[1] ?? 'http://meuble2.localhost/53-meuble-de-jardain';

$ctx = stream_context_create([
    'http' => [
        'ignore_errors' => true,
        'timeout' => 20,
    ],
]);

$body = @file_get_contents($url, false, $ctx);
$status = $http_response_header[0] ?? 'no-status';

echo "URL: {$url}\n";
echo "HTTP: {$status}\n";
echo 'Body length: ' . strlen((string)$body) . "\n\n";

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

preg_match('~/(\d+)-~', $url, $m);
$idCategory = isset($m[1]) ? (int)$m[1] : 53;

echo "Category id inferred: {$idCategory}\n\n";

$queries = [
    'category' => "SELECT c.id_category,c.id_parent,c.active,c.level_depth,cl.name,cl.link_rewrite,cl.meta_title FROM ps_category c JOIN ps_category_lang cl ON cl.id_category=c.id_category AND cl.id_lang=1 AND cl.id_shop=1 WHERE c.id_category={$idCategory}",
    'category_shop' => "SELECT id_category,id_shop,position FROM ps_category_shop WHERE id_category={$idCategory}",
    'category_group' => "SELECT id_category,id_group FROM ps_category_group WHERE id_category={$idCategory} ORDER BY id_group",
    'products_count' => "SELECT COUNT(*) AS cnt FROM ps_category_product WHERE id_category={$idCategory}",
    'sample_products' => "SELECT cp.id_product,ps.active,pl.name FROM ps_category_product cp JOIN ps_product_shop ps ON ps.id_product=cp.id_product AND ps.id_shop=1 LEFT JOIN ps_product_lang pl ON pl.id_product=cp.id_product AND pl.id_lang=1 AND pl.id_shop=1 WHERE cp.id_category={$idCategory} LIMIT 10",
];

foreach ($queries as $label => $sql) {
    echo "=== {$label} ===\n";
    $rows = $pdo->query($sql)->fetchAll();
    if ($rows === []) {
        echo "(no rows)\n\n";
        continue;
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
    echo "\n";
}

if ($body !== false && strlen($body) > 0) {
    echo "=== body snippet ===\n";
    echo substr($body, 0, 2000) . "\n";
}
