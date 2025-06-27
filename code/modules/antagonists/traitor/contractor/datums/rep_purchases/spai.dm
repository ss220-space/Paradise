/**
  * # Rep Purchase - SPAI Kit
  */
/datum/rep_purchase/item/spai_kit
	name = "Набор СПИИ"
	description = "Усовершенствованная версия обычного ПИИ. Он отличается большим объёмом памяти и наличием специальных программ, \
			позволяющих, например, удалённо управлять шлюзами, вводить лечебные препараты в организм, видеть сквозь стены и так далее."
	cost = 2
	stock = 1
	item_type = /obj/item/storage/box/contractor/spai_kit
	refundable = TRUE
	refund_path = /obj/item/paicard_upgrade/unused

/obj/item/storage/box/contractor/spai_kit
	name = "Boxed Contractor SPAI"
	ru_names = list(
		NOMINATIVE = "набор СПИИ Контрактника",
		GENITIVE = "набора СПИИ Контрактника",
		DATIVE = "набору СПИИ Контрактника",
		ACCUSATIVE = "набор СПИИ Контрактника",
		INSTRUMENTAL = "набором СПИИ Контрактника",
		PREPOSITIONAL = "наборе СПИИ Контрактника"
	)
	gender = MALE
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/contractor/spai_kit/populate_contents()
	new /obj/item/paicard(src)
	new /obj/item/paicard_upgrade/unused(src)
	new /obj/item/screwdriver(src)
	new /obj/item/paper/pai_upgrade(src)
