#define CLING_HIVEMIND_UPLOAD "Поделиться"
#define CLING_HIVEMIND_ABSORB "Поглотить"

/// HIVE MIND UPLOAD/DOWNLOAD DNA
GLOBAL_LIST_EMPTY(hivemind_bank)

/datum/action/changeling/hivemind_pick
	name = "Сеть улья"
	desc = "Позволяет обмениваться ДНК на расстоянии."
	helptext = "Связь с ульем позволяет дистанционно поделиться или поглотить ДНК и говорить с другими генокрадами."
	button_icon_state = "hive_absorb"
	power_type = CHANGELING_INNATE_POWER
	/// Connected linglink ability.
	var/datum/action/changeling/linglink/linglink

/datum/action/changeling/hivemind_pick/on_purchase(mob/user, datum/antagonist/changeling/antag)
	if(!..())
		return FALSE

	var/language_key = cling.evented ? get_language_prefix(LANGUAGE_HIVE_EVENTLING) : get_language_prefix(LANGUAGE_HIVE_CHANGELING)
	desc = "Позволяет обмениваться ДНК на расстоянии. С помощью [language_key]можно говорить с собратьями."
	to_chat(user, span_changeling("Используйте [language_key]для общения с другими генокрадми."))
	return TRUE

/datum/action/changeling/hivemind_pick/Grant(mob/user)
	if(!..() || QDELETED(user) || !cling)
		return

	if(cling.evented)
		user.add_language(LANGUAGE_HIVE_EVENTLING)
	else
		user.add_language(LANGUAGE_HIVE_CHANGELING)

/datum/action/changeling/hivemind_pick/Remove(mob/user)
	if(QDELETED(user))
		return

	to_chat(user, span_changeling("Мы чувствуем пустоту, потеряв связь с ульем."))

	user.remove_language(LANGUAGE_HIVE_CHANGELING)
	user.remove_language(LANGUAGE_HIVE_EVENTLING)

	..()

/datum/action/changeling/hivemind_pick/Destroy(force)
	owner?.remove_language(LANGUAGE_HIVE_CHANGELING)
	owner?.remove_language(LANGUAGE_HIVE_EVENTLING)
	return ..()

/datum/action/changeling/hivemind_pick/sting_action(mob/user)
	var/channel_pick = tgui_alert(user, "Поделиться или поглотить ДНК?", "Сеть улья", list(CLING_HIVEMIND_UPLOAD, CLING_HIVEMIND_ABSORB))

	if(channel_pick == CLING_HIVEMIND_UPLOAD)
		dna_upload(user)

	if(channel_pick == CLING_HIVEMIND_ABSORB)
		if(cling.using_stale_dna())//If our current DNA is the stalest, we gotta ditch it.
			user.balloon_alert(user, "сначала нужно трансформироваться")
			return FALSE
		else
			dna_absorb(user)

	return TRUE

/datum/action/changeling/proc/dna_upload(mob/user)
	var/datum/dna/chosen_dna = cling.select_dna("Каким ДНК мы хотим поделиться?: ", "Поделиться ДНК", TRUE)
	if(!chosen_dna)
		user.balloon_alert(user, "не выбрано ДНК!")
		return FALSE

	GLOB.hivemind_bank += chosen_dna
	to_chat(user, span_notice("Мы поделились ДНК [chosen_dna.real_name] в сети улья."))
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/proc/dna_absorb(mob/user)
	var/list/names = list()
	for(var/datum/dna/DNA in GLOB.hivemind_bank)
		if(!(DNA in cling.absorbed_dna))
			names[DNA.real_name] = DNA

	if(!length(names))
		user.balloon_alert(user, "нет новых ДНК!")
		return FALSE

	var/choice = tgui_input_list(user, "Какое ДНК мы хотим поглотить?: ", "Поглощение ДНК", names)
	if(!choice)
		return FALSE

	var/datum/dna/chosen_dna = names[choice]
	cling.store_dna(chosen_dna)
	user.balloon_alert(user, "мы поглотили ДНК [choice]")
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

#undef CLING_HIVEMIND_UPLOAD
#undef CLING_HIVEMIND_ABSORB
