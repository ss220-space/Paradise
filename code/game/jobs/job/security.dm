/datum/job/hos
	title = JOB_TITLE_HOS
	flag = JOB_FLAG_HOS
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_security = 1
	supervisors = "the captain"
	department_head = list(JOB_TITLE_CAPTAIN)
	selection_color = "#c25656"
	req_admin_notify = 1
	access = list(ACCESS_EVA, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
			            ACCESS_FORENSICS_LOCKERS, ACCESS_PILOT, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
			            ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
			            ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_EVA, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
			            ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
			            ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
			            ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_PILOT, ACCESS_WEAPONS)
	minimal_player_age = 21
	min_age_allowed = 30
	blocked_race_for_job = list(SPECIES_VOX)
	exp_requirements = 3000
	exp_type = EXP_TYPE_SECURITY
	disabilities_allowed = 0
	outfit = /datum/outfit/job/hos
	insurance_type = INSURANCE_TYPE_DELUXE

	salary = 300
	min_start_money = 400
	max_start_money = 700

/datum/outfit/job/hos
	name = "Head of Security"
	jobtype = /datum/job/hos

	uniform = /obj/item/clothing/under/rank/head_of_security
	suit = /obj/item/clothing/suit/armor/hos
	gloves = /obj/item/clothing/gloves/color/black/hos
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/HoS
	l_ear = /obj/item/radio/headset/heads/hos/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/hos
	l_pocket = /obj/item/lighter/zippo/hos
	suit_store = /obj/item/gun/energy/gun/sibyl
	pda = /obj/item/pda/heads/hos
	l_hand = /obj/item/storage/lockbox/sibyl_system_mod
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/security_voucher = 1
	)

	implants = list(/obj/item/implant/mindshield/ert)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival_security/hos



/datum/job/warden
	title = JOB_TITLE_WARDEN
	flag = JOB_FLAG_WARDEN
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_security = 1
	supervisors = "the head of security"
	department_head = list(JOB_TITLE_HOS)
	selection_color = "#edcdcd"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	alt_titles = list("Brig Sergeant")
	minimal_player_age = 21
	min_age_allowed = 30
	blocked_race_for_job = list(SPECIES_VOX)
	exp_requirements = 2100
	exp_type = EXP_TYPE_SECURITY
	outfit = /datum/outfit/job/warden
	insurance_type = INSURANCE_TYPE_DELUXE

	salary = 170
	min_start_money = 200
	max_start_money = 550

/datum/outfit/job/warden
	name = "Warden"
	jobtype = /datum/job/warden

	uniform = /obj/item/clothing/under/rank/warden
	suit = /obj/item/clothing/suit/armor/vest/warden
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/warden
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/warden
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/gun/advtaser
	pda = /obj/item/pda/warden
	l_hand = /obj/item/storage/lockbox/sibyl_system_mod
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/security_voucher = 1
	)

	implants = list(/obj/item/implant/mindshield)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival_security/warden

/datum/job/detective
	title = JOB_TITLE_DETECTIVE
	flag = JOB_FLAG_DETECTIVE
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_security = 1
	supervisors = "the head of security"
	department_head = list(JOB_TITLE_HOS)
	selection_color = "#edcdcd"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_WEAPONS)
	alt_titles = list("Forensic Technician")
	minimal_player_age = 14
	exp_requirements = 1200
	blocked_race_for_job = list(SPECIES_VOX)
	exp_type = EXP_TYPE_SECURITY
	outfit = /datum/outfit/job/detective
	insurance_type = INSURANCE_TYPE_DELUXE

	salary = 170
	min_start_money = 200
	max_start_money = 550

/datum/outfit/job/detective
	name = "Detective"
	jobtype = /datum/job/detective

	uniform = /obj/item/clothing/under/det
	suit = /obj/item/clothing/suit/storage/det_suit
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/det_hat
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/aviators
	id = /obj/item/card/id/security
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/lighter/zippo
	pda = /obj/item/pda/detective
	l_hand = /obj/item/storage/briefcase/crimekit
	backpack_contents = list(
		/obj/item/storage/box/evidence = 1,
		/obj/item/melee/baton/telescopic = 1
	)
	satchel = /obj/item/storage/backpack/satchel_detective
	box = /obj/item/storage/box/survival_security/detective

	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/detective/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Forensic Technician")
				suit = /obj/item/clothing/suit/storage/det_suit/forensics/blue
				head = null

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.force_gene_block(GLOB.soberblock, TRUE, TRUE)


/datum/job/officer
	title = JOB_TITLE_OFFICER
	flag = JOB_FLAG_OFFICER
	department_flag = JOBCAT_ENGSEC
	total_positions = 7
	spawn_positions = 7
	is_security = 1
	supervisors = "the head of security"
	department_head = list(JOB_TITLE_HOS)
	selection_color = "#edcdcd"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	alt_titles = list("Security Trainer","Patrol Officer", "Security Cadet")
	minimal_player_age = 14
	blocked_race_for_job = list(SPECIES_VOX)
	exp_requirements = 600
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/officer
	insurance_type = INSURANCE_TYPE_DELUXE

	salary = 170
	min_start_money = 200
	max_start_money = 550

/datum/outfit/job/officer
	name = "Security Officer"
	jobtype = /datum/job/officer
	uniform = /obj/item/clothing/under/rank/security
	suit = /obj/item/clothing/suit/armor/vest/security
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet
	l_ear = /obj/item/radio/headset/headset_sec/alt
	id = /obj/item/card/id/security
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/gun/advtaser
	pda = /obj/item/pda/security
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/security_voucher = 1
	)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival_security

/datum/outfit/job/officer/cadet
	name = "Security Cadet"
	uniform = /obj/item/clothing/under/rank/security/cadet
	head = /obj/item/clothing/head/soft/sec
	id = /obj/item/card/id/security/cadet
	l_pocket = /obj/item/reagent_containers/spray/pepper
	r_pocket = /obj/item/paper/deltainfo
	suit_store = /obj/item/gun/energy/gun/advtaser
	box = /obj/item/storage/box/survival_security/cadet

/datum/outfit/job/officer/cadet/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/security/cadet/skirt
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Security Assistant")
				uniform = /obj/item/clothing/under/rank/security/cadet/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/security/cadet/assistant/skirt
			if("Security Graduate")
				head = /obj/item/clothing/head/beret/sec

/datum/job/brigdoc
	title = JOB_TITLE_BRIGDOC
	flag = JOB_FLAG_BRIGDOC
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	is_security = 1
	supervisors = "the head of security"
	department_head = list(JOB_TITLE_HOS)
	selection_color = "#edcdcd"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Security Medic")
	blocked_race_for_job = list(SPECIES_VOX)
	exp_requirements = 1800
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/brigdoc
	insurance_type = INSURANCE_TYPE_DELUXE

	salary = 170
	min_start_money = 200
	max_start_money = 550

/datum/outfit/job/brigdoc
	name = "Brig Physician"
	jobtype = /datum/job/brigdoc
	uniform = /obj/item/clothing/under/rank/security/brigphys
	suit = /obj/item/clothing/suit/storage/fr_jacket
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_brigphys
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	id = /obj/item/card/id/security
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/doctor
	pda = /obj/item/pda/medical
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical
	box = /obj/item/storage/box/survival/brigphys


/datum/job/pilot
	title = JOB_TITLE_PILOT
	flag = JOB_FLAG_PILOT
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	is_security = 1
	supervisors = "the head of security"
	department_head = list(JOB_TITLE_HOS)
	selection_color = "#edcdcd"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_PILOT, ACCESS_EXTERNAL_AIRLOCKS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS, ACCESS_PILOT, ACCESS_EXTERNAL_AIRLOCKS)
	minimal_player_age = 7
	blocked_race_for_job = list(SPECIES_VOX)
	exp_requirements = 1200
	exp_type = EXP_TYPE_SECURITY
	outfit = /datum/outfit/job/pilot
	insurance_type = INSURANCE_TYPE_DELUXE

	salary = 170
	min_start_money = 200
	max_start_money = 550

/datum/outfit/job/pilot
	name = "Security Pod Pilot"
	jobtype = /datum/job/pilot
	uniform = /obj/item/clothing/under/rank/security/pod_pilot
	suit = /obj/item/clothing/suit/jacket/pilot
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	l_ear = /obj/item/radio/headset/headset_sec/alt
	id = /obj/item/card/id/security
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/gun/advtaser
	pda = /obj/item/pda/security
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/security_voucher = 1
	)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival_security/pilot
