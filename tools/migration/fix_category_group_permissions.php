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

try {
    $pdo->beginTransaction();

    $groups = $pdo->query('SELECT id_group FROM ps_group WHERE id_group IN (1,2,3) ORDER BY id_group')->fetchAll();
    if ($groups === []) {
        throw new RuntimeException('Groupes clients 1/2/3 introuvables.');
    }

    $categories = $pdo->query('SELECT id_category FROM ps_category WHERE id_category > 2')->fetchAll();
    if ($categories === []) {
        throw new RuntimeException('Aucune catégorie à traiter.');
    }

    $check = $pdo->prepare('SELECT COUNT(*) FROM ps_category_group WHERE id_category = :id_category AND id_group = :id_group');
    $insert = $pdo->prepare('INSERT INTO ps_category_group (id_category, id_group) VALUES (:id_category, :id_group)');

    $inserted = 0;
    foreach ($categories as $cat) {
        $idCategory = (int)$cat['id_category'];
        foreach ($groups as $group) {
            $idGroup = (int)$group['id_group'];
            $check->execute(['id_category' => $idCategory, 'id_group' => $idGroup]);
            if ((int)$check->fetchColumn() === 0) {
                $insert->execute(['id_category' => $idCategory, 'id_group' => $idGroup]);
                $inserted++;
            }
        }
    }

    $pdo->commit();

    echo "Category-group permissions fixed. Inserted rows: {$inserted}" . PHP_EOL;
    exit(0);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    fwrite(STDERR, 'Fix failed: ' . $e->getMessage() . PHP_EOL);
    exit(1);
}
