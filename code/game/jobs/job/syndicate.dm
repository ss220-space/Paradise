/datum/job/syndicateofficer
	title = "Syndicate Officer"
	flag = JOB_SYNDICATE
	department_flag = JOB_SYNDICATE // This gets its job as its own flag because admin jobs dont have flags
	total_positions = 5
	spawn_positions = 5
	supervisors = "the admins"
	selection_color = "#ff0000"
	access = list()
	minimal_access = list()
	admin_only = 1
	syndicate_command = 1
	outfit = /datum/outfit/job/syndicateofficer

/datum/job/syndicateofficer/get_access()
	return get_syndicate_access(title)

/datum/outfit/job/syndicateofficer
	name = "Syndicate Officer"
	jobtype = /datum/job/syndicateofficer

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/deathsquad/officer/syndie
	neck = /obj/item/clothing/neck/cloak/syndieadm
	back = /obj/item/storage/backpack
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	belt = /obj/item/gun/projectile/automatic/pistol/deagle/camo
	l_ear = /obj/item/radio/headset/syndicate/admin_officer
	pda = /obj/item/pinpointer/advpinpointer
	id = /obj/item/card/id/syndicate/command
	box = /obj/item/storage/box/survival/syndicate
	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/ammo_box/magazine/m50 = 2,
		/obj/item/clothing/shoes/magboots/syndie/advance = 1,
		/obj/item/lighter/zippo/gonzofist = 1,
		/obj/item/storage/box/matches = 1
	)
	implants = list(
		/obj/item/implant/dust
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

/datum/outfit/job/nuclear
	name = "Nuclear Operative"
	allow_backbag_choice = FALSE
	allow_loadout = FALSE
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/card/id/syndicate
	belt = /obj/item/gun/projectile/automatic/pistol
	box = /obj/item/storage/box/survival/syndicate
	pda = /obj/item/pinpointer/nukeop
	l_ear = /obj/item/radio/headset/syndicate/alt
	implants = list(/obj/item/implant/explosive)
	backpack_contents = list(/obj/item/radio/uplink/nuclear)

/datum/outfit/job/nuclear/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return

//	U.hidden_uplink.uplink_owner="[H.key]"

	if(H.dna.species.name == "Plasmaman")
		H.equip_or_collect(new /obj/item/extinguisher_refill(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/extinguisher_refill(H), slot_in_backpack)

	var/obj/item/radio/R = H.l_ear
	if(istype(R))
		R.set_frequency(SYND_FREQ)
	H.faction |= "syndicate"

/datum/outfit/job/infiltrator
	name = "Syndicate Infiltrator"
	allow_backbag_choice = FALSE
	allow_loadout = FALSE
	uniform = /obj/item/clothing/under/chameleon
	gloves = /obj/item/clothing/gloves/combat
			equip_to_slot_or_del(new /obj/item/flashlight(src), slot_in_backpack)
	belt = /obj/item/storage/belt/utility/full/multitool
	implants = list(/obj/item/implant/dust, /obj/item/implant/uplink/sit)
	l_ear = /obj/item/radio/headset/syndicate/syndteam
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	id = /obj/item/card/id/syndicate

/datum/outfit/job/infiltrator/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	if(visualsOnly)
		return
	if(flag_mgmt)
		U.hidden_uplink.uses = 2500
	else
		U.hidden_uplink.uses = num_tc

	var/obj/item/clothing/gloves/G = H.gloves
	if(istype(G))
		G.name = "black gloves"
		G.icon_state = "black"

	var/obj/item/radio/R = H.l_ear
	if(istype(R))
		R.set_frequency(SYNDTEAM_FREQ)

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_SYNDICATE,ACCESS_MAINT_TUNNELS,ACCESS_EXTERNAL_AIRLOCKS,ACCESS_MEDICAL,ACCESS_ENGINE,ACCESS_CARGO,ACCESS_RESEARCH), "Civilian", "id")
