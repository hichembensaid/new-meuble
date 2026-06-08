<?php

declare(strict_types=1);

$urls = [
    'http://https://www.lart-du-meuble.tn/',
    'http://https://www.lart-du-meuble.tn/53-meuble-de-jardain',
];

$iterations = 8;
$ctx = stream_context_create([
    'http' => [
        'ignore_errors' => true,
        'timeout' => 20,
    ],
]);

foreach ($urls as $url) {
    echo "\n=== {$url} ===\n";
    $ok = 0;
    $ko = 0;

    for ($i = 1; $i <= $iterations; $i++) {
        $body = @file_get_contents($url, false, $ctx);
        $status = $http_response_header[0] ?? 'no-status';
        $len = strlen((string)$body);
        echo sprintf("%02d) %s | len=%d\n", $i, $status, $len);
        if (str_contains($status, '200')) {
            $ok++;
        } else {
            $ko++;
        }
    }

    echo "Result: OK={$ok}, KO={$ko}\n";
}
