#define PERSONALITY_OWNER 0
#define PERSONALITY_STRANGER 1

/datum/brain_trauma/severe/split_personality
	name = "Split Personality"
	desc = "Мозг пациента расщеплён на две личности, которые случайным образом сменяют друг друга у руля."
	scan_desc = "полное разделение долей"
	gain_text = span_warning_alt("Вам кажется, что ваш разум раскололся надвое.")
	lose_text = span_notice_alt("Вы снова одни в своей голове.")
	var/current_controller = PERSONALITY_OWNER
	var/polling_finished = FALSE
	var/mob/living/split_personality/stranger_backseat
	var/mob/living/split_personality/owner_backseat
	var/poll_role = "расщеплённую личность"
	var/poll_time = 20 SECONDS
	var/backseat_type = /mob/living/split_personality

/datum/brain_trauma/severe/split_personality/on_gain()
	if(owner.stat == DEAD || !owner.client)
		return FALSE

	. = ..()
	make_backseats()
	INVOKE_ASYNC(src, PROC_REF(get_ghost))

/datum/brain_trauma/severe/split_personality/on_lose(silent)
	if(current_controller != PERSONALITY_OWNER)
		switch_personalities(TRUE)
	QDEL_NULL(stranger_backseat)
	QDEL_NULL(owner_backseat)
	return ..()

/datum/brain_trauma/severe/split_personality/on_life()
	if(owner.stat == DEAD)
		if(current_controller != PERSONALITY_OWNER)
			switch_personalities(TRUE)
		qdel(src)
		return

	if(prob(3))
		switch_personalities()

/datum/brain_trauma/severe/split_personality/proc/make_backseats()
	stranger_backseat = new backseat_type(owner, src)
	owner_backseat = new(owner, src)

/datum/brain_trauma/severe/split_personality/proc/get_ghost()
	var/list/candidates = SSghost_spawns.poll_candidates(
		question = "Вы хотите сыграть за [poll_role] [owner.real_name]?",
		role = ROLE_SENTIENT,
		poll_time = poll_time,
		source = owner,
		role_cleanname = poll_role,
	)
	if(QDELETED(src))
		return
	schism(length(candidates) ? pick(candidates) : null)

/datum/brain_trauma/severe/split_personality/proc/schism(mob/dead/observer/ghost)
	if(QDELETED(ghost) || QDELETED(stranger_backseat) || QDELETED(owner))
		qdel(src)
		return

	stranger_backseat.possess_by_player(ghost.ckey)
	stranger_backseat.tts_seed = SStts.get_random_seed(stranger_backseat)
	stranger_backseat.change_voice()
	polling_finished = TRUE
	add_game_logs("became [key_name(owner)]'s split personality", stranger_backseat)
	message_admins("[ADMIN_LOOKUPFLW(stranger_backseat)] became [ADMIN_LOOKUPFLW(owner)]'s split personality.")

/datum/brain_trauma/severe/split_personality/proc/switch_personalities(reset_to_owner = FALSE)
	if(QDELETED(owner) || QDELETED(stranger_backseat) || QDELETED(owner_backseat))
		return

	var/mob/living/split_personality/current_backseat
	var/mob/living/split_personality/new_backseat
	if(current_controller == PERSONALITY_STRANGER || reset_to_owner)
		current_backseat = owner_backseat
		new_backseat = stranger_backseat
	else
		current_backseat = stranger_backseat
		new_backseat = owner_backseat

	if(!current_backseat.client)
		return

	add_game_logs("assumed control of [key_name(owner)] due to [name]", current_backseat)
	to_chat(owner, span_userdanger("Вы чувствуете, как контроль ускользает от вас... теперь телом управляет ваша вторая личность!"))
	to_chat(current_backseat, span_userdanger("Вам удаётся перехватить управление собственным телом!"))

	var/body_id = owner.computer_id
	var/body_ip = owner.lastKnownIP
	owner.computer_id = null
	owner.lastKnownIP = null

	new_backseat.possess_by_player(owner.ckey)
	new_backseat.name = owner.name
	if(!new_backseat.computer_id)
		new_backseat.computer_id = body_id
	if(!new_backseat.lastKnownIP)
		new_backseat.lastKnownIP = body_ip

	var/backseat_id = current_backseat.computer_id
	var/backseat_ip = current_backseat.lastKnownIP
	current_backseat.computer_id = null
	current_backseat.lastKnownIP = null

	owner.possess_by_player(current_backseat.ckey)
	if(!owner.computer_id)
		owner.computer_id = backseat_id
	if(!owner.lastKnownIP)
		owner.lastKnownIP = backseat_ip

	current_controller = !current_controller

/mob/living/split_personality
	name = "split personality"
	real_name = "неизвестное сознание"
	var/mob/living/carbon/body
	var/datum/brain_trauma/severe/split_personality/trauma

/mob/living/split_personality/Initialize(mapload, datum/brain_trauma/severe/split_personality/new_trauma)
	. = ..()
	trauma = new_trauma
	if(iscarbon(loc))
		body = loc
		name = body.real_name
		real_name = body.real_name
		tts_seed = body.tts_seed

	var/datum/action/innate/personality_commune/commune = new(trauma)
	commune.Grant(src)

/mob/living/split_personality/Destroy()
	body = null
	trauma = null
	return ..()

/mob/living/split_personality/Life(seconds, times_fired)
	if(QDELETED(body))
		qdel(src)
		return

	if(body.stat == DEAD && trauma.owner_backseat == src)
		trauma.switch_personalities()
		qdel(trauma)
		return

	if(!body.client && trauma.polling_finished)
		trauma.switch_personalities()
		qdel(trauma)
		return

	return ..()

/mob/living/split_personality/Login()
	. = ..()
	if(!client)
		return
	to_chat(src, span_notice("Как расщеплённая личность, вы не можете ничего, кроме как наблюдать. Однако рано или поздно вы получите контроль над телом, поменявшись местами с текущей личностью."))
	to_chat(src, span_boldwarning("Не совершайте суицид и не подставляйте тело под удар. Ведите себя так, будто оно дорого вам не меньше, чем его хозяину."))

/mob/living/split_personality/ghost()
	if(tgui_alert(src, "Вы уверены, что хотите перестать быть расщеплённой личностью?", "Призрак", list("Остаться", "Стать призраком")) != "Стать призраком")
		return
	ghostize()

/mob/living/split_personality/be_suicidal(forced = FALSE)
	to_chat(src, span_warning("Вы не можете покончить с собой — телом управляет ваше второе «я»!"))

/mob/living/split_personality/say(message, verb = "говор[PLUR_IT_YAT(src)]", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE, ignore_emotes = FALSE)
	to_chat(src, span_warning("Вы не можете говорить, вашим телом управляет ваше второе «я»!"))

/mob/living/split_personality/say_understands(atom/movable/other, datum/language/speaking = null)
	if(!body)
		return ..()
	return body.say_understands(other, speaking)

/mob/living/split_personality/emote(emote_key, type_override = null, message = null, intentional = FALSE, force_silence = FALSE, ignore_cooldowns = FALSE)
	return FALSE

/datum/action/innate/personality_commune
	name = "Связь с личностью"
	desc = "Передать мысль своему второму «я»."
	button_icon_state = "alien_whisper"

/datum/action/innate/personality_commune/Activate()
	var/datum/brain_trauma/severe/split_personality/split = target
	var/mob/living/split_personality/backseat = owner
	if(QDELETED(split) || QDELETED(split.owner) || split.owner.client == backseat.client)
		return

	var/message = tgui_input_text(backseat, "Что вы хотите сказать своему второму «я»?", "Связь с личностью", max_length = MAX_MESSAGE_LEN)
	if(!message || QDELETED(split) || QDELETED(split.owner))
		return

	to_chat(backseat, "[span_boldnotice("Вы сосредотачиваетесь и передаёте мысль своему второму «я»:")] [span_notice(message)]")
	to_chat(split.owner, "[span_boldnotice("Вы слышите эхо чужого голоса на задворках сознания...")] [span_notice(message)]")
	INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, null, split.owner, message, backseat.tts_seed, FALSE)
	add_say_logs(backseat, message, split.owner)

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		to_chat(ghost, "[FOLLOW_LINK(ghost, backseat)] [span_boldnotice("[backseat] ([name]):")] [span_notice("«[message]»")]")

/datum/brain_trauma/severe/split_personality/brainwashing
	gain_text = ""
	lose_text = span_notice_alt("Промывка мозгов отпускает вас.")
	can_gain = FALSE
	known_trauma = FALSE
	poll_role = "промытое сознание"
	poll_time = 7.5 SECONDS
	backseat_type = /mob/living/split_personality/traitor
	var/codeword
	var/objective

/datum/brain_trauma/severe/split_personality/brainwashing/New(new_codeword, new_objective)
	codeword = new_codeword || pick(strings(BRAIN_DAMAGE_FILE, "items"))
	objective = new_objective
	return ..()

/datum/brain_trauma/severe/split_personality/brainwashing/on_gain()
	. = ..()
	if(QDELETED(src))
		return

	var/mob/living/split_personality/traitor/traitor_backseat = stranger_backseat
	traitor_backseat.codeword = codeword
	traitor_backseat.objective = objective

/datum/brain_trauma/severe/split_personality/brainwashing/on_life()
	return

/datum/brain_trauma/severe/split_personality/brainwashing/handle_hearing(datum/source, mob/speaker, list/message_pieces)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == speaker)
		return

	var/triggered = FALSE
	for(var/datum/multilingual_say_piece/piece in message_pieces)
		if(!findtext(piece.message, codeword) || !owner.say_understands(speaker, piece.speaking))
			continue
		piece.message = replacetext(piece.message, codeword, span_warning("[codeword]"))
		triggered = TRUE

	if(triggered)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/brain_trauma/severe/split_personality, switch_personalities)), 1 SECONDS, TIMER_DELETE_ME)

/datum/brain_trauma/severe/split_personality/brainwashing/handle_speech(datum/source, list/speech_args)
	if(findtext(speech_args[SPEECH_MESSAGE], codeword))
		speech_args[SPEECH_MESSAGE] = ""

/mob/living/split_personality/traitor
	var/codeword
	var/objective

/mob/living/split_personality/traitor/Login()
	. = ..()
	if(!client)
		return
	to_chat(src, span_notice("Как промытое сознание, вы пока не можете ничего, кроме как наблюдать. Но вы получите контроль над телом, услышав особое кодовое слово, и поменяетесь местами с текущей личностью."))
	to_chat(src, span_notice("Ваше кодовое слово: <b>[codeword]</b>"))
	if(objective)
		to_chat(src, span_notice("Ваш хозяин оставил вам задание: <b>[objective]</b>. Следуйте ему любой ценой, пока управляете телом."))

/datum/brain_trauma/severe/split_personality/blackout
	name = "Alcohol-Induced CNS Impairment"
	desc = "ЦНС пациента временно подавлена выпитым алкоголем, что блокирует формирование памяти и вызывает отупение."
	scan_desc = "алкогольное угнетение ЦНС"
	gain_text = span_warning_alt("Чёрт, вот этот стакан был лишним. Вы отключаетесь...")
	lose_text = span_notice_alt("Вы приходите в себя в полном недоумении и с тяжёлого похмелья. Вы помните только то, что много пили... что вообще было?")
	random_gain = FALSE
	poll_role = "отключившегося пьяницу"
	poll_time = 10 SECONDS
	backseat_type = /mob/living/split_personality/blackout
	var/sober_time

/datum/brain_trauma/severe/split_personality/blackout/on_gain()
	. = ..()
	sober_time = world.time + 3 MINUTES

/datum/brain_trauma/severe/split_personality/blackout/on_life()
	if(owner.stat == DEAD)
		if(current_controller != PERSONALITY_OWNER)
			switch_personalities(TRUE)
		qdel(src)
		return

	var/seconds_left = round((sober_time - world.time) / (1 SECONDS))
	if(seconds_left <= 0)
		qdel(src)
		return

	if(seconds_left <= 60 && !(seconds_left % 20))
		to_chat(owner, span_warning("Вам осталось [seconds_left] секунд до отрезвления!"))

	if(current_controller == PERSONALITY_OWNER && stranger_backseat?.client)
		owner.overlay_fullscreen("fade_to_black", /atom/movable/screen/fullscreen/blind)
		owner.clear_fullscreen("fade_to_black", animated = 4 SECONDS)
		switch_personalities()

	if(prob(10) && !HAS_TRAIT(owner, TRAIT_DISCOORDINATED))
		ADD_TRAIT(owner, TRAIT_DISCOORDINATED, TRAUMA_TRAIT)
		owner.balloon_alert(owner, "руки не слушаются!")
		addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_DISCOORDINATED, TRAUMA_TRAIT), 10 SECONDS)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, balloon_alert), owner, "руки снова слушаются"), 10 SECONDS)

	if(prob(15))
		owner.emote("burp")

	owner.adjustStaminaLoss(-25)

/mob/living/split_personality/blackout
	real_name = "пьяное сознание"

/mob/living/split_personality/blackout/Login()
	. = ..()
	if(!client)
		return
	to_chat(src, span_notice("Вы — вдребезги пьяные остатки сознания вашего носителя! Отыгрывайте эту роль и оставьте за собой след из недоумения и хаоса."))
	to_chat(src, span_boldwarning("Вы пьяны, но не самоубийца. Не совершайте суицид и не подставляйте тело под удар. У вас есть небольшая лицензия на грифинг, как у клоуна, но не убивайте никого и не создавайте ситуаций, в которых тело может пострадать."))

#undef PERSONALITY_OWNER
#undef PERSONALITY_STRANGER
