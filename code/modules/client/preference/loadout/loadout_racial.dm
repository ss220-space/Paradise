/datum/gear/racial
	sort_category = "Racial"
	subtype_path = /datum/gear/racial
	cost = 1

/datum/gear/racial/taj
	display_name = "embroidered veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind
	slot = ITEM_SLOT_EYES

/datum/gear/racial/taj/bot
	display_name = "veil, blooming"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built botanical HUD."
	path = /obj/item/clothing/glasses/hud/hydroponic/tajblind
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/racial/taj/sec
	display_name = "veil, sleek"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tajblind
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_JUDGE)
	cost = 2

/datum/gear/racial/taj/iaa
	display_name = "veil, sleek(read-only)"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tajblind/read_only
	allowed_roles = list(JOB_TITLE_LAWYER)
	cost = 2

/datum/gear/racial/taj/med
	display_name = "veil, lightweight"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built medical HUD."
	path = /obj/item/clothing/glasses/hud/health/tajblind
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_CHEMIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BRIGDOC, JOB_TITLE_CORONER)
	cost = 2

/datum/gear/racial/taj/sci
	display_name = "veil, hi-tech"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built science goggles"
	path = /obj/item/clothing/glasses/tajblind/sci
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_GENETICIST, JOB_TITLE_CHEMIST)
	cost = 2

/datum/gear/racial/taj/eng
	display_name = "veil, industrial"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built optical meson scanners and welding shields."
	path = /obj/item/clothing/glasses/tajblind/eng
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH)
	cost = 2

/datum/gear/racial/taj/cargo
	display_name = "veil, khaki"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built optical meson scanners."
	path = /obj/item/clothing/glasses/tajblind/cargo
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)
	cost = 2

/datum/gear/racial/taj/diag
	display_name = "veil, diagnostic"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built diagnostic HUD."
	path = /obj/item/clothing/glasses/hud/diagnostic/tajblind
	allowed_roles = list(JOB_TITLE_ROBOTICIST, JOB_TITLE_RD)
	cost = 2
/datum/gear/racial/taj/skills
	display_name = "veil, skills"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built skills HUD."
	path = /obj/item/clothing/glasses/hud/skills/tajblind
	allowed_roles = list(JOB_TITLE_HOP, JOB_TITLE_CAPTAIN)
	cost = 2
/datum/gear/racial/footwraps
	display_name = "cloth footwraps, select"
	path = /obj/item/clothing/shoes/footwraps
	slot = ITEM_SLOT_FEET

/datum/gear/racial/footwraps/New()
	..()
	var/list/feet = list("classic" = /obj/item/clothing/shoes/footwraps,
						 "yellow" = /obj/item/clothing/shoes/footwraps/yellow,
						 "silver" = /obj/item/clothing/shoes/footwraps/silver,
						 "red" = /obj/item/clothing/shoes/footwraps/red,
						 "blue" = /obj/item/clothing/shoes/footwraps/blue,
						 "black" = /obj/item/clothing/shoes/footwraps/black,
						 "brown" = /obj/item/clothing/shoes/footwraps/brown,
						 )
	gear_tweaks += new /datum/gear_tweak/path(feet, src)
