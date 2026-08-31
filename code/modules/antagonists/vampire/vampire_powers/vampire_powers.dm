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

/datum/action/cooldown/spell/vamp_rejuvenate
	name = "Восстановление"
	desc = "Наполните своё тело резервной кровью, чтобы снять с себя любые обездвиживающие эффекты."
	school = SCHOOL_SANGUINE
	button_icon_state = "vampire_rejuvinate"
	background_icon_state = "bg_vampire"
	cooldown_time = 20 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	check_flags = AB_CHECK_PHASED
	charge_restore_time = 10 SECONDS
	cooldown_between_charges = 5 SECONDS

/datum/action/cooldown/spell/vamp_rejuvenate/can_cast_spell(feedback)
	return ..() && owner.stat != DEAD

/datum/action/cooldown/spell/vamp_rejuvenate/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src)
	return handler

/datum/action/cooldown/spell/vamp_rejuvenate/Grant(mob/grant_to)
	. = ..()
	var/datum/antagonist/vampire/vampire = grant_to.mind.has_antag_datum(/datum/antagonist/vampire)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_GAIN, PROC_REF(on_diablerie_level_gain), override = TRUE)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_REMOVE, PROC_REF(on_diablerie_level_remove), override = TRUE)

/datum/action/cooldown/spell/vamp_rejuvenate/proc/on_diablerie_level_gain(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.upgrade_rejuvenate_charges(src)

/datum/action/cooldown/spell/vamp_rejuvenate/proc/on_diablerie_level_remove(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.downgrade_rejuvenate_charges(src)

/datum/action/cooldown/spell/vamp_rejuvenate/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = cast_on
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

/datum/action/cooldown/spell/vamp_rejuvenate/proc/heal(mob/living/carbon/human/user, rejuv_bonus)
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

/datum/action/cooldown/spell/vamp_specialize
	name = "Выбрать специализацию"
	desc = "Выберите, каким подклассом вампира вы хотите стать."
	school = SCHOOL_SANGUINE
	cooldown_time = 2 SECONDS
	button_icon_state = "select_class"
	background_icon_state = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	gain_desc = "Теперь вы можете выбрать, в какую специализацию вампира вы хотите эволюционировать."

/datum/action/cooldown/spell/vamp_specialize/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src)
	return handler

/datum/action/cooldown/spell/vamp_specialize/cast(atom/cast_on)
	. = ..()
	ui_interact(cast_on)

/datum/action/cooldown/spell/vamp_specialize/ui_state(mob/user)
	return GLOB.always_state

/datum/action/cooldown/spell/vamp_specialize/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VampireSpecMenu", "Меню выбора специализации")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/action/cooldown/spell/vamp_specialize/ui_static_data(mob/user)
	var/list/data = list()
	data["hemomancer"] = list(icon='icons/misc/vampire_tgui.dmi', icon_state="hemomancer")
	data["umbrae"] = list(icon='icons/misc/vampire_tgui.dmi',  icon_state="umbrae")
	data["gargantua"] = list(icon='icons/misc/vampire_tgui.dmi', icon_state="gargantua")
	data["dantalion"] = list(icon='icons/misc/vampire_tgui.dmi', icon_state="dantalion")
	data["bestia"] = list(icon='icons/misc/vampire_tgui.dmi', icon_state="bestia")

	return data
/datum/action/cooldown/spell/vamp_specialize/ui_data(mob/user)
	var/datum/antagonist/vampire/vamp = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/list/data = list("subclasses" = vamp.subclass)
	return data

/datum/action/cooldown/spell/vamp_specialize/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/datum/antagonist/vampire/vamp = owner.mind.has_antag_datum(/datum/antagonist/vampire)

	if(vamp.subclass)
		vamp.upgrade_tiers -= type
		vamp.remove_ability(src)
		return

	switch(action)
		if("umbrae")
			vamp.add_subclass(SUBCLASS_UMBRAE)
			vamp.upgrade_tiers -= type
			ui.close()
			vamp.powers -= src
			qdel(src)
		if("hemomancer")
			vamp.add_subclass(SUBCLASS_HEMOMANCER)
			vamp.upgrade_tiers -= type
			ui.close()
			vamp.powers -= src
			qdel(src)
		if("gargantua")
			vamp.add_subclass(SUBCLASS_GARGANTUA)
			vamp.upgrade_tiers -= type
			ui.close()
			vamp.powers -= src
			qdel(src)
		if("dantalion")
			vamp.add_subclass(SUBCLASS_DANTALION)
			vamp.upgrade_tiers -= type
			ui.close()
			vamp.powers -= src
			qdel(src)
		if("bestia")
			vamp.add_subclass(SUBCLASS_BESTIA)
			vamp.upgrade_tiers -= type
			ui.close()
			vamp.powers -= src
			qdel(src)

/datum/antagonist/vampire/proc/add_subclass(subclass_to_add, announce = TRUE, log_choice = TRUE)
	var/datum/vampire_subclass/new_subclass = new subclass_to_add
	subclass = new_subclass
	if(subclass_to_add == SUBCLASS_BESTIA)
		suck_rate = BESTIA_SUCK_RATE
	check_vampire_upgrade(announce)
	if(log_choice)
		SSblackbox.record_feedback("nested tally", "vampire_subclasses", 1, list("[new_subclass.name]"))

/datum/action/cooldown/spell/aoe/glare
	name = "Вспышка"
	desc = "Ваши глаза вспыхивают, ошеломляя и заставляя замолчать всех, кто находится прямо перед вами. В меньшей степени действует на окружающих вне вашего поля зрения."
	button_icon_state = "vampire_glare"
	background_icon_state = "bg_vampire"
	school = SCHOOL_SANGUINE
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	check_flags = AB_CHECK_PHASED
	aoe_radius = 1
	max_charges = 2
	charge_restore_time = 30 SECONDS
	cooldown_between_charges = 3 SECONDS
	targeting_type = /datum/aoe_targeting/vamp_glare

/datum/action/cooldown/spell/aoe/glare/can_cast_spell(feedback)
	return ..() && owner.stat == CONSCIOUS

/datum/action/cooldown/spell/aoe/glare/Grant(mob/granted_to)
	. = ..()
	var/datum/antagonist/vampire/vampire = granted_to.mind.has_antag_datum(/datum/antagonist/vampire)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_GAIN, PROC_REF(on_diablerie_level_gain), override = TRUE)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_REMOVE, PROC_REF(on_diablerie_level_remove), override = TRUE)

/datum/action/cooldown/spell/aoe/glare/proc/on_diablerie_level_gain(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.upgrade_glare_charges(src)

/datum/action/cooldown/spell/aoe/glare/proc/on_diablerie_level_remove(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.downgrade_glare_charges(src)

/// No deviation at all. Flashed from the front or front-left/front-right. Alternatively, flashed in direct view.
#define DEVIATION_NONE 3
/// Partial deviation. Flashed from the side. Alternatively, flashed out the corner of your eyes.
#define DEVIATION_PARTIAL 2
/// Full deviation. Flashed from directly behind or behind-left/behind-rack. Not flashed at all.
#define DEVIATION_FULL 1

/datum/action/cooldown/spell/aoe/glare/can_cast_spell(feedback)
	var/mob/living/carbon/human/user = owner
	if(ishuman(user) && istype(user.glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
		var/obj/item/clothing/glasses/sunglasses/blindfold/blindfold = user.glasses
		if(blindfold.tint)
			if(feedback)
				user.balloon_alert(user, "ваши глаза закрыты!")
			return FALSE
	return ..()

/datum/action/cooldown/spell/aoe/glare/before_cast(atom/cast_on)
	var/list/targets = get_things_to_cast_on(owner)
	if(targets.len == 0)
		return SPELL_CANCEL_CAST
	. = ..()
	var/mob/living/caster = owner
	caster.mob_light(LIGHT_COLOR_BLOOD_MAGIC, range = 3, duration = 0.2 SECONDS)

/datum/action/cooldown/spell/aoe/glare/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/user = caster
	var/mob/living/target = victim
	user.visible_message(span_warning("Глаза [user] испускают ослепительную вспышку!"))

	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
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

/datum/action/cooldown/spell/aoe/glare/proc/calculate_deviation(mob/victim, mob/attacker)
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
/datum/action/cooldown/spell/pointed/raise_free_vampire
	name = "Таинство посвящения"
	desc = "Позволяет поднять из мёртвых труп, мутировав его в вампира по вашему образу и подобию."
	cooldown_time = 300 SECONDS
	button_icon_state = "revive"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	cast_range = 1
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	gain_desc = "Вы получили способность \"Таинство посвящения\". Эта мощная способность действует только на трупы гуманоидов, имеющих кровь, воскрешая их как вампиров. Воскрешённые подобным образом вампиры будут обладать свободной волей и не будут подчиняться вам. Вы также не сможете получить с них доступной крови."
	var/required_blood = 50

/datum/action/cooldown/spell/pointed/raise_free_vampire/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/raise_free_vampire/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/victim = cast_on
	to_chat(owner, span_warning("Вы направляете поток блюспейс энергии в тело [victim], запуская необратимый процесс мутации!"))
	playsound(owner, 'sound/magic/wandodeath.ogg', 70, TRUE)
	owner.Beam(victim, "sendbeam", 'icons/effects/effects.dmi', time = 3 SECONDS, maxdistance = 7, beam_type = /obj/effect/ebeam)
	new /obj/effect/temp_visual/cult/sparks(owner.loc)
	new /obj/effect/temp_visual/cult/sparks(victim.loc)
	add_attack_logs(owner, victim, "raised from the dead as a free vampire")
	victim.revive()
	victim.mind.make_free_vampire()

/datum/action/cooldown/spell/pointed/raise_free_vampire/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		cast_on.balloon_alert(owner, "цель не гуманоид!")
		return FALSE
	var/mob/living/carbon/human/victim = cast_on
	if(!victim.mind)
		victim.balloon_alert(owner, "цель неразумна!")
		return FALSE

	if(victim.stat != DEAD)
		victim.balloon_alert(owner, "цель ещё жива!")
		return FALSE

	if(victim.mind.special_role || victim.mind.isholy || victim.mind.isblessed || ismindshielded(victim))
		victim.balloon_alert(owner, "цель сопротивляется!")
		to_chat(owner, span_warning("Разум [victim] сопротивляется блюспейс воздействию, и ничего не происходит."))
		return FALSE

	if(HAS_TRAIT(victim, TRAIT_NO_BLOOD))
		victim.balloon_alert(owner, "цель не имеет крови!")
		to_chat(owner, span_warning("Кровь [victim] не обладает жизненной силой, в ней невозможно запустить мутацию."))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/aoe/raise_vampires
	name = "Возвышение вампиров"
	desc = "Призывает смертоносных вампиров из блюспейса."
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "revive_thrall"
	background_icon_state = "bg_vampire"
	sound = 'sound/magic/wandodeath.ogg'
	aoe_radius = 3
	gain_desc = "Вы получили способность «Возвышение вампиров». Эта чрезвычайно мощная АОЕ-способность действует на всех людей рядом с вами. Вампиры/стражи исцеляются. Трупы воскрешаются как вампиры. Другие люди оглушаются, получают повреждения мозга, а затем погибают."
	targeting_type = /datum/aoe_targeting/human

/datum/action/cooldown/spell/aoe/raise_vampires/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src)
	return handler

/datum/action/cooldown/spell/aoe/raise_vampires/before_cast(atom/cast_on)
	. = ..()
	new /obj/effect/temp_visual/cult/sparks(owner.loc)
	to_chat(owner, span_warning("Вы взываете к блюспейсу, призывая на помощь ещё больше вампирических духов!"))

/datum/action/cooldown/spell/aoe/raise_vampires/cast_on_thing_in_aoe(atom/victim, atom/caster)
	caster.Beam(victim, "sendbeam", 'icons/effects/effects.dmi', time = 30, maxdistance = 7, beam_type = /obj/effect/ebeam)
	new /obj/effect/temp_visual/cult/sparks(victim.loc)
	raise_vampire(owner, victim)

/datum/action/cooldown/spell/aoe/raise_vampires/proc/raise_vampire(mob/user, mob/living/carbon/human/victim)
	if(!istype(user) || !istype(victim))
		return
	if(!victim.mind)
		victim.visible_message("Похоже, [victim] слишком глуп[GEND_A_O_Y(victim)], чтобы понять, что происходит.")
		return
	if(HAS_TRAIT(victim, TRAIT_NO_BLOOD) || HAS_TRAIT(victim, TRAIT_EXOTIC_BLOOD) || !victim.blood_volume)
		victim.visible_message("[victim] выгляд[PLUR_IT_YAT(victim)] невозмутимым!")
		return
	if(victim.mind.has_antag_datum(/datum/antagonist/vampire) || victim.mind.special_role == SPECIAL_ROLE_VAMPIRE || victim.mind.special_role == SPECIAL_ROLE_VAMPIRE_THRALL)
		victim.visible_message(span_notice("[victim] выгляд[PLUR_IT_YAT(victim)] посвежевшим!"))
		victim.heal_overall_damage(60, 60, affect_robotic = TRUE)
		for(var/obj/item/organ/external/bodypart as anything in victim.bodyparts)
			if(prob(25))
				bodypart.mend_fracture()
				bodypart.stop_internal_bleeding()
				bodypart.stop_bleeding()

		return
	if(victim.stat != DEAD)
		if(victim.IsWeakened())
			victim.visible_message(span_warning("[victim], похоже, испытыва[PLUR_ET_YUT(victim)] боль!"))
			victim.apply_damage(60, BRAIN)
		else
			victim.visible_message(span_warning("Похоже, что [victim] ошеломлен[GEND_A_O_Y(victim)] энергией!"))
			victim.Weaken(40 SECONDS)
		return
	for(var/obj/item/implant/mindshield/L in victim)
		if(L?.implanted)
			qdel(L)
	for(var/obj/item/implant/traitor/T in victim)
		if(T?.implanted)
			qdel(T)
	victim.visible_message(span_warning("У [victim] появля[PLUR_ET_YUT(victim)]ся жуткое красное свечение в глазах!"))
	var/datum/objective/protect/protect_objective = new
	protect_objective.owner = victim.mind
	protect_objective.target = user.mind
	protect_objective.explanation_text = "Защитите [user.real_name]."
	victim.mind.objectives += protect_objective
	add_attack_logs(user, victim, "Vampire-sired")
	victim.mind.make_vampire()
	victim.revive()
	victim.Weaken(40 SECONDS)

