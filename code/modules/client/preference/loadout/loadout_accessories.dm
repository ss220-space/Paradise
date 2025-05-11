/datum/gear/accessory
	subtype_path = /datum/gear/accessory
	slot = ITEM_SLOT_ACCESSORY
	sort_category = "Accessories"

/datum/gear/accessory/scarf
	index_name = "scarf, select"
	display_name = "scarf"
	path = /obj/item/clothing/accessory/scarf/red

/datum/gear/accessory/scarf/New()
	..()
	var/list/scarfs = list(/obj/item/clothing/accessory/scarf/red,
					  	   /obj/item/clothing/accessory/scarf/green,
					  	   /obj/item/clothing/accessory/scarf/darkblue,
					  	   /obj/item/clothing/accessory/scarf/purple,
					  	   /obj/item/clothing/accessory/scarf/yellow,
					  	   /obj/item/clothing/accessory/scarf/orange,
					  	   /obj/item/clothing/accessory/scarf/lightblue,
					  	   /obj/item/clothing/accessory/scarf/white,
					  	   /obj/item/clothing/accessory/scarf/black,
					  	   /obj/item/clothing/accessory/scarf/zebra,
					  	   /obj/item/clothing/accessory/scarf/christmas,)
	gear_tweaks += new /datum/gear_tweak/path(scarfs, src, TRUE)

/datum/gear/accessory/scarfstriped
	index_name = "striped scarf, select"
	display_name = "striped scarf"
	path = /obj/item/clothing/accessory/stripedredscarf

/datum/gear/accessory/scarfstriped/New()
	..()
	var/list/scarfs = list(/obj/item/clothing/accessory/stripedredscarf,
						   /obj/item/clothing/accessory/stripedgreenscarf,
						   /obj/item/clothing/accessory/stripedbluescarf,)
	gear_tweaks += new /datum/gear_tweak/path(scarfs, src, TRUE)

/datum/gear/accessory/holobadge
	index_name = "holobadge, pin"
	path = /obj/item/clothing/accessory/holobadge
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/accessory/holobadge_n
	index_name = "holobadge, cord"
	path = /obj/item/clothing/accessory/holobadge/cord
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/accessory/holobadge/detective
	index_name = "holobadge, detective"
	path = /obj/item/clothing/accessory/holobadge/detective
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_DETECTIVE)

/datum/gear/accessory/tie
	index_name = "tie, select"
	display_name = "tie"
	path = /obj/item/clothing/accessory/blue

/datum/gear/accessory/tie/New()
	..()
	var/list/ties = list(/obj/item/clothing/accessory/blue,
						 /obj/item/clothing/accessory/red,
						 /obj/item/clothing/accessory/black,
						 /obj/item/clothing/accessory/horrible,)
	gear_tweaks += new /datum/gear_tweak/path(ties, src, TRUE)

/datum/gear/accessory/stethoscope
	index_name = "stethoscope"
	path = /obj/item/clothing/accessory/stethoscope
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_MINING_MEDIC, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_PARAMEDIC, JOB_TITLE_BRIGDOC)

/datum/gear/accessory/ntrjacket
	index_name = "jacket, nt rep"
	path = /obj/item/clothing/accessory/ntrjacket
	allowed_roles = list(JOB_TITLE_REPRESENTATIVE)

/datum/gear/accessory/waistcoat
	index_name = "waistcoat"
	path = /obj/item/clothing/accessory/waistcoat

/datum/gear/accessory/cowboyshirt
	index_name = "cowboy shirt, select"
	path = /obj/item/clothing/accessory/cowboyshirt

/datum/gear/accessory/cowboyshirt/New()
	..()
	var/list/shirts = list(/obj/item/clothing/accessory/cowboyshirt,
						   /obj/item/clothing/accessory/cowboyshirt/short_sleeved,
						   /obj/item/clothing/accessory/cowboyshirt/white,
						   /obj/item/clothing/accessory/cowboyshirt/white/short_sleeved,
						   /obj/item/clothing/accessory/cowboyshirt/pink,
						   /obj/item/clothing/accessory/cowboyshirt/pink/short_sleeved,
						   /obj/item/clothing/accessory/cowboyshirt/red,
						   /obj/item/clothing/accessory/cowboyshirt/red/short_sleeved,
						   /obj/item/clothing/accessory/cowboyshirt/navy,
						   /obj/item/clothing/accessory/cowboyshirt/navy/short_sleeved,)
	gear_tweaks += new /datum/gear_tweak/path(shirts, src, TRUE)

/datum/gear/accessory/locket
	index_name = "gold locket"
	path = /obj/item/clothing/accessory/necklace/locket

/datum/gear/accessory/necklace
	index_name = "simple necklace"
	path = /obj/item/clothing/accessory/necklace

/datum/gear/accessory/corset
	index_name = "corset, select"
	display_name = "corset"
	path = /obj/item/clothing/accessory/corset

/datum/gear/accessory/corset/New()
	..()
	var/list/corsets = list(/obj/item/clothing/accessory/corset,
							/obj/item/clothing/accessory/corset/red,
							/obj/item/clothing/accessory/corset/blue,
							)
	gear_tweaks += new /datum/gear_tweak/path(corsets, src, TRUE)

/datum/gear/accessory/armband_red
	index_name = "armband"
	path = /obj/item/clothing/accessory/armband

/datum/gear/accessory/armband_civ
	index_name = "armband, blue-yellow"
	path = /obj/item/clothing/accessory/armband/yb

/datum/gear/accessory/armband_job
	subtype_path = /datum/gear/accessory/armband_job
	subtype_cost_overlap = FALSE

/datum/gear/accessory/armband_job/sec
	index_name = " armband, security"
	path = /obj/item/clothing/accessory/armband/sec
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_BRIGDOC, JOB_TITLE_PILOT)

/datum/gear/accessory/armband_job/cargo
	index_name = "cargo armband"
	path = /obj/item/clothing/accessory/armband/cargo
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH, JOB_TITLE_MINER, JOB_TITLE_MINING_MEDIC)

/datum/gear/accessory/armband_job/medical
	index_name = "armband, medical"
	path = /obj/item/clothing/accessory/armband/med
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_MINING_MEDIC, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_CORONER, JOB_TITLE_PARAMEDIC, JOB_TITLE_BRIGDOC)

/datum/gear/accessory/armband_job/emt
	index_name = "armband, EMT"
	path = /obj/item/clothing/accessory/armband/medgreen
	allowed_roles = list(JOB_TITLE_PARAMEDIC, JOB_TITLE_BRIGDOC)

/datum/gear/accessory/armband_job/engineering
	index_name = "armband, engineering"
	path = /obj/item/clothing/accessory/armband/engine
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ATMOSTECH, JOB_TITLE_ENGINEER_TRAINEE)

/datum/gear/accessory/armband_job/hydro
	index_name = "armband, hydroponics"
	path = /obj/item/clothing/accessory/armband/hydro
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/accessory/armband_job/sci
	index_name = "armband, science"
	path = /obj/item/clothing/accessory/armband/science
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST)

/datum/gear/accessory/holsters
	index_name = "holster, select"
	display_name = "holster"
	path = /obj/item/clothing/accessory/holster/
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_BRIGDOC, JOB_TITLE_PILOT)

/datum/gear/accessory/holsters/New()
	..()
	var/list/holsters = list(/obj/item/clothing/accessory/holster/leg,
							/obj/item/clothing/accessory/holster/leg/black,
							/obj/item/clothing/accessory/holster/belt,
							/obj/item/clothing/accessory/holster/belt/black,
							)
	gear_tweaks += new /datum/gear_tweak/path(holsters, src, TRUE)

