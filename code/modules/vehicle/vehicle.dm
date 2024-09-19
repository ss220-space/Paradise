
/obj/vehicle
	name = "vehicle"
	desc = "A basic vehicle, vroom"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "scooter"
	density = TRUE
	anchored = FALSE
	pass_flags_self = PASSVEHICLE
	can_buckle = TRUE
	pull_push_slowdown = 1
	buckle_lying = 0
	max_integrity = 300
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	/// Item required for the vehicle to be inserted into the ignition.
	var/obj/item/key_type
	/// Whehter our key should be in mob hands, rather than in the vehicle ignintion.
	var/key_in_hands = FALSE
	/// Currently inserted key.
	var/obj/item/key/inserted_key
	/// To allow non-space vehicles to move in no gravity or not, mostly for adminbus.
	var/needs_gravity = FALSE
	/// All dirs apply this pixel_x for the driver.
	var/generic_pixel_x = 0
	/// All dirs apply this pixel_y for the driver.
	var/generic_pixel_y = 0
	/// If we have a xenobio red potion applied to us.
	var/potion_boosted = FALSE
	/// Delay between movements in deciseconds, lower = faster, higher = slower
	var/vehicle_move_delay = 0.35 SECONDS
	COOLDOWN_DECLARE(vehicle_move_cooldown)


/obj/vehicle/Initialize(mapload)
	. = ..()
	handle_vehicle_layer()
	handle_vehicle_icons()


/obj/vehicle/Destroy()
	QDEL_NULL(inserted_key)
	return ..()


/obj/vehicle/examine(mob/user)
	. = ..()
	if(key_type)
		if(key_in_hands)
			. += span_info("[src] requires the [initial(key_type.name)] to be held in hands to start driving.")
		else
			if(inserted_key)
				. += span_info("<b>Alt-click</b> [src] to remove the key.")
			else
				. += span_info("[src] requires the [initial(key_type.name)] to be inserted into ignintion to start driving.")

	if(resistance_flags & ON_FIRE)
		. += span_warning("It's on fire!")
	var/healthpercent = obj_integrity/max_integrity * 100
	switch(healthpercent)
		if(50 to 99)
			. += span_notice("It looks slightly damaged.")
		if(25 to 50)
			. += span_notice("It appears heavily damaged.")
		if(0 to 25)
			. += span_warning("It's falling apart!")


/obj/vehicle/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(key_type && I.type == key_type)
		add_fingerprint(user)
		if(inserted_key)
			to_chat(user, span_warning("The [name] already has [inserted_key.name] in the ignition!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		inserted_key = I
		to_chat(user, span_notice("You have inserted [I] into [src]'s ignintion."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/vehicle/AltClick(mob/living/user)
	if(!istype(user) || !Adjacent(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!inserted_key)
		to_chat(user, span_warning("[src] has no inserted keys!"))
		return
	if(!(user in buckled_mobs))
		to_chat(user, span_warning("You must be riding [src] to remove [src]'s key!"))
		return
	to_chat(user, span_notice("You remove [inserted_key] from [src]."))
	inserted_key.forceMove_turf()
	user.put_in_hands(inserted_key, ignore_anim = FALSE)
	inserted_key = null


/obj/vehicle/proc/keycheck(mob/user, provide_feedback = TRUE)
	if(!key_type)
		return TRUE
	if(key_in_hands)
		if(!(user.l_hand && user.l_hand.type == key_type) && !(user.r_hand && user.r_hand.type == key_type))
			if(provide_feedback)
				to_chat(user, span_warning("You'll need the [initial(key_type.name)] in one of your hands to drive [src]!"))
			return FALSE
		return TRUE
	if(!(inserted_key && inserted_key.type == key_type))
		if(provide_feedback)
			to_chat(user, span_warning("[src] has no inserted keys!"))
		return FALSE
	return TRUE


/// Checks to see if we've been hit with a red xenobio potion to make us faster.
/obj/vehicle/proc/check_potion(obj/item/slimepotion/speed/speed_potion, mob/living/user)
	if(potion_boosted)
		to_chat(user, span_warning("[user] has already been coated with red, that's as fast as it'll go!"))
		return FALSE
	if(has_buckled_mobs()) // effect won't take place till the next time someone mounts it, so just prevent that situation
		to_chat(user, span_warning("It's too dangerous to smear [speed_potion] on [src] while it's being ridden!"))
		return FALSE
	var/speed_limit = round(CONFIG_GET(number/movedelay/run_delay) + get_config_multiplicative_speed_by_path(/mob/living/carbon/human), 0.01)
	if(vehicle_move_delay <= speed_limit) // I say speed but this is actually move delay, so you have to be ABOVE the speed limit to pass
		to_chat(user, span_warning("[src] can't be made any faster!"))
		return FALSE
	vehicle_move_delay = speed_limit
	potion_boosted = TRUE
	to_chat(user, span_notice("You slather the red gunk over [src], making it faster."))
	remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	add_atom_colour(COLOR_RED, FIXED_COLOUR_PRIORITY)
	qdel(speed_potion)
	return TRUE


//APPEARANCE
/obj/vehicle/proc/handle_vehicle_layer()
	if(!has_buckled_mobs())
		layer = OBJ_LAYER
		return
	if(dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER


/// Used to update vehicle icons if needed
/obj/vehicle/proc/handle_vehicle_icons()
	return


//Override this to set your vehicle's various pixel offsets
//if they differ between directions, otherwise use the
//generic variables
/obj/vehicle/proc/handle_vehicle_offsets()
	if(!has_buckled_mobs())
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.setDir(dir)
		buckled_mob.pixel_x = generic_pixel_x
		buckled_mob.pixel_y = generic_pixel_y


/// Used to update dir of buckled mobs on Move().
/obj/vehicle/proc/handle_buckled_dir()
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.setDir(dir)


/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY


//BUCKLE HOOKS
/obj/vehicle/post_buckle_mob(mob/living/target)
	handle_vehicle_layer()
	handle_vehicle_offsets()
	handle_vehicle_icons()


/obj/vehicle/post_unbuckle_mob(mob/living/target)
	target.pixel_x = target.base_pixel_x + target.body_position_pixel_x_offset
	target.pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset
	handle_vehicle_offsets()
	handle_vehicle_layer()
	handle_vehicle_icons()


/obj/vehicle/bullet_act(obj/item/projectile/Proj)
	if(!has_buckled_mobs())
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.bullet_act(Proj)


//MOVEMENT

/obj/vehicle/relaymove(mob/user, direction)
	if(!COOLDOWN_FINISHED(src, vehicle_move_cooldown) || !has_buckled_mobs() || user != buckled_mobs[1])
		return FALSE

	var/turf/next_step = get_step(src, direction)
	if(!next_step || !isturf(loc) || !Process_Spacemove(direction) || !keycheck(user))
		COOLDOWN_START(src, vehicle_move_cooldown, 0.5 SECONDS)
		return FALSE

	if(user.incapacitated())
		unbuckle_mob(user)
		return FALSE

	var/add_delay = vehicle_move_delay

	. = Move(next_step, direction)
	if(ISDIAGONALDIR(direction) && loc == next_step)
		add_delay *= sqrt(2)

	set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay))
	COOLDOWN_START(src, vehicle_move_cooldown, add_delay)


/obj/vehicle/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	handle_vehicle_layer()
	handle_vehicle_offsets()
	handle_vehicle_icons()
	handle_buckled_dir()


/obj/vehicle/Bump(atom/bumped_atom)
	. = ..()
	if(. || !has_buckled_mobs() || !istype(bumped_atom, /obj/machinery/door))
		return .
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		bumped_atom.Bumped(buckled_mob)


/obj/vehicle/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	if(needs_gravity)
		return TRUE
	return ..()


/obj/vehicle/space
	pressure_resistance = INFINITY


/obj/vehicle/space/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

