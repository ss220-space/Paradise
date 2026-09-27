/datum/brain_trauma/hypnosis
	name = "Hypnosis"
	desc = "Подсознание пациента полностью захвачено словом или фразой, вокруг которой вращаются все его мысли и поступки."
	scan_desc = "зациклившийся ход мыслей"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_SURGERY
	random_gain = FALSE
	var/datum/antagonist/hypnotized/antagonist
	var/hypnotic_phrase
	var/regex/target_phrase

/datum/brain_trauma/hypnosis/New(phrase)
	if(!phrase)
		qdel(src)
		return

	hypnotic_phrase = phrase
	try
		target_phrase = new("(\\b[REGEX_QUOTE(hypnotic_phrase)]\\b)", "ig")
	catch(var/exception/regex_error)
		stack_trace("[regex_error] on [regex_error.file]:[regex_error.line]")
		qdel(src)
	..()

/datum/brain_trauma/hypnosis/on_gain()
	message_admins("[ADMIN_LOOKUPFLW(owner)] was hypnotized with the phrase '[hypnotic_phrase]'.")
	owner.create_log(MISC_LOG, "was hypnotized with the phrase '[hypnotic_phrase]'")
	to_chat(owner, span_reallybig(span_hypnophrase("[hypnotic_phrase]")))
	to_chat(owner, span_notice(pick(
		"Что-то в этих словах кажется... правильным. Вы чувствуете, что должны им следовать.",
		"Эти слова эхом отдаются в голове. Вы полностью ими очарованы.",
		"Часть вашего разума повторяет это снова и снова. Вы должны следовать этим словам.",
		"Ваши мысли сходятся на этой фразе... вы не можете выкинуть её из головы.",
		"Голова болит, но вы способны думать только об этом. Это жизненно важно.",
	)))
	to_chat(owner, span_boldwarning("Вы загипнотизированы этой фразой и должны ей следовать. Если это не прямой приказ, вы вольны трактовать его как угодно, пока действуете так, будто эти слова — ваш главный приоритет."))
	var/atom/movable/screen/alert/hypnosis/hypno_alert = owner.throw_alert("hypnosis", /atom/movable/screen/alert/hypnosis)
	if(hypno_alert)
		hypno_alert.desc = "«[hypnotic_phrase]»... ваш разум зациклен на этой мысли."
	if(owner.mind)
		antagonist = owner.mind.add_antag_datum(new /datum/antagonist/hypnotized(hypnotic_phrase))
		antagonist.trauma = src
	return ..()

/datum/brain_trauma/hypnosis/on_lose(silent)
	message_admins("[ADMIN_LOOKUPFLW(owner)] is no longer hypnotized with the phrase '[hypnotic_phrase]'.")
	owner.create_log(MISC_LOG, "is no longer hypnotized with the phrase '[hypnotic_phrase]'")
	to_chat(owner, span_userdanger("Гипноз внезапно отпускает вас. Фраза «[hypnotic_phrase]» больше не кажется важной."))
	owner.clear_alert("hypnosis")
	if(antagonist)
		antagonist.trauma = null
	owner.mind?.remove_antag_datum(/datum/antagonist/hypnotized)
	antagonist = null
	return ..()

/datum/brain_trauma/hypnosis/on_life()
	if(prob(2))
		to_chat(owner, span_hypnophrase("<i>...[lowertext(hypnotic_phrase)]...</i>"))

/datum/brain_trauma/hypnosis/handle_hearing(datum/source, mob/speaker, list/message_pieces)
	if(!target_phrase || HAS_TRAIT(owner, TRAIT_DEAF) || owner == speaker)
		return

	for(var/datum/multilingual_say_piece/piece in message_pieces)
		piece.message = target_phrase.Replace(piece.message, span_hypnophrase("$1"))

/atom/movable/screen/alert/hypnosis
	name = "Гипноз"
	desc = "Что-то гипнотизирует вас, но вы не вполне понимаете, что именно."
	icon_state = "hypnosis"
