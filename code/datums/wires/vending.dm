/datum/wires/vending
	holder_type = /obj/machinery/vending
	wire_count = 4
	window_y = 112
	window_x = 350
	proper_name = "Vending machine"

/datum/wires/vending/New(atom/_holder)
	wires = list(WIRE_THROW_ITEM, WIRE_IDSCAN, WIRE_ELECTRIFY, WIRE_CONTRABAND)
	return ..()

/datum/wires/vending/interactable(mob/user)
	var/obj/machinery/vending/V = holder
	if(!istype(user, /mob/living/silicon) && V.seconds_electrified && V.shock(user, 100))
		return FALSE
	if(V.panel_open)
		return TRUE
	return FALSE

/datum/wires/vending/get_status()
	. = ..()
	var/obj/machinery/vending/V = holder
	. += "The orange light is [V.seconds_electrified ? "on" : "off"]."
	. += "The red light is [V.shoot_inventory ? "off" : "blinking"]."
	. += "The green light is [V.extended_inventory ? "on" : "off"]."
	. += "A [V.scan_id ? "purple" : "yellow"] light is on."

/datum/wires/vending/on_pulse(wire)
	var/obj/machinery/vending/vending = holder
	switch(wire)
		if(WIRE_THROW_ITEM)
			vending.shoot_inventory = !vending.shoot_inventory
			vending.aggressive = !vending.aggressive
			if(vending.aggressive)
				holder.AddComponent(/datum/component/proximity_monitor)
			else
				qdel(holder.GetComponent(/datum/component/proximity_monitor))

		if(WIRE_CONTRABAND)
			vending.extended_inventory = !vending.extended_inventory

		if(WIRE_ELECTRIFY)
			vending.seconds_electrified = 30

		if(WIRE_IDSCAN)
			vending.scan_id = !vending.scan_id

	..()

/datum/wires/vending/on_cut(wire, mend)
	var/obj/machinery/vending/V = holder
	switch(wire)
		if(WIRE_THROW_ITEM)
			V.shoot_inventory = !mend
		if(WIRE_CONTRABAND)
			V.extended_inventory = FALSE
		if(WIRE_ELECTRIFY)
			if(mend)
				V.seconds_electrified = 0
			else
				V.seconds_electrified = -1
		if(WIRE_IDSCAN)
			V.scan_id = TRUE
	..()
