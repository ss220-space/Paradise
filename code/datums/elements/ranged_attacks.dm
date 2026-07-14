//Bee edit: This was included in the basic mobs port, but we don't have glockroach so it is kept here in case we find an alternative or actually need it.

///This proc is used by basic mobs to give them a simple ranged attack! In theory this could be extended to
/datum/element/ranged_attacks
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/casingtype = /obj/item/ammo_casing/caseless/glockroach
	var/projectilesound = 'sound/weapons/gunshots/gunshot3.ogg'
	var/projectiletype

/datum/element/ranged_attacks/Attach(atom/movable/target, casingtype, projectilesound, projectiletype)
	. = ..()
	if(!isbasicmob(target))
		return COMPONENT_INCOMPATIBLE

	src.casingtype = casingtype
	src.projectilesound = projectilesound
	src.projectiletype = projectiletype

	RegisterSignal(target, COMSIG_MOB_ATTACK_RANGED, PROC_REF(fire_ranged_attack))

	if(casingtype && projectiletype)
		CRASH("Set both casing type and projectile type in [target]'s ranged attacks element! uhoh! stinky!")

/datum/element/ranged_attacks/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOB_ATTACK_RANGED)
	return ..()

/datum/element/ranged_attacks/proc/fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(async_fire_ranged_attack), firer, target, modifiers)

/datum/element/ranged_attacks/proc/async_fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	var/turf/startloc = get_turf(firer)

	if(casingtype)
		var/obj/item/ammo_casing/casing = new casingtype(startloc)
		playsound(firer, projectilesound, 100)
		casing.fire(target, firer, modifiers = null, distro = null, quiet = FALSE, zone_override = ran_zone(), firer_source_atom = firer)
		casing.after_fire()

	else if(projectiletype)
		var/obj/projectile/projectile = new projectiletype(startloc)
		playsound(firer, projectilesound, 100)
		projectile.starting = startloc
		projectile.firer = firer
		projectile.firer_source_atom = firer
		projectile.yo = target.y - startloc.y
		projectile.xo = target.x - startloc.x
		projectile.original = target
		projectile.preparePixelProjectile(target, firer)
		projectile.fire()
