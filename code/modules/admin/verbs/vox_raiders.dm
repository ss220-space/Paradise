GLOBAL_VAR_INIT(vox_raiders_radio_freq, PUBLIC_LOW_FREQ + rand(0, 8) * 2) //Random freq every round

/mob/living/carbon/human/proc/equip_vox_raider()
	equip_to_slot_or_del(new /obj/item/radio/headset(src), ITEM_SLOT_EAR_RIGHT) //radio hedset with common freq, for communicate with station
	var/obj/item/radio/R = new /obj/item/radio/headset(src)
	R.set_frequency(GLOB.vox_raiders_radio_freq) //radio hedset with random vox freq, for raders communication
	equip_to_slot_or_del(R, ITEM_SLOT_EAR_LEFT)

	equip_to_slot_or_del(new /obj/item/clothing/under/vox/vox_robes(src), ITEM_SLOT_CLOTH_INNER)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(src), ITEM_SLOT_FEET)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow/vox(src), ITEM_SLOT_GLOVES)
	equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(src), ITEM_SLOT_BELT)
	equip_to_slot_or_del(new /obj/item/storage/backpack/alien/satchel(src), ITEM_SLOT_BACK)
	equip_to_slot_or_del(new /obj/item/flashlight(src), ITEM_SLOT_POCKET_RIGHT)
	equip_to_slot_or_del(new /obj/item/melee/classic_baton/telescopic(src), ITEM_SLOT_POCKET_LEFT)
	equip_to_slot_or_del(new /obj/item/tank/internals/nitrogen(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/restraints/handcuffs/cable/zipties(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/restraints/handcuffs/cable/zipties(src), ITEM_SLOT_BACKPACK)

	var/obj/item/card/id/syndicate/vox/W = new(src)
	W.name = "[real_name]'s Legitimate Human ID Card"
	W.assignment = "Trader"
	W.registered_name = real_name
	W.registered_user = src
	equip_to_slot_or_del(W, ITEM_SLOT_ID)

	return 1
