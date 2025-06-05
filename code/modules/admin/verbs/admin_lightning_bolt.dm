#define MODE_CKEY 	 "По игроку"
#define MODE_COORDS  "По координатам"
#define MODE_POINTER "По указателю"

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

// _________________________________________TGUI_________________________________________
/datum/drop_lightning_bolt_ui
	var/client/client = null
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
		client = user.client
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
	for(var/mob/player as anything in GLOB.player_list) // extra 'spaces  ' hell yea
		players[player.ckey] = "[player.real_name] | [player.ckey]  "
	.["players"] = players

/datum/drop_lightning_bolt_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("pick_player")
			var/ckey = params["ckey"]
			victim_mob = get_mob_by_ckey(ckey)
			victim_turf = null
		if("set_autoupdate")
			ui.set_autoupdate(params["val"])
			if(ui.autoupdate)
				victim_turf = locate(text2num(params["x_coord"]), text2num(params["y_coord"]), text2num(params["z_coord"]))
		if("set_mode")
			mode = params["mode"]
			if(mode == MODE_COORDS)
				victim_turf = null
			if(usr.client.click_intercept)
				qdel(usr.client.click_intercept)
				usr.client.click_intercept = null
			pointing = FALSE
		if("set_coords")
			victim_turf = locate(text2num(params["x_coord"]), text2num(params["y_coord"]), text2num(params["z_coord"]))
			victim_mob = null
			mode = MODE_COORDS
		if("set_damage")
			damage = text2num(params["damage"])
		if("set_radius")
			radius = text2num(params["radius"])
		if("set_delay")
			delay = clamp(text2num(params["delay"]), 0, 60) //  Добавлено ограничение
		if("drop")
			if(!victim_mob && !victim_turf)
				if(mode == MODE_COORDS)
					victim_turf = locate(usr.x, usr.y, usr.z)
				else
					return
			else if(ui.autoupdate)
				victim_turf = locate(usr.x, usr.y, usr.z)

			lightning_bolt()
		if("set_pointing")
			pointing = params["val"]
			if(!usr.client.click_intercept)
				usr.client.click_intercept = new /datum/click_intercept/lightning_bolt_dropper(usr.client, src)
			else
				qdel(usr.client.click_intercept)
				usr.client.click_intercept = null
		else
			. = FALSE

/datum/drop_lightning_bolt_ui/ui_close(mob/user)
	if(!client || !client.click_intercept)
		return

	qdel(client.click_intercept)
	client.click_intercept = null

/datum/drop_lightning_bolt_ui/proc/lightning_bolt()
	if((!victim_mob && !victim_turf) || !mode)
		to_chat(usr, span_warning("Ошибка: не выбрана цель или режим!"))
		return FALSE

	var/turf/target_turf
	var/list/affected_mobs = list()

	if(mode == MODE_CKEY && victim_mob)
		target_turf = get_turf(victim_mob)
		if(!target_turf)
			to_chat(usr, span_warning("Ошибка: не удалось найти местоположение игрока!"))
			return FALSE
		affected_mobs += victim_mob
		victim_mob.visible_message(span_danger("В воздухе разливается металлический привкус, а волосы на затылке встают дыбом..."),
				span_userdanger("Вы чувствуете что-то не ладное, в воздухе разливается металлический привкус и волосы встают дыбом..."))
	else if(mode == MODE_COORDS && victim_turf)
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

	addtimer(CALLBACK(src, PROC_REF(lightning_bolt_part_2), target_turf, affected_mobs), delay SECONDS)

/datum/drop_lightning_bolt_ui/proc/lightning_bolt_part_2(turf/target_turf, list/affected_mobs)
	// Обновляем позицию если цель - игрок (он мог переместиться)
	if(mode == MODE_CKEY && victim_mob)
		target_turf = get_turf(victim_mob)
		if(!target_turf)
			return

	new /obj/effect/temp_visual/thunderbolt/fancy/(target_turf, damage <= 0)
	for(var/mob/living/_mob as anything in affected_mobs)
		if(mode == MODE_COORDS && get_dist(_mob, target_turf) > radius || isobserver(_mob))
			continue
		if(mode == MODE_CKEY)
			affected_mobs = list()
			for(var/mob/living/nearby_mob in range(radius, target_turf))
				affected_mobs += nearby_mob

		_mob.Jitter(10 SECONDS)
		_mob.apply_damage(damage, BURN)
		_mob.updatehealth("admin lightning bolt")

	log_admin("[key_name(usr)] dropped lightning bolt at [target_turf] with damage=[damage], radius=[radius], delay=[delay]")
	message_admins("[key_name_admin(usr)] dropped lightning bolt at [ADMIN_COORDJMP(target_turf)] with damage=[damage], radius=[radius], delay=[delay]")

// _________________________________________CLICK HANDLER_________________________________________
/datum/click_intercept/lightning_bolt_dropper
	var/datum/drop_lightning_bolt_ui/dropper = null
	var/icon/mouse_up_icon = 'icons/effects/mouse_pointers/supplypod_pickturf.dmi'
	var/icon/mouse_down_icon = 'icons/effects/mouse_pointers/supplypod_pickturf_down.dmi'

/datum/click_intercept/lightning_bolt_dropper/New(client/C, datum/drop_lightning_bolt_ui/datum)
	..()
	dropper = datum
	holder.mouse_up_icon = mouse_up_icon
	holder.mouse_down_icon = mouse_down_icon
	holder.mouse_override_icon = holder.mouse_up_icon
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

	if(is_screen_atom(object))
		return FALSE

	if(ismob(object))
		dropper.victim_mob = object
		dropper.victim_turf = null
		dropper.mode = MODE_CKEY
	else
		dropper.victim_turf = get_turf(object)
		dropper.victim_mob = null
		dropper.mode = MODE_COORDS

	dropper.lightning_bolt()
	user.face_atom(object)

	dropper.mode = MODE_POINTER
	return TRUE

#undef MODE_CKEY
#undef MODE_COORDS
#undef MODE_POINTER
