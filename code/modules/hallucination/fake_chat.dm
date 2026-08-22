/// Fake chat hallucination. Sends a fake message to the hallucinator's chat.
/datum/hallucination/chat
	random_hallucination_weight = 100
	hallucination_tier = HALLUCINATION_TIER_COMMON

	/// If TRUE, the message is forced to go over the shared radio. Set to New().
	var/force_radio
	/// If set, forces this message to be selected rather than the auto-generated one.
	var/specific_message

/datum/hallucination/chat/New(mob/living/hallucinator, force_radio = FALSE, specific_message)
	src.force_radio = force_radio
	src.specific_message = specific_message
	return ..()

/datum/hallucination/chat/start()
	if(hallucinator.incapacitated())
		return FALSE

	var/mob/living/carbon/human/speaker
	var/datum/language/understood_language

	if(!force_radio)
		var/list/valid_humans = list()
		var/list/valid_corpses = list()
		for(var/mob/living/carbon/nearby_human in view(hallucinator))
			if(nearby_human == hallucinator)
				continue
			if(nearby_human.stat == DEAD)
				valid_corpses += nearby_human
				continue
			valid_humans += nearby_human

		for(var/mob/living/carbon/nearby_human in shuffle(valid_humans))
			speaker = nearby_human
			break

		if(isnull(speaker) && length(valid_corpses))
			speaker = pick(valid_corpses)

	var/is_radio = force_radio || isnull(speaker)
	if(is_radio)
		for(var/mob/living/carbon/human/crew_member in shuffle(GLOB.human_list))
			if(crew_member == hallucinator || !crew_member.mind)
				continue
			speaker = crew_member
			break

	if(isnull(speaker))
		return

	var/chosen = specific_message
	if(!chosen)
		if(is_radio)
			chosen = pick(list(
				"Помогите!",
				"Ксеноморфы!",
				"Синга вышла!",
				"Они взвели нюку!",
				"Клоун стащил ядерку!",
				"П-пом-могите!",
				"Нашел труп [hallucinator.name] в туалете.",
				"[hallucinator.name] [pick("вампир", "генокрад", "культист")]!",
				"Вызывайте шаттл!",
				"ИИ взломан!",
			))
		else
			chosen = pick(list(
				"Я слежу за тобой.",
				"[hallucinator.name]!",
				"Уйди!",
				"Ну и нахуй ты это сделал?",
				"Ты слышал это?",
				"Ты че делаешь?",
				"Почему?",
				"Отдай!",
				"Хонк!",
				"ПОМОГИТЕ!!",
				"БЕГИТЕ!!",
				"УБЕЙТЕ МЕНЯ!",
			))

	chosen = capitalize(chosen)

	feedback_details += "Type: [is_radio ? "Radio" : "Talk"], Source: [speaker.real_name], Message: [chosen]"

	var/list/message_pieces = message_to_multilingual(chosen, understood_language)
	if(!is_radio)
		hallucinator.hear_say(message_pieces, speaker = speaker, is_whisper = FALSE)
	else
		hallucinator.hear_radio(
			message_pieces,
			speaker = speaker,
			part_a = "<span class='[SSradio.frequency_span_class(PUB_FREQ)]'><b>\[[get_frequency_name(PUB_FREQ)]\]</b> <span class='name'>",
			part_b = "</span> <span class='message'>",
		)

	qdel(src)
	return TRUE
