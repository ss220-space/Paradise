// Would be nice to make this a permanent admin pref so we don't need to click it each time
ADMIN_VERB(enable_debug_verbs, R_DEBUG, "Debug verbs - Enable", "Enable all debug verbs.", ADMIN_CATEGORY_DEBUG)
	SSadmin_verbs.update_visibility_flag(user, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG, TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Enable Debug Verbs")

ADMIN_VERB_VISIBILITY(disable_debug_verbs, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(disable_debug_verbs, R_DEBUG, "Debug verbs - Disable", "Disable all debug verbs.", ADMIN_CATEGORY_DEBUG)
	SSadmin_verbs.update_visibility_flag(user, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG, FALSE)
	BLACKBOX_LOG_ADMIN_VERB("Disable Debug Verbs")
