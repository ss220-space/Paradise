#define INTERNALS_TOGGLE_DELAY (4 SECONDS)
#define POCKET_EQUIP_DELAY (1 SECONDS)

GLOBAL_LIST_INIT(strippable_human_items, create_strippable_list(list(
	/datum/strippable_item/mob_item_slot/head,
	/datum/strippable_item/mob_item_slot/back,
	/datum/strippable_item/mob_item_slot/neck,
	/datum/strippable_item/mob_item_slot/mask,
	/datum/strippable_item/mob_item_slot/eyes,
	/datum/strippable_item/mob_item_slot/left_ear,
	/datum/strippable_item/mob_item_slot/right_ear,
	/datum/strippable_item/mob_item_slot/jumpsuit,
	/datum/strippable_item/mob_item_slot/suit,
	/datum/strippable_item/mob_item_slot/gloves,
	/datum/strippable_item/mob_item_slot/feet,
	/datum/strippable_item/mob_item_slot/suit_storage,
	/datum/strippable_item/mob_item_slot/id,
	/datum/strippable_item/mob_item_slot/pda,
	/datum/strippable_item/mob_item_slot/belt,
	/datum/strippable_item/mob_item_slot/pocket/left,
	/datum/strippable_item/mob_item_slot/pocket/right,
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs,
)))

/datum/strippable_item/mob_item_slot/eyes
	key = STRIPPABLE_ITEM_EYES
	item_slot = ITEM_SLOT_EYES

/datum/strippable_item/mob_item_slot/jumpsuit
	key = STRIPPABLE_ITEM_JUMPSUIT
	item_slot = ITEM_SLOT_CLOTH_INNER

/datum/strippable_item/mob_item_slot/jumpsuit/get_alternate_actions(atom/source, mob/user)
	var/list/multiple_options = list()
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if(!istype(jumpsuit))
		return null
	if(jumpsuit.has_sensor)
		multiple_options |= "suit_sensors"
	if(LAZYLEN(jumpsuit.accessories))
		multiple_options |= "remove_accessory"
	return multiple_options

/datum/strippable_item/mob_item_slot/jumpsuit/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if(!istype(jumpsuit))
		return
	if(action_key == "suit_sensors")
		jumpsuit.set_sensors(user)
		return

	if(action_key != "remove_accessory")
		return

	var/accessories_len = LAZYLEN(jumpsuit.accessories)
	if(!accessories_len)
		return

	var/obj/item/clothing/accessory/accessory
	if(accessories_len > 1)
		accessory = tgui_input_list(user, "Select an accessory to remove from [jumpsuit]", "Accessory Removal", jumpsuit.accessories)
		if(!accessory || !LAZYIN(jumpsuit.accessories, accessory) || !source.Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			return
	else
		accessory = jumpsuit.accessories[1]

	if(!in_thief_mode(user))
		user.visible_message(
			span_danger("[user] starts to take off [accessory] from [source]'s [jumpsuit]!"), \
			span_danger("You start to take off [accessory] from [source]'s [jumpsuit]!")
			)

	if(!do_after(user, POCKET_STRIP_DELAY, jumpsuit, NONE, max_interact_count = 1) || QDELETED(accessory) || !LAZYIN(jumpsuit.accessories, accessory) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	accessory.on_removed(source)
	if(!in_thief_mode(user))
		user.visible_message(
			span_danger("[user] takes [accessory] off of [source]'s [jumpsuit]!"), \
			span_danger("You take [accessory] off of [source]'s [jumpsuit]!")
			)
		if(!user.put_in_hands(accessory, ignore_anim = FALSE))
			accessory.forceMove_turf()
	else
		if(!user.put_in_hands(accessory, silent = TRUE))
			accessory.forceMove_turf()

/datum/strippable_item/mob_item_slot/left_ear
	key = STRIPPABLE_ITEM_L_EAR
	item_slot = ITEM_SLOT_EAR_LEFT

/datum/strippable_item/mob_item_slot/right_ear
	key = STRIPPABLE_ITEM_R_EAR
	item_slot = ITEM_SLOT_EAR_RIGHT

/datum/strippable_item/mob_item_slot/neck
	key = STRIPPABLE_ITEM_NECK
	item_slot = ITEM_SLOT_NECK

/datum/strippable_item/mob_item_slot/suit
	key = STRIPPABLE_ITEM_SUIT
	item_slot = ITEM_SLOT_CLOTH_OUTER

/datum/strippable_item/mob_item_slot/gloves
	key = STRIPPABLE_ITEM_GLOVES
	item_slot = ITEM_SLOT_GLOVES

/datum/strippable_item/mob_item_slot/feet
	key = STRIPPABLE_ITEM_FEET
	item_slot = ITEM_SLOT_FEET

/datum/strippable_item/mob_item_slot/suit_storage
	key = STRIPPABLE_ITEM_SUIT_STORAGE
	item_slot = ITEM_SLOT_SUITSTORE

/datum/strippable_item/mob_item_slot/suit_storage/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/suit_storage/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/id
	key = STRIPPABLE_ITEM_ID
	item_slot = ITEM_SLOT_ID

/datum/strippable_item/mob_item_slot/pda
	key = STRIPPABLE_ITEM_PDA
	item_slot = ITEM_SLOT_PDA

/datum/strippable_item/mob_item_slot/pda/get_obscuring(atom/source)
	return isnull(get_item(source)) \
		? STRIPPABLE_OBSCURING_NONE \
		: STRIPPABLE_OBSCURING_HIDDEN

/datum/strippable_item/mob_item_slot/belt
	key = STRIPPABLE_ITEM_BELT
	item_slot = ITEM_SLOT_BELT

/datum/strippable_item/mob_item_slot/belt/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/belt/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/pocket
	/// Which pocket we're referencing. Used for visible text.
	var/pocket_side

/datum/strippable_item/mob_item_slot/pocket/get_obscuring(atom/source)
	return isnull(get_item(source)) \
		? STRIPPABLE_OBSCURING_NONE \
		: STRIPPABLE_OBSCURING_HIDDEN

/datum/strippable_item/mob_item_slot/pocket/get_equip_delay(obj/item/equipping)
	return POCKET_EQUIP_DELAY // Equipping is 4 times as fast as stripping

/datum/strippable_item/mob_item_slot/pocket/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!. && !in_thief_mode(user))
		warn_owner(source)

/datum/strippable_item/mob_item_slot/pocket/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	to_chat(user, span_notice("You try to empty [source]'s [pocket_side] pocket."))

	add_attack_logs(user, source, "Attempting pickpocketing of [item]")
	item.add_fingerprint(user)

	var/result = start_unequip_mob(item, source, user, POCKET_STRIP_DELAY)

	if(!result && !in_thief_mode(user))
		warn_owner(source)

	return result

/datum/strippable_item/mob_item_slot/pocket/proc/warn_owner(atom/owner)
	owner.balloon_alert(owner, "You feel your [pocket_side] pocket being fumbled with!")

/datum/strippable_item/mob_item_slot/pocket/left
	key = STRIPPABLE_ITEM_LPOCKET
	item_slot = ITEM_SLOT_POCKET_LEFT
	pocket_side = "left"

/datum/strippable_item/mob_item_slot/pocket/right
	key = STRIPPABLE_ITEM_RPOCKET
	item_slot = ITEM_SLOT_POCKET_RIGHT
	pocket_side = "right"

/proc/get_strippable_alternate_action_internals(obj/item/item, atom/source)
	if(!iscarbon(source))
		return

	var/mob/living/carbon/carbon_source = source
	if(carbon_source.has_airtight_items() && istype(item, /obj/item/tank))
		if(carbon_source.internal != item)
			return "enable_internals"
		else
			return "disable_internals"

/proc/strippable_alternate_action_internals(obj/item/item, atom/source, mob/user)
	var/obj/item/tank/tank = item
	if(!istype(tank))
		return

	var/mob/living/carbon/carbon_source = source
	if(!istype(carbon_source))
		return

	var/enabling = carbon_source.internal != item

	if(enabling && !carbon_source.has_airtight_items())
		return

	carbon_source.visible_message(
		span_danger("[user] tries to [(enabling) ? "open" : "close"] the valve on [source]'s [item.name]."),
		span_userdanger("[user] tries to [(enabling) ? "open" : "close"] the valve on your [item.name]."),
	)

	if(!do_after(user, INTERNALS_TOGGLE_DELAY, carbon_source, max_interact_count = 1))
		return

	if(enabling && !carbon_source.has_airtight_items())
		return

	if(carbon_source.internal == item)
		carbon_source.internal = null
	else if(!QDELETED(item))
		carbon_source.internal = item

	carbon_source.update_action_buttons_icon()

	carbon_source.visible_message(
		span_danger("[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on [source]'s [item.name]."),
		span_userdanger("[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on your [item.name]."),
	)


#undef INTERNALS_TOGGLE_DELAY
#undef POCKET_EQUIP_DELAY
