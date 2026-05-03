/datum/job/civilian
	title = JOB_TITLE_CIVILIAN
	flag = JOB_FLAG_CIVILIAN
	department_flag = JOBCAT_SUPPORT
	department = STATION_DEPARTMENT_CIVILIAN
	total_positions = JOB_UNLIMITED_POSITION
	spawn_positions = JOB_UNLIMITED_POSITION
	supervisors = "Главой персонала"
	department_head = list(JOB_TITLE_HOP)
	selection_color = "#e6e6e6"
	access = list()
	minimal_access = list()
	alt_titles = list(
		ALT_JOB_TITLE_RU_TOURIST,
		ALT_JOB_TITLE_RU_ASSISTANT,
		ALT_JOB_TITLE_RU_WORKER,
		ALT_JOB_TITLE_RU_GENERAL_INTERN,
	)
	outfit = /datum/outfit/job/assistant
	insurance_type = INSURANCE_TYPE_BUDGETARY
	paycheck = PAYCHECK_MIN

/datum/outfit/job/assistant
	name = JOB_TITLE_RU_CIVILIAN
	jobtype = /datum/job/civilian

	uniform = /obj/item/clothing/under/color/random

/datum/job/civilian/prisoner
	title = JOB_TITLE_PRISONER
	flag = JOB_FLAG_PRISONER
	total_positions = ROLE_PRISONERS_MAX_COUNT
	spawn_positions = ROLE_PRISONERS_MAX_COUNT
	supervisors = "составом службы безопасности"
	department_head = list(JOB_TITLE_WARDEN)
	access = list()
	minimal_access = list()
	alt_titles = list(
		ALT_JOB_TITLE_RU_ARRESTEE,
		ALT_JOB_TITLE_RU_CONVICT,
	)
	outfit = /datum/outfit/job/assistant/prisoner
	insurance_type = INSURANCE_TYPE_NONE

/datum/job/civilian/prisoner/after_spawn(mob/living/carbon/human/human)
	. = ..()
	var/datum/data/record/record = find_security_record("name", human.real_name)
	if(!record) //record not exists, create record with temporary identifier
		record = CreateSecurityRecord(human.real_name, -1)
	record.fields["criminal"] = SEC_RECORD_STATUS_INCARCERATED
	record.fields["last_modifier_level"] = LAW_LEVEL_MAGISTRATE
	var/crimes = generate_prisoner_role_crimes()
	human.mind.store_memory("Меня посадили за: [crimes]")
	record.fields["comments"] += "Заключен[GEND_A_O_Y(human)] в пермабриг за: [crimes]"

/datum/job/civilian/prisoner/proc/generate_prisoner_role_crimes()
	var/list/major_crimes = list("400", "402", "407")
	. = pick(major_crimes)
	var/count = rand(1, 3)
	var/list/minor_crimes = list("101", "303", "204", "205", "306", "308")
	for(var/i = 0; i < count; i++)
		var/crime = pick(minor_crimes)
		minor_crimes -= crime
		. += ", [crime]"
	. += "."

/datum/outfit/job/assistant/prisoner
	name = JOB_TITLE_RU_PRISONER
	allow_loadout = FALSE
	jobtype = /datum/job/civilian/prisoner
	id = /obj/item/card/id/prisoner/random
	head = /obj/item/clothing/head/prison
	uniform = /obj/item/clothing/under/prison
	shoes = /obj/item/clothing/shoes/prison
	l_ear = /obj/item/radio/headset/prisoner
	pda = null
	box = null
	allow_backbag_choice = FALSE
	back = null
