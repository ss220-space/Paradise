# Add exploit records
ALTER TABLE `characters`
	ADD COLUMN `exploit_record` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `gen_record`;
# Adds support for persistent ghost darkness
ALTER TABLE `player` ADD COLUMN `ghost_darkness_level` tinyint(1) UNSIGNED NOT NULL DEFAULT '255'
