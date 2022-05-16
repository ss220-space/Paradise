/mob/living/simple_animal/hostile/clockwork
	icon = 'icons/mob/clockwork_mobs.dmi'

/mob/living/simple_animal/hostile/clockwork/marauder
	name = "clockwork marauder"
	desc = "The stalwart apparition of a soldier, blazing with crimson flames. It's armed with a gladius and shield."
	icon_state = "marauder"
	health = 200
	maxHealth = 200
	force_threshold = 8
	melee_damage_lower = 18
	melee_damage_upper = 18
	obj_damage = 40
	speed = 0
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	pressure_resistance = 100
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	see_in_dark = 8
	flying = TRUE
	pass_flags = PASSTABLE
	AIStatus = AI_OFF // Usually someone WILL play for him but i don't know about this on chief.
	loot = list(/obj/item/clockwork/component/geis_capacitor/fallen_armor)
	del_on_death = TRUE
	deathmessage = "shatters as the flames goes out."
	light_range = 2
	light_power = 1.1
	var/deflect_chance = 40

/mob/living/simple_animal/hostile/clockwork/marauder/hostile
	AIStatus = AI_ON

/mob/living/simple_animal/hostile/clockwork/marauder/FindTarget(list/possible_targets, HasTargetsList)
	. = list()
	if(!HasTargetsList)
		possible_targets = ListTargets()
	for(var/pos_targ in possible_targets)
		var/atom/A = pos_targ
		if(Found(A))
			. = list(A)
			break
		if(CanAttack(A) && !isclocker(A))//Can we attack it? And no biting our friends!!
			. += A
			continue
	var/Target = PickTarget(.)
	GiveTarget(Target)
	return Target

/mob/living/simple_animal/hostile/clockwork/marauder/bullet_act(obj/item/projectile/P)
	if(deflect_projectile(P))
		return
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/proc/deflect_projectile(obj/item/projectile/P)
	var/final_deflection_chance = deflect_chance
	var/energy_projectile = istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam)
	if(P.nodamage || P.damage_type == STAMINA)
		final_deflection_chance = 100
	else if(!energy_projectile) //Flat 40% chance against energy projectiles; ballistic projectiles are 40% - (damage of projectile)%, min. 10%
		final_deflection_chance = max(10, deflect_chance - P.damage)
	if(prob(final_deflection_chance))
		visible_message("<span class='danger'>[src] deflects [P] with their shield!</span>", \
		"<span class='danger'>You block [P] with your shield!</span>")
		if(energy_projectile)
			playsound(src, 'sound/weapons/effects/searwall.ogg', 50, TRUE)
		else
			playsound(src, "ricochet", 50, TRUE)
		return TRUE

// Little Coggy Droney!
/mob/living/silicon/robot/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "drone"
	health = 50
	maxHealth = 50
	speed = 0
	speak_emote = list("clanks", "clinks", "clunks", "clangs")
	speak_statement = list("clanks", "clinks", "clunks", "clangs")
	speak_exclamation = list("proclaims","harangues")
	speak_query = "requests"
	bubble_icon = "clock"
	pass_flags = PASSTABLE
	braintype = "Clockwork"
	lawupdate = 0
	density = 0
	has_camera = FALSE
	lamp_max = 5
	req_one_access = list(ACCESS_CENT_COMMANDER) //I dare you to try
	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD)
	ventcrawler = 2
	magpulse = 1
	emagged = TRUE
	mob_size = MOB_SIZE_SMALL
	pull_force = MOVE_FORCE_VERY_WEAK // Can only drag small items
	modules_break = FALSE
	holder_type = /obj/item/holder/cogscarab

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


/mob/living/silicon/robot/cogscarab/New()
	..()
	remove_language("Robot Talk")
	if(radio)
		radio.wires.cut(WIRE_RADIO_TRANSMIT)

	//Shhhh it's a secret. No one needs to know about infinite power for clockwork drone
	cell = new /obj/item/stock_parts/cell/high/slime(src)
	mmi = null
	verbs -= /mob/living/silicon/robot/verb/Namepick
	module = new /obj/item/robot_module/cogscarab(src)

	if(!isclocker(src))
		message_admins("[src]([ADMIN_QUE(src, "?")]) ([ADMIN_FLW(src,"FLW")]) has been created, but isn't a clocker! Possible adminspawn.")

	update_icons()

/mob/living/silicon/robot/cogscarab/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/ratvar()
	connected_ai = null

	aiCamera = new/obj/item/camera/siliconcam/drone_camera(src)
	additional_law_channels["Drone"] = ":d"

	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)

/mob/living/silicon/robot/cogscarab/rename_character(oldname, newname)
	// force it to not actually change most things
	return ..(newname, newname)

/mob/living/silicon/robot/cogscarab/get_default_name()
	return "cogscarab [pick(list("Nycun", "Oenib", "Havsbez", "Ubgry", "Fvreen"))]-[rand(10, 99)]"

/mob/living/silicon/robot/cogscarab/update_icons()
	overlays.Cut()
	if(stat == CONSCIOUS)
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"

/mob/living/silicon/robot/cogscarab/attackby(obj/item/W, mob/user, params)
	if(user.a_intent != INTENT_HELP)
		return

	if(istype(W, /obj/item/borg/upgrade/))
		return

	else if(istype(W, /obj/item/crowbar))
		return

	else if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda))
		return

	return ..()

/mob/living/silicon/robot/cogscarab/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
		return TRUE
	return ..()

/mob/living/silicon/robot/cogscarab/choose_icon()
	return

/mob/living/silicon/robot/cogscarab/pick_module()
	return

/mob/living/silicon/robot/cogscarab/emag_act()
	return

/mob/living/silicon/robot/emp_act(severity)
	return

/mob/living/silicon/robot/cogscarab/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = 50
		stat = CONSCIOUS
		return
	health = 50 - (getBruteLoss() + getFireLoss())
	update_stat("updatehealth([reason])")

/mob/living/silicon/robot/cogscarab/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(health <= -maxHealth && stat != DEAD)
		gib()
		create_debug_log("died of damage, trigger reason: [reason]")
		return
	return ..(reason)


/mob/living/silicon/robot/cogscarab/death(gibbed)
	. = ..(gibbed)
	adjustBruteLoss(health)

/mob/living/silicon/robot/cogscarab/Bump(atom/movable/AM, yes)
	if(is_type_in_list(AM, allowed_bumpable_objects))
		return ..()

/mob/living/silicon/robot/cogscarab/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)

	if(is_type_in_list(AM, pullable_items))
		..(AM, force = INFINITY) // Drone power! Makes them able to drag pipes and such

	else if(istype(AM,/obj/item))
		var/obj/item/O = AM
		if(O.w_class > WEIGHT_CLASS_SMALL)
			if(show_message)
				to_chat(src, "<span class='warning'>You are too small to pull that.</span>")
			return
		else
			..()
	else
		if(show_message)
			to_chat(src, "<span class='warning'>You are too small to pull that.</span>")

/mob/living/silicon/robot/cogscarab/add_robot_verbs()
	src.verbs |= silicon_subsystems

/mob/living/silicon/robot/cogscarab/remove_robot_verbs()
	src.verbs -= silicon_subsystems

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

/mob/living/silicon/robot/cogscarab/verb/hide()
	set name = "Hide"
	set desc = "Allows you to hide beneath tables or certain items. Toggled on or off."
	set category = "Drone"

	if(layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

/mob/living/silicon/robot/cogscarab/verb/light()
	set name = "Light On/Off"
	set desc = "Activate a low power omnidirectional LED. Toggled on or off."
	set category = "Drone"

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

/mob/living/silicon/robot/cogscarab/update_headlamp(var/turn_off = 0, var/cooldown = 100)
	set_light(0)

	if(lamp_intensity && (turn_off || stat || low_power_mode))
		to_chat(src, "<span class='danger'>Your headlamp has been deactivated.</span>")
		lamp_intensity = 0
		lamp_recharging = 1
		spawn(cooldown) //10 seconds by default, if the source of the deactivation does not keep stat that long.
			lamp_recharging = 0
	else
		set_light(lamp_intensity)

	if(lamp_button)
		lamp_button.icon_state = "lamp[lamp_intensity*2]"

	update_icons()

/*MOUSE*/
/mob/living/simple_animal/mouse/clockwork
	name = "moaus"
	real_name = "moaus"
	desc = "A fancy clocked mouse. And it still squeeks!"
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "moaus"
	icon_living = "moaus"
	icon_dead = "moaus_dead"
	icon_resting = "moaus" // Need to make rest
	mouse_color = TRUE //Check mouse/New()
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	universal_speak = 1
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/clockwork/alloy_shards/medium/gear_bit = 1)

/mob/living/simple_animal/mouse/clockwork/handle_automated_action()
	if(isturf(loc))
		var/turf/simulated/floor/F = get_turf(src)
		if(istype(F) && !F.intact)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(30))
				if(C.avail())
					visible_message("<span class='warning'>[src] chews through [C]. [src] sparks for a moment!</span>")
					playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
				else
					visible_message("<span class='warning'>[src] chews through [C].</span>")
				investigate_log("was chewed through by a clock mouse in [get_area(F)]([F.x], [F.y], [F.z] - [ADMIN_JMP(F)])","wires")
				C.deconstruct()

/mob/living/simple_animal/mouse/clockwork/splat()
	return

/mob/living/simple_animal/mouse/clockwork/toast()
	return

/mob/living/simple_animal/mouse/clockwork/get_scooped(mob/living/carbon/grabber)
	to_chat(grabber, "<span class='warning'>You try to pick up [src], but they slip out of your grasp!</span>")
	to_chat(src, "<span class='warning'>[src] tries to pick you up, but you wriggle free of their grasp!</span>")

/mob/living/simple_animal/mouse/clockwork/decompile_act(obj/item/matter_decompiler/C, mob/user)
	return

/mob/living/simple_animal/mouse/clockwork/ratvar_act()
	return
