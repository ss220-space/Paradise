# Adds tracking of who flagged which book.
ALTER TABLE `library` ADD COLUMN `flaggedby` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ' ' AFTER `flagged`;