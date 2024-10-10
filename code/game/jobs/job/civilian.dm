#define SALARY_FOR_NISHEBROD 60

/datum/job/civilian
	title = JOB_TITLE_CIVILIAN
	flag = JOB_FLAG_CIVILIAN
	department_flag = JOBCAT_SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "the head of personnel"
	department_head = list(JOB_TITLE_HOP)
	selection_color = "#e6e6e6"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Tourist","Businessman","Trader","Assistant")
	outfit = /datum/outfit/job/assistant

	salary = SALARY_FOR_NISHEBROD
	min_start_money = 10
	max_start_money = 200

/datum/job/civilian/get_access()
	if(CONFIG_GET(flag/assistant_maint))
		return list(ACCESS_MAINT_TUNNELS)
	else
		return list()

/datum/outfit/job/assistant
	name = "Civilian"
	jobtype = /datum/job/civilian

	uniform = /obj/item/clothing/under/color/random
	l_pocket = /obj/item/paper/deltainfo
	shoes = /obj/item/clothing/shoes/black

#undef SALARY_FOR_NISHEBROD
