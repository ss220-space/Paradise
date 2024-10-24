/// Called on [/mob/living/Initialize(mapload)], for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FAKEDEATH), PROC_REF(on_fakedeath_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FAKEDEATH), PROC_REF(on_fakedeath_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(on_immobilized_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_IMMOBILIZED), PROC_REF(on_immobilized_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FLOORED), PROC_REF(on_floored_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FLOORED), PROC_REF(on_floored_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FORCED_STANDING), PROC_REF(on_forced_standing_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FORCED_STANDING), PROC_REF(on_forced_standing_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(on_handsblocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(on_handsblocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_UI_BLOCKED), PROC_REF(on_ui_blocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_UI_BLOCKED), PROC_REF(on_ui_blocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PULL_BLOCKED), PROC_REF(on_pull_blocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PULL_BLOCKED), PROC_REF(on_pull_blocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), PROC_REF(on_incapacitated_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED), PROC_REF(on_incapacitated_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), PROC_REF(on_restrained_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED), PROC_REF(on_restrained_trait_loss))

	RegisterSignal(src, COMSIG_MOVETYPE_FLAG_ENABLED, PROC_REF(on_movement_type_flag_enabled))
	RegisterSignal(src, COMSIG_MOVETYPE_FLAG_DISABLED, PROC_REF(on_movement_type_flag_disabled))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NO_BREATH), PROC_REF(on_no_breath_trait_gain))

	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_IGNORECOLDSLOWDOWN), SIGNAL_REMOVETRAIT(TRAIT_IGNORECOLDSLOWDOWN)), PROC_REF(on_ignore_cold_slowdown))
	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_IGNOREDAMAGESLOWDOWN), SIGNAL_REMOVETRAIT(TRAIT_IGNOREDAMAGESLOWDOWN)), PROC_REF(on_ignore_damage_slowdown))

	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_UNDENSE), SIGNAL_REMOVETRAIT(TRAIT_UNDENSE)), PROC_REF(undense_changed))

	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_NEGATES_GRAVITY), SIGNAL_REMOVETRAIT(TRAIT_NEGATES_GRAVITY)), PROC_REF(on_negate_gravity))
	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_IGNORING_GRAVITY), SIGNAL_REMOVETRAIT(TRAIT_IGNORING_GRAVITY)), PROC_REF(on_ignore_gravity))
	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_FORCED_GRAVITY), SIGNAL_REMOVETRAIT(TRAIT_FORCED_GRAVITY)), PROC_REF(on_force_gravity))
	// We hook for forced grav changes from our turf and ourselves
	var/static/list/loc_connections = list(
		SIGNAL_ADDTRAIT(TRAIT_FORCED_GRAVITY) = PROC_REF(on_loc_force_gravity),
		SIGNAL_REMOVETRAIT(TRAIT_FORCED_GRAVITY) = PROC_REF(on_loc_force_gravity),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/// Called when [TRAIT_KNOCKEDOUT] is added to the mob.
/mob/living/proc/on_knockedout_trait_gain(datum/source)
	SIGNAL_HANDLER

	if(stat < UNCONSCIOUS)
		set_stat(UNCONSCIOUS)


/// Called when [TRAIT_KNOCKEDOUT] is removed from the mob.
/mob/living/proc/on_knockedout_trait_loss(datum/source)
	SIGNAL_HANDLER

	if(stat <= UNCONSCIOUS)
		update_stat("TRAIT_KNOCKEDOUT lost")


/// Called when [TRAIT_FAKEDEATH] is added to the mob.
/mob/living/proc/on_fakedeath_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_KNOCKEDOUT, TRAIT_FAKEDEATH)


/// Called when [TRAIT_FAKEDEATH] is removed from the mob.
/mob/living/proc/on_fakedeath_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, TRAIT_FAKEDEATH)


/// Called when [TRAIT_IMMOBILIZED] is added to the mob.
/mob/living/proc/on_immobilized_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~MOBILITY_MOVE


/// Called when [TRAIT_IMMOBILIZED] is removed from the mob.
/mob/living/proc/on_immobilized_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_MOVE


/// Called when [TRAIT_FLOORED] is added to the mob.
/mob/living/proc/on_floored_trait_gain(datum/source)
	SIGNAL_HANDLER

	if(buckled && buckled.buckle_lying != NO_BUCKLE_LYING)
		return // Handled by the buckle.
	if(HAS_TRAIT(src, TRAIT_FORCED_STANDING))
		return // Don't go horizontal if mob has forced standing trait.
	mobility_flags &= ~MOBILITY_STAND
	on_floored_start()


/// Called when [TRAIT_FLOORED] is removed from the mob.
/mob/living/proc/on_floored_trait_loss(datum/source)
	SIGNAL_HANDLER

	mobility_flags |= MOBILITY_STAND
	on_floored_end()


/// Called when [TRAIT_FORCED_STANDING] is added to the mob.
/mob/living/proc/on_forced_standing_trait_gain(datum/source)
	SIGNAL_HANDLER

	set_body_position(STANDING_UP)


/// Called when [TRAIT_FORCED_STANDING] is removed from the mob.
/mob/living/proc/on_forced_standing_trait_loss(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_FLOORED))
		on_fall()
		set_body_position(LYING_DOWN)
	else if(resting)
		set_lying_on_rest()


/// Called when [TRAIT_HANDS_BLOCKED] is added to the mob.
/mob/living/proc/on_handsblocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_USE|MOBILITY_PICKUP|MOBILITY_STORAGE)
	on_handsblocked_start()


/// Called when [TRAIT_HANDS_BLOCKED] is removed from the mob.
/mob/living/proc/on_handsblocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= (MOBILITY_USE|MOBILITY_PICKUP|MOBILITY_STORAGE)
	on_handsblocked_end()


/// Called when [TRAIT_UI_BLOCKED] is added to the mob.
/mob/living/proc/on_ui_blocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_UI)
	unset_machine()
	update_action_buttons()


/// Called when [TRAIT_UI_BLOCKED] is removed from the mob.
/mob/living/proc/on_ui_blocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_UI
	update_action_buttons()


/// Called when [TRAIT_PULL_BLOCKED] is added to the mob.
/mob/living/proc/on_pull_blocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_PULL)
	if(pulling)
		stop_pulling()

/// Called when [TRAIT_PULL_BLOCKED] is removed from the mob.
/mob/living/proc/on_pull_blocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_PULL


/// Called when [TRAIT_INCAPACITATED] is added to the mob.
/mob/living/proc/on_incapacitated_trait_gain(datum/source)
	SIGNAL_HANDLER
	add_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED), TRAIT_INCAPACITATED)
	//update_appearance()


/// Called when [TRAIT_INCAPACITATED] is removed from the mob.
/mob/living/proc/on_incapacitated_trait_loss(datum/source)
	SIGNAL_HANDLER
	remove_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED), TRAIT_INCAPACITATED)
	//update_appearance()


/// Called when [TRAIT_RESTRAINED] is added to the mob.
/mob/living/proc/on_restrained_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)


/// Called when [TRAIT_RESTRAINED] is removed from the mob.
/mob/living/proc/on_restrained_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)


///From [element/movetype_handler/on_movement_type_trait_gain()]
/mob/living/proc/on_movement_type_flag_enabled(datum/source, flag, old_movement_type)
	SIGNAL_HANDLER
	update_movespeed()


///From [element/movetype_handler/on_movement_type_trait_loss()]
/mob/living/proc/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	SIGNAL_HANDLER
	update_movespeed()


/// Called when [TRAIT_NEGATES_GRAVITY] is gained or lost
/mob/living/proc/on_negate_gravity(datum/source)
	SIGNAL_HANDLER
	if(!isgroundlessturf(loc))
		if(HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
			ADD_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)
		else
			REMOVE_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)


/// Called when [TRAIT_IGNORING_GRAVITY] is gained or lost
/mob/living/proc/on_ignore_gravity(datum/source)
	SIGNAL_HANDLER
	refresh_gravity()


/// Called when [TRAIT_FORCED_GRAVITY] is gained or lost
/mob/living/proc/on_force_gravity(datum/source)
	SIGNAL_HANDLER
	refresh_gravity()


/// Called when our loc's [TRAIT_FORCED_GRAVITY] is gained or lost
/mob/living/proc/on_loc_force_gravity(datum/source)
	SIGNAL_HANDLER
	refresh_gravity()


/// Called when [TRAIT_UNDENSE] is gained or lost
/mob/living/proc/undense_changed(datum/source)
	SIGNAL_HANDLER
	if(HAS_TRAIT(src, TRAIT_UNDENSE))
		set_density(FALSE)
	else
		set_density(TRUE)


/// Called when [TRAIT_NO_BREATH] is gained or lost
/mob/living/proc/on_no_breath_trait_gain(datum/source)
	SIGNAL_HANDLER

	setOxyLoss(0)

	clear_alert(ALERT_TOO_MUCH_OXYGEN)
	clear_alert(ALERT_NOT_ENOUGH_OXYGEN)

	clear_alert(ALERT_TOO_MUCH_TOX)
	clear_alert(ALERT_NOT_ENOUGH_TOX)

	clear_alert(ALERT_TOO_MUCH_NITRO)
	clear_alert(ALERT_NOT_ENOUGH_NITRO)

	clear_alert(ALERT_TOO_MUCH_CO2)
	clear_alert(ALERT_NOT_ENOUGH_CO2)

	clear_alert(ALERT_TOO_MUCH_N2O)
	clear_alert(ALERT_NOT_ENOUGH_N2O)


/// Called when [TRAIT_IGNOREDAMAGESLOWDOWN] is gained or lost
/mob/living/proc/on_ignore_damage_slowdown(datum/source)
	SIGNAL_HANDLER
	update_movespeed_damage_modifiers()

/mob/living/proc/on_ignore_cold_slowdown(datum/source)
	SIGNAL_HANDLER
	update_movespeed_damage_modifiers()
