GLOBAL_VAR_INIT(vox_raiders_radio_freq, PUBLIC_LOW_FREQ + rand(0, 8) * 2) //Random freq every round

/mob/living/carbon/human/proc/equip_vox_raider()
	equip_to_slot_or_del(new /obj/item/radio/headset(src), SLOT_HUD_RIGHT_EAR) //radio hedset with common freq, for communicate with station
	var/obj/item/radio/R = new /obj/item/radio/headset(src)
	R.set_frequency(GLOB.vox_raiders_radio_freq) //radio hedset with random vox freq, for raders communication
	equip_to_slot_or_del(R, SLOT_HUD_LEFT_EAR)

	equip_to_slot_or_del(new /obj/item/clothing/under/vox/vox_robes(src), SLOT_HUD_JUMPSUIT)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(src), SLOT_HUD_SHOES)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow/vox(src), SLOT_HUD_GLOVES)
	equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(src), SLOT_HUD_BELT)
	equip_to_slot_or_del(new /obj/item/storage/backpack/alien/satchel(src), SLOT_HUD_BACK)
	equip_to_slot_or_del(new /obj/item/flashlight(src), SLOT_HUD_RIGHT_STORE)
	equip_to_slot_or_del(new /obj/item/melee/classic_baton/telescopic(src), SLOT_HUD_LEFT_STORE)
	equip_to_slot_or_del(new /obj/item/tank/internals/nitrogen(src), SLOT_HUD_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox(src), SLOT_HUD_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/restraints/handcuffs/cable/zipties(src), SLOT_HUD_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/restraints/handcuffs/cable/zipties(src), SLOT_HUD_IN_BACKPACK)

	var/obj/item/card/id/syndicate/vox/W = new(src)
	W.name = "[real_name]'s Legitimate Human ID Card"
	W.assignment = "Trader"
	W.registered_name = real_name
	W.registered_user = src
	equip_to_slot_or_del(W, SLOT_HUD_WEAR_ID)

	return 1
