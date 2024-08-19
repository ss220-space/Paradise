/datum/gear/neck
	subtype_path = /datum/gear/neck
	slot = ITEM_SLOT_NECK
	sort_category = "Neck"

//Mantles
/datum/gear/neck/mantle
	display_name = "mantle, color"
	path = /obj/item/clothing/neck/mantle

/datum/gear/neck/mantle/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)

/datum/gear/neck/mantle/old_scarf
	display_name = "old scarf"
	path = /obj/item/clothing/neck/mantle/old

/datum/gear/neck/mantle/regal_shawl
	display_name = "regal shawl"
	path = /obj/item/clothing/neck/mantle/regal

/datum/gear/neck/mantle/cowboy_mantle
	display_name = "old wrappings"
	path = /obj/item/clothing/neck/mantle/cowboy

/datum/gear/neck/mantle/job
	subtype_path = /datum/gear/neck/mantle/job
	subtype_cost_overlap = FALSE

/datum/gear/neck/mantle/job/captain
	display_name = "mantle, captain"
	path = /obj/item/clothing/neck/mantle/captain
	allowed_roles = list(JOB_TITLE_CAPTAIN)

/datum/gear/neck/mantle/job/chief_engineer
	display_name = "mantle, chief engineer"
	path = /obj/item/clothing/neck/mantle/chief_engineer
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/neck/mantle/job/chief_medical_officer
	display_name = "mantle, chief medical officer"
	path = /obj/item/clothing/neck/mantle/chief_medical_officer
	allowed_roles = list(JOB_TITLE_CMO)

/datum/gear/neck/mantle/job/head_of_security
	display_name = "mantle, head of security"
	path = /obj/item/clothing/neck/mantle/head_of_security
	allowed_roles = list(JOB_TITLE_HOS)

/datum/gear/neck/mantle/job/head_of_personnel
	display_name = "mantle, head of personnel"
	path = /obj/item/clothing/neck/mantle/head_of_personnel
	allowed_roles = list(JOB_TITLE_HOP)

/datum/gear/neck/mantle/job/research_director
	display_name = "mantle, research director"
	path = /obj/item/clothing/neck/mantle/research_director
	allowed_roles = list(JOB_TITLE_RD)

//Cloaks
/datum/gear/neck/cloak
	display_name = "cloak, color"
	path = /obj/item/clothing/neck/cloak/grey

/datum/gear/neck/cloak/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)

/datum/gear/neck/cloak/job
	subtype_path = /datum/gear/neck/cloak/job
	subtype_cost_overlap = FALSE

/datum/gear/neck/cloak/job/healer
	display_name = "cloak, healer"
	path = /obj/item/clothing/neck/cloak/healer
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_PARAMEDIC, JOB_TITLE_BRIGDOC)

/datum/gear/neck/cloak/job/captain
	display_name = "cloak, captain"
	path = /obj/item/clothing/neck/cloak/captain
	allowed_roles = list(JOB_TITLE_CAPTAIN)

/datum/gear/neck/cloak/job/nanotrasen_representative
	display_name = "cloak, nanotrasen representative"
	path = /obj/item/clothing/neck/cloak/nanotrasen_representative
	allowed_roles = list(JOB_TITLE_REPRESENTATIVE)

/datum/gear/neck/cloak/job/blueshield
	display_name = "cloak, blueshield"
	path = /obj/item/clothing/neck/cloak/blueshield
	allowed_roles = list(JOB_TITLE_BLUESHIELD)

/datum/gear/neck/cloak/job/chief_engineer
	display_name = "cloak, chief engineer"
	path = /obj/item/clothing/neck/cloak/chief_engineer
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/neck/cloak/job/chief_engineer/white
	display_name = "cloak, chief engineer, white"
	path = /obj/item/clothing/neck/cloak/chief_engineer/white
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/neck/cloak/job/chief_medical_officer
	display_name = "cloak, chief medical officer"
	path = /obj/item/clothing/neck/cloak/chief_medical_officer
	allowed_roles = list(JOB_TITLE_CMO)

/datum/gear/neck/cloak/job/head_of_security
	display_name = "cloak, head of security"
	path = /obj/item/clothing/neck/cloak/head_of_security
	allowed_roles = list(JOB_TITLE_HOS)

/datum/gear/neck/cloaksecurity
	display_name = "cloak, security officer"
	path = /obj/item/clothing/neck/cloak/security
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_PILOT)

/datum/gear/neck/cloak/job/head_of_personnel
	display_name = "cloak, head of personnel"
	path = /obj/item/clothing/neck/cloak/head_of_personnel
	allowed_roles = list(JOB_TITLE_HOP)

/datum/gear/neck/cloak/job/research_director
	display_name = "cloak, research director"
	path = /obj/item/clothing/neck/cloak/research_director
	allowed_roles = list(JOB_TITLE_RD)

/datum/gear/neck/cloak/job/quartermaster
	display_name = "cloak, quartermaster"
	path = /obj/item/clothing/neck/cloak/quartermaster
	allowed_roles = list(JOB_TITLE_QUARTERMASTER)

//Ponchos
/datum/gear/neck/poncho
	display_name = "poncho, select"
	path = /obj/item/clothing/neck/poncho

/datum/gear/neck/poncho/New()
	. = ..()
	var/list/ponchos = list(/obj/item/clothing/neck/poncho,
							/obj/item/clothing/neck/poncho/red,
							/obj/item/clothing/neck/poncho/orange,
							/obj/item/clothing/neck/poncho/yellow,
							/obj/item/clothing/neck/poncho/green,
							/obj/item/clothing/neck/poncho/blue,
							/obj/item/clothing/neck/poncho/purple,
							/obj/item/clothing/neck/poncho/white,
							/obj/item/clothing/neck/poncho/black,
							/obj/item/clothing/neck/poncho/mime,
							/obj/item/clothing/neck/poncho/rainbow,)
	gear_tweaks += new /datum/gear_tweak/path(ponchos, src, TRUE)

/datum/gear/neck/poncho/security
	display_name = "poncho, corporate"
	path = /obj/item/clothing/neck/poncho/security
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_PILOT)

