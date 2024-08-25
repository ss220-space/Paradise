/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"
	base_icon_state = "fire_extinguisher"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags = CONDUCT
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 7
	force = 10
	container_type = AMOUNT_VISIBLE
	materials = list(MAT_METAL=90)
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")
	dog_fashion = /datum/dog_fashion/back
	resistance_flags = FIRE_PROOF
	/// The max amount of water this extinguisher can hold.
	var/max_water = 50
	/// Does the welder extinguisher start with water.
	var/starting_water = TRUE
	/// Cooldown between uses.
	var/last_use = 1
	/// Can we actually fire currently?
	var/safety = TRUE
	/// Maximum distance launched water will travel.
	var/power = 5
	/// By default, turfs picked from a spray are random, set to TRUE to make it always have at least one water effect per row.
	var/precision = FALSE
	/// Sets the cooling_temperature of the water reagent datum inside of the extinguisher when it is refilled.
	var/cooling_power = 2


/obj/item/extinguisher/mini
	name = "pocket fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	base_icon_state = "miniFE"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags = null //doesn't CONDUCT
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	force = 3.0
	materials = list()
	max_water = 30
	dog_fashion = null


/obj/item/extinguisher/Initialize(mapload)
	. = ..()
	if(!reagents)
		create_reagents(max_water)
		reagents.add_reagent("water", max_water)


/obj/item/extinguisher/examine(mob/user)
	. = ..()
	. += span_info("The safety is <b>[safety ? "on" : "off"]</b>.")


/obj/item/extinguisher/update_icon_state()
	icon_state = "[base_icon_state][!safety]"


/obj/item/extinguisher/update_desc(updates = ALL)
	. = ..()
	desc = "The safety is [safety ? "on" : "off"]."


/obj/item/extinguisher/attack_self(mob/user)
	safety = !safety
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
	to_chat(user, "The safety is [safety ? "on" : "off"].")


/obj/item/extinguisher/attack_obj(obj/object, mob/living/user, params)
	if(AttemptRefill(object, user))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/extinguisher/proc/AttemptRefill(atom/target, mob/user)
	if(istype(target, /obj/structure/reagent_dispensers/watertank) && target.Adjacent(user))
		var/safety_save = safety
		safety = TRUE
		if(reagents.total_volume == reagents.maximum_volume)
			to_chat(user, span_notice("[src] is already full!"))
			safety = safety_save
			return TRUE
		var/obj/structure/reagent_dispensers/watertank/watertank = target
		var/transferred = watertank.reagents.trans_to(src, max_water)
		if(transferred > 0)
			to_chat(user, span_notice("[src] has been refilled by [transferred] units."))
			playsound(loc, 'sound/effects/refill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			for(var/datum/reagent/water/reagent in reagents.reagent_list)
				reagent.cooling_temperature = cooling_power
		else
			to_chat(user, span_notice("[watertank] is empty!"))
		safety = safety_save
		return TRUE
	return FALSE


/obj/item/extinguisher/afterattack(atom/target, mob/user, flag, params)
	. = ..()
	//TODO; Add support for reagents in water.
	if(target.loc == user)//No more spraying yourself when putting your extinguisher away
		return

	if(safety)
		return

	if(reagents.total_volume < 1)
		to_chat(user, span_danger("[src] is empty."))
		return

	if(world.time < last_use + 2 SECONDS)
		return
	last_use = world.time

	if(reagents.chem_temp > 300 || reagents.chem_temp < 280)
		add_attack_logs(user, target, "Sprayed with superheated or cooled fire extinguisher at Temperature [reagents.chem_temp]K")
	playsound(loc, 'sound/effects/extinguish.ogg', 75, TRUE, -3)

	var/direction = get_dir(src,target)

	if(user.buckled && isobj(user.buckled) && !user.buckled.anchored)
		var/movementdirection = REVERSE_DIR(direction)
		addtimer(CALLBACK(src, PROC_REF(move_chair), user.buckled, movementdirection), 0.1 SECONDS)
	else
		user.newtonian_move(REVERSE_DIR(direction))

	//Get all the turfs that can be shot at
	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)
	if(precision)
		var/turf/T3 = get_step(T1, turn(direction, 90))
		var/turf/T4 = get_step(T2,turn(direction, -90))
		the_targets.Add(T3,T4)

	var/list/water_particles = list()
	for(var/a in 1 to 5)
		var/obj/effect/particle_effect/water/extinguisher/water = new (get_turf(src))
		var/my_target = pick(the_targets)
		water_particles[water] = my_target
		// If precise, remove turf from targets so it won't be picked more than once
		if(precision)
			the_targets -= my_target
		var/datum/reagents/water_reagents = new(5)
		water.reagents = water_reagents
		water_reagents.my_atom = water
		reagents.trans_to(water, 1)

	//Make em move dat ass, hun
	move_particles(water_particles)


//Particle movement loop
/obj/item/extinguisher/proc/move_particles(list/particles)
	var/delay = 2
	// Second loop: Get all the water particles and make them move to their target
	for(var/obj/effect/particle_effect/water/extinguisher/water as anything in particles)
		water.move_at(particles[water], delay, power)


//Chair movement loop
/obj/item/extinguisher/proc/move_chair(obj/buckled_object, movementdirection)
	var/datum/move_loop/loop = SSmove_manager.move(buckled_object, movementdirection, 1, timeout = 9, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	//This means the chair slowing down is dependant on the extinguisher existing, which is weird
	//Couldn't figure out a better way though
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(manage_chair_speed))


/obj/item/extinguisher/proc/manage_chair_speed(datum/move_loop/move/source)
	SIGNAL_HANDLER
	switch(source.lifetime)
		if(4 to 5)
			source.delay = 2
		if(1 to 3)
			source.delay = 3

