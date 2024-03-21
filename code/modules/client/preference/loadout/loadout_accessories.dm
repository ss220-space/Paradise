/datum/gear/accessory
	subtype_path = /datum/gear/accessory
	slot = slot_tie
	sort_category = "Accessories"

/datum/gear/accessory/scarf
	display_name = "scarf, select"
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
	display_name = "striped scarf, select"
	path = /obj/item/clothing/accessory/stripedredscarf

/datum/gear/accessory/scarfstriped/New()
	..()
	var/list/scarfs = list(/obj/item/clothing/accessory/stripedredscarf,
						   /obj/item/clothing/accessory/stripedgreenscarf,
						   /obj/item/clothing/accessory/stripedbluescarf,)
	gear_tweaks += new /datum/gear_tweak/path(scarfs, src, TRUE)

/datum/gear/accessory/holobadge
	display_name = "holobadge, pin"
	path = /obj/item/clothing/accessory/holobadge
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/accessory/holobadge_n
	display_name = "holobadge, cord"
	path = /obj/item/clothing/accessory/holobadge/cord
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/accessory/holobadge/detective
	display_name = "holobadge, detective"
	path = /obj/item/clothing/accessory/holobadge/detective
	allowed_roles = list("Head of Security", "Detective")

/datum/gear/accessory/tie
	display_name = "tie, select"
	path = /obj/item/clothing/accessory/blue

/datum/gear/accessory/tie/New()
	..()
	var/list/ties = list(/obj/item/clothing/accessory/blue,
						 /obj/item/clothing/accessory/red,
						 /obj/item/clothing/accessory/black,
						 /obj/item/clothing/accessory/horrible,)
	gear_tweaks += new /datum/gear_tweak/path(ties, src, TRUE)

/datum/gear/accessory/stethoscope
	display_name = "stethoscope"
	path = /obj/item/clothing/accessory/stethoscope
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Intern", "Paramedic", "Brig Physician")

/datum/gear/accessory/ntrjacket
	display_name = "jacket, nt rep"
	path = /obj/item/clothing/accessory/ntrjacket
	allowed_roles = list("Nanotrasen Representative")

/datum/gear/accessory/cowboyshirt
	display_name = "cowboy shirt, select"
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
	display_name = "gold locket"
	path = /obj/item/clothing/accessory/necklace/locket

/datum/gear/accessory/necklace
	display_name = "simple necklace"
	path = /obj/item/clothing/accessory/necklace

/datum/gear/accessory/corset
	display_name = "corset, select"
	path = /obj/item/clothing/accessory/corset

/datum/gear/accessory/corset/New()
	..()
	var/list/corsets = list(/obj/item/clothing/accessory/corset,
							/obj/item/clothing/accessory/corset/red,
							/obj/item/clothing/accessory/corset/blue,
							)
	gear_tweaks += new /datum/gear_tweak/path(corsets, src, TRUE)

/datum/gear/accessory/armband_red
	display_name = "armband"
	path = /obj/item/clothing/accessory/armband

/datum/gear/accessory/armband_civ
	display_name = "armband, blue-yellow"
	path = /obj/item/clothing/accessory/armband/yb

/datum/gear/accessory/armband_job
	subtype_path = /datum/gear/accessory/armband_job
	subtype_cost_overlap = FALSE

/datum/gear/accessory/armband_job/sec
	display_name = " armband, security"
	path = /obj/item/clothing/accessory/armband/sec
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Brig Physician", "Security Pod Pilot")

/datum/gear/accessory/armband_job/cargo
	display_name = "cargo armband"
	path = /obj/item/clothing/accessory/armband/cargo
	allowed_roles = list("Quartermaster","Cargo Technician", "Shaft Miner")

/datum/gear/accessory/armband_job/medical
	display_name = "armband, medical"
	path = /obj/item/clothing/accessory/armband/med
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Intern", "Coroner", "Paramedic", "Brig Physician")

/datum/gear/accessory/armband_job/emt
	display_name = "armband, EMT"
	path = /obj/item/clothing/accessory/armband/medgreen
	allowed_roles = list("Paramedic", "Brig Physician")

/datum/gear/accessory/armband_job/engineering
	display_name = "armband, engineering"
	path = /obj/item/clothing/accessory/armband/engine
	allowed_roles = list("Chief Engineer","Station Engineer", "Life Support Specialist", "Trainee Engineer")

/datum/gear/accessory/armband_job/hydro
	display_name = "armband, hydroponics"
	path = /obj/item/clothing/accessory/armband/hydro
	allowed_roles = list("Botanist")

/datum/gear/accessory/armband_job/sci
	display_name = "armband, science"
	path = /obj/item/clothing/accessory/armband/science
	allowed_roles = list("Research Director", "Scientist", "Student Scientist", "Student Scientist", "Roboticist")
