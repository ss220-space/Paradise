//Crew has to build receiver on the special
var/crack_GPS
/datum/station_goal/bfl
	name = "Mining laser"
	var/goal = 45000

/datum/station_goal/bfl/get_report()
	return {"<b>Mining laser construcion</b><br>"}


/datum/station_goal/bfl/on_report()
	//Unlock BFL parts
	//var/datum/supply_packs/misc/station_goal/bsa/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bsa]"]
	//P.special_enabled = TRUE


/datum/station_goal/bfl/check_completion()
	if(..())
		return TRUE
	return FALSE

/obj/machinery/bfl_emitter
	var/emag = FALSE
	var/state = FALSE
	var/obj/singularity/bfl_red/laser = null
	var/obj/machinery/bfl_receiver/receiver = FALSE
	var/start_time = 0
	var/list/obj/structure/fillers = list()

	name = "BFL Emitter"
	icon = 'icons/obj/machines/BFL_mission/Emitter.dmi'
	icon_state = "Emitter_Off"
	anchored = 1
	denstiy = 1

/obj/machinery/bfl_emitter/attack_hand(mob/user as mob)
	switch(state)
		if (1)
			if(!emag)
				emitter_deactivate()
		if (0)
			if(world.time - start_time > 30 SECONDS)
				emitter_activate()
				start_time = world.time
			else
				to_chat(usr, "Error, emitter is still cooling down")

/obj/machinery/bfl_emitter/emag_act()
	. = ..()
	if(!emag)
		emag = TRUE
		to_chat(usr, "Emitter successfully sabotaged")

/obj/machinery/bfl_emitter/process()
	.=..()
	if(!receiver || !receiver.state || emag)
		if(!laser)
			var/turf/rand_location = locate(rand((2*TRANSITIONEDGE), world.maxx - (2*TRANSITIONEDGE)), rand((2*TRANSITIONEDGE), world.maxy - (2*TRANSITIONEDGE)), 3)
			laser = new (rand_location)
			if(receiver)
				receiver.receiver_deactivate()


/obj/machinery/bfl_emitter/proc/emitter_activate()
//locate bfl_receiver at lavaland
	state = TRUE
	icon_state = "Emitter_On"
	var/turf/location = get_step(src, NORTH)
	location.ex_act(1)

	if(receiver)
		receiver.mining = TRUE
		return

	for(var/obj/machinery/bfl_receiver/T as anything in block(locate(1, 1, 3), locate(world.maxx, world.maxy, 3)))
		receiver = locate() in T
		if(receiver)
			break


/obj/machinery/bfl_emitter/proc/emitter_deactivate()
	state = FALSE
	icon_state = "Emitter_Off"
	if(receiver)
		receiver.mining = FALSE

	if(laser)
		qdel(laser)
		laser = null

//code stolen from bluespace_tap, including comment below.
//code stolen from dna vault, inculding comment below. Taking bets on that datum being made ever.
//TODO: Replace this,bsa and gravgen with some big machinery datum
/obj/machinery/bfl_emitter/New()
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

/obj/machinery/bfl_receiver
	var/state = FALSE
	var/mining = FALSE
	var/obj/item/storage/internal

	name = "BFL Receiver"
	icon = 'icons/obj/machines/BFL_mission/Hole.dmi'
	icon_state = "Receiver_Off"
	anchored = 1

/obj/machinery/bfl_receiver/attack_hand(mob/user as mob)
	switch(state)
		if (1)
			receiver_deactivate()
		if (0)
			receiver_activate()

/obj/machinery/bfl_receiver/process()
	if (mining && state)
		internal += new /obj/item/stack/ore/plasma

/obj/machinery/bfl_receiver/verb/empty_storage()
	set name = "Empty the storage"
	set category = "Object"

	internal.quick_empty()

//make big machines like in harvester
/obj/machinery/bfl_receiver/New()
	.=..()
	verbs += /obj/machinery/bfl_receiver/verb/empty_storage
	//locate bfl_crack
	//if !located, locate lavaland turf
	//if !lavalnd turf

/obj/machinery/bfl_receiver/proc/receiver_activate()
	state = TRUE
	icon_state = "Receiver_On"

/obj/machinery/bfl_receiver/proc/receiver_deactivate()
	state = FALSE
	icon_state = "Receiver_Off"

/obj/bfl_crack
	name = "rich plasma deposit"
	can_be_hit = FALSE
	anchored = 1
	icon = 'icons/obj/machines/BFL_Mission/Hole.dmi'
	icon_state = "Crack"
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
	//Сделать включение сигнала при получении репорта on_report
	//tracking = 0

/obj/singularity/bfl_red
	name = "BFL"
	icon = 'icons/obj/machines/BFL_Mission/Laser.dmi'
	icon_state = "Laser_Red"

/obj/singularity/bfl_red/expand()
	.=..()
	icon = 'icons/obj/machines/BFL_Mission/Laser.dmi'
	icon_state = "Laser_Red"
	pixel_x = -32
	pixel_y = 0
	grav_pull = 1

/obj/singularity/bfl_red/singularity_act()
	return 0

/obj/singularity/bfl_red/New(loc, var/starting_energy = 50, var/temp = 0)
	starting_energy = 250
	.=..(loc, starting_energy, temp)

/obj/singularity/bfl_red/mish_SINGULARITY //nofix
	name = "Михаил"
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"

/obj/singularity/bfl_red/mish_SINGULARITY/expand()
	.=..()
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"
	pixel_x = 0
	pixel_y = 0
	grav_pull = 0
