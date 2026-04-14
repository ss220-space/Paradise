/datum/item_skin_data/gun/stechkin
	item_path = /obj/item/gun/projectile/automatic/pistol

/datum/item_skin_data/stechkin/default
	name = "Обычный"
	icon_state = "pistol"

/datum/item_skin_data/gun/stechkin/sindi
	name = "Синдикат"
	icon_state = "sindi_ste"
	donation_tier = 1
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 17, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 7),
	)

/datum/item_skin_data/gun/stechkin/vitala
	name = "Vitala"
	icon_state = "vitala_ste"
	donation_tier = 1
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 7),
	)

/datum/item_skin_data/gun/stechkin/russian
	name = "Русский"
	icon_state = "ru_ste"
	donation_tier = 2
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 7),
	)

/datum/item_skin_data/gun/stechkin/tacticool
	name = "Тактический"
	icon_state = "TStechkin"
	donation_tier = 3
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 7),
	)

/datum/item_skin_data/gun/stechkin/dig
	name = "Модернизированный"
	icon_state = "dig_ste"
	donation_tier = 4
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 7),
	)
