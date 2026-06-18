/// How long it takes from the gunpoint is initiated to reach stage 2
#define GUNPOINT_DELAY_STAGE_2 (2.5 SECONDS)
/// How long it takes from stage 2 starting to move up to stage 3
#define GUNPOINT_DELAY_STAGE_3 (7.5 SECONDS)
/// How much the damage and wound bonus mod is multiplied when you're on stage 1
#define GUNPOINT_MULT_STAGE_1 1.25
/// As above, for stage 2
#define GUNPOINT_MULT_STAGE_2 2
/// As above, for stage 3
#define GUNPOINT_MULT_STAGE_3 2.5
/// Stages defines
#define GUNPOINT_ESCALATE_STAGE_1 1
#define GUNPOINT_ESCALATE_STAGE_2 2
#define GUNPOINT_ESCALATE_STAGE_3 3

/datum/component/gunpoint
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Who we're holding up
	var/mob/living/target
	/// The gun we're holding them up with
	var/obj/item/gun/weapon

	/// Which stage we're on
	var/stage = GUNPOINT_ESCALATE_STAGE_1
	/// How much the damage and wound values will be multiplied by
	var/damage_mult = GUNPOINT_MULT_STAGE_1
	/// If TRUE, we're committed to firing the shot, for async purposes
	var/point_of_no_return = FALSE

/datum/component/gunpoint/Initialize(mob/living/targ, obj/item/gun/wep)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/shooter = parent
	target = targ
	weapon = wep

	var/distance = max(get_dist(shooter, target), 1)
	var/distance_description = (distance <= 1 ? "в упор" : "")

	shooter.visible_message(
		span_danger("[shooter] [distance_description] нацелил[GEND_A_O_I(shooter)] [weapon.declent_ru(ACCUSATIVE)] на [target.declent_ru(ACCUSATIVE)]!"), \
		span_danger("Вы [distance_description] нацелили [weapon.declent_ru(ACCUSATIVE)] на [target.declent_ru(ACCUSATIVE)]!"), \
		ignored_mobs = target
	)
	to_chat(target, span_userdanger("[shooter] [distance_description] нацелил[GEND_A_O_I(shooter)] на вас [weapon.declent_ru(ACCUSATIVE)]!"))

	if(shooter.a_intent == INTENT_HELP)
		shooter.Immobilize(0.75 SECONDS / distance)

	shooter.apply_status_effect(/datum/status_effect/holdup, shooter)
	target.apply_status_effect(/datum/status_effect/grouped/heldup, shooter.UID())
	do_alert_animation(target)
	playsound(target.loc, 'sound/machines/chime.ogg', 50, TRUE)

	addtimer(CALLBACK(src, PROC_REF(update_stage), GUNPOINT_ESCALATE_STAGE_2), GUNPOINT_DELAY_STAGE_2)

	check_and_award_achievements(shooter)

/datum/component/gunpoint/Destroy(force)
	var/mob/living/shooter = parent
	if(shooter)
		shooter.remove_status_effect(/datum/status_effect/holdup)
	if(target)
		target.remove_status_effect(/datum/status_effect/grouped/heldup, shooter.UID())
		target = null
	weapon = null
	return ..()

/datum/component/gunpoint/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_UPDATE_SIGHT), PROC_REF(check_deescalate))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(flinch))
	RegisterSignals(parent, list(COMSIG_LIVING_START_PULL, COMSIG_MOVABLE_BUMP), PROC_REF(check_bump))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_HUMAN_DISARM_HIT, PROC_REF(trigger_reaction))
	RegisterSignals(parent, list(COMSIG_LIVING_GUNPOINT_CANCEL, COMSIG_MOB_FIRED_GUN), PROC_REF(cancel))
	RegisterSignal(parent, COMSIG_LIVING_GUNPOINT_START, PROC_REF(block_duplicate_gunpoint))

	RegisterSignals(target, list(
		COMSIG_MOB_FIRED_GUN,
		COMSIG_LIVING_START_PULL,
		COMSIG_MOB_ITEM_ATTACK), PROC_REF(trigger_reaction))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(examine_target))
	RegisterSignals(target, list(COMSIG_QDELETING, COMSIG_LIVING_GUNPOINT_CANCEL), PROC_REF(cancel))
	RegisterSignal(target, COMSIG_LIVING_GUNPOINT_START, PROC_REF(block_duplicate_gunpoint))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(check_special_conditions_before_trigger))

	RegisterSignals(weapon, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED, COMSIG_QDELETING), PROC_REF(cancel))

/datum/component/gunpoint/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_MOB_UPDATE_SIGHT,
		COMSIG_LIVING_START_PULL,
		COMSIG_MOVABLE_BUMP,
		COMSIG_ATOM_EXAMINE,
		COMSIG_MOB_ATTACK_HAND,
		COMSIG_HUMAN_DISARM_HIT,
		COMSIG_LIVING_GUNPOINT_CANCEL,
		COMSIG_LIVING_GUNPOINT_START,
	))

	if(target)
		UnregisterSignal(target, list(
			COMSIG_MOVABLE_MOVED,
			COMSIG_MOB_FIRED_GUN,
			COMSIG_LIVING_START_PULL,
			COMSIG_MOB_ITEM_ATTACK,
			COMSIG_ATOM_EXAMINE,
			COMSIG_QDELETING,
			COMSIG_LIVING_GUNPOINT_START,
			COMSIG_LIVING_GUNPOINT_CANCEL,
		))

	if(weapon)
		UnregisterSignal(weapon, list(
			COMSIG_ITEM_DROPPED,
			COMSIG_ITEM_EQUIPPED,
			COMSIG_QDELETING,
		))

///If the shooter bumps the target, cancel the holdup to avoid cheesing and forcing the charged shot
/datum/component/gunpoint/proc/check_bump(datum/source, atom/bumped_atom)
	SIGNAL_HANDLER

	if(bumped_atom != target)
		return
	var/mob/living/shooter = parent
	shooter.visible_message(
		span_danger("[shooter] врезал[GEND_SYA_AS_OS_IS(shooter)] в [target.declent_ru(ACCUSATIVE)] и сбил[GEND_A_O_I(shooter)] себе прицел!"), \
		span_danger("Вы врезались в [target.declent_ru(ACCUSATIVE)] и сбили себе прицел!"), \
		ignored_mobs = target
	)
	to_chat(target, span_userdanger("[shooter] врезал[GEND_SYA_AS_OS_IS(shooter)] в вас и сбил[GEND_A_O_I(shooter)] себе прицел!"))
	qdel(src)

///Update the damage multiplier for whatever stage we're entering into
/datum/component/gunpoint/proc/update_stage(new_stage)
	var/mob/living/shooter = parent
	if(check_deescalate())
		return
	stage = new_stage
	if(stage == GUNPOINT_ESCALATE_STAGE_2)
		to_chat(shooter, span_danger("Вы наставили [weapon.declent_ru(ACCUSATIVE)] на [target.declent_ru(ACCUSATIVE)]."))
		to_chat(target, span_userdanger("[shooter] наставил[GEND_A_O_I(shooter)] [weapon.declent_ru(ACCUSATIVE)] на вас!"))
		damage_mult = GUNPOINT_MULT_STAGE_2
		addtimer(CALLBACK(src, PROC_REF(update_stage), GUNPOINT_ESCALATE_STAGE_3), GUNPOINT_DELAY_STAGE_3)
	else if(stage == GUNPOINT_ESCALATE_STAGE_3)
		to_chat(shooter, span_danger("Вы намертво зафиксировали прицел [weapon.declent_ru(GENITIVE)] на [target.declent_ru(PREPOSITIONAL)]."))
		to_chat(target, span_userdanger("[shooter] намертво зафиксировал[GEND_A_O_I(shooter)] прицел [weapon.declent_ru(GENITIVE)] на вас!"))
		damage_mult = GUNPOINT_MULT_STAGE_3

///Cancel the holdup if the shooter moves out of sight or out of range of the target
/datum/component/gunpoint/proc/check_deescalate()
	SIGNAL_HANDLER

	if(!parent || !target || !can_line(parent, target, GUNPOINT_SHOOTER_STRAY_RANGE))
		cancel()
		return TRUE

///Bang bang, we're firing a charged shot off
/datum/component/gunpoint/proc/trigger_reaction()
	SIGNAL_HANDLER

	if(target && target.has_status_effect(STATUS_EFFECT_CAPITULATED))
		return FALSE

	INVOKE_ASYNC(src, PROC_REF(async_trigger_reaction))
	return TRUE

/// Check special conditions (e.g. walk intent) and only after trigger reaction
/datum/component/gunpoint/proc/check_special_conditions_before_trigger()
	SIGNAL_HANDLER

	if(!target)
		return FALSE

	// If target walk and not run, don't shoot and escort it
	if(target.m_intent == MOVE_INTENT_WALK && !target.pulledby)
		return FALSE

	trigger_reaction()

/datum/component/gunpoint/proc/async_trigger_reaction()
	var/mob/living/shooter = parent

	if(!shooter || !target || !weapon)
		return

	shooter.remove_status_effect(/datum/status_effect/holdup)
	target.remove_status_effect(/datum/status_effect/grouped/heldup, shooter.UID())

	if(point_of_no_return)
		return
	point_of_no_return = TRUE

	if(weapon.chambered && weapon.chambered.BB)
		weapon.chambered.BB.damage *= damage_mult
		weapon.chambered.BB.forced_accuracy = TRUE

	var/def_zone = null

	if(ishuman(shooter))
		var/mob/living/carbon/human/H_shooter = shooter
		def_zone = H_shooter.zone_selected

	var/fired = weapon.fast_fire(target, shooter, def_zone)

	if(!fired)
		if(weapon.chambered && weapon.chambered.BB)
			weapon.chambered.BB.damage /= damage_mult
			weapon.chambered.BB.forced_accuracy = FALSE

	qdel(src)

///Shooter canceled their shot, either by dropping/equipping their weapon, leaving sight/range, or clicking on the alert
/datum/component/gunpoint/proc/cancel()
	SIGNAL_HANDLER

	var/mob/living/shooter = parent
	if(shooter && weapon && target)
		shooter.visible_message(
			span_danger("[shooter] опустил[GEND_A_O_I(shooter)] [weapon.declent_ru(ACCUSATIVE)] и больше не целится в [target.declent_ru(ACCUSATIVE)]!"), \
			span_danger("Вы больше не целитесь из [weapon.declent_ru(GENITIVE)] в [target.declent_ru(ACCUSATIVE)]."), \
			ignored_mobs = target
		)
		to_chat(target, span_userdanger("[shooter] опустил[GEND_A_O_I(shooter)] [weapon.declent_ru(ACCUSATIVE)] и больше не целится в вас!"))

	qdel(src)

///If the shooter is hit by an attack, they have a 50% chance to flinch and fire. If it hit the arm holding the trigger, it's an 80% chance to fire instead
/datum/component/gunpoint/proc/flinch(mob/living/source, damage_amount, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	var/flinch_chance = 50

	if(iscarbon(source))
		var/mob/living/carbon/carbon_source = source
		var/obj/item/held_hand = carbon_source.is_in_hands(weapon)

		if(held_hand && def_zone == ((held_hand == source.l_hand) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM))
			flinch_chance = 80

	if(prob(flinch_chance))
		source.visible_message(
			span_danger("[source] вздрагивает от боли!"),
			span_danger("Вы вздрагиваете от боли!"),
		)
		INVOKE_ASYNC(src, PROC_REF(trigger_reaction))

///Shows if the parent is holding someone at gunpoint
/datum/component/gunpoint/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mob/living/shooter = parent
	if(user in viewers(target))
		examine_list += span_boldwarning("[shooter] держ[PLUR_IT_AT(shooter)] [target] на мушке [weapon.declent_ru(GENITIVE)]!")

///Shows if the examine target is being held at gunpoint
/datum/component/gunpoint/proc/examine_target(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mob/living/shooter = parent
	if(user in viewers(parent))
		examine_list += span_boldwarning("[target] на мушке у [shooter]!")

/datum/component/gunpoint/proc/block_duplicate_gunpoint(mob/living/source)
	SIGNAL_HANDLER

	return COMPONENT_LIVING_ALREADY_HELD_UP

/// Achievements time
/datum/component/gunpoint/proc/check_and_award_achievements(mob/living/shooter)
	if(!shooter || !shooter.client || !target || !target.client)
		return
	var/turf/shooter_turf = get_turf(shooter)
	if(!shooter_turf || is_admin_level(shooter_turf.z))
		return

	if(istype(weapon, /obj/item/gun/projectile/revolver/rocketlauncher) && weapon.chambered)
		if(target.stat == CONSCIOUS && shooter.mind.has_antag_datum(/datum/antagonist/nuclear_operative) && !target.mind.has_antag_datum(/datum/antagonist/nuclear_operative))
			if(locate(/obj/item/disk/nuclear) in target.get_contents())
				target.client.give_award(/datum/award/achievement/misc/rocket_holdup, target)
				return

#undef GUNPOINT_DELAY_STAGE_2
#undef GUNPOINT_DELAY_STAGE_3
#undef GUNPOINT_MULT_STAGE_1
#undef GUNPOINT_MULT_STAGE_2
#undef GUNPOINT_MULT_STAGE_3
#undef GUNPOINT_ESCALATE_STAGE_1
#undef GUNPOINT_ESCALATE_STAGE_2
#undef GUNPOINT_ESCALATE_STAGE_3
