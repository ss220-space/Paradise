# Updates DB from 42 to 43
# Stores map zoom and scaling method in player preferences

ALTER TABLE `player` ADD COLUMN `zoom` float NOT NULL DEFAULT '0';
ALTER TABLE `player` ADD COLUMN `zoom_mode` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'distort';
