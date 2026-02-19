# Adds colors for under clothing
ALTER TABLE `characters` ADD COLUMN `underwear_color` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#ffffff' AFTER `underwear`;
ALTER TABLE `characters` ADD COLUMN `undershirt_color` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#ffffff' AFTER `undershirt`;
