<?php
require_once __DIR__ . '/../cfg/includes.php';
require_once __DIR__ . '/../cfg/functions.php';

$topicId = (int)($_GET['id'] ?? 0);
$getTopic = $db->prepare('SELECT t.*, u.name FROM forum_topics t JOIN users u ON u.id = t.user_id WHERE t.id = :id LIMIT 1');
$getTopic->execute(['id' => $topicId]);
$topic = $getTopic->fetch(PDO::FETCH_ASSOC);
if (!$topic) {
    http_response_code(404);
    page_header('Topic not found');
    echo '<div class="notice error">This forum topic does not exist.</div>';
    page_footer();
    exit;
}
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require_login();
    csrf_check();
    $body = trim($_POST['body'] ?? '');
    if (strlen($body) < 2 || mb_strlen($body) > 3000) {
        $error = 'Your reply must be between 2 and 3000 characters.';
    } else {
        $reply = $db->prepare('INSERT INTO forum_replies (topic_id, user_id, body, created_at) VALUES (:topic_id, :user_id, :body, NOW())');
        $reply->execute(['topic_id' => $topicId, 'user_id' => (int)$_SESSION['id'], 'body' => $body]);
        redirect_to('/Forum/Post.aspx?id=' . $topicId);
    }
}
$replyQuery = $db->prepare('SELECT r.body, r.created_at, u.id AS user_id, u.name FROM forum_replies r JOIN users u ON u.id = r.user_id WHERE r.topic_id = :id ORDER BY r.created_at ASC');
$replyQuery->execute(['id' => $topicId]);
$replies = $replyQuery->fetchAll(PDO::FETCH_ASSOC);
page_header($topic['title']);
echo '<p><a href="/Forum/Default.aspx">&laquo; Back to Forum</a></p><div class="legacy-panel"><h2>' . h($topic['title']) . '</h2><p class="muted">Posted by <a href="/User.aspx?id=' . (int)$topic['user_id'] . '">' . h($topic['name']) . '</a> on ' . h($topic['created_at']) . '</p><p>' . nl2br(h($topic['body'])) . '</p></div>';
if ($error) echo '<div class="notice error">' . h($error) . '</div>';
echo '<h3>Replies</h3>';
foreach ($replies as $reply) {
    echo '<div class="legacy-panel"><p class="muted"><a href="/User.aspx?id=' . (int)$reply['user_id'] . '">' . h($reply['name']) . '</a> - ' . h($reply['created_at']) . '</p><p>' . nl2br(h($reply['body'])) . '</p></div>';
}
if (current_user()) {
    echo '<div class="legacy-panel"><h3>Write a Reply</h3><form class="legacy-form" method="post"><input type="hidden" name="csrf_token" value="' . h(csrf_token()) . '"><label for="body">Your reply</label><textarea id="body" name="body" maxlength="3000" required></textarea><p><button type="submit">Submit Reply</button></p></form></div>';
} else {
    echo '<p><a href="/Login/Default.aspx">Log in</a> to reply.</p>';
}
page_footer();
?>