# Add TTS voice seed preference
ALTER TABLE `characters` ADD `tts_seed` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `uplink_pref`;
# Adds support for hair gradient
ALTER TABLE `characters` ADD COLUMN `hair_gradient` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` ADD COLUMN `hair_gradient_offset` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0,0';
ALTER TABLE `characters` ADD COLUMN `hair_gradient_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000';
ALTER TABLE `characters` ADD COLUMN `hair_gradient_alpha` tinyint(3) UNSIGNED NOT NULL DEFAULT '200'
