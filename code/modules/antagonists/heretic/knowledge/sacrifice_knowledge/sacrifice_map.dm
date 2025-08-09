// Some various defines used in the heretic sacrifice map.

/// A global assoc list of all landmarks that denote a heretic sacrifice location. [string heretic path] = [landmark].
GLOBAL_LIST_EMPTY(heretic_sacrifice_landmarks)

/// Lardmarks meant to designate where heretic sacrifices are sent.
/obj/effect/landmark/heretic
	name = "стандартная метка жертвоприношения еретиков"
	icon_state = "x"
	/// What path this landmark is intended for.
	var/for_heretic_path = PATH_START


/obj/effect/landmark/heretic/Initialize(mapload)
	. = ..()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = src


/obj/effect/landmark/heretic/Destroy()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = null
	return ..()


/obj/effect/landmark/heretic/ash
	name = "метка жертвоприношения еретиков пути Пепла"
	for_heretic_path = PATH_ASH


/obj/effect/landmark/heretic/flesh
	name = "метка жертвоприношения еретиков пути Плоти"
	for_heretic_path = PATH_FLESH


/obj/effect/landmark/heretic/void
	name = "метка жертвоприношения еретиков пути Пустоты"
	for_heretic_path = PATH_VOID


/obj/effect/landmark/heretic/rust
	name = "метка жертвоприношения еретиков пути Ржавчины"
	for_heretic_path = PATH_RUST


/obj/effect/landmark/heretic/lock
	name = "метка жертвоприношения еретиков пути Ключа"
	for_heretic_path = PATH_LOCK


/obj/effect/landmark/heretic/moon
	name = "метка жертвоприношения еретиков пути Луны"
	for_heretic_path = PATH_MOON


/obj/effect/landmark/heretic/cosmic
	name = "метка жертвоприношения еретиков пути Космоса"
	for_heretic_path = PATH_COSMIC


/obj/effect/landmark/heretic/blade
	name = "метка жертвоприношения еретиков пути Клинка"
	for_heretic_path = PATH_BLADE


// A fluff signpost object that doesn't teleport you somewhere when you touch it.
/obj/structure/no_effect_signpost
	name = "указатель"
	desc = "Кто-нибудь подаст мне знак?"
	icon = 'icons/obj/fluff_general.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE


/obj/structure/no_effect_signpost/void
	name = "указатель на краю вселенной"
	desc = "Направление в бесцельной пустоте."
	density = FALSE
	/// Brightness of the signpost.
	var/range = 2
	/// Light power of the signpost.
	var/power = 0.8


/obj/structure/no_effect_signpost/void/Initialize(mapload)
	. = ..()
	set_light(range, power)


// Some VERY dim lights, used for the void sacrifice realm.
/obj/machinery/light/very_dim
	nightshift_allowed = FALSE
	brightness_color = "#d6b6a6ff"
	brightness_power = 3
	//fire_brightness = 3.5
	//bulb_power = 0.5


/obj/machinery/light/very_dim/directional/north
	dir = NORTH

/obj/machinery/light/very_dim/directional/south
	dir = SOUTH

/obj/machinery/light/very_dim/directional/east
	dir = EAST

/obj/machinery/light/very_dim/directional/west
	dir = WEST


// Rooms for where heretic sacrifices send people.
/area/centcom/heretic_sacrifice
	name = "Мансус"
	icon_state = "heretic"
	has_gravity = STANDARD_GRAVITY
	//ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_CAVE
	area_flags = UNIQUE_AREA // | BLOCK_SUICIDE | NO_BOH


/area/centcom/heretic_sacrifice/Initialize(mapload)
	if(!ambientsounds)
		ambientsounds = /*GLOB.ambience_assoc[ambience_index] +*/ 'sound/ambience/misc/ambiatm1.ogg'

	return ..()


/area/centcom/heretic_sacrifice/ash //also, the default
	name = "Пепельные Врата Мансуса"


/area/centcom/heretic_sacrifice/void
	name = "Пустотные Врата Мансуса"
	use_starlight = TRUE
	sound_environment = SOUND_ENVIRONMENT_UNDERWATER


/area/centcom/heretic_sacrifice/flesh
	name = "Врата Мансуса из Плоти"
	sound_environment = SOUND_ENVIRONMENT_STONEROOM


/area/centcom/heretic_sacrifice/rust
	name = "Ржавые Врата Мансуса"
	//ambience_index = AMBIENCE_REEBE
	sound_environment = SOUND_ENVIRONMENT_SEWER_PIPE


/area/centcom/heretic_sacrifice/lock
	name = "Врата Мансуса выкованные из ключей"
	//ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC


/area/centcom/heretic_sacrifice/cosmic
	name = "Космические Врата Мансуса"
	has_gravity = 0
	sound_environment = SOUND_ENVIRONMENT_PLAIN


/area/centcom/heretic_sacrifice/blade
	name = "Железные Врата Мансуса"
	use_starlight = TRUE
	sound_environment = SOUND_ENVIRONMENT_ARENA


/area/centcom/heretic_sacrifice/moon
	name = "Лунные Врата Мансуса"
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC


/area/centcom/heretic_sacrifice/moon2
	name = "Немного другие Лунные Врата Мансуса"
	has_gravity = NEGATIVE_GRAVITY
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC
