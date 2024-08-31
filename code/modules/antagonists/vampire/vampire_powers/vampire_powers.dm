/mob/living/proc/affects_vampire(mob/user)
	//Other vampires and thralls aren't affected
	if(isvampire(src) || isvampirethrall(src))
		return FALSE

	//Vampires who have reached their full potential can affect nearly everything
	var/datum/antagonist/vampire/vamp = user?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp?.get_ability(/datum/vampire_passive/full))
		return TRUE

	//Holy characters are resistant to vampire powers
	if(mind?.isholy)
		return FALSE

	return TRUE


/datum/vampire_passive
	var/gain_desc
	var/mob/living/owner = null


/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You can now use [src]."


/datum/vampire_passive/Destroy(force)
	owner = null
	return ..()


/datum/vampire_passive/proc/on_apply(datum/antagonist/vampire/V)
	return


/datum/vampire_passive/regen
	gain_desc = "Your rejuvenation abilities have improved and will now heal you over time when used."


/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."


/datum/vampire_passive/full
	gain_desc = "You have reached your full potential. You are no longer weak to the effects of anything holy and your vision has improved greatly."


/obj/effect/proc_holder/spell/vampire
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	human_req = TRUE
	clothes_req = FALSE
	/// How much blood this ability costs to use
	var/required_blood
	var/deduct_blood_on_cast = TRUE


/obj/effect/proc_holder/spell/vampire/after_spell_init()
	update_vampire_spell_name()


/obj/effect/proc_holder/spell/proc/update_vampire_spell_name(mob/user = usr)
	var/datum/spell_handler/vampire/handler = custom_handler
	if(istype(handler))
		var/new_name
		if(handler.required_blood)
			new_name = "[initial(name)] ([handler.required_blood])"
		else
			new_name = "[initial(name)]"

		name = new_name
		action?.name = new_name
		action?.UpdateButtonIcon()


/obj/effect/proc_holder/spell/vampire/create_new_handler()
	var/datum/spell_handler/vampire/H = new
	H.required_blood = required_blood
	H.deduct_blood_on_cast = deduct_blood_on_cast
	return H


/obj/effect/proc_holder/spell/vampire/self/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/vampire/self/rejuvenate
	name = "Rejuvenate"
	desc = "Use reserve blood to enliven your body, removing any incapacitating effects."
	action_icon_state = "vampire_rejuvinate"
	base_cooldown = 20 SECONDS
	stat_allowed = UNCONSCIOUS


/obj/effect/proc_holder/spell/vampire/self/rejuvenate/cast(list/targets, mob/living/user = usr)
	user.SetWeakened(0)
	user.SetStunned(0)
	user.SetKnockdown(0)
	user.SetParalysis(0)
	user.SetSleeping(0)
	user.SetConfused(0)
	user.adjustStaminaLoss(-100)
	user.set_resting(FALSE, instant = TRUE)
	user.get_up(instant = TRUE)
	to_chat(user, span_notice("You instill your body with clean blood and remove any incapacitating effects."))
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/rejuv_bonus = V.get_rejuv_bonus()
	if(rejuv_bonus)
		INVOKE_ASYNC(src, PROC_REF(heal), user, rejuv_bonus)


/obj/effect/proc_holder/spell/vampire/self/rejuvenate/proc/heal(mob/living/user, rejuv_bonus)
	for(var/i in 1 to 5)
		var/update = NONE
		update |= user.heal_overall_damage(2 * rejuv_bonus, 2 * rejuv_bonus, updating_health = FALSE, affect_robotic = TRUE)
		update |= user.heal_damages(tox = 2 * rejuv_bonus, oxy = 5 * rejuv_bonus, updating_health = FALSE)
		if(update)
			user.updatehealth()
		for(var/datum/reagent/R in user.reagents.reagent_list)
			if(!R.harmless)
				user.reagents.remove_reagent(R.id, 2 * rejuv_bonus)
		sleep(3.5 SECONDS)


/datum/antagonist/vampire/proc/get_rejuv_bonus()
	var/rejuv_multiplier = 0
	if(!get_ability(/datum/vampire_passive/regen))
		return rejuv_multiplier

	if(subclass?.improved_rejuv_healing)
		rejuv_multiplier = clamp((100 - owner.current.health) / 20, 1, 5) // brute and burn healing between 5 and 50
		return rejuv_multiplier

	return 1


/obj/effect/proc_holder/spell/vampire/self/specialize
	name = "Choose Specialization"
	desc = "Choose what sub-class of vampire you want to evolve into."
	gain_desc = "You can now choose what specialization of vampire you want to evolve into."
	base_cooldown = 2 SECONDS
	action_icon_state = "select_class"


/obj/effect/proc_holder/spell/vampire/self/specialize/cast(mob/user)
	ui_interact(user)

/obj/effect/proc_holder/spell/vampire/self/specialize/ui_state(mob/user)
	return GLOB.always_state

/obj/effect/proc_holder/spell/vampire/self/specialize/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VampireSpecMenu", "Specialisation Menu")
		ui.set_autoupdate(FALSE)
		ui.open()


/obj/effect/proc_holder/spell/vampire/self/specialize/ui_data(mob/user)
	var/datum/antagonist/vampire/vamp = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/list/data = list("subclasses" = vamp.subclass)
	return data


/obj/effect/proc_holder/spell/vampire/self/specialize/ui_act(action, list/params)
	if(..())
		return
	var/datum/antagonist/vampire/vamp = usr.mind.has_antag_datum(/datum/antagonist/vampire)

	if(vamp.subclass)
		vamp.upgrade_tiers -= type
		vamp.remove_ability(src)
		return

	switch(action)
		if("umbrae")
			vamp.add_subclass(SUBCLASS_UMBRAE)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("hemomancer")
			vamp.add_subclass(SUBCLASS_HEMOMANCER)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("gargantua")
			vamp.add_subclass(SUBCLASS_GARGANTUA)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("dantalion")
			vamp.add_subclass(SUBCLASS_DANTALION)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("bestia")
			vamp.add_subclass(SUBCLASS_BESTIA)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)


/datum/antagonist/vampire/proc/add_subclass(subclass_to_add, announce = TRUE, log_choice = TRUE)
	var/datum/vampire_subclass/new_subclass = new subclass_to_add
	subclass = new_subclass
	if(subclass_to_add == SUBCLASS_BESTIA)
		suck_rate = BESTIA_SUCK_RATE
	check_vampire_upgrade(announce)
	if(log_choice)
		SSblackbox.record_feedback("nested tally", "vampire_subclasses", 1, list("[new_subclass.name]"))


/obj/effect/proc_holder/spell/vampire/glare
	name = "Glare"
	desc = "Your eyes flash, stunning and silencing anyone in front of you. It has lesser effects for those around you."
	action_icon_state = "vampire_glare"
	base_cooldown = 30 SECONDS
	stat_allowed = UNCONSCIOUS


/obj/effect/proc_holder/spell/vampire/glare/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.allowed_type = /mob/living
	T.range = 1
	return T


/obj/effect/proc_holder/spell/vampire/glare/valid_target(mob/living/target, mob/user)
	return !isnull(target.mind) && target.stat != DEAD && target.affects_vampire(user)


/obj/effect/proc_holder/spell/vampire/glare/create_new_cooldown()
	var/datum/spell_cooldown/charges/C = new
	C.max_charges = 2
	C.recharge_duration = base_cooldown
	C.charge_duration = 3 SECONDS
	return C


/// No deviation at all. Flashed from the front or front-left/front-right. Alternatively, flashed in direct view.
#define DEVIATION_NONE 3
/// Partial deviation. Flashed from the side. Alternatively, flashed out the corner of your eyes.
#define DEVIATION_PARTIAL 2
/// Full deviation. Flashed from directly behind or behind-left/behind-rack. Not flashed at all.
#define DEVIATION_FULL 1

/obj/effect/proc_holder/spell/vampire/glare/cast(list/targets, mob/living/carbon/human/user = usr)
	if(ishuman(user) && istype(user.glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
		var/obj/item/clothing/glasses/sunglasses/blindfold/blindfold = user.glasses
		if(blindfold.tint)
			to_chat(user, span_warning("You're blindfolded!"))
			return

	user.mob_light(LIGHT_COLOR_BLOOD_MAGIC, _range = 3, _duration = 0.2 SECONDS)
	user.visible_message(span_warning("[user]'s eyes emit a blinding flash!"))

	for(var/mob/living/target as anything in targets)
		var/deviation
		if(user.body_position == LYING_DOWN)
			deviation = DEVIATION_PARTIAL
		else
			deviation = calculate_deviation(target, user)

		if(deviation == DEVIATION_FULL)
			target.Confused(6 SECONDS)
			target.apply_damage(30, STAMINA)

		else if(deviation == DEVIATION_PARTIAL)
			target.Weaken(4 SECONDS)
			target.Confused(10 SECONDS)
			target.apply_damage(40, STAMINA)

		else
			target.Confused(10 SECONDS)
			target.apply_damage(30, STAMINA)
			target.Weaken(2 SECONDS)
			target.apply_status_effect(STATUS_EFFECT_STAMINADOT)
			target.AdjustSilence(8 SECONDS)
			target.flash_eyes(1, TRUE, TRUE)

		to_chat(target, span_warning("You are blinded by [user]'s glare."))
		add_attack_logs(user, target, "(Vampire) Glared at")


/obj/effect/proc_holder/spell/vampire/glare/proc/calculate_deviation(mob/victim, mob/attacker)
	// Are they on the same tile? We'll return partial deviation. This may be someone flashing while lying down
	if(victim.loc == attacker.loc)
		return DEVIATION_PARTIAL

	// If the victim was looking at the attacker, this is the direction they'd have to be facing.
	var/attacker_to_victim = get_dir(attacker, victim)
	// The victim's dir is necessarily a cardinal value.
	var/attacker_dir = attacker.dir

	// - - -
	// - V - Attacker facing south
	// # # #
	// Attacker within 45 degrees of where the victim is facing.
	if(attacker_dir & attacker_to_victim)
		return DEVIATION_NONE

	// # # #
	// - V - Attacker facing south
	// - - -
	// Victim at 135 or more degrees of where the victim is facing.
	if(attacker_dir & GetOppositeDir(attacker_to_victim))
		return DEVIATION_FULL

	// - - -
	// # V # Attacker facing south
	// - - -
	// Victim lateral to the victim.
	return DEVIATION_PARTIAL

#undef DEVIATION_NONE
#undef DEVIATION_PARTIAL
#undef DEVIATION_FULL


/obj/effect/proc_holder/spell/vampire/raise_vampires
	name = "Raise Vampires"
	desc = "Summons deadly vampires from bluespace."
	school = "transmutation"
	clothes_req = FALSE
	human_req = TRUE
	invocation = "none"
	invocation_type = "none"
	base_cooldown = 10 SECONDS
	cooldown_min = 2 SECONDS
	action_icon_state = "revive_thrall"
	sound = 'sound/magic/wandodeath.ogg'
	gain_desc = "You have gained the ability to Raise Vampires. This extremely powerful AOE ability affects all humans near you. Vampires/thralls are healed. Corpses are raised as vampires. Others are stunned, then brain damaged, then killed."


/obj/effect/proc_holder/spell/vampire/raise_vampires/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.range = 3
	return T


/obj/effect/proc_holder/spell/vampire/raise_vampires/cast(list/targets, mob/user = usr)
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	var/turf/T = get_turf(user)
	to_chat(user, span_warning("You call out within bluespace, summoning more vampiric spirits to aid you!"))
	for(var/mob/living/carbon/human/H in targets)
		T.Beam(H, "sendbeam", 'icons/effects/effects.dmi', time = 30, maxdistance = 7, beam_type = /obj/effect/ebeam)
		new /obj/effect/temp_visual/cult/sparks(H.loc)
		raise_vampire(user, H)


/obj/effect/proc_holder/spell/vampire/raise_vampires/proc/raise_vampire(mob/M, mob/living/carbon/human/H)
	if(!istype(M) || !istype(H))
		return
	if(!H.mind)
		visible_message("[H] looks to be too stupid to understand what is going on.")
		return
	if(HAS_TRAIT(H, TRAIT_NO_BLOOD) || HAS_TRAIT(H, TRAIT_EXOTIC_BLOOD) || !H.blood_volume)
		visible_message("[H] looks unfazed!")
		return
	if(H.mind.has_antag_datum(/datum/antagonist/vampire) || H.mind.special_role == SPECIAL_ROLE_VAMPIRE || H.mind.special_role == SPECIAL_ROLE_VAMPIRE_THRALL)
		visible_message(span_notice("[H] looks refreshed!"))
		H.heal_overall_damage(60, 60, affect_robotic = TRUE)
		for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
			if(prob(25))
				bodypart.mend_fracture()
				bodypart.stop_internal_bleeding()

		return
	if(H.stat != DEAD)
		if(H.IsWeakened())
			visible_message(span_warning("[H] looks to be in pain!"))
			H.apply_damage(60, BRAIN)
		else
			visible_message(span_warning("[H] looks to be stunned by the energy!"))
			H.Weaken(40 SECONDS)
		return
	for(var/obj/item/implant/mindshield/L in H)
		if(L && L.implanted)
			qdel(L)
	for(var/obj/item/implant/traitor/T in H)
		if(T && T.implanted)
			qdel(T)
	visible_message(span_warning("[H] gets an eerie red glow in their eyes!"))
	var/datum/objective/protect/protect_objective = new
	protect_objective.owner = H.mind
	protect_objective.target = M.mind
	protect_objective.explanation_text = "Protect [M.real_name]."
	H.mind.objectives += protect_objective
	add_attack_logs(M, H, "Vampire-sired")
	H.mind.make_vampire()
	H.revive()
	H.Weaken(40 SECONDS)

