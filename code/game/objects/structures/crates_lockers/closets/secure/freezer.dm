/obj/structure/closet/secure_closet/freezer
	desc = "Освинцованный защищённый холодильник, предназначенный для хранения скоропортящихся продуктов. \
			Оснащён электронным замком, который активируется с помощью ID-карты. Достаточно вместительный."

/obj/structure/closet/secure_closet/freezer/ex_act(var/severity)
	// IF INDIANA JONES CAN DO IT SO CAN YOU

	// Bomb in here? (using same search as space transits searching for nuke disk)
	var/list/bombs = search_contents_for(/obj/item/transfer_valve)
	if(!isemptylist(bombs)) // You're fucked.
		..(severity)


/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen cabinet"
	ru_names = list(
		NOMINATIVE = "шкаф для продуктов",
		GENITIVE = "шкафа для продуктов",
		DATIVE = "шкафу для продуктов",
		ACCUSATIVE = "шкаф для продуктов",
		INSTRUMENTAL = "шкафом для продуктов",
		PREPOSITIONAL = "шкафе для продуктов"
	)
	req_access = list(ACCESS_KITCHEN)
	icon_state = "kitchen"

/obj/structure/closet/secure_closet/freezer/kitchen/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/condiment/flour(src)
	new /obj/item/reagent_containers/food/condiment/rice(src)
	new /obj/item/reagent_containers/food/condiment/sugar(src)


/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance
	name = "maintenance refrigerator"
	desc = "Старый защищённый холодильник, предназначенный для хранения скоропортящихся продуктов. \
			Оснащён электронным замком, который активируется с помощью ID-карты. \
			Покрыт толстым слоем пыли."
	ru_names = list(
		NOMINATIVE = "старый холодильник",
		GENITIVE = "старого холодильника",
		DATIVE = "старому холодильнику",
		ACCUSATIVE = "старый холодильник",
		INSTRUMENTAL = "старым холодильником",
		PREPOSITIONAL = "старом холодильнике"
	)
	req_access = list()

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance/populate_contents()
	for(var/i = 0, i < 5, i++)
		new /obj/item/reagent_containers/food/condiment/milk(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/reagent_containers/food/condiment/soymilk(src)
	for(var/i = 0, i < 2, i++)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"
	ru_names = list(
		NOMINATIVE = "холодильник для мяса",
		GENITIVE = "холодильника для мяса",
		DATIVE = "холодильнику для мяса",
		ACCUSATIVE = "холодильник для мяса",
		INSTRUMENTAL = "холодильником для мяса",
		PREPOSITIONAL = "холодильнике для мяса"
	)
	icon_state = "fridge"
	overlay_unlocked = "f_unlocked"
	overlay_locked = "f_locked"

/obj/structure/closet/secure_closet/freezer/meat/populate_contents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/food/snacks/meat/humanoid/monkey(src)

/obj/structure/closet/secure_closet/freezer/meat/empty/populate_contents()
	return

/obj/structure/closet/secure_closet/freezer/meat/open
	req_access = null
	locked = FALSE

/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"
	ru_names = list(
		NOMINATIVE = "холодильник",
		GENITIVE = "холодильника",
		DATIVE = "холодильнику",
		ACCUSATIVE = "холодильник",
		INSTRUMENTAL = "холодильником",
		PREPOSITIONAL = "холодильнике"
	)
	icon_state = "fridge"

	overlay_unlocked = "f_unlocked"
	overlay_locked = "f_locked"

/obj/structure/closet/secure_closet/freezer/fridge/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/food/condiment/milk(src)
		new /obj/item/reagent_containers/food/condiment/soymilk(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/fridge/empty/populate_contents()
	return

/obj/structure/closet/secure_closet/freezer/fridge/open
	req_access = null
	locked = FALSE

/obj/structure/closet/secure_closet/freezer/vault
	name = "vault locker"
	desc = "Освинцованный защищённый шкафчик, предназначенный для хранения ценных предметов. \
			Оснащён электронным замком, который активируется с помощью ID-карты."
	ru_names = list(
		NOMINATIVE = "защищённый шкафчик (Хранилище)",
		GENITIVE = "защищённого шкафчика (Хранилище)",
		DATIVE = "защищённому шкафчику (Хранилище)",
		ACCUSATIVE = "защищённый шкафчик (Хранилище)",
		INSTRUMENTAL = "защищённым шкафчиком (Хранилище)",
		PREPOSITIONAL = "защищённом шкафчике (Хранилище)"
	)
	icon_state = "vault"
	req_access = list(ACCESS_HEADS_VAULT)


/obj/structure/closet/secure_closet/freezer/vault/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/stack/spacecash/c1000(src)
	for(var/i in 1 to 5)
		new /obj/item/stack/spacecash/c500(src)
	for(var/i in 1 to 6)
		new /obj/item/stack/spacecash/c200(src)
