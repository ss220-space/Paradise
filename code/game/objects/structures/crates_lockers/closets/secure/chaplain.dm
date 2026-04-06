/obj/structure/closet/secure_closet/chaplain
	name = "chapel wardrobe"
	desc = "Запираемый шкафчик для религиозной одежды, одобренной компанией Nanotrasen."
	req_access = list(ACCESS_CHAPEL_OFFICE)
	icon_state = "chaplain"

/obj/structure/closet/secure_closet/chaplain/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик священника",
        GENITIVE = "шкафчика священника",
        DATIVE = "шкафчику священника",
        ACCUSATIVE = "шкафчик священника",
        INSTRUMENTAL = "шкафчиком священника",
        PREPOSITIONAL = "шкафчике священника",
    )

/obj/structure/closet/secure_closet/chaplain/populate_contents()
	new /obj/item/storage/backpack/cultpack(src)
	new /obj/item/soulstone/anybody/purified/chaplain(src)
	new /obj/structure/constructshell/holy(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/gold(src)
	new /obj/item/clothing/gloves/ring/gold(src)
	new /obj/item/storage/garmentbag/chaplain(src)
	new /obj/item/shield/riot/templar(src)

