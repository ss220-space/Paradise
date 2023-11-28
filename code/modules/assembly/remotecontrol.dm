/obj/item/assembly/control
	/// The control controls things that have matching id tag
	var/list/ids = null
	/// Should it only work on the same z-level
	var/safety_z_check = TRUE

/obj/item/assembly/control/activate()
	// Do nothing if no ids to control
	if(!length(ids))
		return FALSE
	// Cooldown check
	return ..()

/obj/item/assembly/control/poddoor

/obj/item/assembly/control/poddoor/activate()
	if(!..())
		return
	for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
		if(safety_z_check && poddoor.z != z || !(poddoor.id_tag in id))
			continue
		if(poddoor.density)
			INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, open))
		else
			INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, close))

/obj/item/assembly/control/airlock
	/// Bitflag
	var/specialfunctions = OPEN
	/// FALSE is closed, TRUE is open.
	var/desiredstate = FALSE

/obj/item/assembly/control/airlock/activate()
	if(!..())
		return
	for(var/obj/machinery/door/airlock/airlock in GLOB.airlocks)
		if(safety_z_check && airlock.z != z || !(airlock.id_tag in id))
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

/obj/item/assembly/control/ticket_machine/activate()
	if(!..())
		return
	for(var/obj/machinery/ticket_machine/M in GLOB.machines)
		if(!(M.id in ids))
			continue
		M.increment()
