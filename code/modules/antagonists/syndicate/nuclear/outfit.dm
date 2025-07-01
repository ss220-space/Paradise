/datum/outfit/admin/syndicate/operative
	name = "Syndicate Nuclear Operative (hardsuit)"
	toggle_helmet = TRUE
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/on
	belt = /obj/item/storage/belt/military
	mask = /obj/item/clothing/mask/gas/syndicate
	l_ear = /obj/item/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/magboots/syndie
	r_pocket = /obj/item/radio/uplink/nuclear
	l_pocket = /obj/item/pinpointer/advpinpointer
	l_hand = /obj/item/tank/jetpack/oxygen/harness
	gloves = /obj/item/clothing/gloves/combat/swat/syndicate
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi/syndi
	pda = /obj/item/pinpointer/nukeop
	implants = list(/obj/item/implant/explosive)
	internals_slot = ITEM_SLOT_SUITSTORE

	id_access = SYNDICATE_OPERATIVE



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

/datum/outfit/admin/syndicate/operative/loneop
	name = "Syndicate Nuclear Operative (Loneop)"
	r_pocket = /obj/item/radio/uplink/nuclear/loneop
	uplink_uses = null

/datum/outfit/admin/syndicate/operative/nuclear
	name = "Syndicate Nuclear Operative"
	toggle_helmet = FALSE
	suit = null
	belt = /obj/item/gun/projectile/automatic/pistol
	mask = /obj/item/clothing/mask/gas/syndicate
	shoes = /obj/item/clothing/shoes/combat
	l_pocket = null
	l_hand = null

	backpack_contents = list(
		/obj/item/storage/box/survival_syndi = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/crowbar/red = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/shoes/combat = 1
	)

/datum/outfit/admin/syndicate/operative/nuclear/reinf
	name = "Syndicate Nuclear Operative (reinf)"
	uplink_uses = 0

/datum/outfit/admin/syndicate/operative/nuclear/leader
	name = "Syndicate Nuclear Operative Leader"
	l_hand = /obj/item/nuclear_challenge
	id_access = SYNDICATE_OPERATIVE_LEADER

/datum/outfit/admin/syndicate/operative/nuclear/vox
	name = "Syndicate Nuclear Operative (vox)"
	mask = /obj/item/clothing/mask/gas/syndicate
	r_hand = /obj/item/tank/internals/emergency_oxygen/double/vox
	internals_slot = ITEM_SLOT_HAND_RIGHT

/datum/outfit/admin/syndicate/operative/nuclear/leader/vox
	name = "Syndicate Nuclear Operative Leader (vox)"
	mask = /obj/item/clothing/mask/gas/syndicate
	r_hand = /obj/item/tank/internals/emergency_oxygen/double/vox
	internals_slot = ITEM_SLOT_HAND_RIGHT

/datum/outfit/admin/syndicate/operative/nuclear/plasmaman
	name = "Syndicate Nuclear Operative (plasmaman)"
	mask = /obj/item/clothing/mask/gas/syndicate
	uniform = /obj/item/clothing/under/plasmaman/syndie
	head = /obj/item/clothing/head/helmet/space/plasmaman/syndie
	r_hand = /obj/item/tank/internals/plasmaman
	internals_slot = ITEM_SLOT_HAND_RIGHT
	backpack_contents = list(
		/obj/item/storage/box/survival_syndi = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/crowbar/red = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/shoes/combat = 1,
		/obj/item/extinguisher_refill = 2
	)

/datum/outfit/admin/syndicate/operative/nuclear/leader/plasmaman
	name = "Syndicate Nuclear Operative Leader (plasmaman)"
	mask = /obj/item/clothing/mask/gas/syndicate
	uniform = /obj/item/clothing/under/plasmaman/syndie
	head = /obj/item/clothing/head/helmet/space/plasmaman/syndie
	r_hand = /obj/item/tank/internals/plasmaman
	internals_slot = ITEM_SLOT_HAND_RIGHT
	backpack_contents = list(
		/obj/item/storage/box/survival_syndi = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/crowbar/red = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/shoes/combat = 1,
		/obj/item/extinguisher_refill = 2
	)

/datum/outfit/admin/syndicate/operative/freedom
	name = "Syndicate Freedom Operative"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/freedom
