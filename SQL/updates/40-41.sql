# Updates DB from 40 to 41
# Adds a new table for the referral program

DROP TABLE IF EXISTS `referral`;
CREATE TABLE `referral`
(
	`referred_ckey` VARCHAR(32) NOT NULL,
	`referrer_ckey` VARCHAR(32) NOT NULL,
	`date` DATETIME DEFAULT now() NOT NULL,
	`referred_ip` VARCHAR(18) NULL DEFAULT NULL,
	`referred_computerid` VARCHAR(32) NULL DEFAULT NULL,
	`referred_discord_id` VARCHAR(32) NULL DEFAULT NULL,
	`rewarded` BOOLEAN DEFAULT false NOT NULL,
	`reward_date` DATETIME NULL DEFAULT NULL,
	`revoked` BOOLEAN DEFAULT false NOT NULL,
	PRIMARY KEY (`referred_ckey`),
	UNIQUE KEY `referred_discord_id` (`referred_discord_id`),
	KEY `referrer_ckey` (`referrer_ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
