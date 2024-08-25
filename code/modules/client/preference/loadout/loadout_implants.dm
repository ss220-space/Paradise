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
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH, JOB_TITLE_ENGINEER, JOB_TITLE_QUARTERMASTER, JOB_TITLE_MINER)

/datum/gear/implant/security
	display_name = "Security Hud Implant"
	cost = 3
	path = /obj/item/organ/internal/cyberimp/eyes/hud/security
	allowed_roles = list(JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_DETECTIVE, JOB_TITLE_WARDEN, JOB_TITLE_HOS, JOB_TITLE_JUDGE)

/datum/gear/implant/medical
	display_name = "Medical Hud Implant"
	path = /obj/item/organ/internal/cyberimp/eyes/hud/medical
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_CHEMIST, JOB_TITLE_DOCTOR, JOB_TITLE_PARAMEDIC, JOB_TITLE_BRIGDOC, JOB_TITLE_VIROLOGIST)

/datum/gear/implant/diagnostic
	display_name = "Diagnostical Hud Implant"
	path = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_ROBOTICIST)

/datum/gear/implant/science
	display_name = "Science Hud Implant"
	path = /obj/item/organ/internal/cyberimp/eyes/hud/science
	allowed_roles = list(JOB_TITLE_CHEMIST, JOB_TITLE_SCIENTIST, JOB_TITLE_RD, JOB_TITLE_GENETICIST)
