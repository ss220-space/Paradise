#define MONOPHOBIA_PANIC_STRESS 60
#define MONOPHOBIA_HEART_ATTACK_STRESS 90
#define ITALIAN_TUMOR_MAX_NAMES 4

/datum/brain_trauma/severe
	abstract_type = /datum/brain_trauma/severe
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/severe/mute
	name = "Mutism"
	desc = "Пациент полностью лишён речи."
	scan_desc = "обширное повреждение речевого центра мозга"
	gain_text = span_warning_alt("Вы забываете, как говорить!")
	lose_text = span_notice_alt("Вы внезапно вспоминаете, как говорить.")

/datum/brain_trauma/severe/mute/on_gain()
	ADD_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/severe/mute/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/severe/aphasia
	name = "Aphasia"
	desc = "Пациент не способен говорить и понимать ни один язык."
	scan_desc = "обширное повреждение языкового центра мозга"
	gain_text = span_warning_alt("Слова перестают складываться у вас в голове...")
	lose_text = span_notice_alt("Вы внезапно вспоминаете, как устроены языки.")
	var/list/datum/language/known_languages
	var/datum/language/previous_default

/datum/brain_trauma/severe/aphasia/on_gain()
	known_languages = owner.languages?.Copy()
	previous_default = owner.default_language
	owner.languages = null
	owner.add_language(LANGUAGE_APHASIA)
	owner.default_language = GLOB.all_languages[LANGUAGE_APHASIA]
	return ..()

/datum/brain_trauma/severe/aphasia/on_lose(silent)
	owner.remove_language(LANGUAGE_APHASIA)
	for(var/datum/language/language as anything in known_languages)
		owner.add_language(language.name)
	owner.default_language = previous_default
	known_languages = null
	previous_default = null
	return ..()

/datum/brain_trauma/severe/blindness
	name = "Cerebral Blindness"
	desc = "Мозг пациента больше не связан с его глазами."
	scan_desc = "обширное повреждение затылочной доли"
	gain_text = span_warning_alt("Вы ничего не видите!")
	lose_text = span_notice_alt("Зрение возвращается к вам.")

/datum/brain_trauma/severe/blindness/on_gain()
	ADD_TRAIT(owner, TRAIT_BLIND, TRAUMA_TRAIT)
	owner.update_blind_effects()
	return ..()

/datum/brain_trauma/severe/blindness/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_BLIND, TRAUMA_TRAIT)
	owner.update_blind_effects()
	return ..()

/datum/brain_trauma/severe/paralysis
	name = "Paralysis"
	desc = "Мозг пациента больше не управляет частью его двигательных функций."
	scan_desc = "церебральный паралич"
	gain_text = ""
	lose_text = ""
	var/paralysis_type
	var/list/paralysis_traits

/datum/brain_trauma/severe/paralysis/New(specific_type)
	if(specific_type)
		paralysis_type = specific_type
	if(!paralysis_type)
		paralysis_type = pick("full", "left", "right", "arms", "legs", "r_arm", "l_arm", "r_leg", "l_leg")

	var/subject
	switch(paralysis_type)
		if("full")
			subject = "своё тело"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("left")
			subject = "левую половину тела"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_L_LEG)
		if("right")
			subject = "правую половину тела"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_R_LEG)
		if("arms")
			subject = "свои руки"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)
		if("legs")
			subject = "свои ноги"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("r_arm")
			subject = "правую руку"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM)
		if("l_arm")
			subject = "левую руку"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM)
		if("r_leg")
			subject = "правую ногу"
			paralysis_traits = list(TRAIT_PARALYSIS_R_LEG)
		if("l_leg")
			subject = "левую ногу"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG)

	gain_text = span_warning_alt("Вы больше не чувствуете [subject]!")
	lose_text = span_notice_alt("Вы снова чувствуете [subject]!")
	return ..()

/datum/brain_trauma/severe/paralysis/on_gain()
	. = ..()
	set_paralysis(TRUE)

/datum/brain_trauma/severe/paralysis/on_lose(silent)
	set_paralysis(FALSE)
	return ..()

/datum/brain_trauma/severe/paralysis/proc/set_paralysis(paralysed)
	var/list/previously_usable = list()
	var/mob/living/carbon/human/patient = ishuman(owner) ? owner : null
	if(patient)
		for(var/obj/item/organ/external/limb as anything in patient.bodyparts)
			if(limb.paralysis_trait in paralysis_traits)
				previously_usable[limb] = limb.is_usable()

	for(var/trait in paralysis_traits)
		if(paralysed)
			ADD_TRAIT(owner, trait, TRAUMA_TRAIT)
		else
			REMOVE_TRAIT(owner, trait, TRAUMA_TRAIT)

	for(var/obj/item/organ/external/limb as anything in previously_usable)
		if(previously_usable[limb] == limb.is_usable())
			continue
		var/difference = limb.is_usable() ? 1 : -1
		if(istype(limb, /obj/item/organ/external/hand))
			patient.set_usable_hands(patient.usable_hands + difference, hand_index = limb.limb_zone)
		else
			patient.set_usable_legs(patient.usable_legs + difference)

/datum/brain_trauma/severe/paralysis/paraplegic
	random_gain = FALSE
	known_trauma = FALSE
	paralysis_type = "legs"
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/hemiplegic
	random_gain = FALSE
	known_trauma = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/hemiplegic/left
	paralysis_type = "left"

/datum/brain_trauma/severe/paralysis/hemiplegic/right
	paralysis_type = "right"

/datum/brain_trauma/severe/narcolepsy
	name = "Narcolepsy"
	desc = "Пациент может непроизвольно засыпать посреди обычных дел."
	scan_desc = "травматическая нарколепсия"
	gain_text = span_warning_alt("Вас не отпускает сонливость...")
	lose_text = span_notice_alt("Вы снова бодры и внимательны.")
	var/sleep_chance = 2
	var/sleep_chance_running = 4
	var/sleep_chance_drowsy = 6
	var/drowsy_time_minimum = 20 SECONDS
	var/drowsy_time_maximum = 30 SECONDS
	var/sleep_time_minimum = 6 SECONDS
	var/sleep_time_maximum = 6 SECONDS

/datum/brain_trauma/severe/narcolepsy/on_life()
	if(owner.IsSleeping())
		return

	var/static/list/immunity_medicine = list(
		/datum/reagent/medicine/synaptizine,
		/datum/reagent/medicine/ephedrine,
	)
	for(var/medicine in immunity_medicine)
		if(owner.reagents.has_reagent(medicine))
			return

	var/drowsy = owner.get_drowsiness()
	var/final_sleep_chance = sleep_chance
	if(owner.m_intent == MOVE_INTENT_RUN)
		final_sleep_chance += sleep_chance_running
	if(drowsy)
		final_sleep_chance += sleep_chance_drowsy

	if(!prob(final_sleep_chance))
		return

	if(!drowsy)
		to_chat(owner, span_warning("Вы чувствуете усталость..."))
		owner.AdjustDrowsy(rand(drowsy_time_minimum, drowsy_time_maximum))
		if(prob(50))
			owner.emote("yawn")
		else if(prob(33))
			owner.custom_emote(EMOTE_VISIBLE, "трёт глаза.")
		return

	to_chat(owner, span_warning("Вы засыпаете."))
	owner.Sleeping(rand(sleep_time_minimum, sleep_time_maximum))
	if(prob(50) && owner.IsSleeping())
		owner.emote("snore")

/datum/brain_trauma/severe/narcolepsy/permanent
	scan_desc = "хроническая нарколепсия"
	known_trauma = FALSE
	sleep_chance = 0.7
	sleep_chance_running = 0.7
	sleep_chance_drowsy = 2
	sleep_time_minimum = 20 SECONDS
	sleep_time_maximum = 30 SECONDS

/datum/brain_trauma/severe/monophobia
	name = "Monophobia"
	desc = "Оставшись без людей рядом, пациент испытывает дурноту и панику вплоть до смертельного уровня стресса."
	scan_desc = "монофобия"
	gain_text = span_warning_alt("Вам становится ужасно одиноко...")
	lose_text = span_notice_alt("Вам кажется, что в одиночестве вы всё-таки в безопасности.")
	var/stress = 0

/datum/brain_trauma/severe/monophobia/on_life()
	if(!is_alone())
		stress = max(stress - 5, 0)
		return

	stress = min(stress + 3, 100)
	if(prob(stress * 0.5))
		stress_reaction()

/datum/brain_trauma/severe/monophobia/proc/is_alone()
	var/check_range = HAS_TRAIT(owner, TRAIT_BLIND) ? 1 : 7
	for(var/mob/living/friend in view(check_range, owner))
		if(friend == owner)
			continue
		if(friend.ckey || istype(friend, /mob/living/simple_animal/pet))
			return FALSE

	if(prob(5))
		to_chat(owner, span_warning("Вам ужасно одиноко..."))
	return TRUE

/datum/brain_trauma/severe/monophobia/proc/stress_reaction()
	if(owner.stat >= UNCONSCIOUS)
		return

	if(stress >= MONOPHOBIA_HEART_ATTACK_STRESS && prob(15) && ishuman(owner))
		var/mob/living/carbon/human/patient = owner
		if(!patient.undergoing_cardiac_arrest())
			patient.visible_message(
				span_warning("[DECLENT_RU_CAP(patient, NOMINATIVE)] на миг хвата[PLUR_ET_YUT(patient)] себя за грудь и оседа[PLUR_ET_YUT(patient)] на пол."),
				span_userdanger("Тени наползают из углов вашего зрения, и не остаётся ничего..."),
			)
			patient.set_heartattack(TRUE)
			patient.Paralyse(20 SECONDS)
			return

	switch(rand(1, 5))
		if(1)
			to_chat(owner, span_warning("Вас трясёт, и вы никак не можете унять дрожь..."))
			owner.AdjustJitter(20 SECONDS)
			owner.AdjustDizzy(20 SECONDS)
		if(2)
			owner.AdjustStuttering(10 SECONDS)
		if(3)
			to_chat(owner, span_userdanger("Вы чувствуете, как сердце заходится у вас в груди..."))
			owner.adjustOxyLoss(8)
		if(4)
			to_chat(owner, span_warning("Вас начинает мутить..."))
			addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living/carbon, vomit)), 5 SECONDS)
		if(5)
			to_chat(owner, span_warning("Вам не хватает воздуха, и всё плывёт перед глазами..."))
			owner.AdjustEyeBlurry(20 SECONDS)
			if(stress >= MONOPHOBIA_PANIC_STRESS)
				owner.adjustOxyLoss(5)

/datum/brain_trauma/severe/discoordination
	name = "Discoordination"
	desc = "Пациент не способен обращаться со сложными инструментами и техникой."
	scan_desc = "крайняя раскоординированность"
	gain_text = span_warning_alt("Вы едва управляете собственными руками!")
	lose_text = span_notice_alt("Вы снова владеете своими руками.")

/datum/brain_trauma/severe/discoordination/on_gain()
	owner.apply_status_effect(/datum/status_effect/discoordinated)
	return ..()

/datum/brain_trauma/severe/discoordination/on_lose(silent)
	owner.remove_status_effect(/datum/status_effect/discoordinated)
	return ..()

/datum/brain_trauma/severe/pacifism
	name = "Traumatic Non-Violence"
	desc = "Пациент решительно не готов причинять другим вред."
	scan_desc = "пацифический синдром"
	gain_text = span_notice_alt("Вас охватывает странное умиротворение.")
	lose_text = span_notice_alt("Вы больше не чувствуете себя обязанным никому не вредить.")

/datum/brain_trauma/severe/pacifism/on_gain()
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/severe/pacifism/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/severe/hypnotic_stupor
	name = "Hypnotic Stupor"
	desc = "Пациент склонен впадать в глубокое оцепенение, в котором становится крайне внушаемым."
	scan_desc = "онейроидная петля обратной связи"
	gain_text = span_warning_alt("Вы чувствуете лёгкое помутнение.")
	lose_text = span_notice_alt("Вам кажется, будто с разума сняли пелену.")

/datum/brain_trauma/severe/hypnotic_stupor/on_lose(silent)
	owner.remove_status_effect(/datum/status_effect/trance)
	return ..()

/datum/brain_trauma/severe/hypnotic_stupor/on_life()
	if(prob(1) && !owner.has_status_effect(/datum/status_effect/trance))
		owner.apply_status_effect(/datum/status_effect/trance, rand(10 SECONDS, 30 SECONDS), FALSE)

/datum/brain_trauma/severe/hypnotic_trigger
	name = "Hypnotic Trigger"
	desc = "В подсознании пациента засела фраза-триггер, вводящая его во внушаемое трансовое состояние."
	scan_desc = "онейроидная петля обратной связи"
	gain_text = span_warning_alt("Вам не по себе, будто вы забыли что-то важное.")
	lose_text = span_notice_alt("Вам кажется, будто с разума сняли груз.")
	random_gain = FALSE
	known_trauma = FALSE
	var/trigger_phrase = "Nanotrasen"
	var/regex/target_phrase

/datum/brain_trauma/severe/hypnotic_trigger/New(phrase)
	if(phrase)
		trigger_phrase = phrase
	try
		target_phrase = new("(\\b[REGEX_QUOTE(trigger_phrase)]\\b)", "ig")
	catch(var/exception/regex_error)
		stack_trace("[regex_error] on [regex_error.file]:[regex_error.line]")
		qdel(src)
	return ..()

/datum/brain_trauma/severe/hypnotic_trigger/on_lose(silent)
	owner.remove_status_effect(/datum/status_effect/trance)
	return ..()

/datum/brain_trauma/severe/hypnotic_trigger/handle_hearing(datum/source, mob/speaker, list/message_pieces)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == speaker)
		return

	var/triggered = FALSE
	for(var/datum/multilingual_say_piece/piece in message_pieces)
		if(!findtext(piece.message, target_phrase))
			continue
		piece.message = target_phrase.Replace(piece.message, span_hypnophrase("*********"))
		triggered = TRUE

	if(triggered)
		addtimer(CALLBACK(src, PROC_REF(hypnotrigger)), 1 SECONDS, TIMER_DELETE_ME)

/datum/brain_trauma/severe/hypnotic_trigger/proc/hypnotrigger()
	to_chat(owner, span_warning("Эти слова задевают что-то глубоко внутри вас, и вы чувствуете, как сознание ускользает..."))
	owner.apply_status_effect(/datum/status_effect/trance, rand(10 SECONDS, 30 SECONDS), FALSE)

/datum/brain_trauma/severe/dyslexia
	name = "Dyslexia"
	desc = "Пациент не способен читать и писать."
	scan_desc = "дислексия"
	gain_text = span_warning_alt("Читать и писать становится невыносимо трудно...")
	lose_text = span_notice_alt("Вы внезапно вспоминаете, как читать и писать.")

/datum/brain_trauma/severe/dyslexia/on_gain()
	ADD_TRAIT(owner, TRAIT_ILLITERATE, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/severe/dyslexia/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_ILLITERATE, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/severe/kleptomaniac
	name = "Kleptomania"
	desc = "Пациент склонен присваивать чужие вещи."
	scan_desc = "клептомания"
	gain_text = span_warning_alt("Вам внезапно хочется это забрать. Никто ведь не заметит.")
	lose_text = span_notice_alt("Вам больше не хочется хватать чужие вещи.")
	COOLDOWN_DECLARE(steal_cooldown)

/datum/brain_trauma/severe/kleptomaniac/on_gain()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_taken))
	return ..()

/datum/brain_trauma/severe/kleptomaniac/on_lose(silent)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	return ..()

/datum/brain_trauma/severe/kleptomaniac/proc/damage_taken(datum/source, damage_amount, damage_type, ...)
	SIGNAL_HANDLER

	if(damage_amount >= 5 && (damage_type == BRUTE || damage_type == BURN || damage_type == STAMINA))
		COOLDOWN_START(src, steal_cooldown, 12 SECONDS)

/datum/brain_trauma/severe/kleptomaniac/on_life()
	if(!owner.usable_hands)
		return
	if(!prob(10))
		return
	if(!COOLDOWN_FINISHED(src, steal_cooldown))
		return
	if(!owner.has_active_hand() || (owner.l_hand && owner.r_hand))
		return

	var/steal_to_offhand = !!owner.get_active_hand()
	var/previous_dir = owner.dir
	if(steal_to_offhand)
		owner.swap_hand()

	var/list/stealables = list()
	for(var/obj/item/potential_steal in oview(1, owner))
		if(potential_steal.w_class >= WEIGHT_CLASS_BULKY || potential_steal.anchored)
			continue
		if((potential_steal.flags & ABSTRACT) || HAS_TRAIT(potential_steal, TRAIT_NODROP))
			continue
		stealables += potential_steal

	for(var/obj/item/stealable as anything in shuffle(stealables))
		if(!owner.Adjacent(stealable) || stealable.IsObscured())
			continue
		add_game_logs("attempted to pick up [stealable] (kleptomania)", owner)
		stealable.attack_hand(owner)
		break

	if(steal_to_offhand)
		owner.swap_hand()
	owner.setDir(previous_dir)
	COOLDOWN_START(src, steal_cooldown, 8 SECONDS)

/datum/brain_trauma/severe/flesh_desire
	name = "Расстройство Бина"
	desc = "У пациента наблюдается зацикленность на потреблении сырого мяса, особенно того же вида. Пациент также страдает от психосоматических приступов голода."
	scan_desc = "умеренное расстройство пищевого поведения"
	gain_text = span_warning_alt("Вам сильно хочется есть... Есть органы и сырое мясо...")
	lose_text = span_notice_alt("Ваши вкусовые предпочтения вернулись в норму.")
	random_gain = FALSE
	var/hunger_rate = 15

/datum/brain_trauma/severe/flesh_desire/on_gain()
	ADD_TRAIT(owner, TRAIT_FLESH_DESIRE, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/severe/flesh_desire/on_life()
	owner.adjust_nutrition(-hunger_rate * HUNGER_FACTOR)
	if(prob(20))
		to_chat(owner, span_notice_alt(pick("Вы не можете перестать думать о сыром мясе...", "Вам **НУЖНО** съесть кого-нибудь.", "Муки голода вернулись...", "Вы жаждете плоти.", "Вы голодны!")))

	owner.overeatduration = max(owner.overeatduration - 200 SECONDS, 0)

/datum/brain_trauma/severe/flesh_desire/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_FLESH_DESIRE, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/severe/eldritch_beauty
	name = "Eldritch Beauty"
	desc = "Пациент одержим видениями неописуемой потусторонней красоты."
	scan_desc = "тяжёлое диссоциативное расстройство"
	gain_text = span_warning_alt("Перед вашими глазами расцветает невыразимая, ужасающая красота...")
	lose_text = span_notice_alt("Видения меркнут.")
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_MAGIC

/datum/brain_trauma/severe/eldritch_beauty/on_life()
	if(prob(8))
		to_chat(owner, span_warning_alt(pick("Узоры на стенах складываются в нечто прекрасное и неправильное.", "Вы не можете отвести взгляд от пустоты.", "Красота Обители зовёт вас.")))

/datum/brain_trauma/severe/italian_tumor
	name = "Italian Tumor"
	desc = "Пациент видит вместо живых существ невозможных тварей, а вместо речи слышит только их имена."
	scan_desc = "опухоль в височно-затылочной области"
	gain_text = span_warning_alt("В голове что-то тяжело ворочается, и вы перестаёте узнавать всё вокруг...")
	lose_text = span_notice_alt("Твари вокруг расплываются, и вы снова узнаёте лица.")
	var/list/delusions = list()
	var/static/list/beasts = list(
		"Tralalero Tralala" = "tralalelo",
		"Trippi Troppi" = "tralalelo",
		"Frulli Frulla" = "tralalelo",
		"Bombardiro Crocodilo" = "crocodilo",
		"Bombombini Gusini" = "crocodilo",
		"Glorbo Fruttodrillo" = "crocodilo",
		"Tung Tung Tung Sahur" = "sahur",
		"Cappuccino Assassino" = "sahur",
		"Boneca Ambalabu" = "sahur",
		"Brr Brr Patapim" = "bear",
		"Chimpanzini Bananini" = "bear",
		"Bobrito Bandito" = "bear",
		"Lirili Larila" = "candy",
		"Ballerina Cappuccina" = "candy",
		"Burbaloni Luliloli" = "candy",
	)

/datum/brain_trauma/severe/italian_tumor/on_gain()
	. = ..()
	ADD_TRAIT(owner, TRAIT_ITALIAN_TUMOR, TRAUMA_TRAIT)
	owner.mob_flags |= MOB_HAS_SCREENTIPS_NAME_OVERRIDE
	RegisterSignal(owner, COMSIG_MOB_REQUESTING_SCREENTIP_NAME_FROM_USER, PROC_REF(override_screentip_name))
	RegisterSignal(owner, COMSIG_LIVING_PERCEIVE_EXAMINE_NAME, PROC_REF(override_examine_name))
	refresh_delusions()

/datum/brain_trauma/severe/italian_tumor/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_ITALIAN_TUMOR, TRAUMA_TRAIT)
	owner.mob_flags &= ~MOB_HAS_SCREENTIPS_NAME_OVERRIDE
	UnregisterSignal(owner, list(COMSIG_MOB_REQUESTING_SCREENTIP_NAME_FROM_USER, COMSIG_LIVING_PERCEIVE_EXAMINE_NAME))
	clear_delusions()
	return ..()

/datum/brain_trauma/severe/italian_tumor/on_life()
	refresh_delusions()

/datum/brain_trauma/severe/italian_tumor/handle_hearing(datum/source, mob/speaker, list/message_pieces)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == speaker)
		return

	for(var/datum/multilingual_say_piece/piece in message_pieces)
		if(!piece.message)
			continue
		var/list/words = splittext(piece.message, " ")
		var/list/babble = list()
		for(var/spoken in 1 to min(length(words), ITALIAN_TUMOR_MAX_NAMES))
			babble += pick(beasts)
		piece.message = jointext(babble, ", ")

/datum/brain_trauma/severe/italian_tumor/proc/refresh_delusions()
	if(!owner.client)
		return

	for(var/mob/living/creature as anything in GLOB.mob_living_list)
		if(creature == owner)
			continue
		disguise(creature)

/datum/brain_trauma/severe/italian_tumor/proc/disguise(mob/living/creature)
	var/creature_uid = creature.UID()
	var/image/beast = delusions[creature_uid]
	if(!beast)
		var/beast_name = pick(beasts)
		beast = image('icons/mob/italian_brainrot.dmi', creature, beasts[beast_name])
		beast.name = beast_name
		beast.override = TRUE
		delusions[creature_uid] = beast
		RegisterSignal(creature, COMSIG_QDELETING, PROC_REF(forget_creature))
	owner.client?.images |= beast
	return beast

/datum/brain_trauma/severe/italian_tumor/proc/forget_creature(mob/living/creature)
	SIGNAL_HANDLER
	UnregisterSignal(creature, COMSIG_QDELETING)
	var/creature_uid = creature.UID()
	owner?.client?.images -= delusions[creature_uid]
	delusions -= creature_uid

/datum/brain_trauma/severe/italian_tumor/proc/override_screentip_name(datum/source, list/returned_name, obj/item/held_item, atom/hovered)
	SIGNAL_HANDLER
	if(!isliving(hovered) || hovered == owner)
		return NONE
	var/image/beast = disguise(hovered)
	returned_name[1] = beast.name
	return SCREENTIP_NAME_SET

/datum/brain_trauma/severe/italian_tumor/proc/override_examine_name(datum/source, mob/living/examined, visible_name, list/name_override)
	SIGNAL_HANDLER
	if(examined == owner)
		return NONE
	var/image/beast = disguise(examined)
	name_override[1] = beast.name
	return COMPONENT_EXAMINE_NAME_OVERRIDEN

/datum/brain_trauma/severe/italian_tumor/proc/clear_delusions()
	for(var/creature_uid in delusions)
		var/mob/living/creature = locateUID(creature_uid)
		if(creature)
			UnregisterSignal(creature, COMSIG_QDELETING)
		owner?.client?.images -= delusions[creature_uid]
	delusions.Cut()

/mob/living/carbon/perceived_name(atom/movable/speaker, speaker_name)
	if(!HAS_TRAIT(src, TRAIT_ITALIAN_TUMOR) || !isliving(speaker) || speaker == src)
		return speaker_name

	var/datum/brain_trauma/severe/italian_tumor/tumor = has_trauma_type(/datum/brain_trauma/severe/italian_tumor)
	if(!tumor)
		return speaker_name
	var/image/beast = tumor.disguise(speaker)
	return beast.name

#undef MONOPHOBIA_PANIC_STRESS
#undef MONOPHOBIA_HEART_ATTACK_STRESS
#undef ITALIAN_TUMOR_MAX_NAMES
