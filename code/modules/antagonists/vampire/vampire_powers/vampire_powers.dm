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
		gain_desc = "Вы получили способность «[src]»."


/datum/vampire_passive/Destroy(force)
	owner = null
	return ..()


/datum/vampire_passive/proc/on_apply(datum/antagonist/vampire/vampire_datum)
	return


/datum/vampire_passive/proc/on_remove(datum/antagonist/vampire/vampire_datum)
	return


/datum/vampire_passive/regen
	gain_desc = "Ваша способность «Восстановление» улучшена. Теперь она будет постепенно исцелять вас после использования."


/datum/vampire_passive/vision
	gain_desc = "Ваше вампирское зрение улучшено."


/datum/vampire_passive/full
	gain_desc = "Вы достигли полной силы и ничто святое больше не может ослабить вас. Ваше зрение значительно улучшилось."


/datum/vampire_passive/full/on_apply(datum/antagonist/vampire/vampire_datum)
	. = ..()
	ADD_TRAIT(vampire_datum.owner.current, TRAIT_VIRUSIMMUNE, VAMPIRE_TRAIT)


/datum/vampire_passive/full/on_remove(datum/antagonist/vampire/vampire_datum)
	. = ..()
	REMOVE_TRAIT(vampire_datum.owner.current, TRAIT_VIRUSIMMUNE, VAMPIRE_TRAIT)

/datum/vampire_passive/regen_bleeding
	gain_desc = "Теперь ваша способность \"Восстановление\" лечит внетренние кровотечения."

/datum/vampire_passive/glare_aoe
	gain_desc = "Теперь ваша способность \"Вспышка\" не зависит от направления взгляда."


/obj/effect/proc_holder/spell/vampire
	name = "Report Me"
	desc = "You shouldn't see this!"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
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
	name = "Восстановление"
	desc = "Наполните своё тело резервной кровью, чтобы снять с себя любые обездвиживающие эффекты."
	action_icon_state = "vampire_rejuvinate"
	base_cooldown = 20 SECONDS
	stat_allowed = UNCONSCIOUS

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/on_spell_gain(mob/user)
	. = ..()
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_GAIN, PROC_REF(on_diablerie_level_gain))
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_REMOVE, PROC_REF(on_diablerie_level_remove))

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/proc/on_diablerie_level_gain(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.upgrade_rejuvenate_charges(cooldown_handler)

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/proc/on_diablerie_level_remove(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.downgrade_rejuvenate_charges(cooldown_handler)

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/create_new_cooldown()
	var/datum/spell_cooldown/charges/cooldown = new
	cooldown.max_charges = 1
	cooldown.recharge_duration = base_cooldown
	cooldown.charge_duration = 5 SECONDS
	return cooldown

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/cast(list/targets, mob/living/user = usr)
	// mech supress escape
	if(HAS_TRAIT_FROM(user, TRAIT_IMMOBILIZED, MECH_SUPRESSED_TRAIT))
		user.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED), MECH_SUPRESSED_TRAIT)
	user.SetWeakened(0)
	user.SetStunned(0)
	user.SetKnockdown(0)
	user.SetParalysis(0)
	user.SetSleeping(0)
	user.SetConfused(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE, instant = TRUE)
	user.get_up(instant = TRUE)
	to_chat(user, span_notice("Вы наполняете свое тело чистой кровью и снимаете все обездвиживающие эффекты."))
	var/datum/antagonist/vampire/vampire_datum = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/rejuv_bonus = vampire_datum.get_rejuv_bonus()
	if(rejuv_bonus)
		INVOKE_ASYNC(src, PROC_REF(heal), user, rejuv_bonus)


/obj/effect/proc_holder/spell/vampire/self/rejuvenate/proc/heal(mob/living/carbon/human/user, rejuv_bonus)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(vampire.get_ability(/datum/vampire_passive/regen_bleeding))
		var/list/internal_bleedings = user.check_internal_bleedings()
		if(length(internal_bleedings))
			var/obj/item/organ/external/bodypart = pick(internal_bleedings)
			bodypart.stop_internal_bleeding()

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
	name = "Выбрать специализацию"
	desc = "Выберите, каким подклассом вампира вы хотите стать."
	gain_desc = "Теперь вы можете выбрать, в какую специализацию вампира вы хотите эволюционировать."
	base_cooldown = 2 SECONDS
	action_icon_state = "select_class"


/obj/effect/proc_holder/spell/vampire/self/specialize/cast(mob/user)
	ui_interact(user)

/obj/effect/proc_holder/spell/vampire/self/specialize/ui_state(mob/user)
	return GLOB.always_state

/obj/effect/proc_holder/spell/vampire/self/specialize/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VampireSpecMenu", "Меню выбора специализации")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/effect/proc_holder/spell/vampire/self/specialize/ui_static_data(mob/user)
	var/list/data = list()
	data["hemomancer"] = list(icon='icons/misc/vampire_tgui.dmi', icon_state="hemomancer")
	data["umbrae"] = list(icon='icons/misc/vampire_tgui.dmi',  icon_state="umbrae")
	data["gargantua"] = list(icon='icons/misc/vampire_tgui.dmi', icon_state="gargantua")
	data["dantalion"] = list(icon='icons/misc/vampire_tgui.dmi', icon_state="dantalion")
	data["bestia"] = list(icon='icons/misc/vampire_tgui.dmi', icon_state="bestia")

	return data

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
	name = "Вспышка"
	desc = "Ваши глаза вспыхивают, ошеломляя и заставляя замолчать всех, кто находится прямо перед вами. В меньшей степени действует на окружающих вне вашего поля зрения."
	action_icon_state = "vampire_glare"
	base_cooldown = 30 SECONDS
	stat_allowed = UNCONSCIOUS

/obj/effect/proc_holder/spell/vampire/glare/on_spell_gain(mob/user)
	. = ..()
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_GAIN, PROC_REF(on_diablerie_level_gain))
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_REMOVE, PROC_REF(on_diablerie_level_remove))

/obj/effect/proc_holder/spell/vampire/glare/proc/on_diablerie_level_gain(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.upgrade_glare_charges(cooldown_handler)

/obj/effect/proc_holder/spell/vampire/glare/proc/on_diablerie_level_remove(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.downgrade_glare_charges(cooldown_handler)


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
			balloon_alert(user, "ваши глаза закрыты!")
			return

	user.mob_light(LIGHT_COLOR_BLOOD_MAGIC, _range = 3, _duration = 0.2 SECONDS)
	user.visible_message(span_warning("Глаза [user] испускают ослепительную вспышку!"))

	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/mob/living/target as anything in targets)
		var/deviation
		if(vampire.get_ability(/datum/vampire_passive/glare_aoe))
			deviation = DEVIATION_NONE

		else if(user.body_position == LYING_DOWN)
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

		to_chat(target, span_warning("Вы ослеплены взглядом [user]."))
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


/**
 * Unlike "raise_vampires" spell, which is absolutely crazy and shitspawn only, this one just gives you an opportunity
 * to raise from the dead a humanoid and make him a vampire with free will and no antag objectives.
 * Since at this point you alreday have max diablerie level, and this spell has 5 minutes CD, there shouldn't be any strong abuses.
 */
/obj/effect/proc_holder/spell/vampire/raise_free_vampire
	name = "Таинство посвящения"
	desc = "Позволяет поднять из мёртвых труп, мутировав его в вампира по вашему образу и подобию."
	base_cooldown = 300 SECONDS
	action_icon_state = "revive"
	gain_desc = "Вы получили способность \"Таинство посвящения\". Эта мощная способность действует только на трупы гуманоидов, имеющих кровь, воскрешая их как вампиров. Воскрешённые подобным образом вампиры будут обладать свободной волей и не будут подчиняться вам. Вы также не сможете получить с них доступной крови."
	required_blood = 50


/obj/effect/proc_holder/spell/vampire/raise_free_vampire/create_new_targeting()
	var/datum/spell_targeting/click/targeting = new()
	targeting.try_auto_target = FALSE
	targeting.range = 1
	targeting.click_radius = -1
	return targeting


/obj/effect/proc_holder/spell/vampire/raise_free_vampire/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/victim = targets[1]
	to_chat(user, span_warning("Вы направляете поток блюспейс энергии в тело [victim], запуская необратимый процесс мутации!"))
	playsound(user, 'sound/magic/wandodeath.ogg', 70, TRUE)
	user.Beam(victim, "sendbeam", 'icons/effects/effects.dmi', time = 3 SECONDS, maxdistance = 7, beam_type = /obj/effect/ebeam)
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	new /obj/effect/temp_visual/cult/sparks(victim.loc)

	add_attack_logs(user, victim, "raised from the dead as a free vampire")

	victim.revive()
	victim.mind.make_free_vampire()


/obj/effect/proc_holder/spell/vampire/raise_free_vampire/valid_target(mob/living/carbon/human/victim, mob/living/carbon/human/user)
	if(!istype(victim))
		user.balloon_alert(user, "цель не гуманоид!")
		return FALSE

	if(!victim.mind)
		user.balloon_alert(user, "цель неразумна!")
		return FALSE

	if(victim.stat != DEAD)
		user.balloon_alert(user, "цель ещё жива!")
		return FALSE

	if(victim.mind.special_role || victim.mind.isholy || victim.mind.isblessed || ismindshielded(victim))
		user.balloon_alert(user, "цель сопротивляется!")
		to_chat(user, span_warning("Разум [victim] сопротивляется блюспейс воздействию, и ничего не происходит."))
		return FALSE

	if(HAS_TRAIT(victim, TRAIT_NO_BLOOD))
		user.balloon_alert(user, "цель не имеет крови!")
		to_chat(user, span_warning("Кровь [victim] не обладает жизненной силой, в ней невозможно запустить мутацию."))
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/vampire/raise_vampires
	name = "Возвышение вампиров"
	desc = "Призывает смертоносных вампиров из блюспейса."
	school = "transmutation"
	invocation = "none"
	cooldown_min = 2 SECONDS
	action_icon_state = "revive_thrall"
	sound = 'sound/magic/wandodeath.ogg'
	gain_desc = "Вы получили способность «Возвышение вампиров». Эта чрезвычайно мощная АОЕ-способность действует на всех людей рядом с вами. Вампиры/стражи исцеляются. Трупы воскрешаются как вампиры. Другие люди оглушаются, получают повреждения мозга, а затем погибают."


/obj/effect/proc_holder/spell/vampire/raise_vampires/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.range = 3
	return T


/obj/effect/proc_holder/spell/vampire/raise_vampires/cast(list/targets, mob/user = usr)
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	var/turf/T = get_turf(user)
	to_chat(user, span_warning("Вы взываете к блюспейсу, призывая на помощь ещё больше вампирических духов!"))
	for(var/mob/living/carbon/human/H in targets)
		T.Beam(H, "sendbeam", 'icons/effects/effects.dmi', time = 30, maxdistance = 7, beam_type = /obj/effect/ebeam)
		new /obj/effect/temp_visual/cult/sparks(H.loc)
		raise_vampire(user, H)


/obj/effect/proc_holder/spell/vampire/raise_vampires/proc/raise_vampire(mob/M, mob/living/carbon/human/H)
	if(!istype(M) || !istype(H))
		return
	if(!H.mind)
		visible_message("Похоже, [H] слишком глуп[genderize_ru(H.gender, "", "а", "о", "ы")], чтобы понять, что происходит.")
		return
	if(HAS_TRAIT(H, TRAIT_NO_BLOOD) || HAS_TRAIT(H, TRAIT_EXOTIC_BLOOD) || !H.blood_volume)
		visible_message("[H] выгляд[pluralize_ru(H.gender, "ит", "ят")] невозмутимым!")
		return
	if(H.mind.has_antag_datum(/datum/antagonist/vampire) || H.mind.special_role == SPECIAL_ROLE_VAMPIRE || H.mind.special_role == SPECIAL_ROLE_VAMPIRE_THRALL)
		visible_message(span_notice("[H] выгляд[pluralize_ru(H.gender, "ит", "ят")] посвежевшим!"))
		H.heal_overall_damage(60, 60, affect_robotic = TRUE)
		for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
			if(prob(25))
				bodypart.mend_fracture()
				bodypart.stop_internal_bleeding()

		return
	if(H.stat != DEAD)
		if(H.IsWeakened())
			visible_message(span_warning("[H], похоже, испытыва[pluralize_ru(H.gender, "ет", "ют")] боль!"))
			H.apply_damage(60, BRAIN)
		else
			visible_message(span_warning("Похоже, что [H] ошеломлен[genderize_ru(H.gender, "", "а", "о", "ы")] энергией!"))
			H.Weaken(40 SECONDS)
		return
	for(var/obj/item/implant/mindshield/L in H)
		if(L && L.implanted)
			qdel(L)
	for(var/obj/item/implant/traitor/T in H)
		if(T && T.implanted)
			qdel(T)
	visible_message(span_warning("У [H] появля[pluralize_ru(H.gender, "ет", "ют")]ся жуткое красное свечение в глазах!"))
	var/datum/objective/protect/protect_objective = new
	protect_objective.owner = H.mind
	protect_objective.target = M.mind
	protect_objective.explanation_text = "Защитите [M.real_name]."
	H.mind.objectives += protect_objective
	add_attack_logs(M, H, "Vampire-sired")
	H.mind.make_vampire()
	H.revive()
	H.Weaken(40 SECONDS)

