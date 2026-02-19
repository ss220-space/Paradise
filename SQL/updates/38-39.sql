# Updates DB from 38 to 39
# Adds support for exoframes for machine people
ALTER TABLE `characters` ADD COLUMN `exoframe_type` VARCHAR(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EXO_REINFORCED';
