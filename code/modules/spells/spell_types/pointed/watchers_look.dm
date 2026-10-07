/datum/action/cooldown/spell/pointed/projectile/watchers_look
	name = "Watcher's Look"
	desc = "Shoot one of the watcher's beams. To change the mode, use right click on the icon."
	invocation = "ONI DRAKT'CEHOR!"
	invocation_type = INVOCATION_SHOUT
	cooldown_time = 3 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_LAVALAND
	button_icon_state = "watcher_normal"
	background_icon_state = ""
	var/projectiles_icons = list(
		"watcher_normal" = /obj/projectile/watcher,
		"watcher_fire" = /obj/projectile/temp/basilisk/magmawing,
		"watcher_ice" = /obj/projectile/temp/basilisk/icewing,
	)
	var/selected_projectile = 1
	projectile_type = /obj/projectile/watcher

/datum/action/cooldown/spell/pointed/projectile/watchers_look/Trigger(mob/clicker, trigger_flags, atom/target)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		//switch to next type of projectile and update action's icon
		selected_projectile = selected_projectile % length(projectiles_icons) + 1
		projectile_type = projectiles_icons[projectiles_icons[selected_projectile]]
		button_icon_state = projectiles_icons[selected_projectile]
		UpdateButtonIcon()
		return CLICK_ACTION_SUCCESS
	return ..()
