/mob/living/basic/cockroach
	name = "cockroach"
	desc = "Эта станция просто кишит тараканами."
	ru_names = list(
		NOMINATIVE = "таракан",
		GENITIVE = "таракана",
		DATIVE = "таракану",
		ACCUSATIVE = "таракана",
		INSTRUMENTAL = "тараканом",
		PREPOSITIONAL = "таракане"
	)
	icon_state = "cockroach"
	icon_dead = "cockroach" //Make this work
	density = FALSE
	//mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	mob_size = MOB_SIZE_TINY
	health = 1
	maxHealth = 1
	speed = 1.25
	gold_core_spawnable = FRIENDLY_SPAWN
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	verb_say = "щебечет"
	verb_ask = "щебечет с любопытством"
	verb_exclaim = "громко щебечет"
	verb_yell = "громко щебечет"
	response_disarm_continuous = "прогоняет"
	response_disarm_simple = "прогнали"
	response_harm_continuous = "давит"
	response_harm_simple = "раздавливаете"
	speak_emote = list("щебечет")

	basic_mob_flags = DEL_ON_DEATH
	faction = list("hostile")

	ai_controller = /datum/ai_controller/basic_controller/cockroach

/mob/living/basic/cockroach/Initialize()
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/effect/decal/cleanable/insectguts))

	AddElement(/datum/element/basic_body_temp_sensetive, 270, INFINITY)
	AddComponent(/datum/component/squashable, squash_chance = 50, squash_damage = 1)

/mob/living/basic/cockroach/death(gibbed)
	if(SSticker.mode.station_was_nuked) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/basic/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return FALSE

/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/find_and_hunt_target/cockroach,
	)
