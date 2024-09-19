/obj/structure/closet/secure_closet/cabinet/bar
	name = "booze cabinet"
	req_access = list(ACCESS_BAR)

/obj/structure/closet/secure_closet/cabinet/bar/populate_contents()
	for(var/pivo = 1 to 10)
		new /obj/item/reagent_containers/food/drinks/cans/beer(src)
