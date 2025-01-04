/*****************************Money bag********************************/

/obj/item/storage/bag/money
	name = "money bag"
	desc = "Просторный мешок из плотной ткани, украшенный крупным символом доллара. \
	Идеально подходит для хранения монет или банкнот. "

	ru_names = list(
		NOMINATIVE = "денежный мешок",
		GENITIVE = "денежного мешка",
		DATIVE = "денежному мешку",
		ACCUSATIVE = "денежный мешок",
		INSTRUMENTAL = "денежным мешком",
		PREPOSITIONAL = "денежном мешке",
	)
	icon_state = "moneybag"
	item_state = "moneybag"
	force = 10
	throwforce = 0
	resistance_flags = FLAMMABLE
	max_integrity = 100
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 40
	max_combined_w_class = 40
	can_hold = list(/obj/item/coin, /obj/item/stack/spacecash)


/obj/item/storage/bag/money/vault/populate_contents()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/adamantine(src)
