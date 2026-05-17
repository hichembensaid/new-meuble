<?php

declare(strict_types=1);

$root = dirname(__DIR__, 2);
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

function printRows(array $rows, int $max = 8): void
{
    if ($rows === []) {
        echo "   (no rows)\n";
        return;
    }

    $headers = array_keys($rows[0]);
    echo '   ' . implode(' | ', $headers) . "\n";

    $i = 0;
    foreach ($rows as $row) {
        if ($i++ >= $max) {
            echo "   ...\n";
            break;
        }
        $vals = [];
        foreach ($headers as $h) {
            $vals[] = (string)($row[$h] ?? 'NULL');
        }
        echo '   ' . implode(' | ', $vals) . "\n";
    }
}

function splitSqlStatements(string $sql): array
{
    $statements = [];
    $buffer = '';
    $len = strlen($sql);

    $inSingle = false;
    $inDouble = false;
    $inBacktick = false;
    $inLineComment = false;
    $inBlockComment = false;

    for ($i = 0; $i < $len; $i++) {
        $ch = $sql[$i];
        $next = $i + 1 < $len ? $sql[$i + 1] : '';

        if ($inLineComment) {
            if ($ch === "\n") {
                $inLineComment = false;
                $buffer .= $ch;
            }
            continue;
        }

        if ($inBlockComment) {
            if ($ch === '*' && $next === '/') {
                $inBlockComment = false;
                $i++;
            }
            continue;
        }

        if (!$inSingle && !$inDouble && !$inBacktick) {
            if ($ch === '-' && $next === '-') {
                $inLineComment = true;
                $i++;
                continue;
            }
            if ($ch === '#') {
                $inLineComment = true;
                continue;
            }
            if ($ch === '/' && $next === '*') {
                $inBlockComment = true;
                $i++;
                continue;
            }
        }

        if ($ch === "'" && !$inDouble && !$inBacktick) {
            $escaped = $i > 0 && $sql[$i - 1] === '\\';
            if (!$escaped) {
                $inSingle = !$inSingle;
            }
            $buffer .= $ch;
            continue;
        }

        if ($ch === '"' && !$inSingle && !$inBacktick) {
            $escaped = $i > 0 && $sql[$i - 1] === '\\';
            if (!$escaped) {
                $inDouble = !$inDouble;
            }
            $buffer .= $ch;
            continue;
        }

        if ($ch === '`' && !$inSingle && !$inDouble) {
            $inBacktick = !$inBacktick;
            $buffer .= $ch;
            continue;
        }

        if ($ch === ';' && !$inSingle && !$inDouble && !$inBacktick) {
            $stmt = trim($buffer);
            if ($stmt !== '') {
                $statements[] = $stmt;
            }
            $buffer = '';
            continue;
        }

        $buffer .= $ch;
    }

    $tail = trim($buffer);
    if ($tail !== '') {
        $statements[] = $tail;
    }

    return $statements;
}

function runSqlStatements(PDO $pdo, array $statements, string $label, bool $showSelectRows = false): void
{
    echo "\n== Executing {$label} (" . count($statements) . " statements) ==\n";

    foreach ($statements as $idx => $stmt) {
        $n = $idx + 1;
        $lead = strtolower(ltrim($stmt));

        try {
            if (preg_match('/^(select|show|describe|explain)\b/', $lead) === 1) {
                $rows = $pdo->query($stmt)->fetchAll();
                echo sprintf("[%03d] SELECT OK (%d rows)\n", $n, count($rows));
                if ($showSelectRows) {
                    printRows($rows);
                }
            } else {
                $affected = $pdo->exec($stmt);
                $affectedText = $affected === false ? 'n/a' : (string)$affected;
                echo sprintf("[%03d] OK (affected: %s)\n", $n, $affectedText);
            }
        } catch (Throwable $e) {
            echo sprintf("[%03d] ERROR: %s\n", $n, $e->getMessage());
            echo "Statement excerpt:\n";
            echo substr($stmt, 0, 600) . "\n";
            throw $e;
        }
    }
}

function runSqlFile(PDO $pdo, string $filePath, string $sourceDb, bool $showSelectRows = false): void
{
    if (!is_file($filePath)) {
        throw new RuntimeException("SQL file not found: {$filePath}");
    }

    $sql = file_get_contents($filePath);
    if ($sql === false) {
        throw new RuntimeException("Cannot read SQL file: {$filePath}");
    }

    if ($sourceDb !== 'legacy_ps16') {
        $sql = str_replace('legacy_ps16.', $sourceDb . '.', $sql);
    }

    $statements = splitSqlStatements($sql);

    runSqlStatements($pdo, $statements, basename($filePath), $showSelectRows);
}

try {
    $sourceDb = 'legacy_ps16';
    foreach ($argv as $arg) {
        if (strpos($arg, '--source-db=') === 0) {
            $sourceDb = trim(substr($arg, strlen('--source-db=')));
            break;
        }
    }

    $dbExists = static function (PDO $pdo, string $dbName): bool {
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = :db");
        $stmt->execute(['db' => $dbName]);
        return (int)$stmt->fetchColumn() > 0;
    };

    if (!$dbExists($pdo, $sourceDb)) {
        if ($sourceDb === 'legacy_ps16' && $dbExists($pdo, 'old_db_meuble')) {
            $sourceDb = 'old_db_meuble';
            echo "Source DB auto-detected: old_db_meuble\n";
        } else {
            throw new RuntimeException("La base source '{$sourceDb}' n'existe pas.");
        }
    }

    $legacyProducts = (int)$pdo->query("SELECT COUNT(*) FROM `{$sourceDb}`.ps_product")->fetchColumn();
    echo "Source DB: {$sourceDb}\n";
    echo "Legacy products count: {$legacyProducts}\n";
    if ($legacyProducts === 0) {
        throw new RuntimeException("{$sourceDb}.ps_product est vide. Migration arrêtée.");
    }

    $alreadyLegacyTaxGroups = (int)$pdo->query("SELECT COUNT(*) FROM ps_tax_rules_group WHERE name LIKE '[LEGACY16] %'")->fetchColumn();
    if ($alreadyLegacyTaxGroups > 0) {
        echo "Attention: migration legacy semble déjà appliquée ({$alreadyLegacyTaxGroups} groupes taxes [LEGACY16]).\n";
        echo "Arrêt préventif pour éviter des doublons taxes.\n";
        exit(2);
    }

    runSqlFile($pdo, __DIR__ . '/sql/01_migration_ps16_to_ps8.sql', $sourceDb);
    runSqlFile($pdo, __DIR__ . '/sql/02_validation_queries.sql', $sourceDb, true);

    echo "\nMigration SQL terminée avec succès.\n";
    echo "Il reste à copier manuellement les fichiers images legacy vers img/p.\n";
    exit(0);
} catch (Throwable $e) {
    fwrite(STDERR, "\nMigration interrompue: " . $e->getMessage() . "\n");
    exit(1);
}
