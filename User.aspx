<?php
require_once __DIR__ . '/cfg/includes.php';
require_once __DIR__ . '/cfg/functions.php';

$userId = isset($_GET['id']) ? (int)$_GET['id'] : (int)($_SESSION['id'] ?? 0);
if ($userId < 1) {
    redirect_to('/Login/Default.aspx');
}
$query = $db->prepare('SELECT id, name, description, created_at FROM users WHERE id = :id LIMIT 1');
$query->execute(['id' => $userId]);
$profile = $query->fetch(PDO::FETCH_ASSOC);
if (!$profile) {
    http_response_code(404);
    page_header('User not found');
    echo '<div class="notice error">This user could not be found.</div>';
    page_footer();
    exit;
}

$viewer = current_user();
$error = '';
if ($viewer && (int)$viewer['id'] === $userId && $_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $description = trim($_POST['description'] ?? '');
    if (mb_strlen($description) > 500) {
        $error = 'Your description must be 500 characters or fewer.';
    } else {
        $save = $db->prepare('UPDATE users SET description = :description WHERE id = :id');
        $save->execute(['description' => $description, 'id' => $userId]);
        redirect_to('/User.aspx?id=' . $userId);
    }
}

page_header($profile['name'] . "'s Profile");
echo '<h2>' . h($profile['name']) . "'s ROBLOX Profile</h2>";
echo '<div class="legacy-panel"><h3>About Me</h3><p>' . nl2br(h($profile['description'] ?: 'This player has not written a description yet.')) . '</p><p class="muted">Member since ' . h(date('F j, Y', strtotime($profile['created_at']))) . '</p></div>';
if ($viewer && (int)$viewer['id'] === $userId) {
    echo '<div class="legacy-panel"><h3>Edit Profile</h3>';
    if ($error) echo '<div class="notice error">' . h($error) . '</div>';
    echo '<form class="legacy-form" method="post"><input type="hidden" name="csrf_token" value="' . h(csrf_token()) . '"><label for="description">Description</label><textarea id="description" name="description" maxlength="500">' . h($profile['description']) . '</textarea><p><button type="submit">Save Changes</button></p></form></div>';
}
page_footer();
?>