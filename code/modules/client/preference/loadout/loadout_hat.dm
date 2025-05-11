/datum/gear/hat
	subtype_path = /datum/gear/hat
	slot = ITEM_SLOT_HEAD
	sort_category = "Headwear"

/datum/gear/hat/hhat
	index_name = "hardhat, select"
	display_name = "hardhat"
	path = /obj/item/clothing/head/hardhat
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH)

/datum/gear/hat/hhat/New()
	..()
	var/list/hats = list("yellow" = /obj/item/clothing/head/hardhat,
						 "orange" = /obj/item/clothing/head/hardhat/orange,
						 "blue" = /obj/item/clothing/head/hardhat/dblue)
	gear_tweaks += new /datum/gear_tweak/path(hats, src)

/datum/gear/hat/that
	index_name = "top hat"
	path = /obj/item/clothing/head/that

/datum/gear/hat/flatcap
	index_name = "flat cap"
	path = /obj/item/clothing/head/flatcap

/datum/gear/hat/ushanka
	index_name = "ushanka"
	path = /obj/item/clothing/head/ushanka

/datum/gear/hat/witch
	index_name = "witch hat"
	path = /obj/item/clothing/head/wizard/marisa/fake

/datum/gear/hat/piratecaphat
	index_name = "pirate captian hat"
	path = /obj/item/clothing/head/pirate

/datum/gear/hat/fez
	index_name = "fez"
	path = /obj/item/clothing/head/fez

/datum/gear/hat/rasta
	index_name = "rasta hat"
	path = /obj/item/clothing/head/beanie/rasta

/datum/gear/hat/fedora
	index_name = "fedora, select"
	display_name = "fedora"
	path = /obj/item/clothing/head/fedora

/datum/gear/hat/fedora/New()
	..()
	var/list/hats = list(/obj/item/clothing/head/fedora,
						 /obj/item/clothing/head/fedora/whitefedora,
						 /obj/item/clothing/head/fedora/brownfedora)
	gear_tweaks += new /datum/gear_tweak/path(hats, src, TRUE)

/datum/gear/hat/capcsec
	index_name = "security corporate cap"
	path = /obj/item/clothing/head/soft/sec/corp
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/capsec
	index_name = "security cap"
	path = /obj/item/clothing/head/soft/sec
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/capred
	index_name = "cap, select"
	display_name = "cap"
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
	index_name = "cowboy hat, select"
	display_name = "cowboy hat"
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
	index_name = "beret, select"
	display_name = "beret"
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
	index_name = "security beret"
	path = /obj/item/clothing/head/beret/sec
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/beret_job/sec_black
	index_name = "black security beret"
	path = /obj/item/clothing/head/beret/sec/black
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/beret_job/marine
	index_name = "royal marines commando beret"
	path = /obj/item/clothing/head/beret/centcom/officer/sparkyninja_beret
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_BLUESHIELD)

/datum/gear/hat/beret_job/marine_old
	index_name = "marine lieutenant beret"
	path = /obj/item/clothing/head/beret/centcom/officer/sigholt
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_BLUESHIELD)

/datum/gear/hat/beret_job/sci
	index_name = "science beret"
	path = /obj/item/clothing/head/beret/sci
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_GENETICIST)

/datum/gear/hat/beret_job/med
	index_name = "medical beret"
	path = /obj/item/clothing/head/beret/med
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN, JOB_TITLE_VIROLOGIST, JOB_TITLE_BRIGDOC, JOB_TITLE_CORONER, JOB_TITLE_PARAMEDIC, JOB_TITLE_CHEMIST, JOB_TITLE_GENETICIST, JOB_TITLE_PSYCHIATRIST)

/datum/gear/hat/beret_job/eng
	index_name = "engineering beret"
	path = /obj/item/clothing/head/beret/eng
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE)

/datum/gear/hat/beret_job/atmos
	index_name = "atmospherics beret"
	path = /obj/item/clothing/head/beret/atmos
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH)

/datum/gear/hat/surgicalcap
	index_name = "surgical cap, select"
	display_name = "surgical cap"
	path = /obj/item/clothing/head/surgery/purple
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN)

/datum/gear/hat/surgicalcap/New()
	..()
	var/list/caps = list("purple" = /obj/item/clothing/head/surgery/purple,
						 "lightgreen" = /obj/item/clothing/head/surgery/lightgreen,
						 "green" = /obj/item/clothing/head/surgery/green,)
	gear_tweaks += new /datum/gear_tweak/path(caps, src)

/datum/gear/hat/flowerpin
	index_name = "hair flower"
	path = /obj/item/clothing/head/hairflower

/datum/gear/hat/lwhelmet
	index_name = "security lightweight helmet"
	path = /obj/item/clothing/head/helmet/lightweighthelmet
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/hat/beanie
	index_name = "beanie, select"
	display_name = "beanie"
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
