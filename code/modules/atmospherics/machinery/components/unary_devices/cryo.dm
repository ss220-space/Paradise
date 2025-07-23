#define AUTO_EJECT_DEAD		(1<<0)
#define AUTO_EJECT_HEALTHY	(1<<1)
#define OCCUPANT_PIXEL_BOUNCE_HIGH 28
#define OCCUPANT_PIXEL_BOUNCE_LOW 22

/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	desc = "Медицинское устройство, представляющее из себя высокую капсулу, напичканную датчиками и сканерами. Судя по всему, она понижает температуру тела субъекта внутри."
	ru_names = list(
		NOMINATIVE = "криогенная капсула",
		GENITIVE = "криогенной капсулы",
		DATIVE = "криогенной капсуле",
		ACCUSATIVE = "криогенную капсулу",
		INSTRUMENTAL = "криогенной капсулой",
		PREPOSITIONAL = "криогенной капсуле"
	)
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "pod0"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	resistance_flags = null
	interact_offline = 1
	max_integrity = 350
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 30, "acid" = 30)
	on = FALSE
	vent_movement = VENTCRAWL_CAN_SEE
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING
	light_color = LIGHT_COLOR_WHITE
	var/temperature_archived
	var/mob/living/carbon/occupant
	/// A separate effect for the occupant, as you can't animate overlays reliably and constantly removing and adding overlays is spamming the subsystem.
	var/obj/effect/occupant_overlay
	var/obj/item/reagent_containers/glass/beaker
	var/reagent_transfer = 0
	/// Holds two bitflags, AUTO_EJECT_DEAD and AUTO_EJECT_HEALTHY. Used to determine if the cryo cell will auto-eject dead and/or completely health patients.
	var/volume = 100
	var/auto_eject_prefs = NONE
	var/sleep_factor = 750
	var/paralyze_factor = 1000

	var/next_trans = 0
	var/current_heat_capacity = 50
	var/efficiency
	var/heat_capacity = 100000
	var/conduction_coefficient = 0.01

	var/running_bob_animation = 0 // This is used to prevent threads from building up if update_icons is called multiple times


/obj/machinery/atmospherics/components/unary/cryo_cell/power_change(forced = FALSE)
	..()
	if(stat & (BROKEN|NOPOWER))
		set_light_on(FALSE)
	else
		set_light(2)


/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)
	. = ..()
	if(occupant)
		if(occupant.is_dead())
			. += span_warning("Вы видите гуманоида внутри. Это [occupant.name]. [genderize_ru(occupant.gender, "Он мёртв", "Она мертва", "Оно мертво", "Они мертвы")]!")
		else
			. += span_notice("Вы видите гуманоида внутри. Это [occupant.name].")
	if(Adjacent(user))
		. += span_notice("Наведите курсор на пациента, зажмите <b>ЛКМ</b> и перетяните на [declent_ru(ACCUSATIVE)], чтобы поместить пациента внутрь.")


/obj/machinery/atmospherics/components/unary/cryo_cell/New()
	..()
	initialize_directions = dir
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/components/unary/cryo_cell/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/components/unary/cryo_cell/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		C += M.rating
	efficiency = initial(efficiency) * C
	sleep_factor = initial(sleep_factor) * C
	paralyze_factor = initial(paralyze_factor) * C
	heat_capacity = initial(heat_capacity) / C
	conduction_coefficient = initial(conduction_coefficient) * C

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(occupant_overlay)
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/atmos_init()
	..()
	if(NODE1)
		return
	for(var/cdir in GLOB.cardinal)
		NODE1 = find_connecting(cdir)
		if(NODE1)
			break

/obj/machinery/atmospherics/components/unary/cryo_cell/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	if(beaker)
		beaker.ex_act(severity)
	..()

/obj/machinery/atmospherics/components/unary/cryo_cell/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		updateUsrDialog()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/on_deconstruction()
	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null

/obj/machinery/atmospherics/components/unary/cryo_cell/MouseDrop_T(atom/movable/O, mob/living/user, params)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //are you cuffed, dying, lying, stunned or other
		return
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(isanimal(O) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		balloon_alert(user, "внутри кто-то есть!")
		return TRUE
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		balloon_alert(user, "руки субъекта заняты!")
		return TRUE
	if(L.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[L] не помест[pluralize_ru(L.gender, "ит", "ят")]ся в [declent_ru(ACCUSATIVE)], пока на [genderize_ru(L.gender, "нём", "ней", "нём", "них")] сидит слайм!"))
		return TRUE
	. = TRUE
	if(put_mob(L))
		if(L == user)
			visible_message("[user] начинает[pluralize_ru(user.gender,"ет","ют")] залезать в [declent_ru(ACCUSATIVE)].")
		else
			visible_message("[user] начина[pluralize_ru(user.gender,"ет","ют")] укладывать [L] в [declent_ru(ACCUSATIVE)].")
			add_attack_logs(user, L, "put into a cryo cell at [COORD(src)].", ATKLOG_ALL)
			if(user.pulling == L)
				user.stop_pulling()
		SStgui.update_uis(src)

/obj/machinery/atmospherics/components/unary/cryo_cell/process()
	..()
	if(!on)
		return

	var/datum/gas_mixture/air1 = AIR1

	if(occupant)
		auto_eject_check()
		if(occupant.bodytemperature < T0C) // Sleepytime. Why? More cryo magic.
			occupant.Sleeping((occupant.bodytemperature / sleep_factor) * 100)
			occupant.Paralyse((occupant.bodytemperature / paralyze_factor) * 100)

		if(beaker)
			if(reagent_transfer == 0) // Magically transfer reagents. Because cryo magic.
				beaker.reagents.trans_to(occupant, 1, 10 * efficiency) // Transfer reagents, multiplied because cryo magic.
				beaker.reagents.reaction(occupant, REAGENT_VAPOR)
				air1.gases[GAS_O2][MOLES] -= 2 / efficiency // Lets use gas for this.
				air1.garbage_collect()

			if(++reagent_transfer == 10 * efficiency) // Throttle reagent transfer (higher efficiency will transfer the same amount but consume less from the beaker).
				reagent_transfer = 0

	return TRUE

/obj/machinery/atmospherics/components/unary/cryo_cell/process_atmos()
	..()

	if(!on)
		return

	var/datum/gas_mixture/air1 = AIR1

	if(!NODE1 || !air1 || air1.gases[GAS_O2][MOLES] < 5) // Turn off if the machine won't work.
		on = FALSE
		update_icon()
		return

	if(occupant)
		var/cold_protection = 0
		var/mob/living/carbon/human/H = occupant
		if(istype(H))
			cold_protection = H.get_cold_protection(air1.temperature)

		var/temperature_delta = air1.temperature - occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.
		if(abs(temperature_delta) > 1)
			var/air_heat_capacity = air1.heat_capacity()
			var/heat = ((1 - cold_protection) / 10 + conduction_coefficient) \
						* temperature_delta * \
						(air_heat_capacity * heat_capacity / (air_heat_capacity + heat_capacity))
			air1.temperature = max(air1.temperature - heat / air_heat_capacity, TCMB)
			occupant.bodytemperature = max(occupant.bodytemperature + heat / heat_capacity, TCMB)

		air1.gases[GAS_O2][MOLES] -= 0.5 / efficiency // Magically consume gas? Why not, we run on cryo magic.
		air1.garbage_collect()


/obj/machinery/atmospherics/components/unary/cryo_cell/proc/go_out()
	if(!occupant)
		return
	var/turf/drop_loc = get_step(loc, SOUTH)	//this doesn't account for walls or anything, but i don't forsee that being a problem.
	occupant.forceMove(drop_loc)
	occupant.set_bodytemperature(occupant.dna ? occupant.dna.species.body_temperature : BODYTEMP_NORMAL)
	occupant = null
	update_icon()
	// eject trash the occupant dropped
	for(var/atom/movable/thing in (contents - component_parts - beaker))
		thing.forceMove(drop_loc)

/obj/machinery/atmospherics/components/unary/cryo_cell/force_eject_occupant(mob/target)
	go_out()

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/auto_eject_check()
	if((auto_eject_prefs & AUTO_EJECT_DEAD) && occupant.stat == DEAD)
		auto_eject(AUTO_EJECT_DEAD)
		return

	if((auto_eject_prefs & AUTO_EJECT_HEALTHY) && !occupant.has_organic_damage() && !occupant.has_mutated_organs())
		auto_eject(AUTO_EJECT_HEALTHY)
		return


/// Called when either the occupant is dead and the AUTO_EJECT_DEAD flag is present, OR the occupant is alive, has no external damage, and the AUTO_EJECT_HEALTHY flag is present.
/obj/machinery/atmospherics/components/unary/cryo_cell/proc/auto_eject(eject_flag)
	on = FALSE
	go_out()
	switch(eject_flag)
		if(AUTO_EJECT_HEALTHY)
			playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
		if(AUTO_EJECT_DEAD)
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 40)
	SStgui.update_uis(src)


/obj/machinery/atmospherics/components/unary/cryo_cell/AllowDrop()
	return FALSE


/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/user)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/atmospherics/components/unary/cryo_cell/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/components/unary/cryo_cell/attack_hand(mob/user)
	if(..())
		return TRUE

	if(user == occupant)
		return

	if(panel_open)
		balloon_alert(usr, "техпанель открыта!")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cryo", "Криогенная капсула")
		ui.open()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_data(mob/user)
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? TRUE : FALSE
	var/datum/gas_mixture/air_contents = AIR1
	var/occupantData[0]
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = HEALTH_THRESHOLD_DEAD
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData

	data["cellTemperature"] = round(air_contents.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air_contents.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air_contents.temperature > TCRYO)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? TRUE : FALSE
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(beaker)
		data["beakerLabel"] = beaker.label_text ? beaker.label_text : null
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	data["auto_eject_healthy"] = (auto_eject_prefs & AUTO_EJECT_HEALTHY) ? TRUE : FALSE
	data["auto_eject_dead"] = (auto_eject_prefs & AUTO_EJECT_DEAD) ? TRUE : FALSE
	return data

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_act(action, params)
	if(..() || usr == occupant)
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(action)
		if("switchOn")
			on = TRUE
			update_icon()
		if("switchOff")
			on = FALSE
			update_icon()
		if("auto_eject_healthy_on")
			auto_eject_prefs |= AUTO_EJECT_HEALTHY
		if("auto_eject_healthy_off")
			auto_eject_prefs &= ~AUTO_EJECT_HEALTHY
		if("auto_eject_dead_on")
			auto_eject_prefs |= AUTO_EJECT_DEAD
		if("auto_eject_dead_off")
			auto_eject_prefs &= ~AUTO_EJECT_DEAD
		if("ejectBeaker")
			if(!beaker)
				return
			beaker.forceMove(get_step(loc, SOUTH))
			beaker = null
		if("ejectOccupant")
			if(!occupant || isslime(usr) || ispAI(usr))
				return
			add_attack_logs(usr, occupant, "ejected from cryo cell at [COORD(src)]", ATKLOG_ALL)
			go_out()
		else
			return FALSE

	add_fingerprint(usr)


/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		var/obj/item/reagent_containers/glass/glass = I
		if(beaker)
			balloon_alert(user, "слот для ёмкости занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(glass, src))
			return ..()
		beaker = glass
		add_attack_logs(user, null, "Added [glass] containing [glass.reagents.log_list()] to a cryo cell at [COORD(src)]")
		visible_message(span_notice("[user] вставля[pluralize_ru(user.gender,"ет","ют")] [glass] в [declent_ru(ACCUSATIVE)]."))
		balloon_alert(user, "ёмкость установлена")
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/atmospherics/components/unary/cryo_cell/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !ismob(grabbed_thing))
		return .
	if(panel_open)
		balloon_alert(grabber, "техпанель открыта!")
		return .
	if(occupant)
		balloon_alert(grabber, "внутри кто-то есть!")
		return .
	if(grabbed_thing.has_buckled_mobs()) //mob attached to us
		to_chat(grabber, span_warning("[grabbed_thing] не помест[pluralize_ru(grabbed_thing.gender, "ит", "ят")]ся в [declent_ru(ACCUSATIVE)], пока на [genderize_ru(grabbed_thing.gender, "нём", "ней", "нём", "них")] сидит слайм!"))
		return .
	if(put_mob(grabbed_thing))
		return


/obj/machinery/atmospherics/components/unary/cryo_cell/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return

/obj/machinery/atmospherics/components/unary/cryo_cell/screwdriver_act(mob/user, obj/item/I)
	if(occupant || on)
		balloon_alert(user, "машина работает!")
		return TRUE
	if(default_deconstruction_screwdriver(user, I = I))
		return TRUE


/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon()
	SET_PLANE_IMPLICIT(src, initial(plane))
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon_state()
	icon_state = !occupant ? "pod-open" : ((on && is_operational()) ? "pod-on" : "pod-off")
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/update_overlays()
	. = ..()
	if(panel_open)
		. += "pod-panel"

	var/is_operational = is_operational()

	var/cover_state = "cover-[on && is_operational ? "on" : "off"]"

	if(!occupant)
		. += cover_state //if no occupant, just put the lid overlay on, and ignore the rest
		return

	occupant_overlay = new(get_turf(src))
	occupant_overlay.icon = occupant.icon
	occupant_overlay.icon_state = occupant.icon_state
	occupant_overlay.overlays = occupant.overlays
	occupant_overlay.pixel_y = OCCUPANT_PIXEL_BOUNCE_LOW
	occupant_overlay.layer = layer + 0.01
	if(on && is_operational)
		animate(occupant_overlay, time = 3 SECONDS, loop = -1, easing = QUAD_EASING, pixel_y = OCCUPANT_PIXEL_BOUNCE_HIGH)
		animate(time = 3 SECONDS, loop = -1, easing = QUAD_EASING, pixel_y = OCCUPANT_PIXEL_BOUNCE_LOW)

	. += mutable_appearance(icon = icon, cover_state, ABOVE_ALL_MOB_LAYER, src, plane = ABOVE_GAME_PLANE)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/put_mob(mob/living/carbon/M)
	if(!istype(M))
		balloon_alert(usr, "невозможно!")
		return
	if(occupant)
		balloon_alert(usr, "внутри кто-то есть!")
		return
	if(M.abiotic())
		balloon_alert(usr, "руки субъекта заняты!")
		return
	if(!NODE1)
		balloon_alert(usr, "не подключено!")
		return

	add_fingerprint(usr)
	if(M == usr)
		visible_message("[usr] начина[pluralize_ru(usr.gender,"ет","ют")] залезать в [declent_ru(ACCUSATIVE)].")
	else
		visible_message("[usr] начина[pluralize_ru(usr.gender,"ет","ют")] укладывать [M] в [declent_ru(ACCUSATIVE)].")

	if(!do_after(usr, 2 SECONDS, M))
		return

	M.forceMove(src)
	if(M.health > -100 && (M.health < 0 || M.IsSleeping()))
		to_chat(M, span_boldnotice("Вас окружает холодная жидкость. Кожа начинает замерзать."))
	occupant = M
	update_icon(UPDATE_OVERLAYS)
	M.ExtinguishMob()
	return TRUE


/obj/machinery/atmospherics/components/unary/cryo_cell/click_alt(mob/living/carbon/user)
	go_out()
	add_fingerprint(user)
	return CLICK_ACTION_SUCCESS


/obj/machinery/atmospherics/components/unary/cryo_cell/container_resist(mob/living)
	if(usr.incapacitated()) // Check that they're able to open the tube.
		return
	to_chat(usr, span_notice("Вы начинаете шевелиться внутри [declent_ru(GENITIVE)], пиная ногой выпускной клапан."))
	audible_message(span_notice("Вы слышите стук от [declent_ru(GENITIVE)]."))
	addtimer(CALLBACK(src, PROC_REF(eject_occupant), living), 15 SECONDS)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/eject_occupant(mob/user)
	if(occupant && (user in src)) // Make sure they didn't disappear.
		return
	go_out()

/obj/machinery/atmospherics/components/unary/cryo_cell/verb/move_eject()
	set name = "Извлечь пациента"
	set category = STATPANEL_OBJECT
	set src in oview(1)

	if(usr == occupant)//If the user is inside the tube...
		if(usr.stat == DEAD)
			return
		to_chat(usr, span_notice("Активация протокола аварийного извлечения. Время ожидания: 15 секунд."))
		eject_occupant()//and release him from the eternal prison.
	else
		if(usr.default_can_use_topic(src) != UI_INTERACTIVE)
			return
		if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED)) //are you cuffed, dying, lying, stunned or other
			return
		add_attack_logs(usr, occupant, "Ejected from cryo cell at [COORD(src)]")
		go_out()
	add_fingerprint(usr)

/obj/machinery/atmospherics/components/unary/cryo_cell/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	color = "red"//force the icon to red
	light_color = LIGHT_COLOR_RED

/obj/machinery/atmospherics/components/unary/cryo_cell/ratvar_act()
	go_out()
	new /obj/effect/decal/cleanable/blood/gibs/clock(get_turf(src))
	qdel(src)

/obj/machinery/atmospherics/components/unary/cryo_cell/verb/move_inside()
	set name = "Залезть внутрь"
	set category = STATPANEL_OBJECT
	set src in oview(1)

	if(usr.has_buckled_mobs()) //mob attached to us
		to_chat(usr, span_warning("Вы не поместитесь в [declent_ru(ACCUSATIVE)], пока на вас сидит слайм."))
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.buckled) //are you cuffed, dying, lying, stunned or other
		return

	put_mob(usr)
	return



/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user)
	return

/datum/data/function/proc/display()
	return

/obj/machinery/atmospherics/components/unary/cryo_cell/get_remote_view_fullscreens(mob/user)
	user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/machinery/atmospherics/components/unary/cryo_cell/update_remote_sight(mob/living/user)
	return //we don't see the pipe network while inside cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/can_see_pipes()
	return FALSE // you can't see the pipe network when inside a cryo cell.

#undef AUTO_EJECT_HEALTHY
#undef AUTO_EJECT_DEAD
#undef OCCUPANT_PIXEL_BOUNCE_HIGH
#undef OCCUPANT_PIXEL_BOUNCE_LOW

