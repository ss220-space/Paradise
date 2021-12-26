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
	var/state_death_star = FALSE
	var/obj/machinery/bfl_receiver/receiver = FALSE

	name = "BFL Emitter"
	icon = 'icons/obj/machines/BFL_mission/Emitter.dmi'
	icon_state = "Emitter_Off"


/obj/machinery/bfl_emitter/attack_hand(mob/user as mob)
	if(!emag)
		switch(state)
			if (1)
				emitter_deactivate()
			if (0)
				emitter_activate()

/obj/machinery/bfl_emitter/emitter_activate
//locate bfl_receiver на шахте
	state = TRUE
	icon_state = "Emitter_On"
	if(receiver)
    	return
		for(var/turf/T as anything in block(locate(1, 1, GLOB.space_manager.get_zlev_by_name(MINING)), locate(world.maxx, world.maxy, GLOB.space_manager.get_zlev_by_name(MINING))))
    		receiver = locate() in T
    		if(receiver)
        		break
	else
		//activate red laser
/obj/machinery/bfl_emitter/emitter_deactivate
//locate bfl_receiver на шахте
//если красный лазер включен, выключить-удалить его
	state = FALSE
	icon_state = "Emitter_Off"


/obj/machinery/bfl_emitter/New()

/obj/machinery/bfl_receiver
	var/state = FALSE

	name = "BFL Receiver"
	icon = 'icons/obj/machines/BFL_mission/Hole.dmi'
	icon_state = "Base_Close"

/obj/machinery/bfl_receiver/attack_hand(mob/user as mob)
	switch(state)
		if (1)
			state_bfl_receiver = FALSE
			icon_state = "Receiver_Off"
		if (0)
			state_bfl_receiver = TRUE
			icon_state = "Receiver_On"

/obj/machinery/bfl_receiver

/obj/bfl_crack
	name = "rich plasma deposit"
	can_be_hit = FALSE
	anchored = 1
	icon = 'icons/obj/machines/BFL_Mission/Hole.dmi'
	icon_state = "Crack"
	layer = HIGH_TURF_LAYER

	var/obj/item/tank/internal
	var/internal_type = /obj/item/gps/internal/bfl_crack

/obj/bfl_crack/Initialize(mapload)
	. = ..()
	internal = new internal_type(src)
	if(islist(armor))
		armor = getArmor(arglist(armor))
	else if(!armor)
		armor = getArmor()
	else if(!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during /obj Initialize()")

/obj/item/gps/internal/bfl_crack
	gpstag = "NT signal"
	//Сделать включение сигнала при получении репорта on_report
	//tracking = 0

/obj/singularity/bfl_red
