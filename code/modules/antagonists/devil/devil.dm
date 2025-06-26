/datum/antagonist/devil
	name = "Devil"
	roundend_category = "devils"
	antag_menu_name = "Дьявол"
	job_rank = ROLE_DEVIL
	special_role = ROLE_DEVIL
	antag_hud_type = ANTAG_HUD_DEVIL
	antag_hud_name = "huddevil"
	russian_wiki_name = "Торговец_душ"

	var/datum/devilinfo/info = new
	var/list/soulsOwned
	var/list/ritualSouls
	var/sacrifice_count
	var/datum/devil_rank/rank
	var/tmp/list/devil_targets
	var/list/shadows

	var/const/sacrifice_need = BLOOD_SACRIFICE + TRUE_SACRIFICE

/datum/antagonist/devil/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE

	var/datum/mind/tested = new_owner || owner
	if(!tested || !iscarbon(tested.current))
		return FALSE

	return TRUE

/datum/antagonist/devil/Destroy(force)
	QDEL_NULL(rank)
	LAZYNULL(soulsOwned)
	. = ..()
	QDEL_NULL(info)

/datum/antagonist/devil/proc/add_soul(datum/mind/soul)
	if((!istype(soul)) || (LAZYIN(soulsOwned, soul)))
		return

	LAZYOR(soulsOwned, soul)
	to_chat(owner.current, span_warning("Вы поглощаете душу и насыщаетесь ею."))

	owner.current.set_nutrition(NUTRITION_LEVEL_FULL)
	soul.hasSoul = FALSE
	soul.soulOwner = owner

	try_update_rank()
	update_hud()
	SStgui.update_uis(src)

/datum/antagonist/devil/proc/sacrifice_soul(datum/mind/soul)
	if(!istype(soul) || LAZYIN(soulsOwned, soul))
		return

	to_chat(owner.current, span_warning("Вы приносите душу в жертву."))
	soul.hasSoul = FALSE
	soul.soulOwner = owner
	sacrifice_count += 1
	LAZYOR(ritualSouls, soul)
	LAZYOR(soulsOwned, soul)
	try_update_rank()
	update_hud()
	SStgui.update_uis(src)

/datum/antagonist/devil/proc/remove_soul(datum/mind/soul, return_to_owner = TRUE)
	LAZYREMOVE(soulsOwned, soul)
	to_chat(owner.current, span_warning("Вы чувствуете, как часть ваших сил угасает."))
	update_hud()
	SStgui.update_uis(src)

	if(!return_to_owner)
		return

	soul.hasSoul = TRUE
	soul.soulOwner = soul
	soul.damnation_type = null

/datum/antagonist/devil/proc/try_update_rank(is_ritual = FALSE)
	if(!rank.required_souls || !rank.next_rank_type)
		return FALSE

	if(rank.ritual_required && !is_ritual)
		return FALSE

	if(LAZYLEN(soulsOwned) < rank.required_souls)
		return FALSE

	if(sacrifice_count < rank.required_sacrifice)
		return FALSE

	if(!init_new_rank(rank.next_rank_type, TRUE))
		return FALSE

	return TRUE // rank updated.

/datum/antagonist/devil/proc/init_new_rank(typepath, remove_spells = FALSE)
	if(rank && remove_spells)
		rank.remove_spells()

	if(typepath)
		rank = new typepath()

	if(!rank)
		return FALSE // something bad occured, but we prevent runtimes

	rank.link_rank(owner.current)

	if(rank.apply_rank())
		return TRUE

	rank.give_spells()
	SStgui.update_uis(src)
	return TRUE

/datum/antagonist/devil/proc/remove_spells()
	rank?.remove_spells()
	info.obligation.remove_spells()

/datum/antagonist/devil/proc/update_hud()
	var/mob/living/living = owner.current

	if(!living.hud_used)
		addtimer(CALLBACK(src, PROC_REF(update_hud), 1 SECONDS))
		return

	if(!living.hud_used?.devilsouldisplay)
		living.hud_used.devilsouldisplay = new /atom/movable/screen/devil/soul_counter(null, living.hud_used)
		living.hud_used.infodisplay += living.hud_used.devilsouldisplay

	living.hud_used?.devilsouldisplay.update_counter(LAZYLEN(soulsOwned))

/datum/antagonist/devil/proc/remove_hud()
	var/mob/living/living = owner.current

	if(!living.hud_used?.devilsouldisplay)
		return

	living.hud_used.infodisplay -= living.hud_used.devilsouldisplay
	qdel(living.hud_used.devilsouldisplay)

/datum/antagonist/devil/greet()
	var/list/messages = list()
	LAZYADD(messages, span_warning("<b>Вы – [info.truename], агент ада, дьявол.\n\
	Вы прибыли сюда, преследуя важную цель.\n\
	Склоните экипаж к грехопадению и укрепите влияние ада.</b>"))
	LAZYADD(messages, "Вы никак не можете навредить другим дьяволам.")
	LAZYADD(messages, info.bane.law)
	LAZYADD(messages, info.ban.law)
	LAZYADD(messages, info.obligation.law)
	LAZYADD(messages, info.banish.law)
	LAZYADD(messages, "[span_warning("Помните, экипаж может найти ваши слабости, если раскроет ваше истинное имя!")]<br>")
	return messages

/datum/antagonist/devil/on_gain()
	init_devil()

	. = ..()

	if(!.)
		return FALSE

	var/mob/living/carbon/human/human = owner.current
	human.store_memory("Ваше истинное имя — [info.truename]<br>[info.ban.law].<br>Вы не можете сознательно и напрямую причинить физический вред другому дьяволу, за исключением себя самого.<br>[info.bane.law]<br>[info.obligation.law]<br>[info.banish.law]<br>")

	update_hud()

/datum/antagonist/devil/proc/init_devil()
	GLOB.allDevils[lowertext(info.truename)] = info
	rank = new BASIC_DEVIL_RANK()

	return

/datum/antagonist/devil/proc/init_bane()
	info?.bane.link_bane(owner.current)
	info.bane.init_bane()

	return

/datum/antagonist/devil/proc/init_obligation()
	info?.obligation.link_obligation(owner.current)
	info.obligation.apply_obligation_effect()
	info.obligation.give_spells()

	return

/datum/antagonist/devil/proc/init_ban()
	info?.ban.link_ban(owner.current)
	info.ban.apply_ban_effect()

	return

/datum/antagonist/devil/give_objectives()
	add_objective(/datum/objective/devil/ascend)
	add_objective(/datum/objective/devil/sintouch)
	forge_sacrifice_objective()

/datum/antagonist/devil/proc/forge_sacrifice_objective()

	for(var/i in 1 to BLOOD_SACRIFICE)
		var/datum/objective/devil/sacrifice/command/sacrifice = new
		add_objective(sacrifice)

	for(var/i in 1 to (TRUE_SACRIFICE + ASCEND_SACRIFICE - BLOOD_SACRIFICE))
		var/datum/objective/devil/sacrifice/security/sacrifice = new
		add_objective(sacrifice)

/datum/antagonist/devil/add_owner_to_gamemode()
	LAZYADD(SSticker.mode.devils, owner)

/datum/antagonist/devil/remove_owner_from_gamemode()
	LAZYREMOVE(SSticker.mode.devils, owner)

/datum/antagonist/devil/farewell()
	to_chat(owner.current, span_userdanger("Ваша связь с адом пропадает. Вы более не дьявол!"))

/datum/antagonist/devil/apply_innate_effects(mob/living/mob_override)
	. = ..()
	owner.current.AddElement(/datum/element/devil_regeneration)
	owner.current.AddElement(/datum/element/devil_banishment) // handles devil banishes
	ADD_TRAIT(owner.current, TRAIT_ABSOLUTE_VIRUSIMMUNE, DEVIL_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_HEALS_FROM_HELL_RIFTS, DEVIL_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESIST_HEAT, DEVIL_TRAIT)

	init_new_rank()
	init_bane()

	init_obligation()
	init_ban()

	update_hud()
	info.banish.link_banish(owner.current)
	LAZYADD(owner.current.faction, "hell")
	ADD_TRAIT(owner.current, TRAIT_NO_DEATH, UNIQUE_TRAIT_SOURCE(src))

/datum/antagonist/devil/remove_innate_effects()
	. = ..()
	owner.current.RemoveElement(/datum/element/devil_regeneration)
	owner.current.RemoveElement(/datum/element/devil_banishment)
	REMOVE_TRAIT(owner.current, TRAIT_ABSOLUTE_VIRUSIMMUNE, DEVIL_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_HEALS_FROM_HELL_RIFTS, DEVIL_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESIST_HEAT, DEVIL_TRAIT)

	remove_spells()
	remove_hud()

	info.banish?.remove_banish()
	info.bane?.remove_bane()

	info.obligation?.remove_obligation()
	info.ban?.remove_ban()

	LAZYREMOVE(owner.current.faction, "hell")
	REMOVE_TRAIT(owner.current, TRAIT_NO_DEATH, UNIQUE_TRAIT_SOURCE(src))

/datum/antagonist/devil/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Open UI
		ui = new(user, src, "DevilInfo")
		ui.open()


/datum/antagonist/devil/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE

/datum/antagonist/devil/ui_data()
	var/list/data = list()
	data["true_name"] = info.truename
	data["ban"] = info.ban.law
	data["obligation"] = info.obligation.law
	data["banish"] = info.banish.law
	data["bane"] = info.bane.law
	data["souls_count"] = LAZYLEN(soulsOwned)
	data["sacrifice_count"] = LAZYLEN(ritualSouls)
	data["rank"] = rank.name
	data["next_rank"] = rank.next_rank_type?.name
	data["required_souls"] = rank.required_souls || 0
	data["sacrifice_required"] = rank.required_sacrifice || 0
	data["ritual_required"] = rank.ritual_required

	return data


/**
 * Takes any datum `source` and checks it for changeling datum.
 */
/proc/isdevilantag(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/devil)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/devil)

/datum/antagonist/devil/roundend_report()
	var/text
	var/traitorwin = TRUE
	text += "<br>[owner.get_display_key()] был [owner.name], известный в аду как [info.truename]("
	if(owner.current)
		if(owner.current.stat == DEAD)
			text += "умер"
			traitorwin = FALSE
		else
			text += "жив"
	else
		text += "тело уничтожено"
		traitorwin = FALSE
	text += ")<br>"

	text += "Запрет: [info?.ban?.law] <br>"
	text += "Обязательство: [info?.obligation?.law] <br>"
	text += "Слабость: [info?.bane?.law] <br>"
	text += "Изгнание: [info?.banish?.law] <br>"
	var/soul_count = soulsOwned?.len || 0
	var/rituals_count = ritualSouls?.len || 0
	text += "Куплено душ: [max(soul_count - rituals_count, 0)]<br>"
	text += "Принесено жертв: [rituals_count]<br>"
	text += "Наложено проклятий тени: [shadows?.len || 0]<br>"

	var/list/all_objectives = owner.get_all_objectives()

	if(length(all_objectives))
		var/count = 1
		for(var/datum/objective/objective in all_objectives)
			if(objective.check_completion())
				text += "<br><b>Цель #[count]</b>: [objective.explanation_text] <b>[span_green("Успех!")]</b>"
				SSblackbox.record_feedback("nested tally", "devil_objective", 1, list("[objective.type]", "SUCCESS"))
			else
				text += "<br><b>Цель #[count]</b>: [objective.explanation_text] [span_red("Провал!")]"
				SSblackbox.record_feedback("nested tally", "devil_objective", 1, list("[objective.type]", "FAIL"))
				traitorwin = FALSE
			count++

	if(traitorwin)
		text += span_green("<br><b>Дьявол был успешен!</b>")
		SSblackbox.record_feedback("tally", "devil_success", 1, "SUCCESS")
	else
		text += span_red("<br><b>Дьявол провалился!</b>")
		SSblackbox.record_feedback("tally", "devil_success", 1, "FAIL")

	return text

