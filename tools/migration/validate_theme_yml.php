<?php

declare(strict_types=1);

require __DIR__ . '/../../vendor/autoload.php';

use Symfony\Component\Yaml\Yaml;

$file = __DIR__ . '/../../themes/amazonas/config/theme.yml';

try {
    Yaml::parseFile($file);
    echo "yaml_ok\n";
    exit(0);
} catch (Throwable $e) {
    echo 'yaml_err: ' . $e->getMessage() . "\n";
    exit(1);
}
