<?php
$host = getenv('ROBLOX_DB_HOST') ?: '127.0.0.1';
$name = getenv('ROBLOX_DB_NAME') ?: 'roblox2006';
$user = getenv('ROBLOX_DB_USER') ?: 'root';
$password = getenv('ROBLOX_DB_PASSWORD') !== false ? getenv('ROBLOX_DB_PASSWORD') : '';

try {
    $db = new PDO(
        'mysql:host=' . $host . ';dbname=' . $name . ';charset=utf8mb4',
        $user,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
} catch (PDOException $e) {
    error_log('ROBLOX database connection failed: ' . $e->getMessage());
    http_response_code(500);
    exit('The website database is not configured. Check the database settings and try again.');
}
?>