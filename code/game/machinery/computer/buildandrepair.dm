/obj/item/circuitboard
	/// Use `board_name` instead of this.
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "circuit_map"
	item_state = "electronic"
	origin_tech = "programming=2"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_GLASS=200)
	usesound = 'sound/items/deconstruct.ogg'
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	greyscale_config = /datum/greyscale_config/circuit
	flags = /obj/item::flags | NO_NEW_GAGS_PREVIEW
	abstract_type = /obj/item/circuitboard
	/// Use this instead of `name`. Formats as: `circuit board ([board_name])`
	var/board_name = null
	var/build_path = null
	var/board_type = "computer"
	var/list/req_components = null

/obj/item/circuitboard/computer
	name = "Generic"
	abstract_type = /obj/item/circuitboard/computer

/obj/item/circuitboard/machine
	board_type = "machine"
	abstract_type = /obj/item/circuitboard/machine

/obj/item/circuitboard/Initialize(mapload)
	. = ..()
	format_board_name()

/obj/item/circuitboard/proc/format_board_name()
	if(board_name) // Should always have this, but just in case.
		name = "[initial(name)] ([board_name])"
	else
		name = "[initial(name)]"

/obj/item/circuitboard/examine(mob/user)
	. = ..()
	if(LAZYLEN(req_components))
		var/list/nice_list = list()
		for(var/B in req_components)
			var/atom/A = B
			if(!ispath(A))
				continue
			nice_list += list("[req_components[A]] [initial(A.name)]\s")
		. += span_notice("Required components: [english_list(nice_list)].")

/obj/item/circuitboard/message_monitor
	board_name = "Message Monitor"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/message_monitor

/obj/item/circuitboard/camera
	board_name = "Camera Monitor"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/security
	origin_tech = "programming=2;combat=2"

/obj/item/circuitboard/camera/telescreen
	board_name = "Telescreen"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/security/telescreen

/obj/item/circuitboard/camera/telescreen/singularity
	board_name = "Telescreen_Singularity"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/security/telescreen/singularity

/obj/item/circuitboard/camera/telescreen/toxin_chamber
	board_name = "Toxins Telescreen"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/security/telescreen/toxin_chamber

/obj/item/circuitboard/camera/telescreen/test_chamber
	board_name = "Test Chamber Telescreen"
	build_path = /obj/machinery/computer/security/telescreen/test_chamber

/obj/item/circuitboard/camera/telescreen/research
	board_name = "Research Monitor"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/security/telescreen/research

/obj/item/circuitboard/camera/telescreen/prison
	board_name = "Prison Monitor"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/security/telescreen/prison

/obj/item/circuitboard/camera/telescreen/entertainment
	board_name = "Entertainment Monitor"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/computer/security/telescreen/entertainment

/obj/item/circuitboard/camera/wooden_tv
	board_name = "Wooden TV"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/computer/security/wooden_tv

/obj/item/circuitboard/camera/mining
	board_name = "Outpost Camera Monitor"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/security/mining

/obj/item/circuitboard/camera/engineering
	board_name = "Engineering Camera Monitor"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/security/engineering

/obj/item/circuitboard/xenobiology
	board_name = "Xenobiology Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/camera_advanced/xenobio
	origin_tech = "programming=3;biotech=3"

/obj/item/circuitboard/aicore
	board_name = "AI Core"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=3"
	board_type = "other"

/obj/item/circuitboard/aiupload
	board_name = "AI Upload"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/aiupload
	origin_tech = "programming=4;engineering=4"

/obj/item/circuitboard/borgupload
	board_name = "Cyborg Upload"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/aiupload/cyborg
	origin_tech = "programming=4;engineering=4"

/obj/item/circuitboard/med_data
	board_name = "Medical Records"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/med_data
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/pandemic
	board_name = "PanD.E.M.I.C. 2200"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/scan_consolenew
	board_name = "DNA Machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/communications
	board_name = "Communications Console"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=3;magnets=3"

/obj/item/circuitboard/card
	board_name = "ID Computer"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/card
	origin_tech = "programming=3"

/obj/item/circuitboard/card/minor
	board_name = "Dept ID Computer"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = TARGET_DEPT_GENERIC

/obj/item/circuitboard/card/minor/hos
	board_name = "Sec ID Computer"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/card/minor/hos
	target_dept = TARGET_DEPT_SEC

/obj/item/circuitboard/card/minor/cmo
	board_name = "Medical ID Computer"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/card/minor/cmo
	target_dept = TARGET_DEPT_MED

/obj/item/circuitboard/card/minor/qm
	board_name = "Supply ID Computer"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/card/minor/qm
	target_dept = TARGET_DEPT_SUP

/obj/item/circuitboard/card/minor/rd
	board_name = "Science ID Computer"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/card/minor/rd
	target_dept = TARGET_DEPT_SCI

/obj/item/circuitboard/card/minor/ce
	board_name = "Engineering ID Computer"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/card/minor/ce
	target_dept = TARGET_DEPT_ENG

/obj/item/circuitboard/card/centcom
	board_name = "CentComm ID Computer"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/teleporter
	board_name = "Teleporter Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=3;bluespace=3;plasmatech=3"

/obj/item/circuitboard/secure_data
	board_name = "Security Records"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/secure_data
	origin_tech = "programming=2;combat=2"

/obj/item/circuitboard/stationalert_engineering
	board_name = "Station Alert Console - Engineering"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/stationalert
	board_name = "Station Alert Console"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/atmos_alert
	board_name = "Atmospheric Alert Computer"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/atmoscontrol
	board_name = "Central Atmospherics Computer"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/atmoscontrol

/obj/item/circuitboard/air_management
	board_name = "Atmospheric Monitor"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/general_air_control

/obj/item/circuitboard/injector_control
	board_name = "Injector Control"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/general_air_control/fuel_injection

/obj/item/circuitboard/pod
	board_name = "Massdriver Control"
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/pod/deathsquad
	board_name = "Deathsquad Massdriver Control"
	build_path = /obj/machinery/computer/pod/deathsquad

/obj/item/circuitboard/robotics
	board_name = "Robotics Control Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"

/obj/item/circuitboard/drone_control
	board_name = "Drone Control"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/drone_control
	origin_tech = "programming=3"

/obj/item/circuitboard/cloning
	board_name = "Biomass Pod Console"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/arcade/battle
	board_name = "Arcade Battle"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = "programming=1"

/obj/item/circuitboard/arcade/orion_trail
	board_name = "Orion Trail"
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = "programming=1"

/obj/item/circuitboard/arcade/slotmachine
	board_name = "Slotmachine"
	build_path = /obj/machinery/computer/slot_machine
	origin_tech = "programming=1"

/obj/item/circuitboard/solar_control
	board_name = "Solar Control"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/powermonitor
	board_name = "Power Monitor"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/monitor
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/powermonitor/secret
	board_name = "Outdated Power Monitor"
	build_path = /obj/machinery/computer/monitor/secret

/obj/item/circuitboard/olddoor
	board_name = "DoorMex"
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/syndicatedoor
	board_name = "ProComp Executive"
	build_path = /obj/machinery/computer/pod/old/syndicate

/obj/item/circuitboard/swfdoor
	board_name = "Magix"
	build_path = /obj/machinery/computer/pod/old/swf

/obj/item/circuitboard/prisoner
	board_name = "Prisoner Management"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/prisoner

/obj/item/circuitboard/brigcells
	board_name = "Brig Cell Control"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/brigcells

/obj/item/circuitboard/sm_monitor
	board_name = "Supermatter Monitoring Console"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/sm_monitor
	origin_tech = "programming=2;powerstorage=2"

// RD console circuits, so that de/reconstructing one of the special consoles doesn't ruin everything forever
/obj/item/circuitboard/rdconsole
	board_name = "RD Console"
	desc = "Swipe a Scientist level ID or higher to reconfigure."
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/rdconsole/core
	req_access = list(ACCESS_TOX) // This is for adjusting the type of computer we're building - in case something messes up the pre-existing robotics or mechanics consoles
	var/list/access_types = list("R&D Core", "Robotics", "E.X.P.E.R.I-MENTOR", "Mechanics", "Public", "Cargo")

/obj/item/circuitboard/rdconsole/robotics
	board_name = "RD Console - Robotics"
	build_path = /obj/machinery/computer/rdconsole/robotics

/obj/item/circuitboard/rdconsole/experiment
	board_name = "RD Console - E.X.P.E.R.I-MENTOR"
	build_path = /obj/machinery/computer/rdconsole/experiment

/obj/item/circuitboard/rdconsole/mechanics
	board_name = "RD Console - Mechanics"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/rdconsole/mechanics

/obj/item/circuitboard/rdconsole/public
	board_name = "RD Console - Public"
	build_path = /obj/machinery/computer/rdconsole/public

/obj/item/circuitboard/rdconsole/cargo
	name = "RD Console - Cargo"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/rdconsole/cargo

/obj/item/circuitboard/roboquest
	board_name = "Robotics Request Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/roboquest

/obj/item/circuitboard/mecha_control
	board_name = "Exosuit Control Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/pod_locater
	board_name = "Pod Location Console"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/podtracker

/obj/item/circuitboard/rdservercontrol
	board_name = "RD Server Control"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/crew
	board_name = "Crew Monitoring Computer"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/mech_bay_power_console
	board_name = "Mech Bay Power Control Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=3;powerstorage=3"

/obj/item/circuitboard/ordercomp
	board_name = "Supply Ordering Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/supplycomp/public
	origin_tech = "programming=3"

/obj/item/circuitboard/supplycomp
	board_name = "Supply Shuttle Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/supplycomp
	origin_tech = "programming=3"
	var/contraband_enabled = 0

/obj/item/circuitboard/supplyquest
	board_name = "Supply Quest Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/supplyquest
	origin_tech = "programming=3"

/obj/item/circuitboard/questcons
	board_name = "Supply Quest Monitor"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/supplyquest/workers
	origin_tech = "programming=3"

/obj/item/circuitboard/syndicatesupplycomp
	board_name = "Syndicate Supply Pad Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/syndie_supplycomp
	origin_tech = "programming=3;syndicate=3"

/obj/item/circuitboard/syndicatesupplycomp/public
	board_name = "Syndicate Public Supply Pad Console"
	build_path = /obj/machinery/computer/syndie_supplycomp/public

/obj/item/circuitboard/syndicate_teleporter
	board_name = "Syndicate Redspace Teleporter"
	icon_state = "syndicate_circuit"
	greyscale_config = null
	build_path = /obj/machinery/computer/syndicate_depot/teleporter/taipan
	origin_tech = "programming=6;bluespace=5;syndicate=8"

/obj/item/circuitboard/operating
	board_name = "Operating Computer"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=3"

/obj/item/circuitboard/shuttle
	board_name = "Shuttle"
	build_path = /obj/machinery/computer/shuttle
	var/shuttleId
	var/possible_destinations = ""

/obj/item/circuitboard/labor_shuttle
	board_name = "Labor Shuttle"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/shuttle/labor

/obj/item/circuitboard/labor_shuttle/one_way
	board_name = "Prisoner Shuttle Console"
	build_path = /obj/machinery/computer/shuttle/labor/one_way

/obj/item/circuitboard/ferry
	board_name = "Transport Ferry"
	build_path = /obj/machinery/computer/shuttle/ferry

/obj/item/circuitboard/ferry/request
	board_name = "Transport Ferry Console"
	build_path = /obj/machinery/computer/shuttle/ferry/request

/obj/item/circuitboard/mining_shuttle
	board_name = "Mining Shuttle"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/shuttle/mining

/obj/item/circuitboard/ruins_transport_shuttle
	board_name = "Transport Shuttle"
	build_path = /obj/machinery/computer/shuttle/ruins_transport_shuttle

/obj/item/circuitboard/ruins_civil_shuttle
	board_name = "Regular Civilian Shuttle"
	build_path = /obj/machinery/computer/shuttle/ruins_civil_shuttle

/obj/item/circuitboard/white_ship
	board_name = "White Ship"
	build_path = /obj/machinery/computer/shuttle/white_ship

/obj/item/circuitboard/shuttle/syndicate
	board_name = "Syndicate Shuttle"
	build_path = /obj/machinery/computer/shuttle/syndicate

/obj/item/circuitboard/shuttle/syndicate/recall
	board_name = "Syndicate Shuttle Recall Terminal"
	build_path = /obj/machinery/computer/shuttle/syndicate/recall

/obj/item/circuitboard/shuttle/syndicate/drop_pod
	board_name = "Syndicate Drop Pod"
	build_path = /obj/machinery/computer/shuttle/syndicate/drop_pod

/obj/item/circuitboard/shuttle/nt/drop_pod
	board_name = "Nanotrasen Drop Pod"
	build_path = /obj/machinery/computer/shuttle/nt/drop_pod

/obj/item/circuitboard/shuttle/golem_ship
	board_name = "Golem Ship"
	build_path = /obj/machinery/computer/shuttle/golem_ship

/obj/item/circuitboard/HolodeckControl
	board_name = "Holodeck Control"
	build_path = /obj/machinery/computer/HolodeckControl
	origin_tech = "programming=4"

/obj/item/circuitboard/aifixer
	board_name = "AI Integrity Restorer"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/area_atmos
	board_name = "Area Air Control"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/area_atmos

/obj/item/circuitboard/telesci_console
	board_name = "Telepad Control Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/telescience
	origin_tech = "programming=3;bluespace=3;plasmatech=4"

/obj/item/circuitboard/large_tank_control
	board_name = "Atmospheric Tank Control"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/general_air_control/large_tank_control
	origin_tech = "programming=2;engineering=3;materials=2"

/obj/item/circuitboard/turbine_computer
	board_name = "Turbine Computer"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;powerstorage=4"

/obj/item/circuitboard/HONKputer
	board_name = "HONKputer"
	build_path = /obj/machinery/computer/HONKputer
	icon = 'icons/obj/machines/HONKputer.dmi'
	icon_state = "bananium_board"
	greyscale_config = null
	board_type = "HONKputer"

/obj/item/circuitboard/broken
	board_name = "Broken curcuit"
	build_path = null

/obj/item/circuitboard/supplycomp/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	var/catastasis // Why is it called this
	var/opposite_catastasis
	if(contraband_enabled)
		catastasis = "BROAD"
		opposite_catastasis = "STANDARD"
	else
		catastasis = "STANDARD"
		opposite_catastasis = "BROAD"

	var/choice = tgui_alert(user, "Current receiver spectrum is set to: [catastasis]", "Multitool-Circuitboard interface", list("Switch to [opposite_catastasis]", "Cancel"))
	if(!choice || choice == "Cancel")
		return

	contraband_enabled = !contraband_enabled
	playsound(src, 'sound/effects/pop.ogg', 50)

/obj/item/circuitboard/rdconsole/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(I.GetID() || is_pda(I))
		add_fingerprint(user)
		if(!allowed(user))
			to_chat(user, span_warning("Access Denied"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] waves [user.p_their()] ID past [src]'s access protocol scanner."),
			span_notice("You swipe your ID past [src]'s access protocol scanner."),
		)
		var/console_choice = tgui_input_list(user, "What do you want to configure the access to?", "Access Modification", access_types)
		if(!console_choice || !Adjacent(user) || QDELETED(I) || I.loc != user)
			return ATTACK_CHAIN_BLOCKED_ALL
		switch(console_choice)
			if("R&D Core")
				board_name = "RD Console"
				build_path = /obj/machinery/computer/rdconsole/core
			if("Robotics")
				board_name = "RD Console - Robotics"
				build_path = /obj/machinery/computer/rdconsole/robotics
			if("E.X.P.E.R.I-MENTOR")
				board_name = "RD Console - E.X.P.E.R.I-MENTOR"
				build_path = /obj/machinery/computer/rdconsole/experiment
			if("Mechanics")
				board_name = "RD Console - Mechanics"
				build_path = /obj/machinery/computer/rdconsole/mechanics
			if("Public")
				board_name = "RD Console - Public"
				build_path = /obj/machinery/computer/rdconsole/public
			if("Cargo")
				board_name = "RD Console - Cargo"
				build_path = /obj/machinery/computer/rdconsole/cargo
		format_board_name()
		to_chat(user, span_notice("Access protocols set to '[console_choice]'."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

// Construction | Deconstruction
#define STATE_EMPTY 1 // Add a circuitboard | Weld to destroy
#define STATE_CIRCUIT 2 // Screwdriver the cover closed | Crowbar the circuit
#define STATE_NOWIRES 3 // Add wires | Screwdriver the cover open
#define STATE_WIRES 4 // Add glass | Remove wires
#define STATE_GLASS 5 // Screwdriver to complete | Crowbar glass out

/obj/structure/computerframe
	name = "computer frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "comp_frame_1"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	var/state = STATE_EMPTY
	var/obj/item/circuitboard/circuit = null
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING | NEED_DEXTERITY

/obj/structure/computerframe/Initialize(mapload, obj/item/circuitboard/circuit)
	. = ..()

	if(circuit)
		src.circuit = new circuit(src)
		state = STATE_GLASS	// Spawned during completed computer Init, so it's completed.

/obj/structure/computerframe/examine(mob/user)
	. = ..()
	. += span_notice("It is [anchored ? "<b>bolted</b> to the floor" : "<b>unbolted</b>"].")
	switch(state)
		if(STATE_EMPTY)
			. += span_notice("The frame is <b>welded together</b>, but it is missing a <i>circuit board</i>.")
		if(STATE_CIRCUIT)
			. += span_notice("A circuit board is <b>firmly connected</b>, but the cover is <i>unscrewed and open</i>.")
		if(STATE_NOWIRES)
			. += span_notice("The cover is <b>screwed shut</b>, but the frame is missing <i>wiring</i>.")
		if(STATE_WIRES)
			. += span_notice("The frame is <b>wired</b>, but the <i>glass</i> is missing.")
		if(STATE_GLASS)
			. += span_notice("The glass is <b>loosely connected</b> and needs to be <i>screwed into place</i>.")
	if(!anchored)
		. += span_notice("Alt-Click to rotate it.")

/obj/structure/computerframe/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		var/location = drop_location()
		drop_computer_materials(location)

		if(circuit)
			circuit.forceMove(location)

		if(state >= STATE_WIRES)
			new /obj/item/stack/cable_coil(location, 5)

		if(state == STATE_GLASS)
			new /obj/item/stack/sheet/glass(location, 2)

	state = STATE_EMPTY
	circuit = null

	return ..() // will qdel the frame

/obj/structure/computerframe/Destroy()
	if(istype(circuit))
		qdel(circuit)

	circuit = null

	return ..()

/obj/structure/computerframe/click_alt(mob/user)
	if(anchored)
		to_chat(user, span_warning("The frame is anchored to the floor!"))
		return CLICK_ACTION_BLOCKING
	setDir(turn(dir, 90))
	return CLICK_ACTION_SUCCESS

/obj/structure/computerframe/obj_break(damage_flag)
	deconstruct()

/obj/structure/computerframe/proc/drop_computer_materials(location)
	new /obj/item/stack/sheet/metal(location, 5)

/obj/structure/computerframe/update_icon_state()
	icon_state = "comp_frame_[state]"

/obj/structure/computerframe/welder_act(mob/user, obj/item/I)
	if(state != STATE_EMPTY)
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return .
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		return .
	WELDER_SLICING_SUCCESS_MESSAGE
	deconstruct(TRUE)

/obj/structure/computerframe/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	to_chat(user, span_notice("You [anchored ? "fasten the frame into place" : "unfasten the frame"]."))

/obj/structure/computerframe/crowbar_act(mob/living/user, obj/item/I)
	if(state != STATE_CIRCUIT && state != STATE_GLASS)
		return FALSE
	. = TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .

	switch(state)
		if(STATE_CIRCUIT)
			to_chat(user, span_notice("You remove the circuit board."))
			state = STATE_EMPTY
			name = initial(name)
			circuit.forceMove_turf()
			circuit = null
			update_icon(UPDATE_ICON_STATE)
		if(STATE_GLASS)
			to_chat(user, span_notice("You remove the glass panel."))
			state = STATE_WIRES
			new /obj/item/stack/sheet/glass(drop_location(), 2)
			update_icon(UPDATE_ICON_STATE)

/obj/structure/computerframe/screwdriver_act(mob/living/user, obj/item/I)
	if(state != STATE_CIRCUIT && state != STATE_NOWIRES && state != STATE_GLASS)
		return FALSE

	. = TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	switch(state)
		if(STATE_CIRCUIT)
			to_chat(user, span_notice("You screw the circuit board into place."))
			state = STATE_NOWIRES
			update_icon(UPDATE_ICON_STATE)

		if(STATE_NOWIRES)
			to_chat(user, span_notice("You unfasten the circuit board."))
			state = STATE_CIRCUIT
			update_icon(UPDATE_ICON_STATE)

		if(STATE_GLASS)
			if(!anchored)
				to_chat(user, span_warning("Monitor can't be properly connected to the unfastened frame!"))
				return

			to_chat(user, span_notice("You connect the monitor."))
			if(circuit.build_path)
				new circuit.build_path(get_turf(src), src)
			else
				to_chat(user, span_warning("You connect the monitor, but it doesn't work. Maybe the circuit is broken?"))

/obj/structure/computerframe/wirecutter_act(mob/living/user, obj/item/I)
	if(state != STATE_WIRES)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You remove the cables."))
	new /obj/item/stack/cable_coil(drop_location(), 5)
	state = STATE_NOWIRES
	update_icon(UPDATE_ICON_STATE)

/obj/structure/computerframe/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	switch(state)
		if(STATE_EMPTY)
			if(!istype(I, /obj/item/circuitboard))
				return ..()

			add_fingerprint(user)

			if(!circuit_compatibility_check(I))
				to_chat(user, span_warning("[src] does not accept circuit boards of this type!"))
				return ATTACK_CHAIN_PROCEED

			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()

			var/obj/item/circuitboard/new_circuit = I
			new_circuit.play_tool_sound(src)
			to_chat(user, span_notice("You place [new_circuit] inside [src]."))
			name += " ([new_circuit.board_name])"
			state = STATE_CIRCUIT
			circuit = new_circuit
			update_icon(UPDATE_ICON_STATE)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(STATE_NOWIRES)
			if(!iscoil(I))
				return ..()
			add_fingerprint(user)
			var/obj/item/stack/cable_coil/coil = I
			if(coil.get_amount() < 5)
				to_chat(user, span_warning("You need five lengths of cable to wire the frame."))
				return ATTACK_CHAIN_PROCEED
			coil.play_tool_sound(src)
			to_chat(user, span_notice("You start to add cables to the frame..."))
			if(!do_after(user, 2 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || state != STATE_NOWIRES || QDELETED(coil))
				return ATTACK_CHAIN_PROCEED
			if(!coil.use(5))
				to_chat(user, span_warning("At some point during construction you lost some cable. Make sure you have five lengths before trying again."))
				return ATTACK_CHAIN_PROCEED
			state = STATE_WIRES
			update_icon(UPDATE_ICON_STATE)
			to_chat(user, span_notice("You add cables to the frame."))
			return ATTACK_CHAIN_PROCEED_SUCCESS

		if(STATE_WIRES)
			if(!istype(I, /obj/item/stack/sheet/glass))
				return ..()
			add_fingerprint(user)
			var/obj/item/stack/sheet/glass/glass = I
			if(glass.get_amount() < 2)
				to_chat(user, span_warning("You need two sheets of glass for this."))
				return ATTACK_CHAIN_PROCEED
			glass.play_tool_sound(src)
			to_chat(user, span_notice("You start to add the glass panel to the frame..."))
			if(!do_after(user, 2 SECONDS * glass.toolspeed, src, category = DA_CAT_TOOL) || state != STATE_WIRES || QDELETED(glass))
				return ATTACK_CHAIN_PROCEED
			if(!glass.use(2))
				to_chat(user, span_warning("At some point during construction you lost some glass. Make sure you have two sheets before trying again."))
				return ATTACK_CHAIN_PROCEED
			to_chat(user, span_notice("You put in the glass panel."))
			state = STATE_GLASS
			update_icon(UPDATE_ICON_STATE)
			return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/structure/computerframe/proc/on_construction(obj/machinery/computer/computer)
	forceMove(computer)

/obj/structure/computerframe/proc/circuit_compatibility_check(obj/item/circuitboard/circuit)
	return circuit.board_type == "computer"

/obj/structure/computerframe/HONKputer
	name = "Bananium Computer-frame"
	icon = 'icons/obj/machines/HONKputer.dmi'

/obj/structure/computerframe/HONKputer/drop_computer_materials(location)
	new /obj/item/stack/sheet/mineral/bananium(location, 20)

/obj/structure/computerframe/HONKputer/circuit_compatibility_check(obj/item/circuitboard/circuit)
	return circuit.board_type == "HONKputer"

/obj/structure/computerframe/abductor
	icon_state = "comp_frame_alien1"

/obj/structure/computerframe/abductor/update_icon_state()
	icon_state = "comp_frame_alien[state]"

/obj/structure/computerframe/abductor/on_construction(obj/machinery/computer/computer)
	..()
	computer.abductor = TRUE
	computer.max_integrity = 400
	computer.update_integrity(400)

/obj/structure/computerframe/abductor/drop_computer_materials(location)
	new /obj/item/stack/sheet/mineral/abductor(location, 4)

/obj/structure/computerframe/cargo
	name = "cargo R&D console frame"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "cargocomp_unscrewed"

#undef STATE_EMPTY
#undef STATE_CIRCUIT
#undef STATE_NOWIRES
#undef STATE_WIRES
#undef STATE_GLASS

//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, glass sheets, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add MAT_METAL and MAT_GLASS to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/
/obj/item/circuitboard/vendor
	board_name = "Booze-O-Mat Vendor"
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=1"
	build_path = /obj/machinery/vending/boozeomat
	req_components = list(/obj/item/vending_refill/boozeomat = 1)

	var/static/list/station_vendors = list(
		"Booze-O-Mat" = /obj/machinery/vending/boozeomat,
		"Solar's Best Hot Drinks" = /obj/machinery/vending/coffee,
		"Getmore Chocolate Corp" = /obj/machinery/vending/snack,
		"Mr. Chang" = /obj/machinery/vending/chinese,
		"Robust Softdrinks" = /obj/machinery/vending/cola,
		"ShadyCigs Deluxe" = /obj/machinery/vending/cigarette,
		"Hatlord 9000" = /obj/machinery/vending/hatdispenser,
		"Suitlord 9000" = /obj/machinery/vending/suitdispenser,
		"Shoelord 9000" = /obj/machinery/vending/shoedispenser,
		"AutoDrobe" = /obj/machinery/vending/autodrobe,
		"ClothesMate" = /obj/machinery/vending/clothesmate,
		"NanoMed Plus" = /obj/machinery/vending/medical,
		"NanoMed" = /obj/machinery/vending/wallmed,
		"Vendomat" = /obj/machinery/vending/assist,
		"YouTool" = /obj/machinery/vending/tool,
		"Engi-Vend" = /obj/machinery/vending/engivend,
		"NutriMax" = /obj/machinery/vending/hydronutrients,
		"MegaSeed Servitor" = /obj/machinery/vending/hydroseeds,
		"Sustenance Vendor" = /obj/machinery/vending/sustenance,
		"Plasteel Chef's Dinnerware Vendor" = /obj/machinery/vending/dinnerware,
		"PTech" = /obj/machinery/vending/cart,
		"Robotech Deluxe" = /obj/machinery/vending/robotics,
		"Robco Tool Maker" = /obj/machinery/vending/engineering,
		"BODA" = /obj/machinery/vending/sovietsoda,
		"SecTech" = /obj/machinery/vending/security,
		"ModTech" = /obj/machinery/vending/gun_mods,
		"CritterCare" = /obj/machinery/vending/crittercare,
		"Departament Security ClothesMate" = /obj/machinery/vending/department_clothesmate/security,
		"Departament Medical ClothesMate" = /obj/machinery/vending/department_clothesmate/medical,
		"Departament Engineering ClothesMate" = /obj/machinery/vending/department_clothesmate/engineering,
		"Departament Science ClothesMate" = /obj/machinery/vending/department_clothesmate/science,
		"Departament Cargo ClothesMate" = /obj/machinery/vending/department_clothesmate/cargo,
		"Departament Law ClothesMate" = /obj/machinery/vending/department_clothesmate/law,
		"Service Departament ClothesMate Botanical" = /obj/machinery/vending/department_clothesmate/service/botanical,
		"Service Departament ClothesMate Chaplain" = /obj/machinery/vending/department_clothesmate/service/chaplain,
		"RoboFriends" = /obj/machinery/vending/pai,
		"Customat" = /obj/machinery/customat,
		"Автомат спортивного питания" = /obj/machinery/vending/protein,
		"Liberty" = /obj/machinery/vending/ammo,
	)

	var/static/list/unique_vendors = list(
		"ShadyCigs Ultra" = /obj/machinery/vending/cigarette/beach,
		"SyndiWallMed" = /obj/machinery/vending/wallmed/syndicate,
		"SyndiMed Plus" = /obj/machinery/vending/medical/syndicate_access,
		"PlasmaMate" = /obj/machinery/vending/plasmamate,
	)

/obj/item/circuitboard/vendor/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = tgui_input_list(user, "Choose a new brand", "Select an Item", station_vendors)
	if(!choice)
		return
	set_type(choice)

/obj/item/circuitboard/vendor/proc/set_type(type)
	var/static/list/buildable_vendors = station_vendors + unique_vendors
	var/obj/machinery/vending/typepath = buildable_vendors[type]
	build_path = typepath
	board_name = "[type] Vendor"
	format_board_name()
	req_components = list(initial(typepath.refill_canister) = 1)

/obj/item/circuitboard/smes
	board_name = "SMES"
	build_path = /obj/machinery/power/smes
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 5,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/smes/vintage
	build_path = /obj/machinery/power/smes/vintage
	origin_tech = "programming=2;powerstorage=2;engineering=2"
	req_components = list(
		/obj/item/stack/cable_coil = 7,
		/obj/item/stock_parts/cell = 7,
		/obj/item/stock_parts/capacitor = 3,
	)

/obj/item/circuitboard/emitter
	board_name = "Emitter"
	build_path = /obj/machinery/power/emitter
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/power_compressor
	board_name = "Power Compressor"
	build_path = /obj/machinery/power/compressor
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/manipulator = 6,
	)

/obj/item/circuitboard/power_turbine
	board_name = "Power Turbine"
	build_path = /obj/machinery/power/turbine
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 6,
	)

/obj/item/circuitboard/thermomachine
	board_name = "Freezer"
	desc = "Use screwdriver to switch between heating and cooling modes."
	build_path = /obj/machinery/atmospherics/unary/thermomachine/freezer
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/thermomachine/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	if(build_path == /obj/machinery/atmospherics/unary/thermomachine/freezer)
		build_path = /obj/machinery/atmospherics/unary/thermomachine/heater
		board_name = "Heater"
		to_chat(user, span_notice("You set the board to heating."))
	else
		build_path = /obj/machinery/atmospherics/unary/thermomachine/freezer
		board_name = "Freezer"
		to_chat(user, span_notice("You set the board to cooling."))

/obj/item/circuitboard/cell_charger
	board_name = "Cell Recharger"
	build_path = /obj/machinery/cell_charger
	board_type = "machine"
	origin_tech = "powerstorage=3;materials=2"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/recharger
	board_name = "Recharger"
	build_path = /obj/machinery/recharger
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	origin_tech = "powerstorage=3;materials=2"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/snow_machine
	board_name = "Snow Machine"
	build_path = /obj/machinery/snow_machine
	board_type = "machine"
	origin_tech = "programming=2;materials=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/biogenerator
	board_name = "Biogenerator"
	build_path = /obj/machinery/biogenerator
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=2;biotech=3;materials=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/plantgenes
	board_name = "Plant DNA Manipulator"
	build_path = /obj/machinery/plantgenes
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=3;biotech=3"
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/scanning_module = 1,
	)

/obj/item/circuitboard/plantgenes/vault

/obj/item/circuitboard/seed_extractor
	board_name = "Seed Extractor"
	build_path = /obj/machinery/seed_extractor
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/hydroponics
	board_name = "Hydroponics Tray"
	build_path = /obj/machinery/hydroponics/constructable
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=1;biotech=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/microwave
	board_name = "Microwave"
	build_path = /obj/machinery/kitchen_machine/microwave
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=2;magnets=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/oven
	board_name = "Oven"
	build_path = /obj/machinery/kitchen_machine/oven
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=2;magnets=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/grill
	board_name = "Grill"
	build_path = /obj/machinery/kitchen_machine/grill
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=2;magnets=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/candy_maker
	board_name = "Candy Maker"
	build_path = /obj/machinery/kitchen_machine/candy_maker
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=2;magnets=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/deepfryer
	board_name = "Deep Fryer"
	build_path = /obj/machinery/cooker/deepfryer
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/cable_coil = 5,
	)

/obj/item/circuitboard/gibber
	board_name = "Gibber"
	build_path = /obj/machinery/gibber
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/tesla_coil
	board_name = "Tesla Coil"
	build_path = /obj/machinery/power/tesla_coil
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=3;magnets=3;powerstorage=3"
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/grounding_rod
	board_name = "Grounding Rod"
	build_path = /obj/machinery/power/grounding_rod
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=3;powerstorage=3;magnets=3;plasmatech=2"
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/processor
	board_name = "Food Processor"
	build_path = /obj/machinery/processor
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/recycler
	board_name = "Recycler"
	build_path = /obj/machinery/recycler
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/dnaforensics
	board_name = "Анализатор ДНК"
	build_path = /obj/machinery/dnaforensics
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	origin_tech = "programming=2;combat=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/microscope
	board_name = "Электронный микроскоп"
	build_path = /obj/machinery/microscope
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	origin_tech = "programming=2;combat=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/smartfridge
	board_name = "Smartfridge"
	build_path = /obj/machinery/smartfridge
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
	)
	var/static/list/fridge_names_paths = list(
		"SmartFridge" = /obj/machinery/smartfridge,
		"Seed Storage" = /obj/machinery/smartfridge/seeds,
		"Refrigerated Medicine Storage" = /obj/machinery/smartfridge/medbay,
		"Slime Extract Storage" = /obj/machinery/smartfridge/secure/extract,
		"Secure Refrigerated Medicine Storage" = /obj/machinery/smartfridge/secure/medbay/organ,
		"Smart Chemical Storage" = /obj/machinery/smartfridge/secure/chemistry,
		"Smart Virus Storage" = /obj/machinery/smartfridge/secure/chemistry/virology,
		"Drink Showcase" = /obj/machinery/smartfridge/drinks,
		"Disk Storage" = /obj/machinery/smartfridge/disks,
		"Dish Showcase" = /obj/machinery/smartfridge/dish,
	)

/obj/item/circuitboard/smartfridge/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = tgui_input_list(user, "Circuit Setting", "What would you change the board setting to?", fridge_names_paths)
	if(!choice)
		return
	set_type(user, choice)

/obj/item/circuitboard/smartfridge/proc/set_type(mob/user, type)
	if(!ispath(type))
		board_name = type
		type = fridge_names_paths[type]
	else
		for(var/name in fridge_names_paths)
			if(fridge_names_paths[name] == type)
				board_name = name
				break
	build_path = type
	format_board_name()
	if(user)
		to_chat(user, span_notice("You set the board to [board_name]."))

/obj/item/circuitboard/monkey_recycler
	board_name = "Monkey Recycler"
	build_path = /obj/machinery/monkey_recycler
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/holopad
	board_name = "AI Holopad"
	build_path = /obj/machinery/hologram/holopad
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/chem_dispenser
	board_name = "Chem Dispenser"
	build_path = /obj/machinery/chem_dispenser
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	origin_tech = "materials=4;programming=4;plasmatech=4;biotech=3"
	req_access = list(ACCESS_TOX, ACCESS_CHEMISTRY, ACCESS_SYNDICATE_SCIENTIST)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1,
	)

/obj/item/circuitboard/chem_dispenser/botanical
	board_name = "Botanical Chem Dispenser"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/chem_dispenser/botanical

/obj/item/circuitboard/chem_master
	board_name = "ChemMaster 3000"
	build_path = /obj/machinery/chem_master
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	origin_tech = "materials=3;programming=2;biotech=3"
	req_components = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/chem_master/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/new_name = "ChemMaster"
	var/new_path = /obj/machinery/chem_master

	if(build_path == /obj/machinery/chem_master)
		new_name = "CondiMaster"
		new_path = /obj/machinery/chem_master/condimaster

	build_path = new_path
	name = "circuit board ([new_name] 3000)"
	to_chat(user, span_notice("You change the circuit board setting to \"[new_name]\"."))

/obj/item/circuitboard/chem_master/condi_master
	board_name = "CondiMaster 3000"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/chem_heater
	board_name = "Chemical Heater"
	build_path = /obj/machinery/chem_heater
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	origin_tech = "programming=2;engineering=2;biotech=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/reagentgrinder
	board_name = "All-In-One Grinder"
	build_path = /obj/machinery/reagentgrinder/empty
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	origin_tech = "materials=2;engineering=2;biotech=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 1,
	)

//Almost the same recipe as destructive analyzer to give people choices.
/obj/item/circuitboard/experimentor
	board_name = "E.X.P.E.R.I-MENTOR"
	build_path = /obj/machinery/r_n_d/experimentor
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2,
	)

/obj/item/circuitboard/destructive_analyzer
	board_name = "Destructive Analyzer"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/autolathe
	board_name = "Autolathe"
	build_path = /obj/machinery/autolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/protolathe
	board_name = "Protolathe"
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "engineering=2;programming=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2,
	)

/obj/item/circuitboard/chem_dispenser/soda
	board_name = "Soda Machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/chem_dispenser/soda

/obj/item/circuitboard/chem_dispenser/beer
	board_name = "Beer Machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/chem_dispenser/beer

/obj/item/circuitboard/circuit_imprinter
	board_name = "Circuit Imprinter"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "engineering=2;programming=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2,
	)

/obj/item/circuitboard/pacman
	board_name = "PACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=2;powerstorage=3;plasmatech=3;engineering=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/pacman/super
	board_name = "SUPERPACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/circuitboard/pacman/mrs
	board_name = "MRSPACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/mrs
	origin_tech = "programming=3;powerstorage=4;engineering=4;plasmatech=4"

/obj/item/circuitboard/rdserver
	board_name = "R&D Server"
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=3"
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1,
	)

/obj/item/circuitboard/mechfab
	board_name = "Exosuit Fabricator"
	build_path = /obj/machinery/mecha_part_fabricator
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/mechfab/syndicate
	board_name = "Syndicate Exosuit Fabricator"
	icon_state = "syndicate_circuit"
	greyscale_config = null
	build_path = /obj/machinery/mecha_part_fabricator/syndicate
	origin_tech = "programming=2;engineering=2;syndicate=5"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/telecrystal = 25,
	)

/obj/item/circuitboard/podfab
	board_name = "Spacepod Fabricator"
	build_path = /obj/machinery/mecha_part_fabricator/spacepod
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/clonepod
	board_name = "Experimental Biomass Pod"
	build_path = /obj/machinery/clonepod
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	origin_tech = "programming=2;biotech=2"
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/capacitor/quadratic = 5,
	)

/obj/item/circuitboard/clonescanner
	board_name = "DNA Scanner"
	build_path = /obj/machinery/dna_scannernew
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	origin_tech = "programming=2;biotech=2"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2,
	)

/obj/item/circuitboard/mech_recharger
	board_name = "Mech Bay Recharger"
	build_path = /obj/machinery/mech_bay_recharge_port
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/capacitor = 5,
	)

/obj/item/circuitboard/teleporter_hub
	board_name = "Teleporter Hub"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 3,
		/obj/item/stock_parts/matter_bin = 1,
	)

/obj/item/circuitboard/teleporter_station
	board_name = "Teleporter Station"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/teleporter_perma
	board_name = "Permanent Teleporter"
	build_path = /obj/machinery/teleport/perma
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 3,
		/obj/item/stock_parts/matter_bin = 1,
	)
	var/target

/obj/item/circuitboard/teleporter_perma/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/gps))
		add_fingerprint(user)
		var/obj/item/gps/gps = I
		if(gps.locked_location)
			target = get_turf(gps.locked_location)
			to_chat(user, span_caution("You upload the data from [gps]"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/circuitboard/telesci_pad
	board_name = "Telepad"
	build_path = /obj/machinery/telepad
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=4;engineering=3;plasmatech=4;bluespace=4"
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/quantumpad
	board_name = "Quantum Pad"
	build_path = /obj/machinery/quantumpad
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=4"
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
	)

// syndie pads can be created by emagging normal quantumpads
/obj/item/circuitboard/quantumpad/emag_act(mob/user)
	if(!emagged)
		if(user)
			user.visible_message(span_warning("Sparks fly out of the [src]!"), span_notice("You emag the [src], rewriting it's protocols for redspace usage."))
			playsound(src.loc, 'sound/effects/sparks4.ogg', 50, TRUE)
		emagged = TRUE
		name = "circuit board (Syndicate Quantum Pad)"
		build_path = /obj/machinery/syndiepad
		board_type = "machine"
		req_components = list(
			/obj/item/stack/telecrystal = 5,
			/obj/item/stock_parts/capacitor = 1,
			/obj/item/stock_parts/manipulator = 1,
			/obj/item/stack/cable_coil = 1,
		)
	return
// syndie pads by Furukai

/obj/item/circuitboard/quantumpad/syndiepad
	board_name = "Syndicate Quantum Pad"
	build_path = /obj/machinery/syndiepad
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=4;syndicate=6" //Технология достойная подобного уровня нелегала как по мне
	req_components = list(
		/obj/item/stack/telecrystal = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
	)
	emagged = TRUE

/obj/item/circuitboard/roboquest_pad

	board_name = "Robotics Request Quantum Pad"
	build_path = /obj/machinery/roboquest_pad
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=5"
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 5,
		/obj/item/stack/cable_coil = 15,
	)

/obj/item/circuitboard/advanced_roboquest_pad
	board_name = "Robotics Request Advanced Quantum Pad"
	icon_state = "abductor_mod"
	greyscale_config = null
	build_path = /obj/machinery/roboquest_pad/advanced
	board_type = "machine"
	origin_tech = "programming=4;engineering=5;plasmatech=5;bluespace=6"
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stack/cable_coil = 15,
	)

/obj/item/circuitboard/sleeper
	board_name = "Sleeper"
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	origin_tech = "programming=3;biotech=2;engineering=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2,
	)

/obj/item/circuitboard/sleeper/syndicate
	board_name = "Sleeper - Syndicate"
	build_path = /obj/machinery/sleeper/syndie

/obj/item/circuitboard/sleeper/survival
	board_name = "Sleeper - Survival Pod"
	build_path = /obj/machinery/sleeper/survival_pod

/obj/item/circuitboard/bodyscanner
	board_name = "Body Scanner"
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	origin_tech = "programming=3;biotech=2;engineering=3"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2,
	)

/obj/item/circuitboard/cryo_tube
	board_name = "Cryotube"
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	origin_tech = "programming=4;biotech=3;engineering=4;plasmatech=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 4,
	)

/obj/item/circuitboard/cyborgrecharger
	board_name = "Cyborg Recharger"
	build_path = /obj/machinery/recharge_station
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

// Telecomms circuit boards:
/obj/item/circuitboard/tcomms/relay
	board_name = "Telecommunications Relay"
	build_path = /obj/machinery/tcomms/relay
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=2;engineering=2;bluespace=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
	)

/obj/item/circuitboard/tcomms/core
	board_name = "Telecommunications Core"
	build_path = /obj/machinery/tcomms/core
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
	)
// End telecomms circuit boards

/obj/item/circuitboard/ore_redemption
	board_name = "Ore Redemption"
	build_path = /obj/machinery/mineral/ore_redemption
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	origin_tech = "programming=1;engineering=2"
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/assembly/igniter = 1,
	)

/obj/item/circuitboard/ore_redemption/golem
	board_name = "Ore Redemption - Golem"
	build_path = /obj/machinery/mineral/ore_redemption/golem

/obj/item/circuitboard/ore_redemption/labor
	board_name = "Ore Redemption - Labour"
	build_path = /obj/machinery/mineral/ore_redemption/labor

/obj/item/circuitboard/mining_equipment_vendor
	board_name = "Mining Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	origin_tech = "programming=1;engineering=3"
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 3,
	)

/obj/item/circuitboard/mining_equipment_vendor/golem
	board_name = "Golem Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor/golem

/obj/item/circuitboard/mining_equipment_vendor/labor
	board_name = "Labour Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor/labor

/obj/item/circuitboard/clawgame
	board_name = "Claw Game"
	build_path = /obj/machinery/arcade/claw
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/minesweeper
	board_name = "Сапер"
	build_path = /obj/machinery/arcade/minesweeper
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/prize_counter
	board_name = "Prize Counter"
	build_path = /obj/machinery/prize_counter
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 1,
	)

/obj/item/circuitboard/gameboard
	board_name = "Virtual Gameboard"
	build_path = /obj/machinery/gameboard
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/vendor/plasmamate

/obj/item/circuitboard/vendor/plasmamate/Initialize(mapload)
	. = ..()
	set_type("PlasmaMate")

/obj/item/circuitboard/anomaly_generator
	board_name = "генератор аномалий"
	build_path = /obj/machinery/power/anomaly_generator
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "programming=1;bluespace=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/capacitor = 2,
	)

/obj/item/circuitboard/electrolyzer
	board_name = "Electrolyzer"
	build_path = /obj/machinery/power/electrolyzer
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	origin_tech = "programming=3;engineering=3"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 5,
	)

