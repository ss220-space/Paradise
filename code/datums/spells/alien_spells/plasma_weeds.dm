/obj/effect/proc_holder/spell/alien_spell/plant_weeds
	name = "Plant weeds"
	desc = "Allows you to plant some alien weeds on the floor below you. Does not work while in space."
	base_cooldown = 10 SECONDS
	plasma_cost = 50
	var/weed_type = /obj/structure/alien/weeds/node
	var/weed_name = "alien weed node"
	action_icon_state = "alien_plant"


/obj/effect/proc_holder/spell/alien_spell/plant_weeds/queen
	plasma_cost = 0


/obj/effect/proc_holder/spell/alien_spell/plant_weeds/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/alien_spell/plant_weeds/cast(list/targets, mob/living/carbon/user)
	if(!isturf(user.loc))
		to_chat(user, span_noticealien("You cannot plant [weed_name]s inside something!"))
		revert_cast()
		return

	var/turf/turf = user.loc

	if(locate(weed_type) in turf)
		to_chat(user, span_noticealien("There's already an [weed_name] here."))
		revert_cast()
		return

	if(isspaceturf(turf))
		to_chat(user, span_noticealien("You cannot plant [weed_name]s in space."))
		revert_cast()
		return

	playsound_xenobuild(user)
	user.visible_message(span_alertalien("[user] has planted a [weed_name]!"))
	
	new weed_type(turf)
