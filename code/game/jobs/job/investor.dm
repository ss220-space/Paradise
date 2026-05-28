/datum/outfit/job/investor
	name = JOB_TITLE_RU_INVESTOR
	jobtype = /datum/job/investor
	allow_backbag_choice = FALSE

	uniform = /obj/item/clothing/under/suit_jacket/really_black
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/investor
	l_ear = /obj/item/radio/headset/headset_com
	back = /obj/item/storage/backpack/satcheldeluxe

/datum/job/investor
	title = JOB_TITLE_INVESTOR
	flag = JOB_FLAG_INVESTOR
	department_flag = JOBCAT_SUPPORT
	department = STATION_DEPARTMENT_CIVILIAN
	department_head = list(JOB_TITLE_CAPTAIN)
	total_positions = JOB_UNLIMITED_POSITION
	spawn_positions = JOB_UNLIMITED_POSITION
	supervisors = "Капитаном"
	selection_color = "#e6e6e6"
	transfer_allowed = FALSE
	access = list(ACCESS_HEADS, ACCESS_ALL_PERSONAL_LOCKERS)
	minimal_access = list(ACCESS_HEADS, ACCESS_ALL_PERSONAL_LOCKERS)
	outfit = /datum/outfit/job/investor
	insurance_type = INSURANCE_TYPE_DELUXE
	paycheck = PAYCHECK_MAX

/datum/job/investor/check_custom_requirements(client/target)
	. = ..()
	if(!.)
		return FALSE

	if(!target?.persistent_client?.achievements)
		return FALSE

	var/datum/achievement_data/achievements = target.persistent_client.achievements
	var/achievement_status = achievements.get_achievement_status(/datum/award/achievement/donations/project_pillar)

	if(!achievement_status)
		return FALSE

	return achievement_status
