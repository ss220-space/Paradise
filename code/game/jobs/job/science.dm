/datum/job/rd
	title = JOB_TITLE_RD
	flag = JOB_FLAG_RD
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_science = 1
	supervisors = "the captain"
	department_head = list(JOB_TITLE_CAPTAIN)
	selection_color = "#aa66cc"
	req_admin_notify = 1
	access = list(ACCESS_EVA, ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
					ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
					ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
					ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_NETWORK)
	minimal_access = list(ACCESS_EVA, ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
					ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
					ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
					ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_NETWORK)
	minimal_player_age = 21
	min_age_allowed = 30
	exp_requirements = 3000
	exp_type = EXP_TYPE_SCIENCE
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research
	)
	outfit = /datum/outfit/job/rd
	insurance_type = INSURANCE_TYPE_DELUXE

	salary = 300
	min_start_money = 400
	max_start_money = 700


/datum/outfit/job/rd
	name = "Research Director"
	jobtype = /datum/job/rd

	uniform = /obj/item/clothing/under/rank/research_director
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/heads/rd
	id = /obj/item/card/id/rd
	l_pocket = /obj/item/lighter/zippo/rd
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/heads/rd
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science


/datum/job/scientist
	title = JOB_TITLE_SCIENTIST
	flag = JOB_FLAG_SCIENTIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 6
	spawn_positions = 6
	is_science = 1
	supervisors = "the research director"
	department_head = list(JOB_TITLE_RD)
	selection_color = "#e6d1f0"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Anomalist", "Plasma Researcher", "Xenobiologist", "Chemical Researcher")
	minimal_player_age = 3
	exp_requirements = 600
	exp_type = EXP_TYPE_SCIENCE
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research
	)
	outfit = /datum/outfit/job/scientist

	salary = 200
	min_start_money = 250
	max_start_money = 500

/datum/outfit/job/scientist
	name = "Scientist"
	jobtype = /datum/job/scientist

	uniform = /obj/item/clothing/under/rank/scientist
	suit = /obj/item/clothing/suit/storage/labcoat/science
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/research
	pda = /obj/item/pda/toxins

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science


/datum/job/scientist/student
	title = JOB_TITLE_SCIENTIST_STUDENT
	flag = JOB_FLAG_SCIENTIST_STUDENT
	total_positions = 5
	spawn_positions = 3
	department_head = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST)
	selection_color = "#e6d1f0"
	alt_titles = list("Scientist Assistant", "Scientist Pregraduate", "Scientist Graduate", "Scientist Postgraduate", "Student Robotist")
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_max	= 600
	exp_type_max = EXP_TYPE_SCIENCE
	is_novice = TRUE
	outfit = /datum/outfit/job/scientist/student

	salary = 200
	min_start_money = 250
	max_start_money = 500

/datum/outfit/job/scientist/student
	name = "Student Scientist"
	jobtype = /datum/job/scientist/student

	uniform = /obj/item/clothing/under/rank/scientist/student
	l_pocket = /obj/item/paper/deltainfo
	id = /obj/item/card/id/research/student

/datum/outfit/job/scientist/student/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/scientist/student/skirt
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Scientist Assistant")
				uniform = /obj/item/clothing/under/rank/scientist/student/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/scientist/student/assistant/skirt
			if("Student Robotist")
				suit = /obj/item/clothing/suit/storage/labcoat
				uniform = /obj/item/clothing/under/rank/roboticist/student
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/roboticist/skirt/student

/datum/job/roboticist
	title = JOB_TITLE_ROBOTICIST
	flag = JOB_FLAG_ROBOTICIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	is_science = 1
	supervisors = "the research director"
	department_head = list(JOB_TITLE_RD)
	selection_color = "#e6d1f0"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_age = 3
	exp_requirements = 900
	exp_type = EXP_TYPE_SCIENCE
	outfit = /datum/outfit/job/roboticist

	salary = 200
	min_start_money = 250
	max_start_money = 500

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	uniform = /obj/item/clothing/under/rank/roboticist
	suit = /obj/item/clothing/suit/storage/labcoat
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/research
	pda = /obj/item/pda/roboticist
