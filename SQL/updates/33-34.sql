# Adds poll related. Poll question as body, options inside body, textreply and vote as player answers
--
--	Table structure for table `poll_question`
--
DROP TABLE IF EXISTS `poll_question`;
CREATE TABLE IF NOT EXISTS `poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` enum('Single Option','Text Reply','Rating','Multiple Choice') NOT NULL,
  `created_datetime` datetime NOT NULL,
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtitle` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `adminonly` tinyint(1) unsigned NOT NULL,
  `multiplechoiceoptions` int(2) DEFAULT NULL,
  `createdby_ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dontshow` tinyint(1) unsigned NOT NULL,
  `minimum_playtime` int(4) NOT NULL,
  `allow_revoting` tinyint(1) unsigned NOT NULL,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_pquest_question_time_ckey` (`question`,`starttime`,`endtime`,`createdby_ckey`),
  KEY `idx_pquest_time_deleted_id` (`starttime`,`endtime`, `deleted`, `id`),
  KEY `idx_pquest_id_time_type_admin` (`id`,`starttime`,`endtime`,`polltype`,`adminonly`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
--	Table structure for table `poll_option`
--
DROP TABLE IF EXISTS `poll_option`;
CREATE TABLE IF NOT EXISTS `poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `minval` int(3) DEFAULT NULL,
  `maxval` int(3) DEFAULT NULL,
  `descmin` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descmid` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descmax` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default_percentage_calc` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_pop_pollid` (`pollid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
--	Table structure for table `poll_textreply`
--
DROP TABLE IF EXISTS `poll_textreply`;
CREATE TABLE IF NOT EXISTS `poll_textreply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `replytext` varchar(2048) COLLATE utf8mb4_unicode_ci NOT NULL,
  `adminrank` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_ptext_pollid_ckey` (`pollid`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
--	Table structure for table `poll_vote`
--
DROP TABLE IF EXISTS `poll_vote`;
CREATE TABLE IF NOT EXISTS `poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `adminrank` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` int(2) DEFAULT NULL,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_pvote_pollid_ckey` (`pollid`,`ckey`),
  KEY `idx_pvote_optionid_ckey` (`optionid`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER $$
DROP PROCEDURE IF EXISTS `set_poll_deleted`;
CREATE PROCEDURE `set_poll_deleted`(
	IN `poll_id` INT
)
SQL SECURITY INVOKER
BEGIN
UPDATE `poll_question` SET deleted = 1 WHERE id = poll_id;
UPDATE `poll_option` SET deleted = 1 WHERE pollid = poll_id;
UPDATE `poll_vote` SET deleted = 1 WHERE pollid = poll_id;
UPDATE `poll_textreply` SET deleted = 1 WHERE pollid = poll_id;
END
$$
DELIMITER ;
