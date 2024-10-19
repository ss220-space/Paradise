/obj/item/folded_tent
	name = "primitive folded tent"
	desc = "Сложенная палатка."
	icon = 'icons/obj/tent.dmi'
	icon_state = "tent_folded"
	item_state = "tent_folded"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	var/unfoldedtent_path = /obj/structure/tent

/obj/item/folded_tent/attack_self(mob/user)
	if(!do_after(user, 15 SECONDS, user))
		return
	if(loc == user)
		deploy_tent(user, get_turf(user))
	else
		deploy_tent(user, get_turf(src))

/obj/item/folded_tent/pickup(mob/user)
	if(contains(user))
		return FALSE
	return ..()

/obj/item/folded_tent/proc/deploy_tent(mob/user, atom/location)
	var/obj/structure/tent/item_tent = new unfoldedtent_path(location)
	item_tent.foldedtent_instance = src
	user.drop_item_ground(src)
	move_to_null_space()
	return item_tent

/obj/structure/tent
	name = "Primitive tent"
	desc = "Примитивная палатка, способная защитить от бури. Сделана из шкур голиафов."
	icon = 'icons/obj/tent.dmi'
	icon_state = "tent"
	max_integrity = 50
	density = TRUE
	anchored = TRUE
	var/foldedtent_path = /obj/item/folded_tent
	var/obj/item/folded_tent/foldedtent_instance = null
	var/mob/living/carbon/human/occupant = null

/obj/structure/tent/proc/perform_fold(mob/living/carbon/human/the_folder)
	var/folding_tent = new foldedtent_path(get_turf(src))
	the_folder.put_in_hands(folding_tent)

/obj/structure/tent/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!do_after(usr, 5 SECONDS, usr))
		return

	if(over_object == usr && ishuman(usr) && !usr.incapacitated() && !HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) && !length(contents) && usr.Adjacent(src))
		usr.visible_message(
			span_notice("[usr] folds up [src]."),
			span_notice("You fold up [src]."),
		)
		perform_fold(usr)
		qdel(src)
		return FALSE

	if(over_object == usr && ishuman(usr) && !usr.incapacitated() && usr.Adjacent(src))
		if(attempt_fold(usr))
			usr.visible_message(
				span_notice("[usr] folds up [src]."),
				span_notice("You fold up [src]."),
			)
			perform_fold(usr)
			qdel(src)
			return FALSE

	return ..()

/obj/structure/tent/proc/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE
	if(!istype(the_folder))
		return

	if(LAZYLEN(contents))
		return

	return TRUE

/obj/structure/tent/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !ismob(grabbed_thing))
		return .

	var/mob/target = grabbed_thing
	if(occupant)
		grabber.balloon_alert(grabber, "палатка занята!")
		return .

	visible_message(span_notice("[grabber] starts putting [target] into [src]."))
	if(!do_after(grabber, 2 SECONDS, target) || !target || !grabber || grabber.pulling != target || !grabber.Adjacent(src))
		return .

	target.forceMove(src)
	occupant = target

/obj/structure/tent/MouseDrop_T(atom/movable/O, mob/user, params)
	if(O.loc == user)
		return

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src))
		return

	if(!ismob(O))
		return

	if(isanimal(O) || issilicon(O))
		return

	if(!isturf(user.loc) || !isturf(O.loc))
		return

	if(occupant)
		usr.balloon_alert(usr, "палатка занята!")
		return TRUE

	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return

	if(L == user)
		visible_message(span_notice("[user] starts climbing into the tent."))
	else
		visible_message(span_notice("[user] starts putting [L.name] into the tent."))

	. = TRUE
	INVOKE_ASYNC(src, PROC_REF(put_in), L, user)

/obj/structure/tent/Destroy()
	for(var/mob/M in contents)
		M.forceMove(get_turf(src))
		REMOVE_TRAIT(M, TRAIT_ASHSTORM_IMMUNE, "ash")

	return ..()

/obj/structure/tent/proc/put_in(mob/living/L, mob/user)
	if(!do_after(user, 2 SECONDS, L))
		return

	if(occupant)
		user.balloon_alert(user, "палатка занята!")
		return

	if(!L)
		return

	L.forceMove(src)
	occupant = L
	ADD_TRAIT(L, TRAIT_ASHSTORM_IMMUNE, "ash")

/obj/structure/tent/verb/move_inside()
	set name = "Enter Tent"
	set category = "Object"
	set src in oview(1)
	if(!ishuman(usr) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.buckled)
		return

	if(occupant)
		usr.balloon_alert(usr, "палатка занята!")
		return

	visible_message(span_notice("[usr] starts climbing into the tent."))
	put_in(usr, usr)

/obj/structure/tent/verb/eject()
	set name = "Eject Tent"
	set category = "Object"
	set src in oview(1)

	if(usr.default_can_use_topic(src) != UI_INTERACTIVE)
		return

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	go_out()
	add_fingerprint(usr)

/obj/structure/tent/relaymove(mob/user as mob)
	go_out()

/obj/structure/tent/proc/go_out()
	if(!occupant)
		return

	occupant.forceMove(loc)
	if(!istype(occupant, /datum/species/unathi/draconid))
		REMOVE_TRAIT(occupant, TRAIT_ASHSTORM_IMMUNE, "ash")
	occupant = null

/obj/structure/tent/force_eject_occupant(mob/target)
	go_out()

/obj/structure/tent/attack_ai(mob/user)
	return attack_hand(user)
