/obj/effect/proc_holder/spell/watchers_look
	name = "Watcher's Look"
	desc = "Shoot one of the watcher's beams. To change the mode, use alt-click on the icon."
	invocation = "ONI DRAKT'CEHOR!"
	invocation_type = "shout"
	base_cooldown = 3 SECONDS
	action_icon_state = "watcher_normal"
	action_background_icon_state = ""
	need_active_overlay = TRUE
	var/projectiles_icons = list(
		"watcher_normal" = /obj/item/projectile/watcher,
		"watcher_fire" = /obj/item/projectile/temp/basilisk/magmawing,
		"watcher_ice" = /obj/item/projectile/temp/basilisk/icewing)
	var/selected_projectile = 1


/obj/effect/proc_holder/spell/watchers_look/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom


/obj/effect/proc_holder/spell/watchers_look/cast(list/targets, mob/user = usr)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir)
	if(!istype(U) || !istype(T))
		return FALSE
	var/projectile_type = projectiles_icons[projectiles_icons[selected_projectile]]
	var/obj/item/projectile/proj = new projectile_type(T)
	proj.current = get_turf(user)
	proj.original = target
	proj.firer = user
	proj.preparePixelProjectile(target, get_turf(target), user, targeting.click_params)
	proj.fire()
	user.newtonian_move(get_dir(U, T))
	return TRUE


/obj/effect/proc_holder/spell/watchers_look/AltClick(mob/user)
	//switch to next type of projectile and update action's icon
	selected_projectile = selected_projectile % length(projectiles_icons) + 1
	action.button_icon_state = projectiles_icons[selected_projectile]
	action.UpdateButtonIcon()
