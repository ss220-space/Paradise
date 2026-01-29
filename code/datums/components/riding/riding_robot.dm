/datum/component/riding/robot
	var/active_state = TRUE
	rider_traits = list(TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)

/datum/component/riding/robot/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = NONE, potion_boost = FALSE)
	if(!isrobot(parent))
		return COMPONENT_INCOMPATIBLE

	. = ..()

/datum/component/riding/robot/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ROBOT_RIDERS_EJECT, PROC_REF(eject_riders))
	RegisterSignal(parent, COMSIG_ROBOT_RIDERS_EJECT_HARM, PROC_REF(harmful_eject_riders))

/datum/component/riding/robot/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ROBOT_RIDERS_EJECT,
		COMSIG_ROBOT_RIDERS_EJECT_HARM
	))

/datum/component/riding/robot/proc/eject_riders(datum/source)
	SIGNAL_HANDLER
	var/mob/living/silicon/robot/parent_robot = parent
	if(!length(parent_robot.buckled_mobs))
		return

	for(var/mob/ridder as anything in parent_robot.buckled_mobs)
		parent_robot.unbuckle_mob(ridder, TRUE)
		ridder.pixel_y = initial(ridder.pixel_y) //Костыльный багфикс
		ridder.pixel_x = initial(ridder.pixel_x)

/datum/component/riding/robot/proc/harmful_eject_riders(datum/source)
	SIGNAL_HANDLER
	var/mob/living/silicon/robot/parent_robot = parent

	if(!length(parent_robot.buckled_mobs))
		return

	for(var/mob/living/buckled_mob as anything in parent_robot.buckled_mobs)
		var/atom/target = get_edge_target_turf(parent_robot, parent_robot.dir)
		var/mob/living/victim = buckled_mob //save him for future time
		parent_robot.unbuckle_mob(buckled_mob, TRUE)
		victim.throw_at(target, 5, 10)
		victim.visible_message(span_warning("[victim.declent_ru(NOMINATIVE)] вылета[PLUR_ET_YUT(victim)] из кресла [parent_robot.declent_ru(GENITIVE)]!"))

	do_sparks(5, 0, parent_robot)

/datum/component/riding/robot/handle_specials()
	. = ..()

	var/mob/living/silicon/robot/parent_robot = parent

	set_riding_offsets(RIDING_OFFSET_ALL,
	list(
		TEXT_NORTH = parent_robot.selected_skin.north_offset,
		TEXT_SOUTH = parent_robot.selected_skin.south_offset,
	  	TEXT_EAST = parent_robot.selected_skin.east_offset,
	   	TEXT_WEST = parent_robot.selected_skin.west_offset
	))

	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)
