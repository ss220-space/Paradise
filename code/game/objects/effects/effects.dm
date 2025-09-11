
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...

/obj/effect
	icon = 'icons/effects/effects.dmi'
	obj_flags = IGNORE_HITS
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF|FREEZE_PROOF
	move_resist = INFINITY
	anchored = TRUE

/obj/effect/add_debris_element() // They're not hittable, and prevents recursions.
	return

/obj/effect/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/obj/effect/singularity_act()
	qdel(src)
	return FALSE

/obj/effect/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	return

/obj/effect/acid_act()
	return

/obj/effect/proc/is_cleanable() //Called when you want to clean something, and usualy delete it after
	return FALSE

/obj/effect/mech_melee_attack(obj/mecha/M)
	return 0

/obj/effect/blob_act(obj/structure/blob/B)
	return

/obj/effect/experience_pressure_difference()
	return

/obj/effect/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(60))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(25))
				qdel(src)


/obj/effect/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	return


/**
 * # The abstract object
 *
 * This is an object that is intended to able to be placed, but that is completely invisible.
 * The object should be immune to all forms of damage, or things that can delete it, such as the singularity, or explosions.
 */
/obj/effect/abstract
	name = "Abstract object"
	invisibility = INVISIBILITY_ABSTRACT
	layer = TURF_LAYER
	density = FALSE
	icon = null
	icon_state = null
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)

// Most of these overrides procs below are overkill, but better safe than sorry.
/obj/effect/abstract/swarmer_act()
	return

/obj/effect/abstract/bullet_act(obj/projectile/P)
	return

/obj/effect/abstract/decompile_act(obj/item/matter_decompiler/C, mob/user)
	return

/obj/effect/abstract/zap_act()
	return

/obj/effect/abstract/singularity_act()
	return

/obj/effect/abstract/get_gravity()
	return

/obj/effect/abstract/narsie_act()
	return

/obj/effect/abstract/ratvar_act()
	return

/obj/effect/abstract/ex_act(severity, target)
	return

/obj/effect/abstract/blob_act()
	return

/obj/effect/abstract/acid_act()
	return

/obj/effect/abstract/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	return

/obj/effect/abstract/get_gravity(turf/gravity_turf)
	return FALSE
