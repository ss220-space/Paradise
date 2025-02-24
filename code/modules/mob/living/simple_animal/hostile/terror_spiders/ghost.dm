/mob/living/simple_animal/hostile/poison/terror_spider/proc/extra_checks(mob/harbinger)
	if(harbinger.ckey in GLOB.ts_ckey_blacklist)
		to_chat(harbinger, "В этом раунде вы не можете управлять Пауками Ужаса.")
		return FALSE
	else if(cannotPossess(harbinger))
		to_chat(harbinger, "Вы включили Antag HUD и не можете повторно войти в раунд..")
		return FALSE
	else if(spider_awaymission)
		to_chat(harbinger, "Пауки Ужаса из гейтов не могут управляться игроками.")
		return FALSE
	else if(!ai_playercontrol_allowtype)
		to_chat(harbinger, "Этот конкретный тип Паука Ужаса не может управляться игроком.")
		return FALSE
	else if(degenerate || GLOB.global_degenerate)
		to_chat(harbinger, "Умирающими Пауками нельзя управлять.")
		return FALSE
	else if(!(harbinger in GLOB.respawnable_list))
		to_chat(harbinger, "Вы не можете повторно присоединиться к раунду.")
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/poison/terror_spider/proc/humanize_spider()
	add_datum_if_not_exist()
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message("<i>Призрак взял управление <b>[declent_ru(INSTRUMENTAL)]</b>. ([ghost_follow_link(src, ghost=G)]).</i>")


/mob/living/simple_animal/hostile/poison/terror_spider/proc/add_datum_if_not_exist()
	if(mind && !mind.has_antag_datum(/datum/antagonist/terror_spider))
		mind.add_antag_datum(datum_type, /datum/team/terror_spiders)
