<?php
require_once __DIR__ . '/../cfg/includes.php';
require_once __DIR__ . '/../cfg/functions.php';

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require_login();
    csrf_check();
    $title = trim($_POST['title'] ?? '');
    $body = trim($_POST['body'] ?? '');
    if (mb_strlen($title) < 3 || mb_strlen($title) > 100 || mb_strlen($body) < 3 || mb_strlen($body) > 5000) {
        $error = 'Enter a title (3-100 characters) and a message (3-5000 characters).';
    } else {
        $insert = $db->prepare('INSERT INTO forum_topics (user_id, title, body, created_at) VALUES (:user_id, :title, :body, NOW())');
        $insert->execute(['user_id' => (int)$_SESSION['id'], 'title' => $title, 'body' => $body]);
        redirect_to('/Forum/Post.aspx?id=' . $db->lastInsertId());
    }
}
$topics = $db->query('SELECT t.id, t.title, t.created_at, u.name, (SELECT COUNT(*) FROM forum_replies r WHERE r.topic_id = t.id) AS replies FROM forum_topics t JOIN users u ON u.id = t.user_id ORDER BY t.created_at DESC LIMIT 50')->fetchAll(PDO::FETCH_ASSOC);
page_header('Forum');
echo '<h2>ROBLOX Community Forum</h2><p>Talk about building, games, and the ROBLOX community.</p>';
if ($error) echo '<div class="notice error">' . h($error) . '</div>';
if (current_user()) {
    echo '<div class="legacy-panel"><h3>Create a New Topic</h3><form class="legacy-form" method="post"><input type="hidden" name="csrf_token" value="' . h(csrf_token()) . '"><label for="title">Topic title</label><input id="title" name="title" maxlength="100" required><label for="body">Message</label><textarea id="body" name="body" maxlength="5000" required></textarea><p><button type="submit">Post Topic</button></p></form></div>';
} else {
    echo '<div class="notice">Please <a href="/Login/Default.aspx">log in</a> to create a forum topic.</div>';
}
echo '<div class="legacy-panel"><h3>Recent Topics</h3><table class="legacy-table"><tr><th>Topic</th><th>Started by</th><th>Replies</th><th>Date</th></tr>';
foreach ($topics as $topic) {
    echo '<tr><td><a href="/Forum/Post.aspx?id=' . (int)$topic['id'] . '">' . h($topic['title']) . '</a></td><td><a href="/User.aspx?id=' . (int)$topic['id'] . '">' . h($topic['name']) . '</a></td><td>' . (int)$topic['replies'] . '</td><td>' . h(date('Y-m-d', strtotime($topic['created_at']))) . '</td></tr>';
}
if (!$topics) echo '<tr><td colspan="4">No topics yet. Be the first to post!</td></tr>';
echo '</table></div>';
page_footer();
?>