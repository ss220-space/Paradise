/obj/effect/forcefield
	name = "FORCEWALL"
	desc = "A space wizard's magic wall."
	icon_state = "m_shield"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	/// If set, how long the force field lasts after it's created. Set to 0 to have infinite duration forcefields.
	var/initial_duration = 30 SECONDS

/obj/effect/forcefield/Initialize(mapload)
	. = ..()
	if(initial_duration > 0 SECONDS)
		QDEL_IN(src, initial_duration)

/obj/effect/forcefield/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/forcefield/CanAtmosPass(direction)
	return !density

/obj/effect/forcefield/wizard
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE
	/// A weakref to whoever casted our forcefield.
	var/datum/weakref/caster_weakref

/obj/effect/forcefield/wizard/Initialize(mapload, mob/caster, flags = MAGIC_RESISTANCE)
	. = ..()
	if(caster)
		caster_weakref = WEAKREF(caster)
	antimagic_flags = flags

/obj/effect/forcefield/wizard/CanAllowThrough(atom/movable/mover, border_dir)
	if(IS_WEAKREF_OF(mover, caster_weakref))
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.can_block_magic(antimagic_flags, charge_cost = 0))
			return TRUE

	return ..()

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = null
	name = "invisible wall"
	desc = "You have a bad feeling about this."

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You might be here a while."
	initial_duration = 60 SECONDS

///////////Mechawalls///////////
/obj/effect/forcefield/mecha
	icon_state = "shield-old"
	name = "Energy wall"
	desc = "A slowly fading energy wall that blocks passage"

/obj/effect/forcefield/mecha/syndicate
	icon_state = "shield-red"
	name = "Syndicate energy wall"
	desc = "A slowly fading energy wall that blocks passage for every possible nanotrasen scum"

/obj/effect/forcefield/mecha/syndicate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	var/mob/living/mob_check = get_mob_in_atom_without_warning(mover)
	return ("syndicate" in mob_check.faction) || istype(mob_check.get_id_card(), /obj/item/card/id/syndicate)

