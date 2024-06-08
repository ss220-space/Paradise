#define DEFAULT_TIME_LIMIT 5 MINUTES

/**
 *  Special implant that will definetly end brawler's life. Sad, but we have queue to go!
 */
/obj/item/implant/postponed_death
	name = "Postponed death implant"
	desc = "Kills you after specific amount of time"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	var/time_to_live = DEFAULT_TIME_LIMIT
	actions_types = list(/datum/action/item_action/postponed_death)

/datum/action/item_action/postponed_death
	name = "Suicide"
	check_flags = FALSE


/obj/item/implant/postponed_death/implant(mob/source, mob/user)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), time_to_live)

/obj/item/implant/postponed_death/activate()
	imp_in.melt()

#undef DEFAULT_TIME_LIMIT
