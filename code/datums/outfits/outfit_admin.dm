// Used for 'select equipment'
// code/modules/admin/verbs/debug.dm 566

/datum/outfit/admin/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(!visualsOnly)
		H.mind?.assigned_role = name
		H.job = name


/proc/apply_to_card(obj/item/card/id/I, mob/living/carbon/human/H, list/access = list(), rank, special_icon)
	if(!istype(I) || !istype(H))
		return 0

	I.access = access
	I.registered_name = H.real_name
	I.rank = rank
	I.assignment = rank
	I.sex = capitalize(H.gender)
	I.age = H.age
	I.name = "[I.registered_name]'s ID Card ([I.assignment])"
	I.photo = get_id_photo(H)

	if(special_icon)
		I.icon_state = special_icon

/datum/outfit/admin/syndicate
	name = "Syndicate Agent"

	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/syndicate
	r_pocket = /obj/item/radio/uplink
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/flashlight = 1,
		/obj/item/card/emag = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1
	)

	var/id_access = "Syndicate Operative"
	var/uplink_uses = 100

/datum/outfit/admin/syndicate/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_syndicate_access(id_access), name, "syndie")

	var/obj/item/radio/uplink/U = H.r_store
	if(istype(U))
		U.hidden_uplink.uplink_owner = "[H.key]"
		U.hidden_uplink.uses = uplink_uses

	var/obj/item/radio/R = H.l_ear
	if(istype(R))
		R.set_frequency(SYND_FREQ)
	H.faction += "syndicate"

/datum/outfit/admin/syndicate_infiltrator
	name = "Syndicate Infiltrator"

/datum/outfit/admin/syndicate_infiltrator/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = H.equip_syndicate_infiltrator(0, 20, FALSE)
	H.sec_hud_set_ID()
	if(!visualsOnly)
		H.faction += "syndicate"

/datum/outfit/admin/syndicate/operative
	name = "Syndicate Nuclear Operative"
	toggle_helmet = TRUE
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	belt = /obj/item/storage/belt/military
	mask = /obj/item/clothing/mask/gas/syndicate
	l_ear = /obj/item/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/magboots/syndie
	r_pocket = /obj/item/radio/uplink/nuclear
	l_pocket = /obj/item/pinpointer/advpinpointer
	l_hand = /obj/item/tank/jetpack/oxygen/harness

	backpack_contents = list(
		/obj/item/storage/box/survival_syndi = 1,
		/obj/item/gun/projectile/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/crowbar/red = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/shoes/combat = 1
	)

/datum/outfit/admin/syndicate/operative/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/implant/explosive/E = new(H)
	E.implant(H)


/datum/outfit/admin/syndicate/operative/freedom
	name = "Syndicate Freedom Operative"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/freedom

/datum/outfit/admin/syndicate_strike_team
	name = "Syndicate Strike Team Commando"
	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack/security
	shoes =	/obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat/swat/syndicate
	l_ear = /obj/item/radio/headset/syndicate/alt/syndteam
	l_pocket = /obj/item/card/emag
	r_pocket = /obj/item/melee/energy/sword/saber/red
	id = /obj/item/card/id/syndicate
	box = /obj/item/storage/box/survival_syndi
	backpack_contents = list(
		/obj/item/radio/uplink/sst = 1,
		/obj/item/grenade/plastic/x4 = 2,
		/obj/item/reagent_containers/hypospray/combat/nanites = 1,
		/obj/item/gun/projectile/revolver = 1,
		/obj/item/ammo_box/speedloader/a357 = 1
	)
	implants = list(/obj/item/implant/dust)
	can_be_admin_equipped = FALSE

/datum/outfit/admin/syndicate_strike_team/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/card/id/syndicate/I = H.wear_id
	I.icon_state = "syndie"
	I.name = "[H.real_name]'s ID Card"
	I.assignment = "Syndicate Commando"
	I.access += get_syndicate_access(I.assignment)
	I.registered_name = H.real_name
	if(!visualsOnly)
		H.faction += "syndicate"

/datum/outfit/admin/syndicate_strike_team/officer
	name = "Syndicate Stirke Team Officer"
	pda = /obj/item/pinpointer

/datum/outfit/admin/syndicate_strike_team/officer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	.=..()
	H.back.contents += new /obj/item/disk/nuclear/unrestricted

/datum/outfit/admin/syndicate_strike_team/full_gear
	name = "Syndicate Strike Team Commando"
	can_be_admin_equipped = TRUE
	toggle_helmet = TRUE
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite/sst
	belt = /obj/item/storage/belt/military/sst
	shoes = /obj/item/clothing/shoes/magboots/syndie/advance
	mask = /obj/item/clothing/mask/gas/syndicate
	glasses = /obj/item/clothing/glasses/thermal/sunglasses
	l_hand = /obj/item/gun/projectile/automatic/l6_saw

	backpack_contents = list(
		/obj/item/tank/jetpack/oxygen/harness = 1,
		/obj/item/radio/uplink/sst = 1,
		/obj/item/ammo_box/magazine/mm556x45 = 1,
		/obj/item/grenade/plastic/x4 = 2,
		/obj/item/reagent_containers/hypospray/combat/nanites = 1,
		/obj/item/gun/projectile/revolver = 1,
		/obj/item/ammo_box/speedloader/a357 = 1
	)

/datum/outfit/admin/syndicate/spy
	name = "Syndicate Spy"
	uniform = /obj/item/clothing/under/suit_jacket/really_black
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	uplink_uses = 200
	id_access = "Syndicate Agent"

	implants = list(
		/obj/item/implant/dust
	)


/datum/outfit/admin/nt_vip
	name = "VIP Guest"

	uniform = /obj/item/clothing/under/suit_jacket/really_black
	back = /obj/item/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/that
	l_ear = /obj/item/radio/headset/ert
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1
	)

/datum/outfit/admin/nt_vip/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("VIP Guest"), "VIP Guest")
	H.sec_hud_set_ID()

/datum/outfit/admin/special_reaction_team
	name = "Special Reaction Team Member"

	uniform = /obj/item/clothing/under/fluff/jay_turtleneck
	suit = /obj/item/clothing/suit/storage/blueshield/srt
	back = /obj/item/storage/backpack/satchel_blueshield/srt
	belt = /obj/item/storage/belt/security/webbing/srt/full
	gloves = /obj/item/clothing/gloves/combat/swat
	shoes = /obj/item/clothing/shoes/combat/swat
	head = /obj/item/clothing/head/beret/centcom/officer/navy
	l_ear = /obj/item/radio/headset/ert/alt
	l_pocket = /obj/item/reagent_containers/hypospray/combat
	r_pocket = /obj/item/reagent_containers/food/snacks/candy/mre
	glasses = /obj/item/clothing/glasses/hud/blueshield
	id = /obj/item/card/id/centcom

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8/sp8ar = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/storage/box/responseteam = 1,
		/obj/item/gun/energy/gun/blueshield = 1,
		/obj/item/gun/projectile/automatic/proto = 1,
		/obj/item/ammo_box/magazine/smgm9mm = 4,
		/obj/item/shield/riot/tele = 1,
		/obj/item/suppressor = 1,
		/obj/item/CQC_manual = 1,
		/obj/item/storage/box/responseteam = 1
	)

	accessories = list(
		/obj/item/clothing/accessory/holster
	)

	implants = list(
		/obj/item/implant/mindshield/ert
	)

/datum/outfit/admin/special_reaction_team/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.head.desc = null
	H.head.name = "SRT beret"
	H.l_ear.desc = null
	H.l_ear.name = "SRT bowman headset"
	H.shoes.name = "SRT special shoes"
	H.w_uniform.name = "SRT uniform"


/datum/outfit/admin/special_reaction_team/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Special Reaction Team Member"), "Special Reaction Team Member")
	H.sec_hud_set_ID()


/datum/outfit/admin/nt_navy_captain
	name = "NT Navy Captain"

	uniform = /obj/item/clothing/under/rank/centcom/captain
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/rapier/centcomm
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/centcom/captain
	l_ear = /obj/item/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	backpack_contents = list(
		/obj/item/storage/box/centcomofficer = 1,
		/obj/item/gun/energy/pulse/pistol = 1,
		/obj/item/implanter/death_alarm = 1
	)
	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/dust
	)

/datum/outfit/admin/nt_navy_captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Captain"), "Nanotrasen Navy Captain")
	H.sec_hud_set_ID()

/datum/outfit/admin/nt_diplomat
	name = "NT Diplomat"

	uniform = /obj/item/clothing/under/rank/centcom/diplomatic
	back = /obj/item/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/radio/headset/centcom
	id = /obj/item/card/id/centcom
	r_pocket = /obj/item/lighter/zippo/nt_rep
	l_pocket = /obj/item/storage/fancy/cigarettes/dromedaryco
	pda = /obj/item/pda/centcom
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/implanter/death_alarm = 1,
	)
	implants = list(
		/obj/item/implant/mindshield/ert,
		/obj/item/implant/dust
	)

/datum/outfit/admin/nt_diplomat/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Representative"), "Nanotrasen Diplomat")
	H.sec_hud_set_ID() //No, it's recognized.

/datum/outfit/admin/nt_undercover
	name = "NT Undercover Operative"
	// Disguised NT special forces, sent to quietly eliminate or keep tabs on people in high positions (e.g: captain)

	uniform = /obj/item/clothing/under/color/random
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	l_ear = /obj/item/radio/headset/centcom
	id = /obj/item/card/id
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/flashlight = 1,
		/obj/item/pinpointer/crew = 1
	)
	implants = list(
		/obj/item/implant/dust
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/shield,
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/eyes/xray,
		/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus,
		/obj/item/organ/internal/cyberimp/arm/combat/centcom
	)

/datum/outfit/admin/nt_undercover/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("NT Undercover Operative"), JOB_TITLE_CIVILIAN)
	H.sec_hud_set_ID() // Force it to show as Civ on sec huds

	var/obj/item/radio/R = H.l_ear
	if(istype(R))
		R.name = "radio headset"
		R.icon_state = "headset"

/datum/outfit/admin/death_commando
	name = "NT Death Commando"
	toggle_helmet = TRUE
	uniform = /obj/item/clothing/under/rank/centcom_officer
	suit = /obj/item/clothing/suit/space/hardsuit/deathsquad
	back = /obj/item/storage/backpack/ert/security
	belt = /obj/item/gun/projectile/revolver/mateba
	gloves = /obj/item/clothing/gloves/combat/swat
	shoes = /obj/item/clothing/shoes/magboots/syndie/advance
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/shield/energy
	r_pocket = /obj/item/melee/energy/sword/saber
	l_hand = /obj/item/gun/energy/pulse
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	l_ear = /obj/item/radio/headset/alt
	id = /obj/item/card/id
	pda = /obj/item/pinpointer
	box = /obj/item/storage/box/responseteam

	backpack_contents = list(
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/reagent_containers/hypospray/combat/nanites = 1,
		/obj/item/grenade/plastic/x4 = 1,
		/obj/item/ammo_box/speedloader/a357 = 1
	)

	implants = list(/obj/item/implant/mindshield/ert)

/datum/outfit/admin/death_commando/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/radio/R = H.l_ear
	R.set_frequency(DTH_FREQ)
	R.requires_tcomms = FALSE
	R.instant = TRUE
	R.freqlock = TRUE

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Death Commando"), "Death Commando", "deathsquad")
		I.photo = get_id_photo(H, custom_job = JOB_TITLE_REPRESENTATIVE) // They should go die with a good photo instead of assistants grey shorts xD
	H.sec_hud_set_ID()

/datum/outfit/admin/death_commando/officer
	name = "NT Death Commando officer"
	can_be_admin_equipped = FALSE

/datum/outfit/admin/death_commando/officer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	.=..()
	H.back.contents += new /obj/item/disk/nuclear/unrestricted

/datum/outfit/admin/pirate
	name = "Space Pirate"

	uniform = /obj/item/clothing/under/pirate
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/combat/swat/syndicate
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id
	r_hand = /obj/item/melee/energy/sword/pirate
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/pirate/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), name)

/datum/outfit/admin/pirate/first_mate
	name = "Space Pirate First Mate"

	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/bandana

/datum/outfit/admin/pirate/captain
	name = "Space Pirate Captain"

	suit = /obj/item/clothing/suit/pirate_black
	head = /obj/item/clothing/head/pirate

/datum/outfit/admin/vox
	name = "Vox Raider"
	uniform = /obj/item/clothing/under/vox/vox_robes
	suit = /obj/item/clothing/suit/space/vox/carapace
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/yellow/vox
	shoes = /obj/item/clothing/shoes/magboots/vox
	head = /obj/item/clothing/head/helmet/space/vox/carapace
	mask = /obj/item/clothing/mask/gas/syndicate
	l_ear = /obj/item/radio/headset/syndicate
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/card/id/syndicate/vox
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double/vox
	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/restraints/handcuffs/cable/zipties = 1,
		/obj/item/flash = 1,
		/obj/item/gun/energy/noisecannon = 1
	)

/datum/outfit/admin/vox/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(isvoxarmalis(H))
		. = ..()
	else
		H.equip_vox_raider()
		H.regenerate_icons()

/datum/outfit/admin/vox/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), SPECIES_VOX_ARMALIS, "syndie")

/datum/outfit/admin/tunnel_clown
	name = "Tunnel Clown"
	toggle_helmet = TRUE
	uniform = /obj/item/clothing/under/rank/clown
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/card/id
	l_pocket = /obj/item/reagent_containers/food/snacks/grown/banana
	r_pocket = /obj/item/bikehorn
	r_hand = /obj/item/twohanded/fireaxe
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana = 1,
		/obj/item/grenade/clown_grenade = 1,
		/obj/item/melee/baton/security/cattleprod = 1,
		/obj/item/stock_parts/cell/super = 1,
		/obj/item/bikehorn/rubberducky = 1
	)

/datum/outfit/admin/tunnel_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS), "Tunnel Clown")

/datum/outfit/admin/mime_assassin
	name = "Mime Assassin"

	uniform = /obj/item/clothing/under/mime
	suit = /obj/item/clothing/suit/suspenders
	back = /obj/item/storage/backpack/mime
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/beret
	mask = /obj/item/clothing/mask/gas/mime
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/card/id/syndicate
	pda = /obj/item/pda/mime
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 1,
		/obj/item/toy/crayon/mime = 1,
		/obj/item/gun/projectile/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/suppressor = 1,
		/obj/item/card/emag = 1,
		/obj/item/radio/uplink = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/mime_assassin/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/sexymime
		mask = /obj/item/clothing/mask/gas/mime/sexy

/datum/outfit/admin/mime_assassin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = JOB_TITLE_MIME
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MIME, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS), JOB_TITLE_MIME)
	H.sec_hud_set_ID()

/datum/outfit/admin/greytide
	name = "Greytide"

	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/brown
	mask = /obj/item/clothing/mask/gas
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id
	l_hand = /obj/item/storage/toolbox/mechanical
	r_hand = /obj/item/flag/grey
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/greytide/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Greytide")

/datum/outfit/admin/greytide/leader
	name = "Greytide Leader"

	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/yellow

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/clothing/head/welding = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/greytide/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..(H, TRUE)
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Greytide Leader")

/datum/outfit/admin/greytide/xeno
	name = "Greytide Xeno"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/xenos
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/xenos
	glasses = /obj/item/clothing/glasses/thermal
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/toy/toy_xeno
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/clothing/head/welding = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/greytide/xeno/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..(H, TRUE)
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Legit Xenomorph")

/datum/outfit/admin/musician
	name = "Musician"

	uniform = /obj/item/clothing/under/singerb
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/singerb
	gloves = /obj/item/clothing/gloves/color/white
	l_ear = /obj/item/radio/headset
	r_ear = /obj/item/clothing/ears/headphones
	pda = /obj/item/pda
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
		/obj/item/instrument/violin = 1,
		/obj/item/instrument/piano_synth = 1,
		/obj/item/instrument/guitar = 1,
		/obj/item/instrument/eguitar = 1,
		/obj/item/instrument/accordion = 1,
		/obj/item/instrument/saxophone = 1,
		/obj/item/instrument/trombone = 1,
		/obj/item/instrument/harmonica = 1
	)

/datum/outfit/admin/musician/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Bard")

	var/obj/item/clothing/ears/headphones/P = r_ear
	if(istype(P))
		P.attack_self(H) // activate them, display musical notes effect

/datum/outfit/admin/soviet
	name = "Soviet Generic"
	var/list/rank_list = list()
	gloves = /obj/item/clothing/gloves/combat/swat/syndicate
	uniform = /obj/item/clothing/under/soviet
	back = /obj/item/storage/backpack/satchel
	head = /obj/item/clothing/head/sovietsidecap
	id = /obj/item/card/id
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/alt/soviet
	box = /obj/item/storage/box/soviet

/datum/outfit/admin/soviet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.rename_character(null, "[rank_list.len ? pick(rank_list) : "[H.gender==FEMALE ? pick(GLOB.first_names_female) : pick(GLOB.first_names_male)]"] [H.gender==FEMALE ? pick(GLOB.last_names_female) : pick(GLOB.last_names)]")

	H.add_language(LANGUAGE_NEO_RUSSIAN)
	H.set_default_language(GLOB.all_languages[LANGUAGE_NEO_RUSSIAN])

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), name)
	H.sec_hud_set_ID()

/datum/outfit/admin/soviet/tourist
	name = "Soviet Tourist"
	gloves = null
	box = /obj/item/storage/box/survival

/datum/outfit/admin/soviet/conscript
	name = "Soviet Conscript"
	rank_list = list("Рядовой", "Ефрейтор", "Младший сержант", "Сержант")
	gloves = null
	r_pocket = /obj/item/flashlight/seclite
	r_hand = /obj/item/gun/projectile/shotgun/boltaction
	belt = /obj/item/gun/projectile/revolver/nagant

	backpack_contents = list(
		/obj/item/ammo_box/speedloader/a762 = 4
	)

/datum/outfit/admin/soviet/soldier
	name = "Soviet Soldier"
	rank_list = list("Младший сержант", "Сержант", "Старший сержант", "Старшина", "Прапорщик", "Старший прапорщик", "Младший лейтенант", "Лейтенант")
	suit = /obj/item/clothing/suit/sovietcoat
	glasses = /obj/item/clothing/glasses/sunglasses
	r_pocket = /obj/item/flashlight/seclite
	belt = /obj/item/gun/projectile/automatic/pistol/APS

	backpack_contents = list(
		/obj/item/lighter = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 1,
		/obj/item/ammo_box/magazine/pistolm9mm = 2
	)

/datum/outfit/admin/soviet/officer
	name = "Soviet Officer"
	rank_list = list("Старший лейтенант","Капитан", "Майор", "Подполковник", "Полковник")
	suit = /obj/item/clothing/suit/sovietcoat/officer
	uniform = /obj/item/clothing/under/sovietofficer
	head = /obj/item/clothing/head/sovietofficerhat
	glasses = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/gun/projectile/revolver/mateba
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/flashlight/seclite

	backpack_contents = list(
		/obj/item/lighter/zippo = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/ammo_box/speedloader/a357 = 2
	)

/datum/outfit/admin/soviet/marine
	name = "Soviet Marine"
	rank_list = list("Сержант", "Старший сержант", "Старшина", "Прапорщик", "Старший прапорщик", "Младший лейтенант", "Лейтенант")
	toggle_helmet = TRUE
	suit = /obj/item/clothing/suit/space/hardsuit/soviet
	head = null
	mask = /obj/item/clothing/mask/gas
	glasses = /obj/item/clothing/glasses/night
	belt = /obj/item/storage/belt/military/assault/soviet/full
	l_pocket = /obj/item/card/emag
	r_pocket = /obj/item/melee/baton/telescopic
	l_hand = /obj/item/gun/projectile/automatic/ak814
	suit_store = /obj/item/tank/internals/emergency_oxygen/double

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/APS = 1,
		/obj/item/ammo_box/magazine/pistolm9mm = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/lighter/zippo = 1
	)

/datum/outfit/admin/soviet/marine/captain
	name = "Soviet Marine Captain"
	rank_list = list("Старший лейтенант", "Капитан", "Майор", "Подполковник", "Полковник")
	uniform = /obj/item/clothing/under/sovietofficer
	suit = /obj/item/clothing/suit/space/hardsuit/soviet/commander

	backpack_contents = list(
		/obj/item/gun/projectile/revolver/mateba = 1,
		/obj/item/ammo_box/speedloader/a357 = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/lighter/zippo = 1
	)

/datum/outfit/admin/soviet/admiral
	name = "Soviet Admiral"
	rank_list = list("Адмирал")
	uniform = /obj/item/clothing/under/sovietadmiral
	head = /obj/item/clothing/head/sovietadmiralhat
	belt = /obj/item/gun/projectile/revolver/mateba
	l_ear = /obj/item/radio/headset/syndicate
	r_ear = /obj/item/radio/headset/alt/soviet
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	l_pocket = /obj/item/melee/baton/telescopic
	backpack_contents = list(
		/obj/item/ammo_box/speedloader/a357 = 3
	)

/datum/outfit/admin/solgov_rep
	name = "Solar Federation Representative"

	uniform = /obj/item/clothing/under/solgov/rep
	back = /obj/item/storage/backpack/satchel
	glasses = /obj/item/clothing/glasses/hud/security/night
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/radio/headset/ert/alt/solgov
	id = /obj/item/card/id/silver
	r_pocket = /obj/item/lighter/zippo/blue
	l_pocket = /obj/item/storage/fancy/cigarettes/cigpack_robustgold
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/storage/box/responseteam = 1,
		/obj/item/implanter/dust = 1,
		/obj/item/implanter/death_alarm = 1,
		/obj/item/stamp/solgov = 1,
	)

/datum/outfit/admin/solgov_rep/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), name, "lifetimeid")
	H.sec_hud_set_ID()


/datum/outfit/admin/solgov
	name = "Solar Federation Marine (Bulldog)"
	uniform = /obj/item/clothing/under/solgov
	suit = /obj/item/clothing/suit/armor/bulletproof
	back = /obj/item/storage/backpack/ert/solgov
	belt = /obj/item/storage/belt/military/assault/marines/full
	suit_store = /obj/item/gun/projectile/automatic/shotgun/bulldog
	head = /obj/item/clothing/head/soft/solgov
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	gloves = /obj/item/clothing/gloves/combat/swat/syndicate
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/ert/alt/solgov
	id = /obj/item/card/id
	r_pocket = /obj/item/flashlight/seclite
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/storage/box/responseteam = 1,
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/whetstone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/survival = 1,
		/obj/item/gun/projectile/automatic/pistol/m1911 = 1,
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus,
		/obj/item/organ/internal/cyberimp/eyes/hud/security
	)
	var/is_tsf_lieutenant = FALSE

/datum/outfit/admin/solgov/cats
	name = "Solar Federation Marine (CATS)"
	suit_store = /obj/item/gun/projectile/automatic/cats
	belt = /obj/item/storage/belt/military/assault/marines/cats/full
	l_pocket = /obj/item/ammo_box/magazine/m45

/datum/outfit/admin/solgov/elite
	name = "Solar Federation Specops Marine"
	is_tsf_lieutenant = FALSE
	uniform = /obj/item/clothing/under/solgov/elite
	suit = /obj/item/clothing/suit/space/hardsuit/ert/solgov
	suit_store = /obj/item/gun/projectile/automatic/ar
	head = /obj/item/clothing/head/soft/solgov/elite
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/storage/belt/military/assault/marines/elite/full
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/responseteam = 1,
		/obj/item/clothing/shoes/magboots/advance = 1,
		/obj/item/whetstone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/survival = 1,
		/obj/item/gun/projectile/automatic/pistol/m1911 = 1
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus,
		/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened,
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/cyberimp/eyes/shield
	)

/datum/outfit/admin/solgov/elite/lieutenant
	name = "Solar Federation Specops Lieutenant"
	uniform = /obj/item/clothing/under/solgov/command/elite
	suit = /obj/item/clothing/suit/space/hardsuit/ert/solgov/command
	head = /obj/item/clothing/head/beret/solgov/command/elite
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/melee/baton/security/loaded
	l_hand = null
	suit_store = /obj/item/gun/projectile/automatic/pistol/deagle
	l_pocket = /obj/item/pinpointer/advpinpointer
	l_ear = /obj/item/radio/headset/ert/alt/commander/solgov
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/responseteam = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/clothing/shoes/magboots/advance = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/survival = 1,
		/obj/item/ammo_box/magazine/m50 = 3
	)
	is_tsf_lieutenant = TRUE

/datum/outfit/admin/solgov/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(is_tsf_lieutenant)
		H.real_name = "Лейтенант [H.gender==FEMALE ? pick(GLOB.last_names_female) : pick(GLOB.last_names)]"
	else
		H.real_name = "[pick("Младший Сержант", "Сержант", "Старший Сержант", "Старшина", "Прапорщик", "Старший Прапорщик")] [H.gender==FEMALE ? pick(GLOB.last_names_female) : pick(GLOB.last_names)]"
	H.name = H.real_name
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), name, "lifetimeid")
	H.sec_hud_set_ID()

/datum/outfit/admin/sol_trader
	name = "Sol Trader"

	uniform = /obj/item/clothing/under/rank/cargotech
	back = /obj/item/storage/backpack/industrial
	belt = /obj/item/melee/baton
	head = /obj/item/clothing/head/soft
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/supply
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/hand_labeler = 1,
		/obj/item/hand_labeler_refill = 1
	)

/datum/outfit/admin/sol_trader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_TRADE_SOL, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS), name)
	H.sec_hud_set_ID()

/datum/outfit/admin/chrono
	name = "Chrono Legionnaire"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/chronos
	back = /obj/item/chrono_eraser
	gloves = /obj/item/clothing/gloves/combat/swat
	shoes = /obj/item/clothing/shoes/magboots/advance
	head = /obj/item/clothing/head/helmet/space/chronos
	mask = /obj/item/clothing/mask/gas/syndicate
	glasses = /obj/item/clothing/glasses/night
	id = /obj/item/card/id/syndicate
	suit_store = /obj/item/tank/internals/emergency_oxygen/double

/datum/outfit/admin/chrono/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses() + get_all_centcom_access(), name, "syndie")

/datum/outfit/admin/spacegear
	name = "Standard Space Gear"

	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/space
	back = /obj/item/tank/jetpack/oxygen
	shoes = /obj/item/clothing/shoes/magboots
	head = /obj/item/clothing/head/helmet/space
	mask = /obj/item/clothing/mask/breath
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id

/datum/outfit/admin/spacegear/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(istype(H.back, /obj/item/tank/jetpack))
		var/obj/item/tank/jetpack/J = H.back
		J.turn_on()
		J.toggle_internals(H)

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Space Explorer")

/datum/outfit/admin/hardsuit
	name = "Hardsuit Generic"
	toggle_helmet = TRUE
	back = /obj/item/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/magboots
	id = /obj/item/card/id

/datum/outfit/admin/hardsuit/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(istype(H.back, /obj/item/tank/jetpack))
		var/obj/item/tank/jetpack/J = H.back
		J.turn_on()
		J.toggle_internals(H)

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Hardsuit Tester")

/datum/outfit/admin/hardsuit/engineer
	name = "Engineer Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/engine

/datum/outfit/admin/hardsuit/ce
	name = "CE Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/engine/elite
	shoes = /obj/item/clothing/shoes/magboots/advance

/datum/outfit/admin/hardsuit/mining
	name = "Mining Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/mining

/datum/outfit/admin/hardsuit/syndi
	name = "Syndi Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	shoes = /obj/item/clothing/shoes/magboots/syndie

/datum/outfit/admin/hardsuit/wizard
	name = "Wizard Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/wizard/shielded
	shoes = /obj/item/clothing/shoes/magboots/wizard

/datum/outfit/admin/hardsuit/medical
	name = "Medical Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/medical

/datum/outfit/admin/hardsuit/atmos
	name = "Atmos Hardsuit"
	suit = /obj/item/clothing/suit/space/hardsuit/engine/atmos


/datum/outfit/admin/tournament
	name = "Tournament Generic"
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/helmet/thunderdome
	r_pocket = /obj/item/grenade/smokebomb
	l_hand = /obj/item/kitchen/knife
	r_hand = /obj/item/gun/energy/pulse/destroyer

/datum/outfit/admin/tournament/red
	name = "Tournament Standard Red"
	uniform = /obj/item/clothing/under/color/red

/datum/outfit/admin/tournament/green
	name = "Tournament Standard Green"
	uniform = /obj/item/clothing/under/color/green

/datum/outfit/admin/tournament_gangster //gangster are supposed to fight each other. --rastaf0
	name = "Tournament Gangster"

	uniform = /obj/item/clothing/under/det
	suit = /obj/item/clothing/suit/storage/det_suit
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/det_hat
	glasses = /obj/item/clothing/glasses/thermal/monocle
	l_pocket = /obj/item/ammo_box/speedloader/a357
	r_hand = /obj/item/gun/projectile/automatic/proto

/datum/outfit/admin/tournament_chef //Steven Seagal FTW
	name = "Tournament Chef"

	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/chefhat
	l_pocket = /obj/item/kitchen/knife
	r_pocket = /obj/item/kitchen/knife
	l_hand = /obj/item/kitchen/knife
	r_hand = /obj/item/kitchen/rollingpin

/datum/outfit/admin/tournament_janitor
	name = "Tournament Janitor"

	uniform = /obj/item/clothing/under/rank/janitor
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/black
	l_hand = /obj/item/reagent_containers/glass/bucket
	backpack_contents = list(
		/obj/item/grenade/chem_grenade/cleaner = 2,
		/obj/item/stack/tile/plasteel = 7
	)

/datum/outfit/admin/tournament_janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/reagent_containers/R = H.l_hand
	if(istype(R))
		R.reagents.add_reagent("water", 70)

/datum/outfit/admin/survivor
	name = "Survivor"

	uniform = /obj/item/clothing/under/overalls
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/latex
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/survival = 1
	)

/datum/outfit/admin/survivor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	for(var/obj/item/I in H.contents)
		if(!istype(I, /obj/item/implant))
			I.add_mob_blood(H)

	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Survivor")

/datum/outfit/admin/masked_killer
	name = "Masked Killer"

	uniform = /obj/item/clothing/under/overalls
	suit = /obj/item/clothing/suit/apron
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/latex
	shoes = /obj/item/clothing/shoes/white
	head = /obj/item/clothing/head/welding
	mask = /obj/item/clothing/mask/surgical
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/card/id/syndicate
	l_pocket = /obj/item/kitchen/knife
	r_pocket = /obj/item/scalpel
	r_hand = /obj/item/twohanded/fireaxe
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/masked_killer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	for(var/obj/item/I in H.contents)
		if(!istype(I, /obj/item/implant))
			I.add_mob_blood(H)

	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Masked Killer", "syndie")

/datum/outfit/admin/singuloth_knight
	name = "Singuloth Knight"
	toggle_helmet = TRUE
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/space/hardsuit/singuloth
	back = /obj/item/storage/backpack/satchel
	l_hand = /obj/item/twohanded/knighthammer
	belt = /obj/item/claymore/ceremonial
	gloves = /obj/item/clothing/gloves/combat/swat
	shoes = /obj/item/clothing/shoes/magboots
	mask = /obj/item/clothing/mask/breath
	l_ear = /obj/item/radio/headset/ert
	glasses = /obj/item/clothing/glasses/meson/cyber
	id = /obj/item/card/id
	suit_store = /obj/item/tank/internals/oxygen
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/singuloth_knight/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Singuloth Knight")

/datum/outfit/admin/dark_lord
	name = "Dark Lord"
	toggle_helmet = TRUE
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/syndicate
	l_hand = /obj/item/twohanded/dualsaber/red
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
	)

/datum/outfit/admin/dark_lord/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/clothing/suit/hooded/chaplain_hoodie/C = H.wear_suit
	if(istype(C))
		C.name = "dark lord robes"
		C.hood.name = "dark lord hood"

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Dark Lord", "syndie")


/datum/outfit/admin/ancient_vampire
	name = "Ancient Vampire"

	uniform = /obj/item/clothing/under/victsuit/red
	suit = /obj/item/clothing/suit/draculacoat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/under/color/black = 1
	)


/datum/outfit/admin/ancient_vampire/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/clothing/suit/hooded/chaplain_hoodie/C = new(H.loc)
	if(istype(C))
		C.name = "ancient robes"
		C.hood.name = "ancient hood"
		H.equip_to_slot_or_del(C, ITEM_SLOT_BACKPACK)

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Ancient One", "data")

	if(!H.mind)
		return

	H.mind.make_vampire()
	var/datum/antagonist/vampire/V = H.mind.has_antag_datum(/datum/antagonist/vampire)

	if(!V)	// Just in case
		return

	V.bloodusable = 9999
	V.bloodtotal = 9999
	H.mind.offstation_role = TRUE
	V.add_subclass(SUBCLASS_ANCIENT, FALSE)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/shapeshift/bats)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/shapeshift/hellhound)
	H.force_gene_block(GLOB.jumpblock, TRUE)
	H.gene_stability = 100

/datum/outfit/admin/wizard
	name = "Blue Wizard"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/wizard
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id
	r_pocket = /obj/item/teleportation_scroll
	l_hand = /obj/item/twohanded/staff
	r_hand = /obj/item/spellbook
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1
	)

/datum/outfit/admin/wizard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Wizard")

/datum/outfit/admin/wizard/red
	name = "Red Wizard"

	suit = /obj/item/clothing/suit/wizrobe/red
	head = /obj/item/clothing/head/wizard/red

/datum/outfit/admin/wizard/marisa
	name = "Marisa Wizard"

	suit = /obj/item/clothing/suit/wizrobe/marisa
	shoes = /obj/item/clothing/shoes/sandal/marisa
	head = /obj/item/clothing/head/wizard/marisa

/datum/outfit/admin/wizard/arch
	name = "Arch Wizard"

	suit = /obj/item/clothing/suit/wizrobe/magusred
	head = /obj/item/clothing/head/wizard/magus
	belt = /obj/item/storage/belt/wands/full
	l_hand = null
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/clothing/suit/space/hardsuit/wizard/arch/shielded = 1,
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/kitchen/knife/ritual  = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/head/wizard/red = 1
	)

/datum/outfit/admin/wizard/arch/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/spellbook/B = H.r_hand
	if(istype(B))
		B.owner = H // force-bind it so it can never be stolen, no matter what.
		B.name = "Archwizard Spellbook"
		B.uses = 50
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Arch Wizard")

/datum/outfit/admin/dark_priest
	name = "Dark Priest"
	toggle_helmet = TRUE
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/syndicate
	r_hand = /obj/item/nullrod/armblade
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
	)
	implants = list(
		/obj/item/implant/dust
	)

/datum/outfit/admin/dark_priest/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Dark Priest", "syndie")
	var/obj/item/nullrod/armblade/B = H.r_hand
	if(istype(B))
		B.force = 20
		B.name = "blessing of the reaper"
		B.desc = "Sometimes, someone's just gotta die."
	var/obj/item/radio/headset/R = H.l_ear
	if(istype(R))
		ADD_TRAIT(R, TRAIT_NODROP, INNATE_TRAIT)

