/datum/keybinding/human
	abstract_type = /datum/keybinding/human
	category = KB_CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/human/toggle_holster
	name = "toggle_holster"
	full_name = "Использовать кобуру"
	description = "Достать/убрать оружие из кобуры"
	hotkey_keys = list("H")
	keybind_signal = COMSIG_KB_HUMAN_TOGGLEHOLSTER_DOWN

/datum/keybinding/human/toggle_holster/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/human/human_mob = user.mob
	if(!human_mob.w_uniform)
		return TRUE
	var/obj/item/clothing/accessory/holster/holster = locate() in human_mob.w_uniform
	holster?.attack_self(user.mob)
	return TRUE

/datum/keybinding/human/quick_equip_belt
	name = "quick_equip_belt"
	full_name = "Быстрая экипировка пояса"
	description = "Put held thing in belt or take out most recent thing from belt"
	hotkey_keys = list("ShiftE")
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIPBELT_DOWN
	/// which slot are we trying to quickdraw from/quicksheathe into?
	var/slot_type = ITEM_SLOT_BELT
	/// what we should call slot_type in messages (including failure messages)
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
	name = "quick_equip_bag"
	full_name = "Быстрая экипировка рюкзака"
	description = "Put held thing in backpack or take out most recent thing from backpack"
	hotkey_keys = list("ShiftV")
	slot_type = ITEM_SLOT_BACK
	slot_item_name = "рюкзак"
	keybind_signal = COMSIG_KB_HUMAN_BAGEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_suit_storage
	name = "quick_equip_suit_storage"
	full_name = "Быстрая экипировка хранилища костюма"
	description = "Put held thing in suit storage slot item or take out most recent thing from suit storage slot item"
	hotkey_keys = list("ShiftQ")
	slot_type = ITEM_SLOT_SUITSTORE
	slot_item_name = "хранилище костюма"
	keybind_signal = COMSIG_KB_HUMAN_SUITEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_lpocket
	hotkey_keys = list("Ctrl1")
	name = "quick_equip_lpocket"
	full_name = "Quick equip left pocket"
	description = "Put in or take out an item in left pocket"
	slot_type = ITEM_SLOT_POCKET_LEFT
	slot_item_name = "left pocket"
	keybind_signal = COMSIG_KB_HUMAN_LPOCKETEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_rpocket
	hotkey_keys = list("Ctrl2")
	name = "quick_equip_rpocket"
	full_name = "Quick equip right pocket"
	description = "Put in or take out an item in right pocket"
	slot_type =  ITEM_SLOT_POCKET_RIGHT
	slot_item_name = "right pocket"
	keybind_signal = COMSIG_KB_HUMAN_RPOCKETEQUIP_DOWN
