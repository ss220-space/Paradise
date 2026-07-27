/datum/brain_trauma/hypnosis
	name = "Гипноз"
	desc = "Подсознание пациента полностью захвачено словом или фразой, подчиняющей его мысли и действия."
	scan_desc = "зацикленный паттерн мышления"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_SURGERY
	random_gain = FALSE
	var/datum/antagonist/hypnotized/antagonist
	var/hypnotic_phrase = ""
	var/regex/target_phrase

/datum/brain_trauma/hypnosis/New(phrase)
	if(!phrase)
		qdel(src)
		return
	hypnotic_phrase = phrase
	try
		target_phrase = new("(\\b[REGEX_QUOTE(hypnotic_phrase)]\\b)", "ig")
	catch(var/exception/error)
		stack_trace("[error] on [error.file]:[error.line]")
		qdel(src)
	..()

/datum/brain_trauma/hypnosis/on_gain()
	message_admins("[ADMIN_LOOKUPFLW(owner)] has been hypnotized with the phrase '[hypnotic_phrase]'.")
	add_game_logs("was hypnotized with the phrase '[hypnotic_phrase]'.", owner)
	to_chat(owner, span_reallybig(span_hypnophrase("[hypnotic_phrase]")))
	to_chat(owner, span_notice("[pick(list(
			"Что-то в этих словах звучит... правильно. Вы чувствуете, что должны следовать им.",
			"Эти слова эхом отдаются в вашей голове. Вы полностью очарованы ими.",
			"Часть вашего разума повторяет это снова и снова. Вы должны следовать этим словам.",
			"Ваши мысли сосредотачиваются на этой фразе... вы не можете выкинуть её из головы.",
			"Голова болит, но это — всё, о чём вы можете думать. Это должно быть жизненно важно.",
	))]"))
	to_chat(owner, span_boldwarning("Вы загипнотизированы этой фразой. Вы должны следовать этим словам. \
		Если это не прямой приказ, вы можете свободно трактовать, как именно им следовать, \
		но вы обязаны вести себя так, будто эти слова — ваш наивысший приоритет."))
	var/atom/movable/screen/alert/hypnosis/hypno_alert = owner.throw_alert("hypnosis", /atom/movable/screen/alert/hypnosis)
	if(owner.mind)
		antagonist = owner.mind.add_antag_datum(new /datum/antagonist/hypnotized(hypnotic_phrase))
		antagonist.trauma = src
	if(hypno_alert)
		hypno_alert.desc = "\"[hypnotic_phrase]\"... ваш разум зациклен на этой мысли."
	return ..()

/datum/brain_trauma/hypnosis/on_lose(silent)
	message_admins("[ADMIN_LOOKUPFLW(owner)] is no longer hypnotized with the phrase '[hypnotic_phrase]'.")
	add_game_logs("is no longer hypnotized with the phrase '[hypnotic_phrase]'.", owner)
	to_chat(owner, span_userdanger("Вы внезапно выходите из гипноза. Фраза '[hypnotic_phrase]' больше не кажется вам важной."))
	owner.clear_alert("hypnosis")
	..()
	if(!isnull(antagonist))
		antagonist.trauma = null
	owner.mind?.remove_antag_datum(/datum/antagonist/hypnotized)
	antagonist = null

/datum/brain_trauma/hypnosis/on_life(seconds_per_tick, times_fired)
	..()
	if(SPT_PROB(1, seconds_per_tick))
		to_chat(owner, span_hypnophrase("<i>...[lowertext(hypnotic_phrase)]...</i>"))

/datum/brain_trauma/hypnosis/handle_hearing(datum/source, list/hearing_args)
	if(!target_phrase || HAS_TRAIT(owner, TRAIT_DEAF) || owner == hearing_args[HEARING_SPEAKER])
		return
	hearing_args[HEARING_RAW_MESSAGE] = target_phrase.Replace(hearing_args[HEARING_RAW_MESSAGE], span_hypnophrase("$1"))

/atom/movable/screen/alert/hypnosis
	name = "Гипноз"
	desc = "Что-то гипнотизирует вас, но вы не вполне понимаете, что именно."
	icon_state = "hypnosis"
