/datum/gear/implant
	subtype_path = /datum/gear/implant
	slot = null
	sort_category = "Импланты"
	implantable = TRUE

/datum/gear/implant/

//Eye implants

/datum/gear/implant/meson
	index_name = "Meson Scanner Implant"
	cost = 3
	path = /obj/item/organ/internal/cyberimp/eyes/meson
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH, JOB_TITLE_ENGINEER, JOB_TITLE_QUARTERMASTER, JOB_TITLE_MINER, JOB_TITLE_MINING_MEDIC)

/datum/gear/implant/security
	index_name = "Security Hud Implant"
	cost = 3
	path = /obj/item/organ/internal/cyberimp/eyes/hud/security
	allowed_roles = list(JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_DETECTIVE, JOB_TITLE_WARDEN, JOB_TITLE_HOS, JOB_TITLE_JUDGE, JOB_TITLE_BRIGDOC)

/datum/gear/implant/medical
	index_name = "Medical Hud Implant"
	cost = 3
	path = /obj/item/organ/internal/cyberimp/eyes/hud/medical
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_CHEMIST, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_PARAMEDIC, JOB_TITLE_BRIGDOC, JOB_TITLE_VIROLOGIST, JOB_TITLE_GENETICIST, JOB_TITLE_CORONER)

/datum/gear/implant/diagnostic
	index_name = "Diagnostical Hud Implant"
	cost = 3
	path = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_ROBOTICIST)

/datum/gear/implant/science
	index_name = "Science Hud Implant"
	cost = 3
	path = /obj/item/organ/internal/cyberimp/eyes/hud/science
	allowed_roles = list(JOB_TITLE_CHEMIST, JOB_TITLE_SCIENTIST, JOB_TITLE_RD, JOB_TITLE_GENETICIST, JOB_TITLE_VIROLOGIST)

/datum/gear/implant/universal
	index_name = "Universal Eye Implant"
	display_name = "Универсальный ИЛС имплант"
	cost = 3
	path = /obj/item/organ/internal/cyberimp/eyes/hud/universal

/datum/gear/implant/universal/get_spawn_path(job_name, metadata)

	switch(job_name)

		if(JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_HOS, JOB_TITLE_DETECTIVE, JOB_TITLE_PILOT, JOB_TITLE_JUDGE, JOB_TITLE_LAWYER, JOB_TITLE_CAPTAIN)
			return /obj/item/organ/internal/cyberimp/eyes/hud/security

		if(JOB_TITLE_DOCTOR, JOB_TITLE_CMO, JOB_TITLE_PARAMEDIC, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_VIROLOGIST, JOB_TITLE_GENETICIST, JOB_TITLE_CORONER, JOB_TITLE_INTERN, JOB_TITLE_MINING_MEDIC,  JOB_TITLE_BRIGDOC, JOB_TITLE_BLUESHIELD)
			return /obj/item/organ/internal/cyberimp/eyes/hud/medical

		if(JOB_TITLE_ENGINEER, JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_MINER, JOB_TITLE_CARGOTECH, JOB_TITLE_QUARTERMASTER)
			return /obj/item/organ/internal/cyberimp/eyes/meson

		if(JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_RD, JOB_TITLE_CHEMIST)
			return /obj/item/organ/internal/cyberimp/eyes/hud/science

		if(JOB_TITLE_ROBOTICIST)
			return /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic

	return null
