
//////////////////////
//		Cakes		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sliceable/carrotcake
	name = "carrot cake"
	desc = "Любимый десерт одного хитроумного кролика. И это не ложь."
	ru_names = list(
		NOMINATIVE = "морковный торт",
		GENITIVE = "морковного торта",
		DATIVE = "морковному торту",
		ACCUSATIVE = "морковный торт",
		INSTRUMENTAL = "морковным тортом",
		PREPOSITIONAL = "морковном торте"
	)
	icon_state = "carrotcake"
	slice_path = /obj/item/reagent_containers/food/snacks/carrotcakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#FFD675"
	list_reagents = list("nutriment" = 20, "oculine" = 10, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 2, "морковки" = 1)
	foodtype = SUGAR | GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/carrotcakeslice
	name = "carrot cake slice"
	desc = "Морковный кусочек морковного торта. Морковь полезна для глаз! И это тоже не ложь."
	ru_names = list(
		NOMINATIVE = "кусочек морковного торта",
		GENITIVE = "кусочка морковного торта",
		DATIVE = "кусочку морковного торта",
		ACCUSATIVE = "кусочек морковного торта",
		INSTRUMENTAL = "кусочком морковного торта",
		PREPOSITIONAL = "кусочке морковного торта"
	)
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD675"
	tastes = list("тортика" = 5, "сахара" = 2, "морковки" = 1)
	foodtype = SUGAR | GRAIN | VEGETABLES


/obj/item/reagent_containers/food/snacks/sliceable/braincake
	name = "brain cake"
	desc = "Мягкая тортоподобная масса."
	ru_names = list(
		NOMINATIVE = "торт из мозгов",
		GENITIVE = "торта из мозгов",
		DATIVE = "торту из мозгов",
		ACCUSATIVE = "торт из мозгов",
		INSTRUMENTAL = "тортом из мозгов",
		PREPOSITIONAL = "торте из мозгов"
	)
	icon_state = "braincake"
	slice_path = /obj/item/reagent_containers/food/snacks/braincakeslice
	slices_num = 5
	filling_color = "#E6AEDB"
	bitesize = 3
	list_reagents = list("protein" = 10, "nutriment" = 10, "mannitol" = 10, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 2, "мозгов" = 1)
	foodtype = SUGAR | GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/braincakeslice
	name = "brain cake slice"
	desc = "Позвольте рассказать вам кое-что о мозгах. ОНИ ВКУСНЫЕ."
	ru_names = list(
		NOMINATIVE = "кусочек торта из мозгов",
		GENITIVE = "кусочка торта из мозгов",
		DATIVE = "кусочку торта из мозгов",
		ACCUSATIVE = "кусочек торта из мозгов",
		INSTRUMENTAL = "кусочком торта из мозгов",
		PREPOSITIONAL = "кусочке торта из мозгов"
	)
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#E6AEDB"
	tastes = list("тортика" = 5, "сахара" = 2, "мозгов" = 1)
	foodtype = SUGAR | GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/sliceable/cheesecake
	name = "cheese cake"
	desc = "ОПАСНО сырный."
	ru_names = list(
		NOMINATIVE = "чизкейк",
		GENITIVE = "чизкейка",
		DATIVE = "чизкейку",
		ACCUSATIVE = "чизкейк",
		INSTRUMENTAL = "чизкейком",
		PREPOSITIONAL = "чизкейке"
	)
	icon_state = "cheesecake"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5
	filling_color = "#FAF7AF"
	bitesize = 3
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("тортика" = 4, "сырного крема" = 3)
	foodtype = SUGAR | GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/cheesecakeslice
	name = "cheese cake slice"
	desc = "Кусочек чистой сырной удовлетворённости."
	ru_names = list(
		NOMINATIVE = "кусочек чизкейка",
		GENITIVE = "кусочка чизкейка",
		DATIVE = "кусочку чизкейка",
		ACCUSATIVE = "кусочек чизкейка",
		INSTRUMENTAL = "кусочком чизкейка",
		PREPOSITIONAL = "кусочке чизкейка"
	)
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAF7AF"
	tastes = list("тортика" = 4, "сырного крема" = 3)
	foodtype = SUGAR | GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/sliceable/plaincake
	name = "vanilla cake"
	desc = "Обычный торт, и это не ложь."
	ru_names = list(
		NOMINATIVE = "ванильный торт",
		GENITIVE = "ванильного торта",
		DATIVE = "ванильному торту",
		ACCUSATIVE = "ванильный торт",
		INSTRUMENTAL = "ванильным тортом",
		PREPOSITIONAL = "ванильном торте"
	)
	icon_state = "plaincake"
	slice_path = /obj/item/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#F7EDD5"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("тортика" = 5, "ванили" = 1, "сахара" = 2)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/plaincakeslice
	name = "vanilla cake slice"
	desc = "Просто кусочек торта, всем хватит."
	ru_names = list(
		NOMINATIVE = "кусочек ванильного торта",
		GENITIVE = "кусочка ванильного торта",
		DATIVE = "кусочку ванильного торта",
		ACCUSATIVE = "кусочек ванильного торта",
		INSTRUMENTAL = "кусочком ванильного торта",
		PREPOSITIONAL = "кусочке ванильного торта"
	)
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#F7EDD5"
	tastes = list("тортика" = 5, "ванили" = 1, "сахара" = 2)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/sliceable/orangecake
	name = "orange cake"
	desc = "Торт с апельсинами."
	ru_names = list(
		NOMINATIVE = "апельсиновый торт",
		GENITIVE = "апельсинового торта",
		DATIVE = "апельсиновому торту",
		ACCUSATIVE = "апельсиновый торт",
		INSTRUMENTAL = "апельсиновым тортом",
		PREPOSITIONAL = "апельсиновом торте"
	)
	icon_state = "orangecake"
	slice_path = /obj/item/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#FADA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 2, "апельсинов" = 2)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/orangecakeslice
	name = "orange cake slice"
	desc = "Просто кусочек торта, всем хватит."
	ru_names = list(
		NOMINATIVE = "кусочек апельсинового торта",
		GENITIVE = "кусочка апельсинового торта",
		DATIVE = "кусочку апельсинового торта",
		ACCUSATIVE = "кусочек апельсинового торта",
		INSTRUMENTAL = "кусочком апельсинового торта",
		PREPOSITIONAL = "кусочке апельсинового торта"
	)
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	tastes = list("тортика" = 5, "сахара" = 2, "апельсинов" = 2)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/sliceable/bananacake
	name = "banana cake"
	desc = "Торт с бананами."
	ru_names = list(
		NOMINATIVE = "банановый торт",
		GENITIVE = "бананового торта",
		DATIVE = "банановому торту",
		ACCUSATIVE = "банановый торт",
		INSTRUMENTAL = "банановым тортом",
		PREPOSITIONAL = "банановом торте"
	)
	icon_state = "bananacake"
	slice_path = /obj/item/reagent_containers/food/snacks/bananacakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#FADA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 2, "бананов" = 2)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/bananacakeslice
	name = "banana cake slice"
	desc = "Просто кусочек торта, всем хватит."
	ru_names = list(
		NOMINATIVE = "кусочек бананового торта",
		GENITIVE = "кусочка бананового торта",
		DATIVE = "кусочку бананового торта",
		ACCUSATIVE = "кусочек бананового торта",
		INSTRUMENTAL = "кусочком бананового торта",
		PREPOSITIONAL = "кусочке бананового торта"
	)
	icon_state = "bananacake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	tastes = list("тортика" = 5, "сахара" = 2, "бананов" = 2)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/sliceable/limecake
	name = "lime cake"
	desc = "Торт с лаймом."
	ru_names = list(
		NOMINATIVE = "лаймовый торт",
		GENITIVE = "лаймового торта",
		DATIVE = "лаймовому торту",
		ACCUSATIVE = "лаймовый торт",
		INSTRUMENTAL = "лаймовым тортом",
		PREPOSITIONAL = "лаймовом торте"
	)
	icon_state = "limecake"
	bitesize = 3
	slice_path = /obj/item/reagent_containers/food/snacks/limecakeslice
	slices_num = 5
	filling_color = "#CBFA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 2, "невыносимой горечи" = 2)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/limecakeslice
	name = "lime cake slice"
	desc = "Просто кусочек торта, всем хватит."
	ru_names = list(
		NOMINATIVE = "кусочек лаймового торта",
		GENITIVE = "кусочка лаймового торта",
		DATIVE = "кусочку лаймового торта",
		ACCUSATIVE = "кусочек лаймового торта",
		INSTRUMENTAL = "кусочком лаймового торта",
		PREPOSITIONAL = "кусочке лаймового торта"
	)
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#CBFA8E"
	tastes = list("тортика" = 5, "сахара" = 2, "невыносимой горечи" = 2)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/sliceable/lemoncake
	name = "lemon cake"
	desc = "Торт с лимоном."
	ru_names = list(
		NOMINATIVE = "лимонный торт",
		GENITIVE = "лимонного торта",
		DATIVE = "лимонному торту",
		ACCUSATIVE = "лимонный торт",
		INSTRUMENTAL = "лимонным тортом",
		PREPOSITIONAL = "лимонном торте"
	)
	icon_state = "lemoncake"
	slice_path = /obj/item/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#FAFA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 2, "кислинки" = 2)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/lemoncakeslice
	name = "lemon cake slice"
	desc = "Просто кусочек торта, всем хватит."
	ru_names = list(
		NOMINATIVE = "кусочек лимонного торта",
		GENITIVE = "кусочка лимонного торта",
		DATIVE = "кусочку лимонного торта",
		ACCUSATIVE = "кусочек лимонного торта",
		INSTRUMENTAL = "кусочком лимонного торта",
		PREPOSITIONAL = "кусочке лимонного торта"
	)
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAFA8E"
	tastes = list("тортика" = 5, "сахара" = 2, "кислинки" = 2)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "chocolate cake"
	desc = "Просто шоколадный торт."
	ru_names = list(
		NOMINATIVE = "шоколадный торт",
		GENITIVE = "шоколадного торта",
		DATIVE = "шоколадному торту",
		ACCUSATIVE = "шоколадный торт",
		INSTRUMENTAL = "шоколадным тортом",
		PREPOSITIONAL = "шоколадном торте"
	)
	icon_state = "chocolatecake"
	slice_path = /obj/item/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#805930"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 1, "шоколада" = 4)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/chocolatecakeslice
	name = "chocolate cake slice"
	desc = "Просто кусочек торта, всем хватит."
	ru_names = list(
		NOMINATIVE = "кусочек шоколадного торта",
		GENITIVE = "кусочка шоколадного торта",
		DATIVE = "кусочку шоколадного торта",
		ACCUSATIVE = "кусочек шоколадного торта",
		INSTRUMENTAL = "кусочком шоколадного торта",
		PREPOSITIONAL = "кусочке шоколадного торта"
	)
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#805930"
	tastes = list("тортика" = 5, "сахара" = 1, "шоколада" = 4)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "birthday cake"
	desc = "С Днём Рождения..."
	ru_names = list(
		NOMINATIVE = "торт на день рождения",
		GENITIVE = "торта на день рождения",
		DATIVE = "торту на день рождения",
		ACCUSATIVE = "торт на день рождения",
		INSTRUMENTAL = "тортом на день рождения",
		PREPOSITIONAL = "торте на день рождения"
	)
	icon_state = "birthdaycake"
	slice_path = /obj/item/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5
	filling_color = "#FFD6D6"
	bitesize = 3
	list_reagents = list("nutriment" = 20, "sprinkles" = 10, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 1)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/birthdaycakeslice
	name = "birthday cake slice"
	desc = "Кусочек вашего дня рождения."
	ru_names = list(
		NOMINATIVE = "кусочек праздничного торта",
		GENITIVE = "кусочка праздничного торта",
		DATIVE = "кусочку праздничного торта",
		ACCUSATIVE = "кусочек праздничного торта",
		INSTRUMENTAL = "кусочком праздничного торта",
		PREPOSITIONAL = "кусочке праздничного торта"
	)
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD6D6"
	tastes = list("тортика" = 5, "сахара" = 1)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/sliceable/applecake
	name = "apple cake"
	desc = "Торт с яблоком в центре."
	ru_names = list(
		NOMINATIVE = "яблочный торт",
		GENITIVE = "яблочного торта",
		DATIVE = "яблочному торту",
		ACCUSATIVE = "яблочный торт",
		INSTRUMENTAL = "яблочным тортом",
		PREPOSITIONAL = "яблочном торте"
	)
	icon_state = "applecake"
	slice_path = /obj/item/reagent_containers/food/snacks/applecakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#EBF5B8"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("тортика" = 5, "сахара" = 1, "яблока" = 1)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/applecakeslice
	name = "apple cake slice"
	desc = "Кусочек райского торта."
	ru_names = list(
		NOMINATIVE = "кусочек яблочного торта",
		GENITIVE = "кусочка яблочного торта",
		DATIVE = "кусочку яблочного торта",
		ACCUSATIVE = "кусочек яблочного торта",
		INSTRUMENTAL = "кусочком яблочного торта",
		PREPOSITIONAL = "кусочке яблочного торта"
	)
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#EBF5B8"
	tastes = list("тортика" = 5, "сахара" = 1, "яблока" = 1)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/sliceable/slimepie
	name = "slime pie"
	desc = "Буб-боб-блоб-плоб-поп. Можно разрезать."
	ru_names = list(
		NOMINATIVE = "слаймовый пирог",
		GENITIVE = "слаймового пирога",
		DATIVE = "слаймовому пирогу",
		ACCUSATIVE = "слаймовый пирог",
		INSTRUMENTAL = "слаймовым пирогом",
		PREPOSITIONAL = "слаймовом пироге"
	)
	icon_state = "slimepie"
	slice_path = /obj/item/reagent_containers/food/snacks/slimepieslice
	slices_num = 5
	bitesize = 3
	filling_color = "#00d9ff"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("slime" = 5, "сахара" = 1, "желе" = 1)
	foodtype = SUGAR | MEAT | FRUIT

/obj/item/reagent_containers/food/snacks/slimepieslice
	name = "slime pie slice"
	desc = "Буб-боб-блоб-плоб-поп."
	ru_names = list(
		NOMINATIVE = "кусочек слаймового пирога",
		GENITIVE = "кусочка слаймового пирога",
		DATIVE = "кусочку слаймового пирога",
		ACCUSATIVE = "кусочек слаймового пирога",
		INSTRUMENTAL = "кусочком слаймового пирога",
		PREPOSITIONAL = "кусочке слаймового пирога"
	)
	icon_state = "slimepieslice"
	trash = /obj/item/trash/plate
	filling_color = "#00d9ff"
	tastes = list("slime" = 5, "сахара" = 1, "желе" = 1)
	foodtype = SUGAR | MEAT | FRUIT

/obj/item/reagent_containers/food/snacks/sliceable/choccherrycake
	name = "Chocolate - cherry cake"
	desc = "Ещё один торт, однако."
	ru_names = list(
		NOMINATIVE = "шоколадно-вишнёвый торт",
		GENITIVE = "шоколадно-вишнёвого торта",
		DATIVE = "шоколадно-вишнёвому торту",
		ACCUSATIVE = "шоколадно-вишнёвый торт",
		INSTRUMENTAL = "шоколадно-вишнёвым тортом",
		PREPOSITIONAL = "шоколадно-вишнёвом торте"
	)
	icon_state = "choccherrycake"
	slice_path = /obj/item/reagent_containers/food/snacks/choccherrycakeslice
	slices_num = 6
	bitesize = 3
	filling_color = "#5e1706"
	tastes = list("вишни" = 5, "сахара" = 1, "шоколада" = 1)
	list_reagents = list("nutriment" = 10, "sugar" = 35, "cocoa" = 4)
	foodtype = SUGAR | FRUIT | GRAIN

/obj/item/reagent_containers/food/snacks/choccherrycakeslice
	name = "Chocolate - cherry cake's slice"
	desc = "Кусочек ещё одного торта. Погодите, что?"
	ru_names = list(
		NOMINATIVE = "кусочек шоколадно-вишнёвого торта",
		GENITIVE = "кусочка шоколадно-вишнёвого торта",
		DATIVE = "кусочку шоколадно-вишнёвого торта",
		ACCUSATIVE = "кусочек шоколадно-вишнёвого торта",
		INSTRUMENTAL = "кусочком шоколадно-вишнёвого торта",
		PREPOSITIONAL = "кусочке шоколадно-вишнёвого торта"
	)
	icon_state = "choccherrycake_s"
	trash = /obj/item/trash/plate
	filling_color = "#5e1706"
	foodtype = SUGAR | FRUIT | GRAIN

/obj/item/reagent_containers/food/snacks/sliceable/noel
	name = "Buche de Noel"
	desc = "Что?"
	ru_names = list(
		NOMINATIVE = "Бюш де Ноэль",
		GENITIVE = "Бюш де Ноэля",
		DATIVE = "Бюш де Ноэлю",
		ACCUSATIVE = "Бюш де Ноэль",
		INSTRUMENTAL = "Бюш де Ноэлем",
		PREPOSITIONAL = "Бюш де Ноэле"
	)
	icon_state = "noel"
	trash = /obj/item/trash/tray
	slice_path = /obj/item/reagent_containers/food/snacks/noelslice
	slices_num = 5
	filling_color = "#5e1706"
	tastes = list("шоколада" = 3, "сахара" = 2, "яиц" = 1, "ягод" = 2)
	list_reagents = list("nutriment" = 6, "plantmatter" = 2, "cocoa" = 2, "cream" = 3, "sugar" = 15, "berryjuice" = 3)
	foodtype = SUGAR | FRUIT | GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/noelslice
	name = "Noel's slice"
	desc = "Кусочек чего?"
	ru_names = list(
		NOMINATIVE = "кусочек Ноэля",
		GENITIVE = "кусочка Ноэля",
		DATIVE = "кусочку Ноэля",
		ACCUSATIVE = "кусочек Ноэля",
		INSTRUMENTAL = "кусочком Ноэля",
		PREPOSITIONAL = "кусочке Ноэля"
	)
	icon_state = "noel_s"
	trash = /obj/item/trash/plate
	filling_color = "#5e1706"
	bitesize = 2
	foodtype = SUGAR | FRUIT | GRAIN | DAIRY

//////////////////////
//		Cookies		//
//////////////////////

/obj/item/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "ПЕЧЕНЬЕ!!!"
	ru_names = list(
		NOMINATIVE = "печенье",
		GENITIVE = "печенья",
		DATIVE = "печенью",
		ACCUSATIVE = "печенье",
		INSTRUMENTAL = "печеньем",
		PREPOSITIONAL = "печенье"
	)
	icon_state = "COOKIE!!!"
	bitesize = 1
	filling_color = "#DBC94F"
	list_reagents = list("nutriment" = 1, "sugar" = 1, "hot_coco" = 5 )
	tastes = list("печенья" = 1, "хрустящего шоколада" = 1)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "В каждом печенье – истинное пророчество!"
	ru_names = list(
		NOMINATIVE = "печенье с предсказанием",
		GENITIVE = "печенья с предсказанием",
		DATIVE = "печенью с предсказанием",
		ACCUSATIVE = "печенье с предсказанием",
		INSTRUMENTAL = "печеньем с предсказанием",
		PREPOSITIONAL = "печенье с предсказанием"
	)
	icon_state = "fortune_cookie"
	filling_color = "#E8E79E"
	list_reagents = list("nutriment" = 3)
	trash = /obj/item/paper/fortune
	tastes = list("печенья" = 1)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Прямо как делала твоя младшая сестра."
	ru_names = list(
		NOMINATIVE = "сахарное печенье",
		GENITIVE = "сахарного печенья",
		DATIVE = "сахарному печенью",
		ACCUSATIVE = "сахарное печенье",
		INSTRUMENTAL = "сахарным печеньем",
		PREPOSITIONAL = "сахарном печенье"
	)
	icon_state = "sugarcookie"
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	tastes = list("сахара" = 1)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/gingercookie
	name = "ginger cookie"
	desc = "Прямо как делала твоя бабушка."
	ru_names = list(
		NOMINATIVE = "имбирное печенье",
		GENITIVE = "имбирного печенья",
		DATIVE = "имбирному печенью",
		ACCUSATIVE = "имбирное печенье",
		INSTRUMENTAL = "имбирным печеньем",
		PREPOSITIONAL = "имбирном печенье"
	)
	icon_state = "ginger_man"
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	tastes = list("сахара" = 1)
	foodtype = SUGAR | GRAIN

/obj/item/reagent_containers/food/snacks/gingercookie/ball
	icon_state = "ginger_ball"

/obj/item/reagent_containers/food/snacks/gingercookie/heart
	icon_state = "ginger_heart"

/obj/item/reagent_containers/food/snacks/gingercookie/home
	icon_state = "ginger_home"

/obj/item/reagent_containers/food/snacks/gingercookie/tree
	icon_state = "ginger_tree"

/obj/item/reagent_containers/food/snacks/gingercookie/cane
	icon_state = "ginger_cane"

/obj/item/reagent_containers/food/snacks/gingercookie/mitten
	icon_state = "ginger_mitten"

//////////////////////
//		Pies		//
//////////////////////

/obj/item/reagent_containers/food/snacks/pie
	name = "banana cream pie"
	desc = "Прямо как дома, на планете клоунов! ХОНК!"
	ru_names = list(
		NOMINATIVE = "банановый кремовый пирог",
		GENITIVE = "бананового кремового пирога",
		DATIVE = "банановому кремовому пирогу",
		ACCUSATIVE = "банановый кремовый пирог",
		INSTRUMENTAL = "банановым кремовым пирогом",
		PREPOSITIONAL = "банановом кремовом пироге"
	)
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#FBFFB8"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "banana" = 5, "vitamin" = 2)
	tastes = list("пирога" = 1)
	foodtype = SUGAR | GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message(
		span_warning("[capitalize(declent_ru(NOMINATIVE))] разлетелся."),
		span_warning("Вы слышите шлепок.")
		)
	qdel(src)

/obj/item/reagent_containers/food/snacks/meatpie
	name = "meat-pie"
	desc = "Старинный рецепт парикмахеров, очень вкусно!"
	ru_names = list(
		NOMINATIVE = "мясной пирог",
		GENITIVE = "мясного пирога",
		DATIVE = "мясному пирогу",
		ACCUSATIVE = "мясной пирог",
		INSTRUMENTAL = "мясным пирогом",
		PREPOSITIONAL = "мясном пироге"
	)
	icon_state = "meatpie"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("пирога" = 1, "мяса" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/meatpie/human
	list_reagents = list("nutriment" = 9, "protein" = 3)
	tastes = list("пирога" = 2, "солёного мяса" = 1, "запахом человеческого мяса" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/vulpkanin
	list_reagents = list("nutriment" = 7, "protein" = 5)
	tastes = list("пирога" = 2, "солёного мяса" = 2, "запахом мяса вульпы" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/tajaran
	list_reagents = list("nutriment" = 9, "protein" = 3)
	tastes = list("пирога" = 2, "солёного мяса" = 1, "запахом мяса таяры" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/unathi
	list_reagents = list("nutriment" = 8, "protein" = 3, "zessulblood" = 1)
	tastes = list("пирога" = 2, "chiken meat" = 1, "запахом мяса унатха" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/drask
	list_reagents = list("nutriment" = 7, "protein" = 3, "ice" = 2)
	tastes = list("пирога" = 2, "солёного мяса" = 1, "запахом мяса драска" = 1, "льда" = 2)

/obj/item/reagent_containers/food/snacks/meatpie/grey
	list_reagents = list("nutriment" = 9, "protein" = 2, "mannitol" = 1)
	tastes = list("пирога" = 2, "солёного мяса" = 1, "запахом мяса грея" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/skrell
	list_reagents = list("nutriment" = 9, "protein" = 2, "water" = 1)
	tastes = list("пирога" = 2, "watery meat" = 1, "запахом мяса скрелла" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/vox
	list_reagents = list("nutriment" = 8, "protein" = 3, "toxin" = 1)
	tastes = list("пирога" = 2, "chiken meat" = 1, "запахом мяса вокса" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/slime
	list_reagents = list("sugar" = 4, "slimejelly" = 8)
	tastes = list("пирога" = 2, "sweet jelly" = 1, "slime meat odor" = 1)
	foodtype = GRAIN | MEAT | SUGAR

/obj/item/reagent_containers/food/snacks/meatpie/wryn
	list_reagents = list("nutriment" = 8, "protein" = 1, "sugar" = 3)
	tastes = list("пирога" = 2, "sweet meat" = 1, "запахом мяса врина" = 1)
	foodtype = GRAIN | MEAT | SUGAR

/obj/item/reagent_containers/food/snacks/meatpie/kidan
	list_reagents = list("nutriment" = 8, "protein" = 3, "blood" = 1)
	tastes = list("пирога" = 2, "bug meat odor" = 1, "запахом мяса кидана" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/nian
	list_reagents = list("nutriment" = 8, "protein" = 1, "phosphorus" = 3)
	tastes = list("пирога" = 2, "bug meat odor" = 1, "запахом мяса ниан" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/diona
	list_reagents = list("plantmatter" = 5, "protein" = 3)
	tastes = list("пирога" = 2, "vegetables" = 1, "stik" = 1, "запахом дионы" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/meatpie/monkey
	list_reagents = list("nutriment" = 5, "protein" = 3)
	tastes = list("пирога" = 2, "солёного мяса" = 1, "запахом мяса обезьяны" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/farwa
	list_reagents = list("nutriment" = 5, "protein" = 1)
	tastes = list("пирога" = 2, "солёного мяса" = 1, "запахом мяса фарвы" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/wolpin
	list_reagents = list("nutriment" = 5, "protein" = 3)
	tastes = list("пирога" = 2, "солёного мяса" = 1, "запахом мяса вульпина" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/neara
	list_reagents = list("nutriment" = 5, "protein" = 1, "water" = 2)
	tastes = list("пирога" = 2, "watery meat" = 1, "запахом мяса неары" = 1)

/obj/item/reagent_containers/food/snacks/meatpie/stok
	list_reagents = list("nutriment" = 5, "protein" = 2, "zessulblood" = 1)
	tastes = list("пирога" = 2, "солёного мяса" = 1, "курицы" = 1, "запах мяса стока" = 1)

/obj/item/reagent_containers/food/snacks/tofupie
	name = "tofu-pie"
	desc = "Вкусный пирог с тофу."
	ru_names = list(
		NOMINATIVE = "тофу-пирог",
		GENITIVE = "тофу-пирога",
		DATIVE = "тофу-пирогу",
		ACCUSATIVE = "тофу-пирог",
		INSTRUMENTAL = "тофу-пирогом",
		PREPOSITIONAL = "тофу-пироге"
	)
	icon_state = "meatpie"
	trash = /obj/item/trash/plate
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("пирога" = 1, "тофу" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Сладкий и вкусный ядовитый пирог."
	ru_names = list(
		NOMINATIVE = "пирог с мухоморами",
		GENITIVE = "пирога с мухоморами",
		DATIVE = "пирогу с мухоморами",
		ACCUSATIVE = "пирог с мухоморами",
		INSTRUMENTAL = "пирогом с мухоморами",
		PREPOSITIONAL = "пироге с мухоморами"
	)
	icon_state = "amanita_pie"
	filling_color = "#FFCCCC"
	bitesize = 4
	list_reagents = list("nutriment" = 6, "amanitin" = 3, "psilocybin" = 1, "vitamin" = 4)
	tastes = list("пирога" = 1, "грибов" = 1)
	foodtype = GRAIN | VEGETABLES
	log_eating = TRUE

/obj/item/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "Готов поспорить, ты любишь блюда из толстошлемников!"
	ru_names = list(
		NOMINATIVE = "пирог с толстошлемником",
		GENITIVE = "пирога с толстошлемником",
		DATIVE = "пирогу с толстошлемником",
		ACCUSATIVE = "пирог с толстошлемником",
		INSTRUMENTAL = "пирогом с толстошлемником",
		PREPOSITIONAL = "пироге с толстошлемником"
	)
	icon_state = "plump_pie"
	filling_color = "#B8279B"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("пирога" = 1, "грибов" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/plump_pie/Initialize(mapload)
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Микроволновку посетило причудливое настроение! Она приготовила исключительный пирог с толстошлемником!"
		ru_names = list(
			NOMINATIVE = "исключительный пирог с толстошлемником",
			GENITIVE = "исключительного пирога с толстошлемником",
			DATIVE = "исключительному пирогу с толстошлемником",
			ACCUSATIVE = "исключительный пирог с толстошлемником",
			INSTRUMENTAL = "исключительным пирогом с толстошлемником",
			PREPOSITIONAL = "исключительном пироге с толстошлемником"
		)
		reagents.add_reagent("omnizine", 5)
	. = ..()

/obj/item/reagent_containers/food/snacks/xemeatpie
	name = "xeno-pie"
	desc = "Вкусный мясной пирог. Наверное, еретический."
	ru_names = list(
		NOMINATIVE = "пирог с ксеномясом",
		GENITIVE = "пирога с ксеномясом",
		DATIVE = "пирогу с ксеномясом",
		ACCUSATIVE = "пирог с ксеномясом",
		INSTRUMENTAL = "пирогом с ксеномясом",
		PREPOSITIONAL = "пироге с ксеномясом"
	)
	icon_state = "xenomeatpie"
	trash = /obj/item/trash/plate
	filling_color = "#43DE18"
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("пирога" = 1, "мяса" = 1, "кислоты" = 1)
	foodtype = GRAIN | MEAT


/obj/item/reagent_containers/food/snacks/applepie
	name = "apple pie"
	desc = "Пирог, содержащий сладкую сладкую любовь... или яблоки."
	ru_names = list(
		NOMINATIVE = "яблочный пирог",
		GENITIVE = "яблочного пирога",
		DATIVE = "яблочному пирогу",
		ACCUSATIVE = "яблочный пирог",
		INSTRUMENTAL = "яблочным пирогом",
		PREPOSITIONAL = "яблочном пироге"
	)
	icon_state = "applepie"
	filling_color = "#E0EDC5"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("пирога" = 1, "яблока" = 1)
	foodtype = GRAIN | FRUIT | SUGAR


/obj/item/reagent_containers/food/snacks/cherrypie
	name = "cherry pie"
	desc = "Так вкусно, что взрослый мужчина заплачет."
	ru_names = list(
		NOMINATIVE = "вишнёвый пирог",
		GENITIVE = "вишнёвого пирога",
		DATIVE = "вишнёвому пирогу",
		ACCUSATIVE = "вишнёвый пирог",
		INSTRUMENTAL = "вишнёвым пирогом",
		PREPOSITIONAL = "вишнёвом пироге"
	)
	icon_state = "cherrypie"
	filling_color = "#FF525A"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("пирога" = 1, "вишни" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/sliceable/pumpkinpie
	name = "pumpkin pie"
	desc = "Вкусное угощение для осенних месяцев."
	ru_names = list(
		NOMINATIVE = "тыквенный пирог",
		GENITIVE = "тыквенного пирога",
		DATIVE = "тыквенному пирогу",
		ACCUSATIVE = "тыквенный пирог",
		INSTRUMENTAL = "тыквенным пирогом",
		PREPOSITIONAL = "тыквенном пироге"
	)
	icon_state = "pumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	bitesize = 3
	filling_color = "#F5B951"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("пирога" = 1, "тыквы" = 1)
	foodtype = GRAIN | VEGETABLES | SUGAR

/obj/item/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "Кусочек тыквенного пирога со взбитыми сливками сверху. Совершенство."
	ru_names = list(
		NOMINATIVE = "кусочек тыквенного пирога",
		GENITIVE = "кусочка тыквенного пирога",
		DATIVE = "кусочку тыквенного пирога",
		ACCUSATIVE = "кусочек тыквенного пирога",
		INSTRUMENTAL = "кусочком тыквенного пирога",
		PREPOSITIONAL = "кусочке тыквенного пирога"
	)
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#F5B951"
	tastes = list("пирога" = 1, "тыквы" = 1)
	foodtype = GRAIN | VEGETABLES | SUGAR

//////////////////////
//		Donuts		//
//////////////////////

/obj/item/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Отлично сочетается с Робаст кофе."
	ru_names = list(
		NOMINATIVE = "пончик",
		GENITIVE = "пончика",
		DATIVE = "пончику",
		ACCUSATIVE = "пончик",
		INSTRUMENTAL = "пончиком",
		PREPOSITIONAL = "пончике"
	)
	icon_state = "donut1"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "sugar" = 10)
	var/extra_reagent = null
	filling_color = "#D2691E"
	var/randomized_sprinkles = 1
	var/donut_sprite_type = "regular"
	tastes = list("пончика" = 1)
	foodtype = JUNKFOOD

/obj/item/reagent_containers/food/snacks/donut/Initialize(mapload)
	if(randomized_sprinkles && prob(30))
		switch(rand(1,4))
			if(1)
				name = "chocolate donut"
				ru_names = list(
					NOMINATIVE = "шоколадный пончик",
					GENITIVE = "шоколадного пончика",
					DATIVE = "шоколадному пончику",
					ACCUSATIVE = "шоколадный пончик",
					INSTRUMENTAL = "шоколадным пончиком",
					PREPOSITIONAL = "шоколадном пончике"
				)
				icon_state = "donut5"
				reagents.add_reagent("cocoa", 2)
				filling_color = "#2e1300"
				donut_sprite_type = "chocolate"
			if(2)
				name = "vanilla donut"
				ru_names = list(
					NOMINATIVE = "ванильный пончик",
					GENITIVE = "ванильного пончика",
					DATIVE = "ванильному пончику",
					ACCUSATIVE = "ванильный пончик",
					INSTRUMENTAL = "ванильным пончиком",
					PREPOSITIONAL = "ванильном пончике"
				)
				icon_state = "donut4"
				reagents.add_reagent("vanilla", 2)
				filling_color = "#dcd8b0"
				donut_sprite_type = "vanilla"
			if(3)
				name = "berry donut"
				ru_names = list(
					NOMINATIVE = "ягодный пончик",
					GENITIVE = "ягодного пончика",
					DATIVE = "ягодному пончику",
					ACCUSATIVE = "ягодный пончик",
					INSTRUMENTAL = "ягодным пончиком",
					PREPOSITIONAL = "ягодном пончике"
				)
				icon_state = "donut3"
				reagents.add_reagent("berryjuice", 2)
				filling_color = "#82e4ed"
				donut_sprite_type = "berry"
			if(4)
				name = "frosted donut"
				ru_names = list(
					NOMINATIVE = "глазированный пончик",
					GENITIVE = "глазированного пончика",
					DATIVE = "глазированному пончику",
					ACCUSATIVE = "глазированный пончик",
					INSTRUMENTAL = "глазированным пончиком",
					PREPOSITIONAL = "глазированном пончике"
				)
				icon_state = "donut2"
				reagents.add_reagent("sprinkles", 2)
				donut_sprite_type = "frosted"
				filling_color = "#FF69B4"
	. = ..()

/obj/item/reagent_containers/food/snacks/donut/update_icon_state()
	return

/obj/item/reagent_containers/food/snacks/donut/sprinkles
	name = "frosted donut"
	ru_names = list(
		NOMINATIVE = "глазированный пончик",
		GENITIVE = "глазированного пончика",
		DATIVE = "глазированному пончику",
		ACCUSATIVE = "глазированный пончик",
		INSTRUMENTAL = "глазированным пончиком",
		PREPOSITIONAL = "глазированном пончике"
	)
	icon_state = "donut2"
	list_reagents = list("nutriment" = 3, "sugar" = 10)
	filling_color = "#FF69B4"
	donut_sprite_type = "frosted"
	randomized_sprinkles = 0

/obj/item/reagent_containers/food/snacks/donut/sprinkles/Initialize(mapload)
	switch(rand(1,4))
		if(1)
			name = "chocolate donut"
			ru_names = list(
				NOMINATIVE = "шоколадный пончик",
				GENITIVE = "шоколадного пончика",
				DATIVE = "шоколадному пончику",
				ACCUSATIVE = "шоколадный пончик",
				INSTRUMENTAL = "шоколадным пончиком",
				PREPOSITIONAL = "шоколадном пончике"
			)
			icon_state = "donut5"
			reagents.add_reagent("cocoa", 2)
			filling_color = "#2e1300"
			donut_sprite_type = "chocolate"
		if(2)
			name = "vanilla donut"
			ru_names = list(
				NOMINATIVE = "ванильный пончик",
				GENITIVE = "ванильного пончика",
				DATIVE = "ванильному пончику",
				ACCUSATIVE = "ванильный пончик",
				INSTRUMENTAL = "ванильным пончиком",
				PREPOSITIONAL = "ванильном пончике"
			)
			icon_state = "donut4"
			reagents.add_reagent("vanilla", 2)
			filling_color = "#dcd8b0"
			donut_sprite_type = "vanilla"
		if(3)
			name = "berry donut"
			ru_names = list(
				NOMINATIVE = "ягодный пончик",
				GENITIVE = "ягодного пончика",
				DATIVE = "ягодному пончику",
				ACCUSATIVE = "ягодный пончик",
				INSTRUMENTAL = "ягодным пончиком",
				PREPOSITIONAL = "ягодном пончике"
			)
			icon_state = "donut3"
			reagents.add_reagent("berryjuice", 2)
			filling_color = "#82e4ed"
			donut_sprite_type = "berry"
		if(4)
			reagents.add_reagent("sprinkles", 2)
	. = ..()

/obj/item/reagent_containers/food/snacks/donut/chaos
	name = "chaos donut"
	desc = "Как жизнь, никогда не бывает одинаковым на вкус."
	ru_names = list(
		NOMINATIVE = "хаотичный пончик",
		GENITIVE = "хаотичного пончика",
		DATIVE = "хаотичному пончику",
		ACCUSATIVE = "хаотичный пончик",
		INSTRUMENTAL = "хаотичным пончиком",
		PREPOSITIONAL = "хаотичном пончике"
	)
	bitesize = 10
	tastes = list("пончика" = 3, "хаоса" = 1)
	log_eating = TRUE
	randomized_sprinkles = 0

/obj/item/reagent_containers/food/snacks/donut/chaos/Initialize(mapload)
	extra_reagent = pick("nutriment", "capsaicin", "frostoil", "krokodil", "plasma", "cocoa", "slimejelly", "banana", "berryjuice", "omnizine")
	reagents.add_reagent("[extra_reagent]", 3)
	if(prob(30))
		switch(rand(1,4))
			if(1)
				name = "chocolate chaos donut"
				ru_names = list(
					NOMINATIVE = "шоколадный хаотичный пончик",
					GENITIVE = "шоколадного хаотичного пончика",
					DATIVE = "шоколадному хаотичному пончику",
					ACCUSATIVE = "шоколадный хаотичный пончик",
					INSTRUMENTAL = "шоколадным хаотичным пончиком",
					PREPOSITIONAL = "шоколадном хаотичном пончике"
				)
				icon_state = "donut5"
				reagents.add_reagent("cocoa", 2)
				filling_color = "#2e1300"
				donut_sprite_type = "chocolate"
			if(2)
				name = "vanilla chaos donut"
				icon_state = "donut4"
				reagents.add_reagent("vanilla", 2)
				filling_color = "#dcd8b0"
				donut_sprite_type = "vanilla"
			if(3)
				name = "berry chaos donut"
				ru_names = list(
					NOMINATIVE = "ягодный хаотичный пончик",
					GENITIVE = "ягодного хаотичного пончика",
					DATIVE = "ягодному хаотичному пончику",
					ACCUSATIVE = "ягодный хаотичный пончик",
					INSTRUMENTAL = "ягодным хаотичным пончиком",
					PREPOSITIONAL = "ягодном хаотичном пончике"
				)
				icon_state = "donut3"
				reagents.add_reagent("berryjuice", 2)
				filling_color = "#82e4ed"
				donut_sprite_type = "berry"
			if(4)
				name = "frosted chaos donut"
				ru_names = list(
					NOMINATIVE = "глазированный хаотичный пончик",
					GENITIVE = "глазированного хаотичного пончика",
					DATIVE = "глазированному хаотичному пончику",
					ACCUSATIVE = "глазированный хаотичный пончик",
					INSTRUMENTAL = "глазированным хаотичным пончиком",
					PREPOSITIONAL = "глазированном хаотичном пончике"
				)
				icon_state = "donut2"
				reagents.add_reagent("sprinkles", 2)
				donut_sprite_type = "frosted"
				filling_color = "#FF69B4"
	. = ..()

/obj/item/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "Тебе завидно?"
	ru_names = list(
		NOMINATIVE = "желейный пончик",
		GENITIVE = "желейного пончика",
		DATIVE = "желейному пончику",
		ACCUSATIVE = "желейный пончик",
		INSTRUMENTAL = "желейным пончиком",
		PREPOSITIONAL = "желейном пончике"
	)
	icon_state = "jdonut1"
	extra_reagent = "berryjuice"
	donut_sprite_type = "jelly"
	randomized_sprinkles = 0
	tastes = list("желе" = 1, "пончика" = 10)

/obj/item/reagent_containers/food/snacks/donut/jelly/Initialize(mapload)
	if(extra_reagent)
		reagents.add_reagent("[extra_reagent]", 3)
	if(prob(30))
		switch(rand(1,4))
			if(1)
				name = "chocolate jelly donut"
				ru_names = list(
					NOMINATIVE = "шоколадно-желейный пончик",
					GENITIVE = "шоколадно-желейного пончика",
					DATIVE = "шоколадно-желейному пончику",
					ACCUSATIVE = "шоколадно-желейный пончик",
					INSTRUMENTAL = "шоколадно-желейным пончиком",
					PREPOSITIONAL = "шоколадно-желейном пончике"
				)
				icon_state = "jdonut5"
				reagents.add_reagent("cocoa", 2)
				filling_color = "#2e1300"
				donut_sprite_type = "chocolatejelly"
			if(2)
				name = "vanilla jelly donut"
				ru_names = list(
					NOMINATIVE = "ванильно-желейный пончик",
					GENITIVE = "ванильно-желейного пончика",
					DATIVE = "ванильно-желейному пончику",
					ACCUSATIVE = "ванильно-желейный пончик",
					INSTRUMENTAL = "ванильно-желейным пончиком",
					PREPOSITIONAL = "ванильно-желейном пончике"
				)
				icon_state = "jdonut4"
				reagents.add_reagent("vanilla", 2)
				filling_color = "#dcd8b0"
				donut_sprite_type = "vanillajelly"
			if(3)
				name = "berry jelly donut"
				ru_names = list(
					NOMINATIVE = "ягодно-желейный пончик",
					GENITIVE = "ягодно-желейного пончика",
					DATIVE = "ягодно-желейному пончику",
					ACCUSATIVE = "ягодно-желейный пончик",
					INSTRUMENTAL = "ягодно-желейным пончиком",
					PREPOSITIONAL = "ягодно-желейном пончике"
				)
				icon_state = "jdonut3"
				reagents.add_reagent("berryjuice", 2)
				filling_color = "#82e4ed"
				donut_sprite_type = "berryjelly"
			if(4)
				name = "frosted jelly donut"
				ru_names = list(
					NOMINATIVE = "глазированно-желейный пончик",
					GENITIVE = "глазированно-желейного пончика",
					DATIVE = "глазированно-желейному пончику",
					ACCUSATIVE = "глазированно-желейный пончик",
					INSTRUMENTAL = "глазированно-желейным пончиком",
					PREPOSITIONAL = "глазированно-желейном пончике"
				)
				icon_state = "jdonut2"
				reagents.add_reagent("sprinkles", 2)
				donut_sprite_type = "frostedjelly"
				filling_color = "#FF69B4"
	. = ..()

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly
	name = "slimejelly donut"
	desc = "Тебе завидно?"
	ru_names = list(
		NOMINATIVE = "слаймовый желейный пончик",
		GENITIVE = "слаймового желейного пончика",
		DATIVE = "слаймовому желейному пончику",
		ACCUSATIVE = "слаймовый желейный пончик",
		INSTRUMENTAL = "слаймовым желейным пончиком",
		PREPOSITIONAL = "слаймовом желейном пончике"
	)
	icon_state = "jdonut1"
	extra_reagent = "slimejelly"
	foodtype = TOXIC

/obj/item/reagent_containers/food/snacks/donut/jelly/cherryjelly
	name = "jelly donut"
	desc = "Тебе завидно?"
	ru_names = list(
		NOMINATIVE = "желейный пончик",
		GENITIVE = "желейного пончика",
		DATIVE = "желейному пончику",
		ACCUSATIVE = "желейный пончик",
		INSTRUMENTAL = "желейным пончиком",
		PREPOSITIONAL = "желейном пончике"
	)
	icon_state = "jdonut1"
	extra_reagent = "cherryjelly"

//////////////////////
//		Pancakes	//
//////////////////////

/obj/item/reagent_containers/food/snacks/pancake
	name = "pancake"
	desc = "Обычный блинчик."
	ru_names = list(
		NOMINATIVE = "блин",
		GENITIVE = "блина",
		DATIVE = "блину",
		ACCUSATIVE = "блин",
		INSTRUMENTAL = "блином",
		PREPOSITIONAL = "блине"
	)
	icon_state = "pancake"
	filling_color = "#E7D8AB"
	bitesize = 2
	list_reagents = list("nutriment" = 3, "sugar" = 10)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/pancake/berry_pancake
	name = "berry pancake"
	desc = "Блинчик с ягодной начинкой."
	ru_names = list(
		NOMINATIVE = "ягодный блин",
		GENITIVE = "ягодного блина",
		DATIVE = "ягодному блину",
		ACCUSATIVE = "ягодный блин",
		INSTRUMENTAL = "ягодным блином",
		PREPOSITIONAL = "ягодном блине"
	)
	icon_state = "berry_pancake"
	list_reagents = list("nutriment" = 3, "sugar" = 10, "berryjuice" = 3)
	foodtype = GRAIN | SUGAR | FRUIT

/obj/item/reagent_containers/food/snacks/pancake/choc_chip_pancake
	name = "choc-chip pancake"
	desc = "Блинчик с шоколадной крошкой."
	ru_names = list(
		NOMINATIVE = "блин с шоколадной крошкой",
		GENITIVE = "блина с шоколадной крошкой",
		DATIVE = "блину с шоколадной крошкой",
		ACCUSATIVE = "блин с шоколадной крошкой",
		INSTRUMENTAL = "блином с шоколадной крошкой",
		PREPOSITIONAL = "блине с шоколадной крошкой"
	)
	icon_state = "choc_chip_pancake"
	list_reagents = list("nutriment" = 3, "sugar" = 10, "cocoa" = 3)

//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "Вкусный и пышный маленький кекс."
	ru_names = list(
		NOMINATIVE = "маффин",
		GENITIVE = "маффина",
		DATIVE = "маффину",
		ACCUSATIVE = "маффин",
		INSTRUMENTAL = "маффином",
		PREPOSITIONAL = "маффине"
	)
	icon_state = "muffin"
	filling_color = "#E0CF9B"
	list_reagents = list("nutriment" = 6)
	tastes = list("маффина" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "Никаких \"сюрпризов\" – и это хороший знак."
	ru_names = list(
		NOMINATIVE = "ягодный клафути",
		GENITIVE = "ягодного клафути",
		DATIVE = "ягодному клафути",
		ACCUSATIVE = "ягодный клафути",
		INSTRUMENTAL = "ягодным клафути",
		PREPOSITIONAL = "ягодном клафути"
	)
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	bitesize = 3
	list_reagents = list("nutriment" = 10, "berryjuice" = 5, "vitamin" = 2)
	tastes = list("пирога" = 1, "ежевики" = 1)
	foodtype = GRAIN | SUGAR | FRUIT


/obj/item/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "Большой мягкий крендель, полный ХРУСТА! Весь в завитушках!"
	ru_names = list(
		NOMINATIVE = "маковый крендель",
		GENITIVE = "макового кренделя",
		DATIVE = "маковому кренделю",
		ACCUSATIVE = "маковый крендель",
		INSTRUMENTAL = "маковым кренделем",
		PREPOSITIONAL = "маковом кренделе"
	)
	icon_state = "poppypretzel"
	filling_color = "#916E36"
	list_reagents = list("nutriment" = 5)
	tastes = list("кренделя" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "Искусно приготовленное печенье из толстошлемника. Ингредиенты: исключительно мелко нарезанный толстошлемник и хорошо перемолотая пшеничная мука."
	ru_names = list(
		NOMINATIVE = "печенье из толстошлемника",
		GENITIVE = "печенья из толстошлемника",
		DATIVE = "печенью из толстошлемника",
		ACCUSATIVE = "печенье из толстошлемника",
		INSTRUMENTAL = "печеньем из толстошлемника",
		PREPOSITIONAL = "печенье из толстошлемника"
	)
	icon_state = "phelmbiscuit"
	filling_color = "#CFB4C4"
	list_reagents = list("nutriment" = 5)
	tastes = list("грибов" = 1, "бисквита" = 1)
	foodtype = GRAIN | SUGAR | VEGETABLES

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/Initialize(mapload)
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Микроволновку посетило причудливое настроение! Она приготовила исключительное печенье из толстошлемника!"
		ru_names = list(
			NOMINATIVE = "исключительное печенье из толстошлемника",
			GENITIVE = "исключительного печенья из толстошлемника",
			DATIVE = "исключительному печенью из толстошлемника",
			ACCUSATIVE = "исключительное печенье из толстошлемника",
			INSTRUMENTAL = "исключительным печеньем из толстошлемника",
			PREPOSITIONAL = "исключительном печенье из толстошлемника"
		)
		reagents.add_reagent("omnizine", 5)
	. = ..()

/obj/item/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "Вкусный десерт, который не пройдёт через металлодетектор."
	ru_names = list(
		NOMINATIVE = "золотой яблочный штрейзель",
		GENITIVE = "золотого яблочного штрейзеля",
		DATIVE = "золотому яблочному штрейзелю",
		ACCUSATIVE = "золотой яблочный штрейзель",
		INSTRUMENTAL = "золотым яблочным штрейзелем",
		PREPOSITIONAL = "золотом яблочном штрейзеле"
	)
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#FFFF00"
	bitesize = 3
	list_reagents = list("nutriment" = 8, "gold" = 5, "vitamin" = 4)
	tastes = list("пирога" = 1, "яблока" = 1, "дорогого металла" = 1)
	foodtype = GRAIN | SUGAR | FRUIT


/obj/item/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "Солёный крекер. Любимое лакомство Поли."
	ru_names = list(
		NOMINATIVE = "крекер",
		GENITIVE = "крекера",
		DATIVE = "крекеру",
		ACCUSATIVE = "крекер",
		INSTRUMENTAL = "крекером",
		PREPOSITIONAL = "крекере"
	)
	icon_state = "cracker"
	bitesize = 1
	filling_color = "#F5DEB8"
	list_reagents = list("nutriment" = 1)
	tastes = list("cracker" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/sundae
	name = "Sundae"
	desc = "Сливочное наслаждение!"
	ru_names = list(
		NOMINATIVE = "парфе",
		GENITIVE = "парфе",
		DATIVE = "парфе",
		ACCUSATIVE = "парфе",
		INSTRUMENTAL = "парфе",
		PREPOSITIONAL = "парфе"
	)
	icon_state = "sundae"
	filling_color = "#F5DEB8"
	list_reagents = list("nutriment" = 4, "plantmatter" = 2, "bananajucie" = 4, "cream" = 3)
	tastes = list("бананов" = 1, "вишни" = 1, "крема" = 1)
	bitesize = 5
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/croissant
	name = "croissant"
	desc = "Когда-то эта изысканная слоёная выпечка была доступна только состоятельным людям, но теперь она стала частью вашего повседневного меню."
	ru_names = list(
		NOMINATIVE = "круассан",
		GENITIVE = "круассана",
		DATIVE = "круассану",
		ACCUSATIVE = "круассан",
		INSTRUMENTAL = "круассаном",
		PREPOSITIONAL = "круассане"
	)
	icon_state = "croissant"
	bitesize = 4
	filling_color = "#ecb54f"
	list_reagents = list("nutriment" = 4, "sugar" = 2)
	tastes = list("круассана" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/croissant/throwing
	throwforce = 20
	throw_range = 9 //now with extra throwing action
	tastes = list("круассана" = 2, "сливочного масла" = 1, "металла" = 1)
	list_reagents = list("nutriment" = 4, "sugar" = 2, "iron" = 1)

/obj/item/reagent_containers/food/snacks/croissant/throwing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boomerang, throw_range, TRUE)
