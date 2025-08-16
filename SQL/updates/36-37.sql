# Updates DB from 36 to 37
# Adds support for new_light settings
ALTER TABLE `player`
  ADD COLUMN `light` TINYINT UNSIGNED NOT NULL DEFAULT 3,
  ADD COLUMN `glowlevel` TINYINT UNSIGNED NOT NULL DEFAULT 1;