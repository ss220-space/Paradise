/datum/job/civilian/team1
	title = JOB_TITLE_TEAM1
	flag = JOB_FLAG_TEAM1
	department_flag = JOBCAT_COMBAT_TEAM
	selection_color = "#09ff00"
	alt_titles = list()
	total_positions = 0
	spawn_positions = 0
	outfit = /datum/outfit/job/team/team1
	insurance_type = INSURANCE_TYPE_NONE
	announce_job = FALSE
	hidden_from_job_prefs = TRUE
	admin_only = TRUE
	skill_levels = list(
		/datum/skill/general/carrying = SKILL_LEVEL_BASIC,
		/datum/skill/general/mech_drive = SKILL_LEVEL_BASIC,
		/datum/skill/general/mod_use = SKILL_LEVEL_BASIC,
		/datum/skill/combat/guns = SKILL_LEVEL_BASIC,
		/datum/skill/combat/melee = SKILL_LEVEL_BASIC,
		/datum/skill/medical/heal = SKILL_LEVEL_BASIC,
	)

/datum/job/civilian/team1/get_access()
	return get_all_accesses()

/datum/outfit/job/team
	l_hand = /obj/item/crowbar/red
	allow_loadout = FALSE
	allow_backbag_choice = FALSE
	id = /obj/item/card/id/syndicate/anyone
	pda = null
	box = null
	implants = list(/obj/item/implant/mindshield/ert, /obj/item/implant/death_alarm)

/datum/outfit/job/team/team1
	name = JOB_TITLE_RU_TEAM1
	jobtype = /datum/job/civilian/team1

	uniform = /obj/item/clothing/under/color/green
	shoes = /obj/item/clothing/shoes/color/green
	l_ear = /obj/item/radio/headset/green

/datum/job/civilian/team2
	title = JOB_TITLE_TEAM2
	flag = JOB_FLAG_TEAM2
	department_flag = JOBCAT_COMBAT_TEAM
	selection_color = "#1100ff"
	alt_titles = list()
	total_positions = 0
	spawn_positions = 0
	outfit = /datum/outfit/job/team/team2
	insurance_type = INSURANCE_TYPE_NONE
	announce_job = FALSE
	hidden_from_job_prefs = TRUE
	admin_only = TRUE
	skill_levels = list(
		/datum/skill/general/carrying = SKILL_LEVEL_BASIC,
		/datum/skill/general/mech_drive = SKILL_LEVEL_BASIC,
		/datum/skill/general/mod_use = SKILL_LEVEL_BASIC,
		/datum/skill/combat/guns = SKILL_LEVEL_BASIC,
		/datum/skill/combat/melee = SKILL_LEVEL_BASIC,
		/datum/skill/medical/heal = SKILL_LEVEL_BASIC,
	)

/datum/job/civilian/team2/get_access()
	return get_all_accesses()

/datum/outfit/job/team/team2
	name = JOB_TITLE_RU_TEAM2
	jobtype = /datum/job/civilian/team2

	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/color/blue
	l_ear = /obj/item/radio/headset/blue

/datum/job/civilian/team3
	title = JOB_TITLE_TEAM3
	flag = JOB_FLAG_TEAM3
	department_flag = JOBCAT_COMBAT_TEAM
	selection_color = "#ff0000"
	alt_titles = list()
	total_positions = 0
	spawn_positions = 0
	outfit = /datum/outfit/job/team/team3
	insurance_type = INSURANCE_TYPE_NONE
	announce_job = FALSE
	hidden_from_job_prefs = TRUE
	admin_only = TRUE
	skill_levels = list(
		/datum/skill/combat/guns = SKILL_LEVEL_ADVANCED,
		/datum/skill/combat/melee = SKILL_LEVEL_ADVANCED,
		/datum/skill/combat/bows = SKILL_LEVEL_ADVANCED,
		/datum/skill/engineering/building = SKILL_LEVEL_ADVANCED,
		/datum/skill/engineering/electrician = SKILL_LEVEL_ADVANCED,
		/datum/skill/engineering/atmos = SKILL_LEVEL_ADVANCED,
		/datum/skill/general/carrying = SKILL_LEVEL_ADVANCED,
		/datum/skill/general/mech_drive = SKILL_LEVEL_ADVANCED,
		/datum/skill/general/mod_use = SKILL_LEVEL_ADVANCED,
		/datum/skill/general/mixing = SKILL_LEVEL_ADVANCED,
		/datum/skill/general/cooking = SKILL_LEVEL_ADVANCED,
		/datum/skill/medical/heal = SKILL_LEVEL_ADVANCED,
		/datum/skill/medical/genetic = SKILL_LEVEL_ADVANCED,
		/datum/skill/medical/virusology = SKILL_LEVEL_ADVANCED,
		/datum/skill/research/research = SKILL_LEVEL_ADVANCED,
		/datum/skill/research/mech_construct = SKILL_LEVEL_ADVANCED,
		/datum/skill/research/xenobiology = SKILL_LEVEL_ADVANCED,
		/datum/skill/service/botany = SKILL_LEVEL_ADVANCED,
		/datum/skill/service/cleaning = SKILL_LEVEL_ADVANCED,
		/datum/skill/service/mining = SKILL_LEVEL_ADVANCED,
	)

/datum/job/civilian/team3/get_access()
	return get_all_accesses()

/datum/outfit/job/team/team3
	name = JOB_TITLE_RU_TEAM3
	jobtype = /datum/job/civilian/team3

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/color/red
	l_ear = /obj/item/radio/headset/red
