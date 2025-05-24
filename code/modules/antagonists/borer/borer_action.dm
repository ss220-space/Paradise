/datum/action/innate/borer
	background_icon_state = "bg_alien"
	var/cost

/datum/action/innate/borer/talk_to_host
	name = "Converse with Host"
	desc = "Send a silent message to your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_host/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.Communicate()

/datum/action/innate/borer/toggle_hide
	name = "Toggle Hide"
	desc = "Become invisible to the common eye. Toggled on or off."
	button_icon_state = "borer_hiding_false"

/datum/action/innate/borer/toggle_hide/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.hide_borer()
	button_icon_state = "borer_hiding_[borer.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/borer/talk_to_borer
	name = "Converse with Borer"
	desc = "Communicate mentally with your borer."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_borer/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	borer.host = owner
	borer.host.borer_comm()

/datum/action/innate/borer/talk_to_brain
	name = "Converse with Trapped Mind"
	desc = "Communicate mentally with the trapped mind of your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_brain/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	borer.host = owner
	borer.host.trapped_mind_comm()

/datum/action/innate/borer/take_control
	name = "Assume Control"
	desc = "Fully connect to the brain of your host."
	button_icon_state = "borer_brain"

/datum/action/innate/borer/take_control/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.bond_brain()

/datum/action/innate/borer/give_back_control
	name = "Release Control"
	desc = "Release control of your host's body."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/give_back_control/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	borer.host = owner
	borer.host.release_control()

/datum/action/innate/borer/leave_body
	name = "Release Host"
	desc = "Slither out of your host."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/leave_body/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.release_host()

/datum/action/innate/borer/make_chems
	name = "Secrete Chemicals"
	desc = "Push some chemicals into your host's bloodstream."
	button_icon_state = "fleshmend"

/datum/action/innate/borer/make_chems/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.secrete_chemicals()

/datum/action/innate/borer/make_larvae
	name = "Reproduce"
	desc = "Spawn several young."
	button_icon_state = "borer_reproduce"
	cost = 100

/datum/action/innate/borer/make_larvae/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()

	if(!borer)
		return

	if(borer.chemicals < cost)
		to_chat(borer.host, "Вам требуется [cost] химикат[declension_ru(cost, "", "а", "ов")] для размножения!")
		return

	borer.chemicals -= cost

	borer.host.visible_message(
		span_danger("[borer.host] яростно блюёт, изрыгая рвотные массы вместе с извивающимся, похожим на слизня существом!"),
		span_danger("Ваш хозяин дёргается и вздрагивает, когда вы быстро выводите личинку из своего слизнеподобного тела.")
		)

	var/turf/turf = get_turf(borer.host)
	turf.add_vomit_floor()

	new /mob/living/simple_animal/borer(turf, borer.generation + 1)
	SEND_SIGNAL(borer, COMSIG_BORER_REPRODUCE, turf)

	return

/datum/action/innate/borer/torment
	name = "Torment Host"
	desc = "Punish your host with agony."
	button_icon_state = "blind"
	cost = 70

/datum/action/innate/borer/torment/Activate()
	var/mob/living/simple_animal/borer/borer = isborer(owner) ? owner : owner.has_brain_worms()
	var/mob/living/carbon/host = borer.host

	var/total_cost = cost - (borer.antag_datum.borer_rank.rank_ability_amplifier * 10)

	if(borer.chemicals < total_cost)
		to_chat(owner, "Вам требуется [total_cost] химикат[declension_ru(total_cost, "", "а", "ов")] для вызова психической агонии!")
		return

	borer.chemicals -= total_cost

	to_chat(owner, span_danger("Вы посылаете карающий всплеск психической агонии в мозг своего носителя."))
	var/target = borer.host_brain ? borer.host_brain : host
	to_chat(target, span_danger(span_fontsize3("Ужасная, жгучая агония пронзает вас насквозь, \
			вырывая беззвучный крик из глубин вашего разума!")))

	if(borer.host_brain?.host_resisting)
		borer.host_brain.resist()
		return

	host.adjustStaminaLoss(100)

/datum/action/innate/borer/sneak_mode
	name = "Sneak mode"
	desc = "Hides your status from medical huds."
	button_icon_state = "chameleon_skin"

/datum/action/innate/borer/sneak_mode/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	borer.host = owner
	borer.host.sneak_mode()

/datum/action/innate/borer/focus_menu
	name = "Focus menu"
	desc = "Reinforce your host."
	button_icon_state = "human_form"

/datum/action/innate/borer/focus_menu/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.focus_menu()
