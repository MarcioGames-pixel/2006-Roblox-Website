<?php
require_once __DIR__ . '/../cfg/includes.php';
require_once __DIR__ . '/../cfg/functions.php';

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $username = trim($_POST['usernamefield'] ?? '');
    $password = $_POST['passwordfield'] ?? '';
    $confirm = $_POST['passwordconfirm'] ?? '';
    $email = trim($_POST['emailfield'] ?? '');

    if (!preg_match('/^[A-Za-z0-9]{3,20}$/', $username)) {
        $error = 'Choose a name with 3-20 letters or numbers and no spaces.';
    } elseif (strlen($password) < 8 || strlen($password) > 72) {
        $error = 'Your password must be between 8 and 72 characters.';
    } elseif (!hash_equals($password, $confirm)) {
        $error = 'The passwords do not match.';
    } elseif ($email !== '' && (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 190)) {
        $error = 'Enter a valid email address or leave the field blank.';
    } else {
        $check = $db->prepare('SELECT id FROM users WHERE name = :name OR (:email <> "" AND email = :email) LIMIT 1');
        $check->execute(['name' => $username, 'email' => $email]);
        if ($check->fetch()) {
            $error = 'That username or email address is already registered.';
        } else {
            $insert = $db->prepare('INSERT INTO users (name, passwd, email, description, admin, banned, created_at) VALUES (:name, :passwd, :email, "", 0, 0, NOW())');
            $insert->execute([
                'name' => $username,
                'passwd' => password_hash($password, PASSWORD_DEFAULT),
                'email' => $email !== '' ? $email : null
            ]);
            session_regenerate_id(true);
            $_SESSION['id'] = (int)$db->lastInsertId();
            $_SESSION['name'] = $username;
            $_SESSION['loggedin'] = true;
            redirect_to('/');
        }
    }
}

page_header('Register');
echo '<div class="legacy-panel" style="max-width:560px;margin:25px auto"><h2>Download and Play - Step 1 of 2</h2><h3>Choose a name for your ROBLOX character</h3>';
if ($error) echo '<div class="notice error">' . h($error) . '</div>';
echo '<form class="legacy-form" method="post" action="New.aspx"><input type="hidden" name="csrf_token" value="' . h(csrf_token()) . '"><label for="usernamefield">Character name</label><input id="usernamefield" name="usernamefield" type="text" minlength="3" maxlength="20" pattern="[A-Za-z0-9]{3,20}" autocomplete="username" required><p class="muted">Use 3-20 letters or numbers, with no spaces.</p><label for="passwordfield">Choose your password</label><input id="passwordfield" name="passwordfield" type="password" minlength="8" maxlength="72" autocomplete="new-password" required><label for="passwordconfirm">Confirm password</label><input id="passwordconfirm" name="passwordconfirm" type="password" minlength="8" maxlength="72" autocomplete="new-password" required><p class="muted">Use at least 8 characters.</p><label for="emailfield">E-mail address (optional)</label><input id="emailfield" name="emailfield" type="email" maxlength="190" autocomplete="email"><p class="muted">An email recovery workflow will be added separately.</p><p><button type="submit">Register</button></p></form><p>Already registered? <a href="Default.aspx">Log in</a>.</p></div>';
page_footer();
?>