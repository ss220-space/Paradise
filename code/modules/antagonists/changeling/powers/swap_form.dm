/datum/action/changeling/swap_form
	name = "Обмен сосудами"
	desc = "Мы силой забираем чужой сосуд, перенося сознание из него в наш старый сосуд. Требует 40 химикатов."
	helptext = "Новый сосуд получит все наши способности, но мы потеряем ДНК оставленного сосуда взамен на ДНК нового. Для использования требуется душить жертву. Можно использовать в низшей форме."
	button_icon_state = "mindswap"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 40

/datum/action/changeling/swap_form/can_sting(mob/living/carbon/user)
	if(!..())
		return FALSE

	if(!user.pulling || user.pull_hand != user.hand || user.grab_state < GRAB_AGGRESSIVE)
		user.balloon_alert(user, "нужно схватить крепче!")
		return FALSE

	var/mob/living/carbon/human/target = user.pulling
	if(!ishuman(target) || !target.mind || is_monkeybasic(target) || HAS_TRAIT(target, TRAIT_NO_DNA))
		user.balloon_alert(user, "[target] не подойдёт")
		return FALSE

	if(HAS_TRAIT(target, TRAIT_HUSK) || HAS_TRAIT(target, TRAIT_SKELETON) || HAS_TRAIT(target, TRAIT_NO_CLONE))
		user.balloon_alert(user, UNLINT("ДНК [target] уничтожена!"))
		return FALSE

	if(ischangeling(target))
		user.balloon_alert(user, "в сосуде собрат!")
		return FALSE

	if(isdevilantag(target))
		user.balloon_alert(user, "сосуд испорчен!")
		return FALSE

	if(target.has_brain_worms() || user.has_brain_worms())
		user.balloon_alert(user, "в разуме паразит!")
		return FALSE

	return TRUE

/datum/action/changeling/swap_form/sting_action(mob/living/carbon/user)
	var/mob/living/carbon/human/target = user.pulling
	to_chat(user, span_notice("[target] нам подходит. Во время смены сосуда нам нельзя двигаться."))
	target.Jitter(10 SECONDS)
	user.Jitter(10 SECONDS)

	if(!do_after(user, 10 SECONDS, target, NONE))
		user.balloon_alert(user, "смена сосуда прервана!")
		return FALSE

	if(!can_sting(user))
		return FALSE

	to_chat(target, span_userdanger("[user] усиливает захват, и вы чувствуете, как что-то проникает в вас."))

	var/datum/dna/DNA = cling.get_dna(user.dna)
	cling.absorbed_dna -= DNA
	cling.protected_dna -= DNA
	cling.absorbed_count--
	if(!cling.get_dna(target.dna))
		cling.absorb_dna(target)
	cling.trim_dna()

	var/mob/dead/observer/ghost = target.mind?.get_ghost(TRUE)
	if(!ghost)
		ghost = target.ghostize(FALSE)

	user.mind.transfer_to(target)
	user.update_action_buttons(TRUE)

	if(ghost?.mind)
		ghost.mind.transfer_to(user)
		GLOB.non_respawnable_keys -= ghost.ckey //they have a new body, let them be able to re-enter their corpse if they die
		user.possess_by_player(ghost.key)
	qdel(ghost)

	user.regenerate_icons()

	if(target.stat == DEAD)
		user.Paralyse(CLING_FAKEDEATH_TIME)

		if(target.suiciding) //If Target committed suicide, unset flag for User
			target.suiciding = FALSE

	else
		user.Paralyse(10 SECONDS)

	return TRUE
