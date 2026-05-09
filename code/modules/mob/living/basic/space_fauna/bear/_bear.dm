//Space bears!
/mob/living/basic/bear
	name = "space bear"
	desc = "You don't need to be faster than a space bear, you just need to outrun your crewmates."
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/bearmeat = 5, /obj/item/clothing/head/bearpelt = 1)

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"

	max_stamina = 120
	maxHealth = 60
	health = 60
	speed = 0

	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	friendly_verb_continuous = "bear hugs"
	friendly_verb_simple = "bear hug"

	faction = list(FACTION_RUSSIAN, FACTION_BEAR)

	atmos_requirements = null
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 1500
	ai_controller = /datum/ai_controller/basic_controller/bear
	/// is the bear wearing a armor?
	var/armored = FALSE

/mob/living/basic/bear/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_SPACEWALK,  TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/tree_climber, climbing_distance = 15)
	// AddElement(/datum/element/swabable, CELL_LINE_TABLE_BEAR, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/bear/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	AddElement(/datum/element/ridable, /datum/component/riding/creature/bear)

/mob/living/basic/bear/update_icons()
	..()
	if(armored)
		add_overlay("armor_bear")

/mob/living/basic/bear/proc/extract_combs(obj/structure/beebox/hive)
	if(!length(hive.honeycombs))
		return
	var/obj/item/reagent_containers/honeycomb/honey_food = pick_n_take(hive.honeycombs)
	if(isnull(honey_food))
		return
	honey_food.forceMove(get_turf(src))

/mob/living/basic/bear/polar
	name = "space polar bear"
	icon_state = "polarbear"
	icon_living = "polarbear"
	icon_dead = "polarbear_dead"
	desc = "It's a polar bear, in space, but not actually in space."

/mob/living/basic/bear/polar/misha
	name = "Misha"
	real_name = "Misha"
	desc = "Tamed and trained by the Head of Security. Only beasts are above deceit."
	maxHealth = 250
	health = 250
	faction = list(FACTION_NEUTRAL)
	status_flags = CANPUSH | CANSTUN

/mob/living/basic/bear/winny
	name = "winny"
	maxHealth = 120
	health = 120
	faction = list(FACTION_HOSTILE)

/mob/living/basic/bear/polar/fat
	health = 90
	maxHealth = 90

/mob/living/basic/bear/polar/evil_santa
	faction = list(FACTION_HOSTILE, ROLE_SYNDICATE, FACTION_WINTER)

/mob/living/basic/bear/polar/ancient
	name = "ancient polar bear"
	desc = "A grizzled old polar bear, its hide thick enough to make it impervious to almost all weapons."

/mob/living/basic/bear/polar/ancient/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_GODMODE, INNATE_TRAIT)

/mob/living/basic/bear/brown
	icon_state = "brownbear"
	icon_living = "brownbear"
	icon_dead = "brownbear_dead"
	icon_gib = "brownbear_gib"

/mob/living/basic/bear/russian
	name = "combat bear"
	desc = "A ferocious brown bear decked out in armor plating, a red star with yellow outlining details the shoulder plating."
	icon_state = "combatbear"
	icon_living = "combatbear"
	icon_dead = "combatbear_dead"
	faction = list(FACTION_RUSSIAN)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/bearmeat = 5, /obj/item/clothing/head/bearpelt = 1) // , /obj/item/bear_armor = 1
	melee_damage_lower = 18
	melee_damage_upper = 20
	armour_penetration = 20
	health = 120
	maxHealth = 120
	gold_core_spawnable = HOSTILE_SPAWN
	armored = TRUE

