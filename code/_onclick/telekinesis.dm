/*
	Telekinesis

	This needs more thinking out, but I might as well.
*/
#define TK_MAXRANGE 15

/*
	Telekinetic attack:

	By default, emulate the user's unarmed attack
*/
/atom/proc/attack_tk(mob/user)
	if(user.stat)
		return
	user.UnarmedAttack(src,0) // attack_hand, attack_paw, etc
	return

/*
	This is similar to item attack_self, but applies to anything
	that you can grab with a telekinetic grab.

	It is used for manipulating things at range, for example, opening and closing closets.
	There are not a lot of defaults at this time, add more where appropriate.
*/
/atom/proc/attack_self_tk(mob/user)
	return

/obj/attack_tk(mob/user)
	if(user.stat)
		return
	if(anchored)
		..()
		return

	var/obj/item/tk_grab/O = new(src)
	O.form_grab(user, src)

/obj/item/attack_tk(mob/user)
	if(user.stat || !isturf(loc))
		return
	var/telekinesis = HAS_TRAIT(user, TRAIT_TELEKINESIS)
	if(telekinesis && !user.get_active_hand()) // both should already be true to get here
		var/obj/item/tk_grab/O = new(src)
		O.form_grab(user, src)
	else
		warning("Strange attack_tk(): TK([telekinesis]) empty hand([!user.get_active_hand()])")


/mob/attack_tk(mob/user)
	return // needs more thinking about

/*
	TK Grab Item (the workhorse of old TK)

	* If you have not grabbed something, do a normal tk attack
	* If you have something, throw it at the target.  If it is already adjacent, do a normal attackby(, params)
	* If you click what you are holding, or attack_self(), do an attack_self_tk() on it.
	* Deletes itself if it is ever not in your hand, or if you should have no access to TK.
*/
/obj/item/tk_grab
	name = "Telekinetic Grab"
	desc = "Magic"
	icon = 'icons/obj/magic.dmi'//Needs sprites
	icon_state = "2"
	item_flags = NOBLUDGEON|ABSTRACT|DROPDEL
	//item_state = null
	w_class = WEIGHT_CLASS_GIGANTIC
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	blocks_emissive = FALSE

	var/last_throw = 0
	var/atom/movable/focus = null
	var/mob/living/host = null

/obj/item/tk_grab/Destroy()
	if(focus)
		release_object()
	// Focus is null now
	host = null
	return ..()

/obj/item/tk_grab/dropped(mob/user, slot, silent = FALSE)
	if(focus && user && loc != user && loc != user.loc) // drop_from_active_hand() gets called when you tk-attack a table/closet with an item
		if(focus.Adjacent(loc))
			focus.forceMove(loc)
	. = ..()


//stops TK grabs being equipped anywhere but into hands
/obj/item/tk_grab/equipped(mob/user, slot, initial = FALSE)
	SHOULD_CALL_PARENT(FALSE)
	if(slot & ITEM_SLOT_HANDS)
		return TRUE
	qdel(src)


/obj/item/tk_grab/attack_self(mob/user)
	if(focus)
		focus.attack_self_tk(user)

/obj/item/tk_grab/override_throw(mob/user, atom/target)
	afterattack(target, user)
	return TRUE

/obj/item/tk_grab/afterattack(atom/target, mob/living/user, proximity, params)//TODO: go over this
	if(!target || !user)
		return
	if(last_throw+3 > world.time)
		return
	if(!host || host != user)
		qdel(src)
		return
	if(!HAS_TRAIT(host, TRAIT_TELEKINESIS))
		qdel(src)
		return
	if(isobj(target) && !isturf(target.loc))
		return

	var/d = get_dist(user, target)
	if(focus)
		d = max(d,get_dist(user,focus)) // whichever is further
	if((d > TK_MAXRANGE)||(user.z != focus.z)) // both in range and on same z-level
		balloon_alert(user, "не схватить, слишком далеко!")
		return

	if(!focus)
		focus_object(target, user)
		return

	if(target == focus)
		target.attack_self_tk(user)
		return // todo: something like attack_self not laden with assumptions inherent to attack_self

	if(isitem(focus) && target.Adjacent(focus) && !user.in_throw_mode)
		var/obj/item/I = focus
		var/attackby_result = target.attackby(I, user, params)
		if(!(attackby_result & ATTACK_CHAIN_NO_AFTERATTACK) && !QDELETED(I) && !QDELETED(target) && !QDELETED(user))
			I.afterattack(target, user, TRUE, params) // for splashing with beakers

	else
		apply_focus_overlay()
		focus.throw_at(target, 10, 1, user)
		last_throw = world.time


/obj/item/tk_grab/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/tk_grab/is_equivalent(obj/item/I)
	. = ..()
	if(!.)
		return I == focus

/obj/item/tk_grab/proc/focus_object(var/obj/target, var/mob/user)
	if(!isobj(target))
		return//Cant throw non objects atm might let it do mobs later
	if(target.anchored || !isturf(target.loc))
		qdel(src)
		return
	focus = target
	update_icon(UPDATE_OVERLAYS)
	apply_focus_overlay()
	// Make it behave like other equipment
	if(isitem(target))
		if(target in user.tkgrabbed_objects)
			// Release the old grab first
			user.drop_item_ground(user.tkgrabbed_objects[target])
		user.tkgrabbed_objects[target] = src

/obj/item/tk_grab/proc/release_object()
	if(!focus)
		return
	if(isitem(focus))
		// Delete the key/value pair of item to TK grab
		host.tkgrabbed_objects -= focus
	focus = null
	update_icon(UPDATE_OVERLAYS)

/obj/item/tk_grab/proc/apply_focus_overlay()
	if(!focus)
		return
	new /obj/effect/temp_visual/telekinesis(get_turf(focus))

/obj/item/tk_grab/proc/form_grab(mob/user, obj/target)
	user.put_in_active_hand(src)
	host = user
	focus_object(target, user)


/obj/item/tk_grab/update_overlays()
	. = ..()
	if(!focus)
		return

	var/mutable_appearance/focus_overlay = new(focus)
	focus_overlay.layer = layer + 0.01
	SET_PLANE_EXPLICIT(focus_overlay, ABOVE_HUD_PLANE, focus)
	. += focus_overlay
