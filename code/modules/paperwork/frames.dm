/obj/item/picture_frame
	name = "picture frame"
	desc = "Its patented design allows it to be folded larger or smaller to accommodate standard paper, photo, and poster, and canvas sizes."
	icon = 'icons/obj/bureaucracy.dmi'

	usesound = 'sound/items/deconstruct.ogg'

	var/icon_base
	var/obj/displayed

	var/list/wide_posters = list(
		"poster22_legit", "poster23", "poster23_legit", "poster24", "poster24_legit",
		"poster25", "poster27_legit", "poster28", "poster29")

/obj/item/picture_frame/New(loc, obj/item/D)
	..()
	if(D)
		insert(D)
	update_icon()

/obj/item/picture_frame/Destroy()
	if(displayed)
		displayed = null
		for(var/A in contents)
			qdel(A)
	return ..()


/obj/item/picture_frame/update_icon_state()
	if(istype(displayed, /obj/item/photo))
		icon_state = "[icon_base]-photo"
	else if(istype(displayed, /obj/structure/sign/poster))
		icon_state = "[icon_base]-[(displayed.icon_state in wide_posters) ? "wposter" : "poster"]"
	else
		icon_state = "[icon_base]-paper"


/obj/item/picture_frame/update_overlays()
	. = ..()

	if(displayed)
		. += getFlatIcon(displayed)

	. += icon_state


/obj/item/picture_frame/proc/insert(obj/D)
	if(istype(D, /obj/item/poster))
		var/obj/item/poster/P = D
		displayed = P.poster_structure
		P.poster_structure = null
	else
		displayed = D

	name = displayed.name
	displayed.pixel_x = 0
	displayed.pixel_y = 0
	if(displayed.loc != src)
		displayed.forceMove(src)
	if(istype(D, /obj/item/poster))
		qdel(D)


/obj/item/picture_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/poster))
		add_fingerprint(user)
		if(displayed)
			to_chat(user, span_warning("There is nothing to remove from [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		insert(I)
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/picture_frame/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!displayed)
		add_fingerprint(user)
		to_chat(user, span_warning("There is nothing to remove from [src]."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	user.visible_message(
		span_warning("[user] has unfastened [displayed] out of [src]."),
		span_notice("You have unfastened [displayed] out of [src]."),
	)
	if(istype(displayed, /obj/structure/sign/poster))
		var/obj/structure/sign/poster/poster = displayed
		poster.roll_and_drop(drop_location())
	else
		displayed.forceMove(drop_location())
	displayed = null
	name = initial(name)
	update_icon()


/obj/item/picture_frame/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	user.visible_message(
		span_warning("[user] has broken down [src]."),
		span_notice("You have broken down [src]."),
	)
	var/atom/drop_loc = drop_location()
	for(var/atom/movable/thing as anything in contents)
		if(istype(thing, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/poster = thing
			poster.roll_and_drop(drop_loc)
			continue
		thing.forceMove(drop_loc)
	displayed = null
	qdel(src)


/obj/item/picture_frame/afterattack(atom/target, mob/user, proximity_flag, params)
	if(proximity_flag && iswallturf(target))
		place(target, user)
	else
		..()

/obj/item/picture_frame/proc/place(turf/T, mob/user)
	var/stuff_on_wall = 0
	for(var/obj/O in user.loc.contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O, /obj/structure/sign))
			to_chat(user, "<span class='notice'>\The [T] is far too cluttered to place \a [src]!</span>")
			return
		stuff_on_wall++
		if(stuff_on_wall >= 4)
			to_chat(user, "<span class='notice'>\The [T] is far too cluttered to place \a [src]!</span>")
			return

	to_chat(user, "<span class='notice'>You start place \the [src] on \the [T].</span>")

	var/px = 0
	var/py = 0
	var/newdir = getRelativeDirection(user, T)

	switch(newdir)
		if(NORTH)
			py = 32
		if(EAST)
			px = 32
		if(SOUTH)
			py = -32
		if(WEST)
			px = -32
		else
			to_chat(user, "<span class='notice'>You cannot reach \the [T] from here!</span>")
			return

	user.drop_item_ground(src)
	var/obj/structure/sign/picture_frame/PF = new(user.loc, src)
	PF.dir = newdir
	PF.pixel_x = px
	PF.pixel_y = py

	playsound(PF.loc, usesound, 100, 1)

/obj/item/picture_frame/examine(mob/user, var/infix = "", var/suffix = "")
	. = ..()
	if(displayed)
		. += displayed.examine(user, infix, suffix)

/obj/item/picture_frame/attack_self(mob/user)
	if(displayed)
		if(isitem(displayed))
			var/obj/item/I = displayed
			I.attack_self(user)
	else
		..()



/obj/item/picture_frame/glass
	icon_base = "glass"
	icon_state = "glass-poster"
	materials = list(MAT_METAL = 25, MAT_GLASS = 75)

/obj/item/picture_frame/wooden
	icon_base = "wood"
	icon_state = "wood-poster"

/obj/item/picture_frame/wooden/New()
	..()
	new /obj/item/stack/sheet/wood(src, 1)



/obj/structure/sign/picture_frame
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "glass-poster"

	var/obj/item/picture_frame/frame
	var/obj/item/explosive

	var/tilted = 0
	var/tilt_transform = null

/obj/structure/sign/picture_frame/New(loc, F)
	..()
	frame = F
	frame.pixel_x = 0
	frame.pixel_y = 0
	frame.forceMove(src)
	name = frame.name
	update_icon()

	if(!tilt_transform)
		tilt_transform = turn(matrix(), -10)

	if(tilted)
		transform = tilt_transform
		verbs |= /obj/structure/sign/picture_frame/proc/untilt
	else
		verbs |= /obj/structure/sign/picture_frame/proc/tilt

/obj/structure/sign/picture_frame/Destroy()
	QDEL_NULL(frame)
	return ..()


/obj/structure/sign/picture_frame/update_icon_state()
	if(frame)
		icon = null
		icon_state = null
	else
		icon = initial(icon)
		icon_state = initial(icon_state)


/obj/structure/sign/picture_frame/update_overlays()
	. = ..()
	if(frame)
		. += getFlatIcon(frame)


/obj/structure/sign/picture_frame/attackby(obj/item/I, mob/user, params)
	var/bomb = istype(I, /obj/item/grenade) || istype(I, /obj/item/grenade/plastic/c4)
	if(user.a_intent == INTENT_HARM)
		if(bomb)
			return ..() | ATTACK_CHAIN_NO_AFTERATTACK
		return ..()

	if(bomb)
		add_fingerprint(user)
		if(explosive)
			to_chat(user, span_warning("There is already a device attached behind [src], remove it first."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(!tilted)
			to_chat(user, span_warning("The [name] needs to be tilted before being rigged with [I]."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		user.visible_message(
			span_warning("[user] starts to fiddle around behind [src]."),
			span_notice("You start to secure [I] behind [src]."),
		)
		if(!do_after(user, 15 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || explosive || tilted)
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		playsound(loc, 'sound/weapons/handcuffs.ogg', 50, TRUE)
		explosive = I
		user.visible_message(
			span_warning("[user] has stopped to fiddle with the back of [src]."),
			span_notice("You have secured [I] behind [src]."),
		)
		message_admins("[key_name_admin(user)] attached [I] to a picture frame.")
		add_game_logs("attached [I] to a picture frame.", user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/sign/picture_frame/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message(
		span_warning("[user] starts to unfasten [src] from the wall."),
		span_notice("You start to unfasten [src] from the wall."),
	)
	if(!I.use_tool(src, user, 10 SECONDS, volume = I.tool_volume))
		return .
	user.visible_message(
		span_warning("[user] has unfastened [src] from the wall."),
		span_notice("You have unfastened [src] from the wall."),
	)
	var/atom/drop_loc = drop_location()
	if(frame)
		transfer_fingerprints_to(frame)
		frame.add_fingerprint(user)
		frame.forceMove(drop_loc)
		frame = null
	if(explosive)
		explosive.forceMove(drop_loc)
		explosive = null
	qdel(src)


/obj/structure/sign/picture_frame/examine(mob/user, var/infix = "", var/suffix = "")
	if(frame)
		. += frame.examine(user, infix, suffix)
	else
		. = ..()

/obj/structure/sign/picture_frame/attack_hand(mob/user)
	if(frame)
		frame.attack_self(user)
	else
		..()

/obj/structure/sign/picture_frame/ex_act(severity)
	explode()
	..(severity)

/obj/structure/sign/picture_frame/proc/explode()
	if(istype(explosive, /obj/item/grenade))
		var/obj/item/grenade/G = explosive
		explosive = null
		G.prime()

/obj/structure/sign/picture_frame/proc/toggle_tilt(mob/user)
	if(!isliving(usr) || usr.stat)
		return

	tilted = !tilted

	if(tilted)
		animate(src, transform = tilt_transform, time = 10, easing = BOUNCE_EASING)
		verbs -= /obj/structure/sign/picture_frame/proc/tilt
		verbs |= /obj/structure/sign/picture_frame/proc/untilt
	else
		animate(src, transform = matrix(), time = 10, easing = CUBIC_EASING | EASE_IN)
		verbs -= /obj/structure/sign/picture_frame/proc/untilt
		verbs |= /obj/structure/sign/picture_frame/proc/tilt
		explode()

/obj/structure/sign/picture_frame/proc/tilt()
	set name = "Tilt Picture"
	set category = "Object"
	set src in oview(1)

	toggle_tilt(usr)

/obj/structure/sign/picture_frame/proc/untilt()
	set name = "Straighten Picture"
	set category = "Object"
	set src in oview(1)

	toggle_tilt(usr)

/obj/structure/sign/picture_frame/hear_talk(mob/living/M as mob, list/message_pieces)
	..()
	for(var/obj/O in contents)
		O.hear_talk(M, message_pieces)

/obj/structure/sign/picture_frame/hear_message(mob/living/M as mob, msg)
	..()
	for(var/obj/O in contents)
		O.hear_message(M, msg)
