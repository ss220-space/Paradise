/datum/job/head_of_staff/cmo
	title = JOB_TITLE_CMO
	flag = JOB_FLAG_CMO
	department = STATION_DEPARTMENT_MEDICAL
	department_flag = JOBCAT_MEDSCI
	is_medical = 1
	selection_color = "#66c6ff"
	access = list(ACCESS_EVA, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_PSYCHIATRIST, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_PARAMEDIC, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_EVA, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_PSYCHIATRIST, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_PARAMEDIC, ACCESS_MINERAL_STOREROOM)
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/cmo

/datum/outfit/job/cmo
	name = JOB_TITLE_CMO
	jobtype = /datum/job/head_of_staff/cmo

	uniform = /obj/item/clothing/under/rank/chief_medical_officer
	suit = /obj/item/clothing/suit/storage/labcoat/cmo
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/heads/cmo
	id = /obj/item/card/id/cmo
	l_pocket = /obj/item/lighter/zippo/cmo
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/doctor
	pda = /obj/item/pda/heads/cmo
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/job/medical
	department = STATION_DEPARTMENT_MEDICAL
	department_flag = JOBCAT_MEDSCI
	is_medical = 1
	supervisors = "Главным врачом"
	department_head = list(JOB_TITLE_CMO)
	selection_color = "#d1eeff"
	minimal_player_age = 3
	exp_requirements = 600
	exp_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_CREW

/datum/job/medical/doctor
	title = JOB_TITLE_DOCTOR
	flag = JOB_FLAG_DOCTOR
	total_positions = 5
	spawn_positions = 3
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Surgeon", "Nurse")
	outfit = /datum/outfit/job/doctor

/datum/outfit/job/doctor
	name = JOB_TITLE_DOCTOR
	jobtype = /datum/job/medical/doctor

	uniform = /obj/item/clothing/under/rank/medical
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/doctor
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/outfit/job/doctor/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(!H.mind || !H.mind.role_alt_title)
		return
	switch(H.mind.role_alt_title)
		if(JOB_TITLE_DOCTOR)
			uniform = /obj/item/clothing/under/rank/medical
		if("Surgeon")
			uniform = /obj/item/clothing/under/rank/medical/blue
			head = /obj/item/clothing/head/surgery/blue
		if("Nurse")
			if(!H.gender == FEMALE)
				uniform = /obj/item/clothing/under/rank/medical/purple
				return
			if(prob(50))
				uniform = /obj/item/clothing/under/rank/nursesuit
			else
				uniform = /obj/item/clothing/under/rank/nurse
			head = /obj/item/clothing/head/nursehat

/datum/job/medical/doctor/intern
	title = JOB_TITLE_INTERN
	flag = JOB_FLAG_INTERN
	alt_titles = list("Student Medical Doctor", "Medical Assistant")
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_max	= 600
	exp_type_max = EXP_TYPE_MEDICAL
	is_novice = TRUE
	outfit = /datum/outfit/job/doctor/intern
	paycheck = PAYCHECK_LOWER

/datum/outfit/job/doctor/intern
	name = JOB_TITLE_INTERN
	jobtype = /datum/job/medical/doctor/intern

	uniform = /obj/item/clothing/under/rank/medical/intern
	id = /obj/item/card/id/medical/intern
	l_hand = /obj/item/storage/firstaid/o2
	backpack_contents = list(
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/clothing/gloves/color/latex = 1,
	)

/datum/outfit/job/doctor/intern/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/medical/intern/skirt
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Medical Assistant")
				uniform = /obj/item/clothing/under/rank/medical/intern/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/medical/intern/assistant/skirt
			if("Student Medical Doctor")
				head = /obj/item/clothing/head/surgery/lightgreen
				uniform = /obj/item/clothing/under/rank/medical/lightgreen

/datum/job/medical/coroner
	title = JOB_TITLE_CORONER
	flag = JOB_FLAG_CORONER
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	outfit = /datum/outfit/job/coroner

/datum/outfit/job/coroner
	name = JOB_TITLE_CORONER
	jobtype = /datum/job/medical/coroner

	uniform = /obj/item/clothing/under/rank/medical/mortician
	suit = /obj/item/clothing/suit/storage/labcoat/mortician
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

	backpack_contents = list(
		/obj/item/clothing/head/surgery/black = 1,
		/obj/item/autopsy_scanner = 1,
		/obj/item/reagent_scanner = 1,
		/obj/item/storage/box/bodybags = 1,
	)

/datum/job/medical/chemist
	title = JOB_TITLE_CHEMIST
	flag = JOB_FLAG_CHEMIST
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_CHEMISTRY, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Pharmacist", "Pharmacologist")
	outfit = /datum/outfit/job/chemist

/datum/outfit/job/chemist
	name = JOB_TITLE_CHEMIST
	jobtype = /datum/job/medical/chemist

	uniform = /obj/item/clothing/under/rank/chemist
	suit = /obj/item/clothing/suit/storage/labcoat/chemist
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	glasses = /obj/item/clothing/glasses/science
	id = /obj/item/card/id/medical
	pda = /obj/item/pda/chemist

	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel_chem
	dufflebag = /obj/item/storage/backpack/duffel/chemistry

/datum/job/medical/geneticist
	title = JOB_TITLE_GENETICIST
	flag = JOB_FLAG_GENETICIST
	total_positions = 2
	spawn_positions = 2
	supervisors = "Главным врачом и Научным руководителем"
	department_head = list(JOB_TITLE_CMO, JOB_TITLE_RD)
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MAINT_TUNNELS)
	outfit = /datum/outfit/job/geneticist

/datum/outfit/job/geneticist
	name = JOB_TITLE_GENETICIST
	jobtype = /datum/job/medical/geneticist

	uniform = /obj/item/clothing/under/rank/geneticist
	suit = /obj/item/clothing/suit/storage/labcoat/genetics
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_medsci
	id = /obj/item/card/id/genetics
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/geneticist
	l_pocket = /obj/item/dna_notepad

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel_gen
	dufflebag = /obj/item/storage/backpack/duffel/genetics

/datum/job/medical/virologist
	title = JOB_TITLE_VIROLOGIST
	flag = JOB_FLAG_VIROLOGIST
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_VIROLOGY, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Pathologist", "Microbiologist")
	outfit = /datum/outfit/job/virologist

/datum/outfit/job/virologist
	name = JOB_TITLE_VIROLOGIST
	jobtype = /datum/job/medical/virologist

	uniform = /obj/item/clothing/under/rank/virologist
	suit = /obj/item/clothing/suit/storage/labcoat/virologist
	shoes = /obj/item/clothing/shoes/white
	mask = /obj/item/clothing/mask/surgical
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/viro

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel_vir
	dufflebag = /obj/item/storage/backpack/duffel/virology

/datum/job/medical/psychiatrist
	title = JOB_TITLE_PSYCHIATRIST
	flag = JOB_FLAG_PSYCHIATRIST
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_PSYCHIATRIST, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_PSYCHIATRIST, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Psychologist", "Therapist")
	outfit = /datum/outfit/job/psychiatrist

/datum/outfit/job/psychiatrist
	name = JOB_TITLE_PSYCHIATRIST
	jobtype = /datum/job/medical/psychiatrist

	uniform = /obj/item/clothing/under/rank/medical
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/laceup
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical

/datum/outfit/job/psychiatrist/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Psychiatrist")
				uniform = /obj/item/clothing/under/rank/psych
			if("Psychologist")
				uniform = /obj/item/clothing/under/rank/psych/turtleneck
			if("Therapist")
				uniform = /obj/item/clothing/under/rank/medical

/datum/job/medical/paramedic
	title = JOB_TITLE_PARAMEDIC
	flag = JOB_FLAG_PARAMEDIC
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_PARAMEDIC, ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MORGUE, ACCESS_SURGERY)
	minimal_access=list(ACCESS_PARAMEDIC, ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MORGUE, ACCESS_SURGERY)
	outfit = /datum/outfit/job/paramedic

/datum/outfit/job/paramedic
	name = JOB_TITLE_PARAMEDIC
	jobtype = /datum/job/medical/paramedic

	uniform = /obj/item/clothing/under/rank/medical/paramedic
	head = /obj/item/clothing/head/soft/paramedic
	mask = /obj/item/clothing/mask/cigarette
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	l_hand = /obj/item/storage/firstaid/paramed
	l_pocket = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical
	backpack_contents = list(
		/obj/item/healthanalyzer = 1,
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical
	box = /obj/item/storage/box/survival/engineer

/datum/outfit/job/paramedic/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/medical/paramedic/skirt
