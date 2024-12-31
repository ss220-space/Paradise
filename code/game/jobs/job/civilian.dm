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
	access = list(ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MAINT_TUNNELS)
	alt_titles = list("Tourist","Businessman","Trader","Assistant")
	outfit = /datum/outfit/job/assistant
	insurance_type = INSURANCE_TYPE_BUDGETARY

	salary = SALARY_FOR_NISHEBROD
	min_start_money = 10
	max_start_money = 200


/datum/outfit/job/assistant
	name = "Civilian"
	jobtype = /datum/job/civilian

	uniform = /obj/item/clothing/under/color/random
	l_pocket = /obj/item/paper/deltainfo
	shoes = /obj/item/clothing/shoes/black

#undef SALARY_FOR_NISHEBROD
