/datum/action/cooldown/spell/conjure/plant_weeds
	name = "Plant weeds"
	desc = "Allows you to plant some alien weeds on the floor below you. Does not work while in space."
	cooldown_time = 10 SECONDS
	button_icon_state = "alien_plant"
	background_icon_state = "bg_alien"
	summon_radius = 0
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	sound = ""
	summon_type = list(/obj/structure/alien/weeds/node)
	var/plasma_cost = 50
	var/weed_name = "alien weed node"

/datum/action/cooldown/spell/conjure/plant_weeds/queen
	plasma_cost = 0

/datum/action/cooldown/spell/conjure/plant_weeds/New(Target, original)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/datum/action/cooldown/spell/conjure/plant_weeds/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/datum/action/cooldown/spell/conjure/plant_weeds/process()
	. = ..()
	build_all_button_icons()

/datum/action/cooldown/spell/conjure/plant_weeds/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src, plasma_cost)
	return handler

/datum/action/cooldown/spell/conjure/plant_weeds/can_cast_spell(feedback)
	if(!..())
		return FALSE
	if(!isturf(owner.loc))
		if(feedback)
			to_chat(owner, span_noticealien("You cannot plant [weed_name]s inside something!"))
		return FALSE

	var/turf/turf = owner.loc

	if(locate(/obj/structure/alien/weeds/node) in turf)
		if(feedback)
			to_chat(owner, span_noticealien("There's already an [weed_name] here."))
		return FALSE

	if(isspaceturf(turf))
		if(feedback)
			to_chat(owner, span_noticealien("You cannot plant [weed_name]s in space."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/conjure/plant_weeds/post_summon(atom/summoned_object, atom/cast_on)
	playsound_xenobuild(summoned_object)
	cast_on.visible_message(span_alertalien("[cast_on] has planted a [weed_name]!"))

