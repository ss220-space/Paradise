/datum/action/cooldown/spell/conjure/xeno_eggs
	name = "Plant alien eggs"
	desc = "Allows you to plant alien eggs on your current turf, does not work while in space."
	cooldown_time = 1 SECONDS
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	summon_type = list(/obj/structure/alien/egg)
	summon_radius = 0
	button_icon_state = "alien_egg"
	background_icon_state = "bg_alien"
	sound = null
	var/plasma_cost = 95

/datum/action/cooldown/spell/conjure/xeno_eggs/is_valid_target(atom/cast_on)
	return ..() && !is_space_or_openspace(cast_on.loc)

/datum/action/cooldown/spell/conjure/xeno_eggs/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src, plasma_cost)
	return handler

/datum/action/cooldown/spell/conjure/xeno_eggs/post_summon(atom/summoned_object, atom/cast_on)
	playsound_xenobuild(summoned_object)
