/client/proc/drop_lightning_bolt()
	set category = "Admin.Fun"
	set name = "Drop lightning bolt"
	set desc = "Вызвать молнию различной силы под вами."

	if(!check_rights(R_EVENT))
		return
	if(!SSticker || !SSticker.mode)
		tgui_alert(usr, "Нельзя вызывать молнии до начала раунда!", "Предупреждение")
		return

	var/datum/drop_lightning_bolt_ui/editor = new()
	editor.ui_interact(mob)

/turf/proc/spawn_lightning_bolt(harmless = FALSE)
	// FLASH
	var/obj/effect/temp_visual/flash = new (src)
	flash.icon = 'icons/effects/light_overlays/light_128.dmi'
	flash.icon_state = "light"
	flash.blend_mode = BLEND_ADD
	flash.pixel_w = -48
	flash.pixel_z = -48
	flash.set_light(7, 99, "#C5C5FF")
	// BOOM
	playsound(src, 'sound/effects/lightning_bolt.ogg', 100, TRUE, 15, 1.2)
	for(var/mob/to_shake in range(5, src))
		shake_camera(to_shake, 10, 1)
	if(!harmless)
		explosion(src, -1, -1, light_impact_range = 1, flame_range =  2, silent = TRUE)
	// BOLT
	var/obj/effect/temp_visual/thunderbolt/bolt = new (src)
	do_sparks(15, TRUE, bolt)


// _________________________________________TGUI_________________________________________
/datum/drop_lightning_bolt_ui
	var/mob/living/victim_mob = null
	var/turf/victim_turf = null
	var/mode = null
	var/damage = 600
	var/radius = 3
	var/delay = 3
	var/list/players = list()
	var/pointing = FALSE

/datum/drop_lightning_bolt_ui/ui_state(mob/user)
	return GLOB.admin_state

/datum/drop_lightning_bolt_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DropLightningBolt")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/drop_lightning_bolt_ui/ui_data(mob/user)
	. = ..()

	.["x_coord"] = user.x
	.["y_coord"] = user.y
	.["z_coord"] = user.z
	.["damage"] = damage
	.["radius"] = radius
	.["delay"] = delay
	.["mode"] = mode
	.["ckey"] = user.ckey
	.["pointing"] = pointing

	players = list()
	for(var/mob/player in GLOB.player_list) 				// extra 'spaces  ' hell yea
		players[player.ckey] = "[player.real_name] | [player.ckey]  "
	.["players"] = players

/datum/drop_lightning_bolt_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("pickPlayer")
			for(var/mob/player in GLOB.player_list)
				if(player.ckey == params["ckey"])
					victim_mob = player
					break
			victim_turf = null
		if("set_autoupdate")
			ui.set_autoupdate(params["val"])
			victim_turf = locate(text2num(params["x_coord"]), text2num(params["y_coord"]), text2num(params["z_coord"]))
		if("set_mode")
			mode = params["mode"]
			if(usr.client.click_intercept)
				qdel(usr.client.click_intercept)
				usr.client.click_intercept = null
			pointing = FALSE
		if("set_coords")
			victim_turf = locate(text2num(params["x_coord"]), text2num(params["y_coord"]), text2num(params["z_coord"]))
			victim_mob = null
			mode = "По координатам"
		if("set_damage")
			damage = text2num(params["damage"])
		if("set_radius")
			radius = text2num(params["radius"])
		if("set_delay")
			delay = clamp(text2num(params["delay"]), 0, 60)
		if("drop")
			if(!victim_mob && !victim_turf)
				if(mode == "По координатам")
					victim_turf = locate(usr.x, usr.y, usr.z)
				else
					return
			lightning_bolt()
		if("set_pointing")
			pointing = params["val"]
			if(mode == "По указателю")
				if(!usr.client.click_intercept)
					usr.client.click_intercept = new /datum/click_intercept/lightning_bolt_dropper(usr.client, src)
				else
					qdel(usr.client.click_intercept)
					usr.client.click_intercept = null
		else
			. = FALSE

/datum/drop_lightning_bolt_ui/ui_close(mob/user)
	if(usr.client && usr.client.click_intercept)
		qdel(usr.client.click_intercept)

/datum/drop_lightning_bolt_ui/proc/lightning_bolt()
	if((!victim_mob && !victim_turf) || !mode)
		to_chat(usr, span_warning("Ошибка: не выбрана цель или режим!"))
		return FALSE

	var/turf/target_turf
	var/list/affected_mobs = list()

	if(mode == "По игроку" && victim_mob)
		target_turf = get_turf(victim_mob)
		if(!target_turf)
			to_chat(usr, span_warning("Ошибка: не удалось найти местоположение игрока!"))
			return FALSE
		affected_mobs += victim_mob
		victim_mob.visible_message(span_danger("В воздухе разливается металлический привкус, а волосы на затылке встают дыбом..."),
				span_userdanger("Вы чувствуете что-то не ладное, в воздухе разливается металлический привкус и волосы встают дыбом..."))
	else if(mode == "По координатам" && victim_turf)
		target_turf = victim_turf

	if(!target_turf)
		to_chat(usr, span_warning("Ошибка: не удалось определить целевую область!"))
		return FALSE

	if(radius > 0)
		for(var/mob/living/_mob in range(radius, target_turf))
			if(_mob in affected_mobs)
				continue
			affected_mobs += _mob
			to_chat(_mob, span_userdanger("Вы чувствуете что-то не ладное, в воздухе разливается металлический привкус и волосы встают дыбом..."))

	spawn(delay SECONDS)
		if(mode == "По игроку" && victim_mob)
			target_turf = get_turf(victim_mob)
			if(!target_turf)
				return

		target_turf.spawn_lightning_bolt(damage <= 0)

		for(var/mob/living/_mob in affected_mobs)
			if(mode == "По координатам" && get_dist(_mob, target_turf) > radius)
				continue
			if(mode == "По игроку")
				affected_mobs = list()
				for(var/mob/living/nearby_mob in range(radius, target_turf))
					affected_mobs += nearby_mob

			_mob.Jitter(10 SECONDS)
			_mob.apply_damage(damage, BURN)

		log_admin("[key_name(usr)] dropped lightning bolt at [target_turf] with damage=[damage], radius=[radius], delay=[delay]")
		message_admins("[key_name_admin(usr)] dropped lightning bolt at [ADMIN_COORDJMP(target_turf)] with damage=[damage], radius=[radius], delay=[delay]")

// _________________________________________CLICK HANDLER_________________________________________
/datum/click_intercept/lightning_bolt_dropper
	var/datum/drop_lightning_bolt_ui/dropper = null

/datum/click_intercept/lightning_bolt_dropper/New(client/C, datum/drop_lightning_bolt_ui/datum)
	..()
	dropper = datum
	holder.mouse_up_icon = 'icons/effects/mouse_pointers/supplypod_pickturf.dmi' //Icon for when mouse is released
	holder.mouse_down_icon = 'icons/effects/mouse_pointers/supplypod_pickturf_down.dmi' //Icon for when mouse is pressed
	holder.mouse_override_icon = holder.mouse_up_icon //Icon for idle mouse (same as icon for when released)
	holder.mouse_pointer_icon = holder.mouse_override_icon

/datum/click_intercept/lightning_bolt_dropper/Destroy()
	holder.mouse_up_icon = null
	holder.mouse_down_icon = null
	holder.mouse_override_icon = null
	holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)
	return ..()

/datum/click_intercept/lightning_bolt_dropper/InterceptClickOn(mob/user, params, atom/object)
	if(!dropper || !dropper.pointing)
		return FALSE

	if(istype(object, /atom/movable/screen))
		return FALSE

	if(ismob(object))
		dropper.victim_mob = object
		dropper.victim_turf = null
		dropper.mode = "По игроку"
	else
		dropper.victim_turf = get_turf(object)
		dropper.victim_mob = null
		dropper.mode = "По координатам"

	dropper.lightning_bolt()
	user.face_atom(object)

	dropper.mode = "По указателю"
	return TRUE
