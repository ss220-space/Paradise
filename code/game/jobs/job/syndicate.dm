/datum/job/syndicateofficer
	title = JOB_TITLE_SYNDICATE_OFFICER
	flag = JOB_FLAG_SYNDICATE
	department_flag = JOB_FLAG_SYNDICATE // This gets its job as its own flag because admin jobs dont have flags
	department = STATION_DEPARTMENT_OTHER
	total_positions = 5
	spawn_positions = 5
	supervisors = "Администраторами"
	selection_color = "#4c1e1e"
	access = list()
	minimal_access = list()
	admin_only = 1
	syndicate_command = 1
	outfit = /datum/outfit/job/syndicateofficer
	insurance_type = INSURANCE_TYPE_NONE
	skill_levels = list(
		/datum/skill/combat/guns = SKILL_LEVEL_ADVANCED,
		/datum/skill/combat/melee = SKILL_LEVEL_ADVANCED,
		/datum/skill/combat/bows = SKILL_LEVEL_BASIC,
		/datum/skill/engineering/building = SKILL_LEVEL_BASIC,
		/datum/skill/engineering/electrician = SKILL_LEVEL_BASIC,
		/datum/skill/engineering/atmos = SKILL_LEVEL_BASIC,
		/datum/skill/general/carrying = SKILL_LEVEL_BASIC,
		/datum/skill/general/mech_drive = SKILL_LEVEL_BASIC,
		/datum/skill/general/mod_use = SKILL_LEVEL_BASIC,
		/datum/skill/general/mixing = SKILL_LEVEL_BASIC,
		/datum/skill/general/cooking = SKILL_LEVEL_BASIC,
		/datum/skill/medical/heal = SKILL_LEVEL_ADVANCED,
		/datum/skill/medical/genetic = SKILL_LEVEL_BASIC,
		/datum/skill/medical/virusology = SKILL_LEVEL_BASIC,
		/datum/skill/research/research = SKILL_LEVEL_BASIC,
		/datum/skill/research/mech_construct = SKILL_LEVEL_BASIC,
		/datum/skill/research/xenobiology = SKILL_LEVEL_BASIC,
		/datum/skill/service/botany = SKILL_LEVEL_BASIC,
		/datum/skill/service/cleaning = SKILL_LEVEL_BASIC,
		/datum/skill/service/mining = SKILL_LEVEL_BASIC,
	)

/datum/job/syndicateofficer/get_access()
	return get_syndicate_access(title)

/datum/outfit/job/syndicateofficer
	name = JOB_TITLE_RU_SYNDICATE_OFFICER
	jobtype = /datum/job/syndicateofficer

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/deathsquad/officer/syndie
	neck = /obj/item/clothing/neck/cloak/syndieadm
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret
	gloves = /obj/item/clothing/gloves/combat/swat/syndicate
	shoes = /obj/item/clothing/shoes/combat
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	belt = /obj/item/gun/projectile/automatic/pistol/deagle
	l_ear = /obj/item/radio/headset/syndicate/admin_officer
	pda = /obj/item/pinpointer/advpinpointer
	id = /obj/item/card/id/syndicate/command
	box = /obj/item/storage/box/survival/survival_syndi
	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/ammo_box/magazine/m50 = 2,
		/obj/item/clothing/shoes/magboots/syndie/advance = 1,
		/obj/item/lighter/zippo/gonzofist = 1,
		/obj/item/storage/box/matches = 1,
	)
	implants = list(
		/obj/item/implant/dust,
	)

/datum/outfit/job/syndicateofficer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/implant/uplink/admin/U = new /obj/item/implant/uplink/admin(H)
	U.implant(H)
	U.hidden_uplink.uses = 2500
	H.faction += "syndicate"
	var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
	opshud.join_hud(H.mind.current)
	H.mind?.offstation_role = TRUE
	set_antag_hud(H.mind.current, "hudoperative")
	H.regenerate_icons()
