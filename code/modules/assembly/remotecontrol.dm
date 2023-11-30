/obj/item/assembly/control
	name = "abstract"
	desc = "This shouldn't exist"
	icon_state = "control"
	materials = list(MAT_METAL=100, MAT_GLASS=50)
	origin_tech = "programming=1"
	multitool_menu_type = /datum/multitool_menu/idtag/multiple_tags/door_control
	/// The control controls things that have matching id tag
	var/list/ids = null
	/// Should it only work on the same z-level
	var/safety_z_check = TRUE
	/// Can it be configured by players
	var/configurable = TRUE

/obj/item/assembly/control/Initialize()
	. = ..()
	ids = list()

/obj/item/assembly/control/activate()
	// Do nothing if no ids to control
	if(!length(ids))
		return FALSE
	// Cooldown check
	return ..()

/obj/item/assembly/control/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(configurable)
		multitool_menu_interact(user, I)
	else
		to_chat(user, span_warning("Это устройство надёжно защищено, изменить настройки нельзя."))

/obj/item/assembly/control/poddoor
	name = "blast door controller"
	desc = "A small electronic device able to control a blast door remotely."
	configurable = FALSE

/obj/item/assembly/control/poddoor/activate()
	if(!..())
		return
	for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
		if(safety_z_check && M.z != loc.z)
			continue
		if(!(M.id_tag in ids))
			continue
		if(M.density)
			spawn(0)
				M.open()
		else
			spawn(0)
				M.close()

/obj/item/assembly/control/airlock
	name = "airlock controller"
	desc = "A small electronic device able to control an airlock remotely."
	/// Bitflag
	var/specialfunctions = OPEN
	/// FALSE is closed, TRUE is open.
	var/desiredstate = FALSE

/obj/item/assembly/control/airlock/activate()
	if(!..())
		return
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(safety_z_check && D.z != loc.z)
			continue
		if(!(D.id_tag in ids))
			continue

		if(specialfunctions & OPEN)
			if(D.density)
				spawn(0)
					D.open()
			else
				spawn(0)
					D.close()

		if(desiredstate)
			if(specialfunctions & IDSCAN)
				D.aiDisabledIdScanner = TRUE
			if(specialfunctions & BOLTS)
				D.lock()
			if(specialfunctions & SHOCK)
				D.electrify(-1)
			if(specialfunctions & SAFE)
				D.safe = FALSE
		else
			if(specialfunctions & IDSCAN)
				D.aiDisabledIdScanner = FALSE
			if(specialfunctions & BOLTS)
				D.unlock()
			if(specialfunctions & SHOCK)
				D.electrify(0)
			if(specialfunctions & SAFE)
				D.safe = TRUE

	desiredstate = !desiredstate

/obj/item/assembly/control/ticket_machine
	name = "ticket machine controller"
	desc = "A remote controller for the HoP's ticket machine."
	configurable = FALSE

/obj/item/assembly/control/ticket_machine/activate()
	if(!..())
		return
	for(var/obj/machinery/ticket_machine/M in GLOB.machines)
		if(!(M.id in ids))
			continue
		M.increment()
