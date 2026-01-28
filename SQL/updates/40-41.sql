# Updates DB from 40 to 41
# Adds a new table for curcuit designs

DROP TABLE IF EXISTS `curcuit_designs`;
CREATE TABLE `curcuit_designs` (
	`ckey` VARCHAR(32) NOT NULL,
	`author` VARCHAR(32) NOT NULL,
	`design` MEDIUMTEXT NOT NULL,
	PRIMARY KEY (`ckey`,`design`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
