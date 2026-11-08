<?php
require_once __DIR__ . '/cfg/includes.php';
require_once __DIR__ . '/cfg/functions.php';
$term = trim($_GET['q'] ?? '');
if (strlen($term) > 30) $term = substr($term, 0, 30);
if ($term !== '') {
    $query = $db->prepare('SELECT id, name, created_at FROM users WHERE banned = 0 AND name LIKE :term ORDER BY name ASC LIMIT 50');
    $query->execute(['term' => '%' . $term . '%']);
} else {
    $query = $db->query('SELECT id, name, created_at FROM users WHERE banned = 0 ORDER BY id DESC LIMIT 50');
}
$players = $query->fetchAll(PDO::FETCH_ASSOC);
page_header('Browse Players');
echo '<h2>Browse ROBLOX Players</h2><div class="legacy-panel"><form method="get" class="legacy-form"><label for="q">Find a player</label><input id="q" name="q" maxlength="30" value="' . h($term) . '"><p><button type="submit">Search</button></p></form></div><div class="legacy-panel"><h3>Players</h3><table class="legacy-table"><tr><th>Character Name</th><th>Joined</th></tr>';
foreach ($players as $player) {
    echo '<tr><td><a href="/User.aspx?id=' . (int)$player['id'] . '">' . h($player['name']) . '</a></td><td>' . h(date('Y-m-d', strtotime($player['created_at']))) . '</td></tr>';
}
if (!$players) echo '<tr><td colspan="2">No players found.</td></tr>';
echo '</table></div>';
page_footer();
?>