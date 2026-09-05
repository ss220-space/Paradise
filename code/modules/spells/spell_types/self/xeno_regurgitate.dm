/datum/action/cooldown/spell/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach onto the ground."
	button_icon_state = "alien_barf"
	background_icon_state = "bg_alien"
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 5 SECONDS

/datum/action/cooldown/spell/regurgitate/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src)
	return handler

/datum/action/cooldown/spell/regurgitate/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/alien/humanoid/xeno = cast_on
	for(var/mob/mob in xeno.stomach_contents)
		var/turf/output_loc = xeno.loc
		mob.forceMove(output_loc)
		xeno.visible_message(span_alertalien("<b>[xeno] hurls out the contents of [p_their()] stomach!"))
		return
	xeno.visible_message(span_alertalien("<b>[xeno] dry heaves!"))

