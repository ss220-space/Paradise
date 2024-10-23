# Adds pseudorandom support for gamemodes
CREATE TABLE `pseudorandom_gamemodes` (
  `server_port` smallint unsigned NOT NULL,
  `gamemode_config_tag` varchar(32) NOT NULL,
  `n_not_happened` tinyint unsigned DEFAULT '0',
  PRIMARY KEY (`server_port`, `gamemode_config_tag`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci