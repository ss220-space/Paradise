/datum/wryn_building
	var/wax_amount // cost of build
	var/icon = 'icons/mob/actions/actions_wryn.dmi'// dmi path
	var/icon_state // icon in radial menu
	var/structure // structure path
	var/building_time // time to build structure


/datum/wryn_building/proc/wax_check(mob/living/carbon/human/user, wax_amount)
	if(user.getWax() < wax_amount)
		user.balloon_alert(user, "недостаточно воска!")
		return

/datum/wryn_building/proc/wax_building(mob/living/carbon/human/user, wax_amount, obj/structure)
	if(do_after(usr, building_time, usr))
		user.adjustWax(-wax_amount)
		user.visible_message(("[user] выделя[pluralize_ru(user.gender, "ет", "ют")] кучу воска и формиру[pluralize_ru(user.gender, "ет", "ют")] из неё [structure.declent_ru(GENITIVE)]"))
		new structure(user.loc)


/datum/wryn_building/wall
	wax_amount = 50
	icon_state = "wall"
	structure = /obj/structure/wryn/wax/wall
	building_time = 5 SECONDS

/datum/wryn_building/window
	wax_amount = 50
	icon_state = "window"
	structure = /obj/structure/wryn/wax/window
	building_time = 5 SECONDS

/datum/wryn_building/floor
	wax_amount = 25
	icon_state = "floor"
	structure = /obj/structure/wryn/floor
	building_time = 1 SECONDS

/datum/wryn_building/door
	wax_amount = 75
	icon_state = "door"
	structure = /obj/structure/alien/resin/door/wax
	building_time = 10 SECONDS
