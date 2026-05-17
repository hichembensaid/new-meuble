<?php

declare(strict_types=1);

$ctx = stream_context_create([
    'http' => [
        'ignore_errors' => true,
        'timeout' => 20,
    ],
]);

$url = 'http://meuble2.localhost/';
$html = @file_get_contents($url, false, $ctx);
$status = $http_response_header[0] ?? 'no-status';

echo "Status: {$status}\n";
if ($html === false) {
    echo "No body\n";
    exit(1);
}

echo 'Length: ' . strlen($html) . "\n";

$patterns = ['Exception', 'Fatal', 'Error', 'Whoops', 'Stack trace', 'Twig', 'Smarty', 'Warning'];
foreach ($patterns as $p) {
    $pos = stripos($html, $p);
    if ($pos !== false) {
        $start = max(0, $pos - 300);
        $chunk = substr($html, $start, 1200);
        echo "\n--- match: {$p} at {$pos} ---\n";
        echo $chunk . "\n";
    }
}

echo "\n--- tail ---\n";
echo substr($html, max(0, strlen($html) - 2500)) . "\n";
