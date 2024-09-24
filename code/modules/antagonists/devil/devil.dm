/datum/antagonist/devil
	name = "Devil"
	roundend_category = "devils"
	antagpanel_category = "Devil"
	job_rank = ROLE_DEVIL
	antag_hud_name = "devil"
	show_to_ghosts = TRUE
	var/obligation
	var/ban
	var/bane
	var/banish
	var/truename
	var/list/datum/mind/soulsOwned = new
	var/form = BASIC_DEVIL
	var/static/list/devil_spells = typecacheof(list(
		/datum/action/cooldown/spell/pointed/projectile/fireball/hellish,
		/datum/action/cooldown/spell/conjure_item/summon_pitchfork,
		/datum/action/cooldown/spell/conjure_item/summon_pitchfork/greater,
		/datum/action/cooldown/spell/conjure_item/summon_pitchfork/ascended,
		/datum/action/cooldown/spell/jaunt/infernal_jaunt,
		/datum/action/cooldown/spell/aoe/sintouch,
		/datum/action/cooldown/spell/aoe/sintouch/ascended,
		/datum/action/cooldown/spell/pointed/summon_contract,
		/datum/action/cooldown/spell/conjure_item/violin,
		/datum/action/cooldown/spell/summon_dancefloor))

/datum/antagonist/devil/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!ishuman(owner.current))
        return FALSE

/proc/devilInfo(name)
	if(GLOB.allDevils[lowertext(name)])
		return GLOB.allDevils[lowertext(name)]

	else
		var/datum/fakeDevil/devil = new /datum/fakeDevil(name)
		GLOB.allDevils[lowertext(name)] = devil

		return devil

/proc/randomDevilName()
	var/name = ""
	if(prob(65))
		if(prob(35))
			name = pick(GLOB.devil_pre_title)
		name += pick(GLOB.devil_title)
	var/probability = 100
	name += pick(GLOB.devil_syllable)
    
	while(prob(probability))
		name += pick(GLOB.devil_syllable)
		probability -= 20

	if(prob(40))
		name += pick(GLOB.devil_suffix)

	return name

/proc/randomdevilobligation()
	return pick(OBLIGATION_FOOD, OBLIGATION_FIDDLE, OBLIGATION_DANCEOFF, OBLIGATION_GREET, OBLIGATION_PRESENCEKNOWN, OBLIGATION_SAYNAME, OBLIGATION_ANNOUNCEKILL, OBLIGATION_ANSWERTONAME)

/proc/randomdevilban()
	return pick(BAN_HURTWOMAN, BAN_CHAPEL, BAN_HURTPRIEST, BAN_AVOIDWATER, BAN_STRIKEUNCONSCIOUS, BAN_HURTLIZARD, BAN_HURTANIMAL)

/proc/randomdevilbane()
	return pick(BANE_SALT, BANE_LIGHT, BANE_IRON, BANE_WHITECLOTHES, BANE_SILVER, BANE_HARVEST, BANE_TOOLBOX)

/proc/randomdevilbanish()
	return pick(BANISH_WATER, BANISH_COFFIN, BANISH_FORMALDYHIDE, BANISH_RUNES, BANISH_CANDLES, BANISH_DESTRUCTION, BANISH_FUNERAL_GARB)

/datum/antagonist/devil/proc/add_soul(datum/mind/soul)
	if(soulsOwned.Find(soul))
		return

	soulsOwned += soul
	owner.current.set_nutrition(NUTRITION_LEVEL_FULL)
	to_chat(owner.current, span_warning("You feel satiated as you received a new soul."))
	update_hud()

    if(!SOULVALUE)
        to_chat(owner.current, span_warning("Your hellish powers have been restored."))
		update_spells()
        return

	switch(SOULVALUE)
		if(BLOOD_THRESHOLD)
			increase_blood_lizard()
		if(TRUE_THRESHOLD)
			increase_true_devil()
		if(ARCH_THRESHOLD)
			increase_arch_devil()

/datum/antagonist/devil/proc/remove_soul(datum/mind/soul)
	if(soulsOwned.Remove(soul))
		check_regression()
		to_chat(owner.current, span_warning("You feel as though a soul has slipped from your grasp."))
		update_hud()

/datum/antagonist/devil/proc/increase_blood_lizard()
	to_chat(owner.current, span_warning("You feel as though your humanoid form is about to shed.  You will soon turn into a blood lizard."))

	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.set_species(/datum/species/lizard, TRUE)
		H.underwear = "Nude"
		H.undershirt = "Nude"
		H.socks = "Nude"
		H.dna.features["mcolor"] = "#551111" //A deep red
		H.regenerate_icons()
	else //Did the devil get hit by a staff of transmutation?
		owner.current.color = "#501010"

	give_appropriate_spells()
	form = BLOOD_LIZARD

/datum/antagonist/devil/proc/increase_true_devil()
	to_chat(owner.current, span_warning("You feel as though your current form is about to shed.  You will soon turn into a true devil."))
	var/mob/living/carbon/true_devil/A = new /mob/living/carbon/true_devil(owner.current.loc)
	A.faction |= "hell"
	owner.current.forceMove(A)
	A.oldform = owner.current
	owner.transfer_to(A)
	A.set_name()
	give_appropriate_spells()
	form = TRUE_DEVIL
	update_hud()

/datum/antagonist/devil/proc/remove_spells()
	for(var/datum/action/cooldown/spell/spells in owner.current.actions)
		if(is_type_in_typecache(spells, devil_spells))
			spells.Remove(owner.current)

/datum/antagonist/devil/proc/update_spells()
	remove_spells()
    switch(form)
        if(BASIC_DEVIL)
	        owner.AddSpell(new /obj/effect/proc_holder/spell/fireball/hellish(null))
	        owner.AddSpell(new /obj/effect/proc_holder/spell/conjure_item/pitchfork(null))
		    if(obligation == OBLIGATION_FIDDLE)
			    owner.AddSpell(new /obj/effect/proc_holder/spell/conjure_item/violin(null))
		    if(obligation == OBLIGATION_DANCEOFF)
			    owner.AddSpell(new /obj/effect/proc_holder/spell/summon_dancefloor(null))
        if(BLOOD_LIZARD)
            owner.AddSpell(new /obj/effect/proc_holder/spell/conjure_item/pitchfork(null))
	        owner.AddSpell(new /obj/effect/proc_holder/spell/fireball/hellish(null))
	        owner.AddSpell(new /obj/effect/proc_holder/spell/infernal_jaunt(null))
        if(TRUE_DEVIL)
            owner.AddSpell(new /obj/effect/proc_holder/spell/conjure_item/pitchfork/greater(null))
	        owner.AddSpell(new /obj/effect/proc_holder/spell/fireball/hellish(null))
	        owner.AddSpell(new /obj/effect/proc_holder/spell/infernal_jaunt(null))
	        owner.AddSpell(new /obj/effect/proc_holder/spell/sintouch(null))

/datum/antagonist/devil/proc/check_banishment(mob/living/body)
	switch(banish)
		if(BANISH_WATER)
			if(!iscarbon(body))
                return FALSE

			var/mob/living/carbon/H = body
			return H.reagents.has_reagent(/datum/reagent/water/holywater)

		if(BANISH_COFFIN)
			return (body && istype(body.loc, /obj/structure/closet/crate/coffin))

		if(BANISH_FORMALDYHIDE)
			if(!iscarbon(body))
                return FALSE

			var/mob/living/carbon/H = body
			return H.reagents.has_reagent(/datum/reagent/toxin/formaldehyde)

		if(BANISH_RUNES)
			if(!body)
                return FALSE

			for(var/obj/effect/decal/cleanable/crayon/R in range(0,body))
				return R.name == "rune"

		if(BANISH_CANDLES)
			if(!body)
                return FALSE
            
			var/count = 0
			for(var/obj/item/candle/C in range(1,body))
				count += C.lit

			return count >= 4

		if(BANISH_DESTRUCTION)
			return body

		if(BANISH_FUNERAL_GARB)
			if(!ishuman(body))
                return FALSE

			var/mob/living/carbon/human/H = body
			if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/rank/civilian/chaplain/burial))
				return TRUE

			for(var/obj/item/clothing/under/rank/civilian/chaplain/burial/B in range(0,body))
				if(B.loc == get_turf(B)) //Make sure it's not in someone's inventory or something.
					return TRUE

			return FALSE

/datum/antagonist/devil/proc/update_hud()
	if(!iscarbon(owner.current))
        return

	var/mob/living/C = owner.current
	if(C.hud_used && C.hud_used.devilsouldisplay)
	    C.hud_used.devilsouldisplay.update_counter(SOULVALUE)

/datum/antagonist/devil/greet()
	to_chat(owner.current, span_warning("<b>You remember your link to the infernal.  You are [truename], an agent of hell, a devil.  And you were sent to the plane of creation for a reason.  A greater purpose.  Convince the crew to sin, and embroiden Hell's grasp.</b>"))
	to_chat(owner.current, span_warning("<b>However, your infernal form is not without weaknesses.</b>"))
	to_chat(owner.current, "You may not use violence to coerce someone into selling their soul.")
	to_chat(owner.current, "You may not directly and knowingly physically harm a devil, other than yourself.")
	to_chat(owner.current, GLOB.lawlorify[LAW][bane])
	to_chat(owner.current, GLOB.lawlorify[LAW][ban])
	to_chat(owner.current, GLOB.lawlorify[LAW][obligation])
	to_chat(owner.current, GLOB.lawlorify[LAW][banish])
	to_chat(owner.current, "[span_warning("Remember, the crew can research your weaknesses if they find out your devil name.")]<br>")
	.=..()

/datum/antagonist/devil/on_gain()
	truename = randomDevilName()
	ban = randomdevilban()
	bane = randomdevilbane()
	obligation = randomdevilobligation()
	banish = randomdevilbanish()
	GLOB.allDevils[lowertext(truename)] = src
    var/mob/living/carbon/human/human = owner.current
	human.store_memory("Your devilic true name is [truename]<br>[GLOB.lawlorify[LAW][ban]]<br>You may not use violence to coerce someone into selling their soul.<br>You may not directly and knowingly physically harm a devil, other than yourself.<br>[GLOB.lawlorify[LAW][bane]]<br>[GLOB.lawlorify[LAW][obligation]]<br>[GLOB.lawlorify[LAW][banish]]<br>")
	handle_clown_mutation(owner.current, "Your infernal nature has allowed you to overcome your clownishness.")
	return ..()

/datum/antagonist/devil/on_removal()
	to_chat(owner.current, span_userdanger("Your infernal link has been severed! You are no longer a devil!"))
	. = ..()

/datum/antagonist/devil/apply_innate_effects(mob/living/mob_override)
	give_appropriate_spells()
	owner.current.grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_DEVIL)
	update_hud()
	.=..()

/datum/antagonist/devil/remove_innate_effects(mob/living/mob_override)
	for(var/datum/action/cooldown/spell/spells in owner.current.actions)
		if(is_type_in_typecache(spells, devil_spells))
			spells.Remove(owner.current)
	owner.current.remove_all_languages(LANGUAGE_DEVIL)
	.=..()

/datum/antagonist/devil/proc/printdevilinfo()
	var/list/parts = list()
	parts += "The devil's true name is: [truename]"
	parts += "The devil's bans were:"
	parts += "[GLOB.TAB][GLOB.lawlorify[LORE][ban]]"
	parts += "[GLOB.TAB][GLOB.lawlorify[LORE][bane]]"
	parts += "[GLOB.TAB][GLOB.lawlorify[LORE][obligation]]"
	parts += "[GLOB.TAB][GLOB.lawlorify[LORE][banish]]"
	return parts.Join("<br>")

/datum/antagonist/devil/roundend_report()
	var/list/parts = list()
	parts += printplayer(owner)
	parts += printdevilinfo()
	parts += printobjectives(objectives)
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
	if(H.mind && H.mind.devilinfo)
		// Having hell create an ID for you causes its risks
		name_to_use = H.mind.devilinfo.truename

	W.name = "[name_to_use]'s ID Card (Lawyer)"
	W.registered_name = name_to_use
	W.assignment = "Lawyer"
	W.rank = W.assignment
	W.age = H.age
	W.sex = capitalize(H.gender)
	W.access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	W.photo = get_id_photo(H)
