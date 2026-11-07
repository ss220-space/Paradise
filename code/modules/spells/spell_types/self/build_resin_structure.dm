// Defines include required plasma in brackets
#define ALIEN_RESIN_WALL "Смоляная стена (60)"
#define ALIEN_RESIN_DOOR "Смоляная дверь (50)"
#define ALIEN_RESIN_THICK_WALL "Толстая смоляная стена (60)"
#define ALIEN_RESIN_THICK_DOOR "Толстая смоляная дверь (50)"
#define ALIEN_RESIN_NEST "Смоляное гнездо (30)"

/datum/action/cooldown/spell/build_resin
	name = "Выделить смолу"
	desc = "Выделить прочную пластичную смолу."
	button_icon = 'icons/mob/xeno/structures.dmi'
	button_icon_state = "nest"
	background_icon_state = "bg_alien"
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 1
	var/plasma_cost = 0
	var/in_process = FALSE

/datum/action/cooldown/spell/build_resin/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src)
	return handler

/datum/action/cooldown/spell/build_resin/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/alien/host = cast_on

	if(in_process)
		reset_spell_cooldown(owner)
		return

	var/list/resin_params = list()

	// Resin drones build thick walls; regular drones build regular walls
	var/is_resin_drone = istype(host, /mob/living/carbon/alien/humanoid/drone/resin_drone)

	if(is_resin_drone)
		resin_params["Plasma Amount"] = list(
			ALIEN_RESIN_THICK_WALL = 60,
			ALIEN_RESIN_THICK_DOOR = 50,
			ALIEN_RESIN_NEST = 30
		)

		resin_params["Process Time"] = list(
			ALIEN_RESIN_THICK_WALL = 3 SECONDS,
			ALIEN_RESIN_THICK_DOOR = 5 SECONDS,
			ALIEN_RESIN_NEST = 1 SECONDS
		)

		resin_params["Cooldown"] = list(
			ALIEN_RESIN_THICK_WALL = 5 SECONDS,
			ALIEN_RESIN_THICK_DOOR = 5 SECONDS,
			ALIEN_RESIN_NEST = 2 SECONDS
		)

		resin_params["Structure"] = list(
			ALIEN_RESIN_THICK_WALL = /obj/structure/alien/resin/wall/thick,
			ALIEN_RESIN_THICK_DOOR = /obj/structure/alien/resin/door/thick,
			ALIEN_RESIN_NEST = /obj/structure/bed/nest
		)

		resin_params["Image"] = list(
			ALIEN_RESIN_THICK_WALL = image(icon = 'icons/mob/xeno/xeno_building.dmi', icon_state = "thick_resin_wall"),
			ALIEN_RESIN_THICK_DOOR = image(icon = 'icons/mob/xeno/xeno_building.dmi', icon_state = "thick_resin_door"),
			ALIEN_RESIN_NEST = image(icon = 'icons/mob/xeno/xeno_building.dmi', icon_state = "resin_nest")
		)
	else
		resin_params["Plasma Amount"] = list(
			ALIEN_RESIN_WALL = 60,
			ALIEN_RESIN_DOOR = 50,
			ALIEN_RESIN_NEST = 30
		)

		resin_params["Process Time"] = list(
			ALIEN_RESIN_WALL = 1.5 SECONDS,
			ALIEN_RESIN_DOOR = 3 SECONDS,
			ALIEN_RESIN_NEST = 1 SECONDS
		)

		resin_params["Cooldown"] = list(
			ALIEN_RESIN_WALL = 2 SECONDS,
			ALIEN_RESIN_DOOR = 3 SECONDS,
			ALIEN_RESIN_NEST = 2 SECONDS
		)

		resin_params["Structure"] = list(
			ALIEN_RESIN_WALL = /obj/structure/alien/resin/wall,
			ALIEN_RESIN_DOOR = /obj/structure/alien/resin/door,
			ALIEN_RESIN_NEST = /obj/structure/bed/nest
		)

		resin_params["Image"] = list(
			ALIEN_RESIN_WALL = image(icon = 'icons/mob/xeno/xeno_building.dmi', icon_state = "resin_wall"),
			ALIEN_RESIN_DOOR = image(icon = 'icons/mob/xeno/xeno_building.dmi', icon_state = "resin_door"),
			ALIEN_RESIN_NEST = image(icon = 'icons/mob/xeno/xeno_building.dmi', icon_state = "resin_nest")
		)

	var/choice = show_radial_menu(host, host, resin_params["Image"], radius = 40, custom_check = CALLBACK(src, PROC_REF(check_availability), host))

	if(!choice || !check_availability(host, resin_params["Plasma Amount"][choice]))
		reset_spell_cooldown(host)
		return

	host.visible_message(span_warning("[DECLENT_RU_CAP(host, NOMINATIVE)] изрыгает густую фиолетовую субстанцию и формирует из неё структуру!"))

	in_process = TRUE
	if(!do_after(host, resin_params["Process Time"][choice], host))
		in_process = FALSE
		reset_spell_cooldown(host)
		return
	in_process = FALSE

	if(!check_availability(host, resin_params["Plasma Amount"][choice]))
		reset_spell_cooldown(host)
		return

	cooldown_time = resin_params["Cooldown"][choice]

	host.adjust_alien_plasma(-(resin_params["Plasma Amount"][choice]))

	var/build_path = resin_params["Structure"][choice]
	var/obj/alien_structure = new build_path(host.loc)

	playsound_xenobuild(alien_structure)

/datum/action/cooldown/spell/build_resin/proc/check_availability(mob/living/carbon/user, plasma_amount)
	if(!istype(user))
		return FALSE

	if(QDELETED(user) || QDELETED(src))
		return FALSE

	if(isspaceturf(user.loc))
		user.balloon_alert(user, "невозможно!")
		return FALSE

	if(plasma_amount && user.get_plasma() < plasma_amount)
		user.balloon_alert(user, "недостаточно плазмы!")
		return FALSE

	if(user.incapacitated())
		user.balloon_alert(user, "невозможно!")
		return FALSE

	var/turf/source_turf = get_turf(user)
	if((locate(/obj/structure/alien/resin) in source_turf.contents) || (locate(/obj/structure/bed/nest) in source_turf.contents))
		user.balloon_alert(user, "невозможно!")
		return FALSE

	return TRUE

#undef ALIEN_RESIN_WALL
#undef ALIEN_RESIN_DOOR
#undef ALIEN_RESIN_THICK_WALL
#undef ALIEN_RESIN_THICK_DOOR
#undef ALIEN_RESIN_NEST

