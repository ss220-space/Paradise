# Adds support for hair gradient
ALTER TABLE `characters` ADD COLUMN `hair_gradient` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL AFTER `uplink_pref`; 
ALTER TABLE `characters` ADD COLUMN `hair_gradient_offset` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0,0' AFTER `uplink_pref`;
ALTER TABLE `characters` ADD COLUMN `hair_gradient_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000' AFTER `uplink_pref`;
ALTER TABLE `characters` ADD COLUMN `hair_gradient_alpha` tinyint(3) UNSIGNED NOT NULL DEFAULT '200' AFTER `uplink_pref`;
