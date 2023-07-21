#define BREAD_MONSTERS_MAXCAP 20

GLOBAL_VAR_INIT(alive_bread_monsters_count, 0)
GLOBAL_VAR_INIT(bread_monsters_maxcap, 20)
GLOBAL_LIST_EMPTY(bread_monsters)

/mob/living/simple_animal/hostile/bread_monster
	name = "Bread Monster"
	desc = "Not exactly what you should do for three days..."
	health = 20
	maxHealth = 20
	harm_intent_damage = 7
	icon = 'icons/mob/bread_monster.dmi'
	icon_state = "bread_monster"
	icon_dead = "bread_monster_dead"
	death_sound = 'sound/misc/demon_dies.ogg'

	intent = INTENT_HARM
	butcher_results = list(/obj/item/reagent_containers/food/snacks/breadslice/burned = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = list("hits", "gnawing", "bites")
	emote_taunt = list("gnashes")
	attack_sound = 'sound/weapons/bite.ogg'
	melee_damage_lower = 7
	melee_damage_upper = 7
	tts_seed = "Peon"
	obj_damage = 15
	var/tele_limit = 5
	var/damage_increase = 1
	var/obj_damage_increase = 5
	var/health_increase = 5
	var/scaling_coeff = 1.15
	var/current_teleport_count = 0

/mob/living/simple_animal/hostile/bread_monster/on_teleported()
	if(current_teleport_count < tele_limit)
		current_teleport_count += 1
		src.transform = src.transform.Scale(scaling_coeff, scaling_coeff)
		health = initial(health) + health_increase * current_teleport_count
		harm_intent_damage = initial(harm_intent_damage) + damage_increase * current_teleport_count
		melee_damage_lower = initial(melee_damage_lower) + damage_increase * current_teleport_count
		melee_damage_upper = initial(melee_damage_upper) + damage_increase * current_teleport_count
		obj_damage = initial(obj_damage) + obj_damage_increase * current_teleport_count

/mob/living/simple_animal/hostile/bread_monster/New(loc, ...)
	. = ..()
	GLOB.bread_monsters += src

/mob/living/simple_animal/hostile/bread_monster/revive()
	. = ..()
	GLOB.bread_monsters += src

/mob/living/simple_animal/hostile/bread_monster/death(gibbed)
	. = ..()
	if(src in GLOB.bread_monsters)
		GLOB.bread_monsters -= src

/mob/living/simple_animal/hostile/bread_monster/Destroy()
	. = ..()
	if(src in GLOB.bread_monsters)
		GLOB.bread_monsters -= src
