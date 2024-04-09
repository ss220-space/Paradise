/* Tables and Racks
 * Contains:
 *		Tables
 *		Glass Tables
 *		Wooden Tables
 *		Reinforced Tables
 *		Racks
 *		Rack Parts
 */

/*
 * Tables
 */

/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/table.dmi'
	icon_state = "table"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags_self = PASSTABLE|LETPASSTHROW
	climbable = TRUE
	max_integrity = 100
	integrity_failure = 30
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/table, /obj/structure/table/reinforced)
	creates_cover = TRUE
	var/frame = /obj/structure/table_frame
	var/framestack = /obj/item/stack/rods
	var/buildstack = /obj/item/stack/sheet/metal
	var/busy = FALSE
	var/buildstackamount = 1
	var/framestackamount = 2
	var/deconstruction_ready = TRUE
	var/flip_sound = 'sound/machines/wooden_closet_close.ogg'
	var/flipped = FALSE
	/// Can this table be flipped?
	var/can_be_flipped = TRUE

/obj/structure/table/flipped
	flipped = TRUE
	icon_state = "tableflip0"

/obj/structure/table/Initialize(mapload)
	. = ..()
	if(flipped)
		smooth = SMOOTH_FALSE
		update_icon(UPDATE_ICON_STATE)


/obj/structure/table/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)
	if(can_be_flipped)
		if(flipped)
			. += span_info("<b>Alt-Shift-Click</b> to right the table again.")
		else
			. += span_info("<b>Alt-Shift-Click</b> to flip over the table.")


/obj/structure/table/proc/deconstruction_hints(mob/user)
	return "<span class='notice'>The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.</span>"


/obj/structure/table/update_icon(updates = ALL)
	. = ..()
	update_smoothing()


/obj/structure/table/update_icon_state()
	if(smooth && !flipped)
		icon_state = ""

	if(flipped)
		var/type = 0
		var/subtype = null
		for(var/direction in list(turn(dir,90), turn(dir,-90)) )
			var/obj/structure/table/other_table = locate(/obj/structure/table,get_step(src,direction))
			if(other_table?.flipped)
				type++
				if(type == 1)
					subtype = direction == turn(dir,90) ? "-" : "+"
		var/base = "table"
		if(istype(src, /obj/structure/table/wood))
			base = "wood"
		else if(istype(src, /obj/structure/table/reinforced))
			base = "rtable"
		else if(istype(src, /obj/structure/table/wood/poker))
			base = "poker"
		else if(istype(src, /obj/structure/table/wood/fancy))
			base = "fancy"
		else if(istype(src, /obj/structure/table/wood/fancy/black))
			base = "fancyblack"
		icon_state = "[base]flip[type][type == 1 ? subtype : ""]"


/obj/structure/table/proc/update_smoothing()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)

	if(flipped)
		clear_smooth_overlays()


/obj/structure/table/narsie_act()
	new /obj/structure/table/wood(loc)
	qdel(src)

/obj/structure/table/ratvar_act()
	new /obj/structure/table/reinforced/brass(loc)
	qdel(src)

/obj/structure/table/do_climb(mob/living/user)
	. = ..()
	item_placed(user)

/obj/structure/table/attack_hand(mob/living/user)
	..()
	if(climber)
		climber.Weaken(4 SECONDS)
		climber.visible_message("<span class='warning'>[climber.name] has been knocked off the table", "You've been knocked off the table", "You hear [climber.name] get knocked off the table</span>")
	else if(Adjacent(user) && user.pulling && user.pulling.pass_flags & PASSTABLE)
		user.Move_Pulled(src)
		if(user.pulling.loc == loc)
			user.visible_message("<span class='notice'>[user] places [user.pulling] onto [src].</span>",
				"<span class='notice'>You place [user.pulling] onto [src].</span>")
			user.stop_pulling()

/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/proc/item_placed(item)
	return

/obj/structure/table/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(AM.throwing && isliving(AM))
		var/mob/living/user = AM
		clumse_stuff(user)


/obj/structure/table/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return TRUE
	if(isprojectile(mover))
		return check_cover(mover)
	if(mover.throwing)
		return TRUE
	if(mover.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return TRUE
	if(length(get_atoms_of_type(get_turf(mover), /obj/structure/table) - mover))
		var/obj/structure/table/other_table = locate(/obj/structure/table) in get_turf(mover)
		if(!other_table.flipped)
			return TRUE
	if(flipped)
		return dir != border_dir


/obj/structure/table/CanPathfindPass(obj/item/card/id/ID, dir, caller, no_id = FALSE)
	. = !density
	if(checkpass(caller, PASSTABLE))
		. = TRUE


/**
 * Determines whether a projectile crossing our turf should be stopped.
 * Return FALSE to stop the projectile.
 *
 * Arguments:
 * * P - The projectile trying to cross.
 */
/obj/structure/table/proc/check_cover(obj/item/projectile/P)
	. = TRUE

	if(!flipped)
		return .

	if(in_range(P.starting, loc)) // Tables won't help you if people are THIS close
		return .

	var/proj_dir = get_dir(P, loc)
	var/block_dir = get_dir(get_step(loc, dir), loc)
	var/full_protection = (proj_dir & block_dir)
	var/half_protection = ((proj_dir == get_clockwise_dir(block_dir)) || (proj_dir == get_anticlockwise_dir(block_dir)))

	if(!full_protection && !half_protection)	// Back/side shots may pass
		return .

	if(prob(half_protection ? 40 : 60))
		return FALSE // Blocked


/obj/structure/table/CanExit(atom/movable/mover, moving_direction)
	. = ..()
	if(checkpass(mover, PASSTABLE))
		return TRUE
	if(flipped)
		return dir != moving_direction


/obj/structure/table/MouseDrop_T(obj/dropping, mob/user, params)
	if(..())
		return TRUE
	if(!isitem(dropping) || user.get_active_hand() != dropping)
		return FALSE
	if(isrobot(user))
		return FALSE
	if(!user.drop_item_ground(dropping))
		return FALSE
	if(dropping.loc != loc)
		add_fingerprint(user)
		step(dropping, get_dir(dropping, src))
		return TRUE


/obj/structure/table/proc/tablepush(obj/item/grab/G, mob/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(user, "<span class='danger'>Throwing [G.affecting] onto the table might hurt them!</span>")
		return
	if(get_dist(src, user) < 2)
		if(G.affecting.buckled)
			to_chat(user, "<span class='warning'>[G.affecting] is buckled to [G.affecting.buckled]!</span>")
			return FALSE
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return FALSE
		if(!G.confirm())
			return FALSE
		var/blocking_object = density_check(user)
		if(blocking_object)
			to_chat(user, "<span class='warning'>You cannot do this there is \a [blocking_object] in the way!</span>")
			return FALSE
		G.affecting.forceMove(get_turf(src))
		G.affecting.Weaken(4 SECONDS)
		item_placed(G.affecting)
		G.affecting.visible_message("<span class='danger'>[G.assailant] pushes [G.affecting] onto [src].</span>", \
									"<span class='userdanger'>[G.assailant] pushes [G.affecting] onto [src].</span>")
		add_attack_logs(G.assailant, G.affecting, "Pushed onto a table")
		qdel(G)
		return TRUE
	qdel(G)


/obj/structure/table/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grab))
		add_fingerprint(user)
		tablepush(I, user)
		return

	if(user.a_intent != INTENT_HARM && !(I.flags & (ABSTRACT | NODROP)))
		if(user.transfer_item_to_loc(I, src.loc))
			add_fingerprint(user)
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
			item_placed(I)
	else
		if(isrobot(user))
			return
		return ..()


/obj/structure/table/screwdriver_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	if(!deconstruction_ready)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume) && deconstruction_ready)
		deconstruct(TRUE)
		TOOL_DISMANTLE_SUCCESS_MESSAGE


/obj/structure/table/wrench_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	if(!deconstruction_ready)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume) && deconstruction_ready)
		deconstruct(TRUE, 1)
		TOOL_DISMANTLE_SUCCESS_MESSAGE


/obj/structure/table/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags & NODECONSTRUCT))
		var/turf/T = get_turf(src)
		new buildstack(T, buildstackamount)
		if(!wrench_disassembly)
			new frame(T)
		else
			new framestack(T, framestackamount)
	qdel(src)


/obj/structure/table/proc/straight_table_check(direction)
	var/obj/structure/table/check_table
	for(var/angle in list(-90, 90))
		check_table = locate() in get_step(loc, turn(direction, angle))
		if(check_table && !check_table.flipped)
			return FALSE
	check_table = locate() in get_step(loc, direction)
	if(!check_table || check_table.flipped)
		return TRUE
	if(istype(check_table, /obj/structure/table/reinforced) && !check_table.deconstruction_ready)
		return FALSE
	return check_table.straight_table_check(direction)


/obj/structure/table/AltShiftClick(mob/user)
	actual_flip(user)


/obj/structure/table/verb/do_flip()
	set name = "Flip/Unflip table"
	set desc = "Flips or unflips a table"
	set category = null
	set src in oview(1)
	actual_flip(usr)


/obj/structure/table/proc/actual_flip(mob/living/user)
	if(!can_be_flipped || !can_touch(user))
		return FALSE

	if(!flipped)
		if(!flip(get_cardinal_dir(user, src)))
			to_chat(user, span_notice("It won't budge."))
			return

		user.visible_message("<span class='warning'>[user] flips \the [src]!</span>")

		if(climbable)
			structure_shaken()
	else
		if(!unflip())
			to_chat(user, span_notice("It won't budge."))


/obj/structure/table/proc/flip(direction)
	if(flipped)
		return FALSE

	if(!straight_table_check(turn(direction,90)) || !straight_table_check(turn(direction,-90)))
		return FALSE

	var/list/targets = list(get_step(src,dir),get_step(src,turn(dir, 45)),get_step(src,turn(dir, -45)))
	for(var/atom/movable/thing in get_turf(src))
		if(!thing.anchored)
			INVOKE_ASYNC(thing, TYPE_PROC_REF(/atom/movable, throw_at), pick(targets), 1, 1)

	dir = direction
	if(dir != NORTH)
		layer = 5
	flipped = TRUE
	smooth = SMOOTH_FALSE
	flags |= ON_BORDER
	playsound(loc, flip_sound, 100, TRUE)

	for(var/check_dir in list(turn(direction, 90), turn(direction, -90)))
		var/obj/structure/table/other_table = locate(/obj/structure/table, get_step(src, check_dir))
		if(other_table)
			other_table.flip(direction)
	update_icon(UPDATE_ICON_STATE)

	creates_cover = FALSE
	if(isturf(loc))
		REMOVE_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))

	return TRUE


/obj/structure/table/proc/unflip()
	if(!flipped)
		return FALSE

	var/can_flip = TRUE
	for(var/mob/check in oview(src, 0))
		can_flip = FALSE
		break
	if(!can_flip)
		return FALSE

	layer = initial(layer)
	flipped = FALSE
	smooth = initial(smooth)
	flags &= ~ON_BORDER
	playsound(loc, flip_sound, 100, TRUE)

	for(var/check_dir in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/table/other_table = locate(/obj/structure/table, get_step(src, check_dir))
		if(other_table)
			other_table.unflip()
	dir = initial(dir)
	update_icon(UPDATE_ICON_STATE)

	creates_cover = TRUE
	if(isturf(loc))
		ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))

	return TRUE


/*
 * Glass Tables
 */

/obj/structure/table/glass
	name = "glass table"
	desc = "Looks fragile. You should totally flip it. It is begging for it."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table"
	buildstack = /obj/item/stack/sheet/glass
	canSmoothWith = null
	max_integrity = 70
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	var/list/debris = list()

/obj/structure/table/glass/Initialize(mapload)
	. = ..()
	debris += new frame
	debris += new /obj/item/shard

/obj/structure/table/glass/Destroy()
	for(var/i in debris)
		qdel(i)
	. = ..()


/obj/structure/table/glass/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(flags & NODECONSTRUCT)
		return
	if(!isliving(AM))
		return

	// Don't break if they're just flying past
	if(AM.throwing)
		addtimer(CALLBACK(src, PROC_REF(throw_check), AM), 5)
	else
		check_break(AM)


/obj/structure/table/glass/proc/throw_check(mob/living/M)
	if(M.loc == get_turf(src))
		check_break(M)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(M.incorporeal_move || (M.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return
	if(M.has_gravity() && M.mob_size > MOB_SIZE_SMALL)
		table_shatter(M)

/obj/structure/table/glass/flip(direction)
	deconstruct(FALSE)

/obj/structure/table/glass/proc/table_shatter(mob/living/L)
	visible_message("<span class='warning'>[src] breaks!</span>",
		"<span class='danger'>You hear breaking glass.</span>")
	var/turf/T = get_turf(src)
	playsound(T, "shatter", 50, 1)
	for(var/I in debris)
		var/atom/movable/AM = I
		AM.forceMove(T)
		debris -= AM
		if(istype(AM, /obj/item/shard))
			AM.throw_impact(L)
	L.Weaken(10 SECONDS)
	qdel(src)

/obj/structure/table/glass/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			..()
			return
		else
			var/turf/T = get_turf(src)
			playsound(T, "shatter", 50, TRUE)
			for(var/X in debris)
				var/atom/movable/AM = X
				AM.forceMove(T)
				debris -= AM
	qdel(src)

/obj/structure/table/glass/narsie_act()
	color = NARSIE_WINDOW_COLOUR
	for(var/obj/item/shard/S in debris)
		S.color = NARSIE_WINDOW_COLOUR

/*
 * Wooden tables
 */
/obj/structure/table/wood
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table"
	frame = /obj/structure/table_frame/wood
	framestack = /obj/item/stack/sheet/wood
	buildstack = /obj/item/stack/sheet/wood
	max_integrity = 70
	canSmoothWith = list(/obj/structure/table/wood, /obj/structure/table/wood/poker)
	resistance_flags = FLAMMABLE

/obj/structure/table/wood/narsie_act(total_override = TRUE)
	if(!total_override)
		..()

/obj/structure/table/wood/flipped
	flipped = TRUE
	icon_state = "woodflip0"

/obj/structure/table/wood/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	icon_state = "poker_table"
	buildstack = /obj/item/stack/tile/carpet

/obj/structure/table/wood/poker/narsie_act()
	..(FALSE)

/*
 * Fancy Tables
 */

/obj/structure/table/wood/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/smooth_structures/fancy_table.dmi'
	icon_state = "fancy_table"
	frame = /obj/structure/table_frame
	framestack = /obj/item/stack/rods
	buildstack = /obj/item/stack/tile/carpet
	canSmoothWith = list(/obj/structure/table/wood/fancy,
						/obj/structure/table/wood/fancy/black,
						/obj/structure/table/wood/fancy/blue,
						/obj/structure/table/wood/fancy/cyan,
						/obj/structure/table/wood/fancy/green,
						/obj/structure/table/wood/fancy/orange,
						/obj/structure/table/wood/fancy/purple,
						/obj/structure/table/wood/fancy/red,
						/obj/structure/table/wood/fancy/royalblack,
						/obj/structure/table/wood/fancy/royalblue)
	var/smooth_icon = 'icons/obj/smooth_structures/fancy_table.dmi'

/obj/structure/table/wood/fancy/flip(direction)
	return FALSE

/obj/structure/table/wood/fancy/Initialize()
	. = ..()
	icon = smooth_icon

/obj/structure/table/wood/fancy/black
	icon_state = "fancy_table_black"
	buildstack = /obj/item/stack/tile/carpet/black
	icon = 'icons/obj/smooth_structures/fancy_table_black.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_black.dmi'

/obj/structure/table/wood/fancy/blue
	icon_state = "fancy_table_blue"
	buildstack = /obj/item/stack/tile/carpet/blue
	icon = 'icons/obj/smooth_structures/fancy_table_blue.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_blue.dmi'

/obj/structure/table/wood/fancy/cyan
	icon_state = "fancy_table_cyan"
	buildstack = /obj/item/stack/tile/carpet/cyan
	icon = 'icons/obj/smooth_structures/fancy_table_cyan.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_cyan.dmi'

/obj/structure/table/wood/fancy/green
	icon_state = "fancy_table_green"
	buildstack = /obj/item/stack/tile/carpet/green
	icon = 'icons/obj/smooth_structures/fancy_table_green.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_green.dmi'

/obj/structure/table/wood/fancy/orange
	icon_state = "fancy_table_orange"
	buildstack = /obj/item/stack/tile/carpet/orange
	icon = 'icons/obj/smooth_structures/fancy_table_orange.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_orange.dmi'

/obj/structure/table/wood/fancy/purple
	icon_state = "fancy_table_purple"
	buildstack = /obj/item/stack/tile/carpet/purple
	icon = 'icons/obj/smooth_structures/fancy_table_purple.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_purple.dmi'

/obj/structure/table/wood/fancy/red
	icon_state = "fancy_table_red"
	buildstack = /obj/item/stack/tile/carpet/red
	icon = 'icons/obj/smooth_structures/fancy_table_red.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_red.dmi'

/obj/structure/table/wood/fancy/royalblack
	icon_state = "fancy_table_royalblack"
	buildstack = /obj/item/stack/tile/carpet/royalblack
	icon = 'icons/obj/smooth_structures/fancy_table_royalblack.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_royalblack.dmi'

/obj/structure/table/wood/fancy/royalblue
	icon_state = "fancy_table_royalblue"
	buildstack = /obj/item/stack/tile/carpet/royalblue
	icon = 'icons/obj/smooth_structures/fancy_table_royalblue.dmi'
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_royalblue.dmi'

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A reinforced version of the four legged table."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	icon_state = "r_table"
	deconstruction_ready = FALSE
	buildstack = /obj/item/stack/sheet/plasteel
	canSmoothWith = list(/obj/structure/table/reinforced, /obj/structure/table)
	max_integrity = 200
	integrity_failure = 50
	armor = list("melee" = 10, "bullet" = 30, "laser" = 30, "energy" = 100, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)

/obj/structure/table/reinforced/deconstruction_hints(mob/user)
	if(deconstruction_ready)
		to_chat(user, "<span class='notice'>The top cover has been <i>welded</i> loose and the main frame's <b>bolts</b> are exposed.</span>")
	else
		to_chat(user, "<span class='notice'>The top cover is firmly <b>welded</b> on.</span>")

/obj/structure/table/reinforced/flip(direction)
	if(!deconstruction_ready)
		return FALSE
	return ..()

/obj/structure/table/reinforced/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start [deconstruction_ready ? "strengthening" : "weakening"] the reinforced table...</span>")
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You [deconstruction_ready ? "strengthen" : "weaken"] the table.</span>")
		deconstruction_ready = !deconstruction_ready

/obj/structure/table/reinforced/brass
	name = "brass table"
	desc = "A solid, slightly beveled brass table."
	icon = 'icons/obj/smooth_structures/brass_table.dmi'
	icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	frame = /obj/structure/table_frame/brass
	framestack = /obj/item/stack/sheet/brass
	buildstack = /obj/item/stack/sheet/brass
	framestackamount = 1
	buildstackamount = 1
	canSmoothWith = list(/obj/structure/table/reinforced/brass)

/obj/structure/table/reinforced/brass/fake
	desc = "A solid, slightly beveled and totally not magic brass table."
	frame = /obj/structure/table_frame/brass/fake
	framestack = /obj/item/stack/sheet/brass_fake
	buildstack = /obj/item/stack/sheet/brass_fake
	canSmoothWith = list(/obj/structure/table/reinforced/brass/fake)

/obj/structure/table/reinforced/brass/narsie_act()
	take_damage(rand(15, 45), BRUTE)
	if(src) //do we still exist?
		var/previouscolor = color
		color = COLOR_CULT_RED
		animate(src, color = previouscolor, time = 8)

/obj/structure/table/reinforced/brass/ratvar_act()
	obj_integrity = max_integrity

/obj/structure/table/reinforced/brass/fake/ratvar_act()
	return

/obj/structure/table/tray
	name = "surgical tray"
	desc = "A small metal tray with wheels."
	anchored = FALSE
	smooth = SMOOTH_FALSE
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tray"
	buildstack = /obj/item/stack/sheet/mineral/titanium
	buildstackamount = 2
	can_be_flipped = FALSE
	var/list/typecache_can_hold = list(/mob, /obj/item)
	var/list/held_items = list()

/obj/structure/table/tray/Initialize()
	. = ..()
	typecache_can_hold = typecacheof(typecache_can_hold)
	for(var/atom/movable/held in get_turf(src))
		if(!held.anchored && held.move_resist != INFINITY && is_type_in_typecache(held, typecache_can_hold))
			held_items += held.UID()

/obj/structure/table/tray/Move(NewLoc, direct)
	var/atom/OldLoc = loc

	. = ..()
	if(!.) // ..() will return 0 if we didn't actually move anywhere.
		return .

	if(direct & (direct - 1)) // This represents a diagonal movement, which is split into multiple cardinal movements. We'll handle moving the items on the cardinals only.
		return .

	playsound(loc, pick('sound/items/cartwheel1.ogg', 'sound/items/cartwheel2.ogg'), 100, 1, ignore_walls = FALSE)

	var/atom/movable/held
	for(var/held_uid in held_items)
		held = locateUID(held_uid)
		if(!held)
			held_items -= held_uid
			continue
		if(OldLoc != held.loc)
			held_items -= held_uid
			continue
		held.forceMove(NewLoc)


/obj/structure/table/tray/can_be_pulled(user, force, show_message)
	var/atom/movable/puller = user
	if(loc != puller.loc)
		held_items -= puller.UID()
	if(isliving(user))
		var/mob/living/M = user
		if(M.UID() in held_items)
			return FALSE
	return ..()


/obj/structure/table/tray/item_placed(atom/movable/item)
	. = ..()
	if(is_type_in_typecache(item, typecache_can_hold))
		held_items += item.UID()
		if(isliving(item))
			var/mob/living/M = item
			if(M.pulling == src)
				M.stop_pulling()

/obj/structure/table/tray/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags & NODECONSTRUCT))
		var/turf/T = get_turf(src)
		new buildstack(T, buildstackamount)
	qdel(src)

/obj/structure/table/tray/deconstruction_hints(mob/user)
	to_chat(user, "<span class='notice'>It is held together by some <b>screws</b> and <b>bolts</b>.</span>")

/obj/structure/table/tray/flip()
	return

/obj/structure/table/tray/narsie_act()
	return

/obj/structure/table/tray/ratvar_act()
	return

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW //You can throw objects over this, despite it's density.
	max_integrity = 20

/obj/structure/rack/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's held together by a couple of <b>bolts</b>.</span>"


/obj/structure/rack/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover, PASSTABLE))
		return TRUE


/obj/structure/rack/CanPathfindPass(obj/item/card/id/ID, dir, caller, no_id = FALSE)
	. = !density
	if(checkpass(caller, PASSTABLE))
		. = TRUE


/obj/structure/rack/MouseDrop_T(obj/item/dropping, mob/user, params)
	. = FALSE
	if((!isitem(dropping)) || user.get_active_hand() != dropping)
		return .
	if(isrobot(user))
		return .
	if(dropping.loc != loc && user.transfer_item_to_loc(dropping, src.loc))
		add_fingerprint(user)
		return TRUE


/obj/structure/rack/attackby(obj/item/I, mob/user, params)
	if(isrobot(user))
		return
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!(I.flags & ABSTRACT) && user.transfer_item_to_loc(I, loc))
		add_fingerprint(user)


/obj/structure/rack/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(flags & NODECONSTRUCT)
		to_chat(user, "<span class='warning'>Try as you might, you can't figure out how to deconstruct this.</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/rack/attack_hand(mob/living/user)
	if(user.incapacitated() || user.resting)
		return
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
							 "<span class='danger'>You kick [src].</span>")
	take_damage(rand(4,8), BRUTE, "melee", 1)

/obj/structure/rack/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/items/dodgeball.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 40, TRUE)

/obj/structure/rack/skeletal_bar
	name = "skeletal minibar"
	desc = "Made with the skulls of the fallen."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"

/obj/structure/rack/skeletal_bar/left
	icon_state = "minibar_left"

/obj/structure/rack/skeletal_bar/right
	icon_state = "minibar_right"

/obj/structure/rack/gunrack
	name = "gun rack"
	desc = "A gun rack for storing guns."
	icon_state = "gunrack"


/obj/structure/rack/gunrack/proc/place_gun(obj/item/gun/our_gun, mob/user, params)
	. = FALSE
	if(!ishuman(user))
		return .
	if(!(istype(our_gun)))
		to_chat(user, span_warning("This item doesn't fit!"))
		return .
	if(our_gun.flags & ABSTRACT)
		return .
	if(!user.drop_item_ground(our_gun))
		return .
	if(our_gun.loc != loc)
		add_fingerprint(user)
		our_gun.reset_direction()
		our_gun.place_on_rack()
		our_gun.do_drop_animation(src)
		our_gun.Move(loc)
		var/list/click_params = params2list(params)
		//Center the icon where the user clicked.
		if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
			return  .
		//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		our_gun.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
		our_gun.pixel_y = 0
		return TRUE


/obj/structure/rack/gunrack/MouseDrop_T(obj/item/gun/our_gun, mob/user, params)
	return place_gun(our_gun, user, params)


/obj/structure/rack/gunrack/attackby(obj/item/I, mob/user, params)
	if(!ishuman(user))
		return
	if(user.a_intent == INTENT_HARM)
		return ..()
	place_gun(I, user, params)


/obj/structure/rack/gunrack/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)


/obj/structure/rack/gunrack/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	for(var/obj/item/gun/gun in loc)
		gun.place_on_rack()


/obj/structure/rack/gunrack/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		density = FALSE
		var/obj/item/gunrack_parts/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	for(var/obj/item/I in loc.contents)
		if(istype(I, /obj/item/gun))
			var/obj/item/gun/to_remove = I
			to_remove.remove_from_rack()
	qdel(src)

/obj/item/gunrack_parts
	name = "gun rack parts"
	desc = "Parts of a gun rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "gunrack_parts"
	flags = CONDUCT
	materials = list(MAT_METAL=2000)
	var/building = FALSE

/obj/item/gunrack_parts/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	new /obj/item/stack/sheet/metal(user.loc)
	qdel(src)

/obj/item/gunrack_parts/attack_self(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, "<span class='notice'>You start constructing a gun rack...</span>")
	if(do_after(user, 50, target = user, progress=TRUE))
		if(!user.drop_from_active_hand())
			return
		var/obj/structure/rack/gunrack/GR = new (user.loc)
		user.visible_message("<span class='notice'>[user] assembles \a [GR].\
			</span>", "<span class='notice'>You assemble \a [GR].</span>")
		GR.add_fingerprint(user)
		qdel(src)
	building = FALSE

/*
 * Rack destruction
 */

/obj/structure/rack/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		density = FALSE
		var/obj/item/rack_parts/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	qdel(src)

/*
 * Rack Parts
 */

/obj/item/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags = CONDUCT
	materials = list(MAT_METAL=2000)
	var/building = FALSE

/obj/item/rack_parts/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	new /obj/item/stack/sheet/metal(user.loc)
	qdel(src)

/obj/item/rack_parts/attack_self(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, "<span class='notice'>You start constructing a rack...</span>")
	if(do_after(user, 50, target = user, progress=TRUE))
		if(!user.drop_from_active_hand())
			return
		var/obj/structure/rack/R = new /obj/structure/rack(user.loc)
		user.visible_message("<span class='notice'>[user] assembles \a [R].\
			</span>", "<span class='notice'>You assemble \a [R].</span>")
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE
