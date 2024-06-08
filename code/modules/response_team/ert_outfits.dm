/* ERT OUTFIT DATUMS */

/datum/outfit/job/centcom/response_team/imprint_idcard(mob/living/carbon/human/H)
	var/obj/item/card/id/W = H.wear_id
	if(!istype(W))
		return
	W.assignment = rt_assignment
	W.rank = W.assignment
	W.age = H.age
	W.sex = capitalize(H.gender)
	W.registered_name = H.real_name
	W.name = "[H.real_name]'s ID Card ([rt_job])"
	W.access = get_centcom_access(W.assignment)
	W.photo = get_id_photo(H)
	if(H.mind && H.mind.initial_account && H.mind.initial_account.account_number)
		W.associated_account_number = H.mind.initial_account.account_number

/datum/outfit/job/centcom/response_team/imprint_pda(mob/living/carbon/human/H)
	var/obj/item/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = rt_assignment
		PDA.ownrank = rt_assignment
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

/datum/outfit/job/centcom/response_team/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.job = rt_mob_job

//////////////////// COMMANDER ///////////////////

/datum/outfit/job/centcom/response_team/commander
	name = "RT Commander"
	rt_assignment = "Emergency Response Team Leader"
	rt_job = "Emergency Response Team Leader"
	rt_mob_job = "ERT Commander"
	special_message = "В обычных условий вы подчиняетесь <span class='red'>старшим по рангу офицерам Защиты Активов</span>. \n Впрочем, на время проведения операции вы подчиняетесь <span class='red'>Офицеру Специальных Операций</span>. \n Исключениями являются случаи, когда его приказания прямо противоречат интересам Отдела Защиты Активов или приказаниям членов ОЗА в более высоком звании, чем вы. \n Вы имеете абсолютную власть в рамках вашего отряда, и практически абсолютную в рамках зоны проведения операции. Пресекайте прямое неподчинение, но не забывайте прислушиваться к мнению специалистов."
	exp_type = EXP_TYPE_COMMAND

	uniform = /obj/item/clothing/under/rank/centcom_officer/sensor
	back = /obj/item/storage/backpack/ert/commander
	l_ear = /obj/item/radio/headset/ert/alt/commander
	id = /obj/item/card/id/ert/commander
	l_pocket = /obj/item/pinpointer
	r_pocket = /obj/item/melee/classic_baton/telescopic

/datum/outfit/job/centcom/response_team/commander/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.age = rand(35,45)

/datum/outfit/job/centcom/response_team/commander/amber
	name = "RT Commander (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/armor/vest/ert/command
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/gun/energy/gun/pdw9/ert
	head = /obj/item/clothing/head/helmet/ert/command

	hours_dif = 200
	ranks = list("Min" = "Младший сержант",
				"Med" = "Сержант",
				"Max" = "Мастер-сержант")
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/storage/lockbox/mindshield/ert = 1,
		/obj/item/flashlight/seclite = 1
	)

/datum/outfit/job/centcom/response_team/commander/red
	name = "RT Commander (Red)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit_store = /obj/item/gun/energy/gun/pdw9/ert
	belt = /obj/item/gun/projectile/automatic/pistol/sp8/sp8t

	hours_dif = 250
	ranks = list("Min" = "Мастер-сержант",
				"Med" = "Уорент-офицер",
				"Max" = "Младший лейтенант")
	backpack_contents = list(
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/camera_bug/ert = 1,
		/obj/item/door_remote/omni = 1,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/storage/lockbox/mindshield/ert = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/commander/gamma
	name = "RT Commander (Gamma)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/gamma/commander
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit_store = /obj/item/gun/energy/gun/pdw9/ert
	belt = /obj/item/gun/projectile/automatic/pistol/sp8/sp8t

	hours_dif = 300
	ranks = list("Min" = "Лейтенант",
				"Med" = "Старший лейтенант",
				"Max" = "Капитан")
	backpack_contents = list(
		/obj/item/ammo_box/magazine/sp8 = 4,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/storage/lockbox/mindshield/ert = 1,
		/obj/item/camera_bug/ert = 1,
		/obj/item/door_remote/omni = 1,
		)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/thermals/empproof,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened,
		/obj/item/organ/internal/cyberimp/arm/flash
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

//////////////////// SECURITY ///////////////////

/datum/outfit/job/centcom/response_team/security
	name = "RT Security"
	rt_job = "Emergency Response Team Officer"
	rt_mob_job = "ERT Security"
	uniform = /obj/item/clothing/under/rank/security/sensor
	back = /obj/item/storage/backpack/ert/security
	belt = /obj/item/storage/belt/security/sec
	pda = /obj/item/pda/heads/ert/security
	id = /obj/item/card/id/ert/security
	exp_type = EXP_TYPE_SECURITY

/datum/outfit/job/centcom/response_team/security/amber
	name = "RT Security (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/armor/vest/ert/security
	suit_store = /obj/item/gun/energy/gun/advtaser/sibyl
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/ert/security

	backpack_contents = list(
		/obj/item/storage/box/zipties = 1,
		/obj/item/storage/box/teargas = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/gun/energy/laser/sibyl = 1
	)

/datum/outfit/job/centcom/response_team/security/red
	name = "RT Security (Red)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/security
	suit_store = /obj/item/gun/projectile/automatic/lasercarbine
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat

	hours_dif = 100
	ranks = list("Min" = "Рядовой",
				"Med" = "Капрал",
				"Max" = "Специалист")

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 3,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/grenade/flashbang = 2,
		/obj/item/ammo_box/magazine/laser = 2,
		/obj/item/gun/energy/gun/pdw9/ert = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old,
		/obj/item/organ/internal/cyberimp/eyes/hud/security
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/security/gamma
	name = "RT Security (Gamma)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/gamma/security
	belt = /obj/item/storage/belt/military/assault/gammaert/full
	suit_store = /obj/item/gun/energy/immolator/multi/sibyl
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	l_pocket = /obj/item/restraints/legcuffs/bola/energy
	r_pocket = /obj/item/extinguisher/mini

	hours_dif = 200
	ranks = list("Min" = "Старший капрал",
				"Med" = "Специалист",
				"Max" = "Старший специалист")

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 3,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/whetstone = 1,
		/obj/item/storage/lockbox/t4 = 1,
		/obj/item/gun/energy/gun/nuclear/sibyl = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/thermals/empproof,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened,
		/obj/item/organ/internal/cyberimp/arm/telebaton,
		/obj/item/organ/internal/cyberimp/chest/reviver/hardened
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

//////////////////// ENGINEER ///////////////////

/datum/outfit/job/centcom/response_team/engineer
	name = "RT Engineer"
	rt_job = "Emergency Response Team Engineer"
	rt_mob_job = "ERT Engineering"
	toggle_helmet = TRUE
	back = /obj/item/storage/backpack/ert/engineer
	uniform = /obj/item/clothing/under/rank/engineer
	belt = /obj/item/storage/belt/utility/full/multitool
	pda = /obj/item/pda/heads/ert/engineering
	id = /obj/item/card/id/ert/engineering
	exp_type = EXP_TYPE_ENGINEERING

/datum/outfit/job/centcom/response_team/engineer/amber
	name = "RT Engineer (Amber)"
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson/night
	mask = /obj/item/clothing/mask/gas
	r_pocket = /obj/item/melee/classic_baton/telescopic

	hours_dif = 100
	ranks = list("Min" = "Младший капрал",
				"Med" = "Капрал",
				"Max" = "Старший капрал")

	backpack_contents = list(
		/obj/item/gun/energy/gun/pdw9/ert = 1,
		/obj/item/t_scanner = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/metal/fifty = 1,
		/obj/item/rpd = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/job/centcom/response_team/engineer/red
	name = "RT Engineer (Red)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/chief/full
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson/night
	mask = /obj/item/clothing/mask/gas
	l_pocket = /obj/item/t_scanner/extended_range
	r_pocket = /obj/item/melee/classic_baton/telescopic

	hours_dif = 200
	ranks = list("Min" = "Старший капрал",
				"Med" = "Младший специалист",
				"Max" = "Специалист")

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/rcd/preloaded = 1,
		/obj/item/rcd_ammo = 3,
		/obj/item/rpd = 1,
		/obj/item/gun/energy/gun/sibyl = 1
	)

	cybernetic_implants = list(
	/obj/item/organ/internal/cyberimp/eyes/shield,
	/obj/item/organ/internal/cyberimp/chest/nutriment_old
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/engineer/gamma
	name = "RT Engineer (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/chief/full
	suit = /obj/item/clothing/suit/space/hardsuit/ert/gamma/engineer
	suit_store = /obj/item/gun/energy/gun/pdw9/ert
	glasses = /obj/item/clothing/glasses/meson/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	l_pocket = /obj/item/t_scanner/extended_range
	r_pocket = /obj/item/melee/classic_baton/telescopic

	hours_dif = 250
	ranks = list("Min" = "Младший специалист",
				"Med" = "Специалист",
				"Max" = "Старший специалист")

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/rcd/combat = 1,
		/obj/item/rcd_ammo/large = 3,
		/obj/item/rpd/bluespace = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened,
		/obj/item/organ/internal/cyberimp/eyes/shield,
		/obj/item/organ/internal/cyberimp/arm/toolset
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

//////////////////// MEDIC ///////////////////

/datum/outfit/job/centcom/response_team/medic
	name = "RT Medic"
	rt_job = "Emergency Response Team Medic"
	rt_mob_job = "ERT Medical"
	uniform = /obj/item/clothing/under/rank/medical
	back = /obj/item/storage/backpack/ert/medical
	pda = /obj/item/pda/heads/ert/medical
	id = /obj/item/card/id/ert/medic
	exp_type = EXP_TYPE_MEDICAL

/datum/outfit/job/centcom/response_team/medic/amber
	name = "RT Medic (Amber)"
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/armor/vest/ert/medical
	suit_store = /obj/item/gun/energy/gun/pdw9/ert
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	head = /obj/item/clothing/head/helmet/ert/medical
	mask = /obj/item/clothing/mask/gas/sechailer
	belt = /obj/item/storage/belt/medical/surgery/loaded
	l_pocket = /obj/item/reagent_containers/hypospray/safety/ert
	r_pocket = /obj/item/melee/classic_baton/telescopic
	r_hand = /obj/item/defibrillator/loaded

	hours_dif = 100
	ranks = list("Min" = "Младший капрал",
				"Med" = "Капрал",
				"Max" = "Старший капрал")

	backpack_contents = list(
		/obj/item/storage/firstaid/adv = 1,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/roller/holo = 1,
		/obj/item/storage/pill_bottle/ert = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/handheld_defibrillator = 1
	)

/datum/outfit/job/centcom/response_team/medic/red
	name = "RT Medic (Red)"
	rt_mob_job = "ERT Medical"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/medical
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit_store = /obj/item/gun/energy/gun/sibyl
	belt = /obj/item/defibrillator/compact/loaded
	l_pocket = /obj/item/reagent_containers/hypospray/safety/ert
	r_pocket = /obj/item/melee/classic_baton/telescopic

	hours_dif = 200
	ranks = list("Min" = "Старший капрал",
				"Med" = "Младший специалист",
				"Max" = "Специалист")

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/storage/firstaid/ertm = 1,
		/obj/item/storage/box/autoinjectors = 1,
		/obj/item/roller/holo = 1,
		/obj/item/bodyanalyzer = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/handheld_defibrillator = 1,
		/obj/item/reagent_containers/applicator/burn = 1,
		/obj/item/reagent_containers/applicator/brute = 1,
		/obj/item/storage/pill_bottle/patch_pack/filled = 1
	)

	cybernetic_implants = list(
	/obj/item/organ/internal/cyberimp/arm/surgery,
	/obj/item/organ/internal/cyberimp/chest/nutriment_old
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/medic/gamma
	name = "RT Medic (Gamma)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/gamma/medical
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit_store = /obj/item/gun/energy/gun/pdw9/ert
	belt = /obj/item/defibrillator/compact/advanced/loaded
	l_pocket = /obj/item/reagent_containers/hypospray/combat/nanites
	r_pocket = /obj/item/reagent_containers/hypospray/autoinjector

	hours_dif = 250
	ranks = list("Min" = "Младший специалист",
				"Med" = "Специалист",
				"Max" = "Старший специалист")

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/storage/firstaid/ertm = 1,
		/obj/item/bodyanalyzer/advanced = 1,
		/obj/item/extinguisher/mini = 1,
		/obj/item/roller/holo = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/handheld_defibrillator = 1
		)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery/l,
		/obj/item/organ/internal/cyberimp/arm/medibeam,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

//////////////////// PARANORMAL ///////////////////

/datum/outfit/job/centcom/response_team/paranormal
	name = "RT Paranormal"
	rt_job = "Emergency Response Team Inquisitor"
	rt_mob_job = "ERT Paranormal"
	uniform = /obj/item/clothing/under/rank/chaplain
	back = /obj/item/storage/backpack/ert/security
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset/ert/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/storage/belt/security/sec
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	special_message = "Вы подчиняетесь непосредственно <span class='red'>назначенному корпорацией командиру</span>. \n Хоть вы и можете возражать ему, прямое подчинение крайне нежелательно. Исключениями являются случаи, когда ваш командир открыто действует против интересов НТ, или случаи, когда это требуется согласно приказаниям членов вашего Ордена с высшим саном. \n В случае его отсутствия или недееспособности, вам стоит прислушиваться к мнению члена отряда с самым высоким званием."

	backpack_contents = list(
		/obj/item/storage/box/zipties = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 1
		)

/datum/outfit/job/centcom/response_team/paranormal/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind)
		H.mind.isholy = TRUE

/datum/outfit/job/centcom/response_team/paranormal/amber
	name = "RT Paranormal (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/armor/vest/ert/security/paranormal
	head = /obj/item/clothing/head/helmet/ert/security/paranormal
	suit_store = /obj/item/gun/energy/gun/pdw9/ert
	r_pocket = /obj/item/nullrod

	hours_dif = 100
	ranks = list("Min" = "Искатель",
				"Med" = "Аколит",
				"Max" = "Дознаватель")

/datum/outfit/job/centcom/response_team/paranormal/red
	name = "RT Paranormal (Red)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal
	suit_store = /obj/item/gun/energy/gun/sibyl
	r_pocket = /obj/item/nullrod/ert
	glasses = /obj/item/clothing/glasses/night

	hours_dif = 200
	ranks = list("Min" = "Дознаватель",
				"Med" = "Коммисар",
				"Max" = "Инквизитор")

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 1
	)


	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

/datum/outfit/job/centcom/response_team/paranormal/gamma
	name = "RT Paranormal (Gamma)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots/advance
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	suit_store = /obj/item/gun/energy/gun/nuclear/sibyl
	l_pocket = /obj/item/grenade/clusterbuster/holy
	shoes = /obj/item/clothing/shoes/magboots/advance
	glasses = /obj/item/clothing/glasses/night
	r_pocket = /obj/item/nullrod/ert

	ranks = list("Min" = "Инквизитор",
				"Med" = "Инквизитор",
				"Max" = "Инквизитор")

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)

//////////////////// JANITORIAL ///////////////////

/datum/outfit/job/centcom/response_team/janitorial
	name = "RT Janitor"
	rt_job = "Emergency Response Team Janitor"
	rt_mob_job = "ERT Janitor"
	uniform = /obj/item/clothing/under/color/purple/sensor
	back = /obj/item/storage/backpack/ert/janitor
	belt = /obj/item/storage/belt/janitor/ert
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset/ert/alt
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	r_pocket = /obj/item/melee/classic_baton/telescopic
	backpack_contents = list(
		/obj/item/gun/energy/gun/pdw9/ert = 1,
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/storage/bag/trash = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/holosign_creator/janitor = 1,
		/obj/item/flashlight = 1,
		/obj/item/melee/flyswatter = 1)
	exp_type = EXP_TYPE_SERVICE
	ranks = list("Min" = "Очиститель",
				"Med" = "Очиститель",
				"Max" = "Очиститель")

/datum/outfit/job/centcom/response_team/janitorial/amber
	name = "RT Janitor (Amber)"
	shoes = /obj/item/clothing/shoes/galoshes
	suit = /obj/item/clothing/suit/armor/vest/ert/janitor
	head = /obj/item/clothing/head/helmet/ert/janitor
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/gas/sechailer

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/advmop)

/datum/outfit/job/centcom/response_team/janitorial/red
	name = "RT Janitor (Red)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/hardsuit/ert/janitor
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/scythe/tele
	mask = /obj/item/clothing/mask/gas/sechailer

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
	)


	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/janitorial,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old
	)

/datum/outfit/job/centcom/response_team/janitorial/gamma
	name = "RT Janitor (Gamma)"
	toggle_helmet = TRUE
	shoes = /obj/item/clothing/shoes/magboots/advance
	suit = /obj/item/clothing/suit/space/hardsuit/ert/gamma/janitor
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit_store = /obj/item/gun/energy/gun/pdw9/ert
	l_pocket = /obj/item/grenade/clusterbuster/cleaner
	r_pocket = /obj/item/scythe/tele

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8t = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/storage/bag/trash/bluespace = 1,
		/obj/item/reagent_containers/spray/cleaner = 1
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/advmop,
		/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus
	)

	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/death_alarm
	)
