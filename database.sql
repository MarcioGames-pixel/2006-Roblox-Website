CREATE DATABASE IF NOT EXISTS roblox2006 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE roblox2006;

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(20) NOT NULL,
  passwd VARCHAR(255) NOT NULL,
  email VARCHAR(190) DEFAULT NULL,
  description VARCHAR(500) NOT NULL DEFAULT '',
  admin TINYINT(1) NOT NULL DEFAULT 0,
  banned TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY users_name_unique (name),
  UNIQUE KEY users_email_unique (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS forum_topics (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  title VARCHAR(100) NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY forum_topics_created (created_at),
  CONSTRAINT forum_topics_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS forum_replies (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  topic_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY forum_replies_topic (topic_id, created_at),
  CONSTRAINT forum_replies_topic_fk FOREIGN KEY (topic_id) REFERENCES forum_topics(id) ON DELETE CASCADE,
  CONSTRAINT forum_replies_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create the first administrator only after registration:
-- UPDATE users SET admin = 1 WHERE name = 'YOUR_USERNAME';
-- Never use a shared default administrator password.
