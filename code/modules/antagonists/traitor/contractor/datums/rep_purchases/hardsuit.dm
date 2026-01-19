/**
 * # Rep Purchase - Contractor Hardsuit
 */
/datum/rep_purchase/item/contractor_hardsuit
	name = "МЭК \"Специалист\""
	description = "Элитный МЭК, оснащённый технологией \"Хамелеон\". В комплект также входит оборудование для поддержания жизнедеятельности. \
			МЭК окрашен в классические для Контрактников цвета, при этом обеспечивает достойную защиту. Вы можете приобрести модули для \
			дальнейшего улучшения вашего МЭКа."
	cost = 2
	stock = 1
	item_type = /obj/item/mod/control/pre_equipped/contractor

/obj/item/storage/box/contractor/hardsuit
	name = "Boxed Contractor Hardsuit"
	gender = MALE
	icon_state = "box_of_doom"
	item_state = "syndie"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/contractor, /obj/item/tank/internals/emergency_oxygen/engi/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/contractor/hardsuit/get_ru_names()
	return list(
		NOMINATIVE = "набор МЭК \"Специалист\"",
		GENITIVE = "набора МЭК \"Специалист\"",
		DATIVE = "набору МЭК \"Специалист\"",
		ACCUSATIVE = "набор МЭК \"Специалист\"",
		INSTRUMENTAL = "набором МЭК \"Специалист\"",
		PREPOSITIONAL = "наборе МЭК \"Специалист\"",
	)

/obj/item/storage/box/contractor/hardsuit/populate_contents()
	new /obj/item/clothing/suit/space/hardsuit/contractor(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)


/datum/rep_purchase/item/scorpion_hook
	name = "Модуль крюк-кошки \"Скорпион\""
	description = "Модифицированный вариант крюк-кошки, сделанный с применением редспейс-технологий. Данный крюк \
			применяется исключительно против биологических целей. Мощные катушки притягивают жертву к пользователю на огромной скорости, \
			выбивая её из равновесия. Не спасает от падения с большой высоты."
	cost = 2
	stock = 1
	item_type = /obj/item/mod/module/scorpion_hook

/datum/rep_purchase/item/activation_upgrade
	name = "Модуль продвинутых актуаторов"
	description = "Набор обновленных актуаторов для МЭК, сделанных из пластитана. Данные актуаторы, еще официально не вышедшие на рынок, \
			позволяют пользователю активировать МЭК практически без каких либо задержек."
	cost = 2
	stock = 1
	item_type = /obj/item/mod/module/activation_upgrade/elite

