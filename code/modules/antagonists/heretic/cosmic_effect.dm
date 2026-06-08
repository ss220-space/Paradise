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


/// The cosmic heretic's forcefield (extracted from tg construct_spells.dm during the port).
/obj/effect/forcefield/cosmic_field
	name = "космический щит"
	ru_names = list(
		NOMINATIVE = "космический щит",
		GENITIVE = "космического щита",
		DATIVE = "космическому щиту",
		ACCUSATIVE = "космический щит",
		INSTRUMENTAL = "космическим щитом",
		PREPOSITIONAL = "космическом щите",
	)
	desc = "Силовой щит, который не могут пройти люди, отмеченные звездой."
	gender = MALE
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_carpet"
	density = FALSE
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE

/obj/effect/forcefield/cosmic_field/Initialize(mapload, flags = MAGIC_RESISTANCE)
	. = ..()
	antimagic_flags = flags

/obj/effect/forcefield/cosmic_field/CanAllowThrough(atom/movable/mover, border_dir)
	if(!isliving(mover))
		return ..()

	var/mob/living/living_mover = mover
	if(living_mover.can_block_magic(antimagic_flags, charge_cost = 0))
		return ..()

	if(living_mover.has_status_effect(/datum/status_effect/star_mark))
		return FALSE

	return ..()

/obj/effect/forcefield/cosmic_field/fast
	lifetime = 5 SECONDS

/obj/effect/forcefield/cosmic_field/extrafast
	lifetime = 2.5 SECONDS
