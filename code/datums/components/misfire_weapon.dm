/**
 * Gun misfire component
 */
/datum/component/misfire_weapon
	/// Maximal misfire chance
	var/misfire_max_chance
	/// Shots after gun begin misfiring from 0 to max
	var/misfire_low_bound
	/// Shots after gun begin misfiring with max chance
	var/misfire_high_bound
	/// Fires counter
	var/fire_counter = 0

/datum/component/misfire_weapon/Initialize(misfire_max_chance = 25, misfire_low_bound = 50, misfire_high_bound = 300)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	src.misfire_max_chance = misfire_max_chance
	src.misfire_low_bound = misfire_low_bound
	src.misfire_high_bound = misfire_high_bound

/datum/component/misfire_weapon/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_GUN_FIRED, PROC_REF(before_process_fire))

/datum/component/misfire_weapon/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_GUN_FIRED)

/datum/component/misfire_weapon/proc/before_process_fire(datum/source, mob/living/user, atom/target)
	var/obj/item/gun/gun = parent
	fire_counter += gun.burst_size
	if(fire_counter < misfire_low_bound)
		return //no misfire
	var/misfire_chance = fire_counter >= misfire_high_bound ? misfire_max_chance : ((fire_counter - misfire_low_bound) / (misfire_high_bound - misfire_low_bound) * misfire_max_chance)
	if(!prob(misfire_chance))
		return
	if(!gun.chambered || !gun.chambered.BB)
		return
	QDEL_NULL(gun.chambered.BB)
	gun.balloon_alert(user, "осечка!")
