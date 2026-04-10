/datum/outfit/job/investor
	name = JOB_TITLE_RU_INVESTOR
	jobtype = /datum/job/investor
	allow_backbag_choice = FALSE

	uniform = /obj/item/clothing/under/suit_jacket/really_black
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/investor
	l_ear = /obj/item/radio/headset/headset_com
	pda = /obj/item/pda
	back = /obj/item/storage/backpack/satcheldeluxe

/datum/job/investor
	title = JOB_TITLE_INVESTOR
	flag = JOB_FLAG_INVESTOR
	department_flag = JOBCAT_SUPPORT
	department = STATION_DEPARTMENT_CIVILIAN
	total_positions = -1
	spawn_positions = -1
	supervisors = "Капитаном"
	selection_color = "#e6e6e6"
	access = list(ACCESS_HEADS, ACCESS_ALL_PERSONAL_LOCKERS)
	minimal_access = list(ACCESS_HEADS, ACCESS_ALL_PERSONAL_LOCKERS)
	outfit = /datum/outfit/job/investor
	insurance_type = INSURANCE_TYPE_DELUXE

/datum/job/investor/check_custom_requirements(client/C)
	. = ..()
	if(!.)
		return FALSE

	if(!C)
		return FALSE

	if(!C.persistent_client)
		return FALSE

	if(!C.persistent_client.achievements)
		return FALSE

	var/datum/achievement_data/achievements = C.persistent_client.achievements
	var/achievement_status = achievements.get_achievement_status(/datum/award/achievement/donations/project_pillar)

	if(!achievement_status)
		return FALSE

	return TRUE
