/datum/job/head_of_staff
	total_positions = 1
	spawn_positions = 1
	supervisors = "Капитаном"
	department_head = list(JOB_TITLE_CAPTAIN)
	minimal_player_age = 21
	req_admin_notify = 1
	exp_requirements = 3000
	disabilities_allowed = 0
	head_position = TRUE
	insurance_type = INSURANCE_TYPE_DELUXE
	paycheck = PAYCHECK_COMMAND

/datum/job/captain
	title = JOB_TITLE_CAPTAIN
	flag = JOB_FLAG_CAPTAIN
	department_flag = JOBCAT_ENGSEC
	department = STATION_DEPARTMENT_COMMAND
	total_positions = 1
	spawn_positions = 1
	supervisors = "должностными лицами \"Нанотрейзен\""
	department_head = list(JOB_TITLE_CCOFFICER)
	selection_color = "#6691ff"
	req_admin_notify = 1
	is_command = 1
	access = list()	//See get_access()
	minimal_access = list()	//See get_access()
	law_level = LAW_LEVEL_CAPTAIN
	minimal_player_age = 30
	min_age_type = JOB_MIN_AGE_COMMAND
	blocked_race_for_job = list(SPECIES_VOX)
	exp_requirements = 3000
	exp_type = EXP_TYPE_COMMAND
	disabilities_allowed = 0
	head_position = TRUE
	outfit = /datum/outfit/job/captain
	insurance_type = INSURANCE_TYPE_DELUXE
	paycheck = PAYCHECK_MAX

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/human)
	. = ..()
	// Why the hell are captain announcements minor
	GLOB.minor_announcement.announce(
		message = "Всему экипажу! Капитан [human.real_name] взо[GEND_SHEL(human)] на борт!",
		new_sound = 'sound/misc/announce.ogg'
	)

/datum/outfit/job/captain
	name = JOB_TITLE_CAPTAIN
	jobtype = /datum/job/captain
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/color/brown
	head = /obj/item/clothing/head/caphat
	l_ear = /obj/item/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/hud/blueshield/cap
	id = /obj/item/card/id/gold
	l_pocket = /obj/item/lighter/zippo/cap
	pda = /obj/item/pda/captain
	backpack_contents = list(
		/obj/item/storage/box/ids = 1,
		/obj/item/melee/baton/telescopic = 1,
	)
	implants = list(/obj/item/implant/mindshield/ert)
	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel_cap
	dufflebag = /obj/item/storage/backpack/duffel/captain
	implant_variant = /obj/item/organ/internal/cyberimp/eyes/hud/security

/datum/outfit/job/captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H?.w_uniform)
		var/obj/item/clothing/accessory/medal/gold/captain/medal = new(H.w_uniform)
		medal.on_attached(H.w_uniform)

/datum/job/head_of_staff/nanotrasenrep
	title = JOB_TITLE_REPRESENTATIVE
	flag = JOB_FLAG_REPRESENTATIVE
	department_flag = JOBCAT_KARMA
	department = STATION_DEPARTMENT_COMMAND
	selection_color = "#d1deff"
	is_command = 1
	transfer_allowed = FALSE
	blocked_race_for_job = list(SPECIES_VOX)
	head_position = FALSE
	exp_requirements = 1200
	exp_type = EXP_TYPE_COMMAND
	access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
		ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
		ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
		ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
		ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
		ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_NTREP
	)
	minimal_access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
		ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_EVA, ACCESS_HEADS,
		ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
		ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
		ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
		ACCESS_CLOWN, ACCESS_MIME, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_NTREP
	)
	alt_titles = list("NT Consultant", "Central Command Consultant")
	outfit = /datum/outfit/job/nanotrasenrep
	paycheck = PAYCHECK_MAX

/datum/outfit/job/nanotrasenrep
	name = JOB_TITLE_REPRESENTATIVE
	jobtype = /datum/job/head_of_staff/nanotrasenrep
	uniform = /obj/item/clothing/under/rank/ntrep
	suit = /obj/item/clothing/suit/storage/ntrep
	shoes = /obj/item/clothing/shoes/centcom
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	l_ear = /obj/item/radio/headset/heads/ntrep
	id = /obj/item/card/id/nanotrasen
	l_pocket = /obj/item/lighter/zippo/nt_rep
	pda = /obj/item/pda/heads/ntrep
	backpack_contents = list(
		/obj/item/melee/baton/ntcane = 1,
	)
	implants = list(/obj/item/implant/mindshield/ert)

/datum/job/blueshield
	title = JOB_TITLE_BLUESHIELD
	flag = JOB_FLAG_BLUESHIELD
	department_flag = JOBCAT_KARMA
	department = STATION_DEPARTMENT_COMMAND
	total_positions = 1
	spawn_positions = 1
	supervisors = "Представителем \"Нанотрейзен\""
	department_head = list(JOB_TITLE_CAPTAIN)
	selection_color = "#d1deff"
	req_admin_notify = 1
	is_command = 1
	transfer_allowed = FALSE
	minimal_player_age = 21
	blocked_race_for_job = list(SPECIES_VOX, SPECIES_NUCLEATION)
	exp_requirements = 3000
	exp_type = EXP_TYPE_SECURITY
	disabilities_allowed = 0
	disabilities_allowed_slightly = 0
	access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
		ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
		ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
		ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
		ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
		ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_BLUESHIELD
	)
	minimal_access = list(
		ACCESS_FORENSICS_LOCKERS, ACCESS_SEC_DOORS, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH,
		ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_HEADS, ACCESS_BLUESHIELD, ACCESS_WEAPONS
	)
	outfit = /datum/outfit/job/blueshield
	insurance_type = INSURANCE_TYPE_DELUXE
	paycheck = PAYCHECK_COMMAND

/datum/outfit/job/blueshield
	name = JOB_TITLE_BLUESHIELD
	jobtype = /datum/job/blueshield
	uniform = /obj/item/clothing/under/rank/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield
	gloves = /obj/item/clothing/gloves/combat/swat
	shoes = /obj/item/clothing/shoes/jackboots
	l_ear = /obj/item/radio/headset/heads/blueshield/alt
	glasses = /obj/item/clothing/glasses/hud/blueshield
	id = /obj/item/card/id/nanotrasen
	pda = /obj/item/pda/heads/blueshield
	backpack_contents = list(
		/obj/item/storage/box/deathimp = 1,
		/obj/item/gun/energy/gun/blueshield = 1,
		/obj/item/gun/projectile/automatic/proto/rubber = 1,
		/obj/item/ammo_box/magazine/smgm9mm = 2,
	)
	implants = list(/obj/item/implant/mindshield/ert)
	backpack = /obj/item/storage/backpack/blueshield
	satchel = /obj/item/storage/backpack/satchel_blueshield
	dufflebag = /obj/item/storage/backpack/duffel/blueshield

/datum/job/head_of_staff/judge
	title = JOB_TITLE_JUDGE
	flag = JOB_FLAG_JUDGE
	department_flag = JOBCAT_KARMA
	department = STATION_DEPARTMENT_LEGAL
	supervisors = "верховным судом \"Нанотрейзен\""
	department_head = list(JOB_TITLE_CAPTAIN)
	selection_color = "#db6d92"
	is_legal = 1
	transfer_allowed = FALSE
	minimal_player_age = 30
	min_age_type = JOB_MIN_AGE_COMMAND
	blocked_race_for_job = list(SPECIES_VOX)
	exp_requirements = 1200
	exp_type = EXP_TYPE_COMMAND
	access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
		ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
		ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
		ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
		ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
		ACCESS_CLOWN, ACCESS_MIME, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MAGISTRATE
	)
	minimal_access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_LAWYER, ACCESS_MAGISTRATE, ACCESS_HEADS
	)
	law_level = LAW_LEVEL_MAGISTRATE
	alt_titles = list("Judge")
	outfit = /datum/outfit/job/judge
	paycheck = PAYCHECK_MAX

/datum/outfit/job/judge
	name = JOB_TITLE_JUDGE
	jobtype = /datum/job/head_of_staff/judge
	uniform = /obj/item/clothing/under/suit_jacket/really_black
	suit = /obj/item/clothing/suit/judgerobe
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/powdered_wig
	l_ear = /obj/item/radio/headset/heads/magistrate/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/nanotrasen
	l_pocket = /obj/item/flash
	r_pocket = /obj/item/clothing/accessory/head_strip/lawyers_badge
	pda = /obj/item/pda/heads/magistrate
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
	)
	implants = list(/obj/item/implant/mindshield/ert)
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival/survival_laws/magisraka

/datum/job/lawyer
	title = JOB_TITLE_LAWYER
	flag = JOB_FLAG_LAWYER
	department_flag = JOBCAT_SUPPORT
	department = STATION_DEPARTMENT_LEGAL
	total_positions = 2
	spawn_positions = 2
	is_legal = 1
	supervisors = "Магистратом"
	department_head = list(JOB_TITLE_CAPTAIN)
	selection_color = "#edccd7"
	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)
	minimal_access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)
	minimal_player_age = 30
	blocked_race_for_job = list(SPECIES_VOX)
	exp_requirements = 3000
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/lawyer
	insurance_type = INSURANCE_TYPE_DELUXE
	paycheck = PAYCHECK_COMMAND

/datum/outfit/job/lawyer
	name = JOB_TITLE_LAWYER
	jobtype = /datum/job/lawyer
	uniform = /obj/item/clothing/under/rank/lawyer
	suit = /obj/item/clothing/suit/storage/internalaffairs
	shoes = /obj/item/clothing/shoes/color/brown
	l_ear = /obj/item/radio/headset/headset_iaa/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/read_only
	id = /obj/item/card/id/iaa
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/head_strip/lawyers_badge
	l_hand = /obj/item/storage/briefcase
	pda = /obj/item/pda/lawyer
	backpack_contents = list(
		/obj/item/flash = 1,
	)
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	box = /obj/item/storage/box/survival/survival_laws
