/obj/structure/spacepoddoor
	name = "podlock"
	desc = "Why it no open!!!"
	icon = 'icons/effects/beam.dmi'
	icon_state = "n_beam"
	density = FALSE
	anchored = TRUE
	var/id = 1.0

/obj/structure/spacepoddoor/Initialize()
	. = ..()
	air_update_turf(1)

/obj/structure/spacepoddoor/CanAtmosPass(turf/T, vertical)
	return 0

/obj/structure/spacepoddoor/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)


/obj/structure/spacepoddoor/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!isspacepod(mover) && !checkpass(mover))
		return FALSE


/obj/structure/spacepoddoor/invincible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
