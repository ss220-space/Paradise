/**
  * # Rep Purchase - SPAI Kit
  */
/datum/rep_purchase/item/spai_kit
	name = "SPAI Kit"
	description = "A kit with your personal assistant. It comes with an increased amount of memory and special programs."
	cost = 2
	stock = 1
	item_type = /obj/item/storage/box/contractor/spai_kit
	refundable = TRUE
	refund_path = /obj/item/paicard_upgrade/unused

/obj/item/storage/box/contractor/spai_kit
	name = "Boxed Contractor SPAI"
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/contractor/spai_kit/populate_contents()
	new /obj/item/paicard(src)
	new /obj/item/paicard_upgrade/unused(src)
	new /obj/item/screwdriver(src)
	new /obj/item/paper/pai_upgrade(src)
