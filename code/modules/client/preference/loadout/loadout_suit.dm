/datum/gear/suit
	subtype_path = /datum/gear/suit
	slot = slot_wear_suit
	sort_category = "External Wear"

//WINTER COATS
/datum/gear/suit/coat
	subtype_path = /datum/gear/suit/coat

/datum/gear/suit/coat/grey
	display_name = "winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat

/datum/gear/suit/coat/job
	subtype_path = /datum/gear/suit/coat/job
	subtype_cost_overlap = FALSE

/datum/gear/suit/coat/job/sec
	display_name = "winter coat, security"
	path = /obj/item/clothing/suit/hooded/wintercoat/security
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot", "Brig Physician")

/datum/gear/suit/coat/job/hos
	display_name = "winter coat, head of security"
	path = /obj/item/clothing/suit/hooded/wintercoat/security/hos
	allowed_roles = list("Head of Security")

/datum/gear/suit/coat/job/captain
	display_name = "winter coat, captain"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain
	allowed_roles = list("Captain")

/datum/gear/suit/coat/job/med
	display_name = "winter coat, medical"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Intern", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Brig Physician" , "Coroner")

/datum/gear/suit/coat/job/cmo
	display_name = "winter coat, chief medical officer"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/cmo
	allowed_roles = list("Chief Medical Officer")

/datum/gear/suit/coat/job/sci
	display_name = "winter coat, science"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/science
	allowed_roles = list("Scientist", "Research Director", "Student Scientist")

/datum/gear/suit/coat/job/rd
	display_name = "winter coat, research director"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/science/rd
	allowed_roles = list("Research Director")

/datum/gear/suit/coat/job/engi
	display_name = "winter coat, engineering"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	allowed_roles = list("Chief Engineer", "Station Engineer", "Trainee Engineer", "Mechanic")

/datum/gear/suit/coat/job/atmos
	display_name = "winter coat, atmospherics"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	allowed_roles = list("Chief Engineer", "Life Support Specialist")

/datum/gear/suit/coat/job/ce
	display_name = "winter coat, chief engineer"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/ce
	allowed_roles = list("Chief Engineer")

/datum/gear/suit/coat/job/hydro
	display_name = "winter coat, hydroponics"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list("Botanist")

/datum/gear/suit/coat/job/cargo
	display_name = "winter coat, cargo"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/suit/coat/job/qm
	display_name = "winter coat, quartermaster"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo/qm
	allowed_roles = list("Quartermaster")

/datum/gear/suit/coat/job/miner
	display_name = "winter coat, miner"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list("Shaft Miner")

/datum/gear/suit/coat/job/hop
	display_name = "winter coat, head of personnel"
	path = /obj/item/clothing/suit/hooded/wintercoat/hop
	allowed_roles = list("Head of Personnel")

//LABCOATS
/datum/gear/suit/labcoat_emt
	display_name = "labcoat, paramedic"
	path = /obj/item/clothing/suit/storage/labcoat/emt
	allowed_roles = list("Chief Medical Officer", "Paramedic")

//JACKETS
/datum/gear/suit/leather_jacket
	display_name = "leather jacket"
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/suit/motojacket
	display_name = "leather motorcycle jacket"
	path = /obj/item/clothing/suit/jacket/motojacket

/datum/gear/suit/br_tcoat
	display_name = "trenchcoat, brown"
	path = /obj/item/clothing/suit/browntrenchcoat

/datum/gear/suit/bl_tcoat
	display_name = "trenchcoat, black"
	path = /obj/item/clothing/suit/blacktrenchcoat

/datum/gear/suit/bomber_jacket
	display_name = "bomber jacket"
	path = /obj/item/clothing/suit/jacket

/datum/gear/suit/miljacket
	display_name = "military jacket, select"
	path = /obj/item/clothing/suit/jacket/miljacket

/datum/gear/suit/miljacket/New()
	..()
	var/list/jackets = list("olive" = /obj/item/clothing/suit/jacket/miljacket,
							"navy" = /obj/item/clothing/suit/jacket/miljacket/navy,
							"desert" = /obj/item/clothing/suit/jacket/miljacket/desert,
							"white" = /obj/item/clothing/suit/jacket/miljacket/white,
							)
	gear_tweaks += new /datum/gear_tweak/path(jackets, src)

/datum/gear/suit/secjacket
	display_name = "security jacket"
	path = /obj/item/clothing/suit/armor/secjacket
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/suit/coat/russian
	display_name = "russian coat"
	path = /obj/item/clothing/suit/russiancoat

/datum/gear/suit/secbomber
	display_name = "security bomber"
	path = /obj/item/clothing/suit/jacket/pilot
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/suit/sec_rps
	display_name = "security belt-shoulder system"
	path = /obj/item/clothing/suit/armor/vest/sec_rps
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

//SURAGI JACKET
/datum/gear/suit/suragi_jacket
	subtype_path = /datum/gear/suit/suragi_jacket

/datum/gear/suit/suragi_jacket/civ
	display_name = "Suragi Jacket"
	path = /obj/item/clothing/suit/storage/suragi_jacket/civ


/datum/gear/suit/suragi_jacket/sec
	display_name = "Suragi Jacket - Security"
	path = /obj/item/clothing/suit/storage/suragi_jacket/sec
	allowed_roles = list("Warden", "Detective", "Security Officer", "Security Pod Pilot")


/datum/gear/suit/suragi_jacket/cargo
	display_name = "Suragi Jacket - Cargo"
	path = /obj/item/clothing/suit/storage/suragi_jacket/cargo
	allowed_roles = list("Cargo Technician")


/datum/gear/suit/suragi_jacket/atmos
	display_name = "Suragi Jacket - Atmospherics"
	path = /obj/item/clothing/suit/storage/suragi_jacket/atmos
	allowed_roles = list("Life Support Specialist")


/datum/gear/suit/suragi_jacket/eng
	display_name = "Suragi Jacket - Engineering"
	path = /obj/item/clothing/suit/storage/suragi_jacket/eng
	allowed_roles = list("Station Engineer", "Trainee Engineer", "Mechanic")


/datum/gear/suit/suragi_jacket/botany
	display_name = "Suragi Jacket - Hydroponics"
	path = /obj/item/clothing/suit/storage/suragi_jacket/botany
	allowed_roles = list("Botanist")


/datum/gear/suit/suragi_jacket/medic
	display_name = "Suragi Jacket - Medical"
	path = /obj/item/clothing/suit/storage/suragi_jacket/medic
	allowed_roles = list("Medical Doctor", "Intern", "Psychiatrist", "Paramedic", "Coroner")


/datum/gear/suit/suragi_jacket/medsec
	display_name = "Suragi Jacket - Medical Security"
	path = /obj/item/clothing/suit/storage/suragi_jacket/medsec
	allowed_roles = list("Brig Physician")


/datum/gear/suit/suragi_jacket/virus
	display_name = "Suragi Jacket - Virology"
	path = /obj/item/clothing/suit/storage/suragi_jacket/virus
	allowed_roles = list("Virologist")


/datum/gear/suit/suragi_jacket/chem
	display_name = "Suragi Jacket - Chemistry"
	path = /obj/item/clothing/suit/storage/suragi_jacket/chem
	allowed_roles = list("Chemist")


/datum/gear/suit/suragi_jacket/genetics
	display_name = "Suragi Jacket - Genetics"
	path = /obj/item/clothing/suit/storage/suragi_jacket/genetics
	allowed_roles = list("Geneticist")


/datum/gear/suit/suragi_jacket/robot
	display_name = "Suragi Jacket - Roboticist"
	path = /obj/item/clothing/suit/storage/suragi_jacket/robot
	allowed_roles = list("Roboticist")


/datum/gear/suit/suragi_jacket/sci
	display_name = "Suragi Jacket - Science"
	path = /obj/item/clothing/suit/storage/suragi_jacket/sci
	allowed_roles = list("Scientist", "Student Scientist")


/datum/gear/suit/suragi_jacket/janitor
	display_name = "Suragi Jacket - Janitor"
	path = /obj/item/clothing/suit/storage/suragi_jacket/janitor
	allowed_roles = list("Janitor")


/datum/gear/suit/ianshirt
	display_name = "Ian Shirt"
	path = /obj/item/clothing/suit/ianshirt

/datum/gear/suit/hoodie
	display_name = "hoodie, select"
	path = /obj/item/clothing/suit/hooded/hoodie

/datum/gear/suit/hoodie/New()
	..()
	var/list/hoods = list(/obj/item/clothing/suit/hooded/hoodie,
						  /obj/item/clothing/suit/hooded/hoodie/tp,
						  /obj/item/clothing/suit/hooded/hoodie/nt,
						  /obj/item/clothing/suit/hooded/hoodie/lam,
						  /obj/item/clothing/suit/hooded/hoodie/cut,
						  /obj/item/clothing/suit/hooded/hoodie/mit,
						  /obj/item/clothing/suit/hooded/hoodie/blue,
						  )
	gear_tweaks += new /datum/gear_tweak/path(hoods, src, TRUE)

//SUITS!

/datum/gear/suit/blacksuit
	display_name = "suit jacket, select"
	path = /obj/item/clothing/suit/storage/lawyer/blackjacket

/datum/gear/suit/blacksuit/New()
	..()
	var/list/suits = list("black" = /obj/item/clothing/suit/storage/lawyer/blackjacket,
						  "blue" = /obj/item/clothing/suit/storage/lawyer/bluejacket,
						  "purple" = /obj/item/clothing/suit/storage/lawyer/purpjacket,)
	gear_tweaks += new /datum/gear_tweak/path(suits, src, TRUE)

//Robes!

/datum/gear/suit/witch
	display_name = "witch robes"
	path = /obj/item/clothing/suit/wizrobe/marisa/fake


//Suspenders

/datum/gear/suit/suspenders
	display_name = "suspenders, color"
	path = /obj/item/clothing/suit/suspenders

/datum/gear/suit/suspenders/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)
