/mob/living/simple_animal/hostile/heretic_summon
	name = "Жуткий Демон"
	real_name = "Жуткий Демон"
	desc = "Ужас из потустороннего мира, вызванный плохим кодом."
	icon = 'icons/mob/eldritch_mobs.dmi'
	faction = list(FACTION_HERETIC)
	gender = NEUTER
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
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)


/mob/living/simple_animal/hostile/heretic_summon/get_ru_names()
	return alist(
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


/// tg's /mob/living/basic/melee_attack, adapted: the ported basic-mob AI behaviors (basic_melee_attack etc.)
/// call pawn.melee_attack(target) - route that into the native simple_animal attack flow. (The behavior's
/// pawn var is declared /mob/living/basic, so this resolves via dynamic dispatch at runtime.)
/mob/living/simple_animal/hostile/heretic_summon/proc/melee_attack(atom/attacked_target)
	if(QDELETED(attacked_target))
		return FALSE
	face_atom(attacked_target)
	target = attacked_target
	return AttackingTarget()
