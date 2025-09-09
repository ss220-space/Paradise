/datum/job/civilian/team1
	title = JOB_TITLE_TEAM1
	flag = JOB_FLAG_TEAM1
	department_flag = JOBCAT_COMBAT_TEAM
	selection_color = "#09ff00"
	alt_titles = list()
	total_positions = 0
	spawn_positions = 0
	outfit = /datum/outfit/job/assistant/team1
	insurance_type = INSURANCE_TYPE_NONE
	min_start_money = 0
	max_start_money = 10
	announce_job = FALSE
	hidden_from_job_prefs = TRUE
	admin_only = TRUE

/datum/job/civilian/team1/get_access()
	return get_all_accesses()

/datum/outfit/job/assistant/team1
	name = "Команда 1"
	jobtype = /datum/job/civilian/team1

	uniform = /obj/item/clothing/under/color/green
	shoes = /obj/item/clothing/shoes/green
	l_hand = /obj/item/crowbar/red
	id = /obj/item/card/id/syndicate/anyone
	l_ear = /obj/item/radio/headset/green
	implants = list(/obj/item/implant/mindshield/ert)

/datum/job/civilian/team2
	title = JOB_TITLE_TEAM2
	flag = JOB_FLAG_TEAM2
	department_flag = JOBCAT_COMBAT_TEAM
	selection_color = "#1100ff"
	alt_titles = list()
	total_positions = 0
	spawn_positions = 0
	outfit = /datum/outfit/job/assistant/team2
	insurance_type = INSURANCE_TYPE_NONE
	min_start_money = 0
	max_start_money = 10
	announce_job = FALSE
	hidden_from_job_prefs = TRUE
	admin_only = TRUE

/datum/job/civilian/team2/get_access()
	return get_all_accesses()

/datum/outfit/job/assistant/team2
	name = "Команда 2"
	jobtype = /datum/job/civilian/team2

	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/blue
	l_hand = /obj/item/crowbar/red
	id = /obj/item/card/id/syndicate/anyone
	l_ear = /obj/item/radio/headset/blue
	implants = list(/obj/item/implant/mindshield/ert)

/datum/job/civilian/team3
	title = JOB_TITLE_TEAM3
	flag = JOB_FLAG_TEAM3
	department_flag = JOBCAT_COMBAT_TEAM
	selection_color = "#ff0000"
	alt_titles = list()
	total_positions = 0
	spawn_positions = 0
	outfit = /datum/outfit/job/assistant/team3
	insurance_type = INSURANCE_TYPE_NONE
	min_start_money = 0
	max_start_money = 10
	announce_job = FALSE
	hidden_from_job_prefs = TRUE
	admin_only = TRUE

/datum/job/civilian/team3/get_access()
	return get_all_accesses()

/datum/outfit/job/assistant/team3
	name = "Команда 3"
	jobtype = /datum/job/civilian/team3

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/red
	l_hand = /obj/item/crowbar/red
	id = /obj/item/card/id/syndicate/anyone
	l_ear = /obj/item/radio/headset/red
	implants = list(/obj/item/implant/mindshield/ert)
