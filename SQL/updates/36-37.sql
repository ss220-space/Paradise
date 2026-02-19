# Updates DB from 36 to 37
# Adds support for disabling antagonism for some characters.
ALTER TABLE `characters` ADD COLUMN `can_be_antagonist` tinyint(1) DEFAULT '1' AFTER `hair_gradient_alpha`;
