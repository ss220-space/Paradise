/**
  * # Rep Purchase - Contractor Hardsuit
  */
/datum/rep_purchase/item/contractor_hardsuit
	name = "Contractor Hardsuit"
	description = "A top-tier Hardsuit developed with cooperation of Cybersun Industries and the Gorlex Marauders, a favorite of Syndicate Contractors. \
	Hardsuit comes with a pre-installed SCORPION module - a hardlight hook, allowing you to to forcefully pull a target towards you. \
	In addition, it has an in-built chameleon system, allowing you to disguise your hardsuit to the most common variations on your mission area."
	cost = 6 //free reskinned blood-red hardsuit with hook
	stock = 1
	item_type = /obj/item/storage/box/contractor/hardsuit

/obj/item/storage/box/contractor/hardsuit
	name = "Boxed Contractor Hardsuit"
	icon_state = "box_of_doom"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/contractor, /obj/item/tank/internals/emergency_oxygen/engi/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/contractor/hardsuit/New()
	..()
	new /obj/item/clothing/suit/space/hardsuit/contractor(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
