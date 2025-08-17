/mob/living/simple_animal/hostile/heretic_summon
	name = "Жуткий Демон"
	real_name = "Жуткий Демон"
	desc = "Ужас из потустороннего мира, вызванный плохим кодом."
	icon = 'icons/mob/eldritch_mobs.dmi'
	faction = list(FACTION_HERETIC)
	gender = NEUTER
	//mob_biotypes = NONE

	status_flags = CANPUSH
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	speed = 0
	Atkcool = CLICK_CD_MELEE
	universal_speak = TRUE
	attack_sound = 'sound/weapons/punch1.ogg'
	response_help = "прикосается"
	response_disarm = "молотит"
	response_harm = "рвет"
	deathmessage = "распадается в воздухе."
	del_on_death = TRUE

	unsuitable_atmos_damage = 0
	ai_controller = null
	speak_emote = list("кричит")
	gold_core_spawnable = NO_SPAWN


/mob/living/simple_animal/hostile/heretic_summon/get_ru_names()
	return list(
		NOMINATIVE = "Жуткий Демон",
		GENITIVE = "Жуткого Демона",
		DATIVE = "Жуткому Демону",
		ACCUSATIVE = "Жуткого Демона",
		INSTRUMENTAL = "Жутким Демоном",
		PREPOSITIONAL = "Жутком Демоне",
	)


/mob/living/simple_animal/hostile/heretic_summon/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/death_drops, string_list(list(/obj/effect/gibspawner/generic)))
	ADD_TRAIT(src, TRAIT_HERETIC_SUMMON, INNATE_TRAIT)

/mob/living/simple_animal/hostile/heretic_summon/death(gibbed)
	. = ..()
	qdel(src)
