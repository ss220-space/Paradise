/datum/antagonist/devil
	name = "Devil"
	roundend_category = "devils"
	job_rank = ROLE_DEVIL
	special_role = ROLE_DEVIL
	antag_hud_type = ANTAG_HUD_DEVIL

	var/datum/devilinfo/info = new
	var/list/soulsOwned
	var/datum/devil_rank/rank

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
	QDEL_NULL(info)
	LAZYNULL(soulsOwned)

	return ..()

/datum/antagonist/devil/proc/add_soul(datum/mind/soul)
	if((!istype(soul)) || (LAZYIN(soulsOwned, soul)))
		return

	LAZYADD(soulsOwned, soul)
	to_chat(owner.current, span_warning("Вы поглощаете душу и насыщаетесь ею."))

	owner.current.set_nutrition(NUTRITION_LEVEL_FULL)
	soul.hasSoul = FALSE

	try_update_rank()
	update_hud()

/datum/antagonist/devil/proc/remove_soul(datum/mind/soul)
	LAZYREMOVE(soulsOwned, soul)
	to_chat(owner.current, span_warning("Вы чувствуете, как часть ваших сил угасает"))
	update_hud()

/datum/antagonist/devil/proc/try_update_rank()
	if(!rank.required_souls || !rank.next_rank_type)
		return FALSE
	
	if(LAZYLEN(soulsOwned) < rank.required_souls)
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
	rank.apply_rank()
	rank.give_spells()

	return TRUE

/datum/antagonist/devil/proc/remove_spells()
	rank.remove_spells()
	info.obligation.remove_spells()

/datum/antagonist/devil/proc/update_hud()
	var/mob/living/living = owner.current

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
	LAZYADD(messages, span_warning("<b>Вы - [info.truename], агент ада, дьявол.\n\  
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
	human.store_memory("Your devilic true name is [info.truename]<br>[info.ban.law].<br>You may not directly and knowingly physically harm a devil, other than yourself.<br>[info.bane.law]<br>[info.obligation.law]<br>[info.banish.law]<br>")

	update_hud()

/datum/antagonist/devil/proc/init_devil()
	GLOB.allDevils[lowertext(info.truename)] = src
	rank = new BASIC_DEVIL_RANK()
	
	return

/datum/antagonist/devil/proc/init_bane()
	info.bane.link_bane(owner.current)
	info.bane.init_bane()

	return

/datum/antagonist/devil/proc/init_obligation()
	info.obligation.link_obligation(owner.current)
	info.obligation.apply_obligation_effect()
	info.obligation.give_spells()

	return

/datum/antagonist/devil/proc/init_ban()
	info.ban.link_ban(owner.current)
	info.ban.apply_ban_effect()

	return

/datum/antagonist/devil/give_objectives()
	add_objective(/datum/objective/devil/ascend)
	add_objective(/datum/objective/devil/sintouch)
	forge_sacrifice_objective()

/datum/antagonist/devil/proc/forge_sacrifice_objective()
	var/datum/objective/devil/sacrifice/sacrifice = new

	if(!sacrifice.forge())
		addtimer(CALLBACK(src, PROC_REF(forge_sacrifice_objective)), 1 MINUTES)
		qdel(sacrifice)
		return
	
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

	remove_spells()
	remove_hud()

	info.banish.remove_banish()
	info.bane.remove_bane()

	info.obligation.remove_obligation()
	info.ban.remove_ban()

	LAZYREMOVE(owner.current.faction, "hell")
	REMOVE_TRAIT(owner.current, TRAIT_NO_DEATH, UNIQUE_TRAIT_SOURCE(src))
