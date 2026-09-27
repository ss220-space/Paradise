#define SHADOWLING_MIN_THRALLS 15
#define SHADOWLING_MAX_THRALLS 25
#define SHADOWLING_WARNING_RATIO 0.66

/datum/team/shadowling
	name = "Тенеморфы"
	antag_datum_type = /datum/antagonist/shadowling
	var/required_thralls = SHADOWLING_MIN_THRALLS
	var/thrall_ratio = 1
	var/warning_threshold
	var/victory_warning_announced = FALSE
	var/ascended = FALSE
	var/wiped_out = FALSE

/datum/team/shadowling/New(list/starting_members)
	. = ..()
	recount_required_thralls()

/proc/get_shadowling_team()
	RETURN_TYPE(/datum/team/shadowling)
	return GLOB.antagonist_teams[/datum/team/shadowling] || create_antag_team(/datum/team/shadowling)

/datum/team/shadowling/proc/recount_required_thralls()
	required_thralls = clamp(round(SSticker.mode.num_players() / 3), SHADOWLING_MIN_THRALLS, SHADOWLING_MAX_THRALLS)
	thrall_ratio = required_thralls / SHADOWLING_MIN_THRALLS
	warning_threshold = round(SHADOWLING_WARNING_RATIO * required_thralls)

/datum/team/shadowling/proc/try_announce_victory_warning()
	if(victory_warning_announced || length(get_antag_minds(/datum/antagonist/shadowling_thrall)) < warning_threshold)
		return
	victory_warning_announced = TRUE
	GLOB.major_announcement.announce(
		message = "Сканерами дальнего действия обнаружена большая концентрация психической блюспейс-энергии. Вероятность вознесения тенеморфов высока, всему экипажу следует предотвратить вознесение любой ценой!",
		new_title = ANNOUNCE_CCPARANORMAL_RU,
		new_sound = SSstation.announcer.get_rand_report_sound(),
	)
	log_game("Shadowling reveal. Powergame and validhunt allowed.")

/datum/team/shadowling/declare_completion()
	if(!length(members))
		return

	var/list/text = list()
	var/result
	if(ascended && EMERGENCY_ESCAPED_OR_ENDGAMED)
		result = "Победа тенелингов — тенелинги возвысились"
		text += span_fontsize3("<b>Победа тенелингов</b>")
		text += span_greentext("<b>Тенелинги возвысились и полностью захватили станцию!</b>")
	else if(wiped_out && !ascended)
		result = "Тенелинги проиграли — тенелинги погибли"
		text += span_fontsize3("<b>Крупная победа экипажа</b>")
		text += span_redtext("<b>Тенелинги были убиты экипажем!</b>")
	else if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		result = "Тенелинги проиграли — экипаж сбежал"
		text += span_fontsize3("<b>Мелкая победа экипажа</b>")
		text += span_redtext("<b>Экипаж сбежал со станции до того, как тенелинги возвысились!</b>")
	else
		result = "Тенелинги проиграли — тенелинги не справились"
		text += span_fontsize3("<b>Крупная победа экипажа</b>")
		text += span_redtext("<b>Тенелинги не смогли возвыситься!</b>")

	if(sets_round_result)
		SSticker.mode_result = result

	text += span_big("<b>Тенеморфами были:</b>")
	for(var/datum/mind/shadow as anything in get_antag_minds(/datum/antagonist/shadowling))
		text += print_shadowling_status(shadow)

	var/list/datum/mind/thralls = get_antag_minds(/datum/antagonist/shadowling_thrall)
	if(length(thralls))
		text += span_big("<b>Рабами были:</b>")
		for(var/datum/mind/thrall as anything in thralls)
			text += print_shadowling_status(thrall)

	return text.Join("<br>")

/datum/team/shadowling/proc/print_shadowling_status(datum/mind/member)
	var/text = "[member.get_mind_key()] был [member.name] ("
	if(!member.current)
		return text + "тело уничтожено)"
	text += member.current.stat == DEAD ? "погиб" : "выжил"
	if(member.current.real_name != member.name)
		text += " как <b>[member.current.real_name]</b>"
	return text + ")"

#undef SHADOWLING_MIN_THRALLS
#undef SHADOWLING_MAX_THRALLS
#undef SHADOWLING_WARNING_RATIO
