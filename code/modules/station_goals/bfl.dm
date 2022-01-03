/datum/station_goal/bfl
	name = "BFL Mining laser"

/datum/station_goal/bfl/get_report()
	return {"<b>Mining laser construcion</b><br>
	Our surveillance drone detected a enormous deposit, oozing with plasma. We need you to construct a BFL system to collect the plasma and send it to the Central Command via cargo shuttle.
	<br>
	In order to complete the mission, you must to order a special pack in cargo called Mission goal, and install it content anywhere on the station.
	<br>
	Its base parts should be available for shipping by your cargo shuttle.
	<br><br>
	-Nanotrasen Naval Command"}


/datum/station_goal/bfl/on_report()
	//Unlock BFL related things
	var/datum/supply_packs/misc/station_goal/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bfl]"]
	P.special_enabled = TRUE

	P =  SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bfl_lens]"]
	P.special_enabled = TRUE

	P =  SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bfl_goal]"]
	P.special_enabled = TRUE

/datum/station_goal/bfl/check_completion()
	if(..())
		return TRUE
	for(var/obj/structure/toilet/golden_toilet/B)
		if(B && is_station_contact(B.z))
			return TRUE
	return FALSE

////////////
//Building//
////////////

/obj/item/circuitboard/machine/bfl_emitter
	name = "BFL Emitter (Machine Board)"
	build_path = /obj/machinery/bsa/back
	origin_tech = "engineering=4;combat=4;bluespace=4"
	req_components = list(
					/obj/item/stock_parts/manipulator/femto = 2,
					/obj/item/stock_parts/capacitor/quadratic = 5,
					/obj/item/stock_parts/micro_laser/quadultra = 20,
					/obj/item/gun/energy/lasercannon = 4,
					/obj/item/stack/cable_coil = 6)

/obj/item/circuitboard/machine/bfl_receiver
	name = "BFL Receiver (Machine Board)"
	build_path = /obj/machinery/bsa/back
	origin_tech = "engineering=4;combat=4;bluespace=4"
	req_components = list(
					/obj/item/stock_parts/capacitor/quadratic = 20,
					/obj/item/stack/cable_coil = 2)

///////////
//Emitter//
///////////
/obj/machinery/bfl_emitter
	name = "BFL Emitter"
	icon = 'icons/obj/machines/BFL_mission/Emitter.dmi'
	icon_state = "Emitter_Off"
	anchored = TRUE
	density = TRUE

	var/emag = FALSE
	var/state = FALSE
	var/obj/singularity/bfl_red/laser = null
	var/obj/machinery/bfl_receiver/receiver = FALSE
	var/start_time = 0
	var/list/obj/structure/fillers = list()
/obj/machinery/bfl_emitter/attack_hand(mob/user as mob)
	var/response
	if(state)
		response = alert(user, "You trying to deactivate BFL emitter machine, are you sure?", "BFL Emitter", "deactivate", "nothing")
	else
		response = alert(user, "You trying to activate BFL emitter machine, are you sure?", "BFL Emitter", "activate", "nothing")

	switch(response)
		if("deactivate")
			if(emag)
				visible_message("E.r$%^0r")
			else
				emitter_deactivate()
				start_time = world.time
		if("activate")
			if(world.time - start_time > 30 SECONDS)
				emitter_activate()
			else
				visible_message("Error, emitter is still cooling down")

/obj/machinery/bfl_emitter/emag_act()
	. = ..()
	if(!emag)
		emag = TRUE
		to_chat(usr, "Emitter successfully sabotaged")

/obj/machinery/bfl_emitter/process()
	if(!state)
		return
	if(laser)
		return
	if(!receiver || !receiver.state || emag)
		var/turf/rand_location = locate(rand((2*TRANSITIONEDGE), world.maxx - (2*TRANSITIONEDGE)), rand((2*TRANSITIONEDGE), world.maxy - (2*TRANSITIONEDGE)), 3)
		laser = new (rand_location)
		if(receiver)
			receiver.receiver_deactivate()
			receiver.lens.deactivate_lens()


/obj/machinery/bfl_emitter/proc/emitter_activate()
	state = TRUE
	icon_state = "Emitter_On"
	var/turf/location = get_step(src, NORTH)
	location.ex_act(1)

	if(receiver)
		receiver.mining = TRUE
		if(receiver.state)
			receiver.lens.activate_lens()
		return

	for(var/turf/T as anything in block(locate(1, 1, 3), locate(world.maxx, world.maxy, 3)))
		receiver = locate() in T
		if(receiver)
			break

	if(receiver)
		receiver.mining = TRUE
		//better to be safe than sorry
		if(receiver.state && receiver.lens)
			receiver.lens.activate_lens()
		return

/obj/machinery/bfl_emitter/proc/emitter_deactivate()
	state = FALSE
	icon_state = "Emitter_Off"
	if(receiver)
		receiver.mining = FALSE
		if(receiver.lens.state)
			receiver.lens.activate_lens()

	if(laser)
		qdel(laser)
		laser = null

//code stolen from bluespace_tap, including comment below. He was right about the new datum
//code stolen from dna vault, inculding comment below. Taking bets on that datum being made ever.
//TODO: Replace this,bsa and gravgen with some big machinery datum
/obj/machinery/bfl_emitter/Initialize()
	.=..()
	pixel_x = -32
	pixel_y = 0
	var/list/occupied = list()
	for(var/direct in list(NORTH, NORTHWEST, NORTHEAST, EAST, WEST))
		occupied += get_step(src, direct)
	occupied += locate(x, y + 2, z)
	occupied += locate(x + 1, y + 2, z)
	occupied += locate(x - 1, y + 2, z)
	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

/obj/machinery/bfl_emitter/Destroy()
	. = ..()
	emitter_deactivate()
	QDEL_LIST(fillers)

////////////
//Receiver//
////////////
/obj/item/storage/bag/ore/holding/bfl_storage/proc/empty_storage(turf/location)
	for(var/obj/item/I in contents)
		remove_from_storage(I, location)
		CHECK_TICK

/obj/machinery/bfl_receiver
	name = "BFL Receiver"
	icon = 'icons/obj/machines/BFL_mission/Hole.dmi'
	icon_state = "Receiver_Off"
	anchored = TRUE

	var/state = FALSE
	var/mining = FALSE
	var/obj/item/storage/bag/ore/holding/bfl_storage/internal
	var/internal_type = /obj/item/storage/bag/ore/holding/bfl_storage
	var/obj/machinery/bfl_lens/lens = null
	var/ore_type = FALSE

/obj/machinery/bfl_receiver/attack_hand(mob/user as mob)
	var/response
	if(state)
		response = alert(user, "You trying to deactivate BFL receiver machine, are you sure?", "BFL Receiver", "deactivate", "empty ore storage", "nothing")
	else
		response = alert(user, "You trying to activate BFL receiver machine, are you sure?", "BFL Receiver", "activate", "empty ore storage", "nothing")

	switch(response)
		if("deactivate")
			receiver_deactivate()
		if("activate")
			receiver_activate()
		if("empty ore storage")
			var/turf/location = get_step(src, SOUTH)
			internal.empty_storage(location)

/obj/machinery/bfl_receiver/process()
	if (!(mining && state))
		return
	switch(ore_type)
		if(2)
			internal.handle_item_insertion(new /obj/item/stack/ore/plasma, 1)
		if(1)
			internal.handle_item_insertion(new /obj/item/stack/ore/glass, 1)

/obj/machinery/bfl_receiver/New()
	.=..()
	pixel_x = -32
	pixel_y = -32
	//it's just works ¯\_(ツ)_/¯
	internal = new internal_type(src)

	var/turf/turf_under = get_turf(src)
	if(locate(/obj/bfl_crack) in turf_under)
		ore_type = 2 //plasma
	else if(istype(turf_under, /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface))
		ore_type = 1 //sand
	else
		ore_type = 0 //sosi bibu

/obj/machinery/bfl_receiver/proc/receiver_activate()
	if(lens)
		state = TRUE
		icon_state = "Receiver_On"
		density = 1
	else
		visible_message("Error, lens not found")

/obj/machinery/bfl_receiver/proc/receiver_deactivate()
	state = FALSE
	icon_state = "Receiver_Off"
	density = 0

/obj/machinery/bfl_receiver/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(istype(AM, /obj/machinery/bfl_lens))
		lens = AM

/obj/machinery/bfl_receiver/Uncrossed(atom/movable/AM)
	. = ..()
	if(AM == lens)
		lens = null
		if(state)
			receiver_deactivate()

////////
//Lens//
////////
/obj/machinery/bfl_lens
	name = "High-precision lens"
	desc = "Extremely fragile, handle with care."
	icon = 'icons/obj/machines/BFL_Mission/Hole.dmi'
	icon_state = "Lens_Off"
	max_integrity = 40
	layer = 2.91
	density = 1

	var/step_count = 0
	var/state = FALSE

/obj/machinery/bfl_lens/proc/activate_lens()
	icon_state = "Lens_On"
	state = TRUE
	overlays += image('icons/obj/machines/BFL_Mission/Laser.dmi', icon_state = "Laser_Blue", pixel_y = 64)

/obj/machinery/bfl_lens/proc/deactivate_lens()
	icon_state = "Lens_Off"
	overlays.Cut()
	state = FALSE

/obj/machinery/bfl_lens/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	default_unfasten_wrench(user, I, time = 60)

/obj/machinery/bfl_lens/Initialize()
	. = ..()
	pixel_x = -32
	pixel_y = -32

/obj/machinery/bfl_lens/Destroy()
	visible_message("Lens shatters in a million pieces")
	overlays.Cut()
	. = ..()


/obj/machinery/bfl_lens/Move(atom/newloc, direct, movetime)
	. = ..()
	if(!.)
		return
	if(step_count > 5)
		Destroy()
	step_count++


//everything else
/obj/bfl_crack
	name = "rich plasma deposit"
	can_be_hit = FALSE
	anchored = TRUE
	icon = 'icons/obj/machines/BFL_Mission/Hole.dmi'
	icon_state = "Crack"
	pixel_x = -32
	pixel_y = -32
	layer = HIGH_TURF_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	//space for gps tracker
	var/obj/item/tank/internal
	var/internal_type = /obj/item/gps/internal/bfl_crack

/obj/bfl_crack/Initialize(mapload)
	. = ..()
	internal = new internal_type(src)

/obj/item/gps/internal/bfl_crack
	gpstag = "NT signal"

/obj/singularity/bfl_red
	name = "BFL"
	desc = "Giant laser, which is supposed for mining"
	icon = 'icons/obj/machines/BFL_Mission/Laser.dmi'
	icon_state = "Laser_Red"
	speed_process = TRUE

/obj/singularity/bfl_red/move(force_move)
	if(!move_self)
		return 0

	var/movement_dir = pick(GLOB.alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move
	else
		loc = locate((world.time/16 % 255) + 1, (sin(world.time/16) + 1)*125 + 1, 3)
	step(src, movement_dir)

/obj/singularity/bfl_red/expand()
	. = ..()
	icon = 'icons/obj/machines/BFL_Mission/Laser.dmi'
	icon_state = "Laser_Red"
	pixel_x = -32
	pixel_y = 0
	grav_pull = 1

/obj/singularity/bfl_red/singularity_act()
	return 0

/obj/singularity/bfl_red/New(loc, var/starting_energy = 50, var/temp = 0)
	starting_energy = 250
	. = ..(loc, starting_energy, temp)

/obj/singularity/bfl_red/mish_SINGULARITY
	name = "Михаил"
	desc = "A gravitational singularity."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"

/obj/singularity/bfl_red/mish_SINGULARITY/expand()
	. = ..()
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"
	pixel_x = 0
	pixel_y = 0
	grav_pull = 0

/obj/singularity/bfl_red/mish_SINGULARITY/move(force_move)
	if(!move_self)
		return 0

	var/movement_dir = pick(GLOB.alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move

	step(src, movement_dir)
