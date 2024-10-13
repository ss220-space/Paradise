/datum/gear/glasses
	subtype_path = /datum/gear/glasses
	slot = ITEM_SLOT_EYES
	sort_category = "Glasses"

/datum/gear/glasses/sunglasses
	display_name = "cheap sunglasses"
	path = /obj/item/clothing/glasses/sunglasses_fake

/datum/gear/glasses/eyepatch
	display_name = "Eyepatch"
	path = /obj/item/clothing/glasses/eyepatch

/datum/gear/glasses/blindfold
	display_name = "Blindfold"
	path = /obj/item/clothing/glasses/sunglasses/blindfold

/datum/gear/glasses/blindfold/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)

/datum/gear/glasses/blindfold_fake
	display_name = "Fake blindfold"
	path = /obj/item/clothing/glasses/sunglasses/blindfold_fake

/datum/gear/glasses/blindfold_fake/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)

/datum/gear/glasses/hipster
	display_name = "Hipster glasses"
	path = /obj/item/clothing/glasses/regular/hipster

/datum/gear/glasses/monocle
	display_name = "Monocle"
	path = /obj/item/clothing/glasses/monocle

/datum/gear/glasses/prescription
	display_name = "Prescription glasses"
	path = /obj/item/clothing/glasses/regular

/datum/gear/glasses/sectacticool
	display_name = "Security tactical glasses"
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tacticool
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)
