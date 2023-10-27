/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	item_color = "holster"
	slot = ACCESSORY_SLOT_UTILITY
	var/holster_allow = /obj/item/gun
	var/obj/item/holstered = null
	actions_types = list(/datum/action/item_action/accessory/holster)
	w_class = WEIGHT_CLASS_NORMAL // so it doesn't fit in pockets

/obj/item/clothing/accessory/holster/Destroy()
	if(holstered?.loc == src)
		QDEL_NULL(holstered)
	holstered = null
	return ..()

//subtypes can override this to specify what can be holstered
/obj/item/clothing/accessory/holster/proc/can_holster(obj/item/gun/W)
	if(!W.can_holster || !istype(W, holster_allow) || W.w_class > WEIGHT_CLASS_NORMAL)
		return FALSE
	return TRUE

/obj/item/clothing/accessory/holster/attack_self(mob/user = usr)
	var/holsteritem = user.get_active_hand()
	if(holsteritem)
		holster(holsteritem, user)
	else
		unholster(user)

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user as mob)
	if(holstered)
		to_chat(user, span_warning("There is already a [holstered] holstered here!"))
		return

	if(!istype(I, /obj/item/gun))
		to_chat(user, span_warning("Only guns can be holstered!"))
		return

	var/obj/item/gun/W = I
	if(!can_holster(W))
		to_chat(user, span_warning("This [W] won't fit in the [src]!"))
		return

	if(!user.can_unEquip(W))
		to_chat(user, span_warning("You can't let go of the [W]!"))
		return

	holstered = W
	user.temporarily_remove_item_from_inventory(holstered)
	holstered.forceMove(src)
	holstered.add_fingerprint(user)
	user.visible_message(span_notice("[user] holsters the [holstered]."), span_notice("You holster the [holstered]."))
	playsound(user.loc, 'sound/weapons/gun_interactions/1holster.ogg', 50, 1)

/obj/item/clothing/accessory/holster/proc/unholster(mob/user as mob)
	if(!holstered || user.stat == DEAD)
		return

	if(isliving(user))
		var/mob/living/L = user
		if(L.IsStunned() || L.IsWeakened() || user.stat == UNCONSCIOUS)
			to_chat(user, span_warning("Вы не можете достать [holstered] сейчас!"))
			return

	if(istype(user.get_active_hand(), /obj) && istype(user.get_inactive_hand(), /obj))
		to_chat(user, span_warning("You need an empty hand to draw the [holstered]!"))
	else
		if(user.a_intent == INTENT_HARM)
			usr.visible_message(span_warning("[user] draws the [holstered], ready to shoot!"),
								span_warning("You draw the [holstered], ready to shoot!"))
		else
			user.visible_message(span_notice("[user] draws the [holstered], pointing it at the ground."),
								span_notice("You draw the [holstered], pointing it at the ground."))
		user.put_in_hands(holstered)
		holstered.add_fingerprint(user)
		holstered = null
		playsound(user.loc, 'sound/weapons/gun_interactions/1unholster.ogg', 50, 1)

/obj/item/clothing/accessory/holster/attack_hand(mob/user as mob)
	if(has_suit)	//if we are part of a suit
		if(holstered)
			unholster(user)
		return

	..(user)

/obj/item/clothing/accessory/holster/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/clothing/accessory/holster))
		return
	holster(W, user)

/obj/item/clothing/accessory/holster/emp_act(severity)
	if(holstered)
		holstered.emp_act(severity)
	..()

/obj/item/clothing/accessory/holster/examine(mob/user, skip = FALSE)
	. = ..(user)
	if(!skip)
		if(holstered)
			. += span_notice("A [holstered] is holstered here.")
		else
			. += span_notice("It is empty.")

/obj/item/clothing/accessory/holster/on_attached(obj/item/clothing/under/S, mob/user as mob)
	..()
	has_suit.verbs += /obj/item/clothing/accessory/holster/verb/holster_verb

/obj/item/clothing/accessory/holster/on_removed(mob/user as mob)
	has_suit.verbs -= /obj/item/clothing/accessory/holster/verb/holster_verb
	..()

//For the holster hotkey
/obj/item/clothing/accessory/holster/verb/holster_verb()
	set name = "Holster"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	var/obj/item/clothing/accessory/holster/H = null
	if(istype(src, /obj/item/clothing/accessory/holster))
		H = src
	else if(istype(src, /obj/item/clothing/under))
		var/obj/item/clothing/under/S = src
		if(S.accessories.len)
			H = locate() in S.accessories

	if(!H)
		to_chat(usr, span_warning("Something is very wrong."))

	if(!H.holstered)
		if(!istype(usr.get_active_hand(), /obj/item/gun))
			to_chat(usr, span_warning("You need your gun equiped to holster it."))
			return
		var/obj/item/gun/W = usr.get_active_hand()
		H.holster(W, usr)
	else
		H.unholster(usr)

/obj/item/clothing/accessory/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"
	item_color = "holster"
	holster_allow = /obj/item/gun/projectile

/obj/item/clothing/accessory/holster/waist
	name = "shoulder holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"
	item_color = "holster_low"

/obj/item/clothing/accessory/holster/knives
	name = "ы"
	desc = "ы"
	icon_state = "holsterknife"
	item_color = "holsterknife"
	holster_allow = /obj/item/kitchen/knife/combat
	var/list/holstered_list = list()
	var/max_content = 7

/obj/item/clothing/accessory/holster/knives/Destroy()
	for(var/obj/item/I in holstered_list)
		if(I.loc == src)
			holstered_list -= I
			QDEL_NULL(I)
	return ..()

/obj/item/clothing/accessory/holster/knives/holster(obj/item/I, mob/user as mob)
	if(holstered_list.len >= max_content)
		to_chat(user, span_warning("No more knives will fit in the holster!"))
		return

	if(!istype(I, holster_allow))
		to_chat(user, span_warning("Only knifes can be holstered!"))
		return

	var/obj/item/kitchen/knife/combat/K = I

	if(!user.can_unEquip(K))
		to_chat(user, span_warning("You can't let go of the [K]!"))
		return

	holstered_list += K
	user.temporarily_remove_item_from_inventory(K)
	K.forceMove(src)
	K.add_fingerprint(user)
	user.visible_message(span_notice("[user] holsters the [K]."), span_notice("You holster the [K]."))
	playsound(user.loc, 'sound/weapons/gun_interactions/1holster.ogg', 50, 1)

/obj/item/clothing/accessory/holster/knives/unholster(mob/user as mob)
	if(isliving(user))
		var/mob/living/L = user
		if(L.IsStunned() || L.IsWeakened() || user.stat)
			to_chat(user, span_warning("You can't get [holstered_list] now!"))
			return

	if(!holstered_list.len)
		to_chat(user, span_warning("Holster is empty!"))
		return

	var/obj/item/next_knife = holstered_list[holstered_list.len]
	if(istype(user.get_active_hand(), /obj) && istype(user.get_inactive_hand(), /obj))
		to_chat(user, span_warning("You need an empty hand to draw the [next_knife]!"))
	else
		if(user.a_intent == INTENT_HARM)
			user.visible_message(span_warning("[user] takes the [next_knife] out, ready to throw!"),
				span_warning("You takes the [next_knife] out, ready to throw!"))
		else
			user.visible_message(span_notice("[user] takes the [next_knife] out."),
				span_notice("You takes the [next_knife] out"))
		user.put_in_hands(next_knife)
		next_knife.add_fingerprint(user)
		holstered_list -= next_knife
		playsound(user.loc, 'sound/weapons/gun_interactions/1unholster.ogg', 50, 1)

/obj/item/clothing/accessory/holster/knives/examine(mob/user)
	. = ..(user, TRUE)
	if(holstered_list.len)
		for(var/obj/item/I in holstered_list)
			. += span_notice("A [I] is holstered here.")
	else
		. += span_notice("It is empty.")

/obj/item/clothing/accessory/holster/knives/holster_verb()
	set name = "Holster"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	var/obj/item/clothing/accessory/holster/knives/H = null
	if(istype(src, /obj/item/clothing/accessory/holster/knives))
		H = src
	else if(istype(src, /obj/item/clothing/under))
		var/obj/item/clothing/under/S = src
		if(S.accessories.len)
			H = locate() in S.accessories
	if(!H)
		return

	var/obj/item/I = usr.get_active_hand()

	if(istype(I, holster_allow))
		H.holster(I, usr)
	else if(I)
		to_chat(usr, span_warning("Only knifes can be holstered!"))
	else
		H.unholster(usr)
