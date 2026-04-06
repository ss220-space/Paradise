/obj/structure/closet/athletic_mixed
	name = "athletic wardrobe"
	desc = "Это устройство для хранения спортивной одежды."
	custom_door_overlay = "mixed"

/obj/structure/closet/athletic_mixed/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для спортивного гардероба",
        GENITIVE = "шкафчика для спортивного гардероба",
        DATIVE = "шкафчику для спортивного гардероба",
        ACCUSATIVE = "шкафчик для спортивного гардероба",
        INSTRUMENTAL = "шкафчиком для спортивного гардероба",
        PREPOSITIONAL = "шкафчике для спортивного гардероба",
    )

/obj/structure/closet/athletic_mixed/populate_contents()
	new /obj/item/clothing/under/shorts/grey(src)
	new /obj/item/clothing/under/shorts/black(src)
	new /obj/item/clothing/under/shorts/red(src)
	new /obj/item/clothing/under/shorts/blue(src)
	new /obj/item/clothing/under/shorts/green(src)
	new /obj/item/clothing/under/swimsuit/red(src)
	new /obj/item/clothing/under/swimsuit/black(src)
	new /obj/item/clothing/under/swimsuit/blue(src)
	new /obj/item/clothing/under/swimsuit/green(src)
	new /obj/item/clothing/under/swimsuit/purple(src)

/obj/structure/closet/boxinggloves
	name = "boxing gloves"
	desc = "Это устройство для хранения перчаток, используемых на боксерском ринге."

/obj/structure/closet/boxinggloves/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для боксерских перчаток",
        GENITIVE = "шкафчика для боксерских перчаток",
        DATIVE = "шкафчику для боксерских перчаток",
        ACCUSATIVE = "шкафчик для боксерских перчаток",
        INSTRUMENTAL = "шкафчиком для боксерских перчаток",
        PREPOSITIONAL = "шкафчике для боксерских перчаток",
    )

/obj/structure/closet/boxinggloves/populate_contents()
	new /obj/item/clothing/gloves/boxing/blue(src)
	new /obj/item/clothing/gloves/boxing/green(src)
	new /obj/item/clothing/gloves/boxing/yellow(src)
	new /obj/item/clothing/gloves/boxing(src)

/obj/structure/closet/masks
	name = "mask closet"
	desc = "ЭТО СКЛАДСКОЕ УСТРОЙСТВО ДЛЯ БОКСЕРСКИХ МАСОК!"

/obj/structure/closet/masks/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для боксерских масок",
        GENITIVE = "шкафчика для боксерских масок",
        DATIVE = "шкафчику для боксерских масок",
        ACCUSATIVE = "шкафчик для боксерских масок",
        INSTRUMENTAL = "шкафчиком для боксерских масок",
        PREPOSITIONAL = "шкафчике для боксерских масок",
    )

/obj/structure/closet/masks/populate_contents()
	new /obj/item/clothing/mask/luchador(src)
	new /obj/item/clothing/mask/luchador/rudos(src)
	new /obj/item/clothing/mask/luchador/tecnicos(src)

/obj/structure/closet/lasertag/red
	name = "red laser tag equipment"
	desc = "Это складское устройство для снаряжения лазертага."
	custom_door_overlay = "red"

/obj/structure/closet/lasertag/red/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для лазертага (красные)",
        GENITIVE = "шкафчика для лазертага (красные)",
        DATIVE = "шкафчику для лазертага (красные)",
        ACCUSATIVE = "шкафчик для лазертага (красные)",
        INSTRUMENTAL = "шкафчиком для лазертага (красные)",
        PREPOSITIONAL = "шкафчике для лазертага (красные)",
    )

/obj/structure/closet/lasertag/red/populate_contents()
	new /obj/item/gun/energy/laser/tag/red(src)
	new /obj/item/gun/energy/laser/tag/red(src)
	new /obj/item/gun/energy/laser/tag/red(src)
	new /obj/item/clothing/suit/redtag(src)
	new /obj/item/clothing/suit/redtag(src)
	new /obj/item/clothing/suit/redtag(src)
	new /obj/item/clothing/head/helmet/redtaghelm(src)

/obj/structure/closet/lasertag/blue
	name = "blue laser tag equipment"
	desc = "Это складское устройство для снаряжения лазертага."
	custom_door_overlay = "blue"

/obj/structure/closet/lasertag/blue/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для лазертага (синие)",
        GENITIVE = "шкафчика для лазертага (синие)",
        DATIVE = "шкафчику для лазертага (синие)",
        ACCUSATIVE = "шкафчик для лазертага (синие)",
        INSTRUMENTAL = "шкафчиком для лазертага (синие)",
        PREPOSITIONAL = "шкафчике для лазертага (синие)",
    )

/obj/structure/closet/lasertag/blue/populate_contents()
	new /obj/item/gun/energy/laser/tag/blue(src)
	new /obj/item/gun/energy/laser/tag/blue(src)
	new /obj/item/gun/energy/laser/tag/blue(src)
	new /obj/item/clothing/suit/bluetag(src)
	new /obj/item/clothing/suit/bluetag(src)
	new /obj/item/clothing/suit/bluetag(src)
	new /obj/item/clothing/head/helmet/bluetaghelm(src)
