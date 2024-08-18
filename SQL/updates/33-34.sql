# Updates DB from 33 to 34
# Adds a new table for instance data caching, and server_id fields on other tables

CREATE TABLE `instance_data_cache` (
	`server_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`key_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`key_value` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`last_updated` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	PRIMARY KEY (`server_id`, `key_name`) USING HASH
) COLLATE='utf8mb4_unicode_ci' ENGINE=MEMORY;

ALTER TABLE `ban`
	ADD COLUMN `server_id` VARCHAR(50) NULL DEFAULT NULL AFTER `serverip`;

ALTER TABLE `connection_log`
	ADD COLUMN `server_id` VARCHAR(50) NULL DEFAULT NULL AFTER `computerid`;

ALTER TABLE `death`
	ADD COLUMN `server_id` TEXT NULL AFTER `tod`;

ALTER TABLE `karma`
	ADD COLUMN `server_id` TEXT NULL AFTER `spenderip`;

ALTER TABLE `legacy_population`
	ADD COLUMN `server_id` VARCHAR(50) NULL DEFAULT NULL AFTER `admincount`;

# Notes already has a column for this
ALTER TABLE `notes`
	CHANGE COLUMN `server` `server` VARCHAR(50) NULL COLLATE 'utf8mb4_unicode_ci' AFTER `edits`;

ALTER TABLE `round`
	ADD COLUMN `server_id` VARCHAR(50) NULL DEFAULT NULL AFTER `station_name`;
