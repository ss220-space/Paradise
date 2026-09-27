/datum/brain_trauma/special/obsessed
	name = "Psychotic Schizophrenia"
	desc = "У пациента разновидность бредового расстройства: он иррационально привязан к конкретному человеку."
	scan_desc = "психотический шизофренический бред"
	gain_text = span_warning_alt("В вашей голове звучит тошнотворный сиплый голос. Он просит вас об одной небольшой услуге...")
	lose_text = span_notice_alt("Голоса в вашей голове смолкают.")
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	var/mob/living/obsession
	var/datum/objective/spendtime/creeping_objective
	var/viewing = FALSE
	var/total_time_creeping = 0
	var/time_spent_away = 0
	var/obsession_hug_count = 0

/datum/brain_trauma/special/obsessed/on_gain()
	if(!owner.mind || jobban_isbanned(owner, ROLE_OBSESSED))
		return FALSE

	if(!obsession)
		obsession = find_obsession()
	if(!obsession?.mind)
		lose_text = ""
		return FALSE

	. = ..()
	var/datum/antagonist/obsessed/antagonist = new
	antagonist.trauma = src
	antagonist.obsession = obsession.mind
	if(!owner.mind.add_antag_datum(antagonist))
		return FALSE

	RegisterSignal(obsession, COMSIG_MOB_EYECONTACT, PROC_REF(stare))
	RegisterSignal(owner, COMSIG_CARBON_HELPED, PROC_REF(on_hug))
	log_game("[key_name(owner)] has developed an obsession with [key_name(obsession)].")

/datum/brain_trauma/special/obsessed/on_lose(silent)
	if(obsession)
		log_game("[key_name(owner)] is no longer obsessed with [key_name(obsession)].")
		UnregisterSignal(obsession, COMSIG_MOB_EYECONTACT)
	UnregisterSignal(owner, COMSIG_CARBON_HELPED)
	if(owner.mind?.remove_antag_datum(/datum/antagonist/obsessed))
		owner.mind.add_antag_datum(/datum/antagonist/former_obsessed)
	creeping_objective = null
	obsession = null
	return ..()

/datum/brain_trauma/special/obsessed/on_life()
	if(!obsession || obsession.stat == DEAD)
		viewing = FALSE
		return

	if(get_dist(owner, obsession) > world.view)
		viewing = FALSE
		time_spent_away += 2 SECONDS
		return

	viewing = (obsession in view(world.view, owner))
	if(!viewing)
		time_spent_away += 2 SECONDS
		return

	total_time_creeping += 2 SECONDS
	time_spent_away = 0
	creeping_objective?.timer -= 2 SECONDS

/datum/brain_trauma/special/obsessed/handle_speech(datum/source, list/speech_args)
	if(!viewing || !prob(25))
		return

	if(prob(50))
		addtimer(CALLBACK(src, PROC_REF(on_failed_social_interaction)), rand(1 SECONDS, 3 SECONDS), TIMER_DELETE_ME)
	else if(!owner.AmountStuttering())
		to_chat(owner, span_warning("Рядом с [obsession.declent_ru(INSTRUMENTAL)] вы нервничаете и начинаете заикаться..."))

	owner.AdjustStuttering(6 SECONDS)

/datum/brain_trauma/special/obsessed/proc/on_hug(datum/source, mob/living/hugged)
	SIGNAL_HANDLER

	if(hugged == obsession)
		obsession_hug_count++

/datum/brain_trauma/special/obsessed/proc/on_failed_social_interaction()
	if(QDELETED(owner) || owner.stat >= UNCONSCIOUS)
		return

	switch(rand(1, 100))
		if(1 to 40)
			owner.emote("blink")
			owner.AdjustEyeBlurry(20 SECONDS)
			to_chat(owner, span_userdanger("Вас прошибает пот, и вы никак не можете сосредоточиться..."))
		if(41 to 80)
			owner.emote("pale")
			shake_camera(owner, 15, 1)
			owner.adjustStaminaLoss(70)
			to_chat(owner, span_userdanger("Вы чувствуете, как сердце заходится у вас в груди..."))
		if(81 to 100)
			owner.emote("cough")
			owner.AdjustDizzy(20 SECONDS)
			owner.AdjustDisgust(5)
			to_chat(owner, span_userdanger("Вы давитесь подступившей желчью..."))

/datum/brain_trauma/special/obsessed/proc/stare(datum/source, mob/living/examined_mob, triggering_examiner)
	SIGNAL_HANDLER

	if(examined_mob != owner || !triggering_examiner || prob(50))
		return

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), obsession, span_warning("Вы ловите на себе взгляд [examined_mob.declent_ru(GENITIVE)]...")), 0.3 SECONDS)
	return COMSIG_BLOCK_EYECONTACT

/datum/brain_trauma/special/obsessed/proc/find_obsession()
	var/list/possible_targets = list()
	for(var/mob/player as anything in GLOB.player_list)
		if(!player.client || !player.mind || player == owner)
			continue
		if(isnewplayer(player) || isbrain(player) || !ishuman(player) || player.stat == DEAD)
			continue
		if(player.mind.offstation_role || !player.mind.assigned_role)
			continue
		possible_targets += player

	return length(possible_targets) ? pick(possible_targets) : null
