/obj/thunderdomepurifier
	/var/global/purifierinstance  // singleton Раз locate возвращает только один объект, то возможно и не придется. С др. стороны - защита от щитспавна
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "thunderdome-bomb"

	name = "thunderdome bomb"
	desc = "A small device used to purify thunderdome"
	var/area/tdome_arena = null

	anchored = 1
	density = 0
	invisibility = INVISIBILITY_MAXIMUM
	opacity = 0
	layer = BELOW_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE

	var/timer = 20 // TODO later change to 300

/obj/thunderdomepurifier/proc/purify()
	tdome_arena = locate(/area/tdome/newtdome)

	for (var/mob/living/mob in tdome_arena) {
		mob.melt()
	}
	for (var/obj/A in tdome_arena) {
		if (!istype(A, /obj/thunderdomepurifier)) {
			qdel(A)
		}
	}

/obj/thunderdomepurifier/New()
	if (purifierinstance) {
		return ..()
	}
	if (loc) {
		purifierinstance = src
	}
