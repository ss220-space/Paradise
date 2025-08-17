#define MODE_CKEY			"По игроку"
#define MODE_POINTER		"По указателю"
#define WARNING_MESSAGE		span_userdanger("Вы чувствуете что-то не ладное, в воздухе разливается металлический привкус и волосы встают дыбом...")
#define DEFAULT_DAMAGE		100
#define DEFAULT_RADIUS		3
#define DEFAULT_DELAY		3

/client/proc/drop_lightning_bolt()
	set category = STATPANEL_ADMIN_FUN
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
	var/damage = DEFAULT_DAMAGE
	var/radius = DEFAULT_RADIUS
	var/delay = DEFAULT_DELAY
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

/datum/drop_lightning_bolt_ui/ui_static_data(mob/user)
	. = ..()

	.["ckey"] = "Выберите..."

	players = list()
	for(var/mob/player as anything in GLOB.player_list) // extra 'spaces  ' hell yea
		players[player.ckey] = "[player.real_name] | [player.ckey]  "
	.["players"] = players

/datum/drop_lightning_bolt_ui/ui_data(mob/user)
	. = ..()

	.["damage"] = damage
	.["radius"] = radius
	.["delay"] = delay
	.["mode"] = mode
	.["ckey"] = victim_mob.ckey
	.["pointing"] = pointing

/datum/drop_lightning_bolt_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("pick_player")
			var/ckey = params["ckey"]
			victim_mob = get_mob_by_ckey(ckey)
			victim_turf = null

		if("set_mode")
			mode = params["mode"]
			if(usr.client.click_intercept)
				qdel(usr.client.click_intercept)
				usr.client.click_intercept = null
			pointing = FALSE

		if("set_damage")
			damage = text2num(params["damage"])

		if("set_radius")
			radius = text2num(params["radius"])

		if("set_delay")
			delay = clamp(text2num(params["delay"]), 0, 1 MINUTES)

		if("drop")
			prepare_bolt()

		if("set_pointing")
			pointing = params["val"]

			if(!usr.client.click_intercept)
				usr.client.click_intercept = new /datum/click_intercept/lightning_bolt_dropper(usr.client, src)
			else
				QDEL_NULL(usr.client.click_intercept)

		else
			. = FALSE

/datum/drop_lightning_bolt_ui/ui_close(mob/user)
	if(!client || !client.click_intercept)
		return

	QDEL_NULL(client.click_intercept)
	qdel(src)

/datum/drop_lightning_bolt_ui/Destroy(force)

	client = null
	victim_mob = null
	victim_turf = null
	. = ..()

/datum/drop_lightning_bolt_ui/proc/prepare_bolt()
	if((!victim_mob && !victim_turf) || !mode)
		to_chat(usr, span_warning("Ошибка: не выбрана цель или режим!"))
		return FALSE

	var/turf/victim = get_turf(victim_mob) || victim_turf

	if(radius > 1)
		for(var/mob/living/_mob in range(radius, victim))
			to_chat(_mob, WARNING_MESSAGE)
	else if(victim_mob)
		to_chat(victim_mob, WARNING_MESSAGE)

	addtimer(CALLBACK(src, PROC_REF(drop_bolt), victim), delay SECONDS)

/datum/drop_lightning_bolt_ui/proc/drop_bolt(atom/victim)
	victim = get_turf(victim_mob) || victim_turf // yes, we need to update this
	new /obj/effect/temp_visual/thunderbolt/fancy/(victim, damage <= 10)

	for(var/mob/living/_mob in range(radius, victim))
		if(isobserver(_mob))
			continue
		_mob.Jitter(10 SECONDS)
		_mob.apply_damage(damage, BURN)
		_mob.updatehealth("admin lightning bolt")


	log_admin("[key_name(usr)] dropped lightning bolt at [victim] with damage=[damage], radius=[radius], delay=[delay]")
	message_admins("[key_name_admin(usr)] dropped lightning bolt at [ADMIN_COORDJMP(victim)] with damage=[damage], radius=[radius], delay=[delay]")

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

	dropper.prepare_bolt()
	user.face_atom(object)

	dropper.mode = MODE_POINTER
	return TRUE

#undef MODE_CKEY
#undef MODE_POINTER
#undef WARNING_MESSAGE
#undef DEFAULT_DAMAGE
#undef DEFAULT_RADIUS
#undef DEFAULT_DELAY
