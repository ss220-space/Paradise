# Updates DB from 35 to 36
# Adds support for screentips
ALTER TABLE `player` ADD COLUMN `screentip_mode` tinyint(1) DEFAULT '8';
ALTER TABLE `player` ADD COLUMN `screentip_color` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#deefff';
