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

/datum/gear/glasses/medhudpatch
	display_name = "Medical HUD eyepatch"
	path = /obj/item/clothing/glasses/hud/health/patch
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Coroner")

/datum/gear/glasses/sechudpatch
	display_name = "Security HUD eyepatch"
	path = /obj/item/clothing/glasses/hud/security/patch
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot", "Internal Affairs Agent","Magistrate")

/datum/gear/glasses/hydrohudpatch
	display_name = "Hydroponic HUD eyepatch"
	path = /obj/item/clothing/glasses/hud/hydroponic/patch
	allowed_roles = list("Botanist")

/datum/gear/glasses/diaghudpatch
	display_name = "Diagnostic HUD eyepatch"
	path = /obj/item/clothing/glasses/hud/diagnostic/patch
	allowed_roles = list("Research Director", "Roboticist")

/datum/gear/glasses/skillhudpatch
	display_name = "Skills HUD eyepatch"
	path = /obj/item/clothing/glasses/hud/skills/patch
	allowed_roles = list("Head of Personnel", "Captain")
