# Add exploit records
ALTER TABLE `characters`
	ADD COLUMN `exploit_record` longtext COLLATE utf8mb4_unicode_ci NOT NULL AFTER `gen_record`;
