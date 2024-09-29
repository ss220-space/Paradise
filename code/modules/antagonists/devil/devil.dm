/datum/antagonist/devil
	name = "Devil"
	roundend_category = "devils"
	job_rank = ROLE_DEVIL
	special_role = ROLE_DEVIL
	antag_hud_type = ANTAG_HUD_DEVIL

	var/datum/devilinfo/info
	var/list/datum/mind/soulsOwned = new
	var/datum/devil_rank/rank

	var/static/list/devil_spells = typecacheof(list(
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/conjure_item/violin,
		/obj/effect/proc_holder/spell/summon_dancefloor,
		/obj/effect/proc_holder/spell/sintouch,
		/obj/effect/proc_holder/spell/dark_conversion,
		/obj/effect/proc_holder/spell/aoe/devil_fire
		))

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
	soulsOwned = null
	QDEL_NULL(info)
	
	return ..()

/datum/antagonist/devil/proc/add_soul(datum/mind/soul)
	if(soulsOwned.Find(soul))
		return

	LAZYADD(soulsOwned, soul)
	owner.current.set_nutrition(NUTRITION_LEVEL_FULL)
	to_chat(owner.current, span_warning("You feel satiated as you received a new soul."))

	try_update_rank()
	update_hud()

/datum/antagonist/devil/proc/remove_soul(datum/mind/soul)
	LAZYREMOVE(soulsOwned, soul)
	to_chat(owner.current, span_warning("You feel as though a soul has slipped from your grasp."))
	update_hud()

/datum/antagonist/devil/proc/try_update_rank()
	var/devil_rank = update_rank()
	if(!devil_rank)
		return FALSE

	if(!init_new_rank(devil_rank))
		return FALSE

	return TRUE // rank updated.

/datum/antagonist/devil/proc/update_rank()
	switch(SOULVALUE)
		if(ENRAGED_THRESHOLD)
			. = ENRAGED_DEVIL_RANK
		if(BLOOD_THRESHOLD)
			. = BLOOD_LIZARD_RANK
		if(TRUE_THRESHOLD)
			. = TRUE_DEVIL_RANK

	return .

/datum/antagonist/devil/proc/init_new_rank(typepath)
	if(rank)
		rank.remove_spells()

	if(typepath)
		rank = new typepath()

	if(!rank)
		return FALSE // something bad occured, but we prevent runtimes

	rank.link_rank(owner.current)
	rank.apply_rank()
	rank.apply_spells()

	return TRUE

/datum/antagonist/devil/proc/remove_spells()
	for(var/obj/effect/proc_holder/spell/spell as anything in owner.spell_list)
		if(!is_type_in_typecache(spell, devil_spells))
			continue

		owner.RemoveSpell(spell)

/datum/antagonist/devil/proc/give_obligation_spells()
	switch(info.obligation)
		if(OBLIGATION_FIDDLE)
			owner.AddSpell(new /obj/effect/proc_holder/spell/conjure_item/violin(null))
		if(OBLIGATION_DANCEOFF)
			owner.AddSpell(new /obj/effect/proc_holder/spell/summon_dancefloor(null))

/datum/antagonist/devil/proc/update_hud()
	var/mob/living/living = owner.current

	if(!living.hud_used?.devilsouldisplay)
		living.hud_used.devilsouldisplay = new /atom/movable/screen/devil/soul_counter(null, living.hud_used)

	living.hud_used?.devilsouldisplay.update_counter(SOULVALUE)

/datum/antagonist/devil/proc/remove_hud()
	var/mob/living/living = owner.current

	if(!living.hud_used?.devilsouldisplay)
		return

	QDEL_NULL(living.hud_used.devilsouldisplay)

/datum/antagonist/devil/greet()
	var/list/messages = list()
	LAZYADD(messages, span_warning("<b>You remember your link to the infernal.  You are [info.truename], an agent of hell, a devil.  And you were sent to the plane of creation for a reason.  A greater purpose.  Convince the crew to sin, and embroiden Hell's grasp.</b>"))
	LAZYADD(messages, span_warning("<b>However, your infernal form is not without weaknesses.</b>"))
	LAZYADD(messages, "You may not use violence to coerce someone into selling their soul.")
	LAZYADD(messages, "You may not directly and knowingly physically harm a devil, other than yourself.")
	LAZYADD(messages, info.bane.law)
	LAZYADD(messages, GLOB.lawlorify[LAW][info.ban])
	LAZYADD(messages, GLOB.lawlorify[LAW][info.obligation])
	LAZYADD(messages, info.banish.law)
	LAZYADD(messages, "[span_warning("Remember, the crew can research your weaknesses if they find out your devil name.")]<br>")
	return messages

/datum/antagonist/devil/on_gain()
	init_devil()

	. = ..()
	if(!.)
		return FALSE
	
	init_bane()

	var/mob/living/carbon/human/human = owner.current
	human.store_memory("Your devilic true name is [info.truename]<br>[GLOB.lawlorify[LAW][info.ban]]<br>You may not use violence to coerce someone into selling their soul.<br>You may not directly and knowingly physically harm a devil, other than yourself.<br>[info.bane.law]<br>[GLOB.lawlorify[LAW][info.obligation]]<br>[info.banish.law]<br>")

	update_hud()
	init_new_rank(BASIC_DEVIL_RANK)

/datum/antagonist/devil/proc/init_devil()
	info = new info()
	GLOB.allDevils[lowertext(info.truename)] = src

	return

/datum/antagonist/devil/proc/init_bane()
	info.bane.link_bane(owner.current)
	info.bane.init_bane()

	return

/datum/antagonist/devil/give_objectives()
	add_objective(/datum/objective/devil/ascend)
	add_objective(/datum/objective/devil/sintouch)
	add_objective(/datum/objective/devil/sacrifice)

/datum/antagonist/devil/add_owner_to_gamemode()
	LAZYADD(SSticker.mode.devils, owner)

/datum/antagonist/devil/remove_owner_from_gamemode()
	LAZYREMOVE(SSticker.mode.devils, owner)

/datum/antagonist/devil/farewell()
	to_chat(owner.current, span_userdanger("Your infernal link has been severed! You are no longer a devil!"))

/datum/antagonist/devil/apply_innate_effects(mob/living/mob_override)
	. = ..()
	owner.current.AddElement(/datum/element/devil_regeneration)
	owner.current.AddElement(/datum/element/devil_banishment) // handles devil banishes

	init_new_rank()
	init_bane()

	update_hud()
	give_obligation_spells()
	info.banish.link_banish(owner.current)

	LAZYADD(owner.current.faction, "hell")
	ADD_TRAIT(owner.current, TRAIT_NO_DEATH, UNIQUE_TRAIT_SOURCE(src))

/datum/antagonist/devil/remove_innate_effects()
	. = ..()
	owner.current.RemoveElement(/datum/element/devil_regeneration)
	owner.current.RemoveElement(/datum/element/devil_banishment)

	remove_spells()
	remove_hud()

	info.bane.remove_bane()

	LAZYREMOVE(owner.current.faction, "hell")
	REMOVE_TRAIT(owner.current, TRAIT_NO_DEATH, UNIQUE_TRAIT_SOURCE(src))

/datum/antagonist/devil/proc/printdevilinfo()
	var/list/parts = list()
	LAZYADD(parts, "The devil's true name is: [info.truename]")
	LAZYADD(parts, "The devil's bans were:")
	LAZYADD(parts, info.bane.law)
	LAZYADD(parts, (GLOB.lawlorify[LAW][info.ban]))
	LAZYADD(parts, (GLOB.lawlorify[LAW][info.obligation]))
	LAZYADD(parts, info.banish.law)
	return parts.Join("<br>")

/datum/antagonist/devil/roundend_report()
	var/list/parts = list()
	LAZYADD(parts, printplayer(owner))
	LAZYADD(parts, printdevilinfo())
	LAZYADD(parts, printobjectives(objectives))
	return parts.Join("<br>")

/datum/outfit/devil_lawyer
	name = "Devil Lawyer"
	uniform = /obj/item/clothing/under/lawyer/black
	shoes = /obj/item/clothing/shoes/laceup
	back = /obj/item/storage/backpack
	l_hand = /obj/item/storage/briefcase
	l_pocket = /obj/item/pen
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id

/datum/outfit/devil_lawyer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = H.wear_id
	if(!istype(W) || W.assignment) // either doesn't have a card, or the card is already written to
		return

	var/name_to_use = H.real_name
	var/datum/antagonist/devil/devilinfo = H.mind?.has_antag_datum(/datum/antagonist/devil)

	if(devilinfo)
		// Having hell create an ID for you causes its risks
		name_to_use = devilinfo.info.truename

	W.name = "[name_to_use]'s ID Card (Lawyer)"
	W.registered_name = name_to_use
	W.assignment = "Lawyer"
	W.rank = W.assignment
	W.age = H.age
	W.sex = capitalize(H.gender)
	W.access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	W.photo = get_id_photo(H)
