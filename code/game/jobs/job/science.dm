/datum/job/head_of_staff/rd
	title = JOB_TITLE_RD
	flag = JOB_FLAG_RD
	department = STATION_DEPARTMENT_SCIENCE
	department_flag = JOBCAT_MEDSCI
	is_science = 1
	selection_color = "#aa66cc"
	access = list(ACCESS_EVA, ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
					ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
					ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
					ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_NETWORK, ACCESS_MECHANIC)
	minimal_access = list(ACCESS_EVA, ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
					ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
					ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
					ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_NETWORK, ACCESS_MECHANIC)
	exp_type = EXP_TYPE_SCIENCE
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research,
	)
	outfit = /datum/outfit/job/rd

/datum/outfit/job/rd
	name = JOB_TITLE_RD
	jobtype = /datum/job/head_of_staff/rd

	uniform = /obj/item/clothing/under/rank/research_director
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/color/brown
	l_ear = /obj/item/radio/headset/heads/rd
	id = /obj/item/card/id/rd
	l_pocket = /obj/item/lighter/zippo/rd
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/heads/rd
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
	)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/science

/datum/job/science
	department = STATION_DEPARTMENT_SCIENCE
	department_flag = JOBCAT_MEDSCI
	is_science = 1
	supervisors = "Научным руководителем"
	department_head = list(JOB_TITLE_RD)
	selection_color = "#e6d1f0"
	minimal_player_age = 3
	exp_requirements = 600
	exp_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_CREW
	// All science guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research,
	)

/datum/job/science/scientist
	title = JOB_TITLE_SCIENTIST
	flag = JOB_FLAG_SCIENTIST
	total_positions = 6
	spawn_positions = 6
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Anomalist", "Plasma Researcher", "Xenobiologist", "Chemical Researcher")
	outfit = /datum/outfit/job/scientist

/datum/outfit/job/scientist
	name = JOB_TITLE_SCIENTIST
	jobtype = /datum/job/science/scientist

	uniform = /obj/item/clothing/under/rank/scientist
	suit = /obj/item/clothing/suit/storage/labcoat/science
	shoes = /obj/item/clothing/shoes/color/white
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/research
	pda = /obj/item/pda/toxins

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/science

/datum/job/science/scientist/student
	title = JOB_TITLE_SCIENTIST_STUDENT
	flag = JOB_FLAG_SCIENTIST_STUDENT
	total_positions = 5
	spawn_positions = 3
	department_head = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST)
	alt_titles = list("Scientist Assistant", "Scientist Pregraduate", "Scientist Graduate", "Scientist Postgraduate", "Student Robotist")
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_max	= 600
	exp_type_max = EXP_TYPE_SCIENCE
	is_novice = TRUE
	outfit = /datum/outfit/job/scientist/student
	paycheck = PAYCHECK_LOWER

/datum/outfit/job/scientist/student
	name = JOB_TITLE_SCIENTIST_STUDENT
	jobtype = /datum/job/science/scientist/student

	uniform = /obj/item/clothing/under/rank/scientist/student
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

/datum/job/science/roboticist
	title = JOB_TITLE_ROBOTICIST
	flag = JOB_FLAG_ROBOTICIST
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer", "Mechatronic Engineer")
	outfit = /datum/outfit/job/roboticist

/datum/outfit/job/roboticist
	name = JOB_TITLE_ROBOTICIST
	jobtype = /datum/job/science/roboticist

	uniform = /obj/item/clothing/under/rank/roboticist
	suit = /obj/item/clothing/suit/storage/labcoat
	belt = /obj/item/storage/belt/utility/full
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/research
	pda = /obj/item/pda/roboticist
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic

/datum/job/science/mechanic
	title = JOB_TITLE_MECHANIC
	flag = JOB_FLAG_MECHANIC
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_RESEARCH, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECHANIC, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MINERAL_STOREROOM, ACCESS_EMERGENCY_STORAGE)
	minimal_access = list(ACCESS_RESEARCH, ACCESS_MAINT_TUNNELS, ACCESS_EMERGENCY_STORAGE, ACCESS_MECHANIC, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MINERAL_STOREROOM)
	outfit = /datum/outfit/job/mechanic

/datum/outfit/job/mechanic
	name = JOB_TITLE_MECHANIC
	jobtype = /datum/job/science/mechanic
	uniform = /obj/item/clothing/under/rank/mechanic
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/research
	r_pocket = /obj/item/t_scanner
	pda = /obj/item/pda/toxins
	backpack_contents = list(
		/obj/item/pod_paint_bucket = 1,
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/survival/engineer
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/meson
