GLOBAL_LIST_EMPTY(bump_teleporters)

/obj/effect/bump_teleporter
	name = "bump-teleporter"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	var/id = null	// id of this bump_teleporter.
	var/id_target = null	// id of bump_teleporter which this moves you to.
	invisibility = INVISIBILITY_ABSTRACT	// nope, can't see this
	anchored = TRUE
	density = TRUE
	opacity = 0

/obj/effect/bump_teleporter/New()
	..()
	GLOB.bump_teleporters += src

/obj/effect/bump_teleporter/Destroy()
	GLOB.bump_teleporters -= src
	return ..()

/obj/effect/bump_teleporter/singularity_act()
	return

/obj/effect/bump_teleporter/singularity_pull()
	return


/obj/effect/bump_teleporter/Bumped(atom/movable/moving_atom)
	. = ..()
	if(!id_target || !ismob(moving_atom))
		return .

	for(var/obj/effect/bump_teleporter/teleporter as anything in GLOB.bump_teleporters)
		if(teleporter.id == id_target)
			moving_atom.forceMove(teleporter.loc)
			process_special_effects(moving_atom)
			break


///Special effects for teleporter. Supposed to be overriden.
/obj/effect/bump_teleporter/proc/process_special_effects(mob/living/target)
	return
