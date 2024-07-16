/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	var/lifetime = 30 SECONDS

/obj/effect/forcefield/New()
	..()
	if(lifetime)
		QDEL_IN(src, lifetime)

/obj/effect/forcefield/CanAtmosPass(direction)
	return !density

/obj/effect/forcefield/wizard
	var/mob/wizard

/obj/effect/forcefield/wizard/Initialize(mapload, mob/summoner)
	. = ..()
	wizard = summoner


/obj/effect/forcefield/wizard/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == wizard)
		return TRUE


/obj/structure/forcefield
	name = "ain't supposed to see this"
	desc = "file a github report if you do!"
	icon = 'icons/effects/effects.dmi'
	density = TRUE
	anchored = TRUE
	var/blocks_atmos = TRUE

/obj/structure/forcefield/Initialize(mapload)
	. = ..()
	if(blocks_atmos)
		recalculate_atmos_connectivity()

/obj/structure/forcefield/Destroy()
	if(blocks_atmos)
		blocks_atmos = FALSE
		recalculate_atmos_connectivity()
	return ..()

/obj/structure/forcefield/CanAtmosPass(direction)
	return !blocks_atmos

///////////Mimewalls///////////
/obj/structure/forcefield/mime
	icon = 'icons/effects/effects.dmi'
	icon_state = "5"
	name = "invisible wall"
	desc = "You have a bad feeling about this."

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You might be here a while."
	lifetime = 60 SECONDS

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

