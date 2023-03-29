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
		pixel_x = 0
		pixel_y = 0

/mob/proc/pixel_shift(direction)
	return

/* Добавить больше мест, где вручную это вызывается
/mob/living/set_pull_offsets(mob/living/pull_target, grab_state)
	pull_target.unpixel_shift()
	return ..()

/mob/living/reset_pull_offsets(mob/living/pull_target, override)
	pull_target.unpixel_shift()
	return ..()
*/

/mob/living/pixel_shift(direction)
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

/*

https://github.com/tgstation/tgstation/issues/48659
https://github.com/Skyrat-SS13/Skyrat-tg/pull/6527

/mob/living/CanPass(atom/movable/mover, border_dir)
	// Make sure to not allow projectiles of any kind past where they normally wouldn't.
	if(!istype(mover, /obj/projectile) && !mover.throwing && passthroughable & border_dir)
		return TRUE
	return ..()
*/

#undef MAXIMUM_PIXEL_SHIFT
#undef PASSABLE_SHIFT_THRESHOLD
