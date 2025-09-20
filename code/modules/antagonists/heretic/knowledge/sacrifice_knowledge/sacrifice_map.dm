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
	//ambience_index = AMBIENCE_SPOOKY
	base_lighting_alpha = 0
	static_lighting = TRUE
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
	base_lighting_color = COLOR_BLUE
	base_lighting_alpha = 255
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
	base_lighting_color = COLOR_GREEN
	base_lighting_alpha = 255
	sound_environment = SOUND_ENVIRONMENT_ARENA


/area/centcom/heretic_sacrifice/moon
	name = "Лунные Врата Мансуса"
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC


/area/centcom/heretic_sacrifice/moon2
	name = "Немного другие Лунные Врата Мансуса"
	has_gravity = NEGATIVE_GRAVITY
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC


/obj/structure/moon
	name = "символ правды и луны"
	desc = "Раздробленный на несколько частей символ из неизвестного материала. \
			Трещины складываются в жуткого вида улыбку, что наводит на мысль, \
			что этот символ был разбит специально. Но подождите. Почему на моём лице нет трещин? \
			Что-то не так. Что-то повлияло на мои мысли. Почему я забыл что на моём лице должны быть трещины?"
	gender = MALE
	icon = 'icons/obj/eretik_slabs.dmi'
	icon_state = "moon1"
	light_color = "#32c3f0"
	light_range = 4


/obj/structure/moon/get_ru_names()
	return list(
		NOMINATIVE = "символ правды и луны",
		GENITIVE = "символа правды и луны",
		DATIVE = "символу правды и луны",
		ACCUSATIVE = "символ правды и луны",
		INSTRUMENTAL = "символом правды и луны",
		PREPOSITIONAL = "символе правды и луны",
	)


/obj/structure/moon/examine(mob/living/user)
	. = ..()
	if(!istype(user))
		return

	user.AdjustHallucinate(10 SECONDS)
	user.Confused(3 SECONDS)
	user.AdjustDruggy(3 SECONDS)
	if(!prob(30))
		return

	user.emote(pick("smile", "grin", "yawn", "laugh", "drool"))


/obj/structure/moon/star
	name = "звезда"
	desc = "Символ из неизвестного материала в форме звезды с глазом в центре. \
			Для чего он предназначен? Кто оставил его здесь? Откуда на моём лице улыбка? \
			С каждым задаваемым про себя вопросом ваши мысли путаются всё сильнее."
	gender = FEMALE
	icon_state = "star"
	light_range = 3
	light_power = 3


/obj/structure/moon/star/get_ru_names()
	return list(
		NOMINATIVE = "звезда",
		GENITIVE = "звезды",
		DATIVE = "звезде",
		ACCUSATIVE = "звезду",
		INSTRUMENTAL = "звездой",
		PREPOSITIONAL = "звезде",
	)


/obj/structure/moon/stars
	name = "звёзды"
	desc = "Три символа из неизвестного материала в форме звёзд. Почему на них нет глаз? \
			У звёзд должны быть глаза. У луны должна быть улыбка. Нам лгут. Из-за этого \
			никто не хочет участвовать в параде."
	gender = PLURAL
	icon_state = "stars"
	light_range = 2
	light_power = 3


/obj/structure/moon/stars/get_ru_names()
	return list(
		NOMINATIVE = "звёзды",
		GENITIVE = "звёзд",
		DATIVE = "звёздам",
		ACCUSATIVE = "звёзды",
		INSTRUMENTAL = "звёздами",
		PREPOSITIONAL = "звёздах",
	)


/obj/structure/orb
	name = "жуткая сфера"
	desc = "Жуткая, покрытая трещинами, сфера, состоящая из затвердевшей плоти неизвестного существа. \
			Щупальца растущие из неё уходят в пол, если это жуткое месиво вообще можно так назвать."
	gender = FEMALE
	plane = BELOW_GAME_PLANE
	icon = 'icons/obj/eretik_slabs64x64x.dmi'
	icon_state = "light_orb"
	light_color = "#d48d42"
	light_range = 10
	light_power = 3


/obj/structure/orb/get_ru_names()
	return list(
		NOMINATIVE = "жуткая сфера",
		GENITIVE = "жуткой сферы",
		DATIVE = "жуткой сфере",
		ACCUSATIVE = "жуткую сферу",
		INSTRUMENTAL = "жуткой сферой",
		PREPOSITIONAL = "жуткой сфере",
	)


/obj/structure/punji_sticks/bone
	name = "костяной шип"
	desc = "Костяной шип ростущий из кучи плоти. Большая часть его поверхности покрыта застывшей кровью, \
			но остриё по какой-то причине чисто."
	gender = MALE
	icon = 'icons/obj/eretik_slabs.dmi'
	icon_state = "bone"


/obj/structure/punji_sticks/bone/get_ru_names()
	return list(
		NOMINATIVE = "костяной шип",
		GENITIVE = "костяного шипа",
		DATIVE = "костяному шипу",
		ACCUSATIVE = "костяной шип",
		INSTRUMENTAL = "костяным шипом",
		PREPOSITIONAL = "костяном шипе",
	)


/obj/structure/punji_sticks/spike
	name = "шипы"
	desc = "Каменные шипы странной формы торчащие откуда-то из под земли."
	gender = PLURAL
	icon = 'icons/obj/eretik_slabs.dmi'
	icon_state = "spike"


/obj/structure/punji_sticks/spike/get_ru_names()
	return list(
		NOMINATIVE = "шипы",
		GENITIVE = "шипов",
		DATIVE = "шипам",
		ACCUSATIVE = "шипы",
		INSTRUMENTAL = "шипами",
		PREPOSITIONAL = "шипах",
	)
