/datum/keybinding/human
	category = KB_CATEGORY_HUMAN

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/human/toggle_holster
	name = "Использовать кобуру"
	keys = list("H")

/datum/keybinding/human/toggle_holster/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/human/human_mob = user.mob
	if(!human_mob.w_uniform)
		return TRUE
	var/obj/item/clothing/accessory/holster/holster = locate() in human_mob.w_uniform
	holster?.holster_verb()
	return TRUE

/datum/keybinding/human/quick_equip_belt
	name = "Быстрая экипировка пояса"
	keys = list("ShiftE")
	///which slot are we trying to quickdraw from/quicksheathe into?
	var/slot_type = ITEM_SLOT_BELT
	///what we should call slot_type in messages (including failure messages)
	var/slot_item_name = "пояс"

/datum/keybinding/human/quick_equip_belt/New()
	. = ..()
	var/list/names_list = parse_slot_flags(slot_type)
	slot_item_name = names_list?[1] || slot_item_name

/datum/keybinding/human/quick_equip_belt/down(client/client)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human = client.mob
	human.smart_equip_targeted(slot_type, slot_item_name)
	return TRUE

/datum/keybinding/human/quick_equip_belt/quick_equip_bag
	name = "Быстрая экипировка рюкзака"
	keys = list("ShiftV")
	slot_type = ITEM_SLOT_BACK

/datum/keybinding/human/quick_equip_belt/quick_equip_suit_storage
	name = "Быстрая экипировка хранилища костюма"
	keys = list("ShiftQ")
	slot_type = ITEM_SLOT_SUITSTORE
