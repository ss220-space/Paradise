-- Optimizing queries performance by adding indexes
ALTER TABLE `budget` ADD INDEX `idx_budget_search` (`ckey`, `is_valid`, `date_start`, `date_end`, `amount`);
