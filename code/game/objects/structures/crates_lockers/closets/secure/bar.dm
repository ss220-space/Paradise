/obj/structure/closet/secure_closet/cabinet/bar
	name = "booze cabinet"
	req_access = list(ACCESS_BAR)

/obj/structure/closet/secure_closet/cabinet/bar/get_ru_names()
    return list(
        NOMINATIVE = "шкаф с алкоголем",
        GENITIVE = "шкафа с алкоголем",
        DATIVE = "шкафу с алкоголем",
        ACCUSATIVE = "шкаф с алкоголем",
        INSTRUMENTAL = "шкафом с алкоголем",
        PREPOSITIONAL = "шкафе с алкоголем",
    )

/obj/structure/closet/secure_closet/cabinet/bar/populate_contents()
	for(var/pivo = 1 to 10)
		new /obj/item/reagent_containers/food/drinks/cans/beer(src)
