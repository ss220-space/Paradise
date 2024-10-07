/obj/machinery/chem_heater
	name = "chemical heater"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF|ACID_PROOF
	var/obj/item/reagent_containers/beaker = null
	var/desired_temp = T0C
	var/on = FALSE
	/// Whether this should auto-eject the beaker once done heating/cooling.
	var/auto_eject = FALSE
	/// The higher this number, the faster reagents will heat/cool.
	var/speed_increase = 0

/obj/machinery/chem_heater/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_heater(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/chem_heater/RefreshParts()
	speed_increase = initial(speed_increase)
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		speed_increase += 5 * (M.rating - 1)

/obj/machinery/chem_heater/process()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(on)
		if(beaker)
			if(!beaker.reagents.total_volume)
				on = FALSE
				return
			beaker.reagents.temperature_reagents(desired_temp, max(1, 35 - speed_increase))
			if(round(beaker.reagents.chem_temp) == round(desired_temp))
				playsound(loc, 'sound/machines/ding.ogg', 50, 1)
				on = FALSE
				if(auto_eject)
					eject_beaker()


/obj/machinery/chem_heater/update_icon_state()
	icon_state = "mixer[beaker ? "1" : "0"]b"



/obj/machinery/chem_heater/proc/eject_beaker(mob/user)
	if(beaker)
		beaker.forceMove(get_turf(src))
		if(user && Adjacent(user) && !issilicon(user))
			user.put_in_hands(beaker, ignore_anim = FALSE)
		beaker = null
		on = FALSE
		update_icon(UPDATE_ICON_STATE)
		SStgui.update_uis(src)


/obj/machinery/chem_heater/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		SStgui.update_uis(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		if(beaker)
			to_chat(user, span_warning("The [name] already has [beaker] loaded."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		beaker = I
		to_chat(user, span_notice("You have inserted [I] into [src]."))
		SStgui.update_uis(src)
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/chem_heater/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/chem_heater/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I)

/obj/machinery/chem_heater/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	eject_beaker()
	default_deconstruction_crowbar(user, I)

/obj/machinery/chem_heater/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/chem_heater/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/chem_heater/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/chem_heater/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(action)
		if("toggle_on")
			on = !on
		if("adjust_temperature")
			desired_temp = clamp(text2num(params["target"]), 0, 1000)
		if("eject_beaker")
			eject_beaker(usr)
			. = FALSE
		if("toggle_autoeject")
			auto_eject = !auto_eject
		else
			return FALSE
	add_fingerprint(usr)

/obj/machinery/chem_heater/ui_interact(mob/user, datum/tgui/ui = null)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemHeater", "Chemical Heater")
		ui.open()

/obj/machinery/chem_heater/ui_data(mob/user)
	var/data[0]
	var/cur_temp = beaker ? beaker.reagents.chem_temp : null

	data["targetTemp"] = desired_temp
	data["targetTempReached"] = FALSE
	data["autoEject"] = auto_eject
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? TRUE : FALSE

	data["currentTemp"] = cur_temp
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	if(cur_temp)
		data["targetTempReached"] = round(cur_temp) == round(desired_temp)

	//copy-pasted from chem dispenser
	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	return data
