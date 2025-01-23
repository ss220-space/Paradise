/datum/objective/pulse_demon/infest
	name = "Hijack APCs"
	antag_menu_name = "Захватить ЛКП"
	/// Amount of APCs we need to hijack, can be 15, 20, or 25
	var/amount = 0

/datum/objective/pulse_demon/infest/New()
	. = ..()
	amount = rand(3, 5) * 5
	explanation_text = "Захватить [amount] ЛКП."


/datum/objective/pulse_demon/infest/check_completion()
	if(..())
		return TRUE
	var/hijacked = 0
	for(var/datum/mind/M in get_owners())
		if(!ispulsedemon(M.current) || QDELETED(M.current))
			continue
		var/mob/living/simple_animal/demon/pulse_demon/demon = M.current
		hijacked += length(demon.hijacked_apcs)
	return hijacked >= amount

/datum/objective/pulse_demon/drain
	name = "Drain Power"
	antag_menu_name = "поглотить энергию"
	/// Amount of power we need to drain, ranges from 500 KW to 5 MW
	var/amount = 0

/datum/objective/pulse_demon/drain/New()
	. = ..()
	amount = rand(1, 10) * 500000
	explanation_text = "Поглотите [format_si_suffix(amount)]W Энергии."

/datum/objective/pulse_demon/drain/check_completion()
	if(..())
		return TRUE
	var/drained = 0
	for(var/datum/mind/M in get_owners())
		if(!ispulsedemon(M.current) || QDELETED(M.current))
			continue
		var/mob/living/simple_animal/demon/pulse_demon/demon = M.current
		drained += demon.charge_drained
	return drained >= amount

// Requires 1 APC to be hacked and not destroyed to complete
/datum/objective/pulse_demon/tamper
	name = "Tamper Machinery"
	antag_menu_name = "Разрушать машины"
	explanation_text = "Наносите вред машинам в комнатах с захваченными вами ЛКП и защищайтесь от всех, кто пытается вас остановить."

/datum/objective/pulse_demon/tamper/check_completion()
	if(..())
		return TRUE
	for(var/datum/mind/M in get_owners())
		if(!ispulsedemon(M.current) || QDELETED(M.current))
			continue
		var/mob/living/simple_animal/demon/pulse_demon/demon = M.current
		if(!length(demon.hijacked_apcs) || !M.active || demon.stat == DEAD)
			return FALSE
	return TRUE
