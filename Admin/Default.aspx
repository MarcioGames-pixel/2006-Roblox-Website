<?php
require_once __DIR__ . '/../cfg/includes.php';
require_once __DIR__ . '/../cfg/functions.php';
require_login();
$admin = current_user();
if (!$admin || (int)$admin['admin'] !== 1) {
    http_response_code(403);
    page_header('Access denied');
    echo '<div class="notice error">You do not have permission to access this page.</div>';
    page_footer();
    exit;
}
$notice = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $targetId = (int)($_POST['user_id'] ?? 0);
    $action = $_POST['action'] ?? '';
    if ($targetId > 0 && $targetId !== (int)$admin['id'] && in_array($action, ['ban', 'unban'], true)) {
        $update = $db->prepare('UPDATE users SET banned = :banned WHERE id = :id AND admin = 0');
        $update->execute(['banned' => $action === 'ban' ? 1 : 0, 'id' => $targetId]);
        $notice = $update->rowCount() ? 'Account status updated.' : 'No eligible account was changed.';
    } else {
        $notice = 'That moderation action is not allowed.';
    }
}
$users = $db->query('SELECT id, name, banned, created_at FROM users ORDER BY id DESC LIMIT 100')->fetchAll(PDO::FETCH_ASSOC);
page_header('Administration');
echo '<h2>ROBLOX Administration</h2><p>Manage community accounts. Administrator accounts are protected from these actions.</p>';
if ($notice) echo '<div class="notice">' . h($notice) . '</div>';
echo '<div class="legacy-panel"><h3>Recent Accounts</h3><table class="legacy-table"><tr><th>Player</th><th>Joined</th><th>Status</th><th>Action</th></tr>';
foreach ($users as $account) {
    echo '<tr><td><a href="/User.aspx?id=' . (int)$account['id'] . '">' . h($account['name']) . '</a></td><td>' . h($account['created_at']) . '</td><td>' . ((int)$account['banned'] ? 'Banned' : 'Active') . '</td><td>';
    if ((int)$account['banned'] === 1) {
        echo '<form method="post"><input type="hidden" name="csrf_token" value="' . h(csrf_token()) . '"><input type="hidden" name="user_id" value="' . (int)$account['id'] . '"><input type="hidden" name="action" value="unban"><button type="submit">Unban</button></form>';
    } elseif ((int)$account['admin'] !== 1 && (int)$account['id'] !== (int)$admin['id']) {
        echo '<form method="post"><input type="hidden" name="csrf_token" value="' . h(csrf_token()) . '"><input type="hidden" name="user_id" value="' . (int)$account['id'] . '"><input type="hidden" name="action" value="ban"><button type="submit">Ban</button></form>';
    } else { echo 'Protected'; }
    echo '</td></tr>';
}
echo '</table></div>';
page_footer();
?>