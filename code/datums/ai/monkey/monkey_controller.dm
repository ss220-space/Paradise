/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

/datum/ai_controller/monkey
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.4 SECONDS
	planning_subtrees = list(
		/datum/ai_planning_subtree/monkey_combat,
		/datum/ai_planning_subtree/monkey_tree,
	)
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/monkey,
		BB_MONKEY_AGGRESSIVE = FALSE,
		BB_MONKEY_BEST_FORCE_FOUND = 0,
		BB_MONKEY_ENEMIES = list(),
		BB_MONKEY_BLACKLISTITEMS = list(),
		BB_MONKEY_PICKUPTARGET = null,
		BB_MONKEY_PICKPOCKETING = FALSE,
		BB_MONKEY_DISPOSING = FALSE,
		BB_MONKEY_TARGET_DISPOSAL = null,
		BB_MONKEY_CURRENT_ATTACK_TARGET = null,
		BB_MONKEY_GUN_NEURONS_ACTIVATED = FALSE,
		BB_MONKEY_GUN_WORKED = TRUE,
		BB_MONKEY_NEXT_HUNGRY = 0
	)
	idle_behavior = /datum/idle_behavior/idle_monkey

/datum/targeting_strategy/basic/monkey

/datum/targeting_strategy/basic/monkey/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if(controller.blackboard[BB_MONKEY_ENEMIES][the_target])
		return FALSE
	return ..()


/datum/ai_controller/monkey/angry

/datum/ai_controller/monkey/angry/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	blackboard[BB_MONKEY_AGGRESSIVE] = TRUE //Angry cunt

/datum/ai_controller/monkey/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	blackboard[BB_MONKEY_NEXT_HUNGRY] = world.time + rand(0, 300)

	var/mob/living/living_pawn = new_pawn

	living_pawn.AddElement(/datum/element/relay_attackers)
	RegisterSignal(new_pawn, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

	RegisterSignal(new_pawn, COMSIG_MOVABLE_CROSS, PROC_REF(on_Crossed))
	RegisterSignal(new_pawn, COMSIG_LIVING_START_PULL, PROC_REF(on_startpulling))
	RegisterSignal(new_pawn, COMSIG_LIVING_TRY_SYRINGE, PROC_REF(on_try_syringe))
	RegisterSignal(new_pawn, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(on_attempt_cuff))
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))
	RegisterSignal(new_pawn, COMSIG_FOOD_EATEN, PROC_REF(on_eat))
	RegisterSignal(new_pawn, COMSIG_LIVING_RESTING, PROC_REF(on_resting))

	movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..() //Run parent at end

/datum/ai_controller/monkey/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(
			COMSIG_ATOM_WAS_ATTACKED,
			COMSIG_LIVING_START_PULL,
			COMSIG_LIVING_TRY_SYRINGE,
			COMSIG_CARBON_CUFF_ATTEMPTED,
			COMSIG_MOB_MOVESPEED_UPDATED,
			COMSIG_FOOD_EATEN,
			COMSIG_LIVING_RESTING,
			COMSIG_MOVABLE_CROSS,
			))
	return ..() //Run parent at end

// Stops sentient monkeys from being knocked over like weak dunces.
/datum/ai_controller/monkey/on_sentience_gained()
	. = ..()
	UnregisterSignal(pawn, COMSIG_MOVABLE_CROSS)

/datum/ai_controller/monkey/on_sentience_lost()
	. = ..()
	RegisterSignal(pawn, COMSIG_MOVABLE_CROSS)

/datum/ai_controller/monkey/able_to_run()
	. = ..()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE

///re-used behavior pattern by monkeys for finding a weapon
/datum/ai_controller/monkey/proc/TryFindWeapon()
	var/mob/living/living_pawn = pawn

	if(!locate(/obj/item) in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand()))
		blackboard[BB_MONKEY_BEST_FORCE_FOUND] = 0

	if(blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED] && (locate(/obj/item/gun) in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand())))
		// We have a gun, what could we possibly want?
		return FALSE

	var/obj/item/weapon
	var/list/nearby_items = list()
	for(var/obj/item/item in oview(2, living_pawn))
		nearby_items += item

	weapon = GetBestWeapon(nearby_items, list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand()))

	var/pickpocket = FALSE
	for(var/mob/living/carbon/human/human in oview(5, living_pawn))
		var/obj/item/held_weapon = GetBestWeapon(list(human.get_active_hand(), human.get_inactive_hand()) + weapon, list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand()))
		if(held_weapon == weapon) // It's just the same one, not a held one
			continue
		pickpocket = TRUE
		weapon = held_weapon

	if(!weapon || (weapon in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand())))
		return FALSE

	blackboard[BB_MONKEY_PICKUPTARGET] = weapon
	set_movement_target(weapon)
	if(pickpocket)
		queue_behavior(/datum/ai_behavior/monkey_equip/pickpocket)
	else
		queue_behavior(/datum/ai_behavior/monkey_equip/ground)
		return TRUE

/// Returns either the best weapon from the given choices or null if held weapons are better
/datum/ai_controller/monkey/proc/GetBestWeapon(list/choices, list/held_weapons)
	var/gun_neurons_activated = blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED]
	var/top_force = 0
	var/obj/item/top_force_item
	for(var/obj/item/item as anything in held_weapons)
		if(!item)
			continue
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && istype(item, /obj/item/gun))
			// We have a gun, why bother looking for something inferior
			// Also yes it is intentional that monkeys dont know how to pick the best gun
			return item
		if(item.force > top_force)
			top_force = item.force
			top_force_item = item

	for(var/obj/item/item as anything in choices)
		if(!item)
			continue
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && istype(item, /obj/item/gun))
			return item
		if(item.force <= top_force)
			continue
		top_force_item = item
		top_force = item.force

	return top_force_item

/datum/ai_controller/monkey/proc/IsEdible(obj/item/thing)
	if(istype(thing, /obj/item/reagent_containers/food))
		return TRUE
	if(istype(thing, /obj/item/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = thing
		if(glass.reagents.total_volume) // The glass has something in it, time to drink the mystery liquid!
			return TRUE
	return FALSE

///Reactive events to being hit
/datum/ai_controller/monkey/proc/retaliate(mob/living/living_mob)
	// just to be safe
	if(QDELETED(living_mob))
		return

	add_blackboard_key_assoc(BB_MONKEY_ENEMIES, living_mob, MONKEY_HATRED_AMOUNT)

/datum/ai_controller/monkey/proc/on_attacked(datum/source, mob/attacker)
	SIGNAL_HANDLER
	if(prob(MONKEY_RETALIATE_PROB))
		retaliate(attacker)

/datum/ai_controller/monkey/proc/on_Crossed(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && isliving(arrived))
		var/mob/living/in_the_way_mob = arrived
		in_the_way_mob.knockOver(living_pawn)
		return

/datum/ai_controller/monkey/proc/on_startpulling(datum/source, atom/movable/puller, state, force)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && prob(MONKEY_PULL_AGGRO_PROB)) // nuh uh you don't pull me!
		retaliate(living_pawn.pulledby)
		return TRUE

/datum/ai_controller/monkey/proc/on_try_syringe(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_SYRINGE_RETALIATION_PROB))
		retaliate(user)


/datum/ai_controller/monkey/proc/on_attempt_cuff(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_CUFF_RETALIATION_PROB))
		retaliate(user)

/datum/ai_controller/monkey/proc/update_movespeed(mob/living/pawn)
	SIGNAL_HANDLER
	movement_delay = pawn.cached_multiplicative_slowdown

/datum/ai_controller/monkey/proc/target_del(target)
	SIGNAL_HANDLER
	blackboard[BB_MONKEY_BLACKLISTITEMS] -= target

/datum/ai_controller/monkey/proc/on_eat(mob/living/pawn)
	SIGNAL_HANDLER
	blackboard[BB_MONKEY_NEXT_HUNGRY] = world.time + rand(120, 600) SECONDS

/datum/ai_controller/monkey/proc/on_resting(new_resting)
	SIGNAL_HANDLER
	queue_behavior(/datum/ai_behavior/resist)
