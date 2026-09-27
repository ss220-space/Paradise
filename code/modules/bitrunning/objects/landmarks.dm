/obj/effect/landmark/bitrunning
	name = "Generic bitrunning effect"
	icon = 'icons/effects/bitrunning.dmi'
	icon_state = "crate"

/obj/effect/landmark/bitrunning/loot_signal
	name = "Mysterious aura"

/obj/effect/landmark/bitrunning/hololadder_spawn
	name = "Bitrunning hololadder spawn"
	icon_state = "hololadder"

/obj/effect/landmark/bitrunning/permanent_exit
	name = "Bitrunning permanent exit"
	icon_state = "perm_exit"

/obj/effect/landmark/bitrunning/cache_goal_turf
	name = "Bitrunning goal turf"
	icon_state = "goal"

/obj/effect/landmark/bitrunning/cache_spawn
	name = "Bitrunning crate spawn"

/obj/effect/landmark/bitrunning/curiosity_spawn
	name = "Bitrunning curiosity spawn"

/obj/effect/landmark/bitrunning/mob_segment
	name = "Bitrunning modular mob segment"
	icon_state = "mob_segment"

/obj/effect/landmark/bitrunning/crate_replacer
	name = "Bitrunning Goal Crate Randomizer"

/obj/effect/landmark/bitrunning/crate_replacer/Initialize(mapload)
	. = ..()

#ifdef UNIT_TESTS
	return
#endif

	var/list/crate_list = list()
	var/obj/structure/closet/crate/secure/bitrunning/encrypted/encrypted_crate
	var/area/my_area = get_area(src)

	for(var/turf/area_turf in my_area)
		for(var/obj/structure/closet/crate/crate_to_check in area_turf)
			if(istype(crate_to_check, /obj/structure/closet/crate/secure/bitrunning/encrypted))
				encrypted_crate = crate_to_check
				crate_to_check.desc += span_hypnophrase(" Кажется, это тот самый ящик!")
			else
				crate_list += crate_to_check
			crate_to_check.name = "Unidentified Crate"

	if(isnull(encrypted_crate))
		stack_trace("Bitrunning Goal Crate Randomizer failed to find an encrypted crate to swap positions for.")
		return

	if(!length(crate_list))
		stack_trace("Bitrunning Goal Crate Randomizer failed to find any NORMAL crates to swap positions for.")
		return

	var/original_location = encrypted_crate.loc
	var/obj/structure/closet/crate/selected_crate = pick(crate_list)

	encrypted_crate.abstract_move(selected_crate.loc)
	selected_crate.abstract_move(original_location)
