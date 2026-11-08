<?php
function h($value) {
    return htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function csrf_token() {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function csrf_check() {
    $token = $_POST['csrf_token'] ?? '';
    if (!is_string($token) || !hash_equals(csrf_token(), $token)) {
        http_response_code(403);
        exit('Invalid request token. Please go back and try again.');
    }
}

function redirect_to($url) {
    header('Location: ' . $url);
    exit;
}

function current_user() {
    global $db;
    if (empty($_SESSION['id'])) {
        return null;
    }

    $query = $db->prepare('SELECT id, name, email, description, admin, banned, created_at FROM users WHERE id = :id LIMIT 1');
    $query->execute(['id' => (int)$_SESSION['id']]);
    $user = $query->fetch(PDO::FETCH_ASSOC);

    if (!$user || (int)$user['banned'] === 1) {
        $_SESSION = [];
        if (session_status() === PHP_SESSION_ACTIVE) {
            session_regenerate_id(true);
        }
        return null;
    }

    $_SESSION['loggedin'] = true;
    $_SESSION['name'] = $user['name'];
    $_SESSION['admin'] = (int)$user['admin'];
    return $user;
}

function require_login() {
    if (!current_user()) {
        redirect_to('/Login/Default.aspx');
    }
}

function page_header($title) {
    $user = current_user();
    echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>' . h($title) . ' - ROBLOX</title><link rel="stylesheet" href="/css/Roblox.css"><link rel="stylesheet" href="/css/Roblox_002.css"><style>
    body{margin:0;background:#fff;color:#333;font:12px Arial,sans-serif}#Container{max-width:980px;margin:0 auto}#Header{background:#9fc4df;border-bottom:1px solid #6489a5;padding:12px 18px}#Logo a{font-size:27px;font-weight:bold;color:#fff;text-decoration:none;text-shadow:1px 1px #567}#Navigation{padding:9px 14px;background:#eee;border-bottom:1px solid #bbb}#Navigation a{color:#03c;font-weight:bold;margin:0 7px}#Body{padding:18px;min-height:420px}.legacy-panel{border:1px solid #999;padding:14px;margin:12px 0;background:#fafafa}.legacy-panel h2,.legacy-panel h3{margin-top:0;color:#333}.legacy-form label{display:block;font-weight:bold;margin:9px 0 3px}.legacy-form input,.legacy-form textarea{box-sizing:border-box;max-width:100%;width:320px;padding:6px;border:1px solid #888}.legacy-form textarea{height:110px}.legacy-form button,.legacy-button{padding:6px 16px;background:#ddd;border:1px solid #777;color:#111;font-weight:bold;cursor:pointer}.notice{padding:9px;border:1px solid #c5a45a;background:#fff8dc;margin:10px 0}.error{border-color:#c66;background:#fff0f0}.legacy-table{width:100%;border-collapse:collapse}.legacy-table th,.legacy-table td{padding:8px;border-bottom:1px solid #ccc;text-align:left}.muted{color:#777}#Footer{padding:10px 18px;color:#555}#Footer hr{border:0;border-top:1px solid #aaa}@media(max-width:600px){#Navigation a{display:inline-block;margin:5px}.legacy-form input,.legacy-form textarea{width:100%}#Body{padding:10px}}
    </style></head><body><div id="Container"><div id="Header"><div id="Logo"><a href="/">ROBLOX</a></div></div><div id="Navigation"><a href="/">Home</a><a href="/MP/Default.aspx">Games</a><a href="/User.aspx">My ROBLOX</a><a href="/Browse.aspx">Browse</a><a href="/Badges.aspx">Badges</a><a href="/Forum/Default.aspx">Forum</a><a href="/News.aspx">News</a><a href="/Help.aspx">Help</a>';
    if ($user && (int)$user['admin'] === 1) echo '<a href="/Admin/Default.aspx">Admin</a>';
    if ($user) {
        echo '<span style="float:right"><a href="/Login/logout.php">Log out (' . h($user['name']) . ')</a></span>';
    } else {
        echo '<span style="float:right"><a href="/Login/Default.aspx">Log in</a> | <a href="/Login/New.aspx">Register</a></span>';
    }
    echo '</div><main id="Body">';
}

function page_footer() {
    echo '</main><footer id="Footer"><hr><p>ROBLOX, Online Building Toy. Classic 2006 website revival.</p></footer></div></body></html>';
}
?>