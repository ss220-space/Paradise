/datum/wires/rnd
	holder_type = /obj/machinery/r_n_d
	proper_name = "R&D Machinery"
	randomize = TRUE

/datum/wires/rnd/New(atom/holder)
	wires = list(
		WIRE_HACK, WIRE_DISABLE,
		WIRE_ELECTRIFY
	)
	add_duds(5)
	..()

/datum/wires/rnd/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/r_n_d/rnd_machine = holder
	if(rnd_machine.panel_open)
		return TRUE

/datum/wires/rnd/get_status()
	var/obj/machinery/r_n_d/rnd_machine = holder
	var/list/status = list()
	status += "The red light is [rnd_machine.disabled ? "off" : "on"]."
	status += "The blue light is [rnd_machine.hacked ? "off" : "on"]."
	return status

/datum/wires/rnd/on_pulse(wire)
	set waitfor = FALSE
	var/obj/machinery/r_n_d/rnd_machine = holder
	switch(wire)
		if(WIRE_HACK)
			var/change = !rnd_machine.hacked
			rnd_machine.hacked = change
			addtimer(VARSET_CALLBACK(rnd_machine, hacked, !change), 10 SECONDS)
		if(WIRE_DISABLE)
			var/change = !rnd_machine.disabled
			rnd_machine.disabled = change
			rnd_machine.shock(usr, 50)
			addtimer(VARSET_CALLBACK(rnd_machine, disabled, !change), 10 SECONDS)
		if(WIRE_ELECTRIFY)
			var/change = !rnd_machine.shocked
			rnd_machine.shocked = change
			rnd_machine.shock(usr, 50)
			addtimer(VARSET_CALLBACK(rnd_machine, shocked, !change), 10 SECONDS)

/datum/wires/rnd/on_cut(wire, mend, source)
	var/obj/machinery/r_n_d/rnd_machine = holder
	switch(wire)
		if(WIRE_HACK)
			rnd_machine.hacked = !mend
		if(WIRE_DISABLE)
			rnd_machine.disabled = !mend
			rnd_machine.shock(usr, 50)
		if(WIRE_ELECTRIFY)
			rnd_machine.shocked = !mend
			rnd_machine.shock(usr, 50)
