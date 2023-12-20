#define LIVING_PLAYERS_COUNT_FOR_1_PRAETORIAN 25

/obj/effect/proc_holder/spell/alien_spell/evolve
	desc = "Evolve into reporting this issue."
	action_icon_state = "larva2"
	action_icon = 'icons/mob/alien.dmi'
	action_icon_state = "AlienMMI"
	var/queen_check = FALSE
	var/evolution_path = /mob/living/carbon/alien/larva


/obj/effect/proc_holder/spell/alien_spell/evolve/praetorian
	name = "Evolve"
	desc = "Become a Praetorian, Royal Guard to the Queen."
	action_icon_state = "aliens_running"
	evolution_path = /mob/living/carbon/alien/humanoid/praetorian


/obj/effect/proc_holder/spell/alien_spell/evolve/queen
	name = "Evolve"
	desc = "Evolve into an Alien Queen."
	action_icon_state = "alienq_running"
	queen_check = TRUE
	evolution_path = /mob/living/carbon/alien/humanoid/queen/large


/obj/effect/proc_holder/spell/alien_spell/evolve/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/alien_spell/evolve/cast(list/targets, mob/living/carbon/alien/user)
	if(!user.can_evolve)
		to_chat(user, span_warning("We have nowhere to evolve further!"))
		return

	if(user.evolution_points < user.max_evolution_points)
		to_chat(user, span_warning("We are not ready to evolve yet!"))
		return

	if(user.has_brain_worms())
		to_chat(user, span_warning("We cannot perform this ability at the present time!"))
		return

	if(queen_check)
		if(user.queen_count >= user.queen_maximum)
			to_chat(user, span_warning("We already have a queen."))
			return
		else
			user.queen_count++

	to_chat(user, span_noticealien("You begin to evolve!"))
	user.visible_message(span_alertalien("[user] begins to twist and contort!"))
	var/mob/living/carbon/alien/new_xeno = new evolution_path(user.loc)
	user.mind.transfer_to(new_xeno)
	new_xeno.mind.name = new_xeno.name
	playsound_xenobuild(user.loc)
	SSblackbox.record_feedback("tally", "alien_growth", 1, "[new_xeno]")
	qdel(user)

/obj/effect/proc_holder/spell/alien_spell/evolve/praetorian/cast(list/targets, mob/living/carbon/user)
	var/mob/living/carbon/alien/spell_owner = user
	if(!istype(spell_owner))
		return

	var/living_players_count = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.client && player.stat != DEAD)
			living_players_count++

	if(spell_owner.praetorian_count < (living_players_count/LIVING_PLAYERS_COUNT_FOR_1_PRAETORIAN))
		..()
	else
		to_chat(user, span_warning("We have too many praetorians."))

#undef LIVING_PLAYERS_COUNT_FOR_1_PRAETORIAN
