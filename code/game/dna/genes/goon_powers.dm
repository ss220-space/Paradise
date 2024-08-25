#define EAT_MOB_DELAY 300 // 30s

// WAS: /datum/bioEffect/alcres
/datum/dna/gene/basic/sober
	name = "Sober"
	activation_messages = list("You feel unusually sober.")
	deactivation_messages = list("You feel like you could use a stiff drink.")
	traits_to_add = list(TRAIT_SOBER)


/datum/dna/gene/basic/sober/New()
	..()
	block = GLOB.soberblock


//WAS: /datum/bioEffect/psychic_resist
/datum/dna/gene/basic/psychic_resist
	name = "Psy-Resist"
	desc = "Boosts efficiency in sectors of the brain commonly associated with meta-mental energies."
	activation_messages = list("Your mind feels closed.")
	deactivation_messages = list("You feel oddly exposed.")
	traits_to_add = list(TRAIT_PSY_RESIST)


/datum/dna/gene/basic/psychic_resist/New()
	..()
	block = GLOB.psyresistblock


/////////////////////////
// Stealth Enhancers
/////////////////////////

/datum/dna/gene/basic/stealth
	instability = GENE_INSTABILITY_MODERATE


/datum/dna/gene/basic/stealth/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.alpha = initial(mutant.alpha)


// WAS: /datum/bioEffect/darkcloak
/datum/dna/gene/basic/stealth/darkcloak
	name = "Cloak of Darkness"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	activation_messages = list("You begin to fade into the shadows.")
	deactivation_messages = list("You become fully visible.")
	activation_prob = 25


/datum/dna/gene/basic/stealth/darkcloak/New()
	..()
	block = GLOB.shadowblock


/datum/dna/gene/basic/stealth/darkcloak/OnMobLife(mob/living/mutant)
	var/turf/simulated/T = get_turf(mutant)
	if(!istype(T))
		return
	var/light_available = T.get_lumcount() * 10
	if(light_available <= 2)
		mutant.alpha = round(mutant.alpha * 0.8)
	else
		mutant.alpha = initial(mutant.alpha)


//WAS: /datum/bioEffect/chameleon
/datum/dna/gene/basic/stealth/chameleon
	name = "Chameleon"
	desc = "The subject becomes able to subtly alter light patterns to become invisible, as long as they remain still."
	activation_messages = list("You feel one with your surroundings.")
	deactivation_messages = list("You feel oddly visible.")
	activation_prob = 25


/datum/dna/gene/basic/stealth/chameleon/New()
	..()
	block = GLOB.chameleonblock


/datum/dna/gene/basic/stealth/chameleon/OnMobLife(mob/living/mutant)
	if((world.time - mutant.last_movement) >= 30 && (mutant.mobility_flags & MOBILITY_MOVE) && !HAS_TRAIT(mutant, TRAIT_RESTRAINED))
		mutant.alpha -= 25
	else
		mutant.alpha = round(255 * 0.80)


/////////////////////////////////////////////////////////////////////////////////////////

/datum/dna/gene/basic/grant_spell
	var/obj/effect/proc_holder/spell/spelltype


/datum/dna/gene/basic/grant_spell/activate(mob/living/mutant, flags)
	. = ..()
	mutant.AddSpell(new spelltype(null))


/datum/dna/gene/basic/grant_spell/deactivate(mob/living/mutant, flags)
	. = ..()
	for(var/obj/effect/proc_holder/spell/spell as anything in mutant.mob_spell_list)
		if(istype(spell, spelltype))
			mutant.RemoveSpell(spell)


/datum/dna/gene/basic/grant_verb
	var/verbtype


/datum/dna/gene/basic/grant_verb/activate(mob/living/mutant, flags)
	. = ..()
	add_verb(mutant, verbtype)


/datum/dna/gene/basic/grant_verb/deactivate(mob/living/mutant, flags)
	. = ..()
	remove_verb(mutant, verbtype)


// WAS: /datum/bioEffect/cryokinesis
/datum/dna/gene/basic/grant_spell/cryo
	name = "Cryokinesis"
	desc = "Allows the subject to lower the body temperature of others."
	activation_messages = list("You notice a strange cold tingle in your fingertips.")
	deactivation_messages = list("Your fingers feel warmer.")
	instability = GENE_INSTABILITY_MODERATE
	spelltype = /obj/effect/proc_holder/spell/cryokinesis


/datum/dna/gene/basic/grant_spell/cryo/New()
	..()
	block = GLOB.cryoblock


/obj/effect/proc_holder/spell/cryokinesis
	name = "Cryokinesis"
	desc = "Drops the bodytemperature of another person."
	base_cooldown = 120 SECONDS
	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	selection_activated_message		= "<span class='notice'>Your mind grow cold. Click on a target to cast the spell.</span>"
	selection_deactivated_message	= "<span class='notice'>Your mind returns to normal.</span>"

	var/list/compatible_mobs = list(/mob/living/carbon/human)

	action_icon_state = "genetic_cryo"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/cryokinesis/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living/carbon
	T.click_radius = 0
	T.try_auto_target = FALSE // Give the clueless geneticists a way out and to have them not target themselves
	T.selection_type = SPELL_SELECTION_RANGE
	T.include_user = TRUE
	return T


/obj/effect/proc_holder/spell/cryokinesis/cast(list/targets, mob/user = usr)

	var/mob/living/carbon/C = targets[1]

	if(HAS_TRAIT(C, TRAIT_RESIST_COLD))
		C.visible_message("<span class='warning'>A cloud of fine ice crystals engulfs [C.name], but disappears almost instantly!</span>")
		return
	var/handle_suit = FALSE
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.head, /obj/item/clothing/head/helmet/space))
			if(istype(H.wear_suit, /obj/item/clothing/suit/space))
				handle_suit = TRUE
				if(H.internal)
					H.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals, engulfing [H]!</span>",
										"<span class='notice'>[user] sprays a cloud of fine ice crystals over your [H.head]'s visor.</span>")
				else
					H.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals engulfing, [H]!</span>",
										"<span class='warning'>[user] sprays a cloud of fine ice crystals cover your [H.head]'s visor and make it into your air vents!.</span>")

					H.adjust_bodytemperature(-100)
				add_attack_logs(user, C, "Cryokinesis")
	if(!handle_suit)
		C.adjust_bodytemperature(-200)
		C.ExtinguishMob()

		C.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals, engulfing [C]!</span>")
		add_attack_logs(user, C, "Cryokinesis- NO SUIT/INTERNALS")


/obj/effect/self_deleting
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	icon = null
	desc = ""
	//layer = 15


/obj/effect/self_deleting/New(atom/location, icon/I, duration = 20, oname = "something")
	. = ..()
	name = oname
	loc=location
	icon = I
	QDEL_IN(src, duration)

///////////////////////////////////////////////////////////////////////////////////////////


// WAS: /datum/bioEffect/mattereater
/datum/dna/gene/basic/grant_spell/mattereater
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	activation_messages = list("You feel hungry.")
	deactivation_messages = list("You don't feel quite so hungry anymore.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /obj/effect/proc_holder/spell/eat


/datum/dna/gene/basic/grant_spell/mattereater/New()
	..()
	block = GLOB.eatblock


/obj/effect/proc_holder/spell/eat
	name = "Eat"
	desc = "Eat just about anything!"

	base_cooldown = 30 SECONDS

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_eat"


/obj/effect/proc_holder/spell/eat/create_new_targeting()
	return new /datum/spell_targeting/matter_eater


/obj/effect/proc_holder/spell/eat/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	. = ..()
	if(!.)
		return
	var/can_eat = TRUE
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if((C.head && (C.head.flags_cover & HEADCOVERSMOUTH)) || (C.wear_mask && (C.wear_mask.flags_cover & MASKCOVERSMOUTH) && !C.wear_mask.up))
			if(show_message)
				to_chat(C, "<span class='warning'>Your mouth is covered, preventing you from eating!</span>")
			can_eat = FALSE
	return can_eat


/obj/effect/proc_holder/spell/eat/proc/doHeal(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/should_update_health = FALSE
		var/update_damage_icon = NONE
		for(var/name in H.bodyparts_by_name)
			var/obj/item/organ/external/affecting = null
			if(!H.bodyparts_by_name[name])
				continue
			affecting = H.bodyparts_by_name[name]
			if(!isexternalorgan(affecting))
				continue
			var/brute_was = affecting.brute_dam
			update_damage_icon |= affecting.heal_damage(4, updating_health = FALSE)
			if(affecting.brute_dam != brute_was)
				should_update_health = TRUE
		if(should_update_health)
			H.updatehealth("[name] heal")
		if(update_damage_icon)
			H.UpdateDamageIcon()


/obj/effect/proc_holder/spell/eat/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/atom/movable/the_item = targets[1]
	if(ishuman(the_item))
		var/mob/living/carbon/human/H = the_item
		var/obj/item/organ/external/limb = H.get_organ(user.zone_selected)
		if(!istype(limb))
			to_chat(user, "<span class='warning'>You can't eat this part of them!</span>")
			revert_cast()
			return FALSE

		if(istype(limb,/obj/item/organ/external/head))
			// Bullshit, but prevents being unable to clone someone.
			to_chat(user, "<span class='warning'>You try to put \the [limb] in your mouth, but [the_item.p_their()] ears tickle your throat!</span>")
			revert_cast()
			return FALSE

		if(istype(limb,/obj/item/organ/external/chest))
			// Bullshit, but prevents being able to instagib someone.
			to_chat(user, "<span class='warning'>You try to put [the_item.p_their()] [limb] in your mouth, but it's too big to fit!</span>")
			revert_cast()
			return FALSE

		user.visible_message("<span class='danger'>[user] begins stuffing [the_item]'s [limb.name] into [user.p_their()] gaping maw!</span>")
		var/oldloc = H.loc
		if(!do_after(user, EAT_MOB_DELAY, H, NONE))
			to_chat(user, "<span class='danger'>You were interrupted before you could eat [the_item]!</span>")
		else
			if(!limb || !H)
				return
			if(H.loc != oldloc)
				to_chat(user, "<span class='danger'>\The [limb] moved away from your mouth!</span>")
				return
			user.visible_message("<span class='danger'>[user] [pick("chomps","bites")] off [the_item]'s [limb]!</span>")
			playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
			limb.droplimb(0, DROPLIMB_SHARP)
			doHeal(user)
	else
		user.visible_message("<span class='danger'>[user] eats \the [the_item].</span>")
		playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
		qdel(the_item)
		doHeal(user)


////////////////////////////////////////////////////////////////////////

//WAS: /datum/bioEffect/jumpy
/datum/dna/gene/basic/grant_spell/jumpy
	name = "Jumpy"
	desc = "Allows the subject to leap great distances."
	//cooldown = 30
	activation_messages = list("Your leg muscles feel taut and strong.")
	deactivation_messages = list("Your leg muscles shrink back to normal.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /obj/effect/proc_holder/spell/leap


/datum/dna/gene/basic/grant_spell/jumpy/New()
	..()
	block = GLOB.jumpblock


/obj/effect/proc_holder/spell/leap
	name = "Jump"
	desc = "Leap great distances!"

	base_cooldown = 6 SECONDS

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_jump"


/obj/effect/proc_holder/spell/leap/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/leap/cast(list/targets, mob/living/user = usr)
	var/failure = FALSE
	if(ismob(user.loc) || user.incapacitated(INC_IGNORE_RESTRAINED) || user.buckled)
		to_chat(user, "<span class='warning'>You can't jump right now!</span>")
		return
	var/turf/turf_to_check = get_turf(user)
	if(user.can_z_move(DOWN, turf_to_check))
		to_chat(user, span_warning("You need a ground to jump from!"))
		return

	if(isturf(user.loc))
		if(HAS_TRAIT(user, TRAIT_RESTRAINED))//Why being pulled while cuffed prevents you from moving
			var/mob/living/puller = user.pulledby
			if(puller && !puller.stat && (puller.mobility_flags & MOBILITY_MOVE) && user.Adjacent(puller))
				failure = TRUE
			else if(puller)
				puller.stop_pulling()

		user.visible_message("<span class='danger'>[user.name]</b> takes a huge leap!</span>")
		playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
		if(failure)
			user.Weaken(10 SECONDS)
			user.visible_message("<span class='warning'>[user] attempts to leap away but is slammed back down to the ground!</span>",
								"<span class='warning'>You attempt to leap away but are suddenly slammed back down to the ground!</span>",
								"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
			return FALSE
		var/prevLayer = user.layer
		user.layer = LOW_LANDMARK_LAYER

		ADD_TRAIT(user, TRAIT_MOVE_FLYING, SPELL_LEAP_TRAIT)

		for(var/i=0, i<10, i++)
			step(user, user.dir)
			if(i < 5) user.pixel_y += 8
			else user.pixel_y -= 8
			sleep(1)
		REMOVE_TRAIT(user, TRAIT_MOVE_FLYING, SPELL_LEAP_TRAIT)

		if(!(user.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) && !user.currently_z_moving) // in case he could fly after
			var/turf/pitfall = get_turf(user)
			pitfall?.zFall(user)

		else if(HAS_TRAIT(user, TRAIT_FAT) && prob(66))
			user.visible_message("<span class='danger'>[user.name]</b> crashes due to [user.p_their()] heavy weight!</span>")
			//playsound(user.loc, 'zhit.wav', 50, 1)
			user.AdjustWeakened(20 SECONDS)

		user.layer = prevLayer

	if(isobj(user.loc))
		var/obj/container = user.loc
		to_chat(user, "<span class='warning'>You leap and slam your head against the inside of [container]! Ouch!</span>")
		user.AdjustParalysis(6 SECONDS)
		user.AdjustWeakened(10 SECONDS)
		container.visible_message("<span class='danger'>[user.loc]</b> emits a loud thump and rattles a bit.</span>")
		playsound(user.loc, 'sound/effects/bang.ogg', 50, 1)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0


////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/polymorphism

/datum/dna/gene/basic/grant_spell/polymorph
	name = "Polymorphism"
	desc = "Enables the subject to reconfigure their appearance to mimic that of others."

	spelltype = /obj/effect/proc_holder/spell/polymorph
	//cooldown = 1800
	activation_messages = list("You don't feel entirely like yourself somehow.")
	deactivation_messages = list("You feel secure in your identity.")
	instability = GENE_INSTABILITY_MODERATE


/datum/dna/gene/basic/grant_spell/polymorph/New()
	..()
	block = GLOB.polymorphblock


/obj/effect/proc_holder/spell/polymorph
	name = "Polymorph"
	desc = "Mimic the appearance of others!"
	base_cooldown = 3 MINUTES

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	selection_activated_message		= "<span class='notice'>You body becomes unstable. Click on a target to cast transform into them.</span>"
	selection_deactivated_message	= "<span class='notice'>Your body calms down again.</span>"

	action_icon_state = "genetic_poly"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/polymorph/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.try_auto_target = FALSE
	T.click_radius = -1
	T.range = 1
	T.selection_type = SPELL_SELECTION_RANGE
	return T


/obj/effect/proc_holder/spell/polymorph/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	user.visible_message("<span class='warning'>[user]'s body shifts and contorts.</span>")

	spawn(1 SECONDS)
		if(target && user)
			playsound(user.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
			var/mob/living/carbon/human/H = user
			H.UpdateAppearance(target.dna.UI)
			H.real_name = target.real_name
			H.name = target.name

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/empath
/datum/dna/gene/basic/grant_spell/empath
	name = "Empathic Thought"
	desc = "The subject becomes able to read the minds of others for certain information."

	spelltype = /obj/effect/proc_holder/spell/empath
	activation_messages = list("You suddenly notice more about others than you did before.")
	deactivation_messages = list("You no longer feel able to sense intentions.")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_EMPATHY)


/datum/dna/gene/basic/grant_spell/empath/New()
	..()
	block = GLOB.empathblock


/obj/effect/proc_holder/spell/empath
	name = "Read Mind"
	desc = "Read the minds of others for information."
	base_cooldown = 18 SECONDS
	clothes_req = FALSE
	human_req = TRUE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_empath"


/obj/effect/proc_holder/spell/empath/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living/carbon
	T.selection_type = SPELL_SELECTION_RANGE
	return T


/obj/effect/proc_holder/spell/empath/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/M in targets)
		if(!iscarbon(M))
			to_chat(user, "<span class='warning'>You may only use this on other organic beings.</span>")
			return

		if(M.dna?.GetSEState(GLOB.psyresistblock))
			to_chat(user, "<span class='warning'>You can't see into [M.name]'s mind at all!</span>")
			return

		if(M.stat == 2)
			to_chat(user, "<span class='warning'>[M.name] is dead and cannot have [M.p_their()] mind read.</span>")
			return
		if(M.health < 0)
			to_chat(user, "<span class='warning'>[M.name] is dying, and [M.p_their()] thoughts are too scrambled to read.</span>")
			return

		to_chat(user, "<span class='notice'>Mind Reading of <b>[M.name]:</b></span>")

		var/pain_condition = M.health / M.maxHealth
		// lower health means more pain
		var/list/randomthoughts = list("what to have for lunch","the future","the past","money",
		"[M.p_their()] hair","what to do next","[M.p_their()] job","space","amusing things","sad things",
		"annoying things","happy things","something incoherent","something [M.p_they()] did wrong")
		var/thoughts = "thinking about [pick(randomthoughts)]"

		if(M.fire_stacks)
			pain_condition -= 0.5
			thoughts = "preoccupied with the fire"

		if(M.radiation)
			pain_condition -= 0.25

		switch(pain_condition)
			if(0.81 to INFINITY)
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] feels good.</span>")
			if(0.61 to 0.8)
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] is suffering mild pain.</span>")
			if(0.41 to 0.6)
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] is suffering significant pain.</span>")
			if(0.21 to 0.4)
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] is suffering severe pain.</span>")
			else
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] is suffering excruciating pain.</span>")
				thoughts = "haunted by [M.p_their()] own mortality"

		switch(M.a_intent)
			if(INTENT_HELP)
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense benevolent thoughts from [M.name].</span>")
			if(INTENT_DISARM)
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense cautious thoughts from [M.name].</span>")
			if(INTENT_GRAB)
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense hostile thoughts from [M.name].</span>")
			if(INTENT_HARM)
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense cruel thoughts from [M.name].</span>")
				for(var/mob/living/L in view(7,M))
					if(L == M)
						continue
					thoughts = "thinking about punching [L.name]"
					break
			else
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense strange thoughts from [M.name].</span>")

		if(ishuman(M))
			var/numbers[0]
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.initial_account)
				numbers += H.mind.initial_account.account_number
				numbers += H.mind.initial_account.remote_access_pin
			if(numbers.len>0)
				to_chat(user, "<span class='notice'><b>Numbers</b>: You sense the number[numbers.len>1?"s":""] [english_list(numbers)] [numbers.len>1?"are":"is"] important to [M.name].</span>")
		to_chat(user, "<span class='notice'><b>Thoughts</b>: [M.name] is currently [thoughts].</span>")

		if(HAS_TRAIT(M, TRAIT_EMPATHY))
			to_chat(M, "<span class='warning'>You sense [user.name] reading your mind.</span>")
		else if(prob(5) || M.mind?.assigned_role == JOB_TITLE_CHAPLAIN)
			to_chat(M, "<span class='warning'>You sense someone intruding upon your thoughts...</span>")


////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/strong
/datum/dna/gene/basic/strong
	name = "Strong"
	desc = "Enhances the subject's ability to build and retain heavy muscles."
	activation_messages = list("You feel buff!")
	deactivation_messages = list("You feel wimpy and weak.")
	instability = GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_GENE_STRONG)


/datum/dna/gene/basic/strong/New()
	..()
	block = GLOB.strongblock


/datum/dna/gene/basic/strong/can_activate(mob/living/mutant, flags)
	if(!ishuman(mutant) || HAS_TRAIT(mutant, TRAIT_GENE_WEAK))
		return FALSE
	return ..()


/datum/dna/gene/basic/strong/activate(mob/living/carbon/human/mutant, flags)
	. = ..()
	RegisterSignal(mutant, COMSIG_HUMAN_SPECIES_CHANGED, PROC_REF(on_species_change))
	add_strong_modifiers(mutant)


/datum/dna/gene/basic/strong/deactivate(mob/living/carbon/human/mutant, flags)
	. = ..()
	UnregisterSignal(mutant, COMSIG_HUMAN_SPECIES_CHANGED)
	remove_strong_modifiers(mutant)


/datum/dna/gene/basic/strong/proc/on_species_change(mob/living/carbon/human/mutant, datum/species/old_species)
	SIGNAL_HANDLER

	if(old_species.name != mutant.dna.species.name)
		remove_strong_modifiers(mutant, old_species)
		add_strong_modifiers(mutant)


/datum/dna/gene/basic/strong/proc/add_strong_modifiers(mob/living/carbon/human/mutant)
	mutant.physiology.tail_strength_mod *= 1.25
	switch(mutant.dna.species.name)
		if(SPECIES_VULPKANIN, SPECIES_DRASK, SPECIES_UNATHI)
			mutant.physiology.grab_resist_mod *= 1.1
			mutant.physiology.punch_damage_low += 1
			mutant.physiology.punch_damage_high += 2
		if(SPECIES_HUMAN)
			mutant.physiology.grab_resist_mod *= 1.25
			mutant.physiology.punch_damage_low += 3
			mutant.physiology.punch_damage_high += 4
		else
			mutant.physiology.grab_resist_mod *= 1.15
			mutant.physiology.punch_damage_low += 2
			mutant.physiology.punch_damage_high += 3


/datum/dna/gene/basic/strong/proc/remove_strong_modifiers(mob/living/carbon/human/mutant, datum/species/species)
	if(!species)
		species = mutant.dna.species
	mutant.physiology.tail_strength_mod /= 1.25
	switch(species.name)
		if(SPECIES_VULPKANIN, SPECIES_DRASK, SPECIES_UNATHI)
			mutant.physiology.grab_resist_mod /= 1.1
			mutant.physiology.punch_damage_low -= 1
			mutant.physiology.punch_damage_high -= 2
		if(SPECIES_HUMAN)
			mutant.physiology.grab_resist_mod /= 1.25
			mutant.physiology.punch_damage_low -= 3
			mutant.physiology.punch_damage_high -= 4
		else
			mutant.physiology.grab_resist_mod /= 1.15
			mutant.physiology.punch_damage_low -= 2
			mutant.physiology.punch_damage_high -= 3

