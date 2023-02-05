# Prepare ban table for conversion in TG-like format
# Run this BEFORE 30-31

# Rename old ban table
RENAME TABLE `ban` TO `ban_old`;

# Create the ban table in new format
CREATE TABLE `ban` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `server_ip` varchar(32) NOT NULL,
  `server_port` varchar(32) NOT NULL,
  `round_id` int(11) UNSIGNED NULL,
  `role` varchar(32) NULL DEFAULT NULL,
  `expiration_time` datetime NULL DEFAULT NULL,
  `applies_to_admins` tinyint(1) UNSIGNED NOT NULL DEFAULT '0',
  `reason` varchar(2048) NOT NULL,
  `ckey` varchar(32) NULL DEFAULT NULL,
  `ip` varchar(32) NULL DEFAULT NULL,
  `computerid` varchar(32) NULL DEFAULT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_ip` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `who` varchar(2048) NOT NULL,
  `adminwho` varchar(2048) NOT NULL,
  `edits` TEXT NULL DEFAULT NULL,
  `unbanned_datetime` datetime NULL DEFAULT NULL,
  `unbanned_ckey` varchar(32) NULL DEFAULT NULL,
  `unbanned_ip` varchar(32) NULL DEFAULT NULL,
  `unbanned_computerid` varchar(32) NULL DEFAULT NULL,
  `unbanned_round_id` int(11) UNSIGNED NULL DEFAULT NULL,
  `server` varchar(32) NOT NULL,
  `is_global` tinyint(1) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `computerid` (`computerid`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=58903 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
