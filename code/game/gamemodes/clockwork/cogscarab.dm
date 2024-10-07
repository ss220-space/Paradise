#define WINDUP_STATE_NONE 0
#define WINDUP_STATE_WARNING 1
#define WINDUP_STATE_DANGER 2

// Little Coggy Droney!
/mob/living/silicon/robot/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "drone"
	health = 35
	maxHealth = 35
	density = FALSE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE

	speak_emote = list("clanks", "clinks", "clunks", "clangs")
	tts_seed = "Earth"
	speak_statement = "clinks"
	speak_exclamation = "proclaims"
	speak_query = "requests"
	bubble_icon = "clock"
	braintype = "Clockwork"

	lawupdate = FALSE
	scrambledcodes = TRUE
	has_camera = FALSE
	viewalerts = FALSE
	modules_break = FALSE

	req_access = list(ACCESS_CENT_COMMANDER) //I dare you to try
	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD)

	pull_force = MOVE_FORCE_VERY_WEAK // Can only drag small items
	holder_type = /obj/item/holder/cogscarab
	lamp_max = 5

	var/static/list/allowed_bumpable_objects = list(/obj/machinery/door, /obj/machinery/disposal/deliveryChute, /obj/machinery/teleport/hub, /obj/effect/portal, /obj/structure/transit_tube/station)

	var/list/pullable_items = list(
		/obj/item/pipe,
		/obj/structure/disposalconstruct,
		/obj/item/stack/cable_coil,
		/obj/item/stack/rods,
		/obj/item/stack/sheet,
		/obj/item/stack/tile,
		/obj/item/clockwork
	)

	var/wind_up_timer = CLOCK_MAX_WIND_UP_TIMER
	var/wind_up_icon_segment = CLOCK_MAX_WIND_UP_TIMER / 5
	var/warn_wind_up = WINDUP_STATE_NONE
	var/obj/structure/clockwork/functional/cogscarab_fabricator/fabr

/mob/living/silicon/robot/cogscarab/Initialize(mapload)
	. = ..()
	remove_language(LANGUAGE_BINARY)
	add_language(LANGUAGE_DRONE_BINARY, 1)
	if(radio)
		radio.wires.cut(WIRE_RADIO_TRANSMIT)

	//Shhhh it's a secret. No one needs to know about infinite power for clockwork drone
	cell = new /obj/item/stock_parts/cell/high/slime(src)
	mmi = null
	remove_verb(src, /mob/living/silicon/robot/verb/Namepick)
	module = new /obj/item/robot_module/cogscarab(src)

	var/datum/action/innate/hide/drone/cogscarab/hide = new()
	hide.Grant(src)

	if(!isclocker(src))
		SSticker.mode.add_clocker(mind)

	update_icons()


/mob/living/silicon/robot/drone/Destroy()
	for(var/datum/action/innate/hide/drone/cogscarab/hide in actions)
		hide.Remove(src)
	. = ..()

/mob/living/silicon/robot/cogscarab/add_strippable_element()
	return

/mob/living/silicon/robot/cogscarab/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/ratvar()
	set_connected_ai(null)

	aiCamera = new/obj/item/camera/siliconcam/drone_camera(src)
	additional_law_channels["Drone"] = get_language_prefix(LANGUAGE_DRONE_BINARY)

	playsound(loc, 'sound/machines/twobeep.ogg', 50, FALSE)

/mob/living/silicon/robot/cogscarab/create_mob_hud()
	..()
	if(hud_used)
		var/datum/hud/hud = hud_used
		if(!hud.wind_up_timer)
			hud.wind_up_timer = new /atom/movable/screen/wind_up_timer()
			hud.infodisplay += hud.wind_up_timer
			hud.show_hud(hud.hud_version)

/mob/living/silicon/robot/cogscarab/Life(seconds, times_fired)
	..()
	if(wind_up_timer > CLOCK_MAX_WIND_UP_TIMER/2)
		warn_wind_up = WINDUP_STATE_NONE
	else
		if(!warn_wind_up)
			to_chat(src, "<span class='warning'>You feel how your cogs inside slowing down! You need to find beacon to rewind yourself!</span>")
			warn_wind_up = WINDUP_STATE_WARNING


	if(wind_up_timer <= 0)
		if(wind_up_timer < 0)
			wind_up_timer = 0
		if(warn_wind_up < WINDUP_STATE_DANGER)
			to_chat(src, "<span class='userdanger'>The gears inside stopped to work! Find the beacon!</span>")
			warn_wind_up = WINDUP_STATE_DANGER
		adjustBruteLoss(2)
	else
		wind_up_timer -= seconds
	hud_used?.wind_up_timer?.icon_state = "windup_display-[6-(round(wind_up_timer, wind_up_icon_segment) / wind_up_icon_segment)]"
	//rounds to 30 and divides by 30. if timer full, 6 - 5, state 1. from 1 to 6.


/mob/living/silicon/robot/cogscarab/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(mind?.current)
		status_tab_data[++status_tab_data.len] = list("Wind Up Timer:", "[wind_up_timer]")

/mob/living/silicon/robot/cogscarab/rename_character(oldname, newname)
	// force it to not actually change most things
	return ..(newname, newname)

/mob/living/silicon/robot/cogscarab/get_default_name()
	return "cogscarab [pick(list("Nycun", "Oenib", "Havsbez", "Ubgry", "Fvreen"))]-[rand(10, 99)]"

/mob/living/silicon/robot/cogscarab/update_icons()
	cut_overlays()

	if(stat == CONSCIOUS)
		add_overlay("eyes-[icon_state]")

	if(blocks_emissive)
		add_overlay(get_emissive_block())


/mob/living/silicon/robot/cogscarab/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/borg/upgrade))
		return ATTACK_CHAIN_BLOCKED
	return ..()


/mob/living/silicon/robot/cogscarab/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return

/mob/living/silicon/robot/cogscarab/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
		return TRUE
	return ..()

/mob/living/silicon/robot/cogscarab/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/cogscarab/H = new(loc)
	src.forceMove(H)
	H.name = name
	H.icon = icon
	H.w_class = WEIGHT_CLASS_TINY
	H.attack_hand(grabber)

	to_chat(grabber, "<span class='notice'>Вы подняли [src.name].")
	to_chat(src, "<span class='notice'>[grabber.name] поднял[genderize_ru(grabber.gender,"","а","о","и")] вас.</span>")
	grabber.status_flags |= PASSEMOTES

	return H

/mob/living/silicon/robot/cogscarab/choose_icon()
	return

/mob/living/silicon/robot/cogscarab/pick_module()
	return

/mob/living/silicon/robot/cogscarab/emag_act()
	return

/mob/living/silicon/robot/cogscarab/emp_act(severity)
	return

/mob/living/silicon/robot/cogscarab/ratvar_act(weak)
	if(!isclocker(src))
		SSticker.mode.add_clocker(mind)
	return

/mob/living/silicon/robot/cogscarab/allowed(obj/item/I) //No opening cover
	return FALSE


/mob/living/silicon/robot/cogscarab/updatehealth(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	set_health(maxHealth - (getBruteLoss() + getFireLoss() + (suiciding ? getOxyLoss() : 0)))
	update_stat("updatehealth([reason])", should_log)


/mob/living/silicon/robot/cogscarab/update_stat(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	if(health <= 0 && stat != DEAD)
		ghostize(TRUE)
		gib()
		log_debug("died of damage, trigger reason: [reason]")
		return
	return ..()


/mob/living/silicon/robot/cogscarab/death(gibbed)
	. = ..(gibbed)
	fabr?.close_slot(src)
	SSticker.mode.remove_clocker(mind, FALSE)
	adjustBruteLoss(health)

/mob/living/silicon/robot/cogscarab/Bump(atom/bumped_atom)
	if(is_type_in_list(bumped_atom, allowed_bumpable_objects))
		return ..()

/mob/living/silicon/robot/cogscarab/start_pulling(atom/movable/pulled_atom, state, force = pull_force, supress_message = FALSE)
	if(is_type_in_list(pulled_atom, pullable_items))
		force = INFINITY	// Drone power! Makes them able to drag pipes and such
		return ..()

	if(isitem(pulled_atom))
		var/obj/item/pulled_item = pulled_atom
		if(pulled_item.w_class > WEIGHT_CLASS_SMALL)
			if(!supress_message)
				to_chat(src, span_warning("You are too small to pull that."))
			return FALSE
		return ..()

	if(!supress_message)
		to_chat(src, span_warning("You are too small to pull that."))
	return FALSE


/mob/living/silicon/robot/cogscarab/add_robot_verbs()
	add_verb(src, silicon_subsystems)

/mob/living/silicon/robot/cogscarab/remove_robot_verbs()
	remove_verb(src, silicon_subsystems)

/mob/living/silicon/robot/cogscarab/toggle_sensor_mode()
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in list("Medical","Diagnostic", "Multisensor","Disable")
	remove_med_sec_hud()
	switch(sensor_type)
		if("Medical")
			add_med_hud()
			to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
		if("Diagnostic")
			add_diag_hud()
			to_chat(src, "<span class='notice'>Robotics diagnostic overlay enabled.</span>")
		if("Multisensor")
			add_med_hud()
			add_diag_hud()
			to_chat(src, "<span class='notice'>Multisensor overlay enabled.</span>")
		if("Disable")
			to_chat(src, "Sensor augmentations disabled.")


/mob/living/silicon/robot/cogscarab/get_access()
	return list() //none cause from gears.

/mob/living/silicon/robot/cogscarab/flash_eyes(intensity, override_blindness_check, affect_silicon, visual, type)
	return

/mob/living/silicon/robot/cogscarab/use_power() //it's made of gears...
	return

/mob/living/silicon/robot/cogscarab/verb/light()
	set name = "Light On/Off"
	set desc = "Activate a low power omnidirectional LED. Toggled on or off."
	set category = "Cogscarab"

	if(lamp_intensity)
		lamp_intensity = lamp_max // setting this to lamp_max will make control_headlamp shutoff the lamp
	control_headlamp()

/mob/living/silicon/robot/cogscarab/control_headlamp()
	if(stat || lamp_recharging || low_power_mode)
		to_chat(src, "<span class='danger'>This function is currently offline.</span>")
		return

//Some sort of magical "modulo" thing which somehow increments lamp power by 2, until it hits the max and resets to 0.
	lamp_intensity = (lamp_intensity+1) % (lamp_max+1)
	to_chat(src, "[lamp_intensity ? "Headlamp power set to Level [lamp_intensity]" : "Headlamp disabled."]")
	update_headlamp()

/obj/item/clockwork/brassmaker
	name = "Brassmaking melter"
	desc = "A machine, spinning and whirring just to create out of thin metal into perfect brass."
	icon_state = "brassmaker"

	var/metal_amount = 0
	var/metal_need_per_brass = 8000 //4 metal for one brass
	var/melt_click_delay = 1.5 //multiplies usual delay of clicking
	var/list/grabbed_items = list()
	var/grab_limit = 30 // limits of how much you can take

/obj/item/clockwork/brassmaker/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity) return //Not adjacent.

	//We only want to deal with using this on turfs. Specific items aren't important.
	var/turf/T = get_turf(target)
	if(!istype(T))
		return

	var/grabbed_something = FALSE
	for(var/obj/item/A in T)
		if(LAZYIN(A.materials, MAT_METAL) && !anchored && (length(grabbed_items) < grab_limit))
			grabbed_items += A
			A.forceMove(src)
			grabbed_something = TRUE

	if(grabbed_something)
		to_chat(user, "<span class='notice'>You deploy your melter and take some contents to melt from \the [T].</span>")
	else
		to_chat(user, "<span class='warning'>Nothing on \the [T] is useful to you.</span>")

	return

/obj/item/clockwork/brassmaker/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It has [length(grabbed_items)] items ready to be melted, and [round(metal_amount/metal_need_per_brass, 0.01)] brass.</span>"

/obj/item/clockwork/brassmaker/attack_self(mob/user)
	. = ..()
	if(!length(grabbed_items))
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	to_chat(user, "<span class='notice'>You begin to melt everything you've picked up.</span>")
	user.playsound_local(src, 'sound/machines/blender.ogg', 20, 1)
	for(var/obj/item/A in grabbed_items)
		if(A.materials[MAT_METAL])
			if(isstack(A))
				var/obj/item/stack/S = A
				metal_amount += S.materials[MAT_METAL] * S.amount
			else
				metal_amount += A.materials[MAT_METAL]

	user.changeNext_move(attack_speed * melt_click_delay)
	QDEL_LIST(grabbed_items)

	if(isrobot(user))
		var/mob/living/silicon/robot/robot = user
		var/obj/item/stack/sheet/brass/cyborg/stack_brass = locate() in robot.module
		var/brass_melted = FLOOR(metal_amount / metal_need_per_brass, 1)
		metal_amount -= brass_melted * metal_need_per_brass
		if(!stack_brass)
			stack_brass = new /obj/item/stack/sheet/brass/cyborg(robot.module, null, FALSE)
			robot.module.modules += stack_brass
			robot.module.fix_modules()
			robot.module.handle_storages()
		stack_brass.add(brass_melted)

#undef WINDUP_STATE_NONE
#undef WINDUP_STATE_WARNING
#undef WINDUP_STATE_DANGER
