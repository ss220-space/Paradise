/**
 * Gun misfire component
 */
/datum/element/misfire_weapon
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Maximal misfire chance
	var/misfire_max_chance
	/// Shots after gun begin misfiring from 0 to max
	var/misfire_low_bound
	/// Shots after gun begin misfiring with max chance
	var/misfire_high_bound

/datum/element/misfire_weapon/Attach(datum/target, misfire_max_chance, misfire_low_bound, misfire_high_bound)
	. = ..()

	if(!isgun(target))
		return ELEMENT_INCOMPATIBLE

	src.misfire_max_chance = misfire_max_chance
	src.misfire_low_bound = misfire_low_bound
	src.misfire_high_bound = misfire_high_bound
	RegisterSignal(target, COMSIG_GUN_FIRED, PROC_REF(before_process_fire))

/datum/element/misfire_weapon/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_GUN_FIRED)

/datum/element/misfire_weapon/proc/before_process_fire(datum/source, mob/living/user, atom/target)
	SIGNAL_HANDLER
	var/obj/item/gun/gun = source

	if(gun.shots_counter < misfire_low_bound)
		return //no misfire

	var/misfire_chance = gun.shots_counter >= misfire_high_bound ? misfire_max_chance : ((gun.shots_counter - misfire_low_bound) / (misfire_high_bound - misfire_low_bound) * misfire_max_chance)
	if(!prob(misfire_chance))
		return

	if(!gun.chambered || !gun.chambered.BB)
		return

	QDEL_NULL(gun.chambered.BB)
	gun.balloon_alert(user, "осечка!")
	playsound(gun, 'sound/weapons/empty.ogg', 100, TRUE)
