#define DEFIB_NO_SHOCK 0
#define DEFIB_SHOCK_FAILED 1
#define DEFIB_SHOCK_SUCCESS 2
#define DEFIB_DAMAGE 40
#define DEFIB_COMBAT_DAMAGE 70
/**
 * A component for an item that attempts to defibrillate a mob when activated.
 */
/datum/component/defib
	/// If this is being used by a borg or not, with necessary safeties applied if so.
	var/robotic
	/// If it should penetrate space suits
	var/ignore_hardsuits
	/// Chance to cause cardiac arrest when used in Harm mode with safety protocols disabled.
	var/heart_attack_chance
	/// Whether the safeties are enabled or not
	var/safety
	/// If the defib is actively performing a defib cycle
	var/busy = FALSE
	/// Cooldown length for this defib in deciseconds
	var/cooldown
	/// Whether or not we're currently on cooldown
	var/on_cooldown = FALSE
	/// How fast the defib should work.
	var/speed_multiplier
	/// If true, EMPs will have no effect.
	var/emp_proof
	/// If true, this cannot be emagged.
	var/emag_proof
	/// uid to an item that should be making noise and handling things that our direct parent shouldn't be concerned with.
	var/actual_unit_uid

/**
 * Create a new defibrillation component.
 *
 * Arguments:
 * * robotic - whether this should be treated like a borg module.
 * * cooldown - Minimum time possible between shocks.
 * * speed_multiplier - Speed multiplier for defib do-afters.
 * * ignore_hardsuits - If true, the defib can zap through hardsuits.
 * * heart_attack_chance - If safeties are off, the % chance for this to cause a heart attack on harm intent.
 * * safe_by_default - If true, safety will be enabled by default.
 * * emp_proof - If true, safety won't be switched by emp. Note that the device itself can still have behavior from it, it's just that the component will not.
 * * emag_proof - If true, safety won't be switched by emag. Note that the device itself can still have behavior from it, it's just that the component will not.
 * * actual_unit - Unit which the component's parent is based from, such as a large defib unit or a borg. The actual_unit will make the sounds and be the "origin" of visible messages, among other things.
 */
/datum/component/defib/Initialize(robotic, cooldown = 5 SECONDS, speed_multiplier = 1, ignore_hardsuits = FALSE, safe_by_default = TRUE, emp_proof = FALSE, emag_proof = FALSE, obj/item/actual_unit = null, heart_attack_chance = 0)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.robotic = robotic
	src.speed_multiplier = speed_multiplier
	src.cooldown = cooldown
	src.ignore_hardsuits = ignore_hardsuits
	src.heart_attack_chance = heart_attack_chance
	safety = safe_by_default
	src.emp_proof = emp_proof
	src.emag_proof = emag_proof

	if(actual_unit)
		actual_unit_uid = actual_unit.UID()

	var/effect_target = isnull(actual_unit) ? parent : actual_unit

	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(trigger_defib))
	RegisterSignal(parent, COMSIG_GLOVES_DOUBLE_HANDS_TOUCH, PROC_REF(trigger_defib))
	RegisterSignal(effect_target, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))
	RegisterSignal(effect_target, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

/**
 * Get the "parent" that effects (emags, EMPs) should be applied onto.
 */
/datum/component/defib/proc/get_effect_target()
	var/actual_unit = locateUID(actual_unit_uid)
	if(!actual_unit)
		return parent
	return actual_unit

/datum/component/defib/proc/on_emp(obj/item/unit)
	SIGNAL_HANDLER  // COMSIG_ATOM_EMP_ACT
	if(emp_proof)
		return

	if(safety)
		safety = FALSE
		playsound(get_turf(unit), 'sound/machines/defib_saftyoff.ogg', 50, FALSE)
		unit.atom_say("Протоколы безопасности деактивированы!", FALSE)
	else
		safety = TRUE
		playsound(get_turf(unit), 'sound/machines/defib_saftyon.ogg', 50, FALSE)
		unit.atom_say("Протоколы безопасности активированы!", FALSE)

/datum/component/defib/proc/on_emag(obj/item/unit, mob/user)
	SIGNAL_HANDLER  // COMSIG_ATOM_EMAG_ACT
	if(emag_proof)
		return
	safety = !safety
	if(user && !robotic)
		user.balloon_alert(user, "протоколы безопасности [safety ? "" : "де"]активированы!")

/datum/component/defib/proc/set_cooldown(how_short)
	on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_cooldown)), how_short)

/datum/component/defib/proc/end_cooldown()
	on_cooldown = FALSE
	SEND_SIGNAL(parent, COMSIG_DEFIB_READY)

/**
 * Start the defibrillation process when triggered by a signal.
 */
/datum/component/defib/proc/trigger_defib(obj/item/paddles, mob/living/carbon/human/target, mob/living/user)
	SIGNAL_HANDLER  // COMSIG_ITEM_ATTACK
	if(HAS_TRAIT(paddles, TRAIT_DEFIB_BLOCKED))  // The TRAIT is added if the built-in defibrillator in the inugami gloves is disabled
		return
	// This includes some do-afters, so we have to pass it off asynchronously
	INVOKE_ASYNC(src, PROC_REF(defibrillate), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Perform a defibrillation.
 */
/datum/component/defib/proc/defibrillate(mob/living/user, mob/living/carbon/human/target)
	// Before we do all the hard work, make sure we aren't already defibbing someone
	if(busy)
		return DEFIB_NO_SHOCK

	var/parent_unit = locateUID(actual_unit_uid)
	var/should_cause_harm = user.a_intent == INTENT_HARM && !safety
	var/should_cause_disarm = user.a_intent == INTENT_DISARM && !safety
	var/is_offensive = should_cause_harm || should_cause_disarm

	// Find what the defib should be referring to itself as
	var/atom/defib_ref
	if(parent_unit)
		defib_ref = parent_unit
	else if(robotic)
		defib_ref = user
	if(!defib_ref) // Contingency
		defib_ref = parent

	// check what the unit itself has to say about how the defib went
	var/application_result = SEND_SIGNAL(parent, COMSIG_DEFIB_PADDLES_APPLIED, user, target, is_offensive)

	if(application_result & COMPONENT_BLOCK_DEFIB_DEAD)
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, FALSE)
		defib_ref.atom_say("Недостаточно энергии!", FALSE)
		return DEFIB_NO_SHOCK

	if(on_cooldown)
		user.balloon_alert(user, "заряд не готов!")
		return DEFIB_NO_SHOCK

	if(application_result & COMPONENT_BLOCK_DEFIB_MISC)
		return DEFIB_NO_SHOCK

	if(!istype(target))
		user.balloon_alert(user, "неподходящая цель!")
		return DEFIB_NO_SHOCK

	busy = TRUE
	var/result = DEFIB_NO_SHOCK

	if(should_cause_harm)
		result = combat_fibrillate(user, target, defib_ref)
	else if(should_cause_disarm)
		result = disarm_fibrillate(user, target, defib_ref)
	else
		result = medical_fibrillate(user, target, defib_ref)

	busy = FALSE

	if(result != DEFIB_NO_SHOCK)
		SEND_SIGNAL(parent, COMSIG_DEFIB_SHOCK_APPLIED, user, target, is_offensive, result == DEFIB_SHOCK_SUCCESS)

	return result

/**
 * Standard medical defibrillation flow.
 *
 * Arguments:
 * * user - wielder of the defib
 * * target - person getting shocked
 * * defib_ref - the defibrillator instance
 */
/datum/component/defib/proc/medical_fibrillate(mob/living/user, mob/living/carbon/human/target, atom/defib_ref)
	user.visible_message(
		span_warning("[user] начина[PLUR_ET_YUT(user)] размещать электроды дефибриллятора на груди [target.name]."),
		span_warning("Вы начинаете размещать электроды дефибриллятора на груди [target.name]."),
	)
	var/mob/dead/observer/ghost = target.get_ghost(TRUE)
	if(ghost?.can_reenter_corpse)
		to_chat(ghost, span_ghostalert("Ваше сердце пытаются дефибриллировать. Вернитесь в своё тело, если хотите быть оживлены!"))
		window_flash(ghost.client)
		SEND_SOUND(ghost, sound('sound/effects/genetics.ogg'))

	if(!do_after(user, 3 SECONDS * speed_multiplier, target, category = DA_CAT_TOOL)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
		return DEFIB_NO_SHOCK

	user.visible_message(
		span_notice("[user] разместил[GEND_A_O_I(user)] электроды дефибриллятора на груди [target.name]."),
		span_notice("Вы разместили электроды дефибриллятора на груди [target.name]."),
	)
	playsound(get_turf(defib_ref), 'sound/machines/defib_charge.ogg', 50, FALSE)

	if(ghost && !ghost.client && !QDELETED(ghost))
		log_debug("Ghost of name [ghost.name] is bound to [target.real_name], but lacks a client. Deleting ghost.")
		QDEL_NULL(ghost)

	if(!do_after(user, 2 SECONDS * speed_multiplier, target, category = DA_CAT_TOOL)) //placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
		return DEFIB_NO_SHOCK

	if(istype(target.wear_suit, /obj/item/clothing/suit/space) && !ignore_hardsuits)
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, FALSE)
		defib_ref.atom_say("Грудь пациента закрыта. Операция отменена.", FALSE)
		return DEFIB_NO_SHOCK

	// --- CARDIAC ARREST PATH ---
	if(target.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = target.get_organ_slot(INTERNAL_ORGAN_HEART)
		if(!heart || heart.is_dead())
			playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, FALSE)
			if(!heart)
				defib_ref.atom_say("Реанимация не удалась — электрическая активность сердца не зафиксирована!", FALSE)
			else
				defib_ref.atom_say("Реанимация не удалась — обнаружен некроз сердца!", FALSE)
			return DEFIB_NO_SHOCK

		target.set_heartattack(FALSE)
		SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
		set_cooldown(cooldown)
		defib_ref.atom_say("Сердечная аритмия устранена!", FALSE)
		target.visible_message(
			span_warning("Тело [target] слегка вздрагивает."),
			span_userdanger("Вы чувствуете мощный удар током, после которого ритм вашего сердца приходит в норму.")
		)
		playsound(get_turf(defib_ref), 'sound/machines/defib_zap.ogg', 50, TRUE, -1)
		playsound(get_turf(defib_ref), SFX_BODYFALL, 50, TRUE)
		playsound(get_turf(defib_ref), 'sound/machines/defib_success.ogg', 50, FALSE)
		target.shock_internal_organs(100)
		return DEFIB_SHOCK_SUCCESS

	// --- NOT DEAD CHECK ---
	if(target.stat != DEAD && !HAS_TRAIT(target, TRAIT_FAKEDEATH))
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, FALSE)
		defib_ref.atom_say("Пациент не подлежит реанимации. Операция отменена.", FALSE)
		return DEFIB_NO_SHOCK

	// --- REVIVE PATH ---
	target.visible_message(span_warning("Тело [target] слегка вздрагивает."))
	playsound(get_turf(defib_ref), SFX_BODYFALL, 50, TRUE)
	playsound(get_turf(defib_ref), 'sound/machines/defib_zap.ogg', 50, TRUE, -1)
	ghost = target.get_ghost(TRUE) // We have to double check whether the dead guy has entered their body during the above

	var/defib_success = TRUE

	// Run through some quick failure states after shocking.
	var/time_dead = world.time - target.timeofdeath

	if((time_dead > DEFIB_TIME_LIMIT) || !target.get_organ_slot(INTERNAL_ORGAN_HEART))
		defib_ref.atom_say("Реанимация не удалась — обнаружены необратимые повреждения сердца!", FALSE)
		defib_success = FALSE
	else if(target.getBruteLoss() >= 180 || target.getFireLoss() >= 180 || target.getCloneLoss() >= 180)
		defib_ref.atom_say("Реанимация не удалась — обнаружены обширные повреждения тканей!", FALSE)
		defib_success = FALSE
	else if(target.blood_volume < BLOOD_VOLUME_SURVIVE)
		defib_ref.atom_say("Реанимация не удалась — объём крови в организме пациента на критически низком уровне!", FALSE)
		defib_success = FALSE
	else if(!target.get_organ_slot(INTERNAL_ORGAN_BRAIN))  //So things like headless clings don't get outed
		defib_ref.atom_say("Реанимация не удалась — мозг в теле пациента не обнаружен!", FALSE)
		defib_success = FALSE
	else if(ghost)
		if(!ghost.can_reenter_corpse || target.suiciding) // DNR or AntagHUD
			defib_ref.atom_say("Реанимация не удалась — электрическая активность мозга не зафиксирована!", FALSE)
		else
			defib_ref.atom_say("Реанимация не удалась — мозг пациента не отреагировал!", FALSE)
		defib_success = FALSE
	else if(HAS_TRAIT(target, TRAIT_NO_CLONE) || !target.mind || !(target.mind.is_revivable()) || HAS_TRAIT(target, TRAIT_FAKEDEATH) || target.suiciding)  // these are a bit more arbitrary
		defib_ref.atom_say("Реанимация не удалась!", FALSE)
		defib_success = FALSE

	if(!defib_success)
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, FALSE)
		set_cooldown(cooldown)
		return DEFIB_SHOCK_FAILED

	// --- SUCCESS ---
	// Heal oxy and tox damage type by as much as we're under -100 health
	var/damage_above_threshold = -(min(target.health, HEALTH_THRESHOLD_DEAD) - HEALTH_THRESHOLD_DEAD)
	var/heal_amount = damage_above_threshold + 5
	target.heal_damages(tox = heal_amount, oxy = heal_amount)

	// Inflict some brain damage scaling with time spent dead
	var/defib_time_brain_damage = min(100 * time_dead / DEFIB_TIME_LIMIT, 99) // 20 from 1 minute onward, +20 per minute up to 99
	if(time_dead > DEFIB_TIME_LOSS && defib_time_brain_damage > target.getBrainLoss())
		target.setBrainLoss(defib_time_brain_damage)

	target.update_revive(updating = TRUE, force = FALSE, defib_revive = TRUE)
	target.Paralyse(12 SECONDS)
	target.emote("gasp")

	if(target.getBrainLoss() >= 100)
		playsound(get_turf(defib_ref), 'sound/machines/defib_saftyoff.ogg', 50, FALSE)
		defib_ref.atom_say("Реанимация успешна. Критически слабая активность мозга пациента.", FALSE)
	else
		playsound(get_turf(defib_ref), 'sound/machines/defib_success.ogg', 50, FALSE)

	defib_ref.atom_say("Реанимация успешна!", FALSE)

	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
	if(ishuman(target.pulledby)) // for some reason, pulledby isnt a list despite it being possible to be pulled by multiple people
		excess_shock(user, target, target.pulledby, defib_ref)

	target.med_hud_set_health()
	target.med_hud_set_status()
	target.shock_internal_organs(100)
	target.special_check_for_transplantation()
	add_attack_logs(user, target, "Revived with [defib_ref]")
	SSblackbox.record_feedback("tally", "players_revived", 1, "defibrillator")
	set_cooldown(cooldown)

	return DEFIB_SHOCK_SUCCESS

/**
 * Attempts to block a attack (such as a defibrillator shock) using the target's held or worn items.
 *
 * Iterates through all items in the target's contents and calls their hit_reaction(),
 * which handles block chance and shield components.
 *
 * Arguments:
 * * target - person being attacked
 * * attack_text - text used in block messages
 * * attack_type - type of the incoming attack (used for block filtering)
 *
 * Returns:
 * * TRUE - if the attack was successfully blocked
 * * FALSE - if no blocking item reacted
 */
/datum/component/defib/proc/try_block_attack(mob/living/carbon/human/target, mob/living/user, attack_type = ITEM_ATTACK)
	if(!target || !user || !isitem(parent))
		return FALSE

	var/obj/item/defib_item = parent
	return target.check_shields(defib_item, 0, "[defib_item.declent_ru(ACCUSATIVE)] [user.declent_ru(GENITIVE)]", attack_type)

/**
 * Applies the non-lethal effects of an offensive defibrillator shock.
 *
 * Standard defibs apply stamina damage and either confusion or knockdown.
 * Combat-capable defibs that ignore hardsuits always apply knockdown instead.
 *
 * Arguments:
 * * target - person being shocked
 */
/datum/component/defib/proc/apply_disarm_fibrillate_effects(mob/living/carbon/human/target)
	target.AdjustJitter(40 SECONDS, bound_upper = 40 SECONDS)
	target.AdjustStuttering(16 SECONDS, bound_upper = 16 SECONDS)

	if(ignore_hardsuits)
		target.apply_damage(DEFIB_COMBAT_DAMAGE, STAMINA)
		target.Knockdown(5 SECONDS)
		return

	target.apply_damage(DEFIB_DAMAGE, STAMINA)
	target.AdjustConfused(10 SECONDS, bound_lower = 0, bound_upper = 10 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(apply_disarm_knockdown_end), target), 5 SECONDS)

/datum/component/defib/proc/apply_disarm_knockdown_end(mob/living/carbon/human/target)
	if(QDELETED(target))
		return
	if(!target.IsKnockdown())
		to_chat(target, span_warning("Ваши мышцы сводит судорогой, и вы падаете на землю!"))
	target.Knockdown(3 SECONDS)
/**
 * Inflict stamina loss and confusion/knockdown on someone.
 *
 * Arguments:
 * * user - wielder of the defib
 * * target - person getting shocked
 * * defib_ref - the defibrillator instance
 */
/datum/component/defib/proc/disarm_fibrillate(mob/user, mob/living/carbon/human/target, atom/defib_ref)
	var/obj/item/defib_item = parent

	if(try_block_attack(target, user))
		return DEFIB_NO_SHOCK

	target.visible_message(
		span_danger("[user] коснул[GEND_SYA_AS_OS_IS(user)] [target.name] [defib_item.declent_ru(INSTRUMENTAL)]!"),
		span_userdanger("[user] коснул[GEND_SYA_AS_OS_IS(user)] вас [defib_item.declent_ru(INSTRUMENTAL)]!"),
	)

	apply_disarm_fibrillate_effects(target)

	playsound(get_turf(defib_ref), 'sound/machines/defib_zap.ogg', 50, TRUE, -1)
	target.emote("gasp")
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
	add_attack_logs(user, target, "Stunned with [parent]")
	target.shock_internal_organs(100)
	set_cooldown(cooldown)

	return DEFIB_SHOCK_SUCCESS

/**
 * Inflict burn damage and potentially trigger a heart attack on someone.
 *
 * Arguments:
 * * user - wielder of the defib
 * * target - person getting shocked
 * * defib_ref - the defibrillator instance
 */
/datum/component/defib/proc/combat_fibrillate(mob/user, mob/living/carbon/human/target, atom/defib_ref)
	var/obj/item/defib_item = parent
	if(!do_after(user, 1 SECONDS * speed_multiplier, target, category = DA_CAT_TOOL))
		return DEFIB_NO_SHOCK

	target.visible_message(
		span_danger("[user] коснул[GEND_SYA_AS_OS_IS(user)] [target.name] [defib_item.declent_ru(INSTRUMENTAL)]!"),
		span_userdanger("[user] коснул[GEND_SYA_AS_OS_IS(user)] вас [defib_item.declent_ru(INSTRUMENTAL)]!"),
	)
	playsound(get_turf(defib_ref), 'sound/machines/defib_charge.ogg', 50, FALSE)

	if(!do_after(user, 2 SECONDS * speed_multiplier, target, category = DA_CAT_TOOL))
		return DEFIB_NO_SHOCK

	var/damage = ignore_hardsuits ? DEFIB_COMBAT_DAMAGE : DEFIB_DAMAGE
	var/obj/item/organ/external/limb_to_hit = target.get_organ(BODY_ZONE_CHEST)
	var/armor = target.run_armor_check(limb_to_hit, MELEE)
	target.apply_damage(damage, BURN, limb_to_hit, armor)

	if(ignore_hardsuits)
		target.Knockdown(5 SECONDS)
	else
		target.Knockdown(3 SECONDS)

	if(prob(heart_attack_chance))
		add_attack_logs(user, target, "Gave a heart attack with [parent]")
		target.set_heartattack(TRUE)

	playsound(get_turf(defib_ref), 'sound/machines/defib_zap.ogg', 50, TRUE, -1)
	target.emote("scream")
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
	add_attack_logs(user, target, "Shocked with [parent]")
	target.shock_internal_organs(100)
	set_cooldown(cooldown)

	return DEFIB_SHOCK_SUCCESS
/*
 * Pass excess shock from a defibrillation into someone else.
 *
 * Arguments:
 * * user - The person using the defib
 * * origin - The person the shock was originally applied to, the person being defibrillated
 * * affecting - The person the shock is spreading to and negatively affecting.
 * * cell_location - item holding the power source.
*/
/datum/component/defib/proc/excess_shock(mob/user, mob/living/origin, mob/living/carbon/human/affecting, obj/item/cell_location)
	if(user == affecting)
		return
	var/power_source
	if(robotic)
		power_source = user
	else
		if(cell_location)
			power_source = locate(/obj/item/stock_parts/cell) in cell_location

	if(!power_source)
		return

	if(electrocute_mob(affecting, power_source, origin)) // shock anyone touching them >:)
		var/obj/item/organ/internal/heart/heart = affecting.get_organ_slot(INTERNAL_ORGAN_HEART)
		if(istype(heart) && heart.parent_organ_zone == BODY_ZONE_CHEST && affecting.has_both_hands()) // making sure the shock will go through their heart (drask hearts are in their head), and that they have both arms so the shock can cross their heart inside their chest
			affecting.visible_message(span_danger("[affecting] сотряса[PLUR_ET_YUT(affecting)]ся от электрического тока, проходящего через [GEND_HIS_HER(affecting)] руку!"), \
							span_userdanger("Вы чувствуете мощный удар током, проходящий через ваше сердце!"))
			affecting.set_heartattack(TRUE)

#undef DEFIB_NO_SHOCK
#undef DEFIB_SHOCK_FAILED
#undef DEFIB_SHOCK_SUCCESS
#undef DEFIB_DAMAGE
#undef DEFIB_COMBAT_DAMAGE
