/**
 * A component for an item that attempts to defibrillate a mob when activated.
 */
/datum/component/defib
	/// If this is being used by a borg or not, with necessary safeties applied if so.
	var/robotic
	/// If it should penetrate space suits
	var/ignore_hardsuits
	/// If ignore_hardsuits is true, this determines whether or not it should always cause a heart attack.
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
/datum/component/defib/Initialize(robotic, cooldown = 5 SECONDS, speed_multiplier = 1, ignore_hardsuits = FALSE, heart_attack_chance = 100, safe_by_default = TRUE, emp_proof = FALSE, emag_proof = FALSE, obj/item/actual_unit = null)
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
		unit.visible_message(span_warning("[unit] beeps: Safety protocols disabled!"))
		playsound(get_turf(unit), 'sound/machines/defib_saftyoff.ogg', 50, 0)
	else
		safety = TRUE
		unit.visible_message(span_notice("[unit] beeps: Safety protocols enabled!"))
		playsound(get_turf(unit), 'sound/machines/defib_saftyon.ogg', 50, 0)

/datum/component/defib/proc/on_emag(obj/item/unit, mob/user)
	SIGNAL_HANDLER  // COMSIG_ATOM_EMAG_ACT
	if(emag_proof)
		return
	safety = !safety
	if(user && !robotic)
		user.balloon_alert(user, "протоколы безопасности [safety ? "де" : ""]активированы!")

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
	// This includes some do-afters, so we have to pass it off asynchronously
	INVOKE_ASYNC(src, PROC_REF(defibrillate), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Perform a defibrillation.
 */
/datum/component/defib/proc/defibrillate(mob/living/user, mob/living/carbon/human/target)
	// Before we do all the hard work, make sure we aren't already defibbing someone
	if(busy)
		return

	var/parent_unit = locateUID(actual_unit_uid)
	var/should_cause_harm = user.a_intent == INTENT_HARM && !safety

	// Find what the defib should be referring to itself as
	var/atom/defib_ref
	if(parent_unit)
		defib_ref = parent_unit
	else if(robotic)
		defib_ref = user
	if(!defib_ref) // Contingency
		defib_ref = parent

	// check what the unit itself has to say about how the defib went
	var/application_result = SEND_SIGNAL(parent, COMSIG_DEFIB_PADDLES_APPLIED, user, target, should_cause_harm)

	if(application_result & COMPONENT_BLOCK_DEFIB_DEAD)
		user.visible_message(span_notice("[defib_ref] beeps: Unit is unpowered."))
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
		return

	if(on_cooldown)
		user.balloon_alert(user, "всё ещё заряжается!")
		return

	if(application_result & COMPONENT_BLOCK_DEFIB_MISC)
		return  // the unit should handle this

	if(!istype(target))
		if(robotic)
			user.balloon_alert(user, "на роботах не сработает")
		else
			user.balloon_alert(user, "\"это\" нельзя дефибриллировать")
		return

	if(should_cause_harm)
		combat_fibrillate(user, target)
		SEND_SIGNAL(parent, COMSIG_DEFIB_SHOCK_APPLIED, user, target, should_cause_harm, TRUE)
		busy = FALSE
		return

	user.visible_message(
		span_warning("[user] begins to place [parent] on [target.name]'s chest."),
		span_warning("You begin to place [parent] on [target.name]'s chest."),
	)

	busy = TRUE
	var/mob/dead/observer/ghost = target.get_ghost(TRUE)
	if(ghost?.can_reenter_corpse)
		to_chat(ghost, "[span_ghostalert("Your heart is being defibrillated. Return to your body if you want to be revived!")] (Verbs -> Ghost -> Re-enter corpse)")
		window_flash(ghost.client)
		SEND_SOUND(ghost, sound('sound/effects/genetics.ogg'))

	if(!do_after(user, 3 SECONDS * speed_multiplier, target, category = DA_CAT_TOOL)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
		busy = FALSE
		return

	user.visible_message(
		span_notice("[user] places [parent] on [target.name]'s chest."),
		span_warning("You place [parent] on [target.name]'s chest."),
	)
	playsound(get_turf(defib_ref), 'sound/machines/defib_charge.ogg', 50, 0)

	if(ghost && !ghost.client && !QDELETED(ghost))
		log_debug("Ghost of name [ghost.name] is bound to [target.real_name], but lacks a client. Deleting ghost.")
		QDEL_NULL(ghost)

	if(!do_after(user, 2 SECONDS * speed_multiplier, target, category = DA_CAT_TOOL)) //placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
		busy = FALSE
		return

	if(istype(target.wear_suit, /obj/item/clothing/suit/space) && !ignore_hardsuits)
		user.visible_message(span_notice("[defib_ref] buzzes: Patient's chest is obscured. Operation aborted."))
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
		busy = FALSE
		return


	if(target.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = target.get_organ_slot(INTERNAL_ORGAN_HEART)
		if(!heart)
			user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed - Failed to pick up any heart electrical activity."))
		else if(heart.is_dead())
			user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed - Heart necrosis detected."))
		if(!heart || heart.is_dead())
			playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
			busy = FALSE
			return

		target.set_heartattack(FALSE)
		SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
		SEND_SIGNAL(parent, COMSIG_DEFIB_SHOCK_APPLIED, user, target, should_cause_harm, TRUE)
		set_cooldown(cooldown)
		user.visible_message(span_boldnotice("[defib_ref] pings: Cardiac arrhythmia corrected."))
		target.visible_message(span_warning("[target]'s body convulses a bit."), span_userdanger("You feel a jolt, and your heartbeat seems to steady."))
		playsound(get_turf(defib_ref), 'sound/machines/defib_zap.ogg', 50, 1, -1)
		playsound(get_turf(defib_ref), "bodyfall", 50, 1)
		playsound(get_turf(defib_ref), 'sound/machines/defib_success.ogg', 50, 0)
		target.shock_internal_organs(100)
		busy = FALSE
		return

	if(target.stat != DEAD && !HAS_TRAIT(target, TRAIT_FAKEDEATH))
		user.visible_message(span_notice("[defib_ref] buzzes: Patient is not in a valid state. Operation aborted."))
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
		busy = FALSE
		return

	target.visible_message(span_warning("[target]'s body convulses a bit."))
	playsound(get_turf(defib_ref), "bodyfall", 50, 1)
	playsound(get_turf(defib_ref), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	ghost = target.get_ghost(TRUE) // We have to double check whether the dead guy has entered their body during the above

	var/defib_success = TRUE

	// Run through some quick failure states after shocking.
	var/time_dead = world.time - target.timeofdeath

	if((time_dead > DEFIB_TIME_LIMIT) || !target.get_organ_slot(INTERNAL_ORGAN_HEART))
		user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed - Heart tissue damage beyond point of no return for defibrillation."))
		defib_success = FALSE
	else if(target.getBruteLoss() >= 180 || target.getFireLoss() >= 180 || target.getCloneLoss() >= 180)
		user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed - Severe tissue damage detected."))
		defib_success = FALSE
	else if(target.blood_volume < BLOOD_VOLUME_SURVIVE)
		user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed - Patient blood volume critically low."))
		defib_success = FALSE
	else if(!target.get_organ_slot(INTERNAL_ORGAN_BRAIN))  //So things like headless clings don't get outed
		user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed - No brain detected within patient."))
		defib_success = FALSE
	else if(ghost)
		if(!ghost.can_reenter_corpse || target.suiciding) // DNR or AntagHUD
			user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed - No electrical brain activity detected."))
		else
			user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed - Patient's brain is unresponsive. Further attempts may succeed."))
		defib_success = FALSE
	else if(HAS_TRAIT(target, TRAIT_NO_CLONE) || !target.mind || !(target.mind.is_revivable()) || HAS_TRAIT(target, TRAIT_FAKEDEATH) || target.suiciding)  // these are a bit more arbitrary
		user.visible_message(span_boldnotice("[defib_ref] buzzes: Resuscitation failed."))
		defib_success = FALSE

	if(!defib_success)
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
	else
		// Heal oxy and tox damage type by as much as we're under -100 health
		var/damage_above_threshold = -(min(target.health, HEALTH_THRESHOLD_DEAD) - HEALTH_THRESHOLD_DEAD)
		var/heal_amount = damage_above_threshold + 5
		target.heal_damages(tox = heal_amount, oxy = heal_amount)

		// Inflict some brain damage scaling with time spent dead
		var/defib_time_brain_damage = min(100 * time_dead / DEFIB_TIME_LIMIT, 99) // 20 from 1 minute onward, +20 per minute up to 99
		if(time_dead > DEFIB_TIME_LOSS && defib_time_brain_damage > target.getBrainLoss())
			target.setBrainLoss(defib_time_brain_damage)

		target.update_revive(TRUE, TRUE)
		target.Paralyse(12 SECONDS)
		target.emote("gasp")

		if(target.getBrainLoss() >= 100)
			playsound(get_turf(defib_ref), 'sound/machines/defib_saftyoff.ogg', 50, 0)
			user.visible_message(span_boldnotice("[defib_ref] chimes: Minimal brain activity detected, brain treatment recommended for full resuscitation."))
		else
			playsound(get_turf(defib_ref), 'sound/machines/defib_success.ogg', 50, 0)
		user.visible_message(span_boldnotice("[defib_ref] pings: Resuscitation successful."))

		SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
		if(ishuman(target.pulledby)) // for some reason, pulledby isnt a list despite it being possible to be pulled by multiple people
			excess_shock(user, target, target.pulledby, defib_ref)

		target.med_hud_set_health()
		target.med_hud_set_status()
		target.shock_internal_organs(100)
		SEND_SIGNAL(parent, COMSIG_DEFIB_SHOCK_APPLIED, user, target, should_cause_harm, TRUE)
		add_attack_logs(user, target, "Revived with [defib_ref]")
		SSblackbox.record_feedback("tally", "players_revived", 1, "defibrillator")
	SEND_SIGNAL(parent, COMSIG_DEFIB_SHOCK_APPLIED, user, target, should_cause_harm, defib_success)
	set_cooldown(cooldown)
	busy = FALSE

/**
 * Inflict stamina loss (and possibly inflict cardiac arrest) on someone.
 *
 * Arguments:
 * * user - wielder of the defib
 * * target - person getting shocked
 */
/datum/component/defib/proc/combat_fibrillate(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return
	busy = TRUE
	target.visible_message(
		span_danger("[user] has touched [target.name] with [parent]!"),
		span_userdanger("[user] has touched [target.name] with [parent]!"),
	)
	target.apply_damage(50, STAMINA)
	target.Weaken(4 SECONDS)
	playsound(get_turf(parent), 'sound/machines/defib_zap.ogg', 50, TRUE, -1)
	target.emote("gasp")
	if(prob(heart_attack_chance))
		add_attack_logs(user, target, "Gave a heart attack with [parent]")
		target.set_heartattack(TRUE)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
	add_attack_logs(user, target, "Stunned with [parent]")
	target.shock_internal_organs(100)
	set_cooldown(cooldown)
	busy = FALSE

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
			affecting.visible_message(span_danger("[affecting]'s entire body shakes as a shock travels up [affecting.p_their()] arm!"), \
							span_userdanger("You feel a powerful shock travel up your [affecting.hand ? affecting.get_organ(BODY_ZONE_L_ARM) : affecting.get_organ(BODY_ZONE_R_ARM)] and back down your [affecting.hand ? affecting.get_organ(BODY_ZONE_R_ARM) : affecting.get_organ(BODY_ZONE_L_ARM)]!"))
			affecting.set_heartattack(TRUE)

