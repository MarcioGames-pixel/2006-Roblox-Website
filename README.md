# 2006-Roblox-Website

A December 2006-style ROBLOX community website revival. The original classic layout and assets are retained while the community features are being made functional.

## Features

- Classic 2006-inspired frontend and original visual assets.
- Account registration and login using PHP sessions and password hashing.
- CSRF protection on registration, login, profile edits, and forum posts.
- User profiles with editable descriptions.
- Forum topics and replies.
- Local Badges, News, and Help pages.
- PDO database access with prepared statements.

## Requirements

- PHP 7.4+ (PHP 8.x recommended)
- MySQL 5.7+ or MariaDB 10.3+
- PHP extensions: PDO, PDO MySQL
- Apache with the provided `.htaccess` rules, or equivalent URL handling.

## Installation

1. Copy the repository files into your web root.
2. Create a database and import `database.sql` for a fresh installation.
3. Configure the connection using environment variables:
   - `ROBLOX_DB_HOST` (default: `127.0.0.1`)
   - `ROBLOX_DB_NAME` (default: `roblox2006`)
   - `ROBLOX_DB_USER` (default: `root`)
   - `ROBLOX_DB_PASSWORD` (default: empty)
4. Ensure Apache sends `.aspx` requests to PHP using the included `.htaccess` files.
5. Open the site and register a new account.

For an existing installation using the original `users` table, back up the database and run `database-upgrade.sql` once instead of importing the fresh schema. Existing plaintext-password accounts are not accepted by the new login; reset those accounts or create new ones.

## Administrator account

There is no default administrator account or shared password. Register your own account, then run this query in your database:

```sql
UPDATE users SET admin = 1 WHERE name = 'YOUR_NEW_USERNAME';
```

The admin flag is reserved for upcoming administration tools. Never publish your database password or reuse a password from another service.

## Notes

- The registration form accepts an optional email address, but automated password-recovery email is not implemented yet.
- The Badges, News, and Help pages currently provide working local pages; badge awarding and an editable news/admin system are future work.
- The classic game page and legacy installer still depend on the original client/server ecosystem and are not replaced by this web update.
- Preserve the original project credits and assets when redistributing.

## Roadmap

- [x] Classic home, games, login, and download page
- [x] Secure account registration and login
- [x] User profile and description editing
- [x] Forum topics and replies
- [x] Local Badges, News, and Help pages
- [ ] Badge awarding and profile badge display
- [ ] Admin dashboard and moderation tools
- [ ] Password reset email flow
- [ ] Complete Browse/catalog and private messages
- [ ] Replace remaining legacy external links and placeholder game actions
- [ ] Automated tests and broader compatibility cleanup