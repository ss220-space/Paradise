/**
 * tgui state: mod_state
 *
 * Checks that the user is admin or mod, end-of-story.
 */

GLOBAL_DATUM_INIT(admin_mod_state, /datum/ui_state/admin_mod_state, new)

/datum/ui_state/admin_mod_state/can_use_topic(src_object, mob/user, atom/ui_source)
	if(check_rights_for(user.client, R_ADMIN) || check_rights_for(user.client, R_MOD))
		return UI_INTERACTIVE
	return UI_CLOSE
