/datum/job/civilian
	title = "Civilian"
	flag = JOB_CIVILIAN
	department_flag = JOBCAT_SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Tourist","Businessman","Trader","Assistant")
	outfit = /datum/outfit/job/assistant

/datum/job/civilian/get_access()
	if(config.assistant_maint)
		return list(ACCESS_MAINT_TUNNELS)
	else
		return list()

/datum/outfit/job/assistant
	name = "Civilian"
	jobtype = /datum/job/civilian

	uniform = /obj/item/clothing/under/color/random
	l_pocket = /obj/item/paper/deltainfo
	shoes = /obj/item/clothing/shoes/black

/datum/job/prisoner
	title = "Prisoner"
	flag = JOB_PRISONER
	department_flag = JOBCAT_SUPPORT
	total_positions = 0
	spawn_positions = 2
	supervisors = "Warden"
	department_head = list("Head of Security", "Warden", "Security Officer")
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/prisoner

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	uniform = /obj/item/clothing/under/color/orange
	shoes = /obj/item/clothing/shoes/orange
	id = /obj/item/card/id/prisoner
