/obj/structure/closet/secure_closet/cabinet/bar
	name = "booze cabinet"
	desc = "Деревянный шкаф, оборудованный электронным замком. \
			Предназначен для хранения алкоголя в недоступном для ассистентов месте."
	ru_names = list(
		NOMINATIVE = "шкаф для выпивки",
		GENITIVE = "шкафа для выпивки",
		DATIVE = "шкафу для выпивки",
		ACCUSATIVE = "шкаф для выпивки",
		INSTRUMENTAL = "шкафом для выпивки",
		PREPOSITIONAL = "шкафе для выпивки"
	)
	req_access = list(ACCESS_BAR)

/obj/structure/closet/secure_closet/cabinet/bar/populate_contents()
	for(var/pivo = 1 to 10)
		new /obj/item/reagent_containers/food/drinks/cans/beer(src)
