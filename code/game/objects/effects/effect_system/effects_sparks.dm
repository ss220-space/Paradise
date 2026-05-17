/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/**
 * Arguments:
 * - number: number of sparks.
 * - cardinal_only: cardinals, bool, do the sparks only move in cardinal directions?
 * - source: source of the sparks.
 */
/proc/do_sparks(number, cardinal_only, source)
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(number, cardinal_only, source)
	sparks.autocleanup = TRUE
	INVOKE_ASYNC(sparks, TYPE_PROC_REF(/datum/effect_system, start))

/obj/effect/particle_effect/sparks
	name = "sparks"
	icon_state = "sparks"
	var/hotspottemp = 1000

/obj/effect/particle_effect/sparks/Initialize(mapload)
	. = ..()
	flick("sparks", src) // replay the animation
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp, 1)
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp, 1)
	return ..()

/obj/effect/particle_effect/sparks/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp, 1)

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks
