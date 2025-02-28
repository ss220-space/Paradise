/**
  * # Rep Purchase - Contractor Hardsuit
  */
/datum/rep_purchase/item/contractor_hardsuit
	name = "ИКС Контрактника"
	description = "ИКС, оснащённый технологией \"Хамелеон\". В комплект также входит оборудование для поддержания жизнедеятельности. \
			ИКС выполнен в чёрно-золотых тонах и отличается компактностью, что позволяет легко носить его в сумке. \
			Передовые материалы обеспечивают надёжную защиту от внешних угроз, а шлем защищает от ярких вспышек."
	cost = 4 //free reskinned blood-red hardsuit with chameleon
	stock = 1
	item_type = /obj/item/storage/box/contractor/hardsuit

/obj/item/storage/box/contractor/hardsuit
	name = "Boxed Contractor Hardsuit"
	ru_names = list(
		NOMINATIVE = "набор ИКС Контрактника",
		GENITIVE = "набора ИКС Контрактника",
		DATIVE = "набору ИКС Контрактника",
		ACCUSATIVE = "набор ИКС Контрактника",
		INSTRUMENTAL = "набором ИКС Контрактника",
		PREPOSITIONAL = "наборе ИКС Контрактника"
	)
	gender = MALE
	icon_state = "box_of_doom"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/contractor, /obj/item/tank/internals/emergency_oxygen/engi/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/contractor/hardsuit/populate_contents()
	new /obj/item/clothing/suit/space/hardsuit/contractor(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
