<?php
require_once __DIR__ . '/../cfg/includes.php';
require_once __DIR__ . '/../cfg/functions.php';

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $username = trim($_POST['usernamefield'] ?? '');
    $password = $_POST['passwordfield'] ?? '';

    if ($username !== '' && $password !== '') {
        $query = $db->prepare('SELECT id, name, passwd, banned FROM users WHERE name = :name LIMIT 1');
        $query->execute(['name' => $username]);
        $account = $query->fetch();

        if ($account && (int)$account['banned'] === 0 && password_verify($password, $account['passwd'])) {
            session_regenerate_id(true);
            $_SESSION['id'] = (int)$account['id'];
            $_SESSION['name'] = $account['name'];
            $_SESSION['loggedin'] = true;
            redirect_to('/');
        }
    }
    $error = 'Invalid username or password.';
}

page_header('Login');
echo '<div class="legacy-panel" style="max-width:520px;margin:35px auto"><h2>Member Log-In</h2><p>New to ROBLOX? <a href="New.aspx">Create an account</a>.</p>';
if ($error) echo '<div class="notice error">' . h($error) . '</div>';
echo '<form class="legacy-form" method="post" action="Default.aspx"><input type="hidden" name="csrf_token" value="' . h(csrf_token()) . '"><label for="usernamefield">Character Name</label><input id="usernamefield" name="usernamefield" type="text" maxlength="20" autocomplete="username" required><label for="passwordfield">Password</label><input id="passwordfield" name="passwordfield" type="password" autocomplete="current-password" required><p><button type="submit">Log In</button></p></form><p><a href="New.aspx">Register</a></p></div>';
page_footer();
?>