/datum/gear/implant
	subtype_path = /datum/gear/implant
	slot = null
	sort_category = "Implants"
	implantable = TRUE

/datum/gear/implant/

//Eye implants

/datum/gear/implant/meson
	display_name = "Meson Scanner Implant"
	path = /obj/item/organ/internal/cyberimp/eyes/meson
	allowed_roles = list("Chief Engineer","Life Support Specialist", "Station Engineer", "Quartermaster", "Shaft Miner")

/datum/gear/implant/security
	display_name = "Security Hud Implant"
	cost = 3
	path = /obj/item/organ/internal/cyberimp/eyes/hud/security
	allowed_roles = list("Security Officer", "Security Pod Pilot", "Detective", "Warden", "Head of Security", "Magistrate")

/datum/gear/implant/medical
	display_name = "Medical Hud Implant"
	path = /obj/item/organ/internal/cyberimp/eyes/hud/medical
	allowed_roles = list("Chief Medical Officer", "Chemist", "Medical Doctor", "Paramedic", "Brig Physician", "Virologist")

/datum/gear/implant/science
	display_name = "Diagnostical Hud Implant"
	path = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	allowed_roles = list("Research Director", "Roboticist")
