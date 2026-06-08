<?php

declare(strict_types=1);

$ctx = stream_context_create([
    'http' => [
        'ignore_errors' => true,
        'timeout' => 20,
    ],
]);

$url = 'http://https://www.lart-du-meuble.tn/';
$html = @file_get_contents($url, false, $ctx);

$status = $http_response_header[0] ?? 'no-status';
echo "Status: {$status}\n\n";

if ($html === false) {
    echo "No body returned.\n";
    exit(1);
}

echo substr($html, 0, 4000) . "\n";
