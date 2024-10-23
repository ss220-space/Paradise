/**
 * Move a client in a direction
 *
 * Huge proc, has a lot of functionality
 *
 * Mostly it will despatch to the mob that you are the owner of to actually move
 * in the physical realm
 *
 * Things that stop you moving as a mob:
 * * world time being less than your next move_delay
 * * not being in a mob, or that mob not having a loc
 * * missing the new_loc and direct parameters
 * * having TRAIT_NO_TRANSFORM
 * * being in remote control of an object (calls Move_object instead)
 * * being dead (it ghosts you instead)
 *
 * Things that stop you moving as a mob living (why even have OO if you're just shoving it all
 * in the parent proc with istype checks right?):
 * * having incorporeal_move set (calls Process_Incorpmove() instead)
 * * being in remote control of a movable, (calls remote_control() instead)
 * * being grabbed
 * * being buckled  (relaymove() is called to the buckled atom instead)
 * * having your loc be some other mob (relaymove() is called on that mob instead)
 * * Not having MOBILITY_MOVE
 * * Failing Process_Spacemove() call
 *
 * At this point, if the mob is is confused, then a random direction and target turf will be calculated for you to travel to instead
 *
 * Now the parent call is made (to the byond builtin move), which moves you
 *
 * Some final move delay calculations (doubling if you moved diagonally successfully)
 *
 * If mob throwing is set I believe it's unset at this point via a call to finalize
 *
 * Finally if you're pulling an object and it's dense, you are turned 180 after the move
 * (if you ask me, this should be at the top of the move so you don't dance around)			// LATER
 *
 */
/client/Move(new_loc, direct)
	if(world.time < move_delay)	//do not move anything ahead of this check please
		return FALSE

	next_move_dir_add = NONE
	next_move_dir_sub = NONE
	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag //this is here because Move() can now be called multiple times per tick

	if(!direct || !new_loc)
		return FALSE

	if(!mob || !mob.loc)
		return FALSE

	if(HAS_TRAIT(mob, TRAIT_NO_TRANSFORM))
		return FALSE //This is sota the goto stop mobs from moving var

	if(mob.control_object)
		return mob.control_object.possessed_relay_move(mob, direct)

	if(!isliving(mob))
		return mob.Move(new_loc, direct)

	if(mob.stat == DEAD)
		mob.ghostize()
		return FALSE

	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, new_loc, direct) & COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE)
		return FALSE

	var/mob/living/living_mob = mob	//Already checked for isliving earlier
	if(living_mob.incorporeal_move)//Move though walls
		Process_Incorpmove(direct)
		return FALSE

	if(mob.remote_control) //we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		if(istype(mob.loc, /obj/item/aicard))
			return mob.loc.relaymove(mob, direct) // aicards have special relaymove stuff
		return AIMove(new_loc, direct, mob)

	if(Process_Grab())
		return FALSE

	if(mob.buckled) //if we're buckled to something, tell it we moved.
		return mob.buckled.relaymove(mob, direct)

	if(!(living_mob.mobility_flags & MOBILITY_MOVE))
		return FALSE

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if(ismovable(mob.loc)) //Inside an object, tell it we moved
		return mob.loc.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return FALSE

	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_MOVE, args) & COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE)
		return FALSE

	//We are now going to move
	var/add_delay = mob.cached_multiplicative_slowdown
	var/new_glide_size = DELAY_TO_GLIDE_SIZE(add_delay * ((NSCOMPONENT(direct) && EWCOMPONENT(direct)) ? sqrt(2) : 1))
	mob.set_glide_size(new_glide_size) // set it now in case of pulled objects
	//If the move was recent, count using old_move_delay
	//We want fractional behavior and all
	if(old_move_delay + world.tick_lag > world.time)
		//Yes this makes smooth movement stutter if add_delay is too fractional
		//Yes this is better then the alternative
		move_delay = old_move_delay
	else
		move_delay = world.time

	//Basically an optional override for our glide size
	//Sometimes you want to look like you're moving with a delay you don't actually have yet
	visual_delay = 0
	var/old_dir = mob.dir

	. = ..()

	if(ISDIAGONALDIR(direct) && mob.loc == new_loc) //moved diagonally successfully
		add_delay *= sqrt(2)

	var/after_glide = 0
	if(visual_delay)
		after_glide = visual_delay
	else
		after_glide = DELAY_TO_GLIDE_SIZE(add_delay)

	mob.set_glide_size(after_glide)

	move_delay += add_delay

	if(.) // If mob is null here, we deserve the runtime
		mob.last_movement = world.time
		mob.throwing?.finalize()

		// At this point we've moved the client's attached mob. This is one of the only ways to guess that a move was done
		// as a result of player input and not because they were pulled or any other magic.
		SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_MOVED, direct, old_dir)


/**
 * Checks to see if you're being grabbed and if so attempts to break it
 *
 * Called by client/Move()
 */
/client/proc/Process_Grab()
	if(!mob.pulledby)
		return FALSE
	if(mob.pulledby == mob.pulling && mob.pulledby.grab_state == GRAB_PASSIVE) //Don't autoresist passive grabs if we're grabbing them too.
		return FALSE
	if(HAS_TRAIT(mob, TRAIT_INCAPACITATED))
		move_delay = world.time + 1 SECONDS
		return TRUE
	else if(HAS_TRAIT(mob, TRAIT_RESTRAINED))
		move_delay = world.time + 1 SECONDS
		to_chat(mob, span_warning("Вы скованы и не можете пошевелиться!"))
		return TRUE
	return mob.resist_grab(moving_resist = TRUE)


/**
 * Allows mobs to ignore density and phase through objects
 *
 * Called by client/Move()
 *
 * The behaviour depends on the incorporeal_move value of the mob
 *
 * * INCORPOREAL_MOVE_BASIC - forceMoved to the next tile with no stop
 * * INCORPOREAL_NINJA  - the same but leaves a cool effect path
 * * INCORPOREAL_REVENANT - the same but blocked by holy tiles
 *
 * You'll note this is another mob living level proc living at the client level
 */
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!mobloc || !isliving(mob))
		return FALSE
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(INCORPOREAL_NORMAL)
			var/T = get_step(L, direct)
			if(T)
				L.forceMove(T)
			L.setDir(direct)
		if(INCORPOREAL_NINJA)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				var/target = locate(locx,locy,mobloc.z)
				if(target)
					L.forceMove(target)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in get_line(mobloc, L.loc))
						new /obj/effect/temp_visual/dir_setting/ninja/shadow(T, L.dir)
						limit--
						if(limit <= 0)
							break
			else
				new /obj/effect/temp_visual/dir_setting/ninja/shadow(mobloc, L.dir)
				var/T = get_step(L, direct)
				if(T)
					L.forceMove(T)
			L.setDir(direct)
		if(INCORPOREAL_REVENANT) //Incorporeal move, but blocked by holy-watered tiles
			var/turf/simulated/floor/stepTurf = get_step(L, direct)
			if(stepTurf)
				if(stepTurf.turf_flags & NOJAUNT)
					move_delay += 0.5 SECONDS
					to_chat(L, span_warning("Святые силы блокируют Ваш путь."))
					return FALSE
				L.forceMove(stepTurf)
			L.setDir(direct)
	return TRUE


/**
 * Handles mob/living movement in space (or no gravity)
 *
 * Called by /client/Move()
 *
 * return TRUE for movement or FALSE for none
 *
 * You can move in space if you have a spacewalk ability
 */
/mob/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	. = ..()
	if(.)
		return .

	if(buckled)
		return TRUE

	var/atom/movable/backup = get_spacemove_backup(movement_dir, continuous_move)
	if(!backup)
		return FALSE

	if(continuous_move || !istype(backup) || !movement_dir || backup.anchored)
		return TRUE

	// last pushoff exists for one reason
	// to ensure pushing a mob doesn't just lead to it considering us as backup, and failing
	last_pushoff = world.time
	if(backup.newtonian_move(REVERSE_DIR(movement_dir), instant = TRUE)) //You're pushing off something movable, so it moves
		// We set it down here so future calls to Process_Spacemove by the same pair in the same tick don't lead to fucky
		backup.last_pushoff = world.time
		to_chat(src, span_info("Вы отталкиваетесь от [backup.name] для продолжения движения."))

	return TRUE


/mob/get_spacemove_backup(moving_direction, continuous_move)
	for(var/atom/pushover as anything in range(1, get_turf(src)))
		if(pushover == src)
			continue
		if(isarea(pushover))
			continue
		if(isturf(pushover))
			var/turf/turf = pushover
			if(isspaceturf(turf))
				continue
			if(!turf.density && !mob_negates_gravity())
				continue
			return turf

		var/atom/movable/rebound = pushover
		if(rebound == buckled)
			continue

		if(ismob(rebound))
			var/mob/lover = rebound
			if(lover.buckled)
				continue

		var/pass_allowed = rebound.CanPass(src, get_dir(rebound, src))
		if(!rebound.density && pass_allowed)
			continue
		//Sometime this tick, this pushed off something. Doesn't count as a valid pushoff target
		if(rebound.last_pushoff == world.time)
			continue
		if(continuous_move && !pass_allowed)
			var/datum/move_loop/move/rebound_engine = SSmove_manager.processing_on(rebound, SSspacedrift)
			// If you're moving toward it and you're both going the same direction, stop
			if(moving_direction == get_dir(src, pushover) && rebound_engine && moving_direction == rebound_engine.direction)
				continue
		else if(!pass_allowed)
			if(moving_direction == get_dir(src, pushover)) // Can't push "off" of something that you're walking into
				continue
		if(rebound.anchored)
			return rebound
		if(pulling == rebound)
			continue
		return rebound


/mob/has_gravity(turf/gravity_turf)
	if(!isnull(GLOB.gravity_is_on))	// global admin override.
		return GLOB.gravity_is_on
	return mob_negates_gravity() || ..()


/**
 * Does this mob ignore gravity
 */
/mob/proc/mob_negates_gravity()
	return FALSE


/client/proc/check_has_body_select()
	return mob && mob.hud_used && mob.hud_used.zone_select && istype(mob.hud_used.zone_select, /atom/movable/screen/zone_sel)

/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.zone_selected)
		if(BODY_ZONE_HEAD)
			next_in_line = BODY_ZONE_PRECISE_EYES
		if(BODY_ZONE_PRECISE_EYES)
			next_in_line = BODY_ZONE_PRECISE_MOUTH
		else
			next_in_line = BODY_ZONE_HEAD

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line)

/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_R_ARM)
		next_in_line = BODY_ZONE_PRECISE_R_HAND
	else
		next_in_line = BODY_ZONE_R_ARM

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line)

/client/verb/body_chest()
	set name = "body-chest"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_CHEST)
		next_in_line = BODY_ZONE_WING
	else
		next_in_line = BODY_ZONE_CHEST

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line)

/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_L_ARM)
		next_in_line = BODY_ZONE_PRECISE_L_HAND
	else
		next_in_line = BODY_ZONE_L_ARM

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line)

/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_R_LEG)
		next_in_line = BODY_ZONE_PRECISE_R_FOOT
	else
		next_in_line = BODY_ZONE_R_LEG

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line)

/client/verb/body_groin()
	set name = "body-groin"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_PRECISE_GROIN)
		next_in_line = BODY_ZONE_TAIL
	else
		next_in_line = BODY_ZONE_PRECISE_GROIN

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line)

/client/verb/body_tail()
	set name = "body-tail"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_TAIL)

/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/next_in_line
	if(mob.zone_selected == BODY_ZONE_L_LEG)
		next_in_line = BODY_ZONE_PRECISE_L_FOOT
	else
		next_in_line = BODY_ZONE_L_LEG

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line)


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(iscarbon(mob))
		var/mob/living/carbon/C = mob
		C.toggle_throw_mode()
	else
		to_chat(usr, "<span class='danger'>Это существо не может бросать предметы.</span>")


/mob/proc/toggle_move_intent(new_move_intent)
	return

/mob/verb/move_up()
	set name = "Move Upwards"
	set category = "IC"

	if(remote_control)
		return remote_control.relaymove(src, UP)

	var/turf/current_turf = get_turf(src)
	var/turf/above_turf = GET_TURF_ABOVE(current_turf)

	if(!above_turf)
		to_chat(src, "<span class='warning'>There's nowhere to go in that direction!</span>")
		return

	if(ismovable(loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, UP)

	var/ventcrawling_flag = HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) ? ZMOVE_VENTCRAWLING : NONE
	if(can_z_move(DOWN, above_turf, current_turf, ZMOVE_FALL_FLAGS|ventcrawling_flag)) //Will we fall down if we go up?
		if(buckled)
			to_chat(src, "<span class='notice'>[buckled] is is not capable of flight.<span>")
		else
			to_chat(src, "<span class='notice'>You are not Superman.<span>")
		return
	if(zMove(UP, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK|ventcrawling_flag))
		to_chat(src, span_notice("You move upwards."))

/mob/verb/move_down()
	set name = "Move Down"
	set category = "IC"

	if(remote_control)
		return remote_control.relaymove(src, DOWN)

	var/turf/current_turf = get_turf(src)
	var/turf/below_turf = GET_TURF_BELOW(current_turf)

	if(!below_turf)
		to_chat(src, span_warning("There's nowhere to go in that direction!"))
		return

	if(ismovable(loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, DOWN)

	var/ventcrawling_flag = HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) ? ZMOVE_VENTCRAWLING : NONE
	if(zMove(DOWN, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK|ventcrawling_flag))
		to_chat(src, span_notice("You move down."))
	return FALSE
