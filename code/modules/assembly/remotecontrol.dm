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
	for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
		if(safety_z_check && poddoor.z != loc.z || !(poddoor.id_tag in ids))
			continue
		if(poddoor.density)
			INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, open))
		else
			INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, close))

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
	for(var/obj/machinery/door/airlock/airlock in GLOB.airlocks)
		if(safety_z_check && airlock.z != loc.z || !(airlock.id_tag in ids))
			continue
		if(specialfunctions & OPEN)
			if(airlock.density)
				INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door, open))
			else
				INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door, close))
		if(desiredstate)
			if(specialfunctions & IDSCAN)
				airlock.aiDisabledIdScanner = TRUE
			if(specialfunctions & BOLTS)
				airlock.lock()
			if(specialfunctions & SHOCK)
				airlock.electrify(-1)
			if(specialfunctions & SAFE)
				airlock.safe = FALSE
		else
			if(specialfunctions & IDSCAN)
				airlock.aiDisabledIdScanner = FALSE
			if(specialfunctions & BOLTS)
				airlock.unlock()
			if(specialfunctions & SHOCK)
				airlock.electrify(0)
			if(specialfunctions & SAFE)
				airlock.safe = TRUE

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
