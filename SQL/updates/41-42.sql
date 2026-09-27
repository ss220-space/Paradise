# Updates DB from 41 to 42
# Adds new tables linking Steam accounts from the launcher to BYOND ckeys

DROP TABLE IF EXISTS `launcher_link`;
CREATE TABLE `launcher_link`
(
	`steamid64` BIGINT UNSIGNED NOT NULL,
	`ckey` VARCHAR(32) NOT NULL,
	`nickname` VARCHAR(32) NULL DEFAULT NULL,
	`first_seen` DATETIME DEFAULT now() NOT NULL,
	`last_seen` DATETIME DEFAULT now() NOT NULL,
	PRIMARY KEY (`steamid64`),
	KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `launcher_link_request`;
CREATE TABLE `launcher_link_request` (
	`launcher_ckey` VARCHAR(32) NOT NULL,
	`ckey` VARCHAR(32) NOT NULL,
	`requested` DATETIME DEFAULT now() NOT NULL,
	`resolved` DATETIME NULL DEFAULT NULL,
	`approved` TINYINT(1) NULL DEFAULT NULL,
	PRIMARY KEY (`launcher_ckey`, `ckey`),
	KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
