/datum/antagonist/devil
	name = "Devil"
	roundend_category = "devils"
	job_rank = ROLE_DEVIL
	special_role = ROLE_DEVIL
	antag_hud_type = ANTAG_HUD_DEVIL
	var/obligation
	var/ban
	var/bane
	var/banish
	var/truename
	var/list/datum/mind/soulsOwned = new
	var/datum/devil_rank/rank
	var/regen_threshold = BASIC_DEVIL_REGEN_THRESHOLD
	var/regen_amount = BASIC_DEVIL_REGEN_AMOUNT
	var/static/list/devil_spells = typecacheof(list(
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/conjure_item/violin,
		/obj/effect/proc_holder/spell/summon_dancefloor,
		/obj/effect/proc_holder/spell/sintouch
		))

/datum/antagonist/devil/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!ishuman(owner.current))
		return FALSE

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
	if(!iscarbon(owner.current))
		return

	if(!update_rank())
		return

	rank.link(owner.current)
	rank.apply_rank()
	update_spells()

	return

/datum/antagonist/devil/proc/update_rank()
	. = FALSE
	switch(SOULVALUE)
		if(BLOOD_THRESHOLD)
			rank = new BLOOD_LIZARD_RANK()
			. = TRUE
		if(TRUE_THRESHOLD)
			rank = new TRUE_DEVIL_RANK()
			. = TRUE

	return .

/datum/antagonist/devil/proc/remove_spells()
	for(var/obj/effect/proc_holder/spell/spell as anything in owner.spell_list)
		if(!is_type_in_typecache(spell, devil_spells))
			continue

		owner.RemoveSpell(spell)

/datum/antagonist/devil/proc/update_spells()
	remove_spells()
	give_obligation_spells()
	rank.apply_spells()

/datum/antagonist/devil/proc/give_obligation_spells()
	switch(obligation)
		if(OBLIGATION_FIDDLE)
			owner.AddSpell(new /obj/effect/proc_holder/spell/conjure_item/violin(null))
		if(OBLIGATION_DANCEOFF)
			owner.AddSpell(new /obj/effect/proc_holder/spell/summon_dancefloor(null))

/datum/antagonist/devil/proc/update_hud()
	var/mob/living/living = owner.current
	if(living.hud_used?.devilsouldisplay)
		living.hud_used.devilsouldisplay.update_counter(SOULVALUE)

/datum/antagonist/devil/proc/remove_hud()
	var/mob/living = owner.current
	var/datum/hud/devil/devil = living.hud_used

	if(!devil)
		return

	LAZYREMOVE(devil.infodisplay, devil.devilsouldisplay)

/datum/antagonist/devil/greet()
	var/list/messages = list()
	LAZYADD(messages, span_warning("<b>You remember your link to the infernal.  You are [truename], an agent of hell, a devil.  And you were sent to the plane of creation for a reason.  A greater purpose.  Convince the crew to sin, and embroiden Hell's grasp.</b>"))
	LAZYADD(messages, span_warning("<b>However, your infernal form is not without weaknesses.</b>"))
	LAZYADD(messages, "You may not use violence to coerce someone into selling their soul.")
	LAZYADD(messages, "You may not directly and knowingly physically harm a devil, other than yourself.")
	LAZYADD(messages, GLOB.lawlorify[LAW][bane])
	LAZYADD(messages, GLOB.lawlorify[LAW][ban])
	LAZYADD(messages, GLOB.lawlorify[LAW][obligation])
	LAZYADD(messages, GLOB.lawlorify[LAW][banish])
	LAZYADD(messages, "[span_warning("Remember, the crew can research your weaknesses if they find out your devil name.")]<br>")
	return messages

/datum/antagonist/devil/on_gain()
	. = ..()
	if(!.)
		return FALSE
		
	truename = randomDevilName()
	ban = randomdevilban()
	bane = randomdevilbane()
	obligation = randomdevilobligation()
	banish = randomdevilbanish()

	GLOB.allDevils[lowertext(truename)] = src
	rank = new BASIC_DEVIL_RANK()

	var/mob/living/carbon/human/human = owner.current
	human.store_memory("Your devilic true name is [truename]<br>[GLOB.lawlorify[LAW][ban]]<br>You may not use violence to coerce someone into selling their soul.<br>You may not directly and knowingly physically harm a devil, other than yourself.<br>[GLOB.lawlorify[LAW][bane]]<br>[GLOB.lawlorify[LAW][obligation]]<br>[GLOB.lawlorify[LAW][banish]]<br>")

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
	owner.current.AddElement(/datum/element/devil_bane)
	owner.current.AddElement(/datum/element/devil_regeneration)
	owner.current.AddElement(/datum/element/devil_banishment)

	rank.link(owner.current)
	rank.apply_rank()

	update_hud()
	update_spells()

/datum/antagonist/devil/remove_innate_effects()
	. = ..()
	remove_spells()
	owner.current.RemoveElement(/datum/element/devil_bane)
	owner.current.RemoveElement(/datum/element/devil_regeneration)
	owner.current.RemoveElement(/datum/element/devil_banishment)
	remove_hud()

/datum/antagonist/devil/proc/printdevilinfo()
	var/list/parts = list()
	LAZYADD(parts, "The devil's true name is: [truename]")
	LAZYADD(parts, "The devil's bans were:")
	LAZYADD(parts, (GLOB.lawlorify[LAW][bane]))
	LAZYADD(parts, (GLOB.lawlorify[LAW][ban]))
	LAZYADD(parts, (GLOB.lawlorify[LAW][obligation]))
	LAZYADD(parts, (GLOB.lawlorify[LAW][banish]))
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
		name_to_use = devilinfo.truename

	W.name = "[name_to_use]'s ID Card (Lawyer)"
	W.registered_name = name_to_use
	W.assignment = "Lawyer"
	W.rank = W.assignment
	W.age = H.age
	W.sex = capitalize(H.gender)
	W.access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	W.photo = get_id_photo(H)

/datum/devil_rank
	/// Antagonist datum of our owner
	var/datum/antagonist/devil/devil
	/// Rank owner
	var/mob/living/carbon/owner
	/// Which spells we'll give to rank owner when rank is applied
	var/list/rank_spells

/datum/devil_rank/proc/link(mob/living/carbon/carbon)
	owner = carbon
	devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

/datum/devil_rank/proc/apply_rank(mob/living/carbon/carbon)
	return

/datum/devil_rank/proc/apply_spells()
	for(var/obj/effect/proc_holder/spell/spell as anything in rank_spells)
		owner.mind?.AddSpell(new spell)

/datum/devil_rank/basic_devil
	rank_spells = list() // TODO: new single spell which allows you to do rituals

/datum/devil_rank/blood_lizard
	rank_spells = list(
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/infernal_jaunt
	)

/datum/devil_rank/blood_lizard/apply_rank()
	if(!ishuman(owner))
		owner.color = "#501010"
		return TRUE

	var/mob/living/carbon/human/human = owner
	var/list/language_temp = LAZYLEN(human.languages) ? human.languages.Copy() : null

	human.set_species(/datum/species/unathi)
	if(language_temp)
		human.languages = language_temp

	human.underwear = "Nude"
	human.undershirt = "Nude"
	human.socks = "Nude"
	human.change_skin_color(80, 16, 16) //A deep red
	human.regenerate_icons()

	return TRUE

/datum/devil_rank/true_devil
	rank_spells = list(
		/obj/effect/proc_holder/spell/conjure_item/pitchfork/greater,
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/infernal_jaunt,
		/obj/effect/proc_holder/spell/sintouch
	)

/datum/devil_rank/true_devil/apply_rank()
	to_chat(owner, span_warning("You feel as though your current form is about to shed.  You will soon turn into a true devil."))
	var/mob/living/carbon/true_devil/A = new /mob/living/carbon/true_devil(owner.loc)

	A.faction |= "hell"
	owner.forceMove(A)
	A.oldform = owner
	owner.mind?.transfer_to(A)
	A.set_name()

	return TRUE

/datum/fakeDevil
	var/truename
	var/bane
	var/obligation
	var/ban
	var/banish

/datum/fakeDevil/New(name = randomDevilName())
	truename = name
	bane = randomdevilbane()
	obligation = randomdevilobligation()
	ban = randomdevilban()
	banish = randomdevilbanish()
