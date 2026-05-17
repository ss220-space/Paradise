
/// Used by station traits to damage/destroy atoms when round starts
/atom/proc/change_from_station_trait(station_trait)
	return

/turf/simulated/floor/change_from_station_trait(station_trait)
	if(prob(80) || station_trait != STATION_TRAIT_POST_WAR_TRASH)
		return

	if(prob(70))
		burn_tile()
		return

	break_tile()

	if(prob(45))
		new /obj/item/ammo_casing/c45/empty(src)

/turf/simulated/wall/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_POST_WAR_TRASH && prob(15))
		add_multiple_dents(rand(1, 10), WALL_DENT_SHOT)

/obj/machinery/vending/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_POST_WAR_TRASH && prob(5))
		obj_break()
		return

	if(station_trait == STATION_TRAIT_REVOLUTIONARY_TRASHING && prob(70))
		obj_break()

/obj/machinery/light/change_from_station_trait(station_trait)
	if((station_trait == STATION_TRAIT_REVOLUTIONARY_TRASHING || station_trait == STATION_TRAIT_POST_WAR_TRASH) && prob(40))
		break_light_tube(skip_sound_and_sparks = TRUE)

/obj/machinery/computer/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_POST_WAR_TRASH && prob(5))
		take_damage(rand(150, 300))
		return

	if(station_trait == STATION_TRAIT_REVOLUTIONARY_TRASHING && prob(40))
		take_damage(160)

/obj/machinery/computer/communications/change_from_station_trait(station_trait)
	return

/obj/machinery/suit_storage_unit/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_LOOTED_ARMORY && prob(40))
		qdel(src)

/obj/machinery/suit_storage_unit/security/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_UPGRADED_ARMORY)
		new /obj/machinery/suit_storage_unit/security/warden(loc)
		qdel(src)
		return
	return ..()

/obj/machinery/flasher/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_LOOTED_ARMORY && prob(60))
		qdel(src)

/obj/machinery/door/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_REVOLUTIONARY_TRASHING && prob(50))
		take_damage(rand(200, 400))
		return

	if(station_trait == STATION_TRAIT_POST_WAR_TRASH && prob(10))
		if(prob(10))
			emag_act()
			return
		take_damage(rand(150, 300))

/obj/structure/closet/secure_closet/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_POST_WAR_TRASH && prob(20))
		emag_act()

/obj/structure/closet/fireaxecabinet/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_REVOLUTIONARY_TRASHING)
		take_damage(90)

/obj/structure/chair/change_from_station_trait(station_trait)
	if(station_trait != STATION_TRAIT_REVOLUTIONARY_TRASHING && prob(40))
		return

	take_damage(300)

/obj/structure/window/change_from_station_trait(station_trait)
	if((station_trait == STATION_TRAIT_REVOLUTIONARY_TRASHING || station_trait == STATION_TRAIT_POST_WAR_TRASH) && prob(45))
		take_damage(rand(40, 90)) //fulltile windows will be safe

/obj/structure/table/change_from_station_trait(station_trait)
	if(station_trait != STATION_TRAIT_REVOLUTIONARY_TRASHING && prob(60))
		return

	take_damage(100)

/obj/vehicle/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_LOOTED_ARMORY && prob(70))
		qdel(src)

/obj/item/gun/energy/gun/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_UPGRADED_ARMORY)
		new /obj/item/gun/energy/gun/pdw9(loc)
		qdel(src)
		return
	return ..()

/obj/item/bedsheet/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_REVOLUTIONARY_TRASHING)
		qdel(src)

/obj/item/shield/riot/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_UPGRADED_ARMORY)
		new /obj/item/shield/riot/tele(loc)
		qdel(src)
		return
	return ..()

/obj/item/flag/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_POST_WAR_TRASH && prob(40))
		new /obj/item/flag/syndi(loc)
		qdel(src)
		return

	if(station_trait == STATION_TRAIT_REVOLUTIONARY_TRASHING)
		new /obj/item/flag/ussp(loc)
		qdel(src)

/obj/item/change_from_station_trait(station_trait)
	if(station_trait == STATION_TRAIT_LOOTED_ARMORY && prob(50))
		qdel(src)
