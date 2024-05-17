/// Called on [/mob/living/Initialize(mapload)], for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(on_handsblocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(on_handsblocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), PROC_REF(on_restrained_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED), PROC_REF(on_restrained_trait_loss))


	RegisterSignal(src, COMSIG_MOVETYPE_FLAG_ENABLED, PROC_REF(on_movement_type_flag_enabled))
	RegisterSignal(src, COMSIG_MOVETYPE_FLAG_DISABLED, PROC_REF(on_movement_type_flag_disabled))

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
	update_density()

