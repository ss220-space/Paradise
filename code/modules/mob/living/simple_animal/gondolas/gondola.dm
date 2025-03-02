#define GONDOLA_HEIGHT pick(list("gondola_body_long", "gondola_body_medium", "gondola_body_short"))
#define GONDOLA_COLOR pick(list("A87855", "915E48", "683E2C"))
#define GONDOLA_MOUSTACHE pick(list("gondola_moustache_large", "gondola_moustache_small"))
#define GONDOLA_EYES pick(list("gondola_eyes_close", "gondola_eyes_far"))

/mob/living/simple_animal/pet/gondola
	name = "gondola"
	real_name = "gondola"
	desc = "Гондола — бесшумный ходок.  \
		Не имея рук, он воплощает даосский принцип у-вэй (недействие), а его улыбающееся \
		выражение лица показывает его полное и полное принятие мира таким, какой он есть."
	icon = 'icons/mob/gondolas.dmi'
	icon_state = "gondola"
	icon_living = "gondola"

	maxHealth = 200
	health = 200
	faction = list("gandola")
	response_help = "pets"
	response_disarm = "bops"
	response_harm = "kicks"

	//Gondolas aren't affected by cold.
	unsuitable_atmos_damage = 0
	del_on_death = TRUE

		///List of loot drops on death, since it deletes itself on death (like trooper).
	loot = list(
		/obj/effect/decal/cleanable/blood/gibs = 1,
	)

	ru_names = list(
		NOMINATIVE = "гандола",
		GENITIVE = "гандолы",
		DATIVE = "гандоле",
		ACCUSATIVE = "гандолу",
		INSTRUMENTAL = "гандолой",
		PREPOSITIONAL = "гандоле"
	)


/mob/living/simple_animal/pet/gondola/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_MUTE, INNATE_TRAIT)
	create_gondola()

/mob/living/simple_animal/pet/gondola/proc/create_gondola()
	icon_state = null
	icon_living = null
	var/height = GONDOLA_HEIGHT
	var/mutable_appearance/body_overlay = mutable_appearance(icon, height)
	var/mutable_appearance/eyes_overlay = mutable_appearance(icon, GONDOLA_EYES)
	var/mutable_appearance/moustache_overlay = mutable_appearance(icon, GONDOLA_MOUSTACHE)
	body_overlay.color = ("#[GONDOLA_COLOR]")

	//Offset the face to match the Gondola's height.
	switch(height)
		if("gondola_body_medium")
			eyes_overlay.pixel_y = -4
			moustache_overlay.pixel_y = -4
		if("gondola_body_short")
			eyes_overlay.pixel_y = -8
			moustache_overlay.pixel_y = -8

	cut_overlays(TRUE)
	add_overlay(body_overlay)
	add_overlay(eyes_overlay)
	add_overlay(moustache_overlay)


#undef GONDOLA_HEIGHT
#undef GONDOLA_COLOR
#undef GONDOLA_MOUSTACHE
#undef GONDOLA_EYES
