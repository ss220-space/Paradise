/obj/effect/cosmic_diamond
	name = "Cosmic Diamond"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_diamond"


/obj/effect/temp_visual/cosmic_cloud
	name = "Cosmic Cloud"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_cloud"
	duration = 8

/obj/effect/temp_visual/cosmic_explosion
	name = "Cosmic Explosion"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "cosmic_explosion"
	duration = 5
	pixel_x = -16
	pixel_y = -16

/obj/effect/temp_visual/space_explosion
	name = "Space Explosion"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "space_explosion"
	duration = 5
	pixel_x = -16
	pixel_y = -16

/obj/effect/temp_visual/cosmic_domain
	name = "Cosmic Domain"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "cosmic_domain"
	duration = 6
	pixel_x = -64
	pixel_y = -64

/obj/effect/temp_visual/cosmic_gem
	name = "cosmic gem"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_gem"
	duration = 12

/obj/effect/temp_visual/cosmic_gem/Initialize(mapload)
	. = ..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)


/// Bombs check this list to see whether a nearby active cosmic field should stop them detonating (level-2
/// cosmic passive). Populated by /obj/effect/forcefield/cosmic_field/proc/prevents_explosions().
GLOBAL_LIST_EMPTY_TYPED(active_cosmic_fields, /obj/effect/forcefield/cosmic_field)

/// The cosmic heretic's forcefield.
/obj/effect/forcefield/cosmic_field
	name = "космический щит"
	desc = "Силовой щит, который не могут пройти люди, отмеченные звёздами."
	gender = MALE
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_carpet"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = FALSE
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE
	/// If we are able to slow down projectiles (level-3 cosmic passive).
	var/slows_projectiles = FALSE

/obj/effect/forcefield/cosmic_field/get_ru_names()
	return alist(
		NOMINATIVE = "космический щит",
		GENITIVE = "космического щита",
		DATIVE = "космическому щиту",
		ACCUSATIVE = "космический щит",
		INSTRUMENTAL = "космическим щитом",
		PREPOSITIONAL = "космическом щите",
	)


/obj/effect/forcefield/cosmic_field/Initialize(mapload, flags = MAGIC_RESISTANCE)
	. = ..()
	antimagic_flags = flags
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_loc_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	for(var/atom/movable/thing in get_turf(src))
		on_entered(src, thing)

/obj/effect/forcefield/cosmic_field/Destroy()
	for(var/atom/movable/thing in get_turf(src))
		on_loc_exited(src, thing)
	GLOB.active_cosmic_fields -= src
	return ..()

/obj/effect/forcefield/cosmic_field/CanAllowThrough(atom/movable/mover, border_dir)
	if(!isliving(mover))
		return ..()

	var/mob/living/living_mover = mover
	if(living_mover.can_block_magic(antimagic_flags, charge_cost = 0))
		return ..()

	if(ismob(living_mover.buckled))
		var/mob/living/fireman = living_mover.buckled
		if(fireman.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
			return ..()
	if(living_mover.pulledby?.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
		return ..()

	if(living_mover.has_status_effect(/datum/status_effect/star_mark))
		return FALSE

	return ..()

/obj/effect/forcefield/cosmic_field/proc/on_entered(datum/source, atom/movable/thing)
	SIGNAL_HANDLER
	if(isprojectile(thing) && slows_projectiles)
		var/obj/projectile/bullet = thing
		if(istype(bullet, /obj/projectile/magic/star_ball)) // Don't slow down star balls
			return
		bullet.speed *= 5 // 80% slowdown (speed = deciseconds per tile, higher = slower)
		return

	if(!isliving(thing))
		return
	var/mob/living/living_mover = thing
	if(!living_mover.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
		return
	living_mover.add_movespeed_modifier(/datum/movespeed_modifier/cosmic_field)

/obj/effect/forcefield/cosmic_field/proc/on_loc_exited(datum/source, atom/movable/thing)
	SIGNAL_HANDLER
	if(isprojectile(thing) && slows_projectiles)
		var/obj/projectile/bullet = thing
		if(istype(bullet, /obj/projectile/magic/star_ball)) // Don't speed up star balls
			return
		bullet.speed /= 5
		return

	if(!isliving(thing))
		return
	var/mob/living/living_mover = thing
	if(!living_mover.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
		return
	living_mover.remove_movespeed_modifier(/datum/movespeed_modifier/cosmic_field)

/// Adds the ability to slow down any projectiles that enters any turf we occupy (level-3 cosmic passive).
/obj/effect/forcefield/cosmic_field/proc/slows_projectiles()
	slows_projectiles = TRUE

/// Adds our cosmic field to the global list which bombs check to stop themselves exploding (level-2 passive).
/obj/effect/forcefield/cosmic_field/proc/prevents_explosions()
	GLOB.active_cosmic_fields |= src

/datum/movespeed_modifier/cosmic_field
	multiplicative_slowdown = -0.25

/obj/effect/forcefield/cosmic_field/star_blast
	lifetime = 5 SECONDS

/obj/effect/forcefield/cosmic_field/star_touch

/obj/effect/forcefield/cosmic_field/fast
	lifetime = 5 SECONDS

/obj/effect/forcefield/cosmic_field/extrafast
	lifetime = 2.5 SECONDS

/**
 * Creates a cosmic field at a given loc, upgrading it based on the creator's cosmic passive level.
 *
 * * loc: Where the cosmic field is created.
 * * creator: Optional. If they have a cosmic passive (or are a stargazer), the field gains the matching upgrades.
 * * type: Optional. A specific cosmic field subtype to make instead of the default.
 */
/proc/create_cosmic_field(loc, mob/living/creator, type = /obj/effect/forcefield/cosmic_field)
	var/obj/effect/forcefield/cosmic_field/new_field = new type(loc)

	if(!creator || !ismob(creator))
		return new_field
	if(istype(creator, /mob/living/simple_animal/hostile/heretic_summon/star_gazer))
		new_field.slows_projectiles()
		new_field.prevents_explosions()
		return new_field
	var/datum/status_effect/heretic_passive/cosmic/cosmic_passive = creator.has_status_effect(/datum/status_effect/heretic_passive/cosmic)
	if(!cosmic_passive)
		return new_field
	if(cosmic_passive.applied_level >= 2)
		new_field.prevents_explosions()
	if(cosmic_passive.applied_level >= 3)
		new_field.slows_projectiles()
	return new_field
