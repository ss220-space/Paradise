/datum/job/head_of_staff/qm
	title = JOB_TITLE_QUARTERMASTER
	flag = JOB_FLAG_QUARTERMASTER
	department_flag = JOBCAT_SUPPORT
	department = STATION_DEPARTMENT_SUPPLY
	is_supply = 1
	selection_color = "#9f8545"
	access = list(ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_HEADS_VAULT, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_HEADS,
		ACCESS_SEC_DOORS, ACCESS_EVA, ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO,
		ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION,
		ACCESS_MINERAL_STOREROOM
	)
	minimal_access = list(ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_HEADS_VAULT, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_HEADS,
		ACCESS_SECURITY, ACCESS_EVA, ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO,
		ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION,
		ACCESS_MINERAL_STOREROOM
	)
	alt_titles = list("Chief Supply Manager")
	exp_type = EXP_TYPE_SUPPLY
	outfit = /datum/outfit/job/qm

/datum/outfit/job/qm
	name = JOB_TITLE_QUARTERMASTER
	jobtype = /datum/job/head_of_staff/qm

	uniform = /obj/item/clothing/under/rank/cargo
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/heads/qm
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/lighter/zippo/qm
	id = /obj/item/card/id/qm
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/quartermaster
	backpack = /obj/item/storage/backpack/cargo
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
	)
	head = /obj/item/clothing/head/cowboyhat/tan

/datum/job/supply
	department_flag = JOBCAT_SUPPORT
	department = STATION_DEPARTMENT_SUPPLY
	is_supply = 1
	supervisors = "Квартирмейстером"
	department_head = list(JOB_TITLE_QUARTERMASTER)
	selection_color = "#e2dbc8"
	exp_requirements = 600
	exp_type = EXP_TYPE_CREW
	paycheck = PAYCHECK_CREW

/datum/job/supply/cargo_tech
	title = JOB_TITLE_CARGOTECH
	flag = JOB_FLAG_CARGOTECH
	total_positions = 3
	spawn_positions = 3
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Supply Manager", "Loader")
	outfit = /datum/outfit/job/cargo_tech

/datum/outfit/job/cargo_tech
	name = JOB_TITLE_CARGOTECH
	jobtype = /datum/job/supply/cargo_tech

	uniform = /obj/item/clothing/under/rank/cargotech
	l_ear = /obj/item/radio/headset/headset_cargo
	id = /obj/item/card/id/supply
	pda = /obj/item/pda/cargo
	backpack = /obj/item/storage/backpack/cargo

/datum/job/supply/mining
	title = JOB_TITLE_MINER
	flag = JOB_FLAG_MINER
	total_positions = 6
	spawn_positions = 8
	blocked_race_for_job = list(SPECIES_NUCLEATION)
	access = list(ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MINING, ACCESS_MINT, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Spelunker")
	outfit = /datum/outfit/job/mining
	insurance_type = INSURANCE_TYPE_EXTENDED

/datum/outfit/job/mining
	name = JOB_TITLE_MINER
	jobtype = /datum/job/supply/mining

	l_ear = /obj/item/radio/headset/headset_cargo/mining
	shoes = /obj/item/clothing/shoes/workboots/mining
	gloves = /obj/item/clothing/gloves/color/black
	uniform = /obj/item/clothing/under/rank/miner/lavaland
	l_pocket = /obj/item/reagent_containers/hypospray/autoinjector/survival
	r_pocket = /obj/item/storage/bag/ore
	id = /obj/item/card/id/supply
	pda = /obj/item/pda/shaftminer
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/kitchen/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/stack/marker_beacon/ten = 1,
		/obj/item/wormhole_jaunter = 1,
		/obj/item/survivalcapsule = 1,
	)

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel_explorer
	box = /obj/item/storage/box/survival/survival_mining

/datum/outfit/job/mining/equipped
	toggle_helmet = TRUE
	suit = /obj/item/clothing/suit/hooded/explorer
	mask = /obj/item/clothing/mask/gas/explorer
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/tank/internals/emergency_oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/kitchen/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/t_scanner/adv_mining_scanner/lesser = 1,
		/obj/item/gun/energy/kinetic_accelerator = 1,
		/obj/item/stack/marker_beacon/ten = 1,
	)

/datum/outfit/job/miner/equipped/hardsuit
	name = "Шахтёр (Снаряжение + ИКС)"
	suit = /obj/item/clothing/suit/space/hardsuit/mining
	mask = /obj/item/clothing/mask/breath

/// Mining medic job and outfit

/datum/job/supply/mining_medic
	title = JOB_TITLE_MINING_MEDIC
	flag = JOB_FLAG_MINING_MEDIC
	total_positions = 1
	spawn_positions = 1
	supervisors = "Главным врачом и Квартирмейстером"
	department_head = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CMO)
	selection_color = "#cee6ef"
	access = list(ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_GENETICS)
	minimal_access = list(ACCESS_MINING, ACCESS_MINT, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY)
	alt_titles = list("Lavaland Health Officer")
	outfit = /datum/outfit/job/mining_medic
	insurance_type = INSURANCE_TYPE_EXTENDED
	exp_type = EXP_TYPE_MEDICAL

/datum/outfit/job/mining_medic
	name = JOB_TITLE_MINING_MEDIC
	jobtype = /datum/job/supply/mining_medic
	glasses = /obj/item/clothing/glasses/hud/health/meson
	l_ear = /obj/item/radio/headset/headset_mining_medic
	shoes = /obj/item/clothing/shoes/workboots/mining
	uniform = /obj/item/clothing/under/rank/medical/mining_medic
	suit = /obj/item/clothing/suit/storage/labcoat/mining_medic
	l_pocket = /obj/item/roller/holo
	r_pocket = /obj/item/flash
	l_hand = /obj/item/storage/firstaid/doctor/mining_medic
	id = /obj/item/card/id/mining_medic
	pda = /obj/item/pda/cargo

	backpack_contents = list(
		/obj/item/flashlight/lantern = 1,
		/obj/item/radio/weather_monitor = 1,
		/obj/item/wormhole_jaunter = 1,
	)
