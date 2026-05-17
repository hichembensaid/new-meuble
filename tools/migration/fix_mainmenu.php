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

    $idModule = (int)$pdo->query("SELECT id_module FROM ps_module WHERE name='ps_mainmenu' LIMIT 1")->fetchColumn();
    if ($idModule <= 0) {
        throw new RuntimeException('Module ps_mainmenu introuvable.');
    }

    $idHook = (int)$pdo->query("SELECT id_hook FROM ps_hook WHERE name='displayTop' LIMIT 1")->fetchColumn();
    if ($idHook <= 0) {
        throw new RuntimeException('Hook displayTop introuvable.');
    }

    $idShop = (int)$pdo->query('SELECT id_shop FROM ps_shop ORDER BY id_shop LIMIT 1')->fetchColumn();
    if ($idShop <= 0) {
        throw new RuntimeException('Shop introuvable.');
    }

    $idShopGroup = (int)$pdo->prepare('SELECT id_shop_group FROM ps_shop WHERE id_shop = :id_shop LIMIT 1')
        ->execute(['id_shop' => $idShop]);
    $shopGroupStmt = $pdo->prepare('SELECT id_shop_group FROM ps_shop WHERE id_shop = :id_shop LIMIT 1');
    $shopGroupStmt->execute(['id_shop' => $idShop]);
    $idShopGroup = (int)$shopGroupStmt->fetchColumn();
    if ($idShopGroup <= 0) {
        throw new RuntimeException('Shop group introuvable.');
    }

    $existsStmt = $pdo->prepare(
        'SELECT COUNT(*) FROM ps_hook_module WHERE id_module = :id_module AND id_hook = :id_hook AND id_shop = :id_shop'
    );
    $existsStmt->execute([
        'id_module' => $idModule,
        'id_hook' => $idHook,
        'id_shop' => $idShop,
    ]);
    $alreadyHooked = (int)$existsStmt->fetchColumn() > 0;

    if (!$alreadyHooked) {
        $position = (int)$pdo->prepare('SELECT COALESCE(MAX(position), 0) + 1 FROM ps_hook_module WHERE id_hook = :id_hook AND id_shop = :id_shop')
            ->execute(['id_hook' => $idHook, 'id_shop' => $idShop]);

        $posStmt = $pdo->prepare('SELECT COALESCE(MAX(position), 0) + 1 FROM ps_hook_module WHERE id_hook = :id_hook AND id_shop = :id_shop');
        $posStmt->execute(['id_hook' => $idHook, 'id_shop' => $idShop]);
        $position = (int)$posStmt->fetchColumn();

        $insertHook = $pdo->prepare(
            'INSERT INTO ps_hook_module (id_module, id_shop, id_hook, position) VALUES (:id_module, :id_shop, :id_hook, :position)'
        );
        $insertHook->execute([
            'id_module' => $idModule,
            'id_shop' => $idShop,
            'id_hook' => $idHook,
            'position' => $position,
        ]);
    }

    $catRows = $pdo->query(
        "SELECT c.id_category
         FROM ps_category c
         WHERE c.id_parent = 2 AND c.active = 1
         ORDER BY c.position"
    )->fetchAll();

    if ($catRows === []) {
        throw new RuntimeException('Aucune catégorie active sous Accueil (id_parent=2).');
    }

    $menuItems = array_map(
        static fn(array $r): string => 'CAT' . (int)$r['id_category'],
        $catRows
    );
    $menuValue = implode(',', $menuItems);

    $pdo->prepare("DELETE FROM ps_configuration WHERE name IN ('MOD_BLOCKTOPMENU_ITEMS','MOD_BLOCKTOPMENU_SEARCH','PS_MAINMENU_MENU','PS_MAINMENU_SEARCH')")
        ->execute();

    $ins = $pdo->prepare(
        "INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
         VALUES (NULL, NULL, :name, :value, NOW(), NOW())"
    );

    $ins->execute(['name' => 'MOD_BLOCKTOPMENU_ITEMS', 'value' => $menuValue]);
    $ins->execute(['name' => 'MOD_BLOCKTOPMENU_SEARCH', 'value' => '0']);

    $insShop = $pdo->prepare(
        "INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
         VALUES (:id_shop_group, :id_shop, :name, :value, NOW(), NOW())"
    );

    $insShop->execute([
        'id_shop_group' => $idShopGroup,
        'id_shop' => $idShop,
        'name' => 'MOD_BLOCKTOPMENU_ITEMS',
        'value' => $menuValue,
    ]);
    $insShop->execute([
        'id_shop_group' => $idShopGroup,
        'id_shop' => $idShop,
        'name' => 'MOD_BLOCKTOPMENU_SEARCH',
        'value' => '0',
    ]);

    $pdo->commit();

    echo "ps_mainmenu hook/displayTop: " . ($alreadyHooked ? 'already hooked' : 'hook added') . PHP_EOL;
    echo "MOD_BLOCKTOPMENU_ITEMS set to: {$menuValue}" . PHP_EOL;
    echo "MOD_BLOCKTOPMENU_SEARCH set to 0" . PHP_EOL;
    exit(0);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    fwrite(STDERR, 'Fix failed: ' . $e->getMessage() . PHP_EOL);
    exit(1);
}
