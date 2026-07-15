// Disabled swarmer shell
/obj/item/deactivated_swarmer
	name = "unactivated swarmer"
	desc = "Деактивированная оболочка свармера. Может оказаться полезным для изучения."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_unactivated"
	origin_tech = "bluespace=4;materials=4;programming=7"
	materials = list(MAT_METAL=10000, MAT_GLASS=4000)

/obj/item/deactivated_swarmer/get_ru_names()
	return alist(
		NOMINATIVE = "деактивированная оболочка свармера",
		GENITIVE = "деактивированной оболочки свармера",
		DATIVE = "деактивированной оболочке свармера",
		ACCUSATIVE = "деактивированную оболочку свармера",
		INSTRUMENTAL = "деактивированной оболочкой свармера",
		PREPOSITIONAL = "деактивированной оболочке свармера"
	)

// Used in cases where no-one wanted to play as swarmer
/obj/effect/mob_spawn/swarmer
	name = "unactivated swarmer"
	desc = "Неактивированная оболочка свармера, которая может активироваться в любой момент. Кажется, её можно отключить отвёрткой."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_unactivated"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER
	anchored = FALSE
	mob_type = /mob/living/simple_animal/hostile/swarmer/basic
	death = FALSE
	roundstart = FALSE
	allow_tts_pick = FALSE
	banType = ROLE_SWARMER

/obj/effect/mob_spawn/swarmer/Initialize(mapload)
	. = ..()
	// I want these to get destroyed immediately
	RegisterSignal(SSdcs, COMSIG_GLOB_SWARMER_CORE_DESTROYED, PROC_REF(on_core_destroy))
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Оболочка свамера была создана в [A.name].", 'sound/effects/bin_close.ogg', source = src, action = NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/swarmer/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_GLOB_SWARMER_CORE_DESTROYED)
	return ..()

/obj/effect/mob_spawn/swarmer/proc/on_core_destroy()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/mob_spawn/swarmer/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return
	user.balloon_alert(user, "деактивировано!")
	new /obj/item/deactivated_swarmer(get_turf(src))
	qdel(src)

/// Flavour var override
/obj/effect/mob_spawn/swarmer/create(mob/plr, flavour = FALSE, name, prefs = FALSE, _mob_name = FALSE, _mob_gender = FALSE, _mob_species = FALSE)
	return ..()

/obj/effect/mob_spawn/swarmer/get_ru_names()
	return alist(
		NOMINATIVE = "оболочка свармера",
		GENITIVE = "оболочки свармера",
		DATIVE = "оболочке свармера",
		ACCUSATIVE = "оболочку свармера",
		INSTRUMENTAL = "оболочкой свармера",
		PREPOSITIONAL = "оболочке свармера"
	)
