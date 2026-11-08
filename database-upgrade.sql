-- Run once on an existing installation after backing up the database.
ALTER TABLE users
  MODIFY name VARCHAR(20) NOT NULL,
  MODIFY passwd VARCHAR(255) NOT NULL,
  ADD COLUMN email VARCHAR(190) DEFAULT NULL AFTER passwd,
  ADD COLUMN description VARCHAR(500) NOT NULL DEFAULT '' AFTER email,
  ADD COLUMN created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD UNIQUE KEY users_name_unique (name),
  ADD UNIQUE KEY users_email_unique (email);

CREATE TABLE forum_topics (id INT UNSIGNED NOT NULL AUTO_INCREMENT, user_id INT NOT NULL, title VARCHAR(100) NOT NULL, body TEXT NOT NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), KEY forum_topics_created (created_at), CONSTRAINT forum_topics_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE forum_replies (id INT UNSIGNED NOT NULL AUTO_INCREMENT, topic_id INT UNSIGNED NOT NULL, user_id INT NOT NULL, body TEXT NOT NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), KEY forum_replies_topic (topic_id, created_at), CONSTRAINT forum_replies_topic_fk FOREIGN KEY (topic_id) REFERENCES forum_topics(id) ON DELETE CASCADE, CONSTRAINT forum_replies_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- The old demo administrator used a publicly documented plaintext password.
-- Do not keep or reuse that account. Create a new account, then promote it:
-- UPDATE users SET admin = 1 WHERE name = 'YOUR_NEW_USERNAME';