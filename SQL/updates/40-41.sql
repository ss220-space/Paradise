# Updates DB from 39 to 40
# Adds a new table for achievements

DROP TABLE IF EXISTS `curcuit_library`;
CREATE TABLE `curcuit_library` (
	`ckey` VARCHAR(32) NOT NULL,
	`author_name` VARCHAR(32) NOT NULL,
	`design` TEXT NOT NULL,
	PRIMARY KEY (`ckey`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
