/// Slow moving mob which attempts to immobilise its target
/mob/living/basic/mining/goliath
	name = "goliath"
	desc = "Массивное бронированное чудовище, которое обездвиживает свою добычу с помощью тентаклей."
	ru_names = list(
		NOMINATIVE = "голиаф",
		GENITIVE = "голиафа",
		DATIVE = "голиафу",
		ACCUSATIVE = "голиафа",
		INSTRUMENTAL = "голиафом",
		PREPOSITIONAL = "голиафе"
	)
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_dead = "goliath_dead"
	gender = MALE
	speed = 30
	basic_mob_flags = IMMUNE_TO_FISTS
	maxHealth = 300
	health = 300
	friendly_verb_continuous = "воет на"
	friendly_verb_simple = "воете на"
	speak_emote = list("ревёт")
	obj_damage = 100
	melee_damage = 25
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_verb_continuous = "сокрушает"
	attack_verb_simple = "сокрушаете"
	throw_blocked_message = "с лёгкостью отскакивает от"
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG

	ai_controller = /datum/ai_controller/basic_controller/goliath

	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/goliath = 2, /obj/item/stack/sheet/animalhide/goliath_hide = 1, /obj/item/stack/sheet/bone = 2)

	/// Goliath can only take a step in intervals of this
	var/movement_delay = 4 SECONDS
	/// Icon state to use when tentacles are available
	var/tentacle_warning_state = "goliath_preattack"
	/// Can this kind of goliath be tamed?
	var/tameable = TRUE
	/// Has this particular goliath been tamed?
	var/tamed = FALSE
	/// Can someone ride us around like a horse?
	var/saddled = FALSE
	/// Slight cooldown to prevent double-dipping if we use both abilities at onc
	COOLDOWN_DECLARE(ability_animation_cooldown)
	/// Our base tentacles ability
	var/obj/effect/proc_holder/spell/goliath_tentacles/tentacles
	/// Our base tentacles ability
	var/obj/effect/proc_holder/spell/tentacle_burst/melee_tentacles
	/// Our base tentacles ability
	var/obj/effect/proc_holder/spell/tentacle_grasp/tentacle_line
	/// Things we want to eat off the floor (or a plate, we're not picky)
	var/static/list/goliath_foods = list(/obj/item/reagent_containers/food/snacks/grown/ash_flora, /obj/item/reagent_containers/food/snacks/bait)

/mob/living/basic/mining/goliath/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_TENTACLE_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)
	AddElement(/datum/element/basic_eating, heal_amt = 10, food_types = goliath_foods)
	AddElement(/datum/element/move_cooldown, move_delay = movement_delay)
	AddComponent(/datum/component/basic_mob_attack_telegraph)
	AddComponentFrom(INNATE_TRAIT, /datum/component/shovel_hands)

