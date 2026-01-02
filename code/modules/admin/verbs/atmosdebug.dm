ADMIN_VERB_VISIBILITY(atmos_debug, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(atmos_debug, R_DEBUG, "Check Plumbing", "Verifies the integrity of the plumbing network.", ADMIN_CATEGORY_MAPPING)
	if(tgui_alert(user, "WARNING: This command should not be run on a live server. Do you want to continue?", "Check Piping", list("No", "Yes")) == "No")
		return

	//all plumbing - yes, some things might get stated twice, doesn't matter.
	to_chat(user, "Checking for unconnected pipes")
	var/list/atmos = list()
	for(var/turf/T in world)
		for(var/obj/machinery/atmospherics/atm in T)
			atmos += atm
	//Manifolds 3w
	for(var/obj/machinery/atmospherics/pipe/manifold/pipe in atmos)
		if(!pipe.node1 || !pipe.node2 || !pipe.node3)
			to_chat(user, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)
	//Manifolds 4w
	for(var/obj/machinery/atmospherics/pipe/manifold4w/pipe in atmos)
		if(!pipe.node1 || !pipe.node2 || !pipe.node3 || !pipe.node4)
			to_chat(user, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)
	//Pipes
	for(var/obj/machinery/atmospherics/pipe/simple/pipe in atmos)
		if(!pipe.node1 || !pipe.node2)
			to_chat(user, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)
	to_chat(user, "Checking for overlapping pipes...")
	for(var/turf/T in world)
		for(var/dir in GLOB.cardinal)
			var/list/check = list(0, 0, 0)
			var/done = 0
			for(var/obj/machinery/atmospherics/pipe in T)
				if(dir & pipe.initialize_directions)
					for(var/ct in pipe.connect_types)
						check[ct]++
						if(check[ct] > 1)
							to_chat(user, "Overlapping pipe ([pipe.name]) located at [ADMIN_VERBOSEJMP(T)]", confidential = TRUE)
							done = 1
							break
				if(done)
					break
	to_chat(user, "Done")
	BLACKBOX_LOG_ADMIN_VERB("Check Plumbing")

ADMIN_VERB_VISIBILITY(power_debug, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(power_debug, R_ADMIN, "Check Power", "Verifies the integrity of the power network.", ADMIN_CATEGORY_MAPPING)
	for(var/datum/powernet/PN in SSmachines.powernets)
		if(!PN.nodes || !length(PN.nodes))
			if(PN.cables && (length(PN.cables) > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(user, "Powernet with no nodes! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]")

		if(!PN.cables || (length(PN.cables) < 10))
			if(PN.cables && (length(PN.cables) > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(user, "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]")

	BLACKBOX_LOG_ADMIN_VERB("Check Power")
