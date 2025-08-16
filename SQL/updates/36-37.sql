# Updates DB from 35 to 36
# Adds support for disabling antagonism for some characters.
ALTER TABLE `characters` ADD COLUMN `can_be_antagonist` tinyint(1) DEFAULT '1' AFTER `hair_gradient_alpha`;
