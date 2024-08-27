/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/inflatable/attack_self(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	var/obj/structure/inflatable/R = new /obj/structure/inflatable(user.loc)
	transfer_fingerprints_to(R)
	qdel(src)

/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	max_integrity = 50
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"
	var/torn = /obj/item/inflatable/torn
	var/intact = /obj/item/inflatable

/obj/structure/inflatable/Initialize(location)
	. = ..()
	air_update_turf(TRUE)

/obj/structure/inflatable/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/inflatable/CanAtmosPass(turf/T, vertical)
	return !density


/obj/structure/inflatable/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.) && !QDELETED(src) && (is_sharp(I) || is_pointed(I)))
		deconstruct(FALSE)


/obj/structure/inflatable/attack_hand(mob/user)
	add_fingerprint(user)

/obj/structure/inflatable/AltClick(mob/living/user)
	if(!istype(user) || !Adjacent(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	deconstruct(TRUE)


/obj/structure/inflatable/deconstruct(disassembled = TRUE)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(!disassembled)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new torn(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		visible_message("[src] slowly deflates.")
		addtimer(CALLBACK(src, PROC_REF(deflate)), 5 SECONDS)


/obj/structure/inflatable/proc/deflate()
	var/obj/item/inflatable/R = new intact(loc)
	transfer_fingerprints_to(R)
	qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	deconstruct(TRUE)

/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door"

/obj/item/inflatable/door/attack_self(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	var/obj/structure/inflatable/door/R = new /obj/structure/inflatable/door(user.loc)
	src.transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/inflatable/door //Based on mineral door code
	name = "inflatable door"
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "door_closed"
	opacity = TRUE
	torn = /obj/item/inflatable/door/torn
	intact = /obj/item/inflatable/door

	var/state_closed = TRUE
	var/is_operating = FALSE

/obj/structure/inflatable/door/attack_ai(mob/user) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user)) //but cyborgs can
		if(get_dist(user,src) <= 1) //not remotely though
			return try_to_operate(user)

/obj/structure/inflatable/door/attack_hand(mob/user)
	return try_to_operate(user)


/obj/structure/inflatable/door/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(istype(mover, /obj/effect/beam))
		return !opacity


/obj/structure/inflatable/door/CanAtmosPass(turf/T, vertical)
	return !density


/obj/structure/inflatable/door/proc/try_to_operate(atom/user)
	if(is_operating)
		return
	if(ismob(user))
		var/mob/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					operate()
			else
				operate()
	else if(ismecha(user))
		operate()


/obj/structure/inflatable/door/proc/operate()
	is_operating = TRUE
	if(state_closed)
		flick("door_opening", src)
	else
		flick("door_closing", src)

	sleep(1 SECONDS)
	if(QDELETED(src))
		return

	state_closed = !state_closed
	set_density(state_closed)
	set_opacity(state_closed)
	update_icon(UPDATE_ICON_STATE)
	air_update_turf(TRUE)
	is_operating = FALSE


/obj/structure/inflatable/door/update_icon_state()
	icon_state = "door_[state_closed ? "closed" : "open"]"


/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall_torn"

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, "<span class='warning'>The inflatable wall is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/inflatable/door/torn
	name = "torn inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation. It is too torn to be usable."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door_torn"

/obj/item/inflatable/door/torn/attack_self(mob/user)
	to_chat(user, "<span class='warning'>The inflatable door is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/storage/briefcase/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	item_state = "syringe_kit"
	max_combined_w_class = 21
	w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/inflatable)

/obj/item/storage/briefcase/inflatable/populate_contents()
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
