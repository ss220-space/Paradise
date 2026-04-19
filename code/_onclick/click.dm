//Delays the mob's next click by num deciseconds
// eg: 10-3 = 7 deciseconds of delay
// eg: 10*0.5 = 5 deciseconds of delay
// DOES NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK

/mob/proc/changeNext_click(num)
	next_click = world.time + ((num + next_move_adjust) * next_move_modifier)

/mob/proc/changeNext_move(num)
	next_move = world.time + ((num + next_move_adjust) * next_move_modifier)

/**
 * Before anything else, defer these calls to a per-mobtype handler.  This allows us to
 * remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.
 *
 * Alternately, you could hardcode every mob's variation in a flat [/mob/proc/ClickOn] proc; however,
 * that's a lot of code duplication and is hard to maintain.
 *
 * Note that this proc can be overridden, and is in the case of screen objects.
 */
/atom/Click(location,control,params)
	usr.ClickOn(src, params, location)

/atom/DblClick(location,control,params)
	usr.DblClickOn(src,params)

/**
 * Standard mob ClickOn()
 *
 * After that, mostly just check your state, check whether you're holding an item,
 * check whether you're adjacent to the target, then pass off the click to whoever is receiving it.
 *
 * The most common are:
 * * [mob/proc/UnarmedAttack] (atom, adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
 * * [atom/proc/attackby] (item, user) - used only when adjacent
 * * [obj/item/proc/melee_attack_chain(user, atom, params) - used only when atom is adjacent adn was clicked byt in hand item
 * * [mob/proc/RangedAttack] (atom, modifiers) - used only ranged, only used for tk and laser eyes but could be changed
 */
/mob/proc/ClickOn(atom/A, params)
	if(next_click > world.time)
		return
	changeNext_click(1)

	if(check_click_intercept(params,A) || HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	var/list/modifiers = params2list(params)

	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, modifiers) & COMSIG_MOB_CANCEL_CLICKON)
		return

	if(LAZYACCESS(modifiers, BUTTON4) || LAZYACCESS(modifiers, BUTTON5))
		return

	var/button_clicked = LAZYACCESS(modifiers, BUTTON)

	var/dragged = LAZYACCESS(modifiers, DRAG)
	if(dragged && button_clicked != dragged)
		return

	if(IsFrozen(A) && !is_admin(usr))
		to_chat(usr, span_boldannounceooc("Interacting with admin-frozen players is not permitted."))
		return

	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, modifiers) & COMSIG_MOB_CANCEL_CLICKON)
		return

	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		if(LAZYACCESS(modifiers, SHIFT_CLICK))
			if(LAZYACCESS(modifiers, CTRL_CLICK))
				MiddleShiftControlClickOn(A)
				return
			MiddleShiftClickOn(A)
			return
		MiddleClickOn(A)
		return

	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			CtrlShiftClickOn(A)
			return
		if(LAZYACCESS(modifiers, ALT_CLICK))
			AltShiftClickOn(A)
			return
		ShiftClickOn(A)
		return

	if(LAZYACCESS(modifiers, ALT_CLICK))
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			AltClickSecondaryOn(A)
		else
			AltClickOn(A)
		return

	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return

	if(incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
		return

	if(is_ventcrawling(usr) && isitem(A)) // stops inventory actions in vents
		var/obj/item/item = A
		if(item.item_flags & (IN_INVENTORY|IN_STORAGE))
			return

	face_atom(A)

	if(next_move > world.time) // in the year 2000...
		return

	if(!LAZYACCESS(modifiers, "catcher") && A.IsObscured())
		return

	if(ismecha(loc))
		if(!locate(/turf) in list(A,A.loc)) // Prevents inventory from being drilled
			return
		var/obj/mecha/M = loc
		return M.click_action(A, src, modifiers)

	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		changeNext_move(CLICK_CD_HANDCUFFED) //Doing shit in cuffs shall be vey slow
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		if(throw_item(A))
			changeNext_move(CLICK_CD_THROW)
		return

	if(isLivingSSD(A))
		if(client && client.send_ssd_warning(A))
			return

	var/obj/item/W = get_active_hand()

	if(W == A)
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			W.attack_self_secondary(src, modifiers)
			update_held_items()
			return
		else
			W.attack_self(src, modifiers)
			update_held_items()
			return

	// operate three levels deep here (item in backpack in src; item in box in backpack in src, not any deeper)
	var/sdepth = A.storage_depth(src)
	if(A == loc || (A in loc) || (sdepth != -1 && sdepth <= 2))
		// No adjacency needed
		beforeAdjacentClick(A, modifiers)
		if(W)
			W.melee_attack_chain(src, A, modifiers)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A, 1, modifiers)

		return

	if(!loc.allow_click()) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	// Allows you to click on a box's contents, if that box is on the ground, but no deeper than that
	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.IsReachableBy(src, W?.reach))
			beforeAdjacentClick(A, modifiers)
			if(W)
				W.melee_attack_chain(src, A, modifiers)
			else
				if(ismob(A))
					changeNext_move(CLICK_CD_MELEE)
				UnarmedAttack(A, 1, modifiers)

			return
		else // non-adjacent click
			beforeRangedClick(A, modifiers)
			if(W)
				A.base_ranged_item_interaction(src, W, modifiers)
			else
				if(LAZYACCESS(modifiers, RIGHT_CLICK))
					ranged_secondary_attack(A, modifiers)
				else
					RangedAttack(A, modifiers)

	return

/mob/proc/beforeAdjacentClick(atom/A, list/modifiers)
	return

/mob/proc/beforeRangedClick(atom/A, list/modifiers)
	return

//Is the atom obscured by a PREVENT_CLICK_UNDER object above it
/atom/proc/IsObscured()
	if(!isturf(loc)) //This only makes sense for things directly on turfs for now
		return FALSE
	var/turf/T = get_turf_pixel(src)
	if(!T)
		return FALSE
	for(var/atom/movable/AM in T)
		if(AM.flags & PREVENT_CLICK_UNDER && AM.density && AM.layer > layer)
			return TRUE
	return FALSE

/turf/IsObscured()
	for(var/atom/movable/AM in src)
		if(AM.flags & PREVENT_CLICK_UNDER && AM.density)
			return TRUE
	return FALSE

/**
 * Returns TRUE if a movable can "Reach" this atom. This is defined as adjacency
 *
 * Args:
 * * user: The movable trying to reach us.
 * * reacher_range: How far the reacher can reach.
 * * depth: How deep nested inside of an atom contents stack an object can be.
 * * direct_access: Do not override. Used for recursion.
 */
/atom/proc/IsReachableBy(atom/movable/user, reacher_range = 1, depth = INFINITY, direct_access = user.DirectAccess())
	SHOULD_NOT_OVERRIDE(TRUE)

	if(isnull(user))
		return FALSE

	if(src in direct_access)
		return TRUE

	// This is a micro-opt, if any turf ever returns false from IsContainedAtomAccessible, change this.
	if(isturf(loc) || isturf(src))
		if(CheckReachableAdjacency(user, reacher_range))
			return TRUE

	depth--

	if(depth <= 0)
		return FALSE

	if(isnull(loc) || isarea(loc))
		return FALSE
	if(!HAS_TRAIT(src, TRAIT_SKIP_BASIC_REACH_CHECK) && !loc.IsContainedAtomAccessible(src, user))
		return FALSE

	return loc.IsReachableBy(user, reacher_range, depth, direct_access)

/atom/proc/CheckReachableAdjacency(atom/movable/reacher, reacher_range)
	if(reacher.Adjacent(src))
		return TRUE

	if(isliving(reacher))
		var/mob/living/living_reacher = reacher
		if(living_reacher.reach_length > reacher_range)
			reacher_range = living_reacher.reach_length

	return (reacher_range > 1) && RangedReachCheck(reacher, src, reacher_range)

/// Called by IsReachableBy() to check for ranged reaches.
/proc/RangedReachCheck(atom/movable/here, atom/movable/there, reach)
	if(!here || !there)
		return FALSE

	if(reach <= 1)
		return FALSE

	// Prevent infinite loop.
	if(istype(here, /obj/effect/abstract/reach_checker))
		return FALSE

	var/obj/effect/abstract/reach_checker/dummy = new(get_turf(here))
	for(var/i in 1 to reach) //Limit it to that many tries
		var/turf/target_turf = get_step(dummy, get_dir(dummy, there))
		if(there.IsReachableBy(dummy))
			. = TRUE
			break

		if(!dummy.Move(target_turf)) //we're blocked!
			break

	qdel(dummy)

/// Returns TRUE if an atom contained within our contents is reachable.
/atom/proc/IsContainedAtomAccessible(atom/contained, atom/movable/user)
	return TRUE

/atom/proc/DirectAccess()
	return list(src, loc)

/mob/DirectAccess(atom/target)
	return ..() + contents

/mob/living/DirectAccess(atom/target)
	return ..() + get_all_contents()

/atom/proc/AllowClick()
	return FALSE

/turf/AllowClick()
	return TRUE

/proc/CheckToolReach(atom/movable/here, atom/movable/there, reach)
	if(!here || !there)
		return
	var/turf/current_turf = get_turf(here)
	if(current_turf.z != there.z)
		return FALSE
	switch(reach)
		if(0)
			return FALSE
		if(1)
			return FALSE //here.Adjacent(there)
		if(2 to INFINITY)
			var/obj/dummy = new(current_turf)
			dummy.pass_flags |= PASSTABLE
			dummy.invisibility = INVISIBILITY_ABSTRACT
			for(var/i in 1 to reach) //Limit it to that many tries
				var/turf/target_turf = get_step(dummy, get_dir(dummy, there))
				if(there.IsReachableBy(dummy))
					qdel(dummy)
					return TRUE
				if(!dummy.Move(target_turf)) //we're blocked!
					qdel(dummy)
					return
			qdel(dummy)

/// Default behavior: ignore double clicks (the second click that makes the doubleclick call already calls for a normal click)
/mob/proc/DblClickOn(atom/target, params)
	return

/**
 * UnarmedAttack: The higest level of mob click chain discounting click itself.
 *
 * This handles, just "clicking on something" without an item. It translates
 * into [atom/proc/attack_hand], [atom/proc/attack_animal] etc.
 *
 * Note: proximity_flag here is used to distinguish between normal usage (flag=1),
 * and usage when clicking on things telekinetically (flag=0).  This proc will
 * not be called at ranged except with telekinesis.
 *
 * proximity_flag is not currently passed to attack_hand, and is instead used
 * in human click code to allow glove touches only at melee range.
 *
 * modifiers is a lazy list of click modifiers this attack had,
 * used for figuring out different properties of the click, mostly right vs left and such.
 */
/mob/proc/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	if(ismob(target))
		changeNext_move(CLICK_CD_MELEE)

	return OnUnarmedAttack(target, proximity_flag, modifiers)

/mob/proc/OnUnarmedAttack(atom/target, proximity_flag, list/modifiers)
	return

/**
 * Ranged unarmed attack:
 *
 * This currently is just a default for all mobs, involving
 * laser eyes and telekinesis.  You could easily add exceptions
 * for things like ranged glove touches, spitting alien acid/neurotoxin,
 * animals lunging, etc.
 */
/mob/proc/RangedAttack(atom/A, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_MOB_ATTACK_RANGED, A, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

	if(SEND_SIGNAL(A, COMSIG_MOB_ATTACKED_RANGED, src, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/**
 * Ranged secondary attack
 *
 * If the same conditions are met to trigger RangedAttack but it is
 * instead initialized via a right click, this will trigger instead.
 * Useful for mobs that have their abilities mapped to right click.
 */
/mob/proc/ranged_secondary_attack(atom/target, modifiers)
	if(SEND_SIGNAL(src, COMSIG_MOB_ATTACK_RANGED_SECONDARY, target, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/*
	Restrained ClickOn

	Used when you are handcuffed and click things.
	Not currently used by anything but could easily be.
*/
/mob/proc/RestrainedClickOn(atom/A)
	return

/*
	Middle click
	Only used for pointing
*/
/mob/proc/MiddleClickOn(atom/A)
	pointed(A)
	return

// See click_override.dm
/mob/living/MiddleClickOn(atom/A)
	. = SEND_SIGNAL(src, COMSIG_MOB_MIDDLECLICKON, A)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	if(middleClickOverride)
		middleClickOverride.onClick(A, src)
	else
		..()

/*
	Middle shift-click
	Makes the mob face the direction of the clicked thing
*/
/mob/proc/MiddleShiftClickOn(atom/A)
	return

/mob/living/MiddleShiftClickOn(atom/A)
	if(incapacitated())
		return
	var/face_dir = get_cardinal_dir(src, A)
	if(!face_dir || forced_look == face_dir || A == src)
		clear_forced_look()
		return
	set_forced_look(A, FALSE)

/*
	Middle shift-control-click
	Makes the mob constantly face the object (until it's out of sight)
*/
/mob/proc/MiddleShiftControlClickOn(atom/A)
	return

/mob/living/MiddleShiftControlClickOn(atom/A)
	if(incapacitated())
		return
	var/face_uid = A.UID()
	if(forced_look == face_uid || A == src)
		clear_forced_look()
		return
	set_forced_look(A, TRUE)

/**
 * Shift click
 * For most mobs, examine.
 * This is overridden in ai.dm
 */
/mob/proc/ShiftClickOn(atom/target)
	target.ShiftClick(src)
	return

/atom/proc/ShiftClick(mob/user)
	if(user.client && get_turf(user.client.eye) == get_turf(user))
		user.examinate(src)
	return

/*
	Ctrl click
	For most objects, pull
*/
/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)
	return

/atom/proc/CtrlClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL, user)
	var/mob/living/ML = user
	if(istype(ML))
		ML.pulled(src)

/mob/living/CtrlClick(mob/living/user)
	if(!isliving(user) || !user.Adjacent(src) || user.incapacitated())
		return ..()

	if(world.time < user.next_move)
		return FALSE

	if(user.grab(src))
		user.changeNext_move(CLICK_CD_MELEE)
		return TRUE

	return ..()

/mob/proc/TurfAdjacent(turf/tile)
	return tile.Adjacent(src)

/**
 * Control+Shift click
 * Unused except for AI
 */
/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)
	return

/atom/proc/CtrlShiftClick(mob/user)
	return

/mob/proc/AltShiftClickOn(atom/A)
	A.AltShiftClick(src)
	return

/atom/proc/AltShiftClick(mob/user)
	return

/atom/proc/allow_click()
	return FALSE

/turf/allow_click()
	return TRUE

/*
	Misc helpers

	Laser Eyes: as the name implies, handles this since nothing else does currently
	face_atom: turns the mob towards what you clicked on
*/
/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	changeNext_move(CLICK_CD_RANGE)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)

	var/obj/projectile/beam/LE = new /obj/projectile/beam(loc)
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, TRUE)

	LE.firer = src
	LE.def_zone = ran_zone(zone_selected)
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	LE.fire()

/// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(atom/atom_to_face)
	if(stat || buckled || !atom_to_face || !x || !y || !atom_to_face.x || !atom_to_face.y)
		return FALSE
	var/dx = atom_to_face.x - x
	var/dy = atom_to_face.y - y
	if(!dx && !dy)
		return FALSE

	var/direction
	if(abs(dx) < abs(dy))
		if(dy > 0)
			direction = NORTH
		else
			direction = SOUTH
	else
		if(dx > 0)
			direction = EAST
		else
			direction = WEST

	setDir(direction)
	return TRUE

/atom/movable/screen/click_catcher
	icon_state = "catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "CENTER"

#define MAX_SAFE_BYOND_ICON_SCALE_TILES (MAX_SAFE_BYOND_ICON_SCALE_PX / ICON_SIZE_ALL)
#define MAX_SAFE_BYOND_ICON_SCALE_PX (33 * 32) //Not using world.icon_size on purpose.

/atom/movable/screen/click_catcher/proc/UpdateGreed(view_size_x = 15, view_size_y = 15)
	var/icon/newicon = icon('icons/mob/screen_gen.dmi', "catcher")
	var/ox = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_x)
	var/oy = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_y)
	var/px = view_size_x * ICON_SIZE_X
	var/py = view_size_y * ICON_SIZE_Y
	var/sx = min(MAX_SAFE_BYOND_ICON_SCALE_PX, px)
	var/sy = min(MAX_SAFE_BYOND_ICON_SCALE_PX, py)
	newicon.Scale(sx, sy)
	icon = newicon
	screen_loc = "CENTER-[(ox-1)*0.5],CENTER-[(oy-1)*0.5]"
	var/matrix/M = new
	M.Scale(px/sx, py/sy)
	transform = M

/atom/movable/screen/click_catcher/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(offset_increased))
	offset_increased(SSmapping, 0, SSmapping.max_plane_offset)

// Draw to the lowest plane level offered
/atom/movable/screen/click_catcher/proc/offset_increased(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	SET_PLANE_W_SCALAR(src, initial(plane), new_offset)

/atom/movable/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK) && iscarbon(usr))
		var/mob/living/carbon/carbon = usr
		carbon.swap_hand()
	else
		var/turf/click_turf = parse_caught_click_modifiers(modifiers, get_turf(usr.client ? usr.client.eye : usr), usr.client)
		if(click_turf)
			modifiers["catcher"] = TRUE
			click_turf.Click(click_turf, control, list2params(modifiers))
	. = 1


/mob/proc/check_click_intercept(params,A)
	//Client level intercept
	if(client?.click_intercept)
		if(call(client.click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	//Mob level intercept
	if(click_intercept)
		if(call(click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	return FALSE

#undef MAX_SAFE_BYOND_ICON_SCALE_TILES
#undef MAX_SAFE_BYOND_ICON_SCALE_PX
