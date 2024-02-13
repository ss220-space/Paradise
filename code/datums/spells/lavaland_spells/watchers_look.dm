/obj/effect/proc_holder/spell/watchers_look
	name = "Watcher's Look"
	desc = ""
	invocation = "ONI DRAKT'CEHOR!"
	invocation_type = "shout"
	base_cooldown = 8 SECONDS
	action_icon_state = "lightning"
	action_background_icon_state = "bg_default"
	need_active_overlay = TRUE
	var/possible_projectiles = list(
		/obj/item/projectile/watcher,
		/obj/item/projectile/temp/basilisk/magmawing,
		/obj/item/projectile/temp/basilisk/icewing)
	var/projectile_number = 1


/obj/effect/proc_holder/spell/watchers_look/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom


/obj/effect/proc_holder/spell/watchers_look/cast(list/targets, mob/user = usr)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir)
	if(!istype(U) || !istype(T))
		return FALSE
	var/projectile_type = possible_projectiles[projectile_number]
	var/obj/item/projectile/proj = new projectile_type(T)
	proj.current = get_turf(user)
	proj.original = target
	proj.firer = user
	proj.preparePixelProjectile(target, get_turf(target), user, targeting.click_params)
	proj.fire()
	user.newtonian_move(get_dir(U, T))
	return TRUE


/obj/effect/proc_holder/spell/watchers_look/AltClick(mob/user)
	projectile_number = (projectile_number % 3) + 1
	switch(projectile_number)
		if(1)
			action.background_icon_state = "bg_default"
		if(2)
			action.background_icon_state = "bg_demon"
		if(3)
			action.background_icon_state = "bg_spell_old"

	action.UpdateButtonIcon()
