/**
 * # Slip behaviour component
 *
 * Add this component to an object to make it a slippery object, slippery objects make mobs that cross them fall over.
 * Items with this component that get picked up may give their parent mob the slip behaviour.
 *
 * Here is a simple example of adding the component behaviour to an object.area
 *
 *     AddComponent(/datum/component/slippery, 80, 0, (NO_SLIP_WHEN_WALKING | SLIDE))
 *
 * This adds slippery behaviour to the parent atom, with a 80 decisecond (~8 seconds) weaken
 * The lube flags control how the slip behaves, in this case, the mob wont slip if it's in walking mode (NO_SLIP_WHEN_WALKING)
 * and if they do slip, they will slide a few tiles (SLIDE)
 *
 *
 * This component has configurable behaviours, see the [Initialize proc for the argument listing][/datum/component/slippery/proc/Initialize].
 */
/datum/component/slippery
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// How long the slip keeps the crossing mob weakened
	var/weaken_time = 0
	/// The amount of tiles someone will be moved after slip
	var/slip_tiles
	/// Flags for how slippery the parent is. See [__DEFINES/mobs.dm]
	var/lube_flags
	/// Optional callback allowing you to define custom conditions for slipping
	var/datum/callback/can_slip_callback
	/// Optional call back that is called when a mob slips on this component
	var/datum/callback/on_slip_callback


/**
 * Initialize the slippery component behaviour
 *
 * When applied to any atom in the game this will apply slipping behaviours to that atom
 *
 * Arguments:
 * * weaken - Length of time the weaken applies (Deciseconds)
 * * lube_flags - Controls the slip behaviour, they are listed starting [here][SLIDE]
 * * datum/callback/on_slip_callback - Callback to define further custom controls on when slipping is applied
 * * datum/callback/on_slip_callback - Callback to add custom behaviours as the crossing mob is slipped
 */
/datum/component/slippery/Initialize(
	weaken,
	slip_tiles,
	lube_flags = NONE,
	datum/callback/on_slip_callback,
	datum/callback/can_slip_callback,
)
	src.weaken_time = max(weaken, 0)
	src.slip_tiles = max(0, slip_tiles)
	src.lube_flags = lube_flags
	src.can_slip_callback = can_slip_callback
	src.on_slip_callback = on_slip_callback

/datum/component/slippery/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), PROC_REF(Slip))

/datum/component/slippery/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED))

/datum/component/slippery/Destroy(force)
	can_slip_callback = null
	on_slip_callback = null
	return ..()

/datum/component/slippery/InheritComponent(
	datum/component/slippery/component,
	i_am_original,
	weaken,
	slip_tiles,
	lube_flags = NONE,
	datum/callback/on_slip_callback,
	datum/callback/can_slip_callback,
)
	if(component)
		weaken = component.weaken_time
		slip_tiles = component.slip_tiles
		lube_flags = component.lube_flags
		on_slip_callback = component.on_slip_callback
		can_slip_callback = component.on_slip_callback

	src.weaken_time = max(weaken, 0)
	src.slip_tiles = max(slip_tiles, 0)
	src.lube_flags = lube_flags
	src.on_slip_callback = on_slip_callback
	src.can_slip_callback = can_slip_callback

/**
 * The proc that does the sliping. Invokes the slip callback we have set.
 *
 * Arguments
 * * source - the source of the signal
 * * arrived - the atom/movable that is being slipped.
 */
/datum/component/slippery/proc/Slip(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!isliving(arrived))
		return
	if(lube_flags & SLIPPERY_TURF)
		var/turf/turf = get_turf(source)
		if(HAS_TRAIT(turf, TRAIT_TURF_IGNORE_SLIPPERY))
			return
	var/mob/living/victim = arrived
	if(victim.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return
	if(can_slip_callback && !can_slip_callback.Invoke(parent, victim))
		return
	if(victim.slip(weaken_time, parent, lube_flags, slip_tiles))
		on_slip_callback?.Invoke(victim)
