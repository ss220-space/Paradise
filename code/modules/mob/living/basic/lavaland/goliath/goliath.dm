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
	var/obj/effect/proc_holder/spell/basic/basic_goliath_tentacles/tentacles
	/// Our base tentacles ability
	var/obj/effect/proc_holder/spell/basic/basic_tentacle_burst/melee_tentacles
	/// Our base tentacles ability
	var/obj/effect/proc_holder/spell/basic/basic_tentacle_grasp/tentacle_line
	/// Things we want to eat off the floor (or a plate, we're not picky)
	var/static/list/goliath_foods = list(/obj/item/reagent_containers/food/snacks/grown/ash_flora, /obj/item/reagent_containers/food/snacks/bait)

/mob/living/basic/mining/goliath/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_TENTACLE_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)
	AddElement(/datum/element/basic_eating, heal_amt = 10, food_types = goliath_foods)
	AddElement(/datum/element/move_cooldown, move_delay = movement_delay)
	AddElement(\
		/datum/element/change_force_on_death,\
		move_force = MOVE_FORCE_DEFAULT,\
		move_resist = MOVE_RESIST_DEFAULT,\
		pull_force = PULL_FORCE_DEFAULT,\
	)
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/basic_mob_attack_telegraph)
	AddComponentFrom(INNATE_TRAIT, /datum/component/shovel_hands)
	if(tameable)
		AddComponent(/datum/component/tameable, tame_chance = 10, bonus_tame_chance = 5)
	tentacles = new
	AddSpell(tentacles)
	melee_tentacles = new
	AddSpell(melee_tentacles)
	tentacle_line = new
	AddSpell(tentacle_line)

	AddComponent(/datum/component/revenge_ability, melee_tentacles, targeting = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY]), max_range = 1, target_self = TRUE)
	AddComponent(/datum/component/revenge_ability, tentacle_line, targeting = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY]), min_range = 2, max_range = 9)

	tentacles_ready()

	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(used_ability))
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(goliath_foods))
	ai_controller.set_blackboard_key(BB_GOLIATH_TENTACLES, tentacles)

/mob/living/basic/mining/goliath/Destroy()
	QDEL_NULL(tentacles)
	QDEL_NULL(melee_tentacles)
	QDEL_NULL(tentacle_line)
	return ..()

/mob/living/basic/mining/goliath/examine(mob/user)
	. = ..()
	if(saddled)
		. += span_info("Кажется кто-то надел на него седло.")

// Goliaths can summon tentacles more frequently if they got hit
/mob/living/basic/mining/goliath/apply_damage(damage, damagetype, def_zone, blocked, sharp, used_weapon, spread_damage, forced, silent, updating_health, update_damage_icon)
	. = ..()
	if(!.)
		return
	if(damage <= 0)
		return
	if(prob(25))
		tentacles.revert_cast()

/mob/living/basic/mining/goliath/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!istype(attacking_item, /obj/item/goliath_saddle))
		return ..()
	if(!tameable)
		balloon_alert(user, "не налезает!")
		return
	if(saddled)
		balloon_alert(user, "уже осёдлан!")
		return
	if(!tamed)
		balloon_alert(user, "слишком агрессивный!")
		return
	balloon_alert(user, "крепим седло...")
	if(!do_after(user, delay = 5.5 SECONDS, target = src))
		return
	balloon_alert(user, "можно кататься!")
	qdel(attacking_item)
	make_rideable()

/mob/living/basic/mining/goliath/proc/make_rideable()
	saddled = TRUE
	add_overlay("goliath_saddled")
	//AddElement(/datum/element/ridable, /datum/component/riding/creature/goliath)

/// When we use an ability, activate some kind of visual tell
/mob/living/basic/mining/goliath/proc/used_ability(mob/living/source, obj/effect/proc_holder/spell/ability)
	SIGNAL_HANDLER
	if(stat == DEAD || !ability.can_cast(source, TRUE))
		return // We died or the action failed for some reason like being out of range

	if(istype(ability, /obj/effect/proc_holder/spell/basic/basic_goliath_tentacles))
		var/cooldown_time = ability.cooldown_handler.get_recharge_time()
		var/needed_world_time = world.time + 2 SECONDS
		var/test = needed_world_time - cooldown_time
		if(cooldown_time <= needed_world_time)
			return
		icon_state = icon_living
		addtimer(CALLBACK(src, PROC_REF(tentacles_ready)), test + 2 SECONDS, TIMER_DELETE_ME)
		return
	if(!COOLDOWN_FINISHED(src, ability_animation_cooldown))
		return
	COOLDOWN_START(src, ability_animation_cooldown, 2 SECONDS)
	playsound(src, 'sound/misc/demon_attack1.ogg', vol = 50)
	Shake(1, 0, 1.5 SECONDS)

/// Called slightly before tentacles ability comes off cooldown, as a warning
/mob/living/basic/mining/goliath/proc/tentacles_ready()
	if(stat == DEAD)
		return
	icon_state = tentacle_warning_state

/// Get ready for mounting
/mob/living/basic/mining/goliath/tamed(mob/living/tamer, atom/food)
	tamed = TRUE

// Copy entire faction rather than just placing user into faction, to avoid tentacle peril on station
/mob/living/basic/mining/goliath/befriend(mob/living/new_friend)
	. = ..()
	if(isnull(.))
		return
	faction = new_friend.faction.Copy()





/// Use this to ride a goliath
/obj/item/goliath_saddle
	name = "goliath saddle"
	desc = "This rough saddle will give you a serviceable seat upon a goliath! Provided you can get one to stand still."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_saddle"
