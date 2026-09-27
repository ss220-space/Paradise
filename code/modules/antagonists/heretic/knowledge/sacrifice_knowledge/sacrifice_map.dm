
/// A global assoc list of all landmarks that denote a heretic sacrifice location. [string heretic path] = [landmark].
GLOBAL_LIST_EMPTY(heretic_sacrifice_landmarks)

/// Landmarks meant to designate where heretic sacrifices are sent.
/obj/effect/landmark/heretic
	name = "standard heretic sacrifice landmark"
	icon = 'icons/effects/landmarks_static.dmi' // Paradise's icons/misc/landmarks.dmi has no "x" state
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
	name = "ash heretic sacrifice landmark"
	for_heretic_path = PATH_ASH


/obj/effect/landmark/heretic/ash/Initialize(mapload)
	. = ..()
	if(!GLOB.heretic_sacrifice_landmarks[PATH_START])
		GLOB.heretic_sacrifice_landmarks[PATH_START] = src


/obj/effect/landmark/heretic/ash/Destroy()
	if(GLOB.heretic_sacrifice_landmarks[PATH_START] == src)
		GLOB.heretic_sacrifice_landmarks[PATH_START] = null
	return ..()


/obj/effect/landmark/heretic/flesh
	name = "flesh heretic sacrifice landmark"
	for_heretic_path = PATH_FLESH


/obj/effect/landmark/heretic/void
	name = "void heretic sacrifice landmark"
	for_heretic_path = PATH_VOID


/obj/effect/landmark/heretic/rust
	name = "rust heretic sacrifice landmark"
	for_heretic_path = PATH_RUST


/obj/effect/landmark/heretic/lock
	name = "lock heretic sacrifice landmark"
	for_heretic_path = PATH_LOCK


/obj/effect/landmark/heretic/moon
	name = "moon heretic sacrifice landmark"
	for_heretic_path = PATH_MOON


/obj/effect/landmark/heretic/cosmic
	name = "cosmic heretic sacrifice landmark"
	for_heretic_path = PATH_COSMIC


/obj/effect/landmark/heretic/rhytm
	name = "rhytm heretic sacrifice landmark"
	for_heretic_path = PATH_RHYTM


/obj/effect/landmark/heretic/blade
	name = "blade heretic sacrifice landmark"
	for_heretic_path = PATH_BLADE


/obj/effect/landmark/heretic/bluespace
	name = "bluespace heretic sacrifice landmark"
	for_heretic_path = PATH_BLUESPACE


/obj/structure/no_effect_signpost
	name = "signpost"
	desc = "Кто-нибудь подаст мне знак?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE

/obj/structure/no_effect_signpost/get_ru_names()
	return alist(
		NOMINATIVE = "указатель",
		GENITIVE = "указателя",
		DATIVE = "указателю",
		ACCUSATIVE = "указатель",
		INSTRUMENTAL = "указателем",
		PREPOSITIONAL = "указателе",
	)


/obj/structure/no_effect_signpost/void
	name = "void signpost"
	desc = "Направление в бесцельной пустоте."
	density = FALSE
	/// Brightness of the signpost.
	var/range = 2
	/// Light power of the signpost.
	var/power = 0.8

/obj/structure/no_effect_signpost/void/get_ru_names()
	return alist(
		NOMINATIVE = "указатель на краю вселенной",
		GENITIVE = "указателя на краю вселенной",
		DATIVE = "указателю на краю вселенной",
		ACCUSATIVE = "указатель на краю вселенной",
		INSTRUMENTAL = "указателем на краю вселенной",
		PREPOSITIONAL = "указателе на краю вселенной",
	)

/obj/structure/no_effect_signpost/void/Initialize(mapload)
	. = ..()
	set_light(range, power)


/obj/machinery/light/very_dim
	nightshift_allowed = FALSE
	brightness_color = "#d6b6a6ff"
	brightness_power = 3


/obj/machinery/light/very_dim/directional/north
	dir = NORTH

/obj/machinery/light/very_dim/directional/south
	dir = SOUTH

/obj/machinery/light/very_dim/directional/east
	dir = EAST

/obj/machinery/light/very_dim/directional/west
	dir = WEST


/turf/simulated/floor/indestructible/mansus
	name = "mansus flesh"
	desc = "Тёплая, слабо пульсирующая поверхность. Лучше не думать о том, на чём вы стоите."
	gender = FEMALE
	icon_state = "necro1"
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE
	baseturf = /turf/simulated/floor/indestructible/mansus
	footstep = FOOTSTEP_MEAT
	barefootstep = FOOTSTEP_MEAT
	clawfootstep = FOOTSTEP_MEAT
	heavyfootstep = FOOTSTEP_MEAT

/turf/simulated/floor/indestructible/mansus/get_ru_names()
	return alist(
		NOMINATIVE = "плоть Обители",
		GENITIVE = "плоти Обители",
		DATIVE = "плоти Обители",
		ACCUSATIVE = "плоть Обители",
		INSTRUMENTAL = "плотью Обители",
		PREPOSITIONAL = "плоти Обители",
	)

/turf/simulated/floor/fakespace/mansus_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/floor/plating/asteroid/mansus_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/floor/plating/asteroid/basalt/lava/mansus_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/floor/plating/ironsand/mansus_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/floor/plating/mansus_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/floor/indestructible/plating/mansus_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/floor/glass/mansus_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/area/centcom/heretic_sacrifice
	name = "Обитель"
	icon = 'icons/area/eldritch_areas.dmi' // base areas.dmi has no "heretic" state
	icon_state = "heretic"
	base_lighting_alpha = 0
	static_lighting = TRUE
	sound_environment = SOUND_ENVIRONMENT_CAVE
	area_flags = UNIQUE_AREA // | BLOCK_SUICIDE | NO_BOH


/area/centcom/heretic_sacrifice/Initialize(mapload)
	if(!ambientsounds)
		ambientsounds = /*GLOB.ambience_assoc[ambience_index] +*/ 'sound/ambience/misc/ambiatm1.ogg'

	return ..()


/area/centcom/heretic_sacrifice/ash //also, the default
	name = "Пепельные Врата Обители"


/area/centcom/heretic_sacrifice/void
	name = "Пустотные Врата Обители"
	base_lighting_color = COLOR_BLUE
	base_lighting_alpha = 255
	sound_environment = SOUND_ENVIRONMENT_UNDERWATER


/area/centcom/heretic_sacrifice/flesh
	name = "Врата Обители из Плоти"
	sound_environment = SOUND_ENVIRONMENT_STONEROOM


/area/centcom/heretic_sacrifice/rust
	name = "Ржавые Врата Обители"
	sound_environment = SOUND_ENVIRONMENT_SEWER_PIPE


/area/centcom/heretic_sacrifice/lock
	name = "Врата Обители выкованные из ключей"
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC


/area/centcom/heretic_sacrifice/cosmic
	name = "Космические Врата Обители"
	has_gravity = 0
	sound_environment = SOUND_ENVIRONMENT_PLAIN


/area/centcom/heretic_sacrifice/blade
	name = "Железные Врата Обители"
	base_lighting_color = COLOR_GREEN
	base_lighting_alpha = 255
	sound_environment = SOUND_ENVIRONMENT_ARENA


/area/centcom/heretic_sacrifice/moon
	name = "Лунные Врата Обители"
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC


/area/centcom/heretic_sacrifice/rhytm
	name = "Гремящие Врата Обители"
	sound_environment = SOUND_ENVIRONMENT_FOREST


/area/centcom/heretic_sacrifice/bluespace
	name = "Блюспейс-Врата Обители"
	base_lighting_color = "#6FE3D4"
	base_lighting_alpha = 255
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL


/area/centcom/heretic_sacrifice/moon2
	name = "Изменённые Лунные Врата Обители"
	has_gravity = NEGATIVE_GRAVITY
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC


/obj/structure/moon
	name = "symbol of truth and moon"
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
	return alist(
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
	name = "star"
	desc = "Символ из неизвестного материала в форме звезды с глазом в центре. \
			Для чего он предназначен? Кто оставил его здесь? Откуда на моём лице улыбка? \
			С каждым задаваемым про себя вопросом ваши мысли путаются всё сильнее."
	gender = FEMALE
	icon_state = "star"
	light_range = 3
	light_power = 3


/obj/structure/moon/star/get_ru_names()
	return alist(
		NOMINATIVE = "звезда",
		GENITIVE = "звезды",
		DATIVE = "звезде",
		ACCUSATIVE = "звезду",
		INSTRUMENTAL = "звездой",
		PREPOSITIONAL = "звезде",
	)


/obj/structure/moon/stars
	name = "stars"
	desc = "Три символа из неизвестного материала в форме звёзд. Почему на них нет глаз? \
			У звёзд должны быть глаза. У луны должна быть улыбка. Нам лгут. Из-за этого \
			никто не хочет участвовать в параде."
	gender = PLURAL
	icon_state = "stars"
	light_range = 2
	light_power = 3


/obj/structure/moon/stars/get_ru_names()
	return alist(
		NOMINATIVE = "звёзды",
		GENITIVE = "звёзд",
		DATIVE = "звёздам",
		ACCUSATIVE = "звёзды",
		INSTRUMENTAL = "звёздами",
		PREPOSITIONAL = "звёздах",
	)


/obj/structure/orb
	name = "eldritch orb"
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
	return alist(
		NOMINATIVE = "жуткая сфера",
		GENITIVE = "жуткой сферы",
		DATIVE = "жуткой сфере",
		ACCUSATIVE = "жуткую сферу",
		INSTRUMENTAL = "жуткой сферой",
		PREPOSITIONAL = "жуткой сфере",
	)


/obj/structure/punji_sticks/bone
	name = "bone spike"
	desc = "Костяной шип ростущий из кучи плоти. Большая часть его поверхности покрыта застывшей кровью, \
			но остриё по какой-то причине чисто."
	gender = MALE
	icon = 'icons/obj/eretik_slabs.dmi'
	icon_state = "bone"


/obj/structure/punji_sticks/bone/get_ru_names()
	return alist(
		NOMINATIVE = "костяной шип",
		GENITIVE = "костяного шипа",
		DATIVE = "костяному шипу",
		ACCUSATIVE = "костяной шип",
		INSTRUMENTAL = "костяным шипом",
		PREPOSITIONAL = "костяном шипе",
	)


/obj/structure/punji_sticks/spike
	name = "spikes"
	desc = "Каменные шипы странной формы торчащие откуда-то из под земли."
	gender = PLURAL
	icon = 'icons/obj/eretik_slabs.dmi'
	icon_state = "spike"


/obj/structure/punji_sticks/spike/get_ru_names()
	return alist(
		NOMINATIVE = "шипы",
		GENITIVE = "шипов",
		DATIVE = "шипам",
		ACCUSATIVE = "шипы",
		INSTRUMENTAL = "шипами",
		PREPOSITIONAL = "шипах",
	)
