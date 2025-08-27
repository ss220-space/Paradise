/datum/wryn_building
	var/name // name of button
	var/wax_amount // cost of build
	var/icon_file = 'icons/mob/actions/actions_wryn.dmi'// dmi path
	var/icon_state = "wall" // icon in radial menu
	var/structure // structure path
	var/building_time = 5 SECONDS // time to build structure
	var/message_word // structure's name in chat

/datum/wryn_building/proc/wax_build(mob/living/carbon/human/user, wax_amount, obj/structure)
	if(user.getWax() < wax_amount)
		user.balloon_alert(user, "недостаточно воска!")
		return

	if(!user.loc || !do_after(user, building_time, user))
		return

	user.adjustWax(-wax_amount)
	user.visible_message(("[user] выделя[pluralize_ru(user.gender, "ет", "ют")] кучу воска и формиру[pluralize_ru(user.gender, "ет", "ют")] из неё [message_word]."))

	new structure(user.loc)

/datum/wryn_building/wall
	name = "Соты (50)"
	wax_amount = 50
	icon_state = "wall"
	structure = /obj/structure/wryn/wax/wall
	message_word = "соты"

/datum/wryn_building/window
	name = "Прозрачные соты (50)"
	wax_amount = 50
	icon_state = "window"
	structure = /obj/structure/wryn/wax/window
	message_word = "прозрачные соты"

/datum/wryn_building/floor
	name = "Пол из воска (25)"
	wax_amount = 25
	icon_state = "floor"
	structure = /obj/structure/wryn/floor
	building_time = 1 SECONDS
	message_word = "пол из воска"

/datum/wryn_building/door
	name = "Дверь из воска (75)"
	wax_amount = 75
	icon_state = "door"
	structure = /obj/structure/alien/resin/door/wax
	building_time = 10 SECONDS
	message_word = "дверь из воска"
