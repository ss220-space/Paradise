/// We won't use tentacles unless we have had the same target for this long
#define MIN_TIME_TO_TENTACLE 3 SECONDS

/datum/ai_controller/basic_controller/goliath
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items/goliath,
	)



/datum/targetting_datum/basic/allow_items/goliath
	stat_attack = UNCONSCIOUS

/datum/ai_planning_subtree/basic_melee_attack_subtree/goliath
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/goliath

/// Go for the tentacles if they're available
/datum/ai_behavior/basic_melee_attack/goliath

/datum/ai_behavior/basic_melee_attack/goliath/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
