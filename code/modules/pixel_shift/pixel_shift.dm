#define MAXIMUM_PIXEL_SHIFT 12 //ORIGINAL: 16
#define PASSABLE_SHIFT_THRESHOLD 8

/mob
	/// Whether the mob is pixel shifted or not
	var/is_shifted = FALSE
	/// If we are in the shifting setting.
	var/shifting = FALSE
	/// Takes the four cardinal direction defines. Any atoms moving into this atom's tile will be allowed to from the added directions.
	var/passthroughable = NONE

/datum/keybinding/mob/pixel_shift
	keys = list("B")
	name = "Pixel Shift"
	category = KB_CATEGORY_MOVEMENT

/datum/keybinding/mob/pixel_shift/down(client/user)
	. = ..()
	var/mob/M = user.mob
	M.shifting = TRUE

/datum/keybinding/mob/pixel_shift/up(client/user)
	. = ..()
	var/mob/M = user.mob
	M.shifting = FALSE

/mob/proc/unpixel_shift()
	return

/mob/living/unpixel_shift()
	. = ..()
	passthroughable = NONE
	if(is_shifted)
		is_shifted = FALSE
		pixel_x = get_standard_pixel_x_offset(lying)
		pixel_y = get_standard_pixel_y_offset(lying)

/mob/proc/pixel_shift(direction)
	return

/mob/living/Move_Pulled(atom/A)
	. = ..()
	if(!. || !isliving(A))
		return
	var/mob/living/pulled_mob = A
	pulled_mob.unpixel_shift()

/mob/living/forceMove(atom/destination)
	. = ..()
	if(.)
		unpixel_shift()

/mob/living/pixel_shift(direction)
	if(restrained() || IsWeakened() || length(grabbed_by) || stat > CONSCIOUS || buckled)
		return
	passthroughable = NONE
	switch(direction)
		if(NORTH)
			if(pixel_y <= MAXIMUM_PIXEL_SHIFT)
				pixel_y++
				is_shifted = TRUE
		if(EAST)
			if(pixel_x <= MAXIMUM_PIXEL_SHIFT)
				pixel_x++
				is_shifted = TRUE
		if(SOUTH)
			if(pixel_y >= -MAXIMUM_PIXEL_SHIFT)
				pixel_y--
				is_shifted = TRUE
		if(WEST)
			if(pixel_x >= -MAXIMUM_PIXEL_SHIFT)
				pixel_x--
				is_shifted = TRUE

	// Yes, I know this sets it to true for everything if more than one is matched.
	// Movement doesn't check diagonals, and instead just checks EAST or WEST, depending on where you are for those.
	if(pixel_y > PASSABLE_SHIFT_THRESHOLD)
		passthroughable |= EAST | SOUTH | WEST
	if(pixel_x > PASSABLE_SHIFT_THRESHOLD)
		passthroughable |= NORTH | SOUTH | WEST
	if(pixel_y < -PASSABLE_SHIFT_THRESHOLD)
		passthroughable |= NORTH | EAST | WEST
	if(pixel_x < -PASSABLE_SHIFT_THRESHOLD)
		passthroughable |= NORTH | EAST | SOUTH

/atom/movable/post_buckle_mob(mob/living/M)
	. = ..()
	M.unpixel_shift()

/mob/living/CanPass(atom/movable/mover, turf/target, height)
	if(!istype(mover, /obj/item/projectile) && !mover.throwing && passthroughable & get_dir(src, mover))
		return TRUE
	return ..()

#undef MAXIMUM_PIXEL_SHIFT
#undef PASSABLE_SHIFT_THRESHOLD
