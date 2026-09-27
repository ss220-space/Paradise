/datum/brain_trauma/mild
	abstract_type = /datum/brain_trauma/mild

/datum/brain_trauma/mild/hallucinations
	name = "Hallucinations"
	desc = "Пациент страдает от постоянных галлюцинаций."
	scan_desc = "шизофрения"
	gain_text = span_warning_alt("Вы чувствуете, как реальность уходит из-под контроля...")
	lose_text = span_notice_alt("Вы снова ощущаете под собой твёрдую почву.")
	var/uncapped = FALSE

/datum/brain_trauma/mild/hallucinations/on_gain()
	owner.add_language(LANGUAGE_APHASIA)
	return ..()

/datum/brain_trauma/mild/hallucinations/on_life()
	if(owner.stat >= UNCONSCIOUS)
		return
	owner.AdjustHallucinate(uncapped ? 24 SECONDS : 10 SECONDS, bound_upper = uncapped ? 240 SECONDS : 60 SECONDS)

/datum/brain_trauma/mild/hallucinations/on_lose(silent)
	owner.SetHallucinate(0)
	if(!owner.has_trauma_type(/datum/brain_trauma/severe/aphasia))
		owner.remove_language(LANGUAGE_APHASIA)
	return ..()

/datum/brain_trauma/mild/stuttering
	name = "Stuttering"
	desc = "Пациент не может говорить нормально."
	scan_desc = "нарушение координации речевого аппарата"
	gain_text = span_warning_alt("Говорить внятно становится всё труднее.")
	lose_text = span_notice_alt("Вы снова владеете своей речью.")

/datum/brain_trauma/mild/stuttering/on_life()
	owner.AdjustStuttering(10 SECONDS, bound_upper = 50 SECONDS)

/datum/brain_trauma/mild/stuttering/on_lose(silent)
	owner.SetStuttering(0)
	return ..()

/datum/brain_trauma/mild/dumbness
	name = "Dumbness"
	desc = "Активность мозга пациента снижена, из-за чего он заметно глупее."
	scan_desc = "пониженная активность мозга"
	gain_text = span_warning_alt("Вы чувствуете себя глупее.")
	lose_text = span_notice_alt("Вы снова чувствуете себя умным.")

/datum/brain_trauma/mild/dumbness/on_gain()
	ADD_TRAIT(owner, TRAIT_DUMB, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/mild/dumbness/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_DUMB, TRAUMA_TRAIT)
	owner.SetSlur(0)
	return ..()

/datum/brain_trauma/mild/dumbness/on_life()
	owner.AdjustSlur(10 SECONDS, bound_upper = 50 SECONDS)
	if(prob(3))
		owner.emote("drool")
	else if(owner.stat == CONSCIOUS && prob(3))
		owner.say(pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage"), ignore_emotes = TRUE)

/datum/brain_trauma/mild/speech_impediment
	name = "Speech Impediment"
	desc = "Пациент не способен строить связные предложения."
	scan_desc = "расстройство речи"
	gain_text = span_danger_alt("Вы не можете собрать мысли воедино!")
	lose_text = span_danger_alt("В голове проясняется.")

/datum/brain_trauma/mild/speech_impediment/on_gain()
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/mild/speech_impediment/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/mild/concussion
	name = "Concussion"
	desc = "У пациента сотрясение мозга."
	scan_desc = "сотрясение мозга"
	gain_text = span_warning_alt("Ваша голова болит!")
	lose_text = span_notice_alt("Давление в голове начинает спадать.")

/datum/brain_trauma/mild/concussion/on_life()
	if(!prob(5))
		return

	switch(rand(1, 11))
		if(1)
			owner.vomit()
		if(2, 3)
			owner.AdjustDizzy(20 SECONDS)
		if(4, 5)
			owner.AdjustConfused(10 SECONDS)
			owner.AdjustEyeBlurry(20 SECONDS)
		if(6 to 9)
			owner.AdjustSlur(1 MINUTES)
		if(10)
			to_chat(owner, span_notice("Вы на мгновение забываете, чем занимались."))
			owner.Stun(2 SECONDS)
		if(11)
			to_chat(owner, span_warning("Вы теряете сознание."))
			owner.Paralyse(8 SECONDS)

/datum/brain_trauma/mild/healthy
	name = "Anosognosia"
	desc = "Пациент всегда чувствует себя здоровым, независимо от своего состояния."
	scan_desc = "нарушение самовосприятия"
	gain_text = span_notice_alt("Вы прекрасно себя чувствуете!")
	lose_text = span_warning_alt("Вы больше не чувствуете себя абсолютно здоровым.")

/datum/brain_trauma/mild/healthy/on_gain()
	owner.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	return ..()

/datum/brain_trauma/mild/healthy/on_life()
	owner.adjustStaminaLoss(-12)

/datum/brain_trauma/mild/healthy/on_lose(silent)
	owner.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	return ..()

/datum/brain_trauma/mild/muscle_weakness
	name = "Muscle Weakness"
	desc = "Пациент периодически испытывает приступы мышечной слабости."
	scan_desc = "ослабленный моторный сигнал"
	gain_text = span_warning_alt("Ваши мышцы кажутся странно слабыми.")
	lose_text = span_notice_alt("Вы снова управляете своими мышцами.")

/datum/brain_trauma/mild/muscle_weakness/on_life()
	var/fall_chance = owner.m_intent == MOVE_INTENT_RUN ? 3 : 1
	var/obj/item/held_item = owner.get_active_hand()

	if(prob(fall_chance) && owner.body_position == STANDING_UP)
		to_chat(owner, span_warning("Ваша нога подкашивается!"))
		owner.Weaken(3.5 SECONDS)
		return

	if(held_item)
		if(prob(1 + held_item.w_class) && owner.drop_item_ground(held_item))
			to_chat(owner, span_warning("Вы выпускаете [held_item.declent_ru(ACCUSATIVE)] из рук!"))
		return

	if(prob(3))
		to_chat(owner, span_warning("Вы чувствуете внезапную слабость в мышцах!"))
		owner.adjustStaminaLoss(50)

/datum/brain_trauma/mild/muscle_spasms
	name = "Muscle Spasms"
	desc = "У пациента периодически случаются мышечные спазмы, заставляющие его двигаться против своей воли."
	scan_desc = "нервные судороги"
	gain_text = span_warning_alt("Ваши мышцы начинают подрагивать сами по себе.")
	lose_text = span_notice_alt("Вы снова управляете своими мышцами.")

/datum/brain_trauma/mild/muscle_spasms/on_gain()
	owner.apply_status_effect(/datum/status_effect/spasms)
	return ..()

/datum/brain_trauma/mild/muscle_spasms/on_lose(silent)
	owner.remove_status_effect(/datum/status_effect/spasms)
	return ..()

/datum/brain_trauma/mild/nervous_cough
	name = "Nervous Cough"
	desc = "Пациент постоянно чувствует потребность кашлять."
	scan_desc = "нервный кашель"
	gain_text = span_warning_alt("В горле нестерпимо першит...")
	lose_text = span_notice_alt("Першение в горле проходит.")

/datum/brain_trauma/mild/nervous_cough/on_life()
	if(!prob(12))
		return

	if(prob(5))
		to_chat(owner, span_warning(pick("У вас начинается приступ кашля!", "Вы не можете перестать кашлять!")))
		owner.Immobilize(2 SECONDS)
		owner.emote("cough")
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, emote), "cough"), 0.6 SECONDS)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, emote), "cough"), 1.2 SECONDS)
	owner.emote("cough")

/datum/brain_trauma/mild/expressive_aphasia
	name = "Expressive Aphasia"
	desc = "Пациент частично утратил речь, из-за чего его словарный запас сильно обеднел."
	scan_desc = "неспособность строить сложные предложения"
	gain_text = span_warning_alt("Сложные слова перестают вам подчиняться.")
	lose_text = span_notice_alt("Словарный запас возвращается к вам.")

/datum/brain_trauma/mild/expressive_aphasia/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return

	var/static/list/sentence_suffixes = list(".", ",", ";", "!", ":", "?")
	var/list/words = splittext(message, " ")
	var/list/new_message = list()
	for(var/word in words)
		word = html_decode(word)
		var/suffix = copytext_char(word, -1)
		if(suffix in sentence_suffixes)
			word = copytext_char(word, 1, -1)
		else
			suffix = ""

		if(GLOB.most_common_words[lowertext(word)])
			new_message += word + suffix
			continue

		if(prob(30) && length(words) > 2)
			new_message += pick("э", "ну")
			break

		var/list/letters = list()
		for(var/letter_index in 1 to length_char(word))
			letters += copytext_char(word, letter_index, letter_index + 1)
		letters.len = round(length(letters) * 0.5, 1)
		shuffle_inplace(letters)
		new_message += jointext(letters, "") + suffix

	speech_args[SPEECH_MESSAGE] = trim(jointext(new_message, " "))

/datum/brain_trauma/mild/mind_echo
	name = "Mind Echo"
	desc = "Речевые нейроны пациента не гасят возбуждение до конца, и прошлые фразы всплывают снова сами собой."
	scan_desc = "зациклившийся нейронный паттерн"
	gain_text = span_warning_alt("Вы слышите слабое эхо собственных мыслей...")
	lose_text = span_notice_alt("Слабое эхо в голове угасает.")
	var/list/heard_echoes = list()
	var/list/spoken_echoes = list()

/datum/brain_trauma/mild/mind_echo/handle_hearing(datum/source, mob/speaker, list/message_pieces)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == speaker)
		return

	var/datum/multilingual_say_piece/piece = message_pieces[1]
	if(!piece?.message)
		return

	if(length(heard_echoes) >= 5 && prob(25))
		piece.message = pick_n_take(heard_echoes)
		return

	if(length(heard_echoes) >= 15)
		if(prob(50))
			popleft(heard_echoes)
			heard_echoes += piece.message
		return

	heard_echoes += piece.message

/datum/brain_trauma/mild/mind_echo/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return

	if(length(spoken_echoes) >= 5 && prob(25))
		speech_args[SPEECH_MESSAGE] = pick_n_take(spoken_echoes)
		return

	if(length(spoken_echoes) >= 15)
		if(prob(50))
			popleft(spoken_echoes)
			spoken_echoes += message
		return

	spoken_echoes += message

/datum/brain_trauma/mild/color_blindness
	name = "Achromatopsia"
	desc = "Затылочная доля пациента не различает цвета, из-за чего он полностью дальтоник."
	scan_desc = "дальтонизм"
	gain_text = span_warning_alt("Мир вокруг словно теряет краски.")
	lose_text = span_notice_alt("Мир снова кажется ярким и красочным.")

/datum/brain_trauma/mild/color_blindness/on_gain()
	ADD_TRAIT(owner, TRAIT_COLORBLIND, TRAUMA_TRAIT)
	owner.update_client_colour()
	return ..()

/datum/brain_trauma/mild/color_blindness/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_COLORBLIND, TRAUMA_TRAIT)
	owner.update_client_colour()
	return ..()

/datum/brain_trauma/mild/possessive
	name = "Possessive"
	desc = "Пациент болезненно привязан к своим вещам."
	scan_desc = "болезненная собственничность"
	gain_text = span_warning_alt("Вы начинаете переживать за свои вещи.")
	lose_text = span_notice_alt("Вы меньше переживаете за свои вещи.")

/datum/brain_trauma/mild/possessive/on_lose(silent)
	. = ..()
	for(var/obj/item/thing in list(owner.l_hand, owner.r_hand))
		clear_grip(thing)

/datum/brain_trauma/mild/possessive/on_life()
	if(!prob(10))
		return

	var/obj/item/precious = pick(list(owner.l_hand, owner.r_hand))
	if(!precious || HAS_TRAIT(precious, TRAIT_NODROP) || (precious.flags & ABSTRACT))
		return

	ADD_TRAIT(precious, TRAIT_NODROP, TRAUMA_TRAIT)
	RegisterSignals(precious, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED), PROC_REF(clear_grip))
	to_chat(owner, span_warning("Вам нужно держать [precious.declent_ru(ACCUSATIVE)] при себе..."))
	addtimer(CALLBACK(src, PROC_REF(relax_grip), precious), rand(30 SECONDS, 3 MINUTES), TIMER_DELETE_ME)

/datum/brain_trauma/mild/possessive/proc/relax_grip(obj/item/precious)
	if(QDELETED(precious))
		return
	if(HAS_TRAIT_FROM_ONLY(precious, TRAIT_NODROP, TRAUMA_TRAIT))
		to_chat(owner, span_notice("Вам становится спокойнее, и вы готовы отпустить [precious.declent_ru(ACCUSATIVE)]."))
	clear_grip(precious)

/datum/brain_trauma/mild/possessive/proc/clear_grip(obj/item/precious, ...)
	SIGNAL_HANDLER

	REMOVE_TRAIT(precious, TRAIT_NODROP, TRAUMA_TRAIT)
	UnregisterSignal(precious, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))
