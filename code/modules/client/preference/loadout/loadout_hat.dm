/datum/gear/hat
	subtype_path = /datum/gear/hat
	slot = ITEM_SLOT_HEAD
	sort_category = "Headwear"

/datum/gear/hat/hhat
	display_name = "hardhat, select"
	path = /obj/item/clothing/head/hardhat
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH)

/datum/gear/hat/hhat/New()
	..()
	var/list/hats = list("yellow" = /obj/item/clothing/head/hardhat,
						 "orange" = /obj/item/clothing/head/hardhat/orange,
						 "blue" = /obj/item/clothing/head/hardhat/dblue)
	gear_tweaks += new /datum/gear_tweak/path(hats, src)

/datum/gear/hat/that
	display_name = "top hat"
	path = /obj/item/clothing/head/that

/datum/gear/hat/flatcap
	display_name = "flat cap"
	path = /obj/item/clothing/head/flatcap

/datum/gear/hat/ushanka
	display_name = "ushanka"
	path = /obj/item/clothing/head/ushanka

/datum/gear/hat/witch
	display_name = "witch hat"
	path = /obj/item/clothing/head/wizard/marisa/fake

/datum/gear/hat/piratecaphat
	display_name = "pirate captian hat"
	path = /obj/item/clothing/head/pirate

/datum/gear/hat/fez
	display_name = "fez"
	path = /obj/item/clothing/head/fez

/datum/gear/hat/rasta
	display_name = "rasta hat"
	path = /obj/item/clothing/head/beanie/rasta

/datum/gear/hat/fedora
	display_name = "fedora, select"
	path = /obj/item/clothing/head/fedora

/datum/gear/hat/fedora/New()
	..()
	var/list/hats = list(/obj/item/clothing/head/fedora,
						 /obj/item/clothing/head/fedora/whitefedora,
						 /obj/item/clothing/head/fedora/brownfedora)
	gear_tweaks += new /datum/gear_tweak/path(hats, src, TRUE)

/datum/gear/hat/capcsec
	display_name = "security corporate cap"
	path = /obj/item/clothing/head/soft/sec/corp
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/capsec
	display_name = "security cap"
	path = /obj/item/clothing/head/soft/sec
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/capred
	display_name = "cap, select"
	path = /obj/item/clothing/head/soft/red

/datum/gear/hat/capred/New()
	..()
	var/list/hats = list(/obj/item/clothing/head/soft/red,
						 /obj/item/clothing/head/soft/blue,
						 /obj/item/clothing/head/soft/green,
						 /obj/item/clothing/head/soft/black,
						 /obj/item/clothing/head/soft/purple,
						 /obj/item/clothing/head/soft/mime,
						 /obj/item/clothing/head/soft/orange,
						 /obj/item/clothing/head/soft/grey,
						 /obj/item/clothing/head/soft/yellow,
						 /obj/item/clothing/head/soft/solgov,)
	gear_tweaks += new /datum/gear_tweak/path(hats, src, TRUE)
/datum/gear/hat/cowboyhat
	display_name = "cowboy hat, select"
	path = /obj/item/clothing/head/cowboyhat

/datum/gear/hat/cowboyhat/New()
	..()
	var/list/hats = list(/obj/item/clothing/head/cowboyhat,
						 /obj/item/clothing/head/cowboyhat/tan,
						 /obj/item/clothing/head/cowboyhat/black,
						 /obj/item/clothing/head/cowboyhat/white,
						 /obj/item/clothing/head/cowboyhat/pink)
	gear_tweaks += new /datum/gear_tweak/path(hats, src, TRUE)

/datum/gear/hat/beret
	display_name = "beret, select"
	path = /obj/item/clothing/head/beret

/datum/gear/hat/beret/New()
	..()
	var/list/berets = list("red" = /obj/item/clothing/head/beret,
						   "purple" = /obj/item/clothing/head/beret/purple_normal,
						   "black" = /obj/item/clothing/head/beret/black,
						   "blue" = /obj/item/clothing/head/beret/blue)
	gear_tweaks += new /datum/gear_tweak/path(berets, src)

/datum/gear/hat/beret_job
	subtype_path = /datum/gear/hat/beret_job
	subtype_cost_overlap = FALSE

/datum/gear/hat/beret_job/sec
	display_name = "security beret"
	path = /obj/item/clothing/head/beret/sec
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/beret_job/sec_black
	display_name = "black security beret"
	path = /obj/item/clothing/head/beret/sec/black
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/beret_job/marine
	display_name = "royal marines commando beret"
	path = /obj/item/clothing/head/beret/centcom/officer/sparkyninja_beret
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_BLUESHIELD)

/datum/gear/hat/beret_job/marine_old
	display_name = "marine lieutenant beret"
	path = /obj/item/clothing/head/beret/centcom/officer/sigholt
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_BLUESHIELD)

/datum/gear/hat/beret_job/sci
	display_name = "science beret"
	path = /obj/item/clothing/head/beret/sci
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_GENETICIST)

/datum/gear/hat/beret_job/med
	display_name = "medical beret"
	path = /obj/item/clothing/head/beret/med
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_VIROLOGIST, JOB_TITLE_BRIGDOC, JOB_TITLE_CORONER, JOB_TITLE_PARAMEDIC, JOB_TITLE_CHEMIST, JOB_TITLE_GENETICIST, JOB_TITLE_PSYCHIATRIST)

/datum/gear/hat/beret_job/eng
	display_name = "engineering beret"
	path = /obj/item/clothing/head/beret/eng
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE)

/datum/gear/hat/beret_job/atmos
	display_name = "atmospherics beret"
	path = /obj/item/clothing/head/beret/atmos
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH)

/datum/gear/hat/surgicalcap
	display_name = "surgical cap, select"
	path = /obj/item/clothing/head/surgery/purple
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN)

/datum/gear/hat/surgicalcap/New()
	..()
	var/list/caps = list("purple" = /obj/item/clothing/head/surgery/purple,
						 "lightgreen" = /obj/item/clothing/head/surgery/lightgreen,
						 "green" = /obj/item/clothing/head/surgery/green,)
	gear_tweaks += new /datum/gear_tweak/path(caps, src)

/datum/gear/hat/flowerpin
	display_name = "hair flower"
	path = /obj/item/clothing/head/hairflower

/datum/gear/hat/lwhelmet
	display_name = "security lightweight helmet"
	path = /obj/item/clothing/head/helmet/lightweighthelmet
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/beanie
	display_name = "beanie, select"
	path = /obj/item/clothing/head/beanie

/datum/gear/hat/beanie/New()
	..()
	var/list/beanies = list(/obj/item/clothing/head/beanie,
							/obj/item/clothing/head/beanie/black,
							/obj/item/clothing/head/beanie/christmas,
							/obj/item/clothing/head/beanie/cyan,
							/obj/item/clothing/head/beanie/darkblue,
							/obj/item/clothing/head/beanie/green,
							/obj/item/clothing/head/beanie/orange,
							/obj/item/clothing/head/beanie/purple,
							/obj/item/clothing/head/beanie/red,
							/obj/item/clothing/head/beanie/yellow,
							/obj/item/clothing/head/beanie/striped,
							/obj/item/clothing/head/beanie/stripedblue,
							/obj/item/clothing/head/beanie/stripedgreen,
							/obj/item/clothing/head/beanie/stripedred)
	gear_tweaks += new /datum/gear_tweak/path(beanies, src, TRUE)
