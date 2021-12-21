//Crew has to build receiver on the special

/datum/station_goal/bfl
	name = "Mining laser"
	var/goal = 45000

/datum/station_goal/bfl/get_report()
	return {"<b>Mining laser construcion</b><br>"}


/datum/station_goal/bfl/on_report()
	//Unlock BFL parts
	var/datum/supply_packs/misc/station_goal/bsa/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bsa]"]
	P.special_enabled = TRUE


/datum/station_goal/bfl/check_completion()
	if(..())
		return TRUE
	return FALSE

/obj/machinery/bfl_emitter
	name = "BFL Emitter"
	icon = 'icons/obj/machines/BFL_mission/Emitter.dmi'
	icon_state = "Emitter_Off"

/obj/machinery/bfl_emitter/attack_hand(mob/user as mob)

/obj/machinery/bfl_receiver
	name = "BFL Receiver"
	icon = 'icons/obj/machines/BFL_mission/Hole.dmi'
	icon_state = "Base_Close"
	var/emag = FALSE

/obj/machinery/bfl_receiver/attack_hand(mob/user as mob)
	if(!emagged)

/obj/bfl_crack
	name = "rich plasma deposit"
	can_be_hit = FALSE
	anchored = 1
	icon = 'icons/obj/machines/BFL_Mission/Hole.dmi'
	icon_state = "Crack"

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

//for ref
/obj/structure/morgue/attack_hand(mob/user as mob)
	if(connected)
		for(var/atom/movable/A in connected.loc)
			if(!( A.anchored ))
				A.forceMove(src)
		playsound(loc, open_sound, 50, 1)
		QDEL_NULL(connected)
	else
		playsound(loc, open_sound, 50, 1)
		connected = new /obj/structure/m_tray( loc )
		step(connected, dir)
		connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, dir)
		if(T.contents.Find(connected))
			connected.connected = src
			icon_state = "morgue0"
			for(var/atom/movable/A in src)
				A.forceMove(connected.loc)
			connected.icon_state = "morguet"
			connected.dir = dir
		else
			QDEL_NULL(connected)
	add_fingerprint(user)
	update()
	return
