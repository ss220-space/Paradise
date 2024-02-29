/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	item_color = "holster"
	slot = ACCESSORY_SLOT_UTILITY
	pickup_sound = 'sound/items/handling/backpack_pickup.ogg'
	equip_sound = 'sound/items/handling/backpack_equip.ogg'
	drop_sound = 'sound/items/handling/backpack_drop.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/accessory/holster)
	var/holster_allow = /obj/item/gun
	var/list/holstered = list()
	var/max_content = 1
	var/sound_holster = 'sound/weapons/gun_interactions/1holster.ogg'
	var/sound_unholster = 'sound/weapons/gun_interactions/1unholster.ogg'

/obj/item/clothing/accessory/holster/Destroy()
	for(var/obj/item/I in holstered)
		if(I.loc == src)
			holstered -= I
			QDEL_NULL(I)
	return ..()

/obj/item/clothing/accessory/holster/proc/can_holster(obj/item/I)
	if(!istype(I, holster_allow))
		return FALSE
	var/obj/item/gun/G = I
	if(istype(G) && (!G.can_holster || G.w_class > WEIGHT_CLASS_NORMAL))
		return FALSE
	return TRUE

/obj/item/clothing/accessory/holster/attack_self(mob/user = usr)
	var/holsteritem = user.get_active_hand()
	if(istype(holsteritem, /obj/item/clothing/accessory/holster))
		unholster(user)
	else if(holsteritem)
		holster(holsteritem, user)
	else
		unholster(user)

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user)
	if(holstered.len >= max_content)
		to_chat(user, span_warning("Holster is full!"))
		return

	if(!can_holster(I))
		to_chat(user, span_warning("This [I] won't fit in the [src]!"))
		return

	if(!user.can_unEquip(I))
		to_chat(user, span_warning("You can't let go of the [I]!"))
		return

	holstered += I
	user.temporarily_remove_item_from_inventory(I)
	I.forceMove(src)
	I.add_fingerprint(user)
	user.visible_message(span_notice("[user] holsters the [I]."), span_notice("You holster the [I]."))
	playsound(user.loc, sound_holster, 50, 1)

/obj/item/clothing/accessory/holster/proc/unholster(mob/user)
	if(!holstered.len)
		to_chat(user, span_warning("Holster is empty!"))
		return

	var/obj/item/next_item = holstered[holstered.len]

	if(isliving(user))
		var/mob/living/L = user
		if(L.IsStunned() || L.IsWeakened() || user.stat)
			to_chat(user, span_warning("You can't get [next_item] now!"))
			return

	if(istype(user.get_active_hand(), /obj) && istype(user.get_inactive_hand(), /obj))
		to_chat(user, span_warning("You need an empty hand to draw the [next_item]!"))
	else
		user.put_in_hands(next_item)
		next_item.add_fingerprint(user)
		holstered -= next_item
		unholster_message(user, next_item)
		playsound(user.loc, sound_unholster, 50, 1)

/obj/item/clothing/accessory/holster/proc/unholster_message(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		usr.visible_message(span_warning("[user] draws the [I], ready to shoot!"),
							span_warning("You draw the [I], ready to shoot!"))
	else
		user.visible_message(span_notice("[user] draws the [I], pointing it at the ground."),
							span_notice("You draw the [I], pointing it at the ground."))

/obj/item/clothing/accessory/holster/attack_hand(mob/user)
	if(has_suit)	//if we are part of a suit
		if(holstered)
			unholster(user)
		return

	..(user)

/obj/item/clothing/accessory/holster/attackby(obj/item/W, mob/user, params)
	if(istype(W, src.type))
		return
	holster(W, user)

/obj/item/clothing/accessory/holster/emp_act(severity)
	for(var/obj/item/I in holstered)
		I.emp_act(severity)
	..()

/obj/item/clothing/accessory/holster/examine(mob/user)
	. = ..(user)
	if(holstered.len)
		for(var/obj/item/I in holstered)
			. += span_notice("A [I] is holstered here.")
	else
		. += span_notice("It is empty.")

/obj/item/clothing/accessory/holster/on_attached(obj/item/clothing/under/S, mob/user)
	..()
	has_suit.verbs += /obj/item/clothing/accessory/holster/verb/holster_verb

/obj/item/clothing/accessory/holster/on_removed(mob/user)
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
		return

	H.attack_self(usr)

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
	name = "knife holster"
	desc = "A bunch of straps connected into one holster. Has 7 special slots for holding knives."
	icon_state = "holsterknife"
	item_color = "holsterknife"
	holster_allow = list(
		/obj/item/kitchen/knife,
		/obj/item/kitchen/knife/combat,
		/obj/item/kitchen/knife/combat/survival,
		/obj/item/kitchen/knife/combat/survival/bone,
		/obj/item/kitchen/knife/combat/throwing,
		/obj/item/kitchen/knife/carrotshiv,
		/obj/item/kitchen/knife/glassshiv,
		/obj/item/kitchen/knife/glassshiv/plasma
	)
	max_content = 7
	sound_holster = 'sound/weapons/knife_holster/knife_holster.ogg'
	sound_unholster = 'sound/weapons/knife_holster/knife_unholster.ogg'


/obj/item/clothing/accessory/holster/knives/unholster_message(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		user.visible_message(span_warning("[user] takes the [I] out, ready to throw!"),
			span_warning("You takes the [I] out, [holstered.len] knives left!"))
	else
		user.visible_message(span_notice("[user] takes the [I] out."),
			span_notice("You takes the [I] out, [holstered.len] knives left"))

/obj/item/clothing/accessory/holster/knives/can_holster(obj/item/I)
	return is_type_in_list(I, holster_allow, FALSE)

/obj/item/clothing/accessory/holster/knives/attached_examine(mob/user)
	return span_notice("\A [src] with [holstered.len] knives attached to it.")
