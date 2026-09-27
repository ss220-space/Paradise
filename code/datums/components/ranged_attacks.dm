/datum/component/ranged_attacks
	var/casing_type
	var/projectile_type
	var/projectile_sound
	var/burst_shots
	var/burst_intervals
	var/cooldown_time
	COOLDOWN_DECLARE(fire_cooldown)

/datum/component/ranged_attacks/Initialize(casing_type, projectile_type, projectile_sound, burst_shots = 1, burst_intervals = 0.2 SECONDS, cooldown_time = 3 SECONDS)
	if(!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE

	if(casing_type && projectile_type)
		CRASH("Set both casing type and projectile type in [parent]'s ranged attacks component!")
	if(!casing_type && !projectile_type)
		CRASH("Set neither casing type nor projectile type in [parent]'s ranged attacks component!")

	src.casing_type = casing_type
	src.projectile_type = projectile_type
	src.projectile_sound = projectile_sound
	src.burst_shots = burst_shots
	src.burst_intervals = burst_intervals
	src.cooldown_time = cooldown_time

/datum/component/ranged_attacks/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ATTACK_RANGED, PROC_REF(fire_ranged_attack))

/datum/component/ranged_attacks/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ATTACK_RANGED)

/datum/component/ranged_attacks/proc/fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, fire_cooldown))
		return

	COOLDOWN_START(src, fire_cooldown, cooldown_time)
	INVOKE_ASYNC(src, PROC_REF(async_fire_ranged_attack), target)
	for(var/shot in 1 to burst_shots - 1)
		addtimer(CALLBACK(src, PROC_REF(async_fire_ranged_attack), target), shot * burst_intervals, TIMER_DELETE_ME)

/datum/component/ranged_attacks/proc/async_fire_ranged_attack(atom/target)
	var/mob/living/basic/firer = parent
	if(QDELETED(target) || firer.stat != CONSCIOUS)
		return

	var/turf/startloc = get_turf(firer)
	playsound(firer, projectile_sound, 100, TRUE)

	if(casing_type)
		var/obj/item/ammo_casing/casing = new casing_type(startloc)
		casing.fire(target, firer, zone_override = ran_zone(), firer_source_atom = firer)
		casing.after_fire()
		return

	var/obj/projectile/bullet = new projectile_type(startloc)
	bullet.starting = startloc
	bullet.firer = firer
	bullet.firer_source_atom = firer
	bullet.original = target
	bullet.preparePixelProjectile(target, firer)
	bullet.fire()
