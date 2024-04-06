/**
  * # Slip Component
  *
  * This is a component that can be applied to any movable atom (mob or obj).
  *
  * While the atom has this component, any human mob that walks over it will have a chance to slip.
  * Duration, tiles moved, and so on, depend on what variables are passed in when the component is added.
  *
  */
/datum/component/slippery
	/// Text that gets displayed in the slip proc, i.e. "user slips on [description]"
	var/description
	/// The amount of weaken to apply after slip.
	var/weaken
	/// The chance that walking over the parent will slip you.
	var/slip_chance
	/// The amount of tiles someone will be moved after slip.
	var/slip_tiles
	/// TRUE If this slip can be avoided by walking.
	var/walking_is_safe
	/// TRUE if you want slip shoes to make you immune to the slip
	var/magic_slip
	/// TRUE if it is a lube slip
	var/lube_slip
	/// FALSE if you want no slip without gravity
	var/gravi_ignore
	/// The verb that players will see when someone slips on the parent. In the form of "You [slip_verb]ped on".
	var/slip_verb

/datum/component/slippery/Initialize(description, weaken = 0, slip_chance = 100, slip_tiles = 0, walking_is_safe = TRUE, magic_slip = FALSE, lube_slip = FALSE, gravi_ignore = FALSE, slip_verb = "slip")
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.description = description
	src.weaken = max(0, weaken)
	src.slip_chance = max(0, slip_chance)
	src.slip_tiles = max(0, slip_tiles)
	src.walking_is_safe = walking_is_safe
	src.magic_slip = magic_slip
	src.lube_slip = lube_slip
	src.gravi_ignore = gravi_ignore
	src.slip_verb = slip_verb

/datum/component/slippery/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), PROC_REF(Slip))

/datum/component/slippery/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED))

/**
	Called whenever the parent recieves either the `MOVABLE_CROSSED` signal or the `ATOM_ENTERED` signal.

	Calls the `victim`'s `slip()` proc with the component's variables as arguments.
	Additionally calls the parent's `after_slip()` proc on the `victim`.
*/
/datum/component/slippery/proc/Slip(datum/source, mob/living/carbon/human/victim)
	if(istype(victim) && !(!magic_slip && victim.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) && prob(slip_chance) && victim.slip(description, weaken, slip_tiles, walking_is_safe, magic_slip, lube_slip, gravi_ignore, slip_verb))
		var/atom/movable/owner = parent
		owner.after_slip(victim)
