/datum/job/head_of_staff/hos
	title = JOB_TITLE_HOS
	flag = JOB_FLAG_HOS
	department = STATION_DEPARTMENT_SECURITY
	department_flag = JOBCAT_ENGSEC
	is_security = 1
	selection_color = "#c25656"
	access = list(
		ACCESS_EVA, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
		ACCESS_FORENSICS_LOCKERS, ACCESS_PILOT, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
		ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS
	)
	minimal_access = list(
		ACCESS_EVA, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
		ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
		ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_PILOT, ACCESS_WEAPONS
	)
	blocked_race_for_job = list(SPECIES_VOX, SPECIES_NUCLEATION)
	law_level = LAW_LEVEL_HOS
	exp_type = EXP_TYPE_SECURITY
	disabilities_allowed_slightly = 0
	outfit = /datum/outfit/job/hos

/datum/outfit/job/hos
	name = JOB_TITLE_HOS
	jobtype = /datum/job/head_of_staff/hos

	uniform = /obj/item/clothing/under/rank/head_of_security
	suit = /obj/item/clothing/suit/armor/hos/alt
	gloves = /obj/item/clothing/gloves/combat/swat
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/HoS/beret
	belt = /obj/item/storage/belt/security/sec
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
		/obj/item/security_voucher = 1,
	)

	implants = list(/obj/item/implant/mindshield/ert)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival/survival_security/hos
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/security

/datum/job/security
	department = STATION_DEPARTMENT_SECURITY
	department_flag = JOBCAT_ENGSEC
	is_security = 1
	supervisors = "Главой службы безопасности"
	department_head = list(JOB_TITLE_HOS)
	selection_color = "#edcdcd"
	minimal_player_age = 14
	blocked_race_for_job = list(SPECIES_VOX, SPECIES_NUCLEATION)
	exp_requirements = 900
	exp_type = EXP_TYPE_CREW
	disabilities_allowed = 0
	disabilities_allowed_slightly = 0
	insurance_type = INSURANCE_TYPE_DELUXE
	paycheck = PAYCHECK_CREW

/datum/job/security/warden
	title = JOB_TITLE_WARDEN
	flag = JOB_FLAG_WARDEN
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_PILOT, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_GATEWAY, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_PILOT, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_GATEWAY, ACCESS_WEAPONS)
	law_level = LAW_LEVEL_WARDEN
	alt_titles = list("Brig Sergeant")
	minimal_player_age = 21
	exp_requirements = 2100
	outfit = /datum/outfit/job/warden

/datum/outfit/job/warden
	name = JOB_TITLE_WARDEN
	jobtype = /datum/job/security/warden

	uniform = /obj/item/clothing/under/rank/warden
	suit = /obj/item/clothing/suit/armor/vest/warden
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/warden
	belt = /obj/item/storage/belt/security/sec
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/warden
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/gun/advtaser
	pda = /obj/item/pda/warden
	l_hand = /obj/item/storage/lockbox/sibyl_system_mod
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/security_voucher = 1,
	)

	implants = list(/obj/item/implant/mindshield)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival/survival_security/warden
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/security

/datum/job/security/detective
	title = JOB_TITLE_DETECTIVE
	flag = JOB_FLAG_DETECTIVE
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_BRIG)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_BRIG)
	law_level = LAW_LEVEL_SEC
	alt_titles = list("Forensic Technician")
	blocked_race_for_job = list(SPECIES_VOX)
	outfit = /datum/outfit/job/detective

/datum/outfit/job/detective
	name = JOB_TITLE_DETECTIVE
	jobtype = /datum/job/security/detective

	uniform = /obj/item/clothing/under/det
	suit = /obj/item/clothing/suit/storage/det_suit
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/det_hat
	belt = /obj/item/storage/belt/security/detective
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/aviators
	id = /obj/item/card/id/security
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/lighter/zippo/detective
	pda = /obj/item/pda/detective
	l_hand = /obj/item/storage/briefcase/crimekit
	backpack_contents = list(
		/obj/item/storage/box/evidence = 1,
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/security_voucher/detective = 1,
	)
	satchel = /obj/item/storage/backpack/satchel_detective
	box = /obj/item/storage/box/survival/survival_security/detective

	implants = list(/obj/item/implant/mindshield)
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/security

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

/datum/job/security/officer
	title = JOB_TITLE_OFFICER
	flag = JOB_FLAG_OFFICER
	total_positions = 6
	spawn_positions = 6
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	law_level = LAW_LEVEL_SEC
	alt_titles = list("Security Trainer", "Patrol Officer", "Security Cadet")
	outfit = /datum/outfit/job/officer

/datum/outfit/job/officer
	name = JOB_TITLE_OFFICER
	jobtype = /datum/job/security/officer
	uniform = /obj/item/clothing/under/rank/security
	suit = /obj/item/clothing/suit/armor/vest/security
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet
	belt = /obj/item/storage/belt/security/sec
	l_ear = /obj/item/radio/headset/headset_sec/alt
	id = /obj/item/card/id/security
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/gun/advtaser
	pda = /obj/item/pda/security
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/security_voucher = 1,
	)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival/survival_security
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/security

/datum/outfit/job/officer/cadet
	name = "Security Cadet"
	uniform = /obj/item/clothing/under/rank/security/cadet
	head = /obj/item/clothing/head/soft/sec
	id = /obj/item/card/id/security/cadet
	l_pocket = /obj/item/reagent_containers/spray/pepper
	box = /obj/item/storage/box/survival/survival_security/cadet

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

/datum/job/security/brigdoc
	title = JOB_TITLE_BRIGDOC
	flag = JOB_FLAG_BRIGDOC
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	selection_color = "#cee6ef"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Security Medic")
	blocked_race_for_job = list(SPECIES_VOX)
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/brigdoc

/datum/outfit/job/brigdoc
	name = JOB_TITLE_BRIGDOC
	jobtype = /datum/job/security/brigdoc
	uniform = /obj/item/clothing/under/rank/security/brigphys
	suit = /obj/item/clothing/suit/storage/fr_jacket
	shoes = /obj/item/clothing/shoes/color/white
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
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/medical

/datum/job/security/pilot
	title = JOB_TITLE_PILOT
	flag = JOB_FLAG_PILOT
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_PILOT, ACCESS_EXTERNAL_AIRLOCKS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS, ACCESS_PILOT, ACCESS_EXTERNAL_AIRLOCKS)
	law_level = LAW_LEVEL_SEC
	outfit = /datum/outfit/job/pilot

/datum/outfit/job/pilot
	name = JOB_TITLE_PILOT
	jobtype = /datum/job/security/pilot
	uniform = /obj/item/clothing/under/rank/security/pod_pilot
	suit = /obj/item/clothing/suit/jacket/pilot
	gloves = /obj/item/clothing/gloves/color/black
	belt = /obj/item/storage/belt/security/sec
	shoes = /obj/item/clothing/shoes/jackboots
	l_ear = /obj/item/radio/headset/headset_sec/alt
	id = /obj/item/card/id/security
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/gun/advtaser
	pda = /obj/item/pda/security
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/security_voucher = 1,
	)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival/survival_security/pilot
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/security
