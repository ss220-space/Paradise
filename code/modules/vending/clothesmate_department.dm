/obj/machinery/vending/department_clothesmate
	name = "Broken Departament ClothesMate"
	desc = "Автомат-помощник по выдаче одежды отдела."
	icon_state = "clothes_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"
	slogan_list = list(
		"Од+ежда усп+ешного раб+отника!",
		"Похвал+а на глаз+а!",
		"Ну након+ец-то норм+ально од+елся!",
		"Надев+ая од+ежду, не заб+удьте про шл+япку!",
		"Вот +это г+ордость так+ое надев+ать!",
		"В+ыглядишь отп+адно!",
		"Я бы и сам так+ое нос+ил!",
		"А я д+умал, куд+а он+а подев+алась...",
		"О, +это был+а мо+я люб+имая!",
		"Производ+итель рекоменд+ует +этот фас+он!",
		"В+аша т+алия иде+ально сочет+ается с ней!",
		"В+аши глаз+а так и блист+ают с ней!",
		"Как же ты зд+орово в+ыглядишь!",
		"И не ск+ажешь? что теб+е не ид+ёт!",
		"Ну жен+их!",
		"Пост+ой на карт+онке, м+ожет найд+ём что поинтер+еснее!",
		"Бер+и-бер+и, не глаз+ей!",
		"Возвр+аты не бер+ём!",
		"Ну как на теб+я ш+или!",
		"Т+олько не стир+айте в маш+инке.",
		"У нас л+учшая од+ежда!",
		"Не пережив+айте! +Если моль её по+ела, то он+а к+ачественная!",
		"Вам иде+ально подошл+а бы др+угая од+ежда, но и +эта подойд+ёт!",
		"В+ыглядите ст+ильно.",
		"Вы теп+ерь в+ыглядите отд+еланным! Ну од+ежда отд+ела у вас!",
		"Отд+ел б+удет в+ами дов+олен, +если вы нар+ядитесь в +это!",
		"Ну крас+авец!"
	)
	vend_reply = "Спас+ибо за исп+ользование автом+ата-пом+ощника в в+ыборе од+ежды отд+ела!"

/obj/machinery/vending/department_clothesmate/get_ru_names()
	return list(
		NOMINATIVE = "сломанный торговый автомат Departament ClothesMate",
		GENITIVE = "сломанного торгового автомата Departament ClothesMate",
		DATIVE = "сломанному торговому автомату Departament ClothesMate",
		ACCUSATIVE = "сломанный торговый автомат Departament ClothesMate",
		INSTRUMENTAL = "сломанным торговым автоматом Departament ClothesMate",
		PREPOSITIONAL = "сломанном торговом автомате Departament ClothesMate",
	)

/obj/machinery/vending/department_clothesmate/security
	name = "Departament Security ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Службы безопасности."
	icon_state = "clothes-dep-sec_off"
	screen_overlay = "clothes-dep-sec"
	broken_overlay = "clothes-dep-sec_broken"
	req_access = list(ACCESS_SEC_DOORS)
	refill_canister = /obj/item/vending_refill/clothing/security

	product_categories = list(
		list(
			"name" = "Головные уборы",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/soft/sec = 10,
				/obj/item/clothing/head/soft/sec/corp = 10,
				/obj/item/clothing/head/beret/sec = 10,
				/obj/item/clothing/head/beret/sec/black = 10,
				/obj/item/clothing/head/officer = 10,
				/obj/item/clothing/head/beret/brigphys = 5,
				/obj/item/clothing/head/soft/brigphys = 5,
				/obj/item/clothing/head/helmet/lightweighthelmet = 10,
			),
		),
		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/gloves/color/black = 10,
				/obj/item/clothing/gloves/color/red = 10,
				/obj/item/clothing/accessory/scarf/black = 10,
				/obj/item/clothing/accessory/scarf/red = 10,
				/obj/item/clothing/neck/poncho/security = 10,
				/obj/item/clothing/neck/cloak/security = 10,
				/obj/item/clothing/accessory/armband/sec = 10,
				/obj/item/radio/headset/headset_sec = 10,
				/obj/item/clothing/glasses/hud/security/sunglasses/tacticool = 5,
			),
		),
		list(
			"name" = "Маски",
			"icon" = "mask-face",
			"products" = list(
				/obj/item/clothing/mask/balaclava = 10,
				/obj/item/clothing/mask/bandana/red = 10,
				/obj/item/clothing/mask/bandana/black = 10,
				/obj/item/clothing/mask/secscarf = 10,
			),
		),
		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/rank/security = 10,
				/obj/item/clothing/under/rank/security/skirt = 10,
				/obj/item/clothing/under/rank/security/formal = 5,
				/obj/item/clothing/under/rank/security/corp = 5,
				/obj/item/clothing/under/rank/security2 = 5,
				/obj/item/clothing/under/rank/dispatch = 5,
				/obj/item/clothing/under/shorts/red = 10,
				/obj/item/clothing/under/shorts/black = 5,
				/obj/item/clothing/under/pants/red = 10,
				/obj/item/clothing/under/pants/track = 5,
				/obj/item/clothing/under/rank/security/brigphys = 3,
				/obj/item/clothing/under/rank/security/brigphys/skirt = 3,
				/obj/item/clothing/under/rank/security/brigmedical = 3,
				/obj/item/clothing/under/rank/security/brigmedical/skirt = 3,
			),
		),
		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/tracksuit/red = 5,
				/obj/item/clothing/suit/hooded/wintercoat/security = 5,
				/obj/item/clothing/suit/jacket/pilot = 5,
				/obj/item/clothing/suit/storage/sec_rps = 5,
				/obj/item/clothing/suit/armor/secjacket = 5,
				/obj/item/clothing/suit/storage/suragi_jacket/medsec = 3,
				/obj/item/clothing/suit/storage/brigdoc = 3,
			),
		),
		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/jackboots = 10,
				/obj/item/clothing/shoes/jackboots/jacksandals = 10,
				/obj/item/clothing/shoes/jackboots/cross = 10,
				/obj/item/clothing/shoes/jackboots/high = 10,
			),
		),
		list(
			"name" = "Сумки",
			"icon" = "suitcase",
			"products" = list(
				/obj/item/storage/backpack/security = 5,
				/obj/item/storage/backpack/satchel_sec = 5,
				/obj/item/storage/backpack/duffel/security = 5,
			),
		),
	)

/obj/machinery/vending/department_clothesmate/security/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Security ClothesMate",
		GENITIVE = "торгового автомата Departament Security ClothesMate",
		DATIVE = "торговому автомату Departament Security ClothesMate",
		ACCUSATIVE = "торговый автомат Departament Security ClothesMate",
		INSTRUMENTAL = "торговым автоматом Departament Security ClothesMate",
		PREPOSITIONAL = "торговом автомате Departament Security ClothesMate",
	)

/obj/machinery/vending/department_clothesmate/medical
	name = "Departament Medical ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Медицинского отдела."
	icon_state = "clothes-dep-med_off"
	screen_overlay = "clothes-dep-med"
	broken_overlay = "clothes-dep-med_broken"
	req_access = list(ACCESS_MEDICAL)
	refill_canister = /obj/item/vending_refill/clothing/medical

	product_categories = list(
		list(
			"name" = "Головные уборы",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/beret/med  = 10,
				/obj/item/clothing/head/soft/paramedic = 5,
				/obj/item/clothing/head/surgery/purple = 10,
				/obj/item/clothing/head/surgery/blue = 10,
				/obj/item/clothing/head/surgery/green = 10,
				/obj/item/clothing/head/surgery/lightgreen = 10,
				/obj/item/clothing/head/surgery/black = 10,
				/obj/item/clothing/head/headmirror = 10,
			),
		),
		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/accessory/scarf/white = 10,
				/obj/item/clothing/accessory/scarf/lightblue = 10,
				/obj/item/clothing/accessory/stethoscope = 10,
				/obj/item/clothing/accessory/armband/med = 10,
				/obj/item/clothing/accessory/armband/medgreen = 10,
				/obj/item/clothing/gloves/color/latex = 10,
				/obj/item/clothing/gloves/color/latex/nitrile = 10,
				/obj/item/radio/headset/headset_med = 10,
			),
		),
		list(
			"name" = "Маски",
			"icon" = "mask-face",
			"products" = list(
				/obj/item/clothing/mask/surgical = 10,
			),
		),
		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/rank/medical = 10,
				/obj/item/clothing/under/rank/medical/skirt = 10,
				/obj/item/clothing/under/rank/medical/intern = 10,
				/obj/item/clothing/under/rank/medical/intern/skirt = 10,
				/obj/item/clothing/under/rank/medical/intern/assistant = 10,
				/obj/item/clothing/under/rank/medical/intern/assistant/skirt = 10,
				/obj/item/clothing/under/rank/medical/blue = 10,
				/obj/item/clothing/under/rank/medical/green = 10,
				/obj/item/clothing/under/rank/medical/purple = 10,
				/obj/item/clothing/under/rank/medical/lightgreen = 10,
				/obj/item/clothing/under/medigown = 10,
				/obj/item/clothing/under/rank/nursesuit = 10,
				/obj/item/clothing/under/rank/nurse = 10,
				/obj/item/clothing/under/rank/orderly = 10,
				/obj/item/clothing/under/rank/medical/paramedic = 5,
				/obj/item/clothing/under/rank/medical/paramedic/skirt = 5,
				/obj/item/clothing/under/rank/virologist = 2,
				/obj/item/clothing/under/rank/virologist/skirt = 2,
				/obj/item/clothing/under/rank/psych = 2,
				/obj/item/clothing/under/rank/psych/turtleneck = 2,
				/obj/item/clothing/under/rank/psych/skirt = 2,
				/obj/item/clothing/under/rank/chemist = 2,
				/obj/item/clothing/under/rank/chemist/skirt = 2,
				/obj/item/clothing/under/rank/geneticist = 2,
				/obj/item/clothing/under/rank/geneticist/skirt = 2,
				/obj/item/clothing/under/rank/medical/mortician = 2,
			),
		),
		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/storage/labcoat = 10,
				/obj/item/clothing/suit/storage/suragi_jacket/medic = 10,
				/obj/item/clothing/suit/apron/surgical = 10,
				/obj/item/clothing/suit/storage/fr_jacket = 5,
				/obj/item/clothing/suit/hooded/wintercoat/medical = 5,
				/obj/item/clothing/suit/storage/labcoat/virologist = 2,
				/obj/item/clothing/suit/storage/suragi_jacket/virus = 2,
				/obj/item/clothing/suit/storage/labcoat/chemist = 2,
				/obj/item/clothing/suit/storage/suragi_jacket/chem = 2,
				/obj/item/clothing/suit/storage/labcoat/genetics = 2,
				/obj/item/clothing/suit/storage/suragi_jacket/genetics = 2,
				/obj/item/clothing/suit/storage/labcoat/mortician = 2,
			),
		),
		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/white = 10,
				/obj/item/clothing/shoes/sandal/white = 10,
			),
		),
		list(
			"name" = "Сумки",
			"icon" = "suitcase",
			"products" = list(
				/obj/item/storage/backpack/satchel_med = 5,
				/obj/item/storage/backpack/medic = 5,
				/obj/item/storage/backpack/duffel/medical = 5,
				/obj/item/storage/backpack/satchel_chem = 2,
				/obj/item/storage/backpack/chemistry = 2,
				/obj/item/storage/backpack/duffel/chemistry = 2,
				/obj/item/storage/backpack/satchel_vir = 2,
				/obj/item/storage/backpack/virology = 2,
				/obj/item/storage/backpack/duffel/virology = 2,
				/obj/item/storage/backpack/satchel_gen = 2,
				/obj/item/storage/backpack/genetics = 2,
				/obj/item/storage/backpack/duffel/genetics = 2,
			),
		),
	)

/obj/machinery/vending/department_clothesmate/medical/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Medical ClothesMate",
		GENITIVE = "торгового автомата Departament Medical ClothesMate",
		DATIVE = "торговому автомату Departament Medical ClothesMate",
		ACCUSATIVE = "торговый автомат Departament Medical ClothesMate",
		INSTRUMENTAL = "торговым автоматом Departament Medical ClothesMate",
		PREPOSITIONAL = "торговом автомате Departament Medical ClothesMate",
	)

/obj/machinery/vending/department_clothesmate/engineering
	name = "Departament Engineering ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Инженерного отдела."
	icon_state = "clothes-dep-eng_off"
	screen_overlay = "clothes-dep-eng"
	broken_overlay = "clothes-dep-eng_broken"
	req_access = list(ACCESS_ENGINE_EQUIP)
	refill_canister = /obj/item/vending_refill/clothing/engineering

	product_categories = list(
		list(
			"name" = "Головные уборы",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/hardhat = 10,
				/obj/item/clothing/head/hardhat/orange = 10,
				/obj/item/clothing/head/hardhat/red = 10,
				/obj/item/clothing/head/hardhat/dblue = 10,
				/obj/item/clothing/head/beret/eng = 10,
				/obj/item/clothing/head/beret/atmos = 3,
			),
		),
		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/gloves/color/orange = 10,
				/obj/item/clothing/gloves/color/fyellow = 3,
				/obj/item/clothing/accessory/scarf/yellow = 10,
				/obj/item/clothing/accessory/scarf/orange = 10,
				/obj/item/clothing/accessory/armband/engine = 10,
				/obj/item/radio/headset/headset_eng = 10,
			),
		),
		list(
			"name" = "Маски",
			"icon" = "mask-face",
			"products" = list(
				/obj/item/clothing/mask/gas = 10,
				/obj/item/clothing/mask/bandana/red = 10,
				/obj/item/clothing/mask/bandana/orange = 10,
				/obj/item/clothing/mask/bandana/red = 10,
			),
		),
		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/rank/engineer = 10,
				/obj/item/clothing/under/rank/engineer/skirt = 10,
				/obj/item/clothing/under/rank/engineer/trainee/assistant = 10,
				/obj/item/clothing/under/rank/engineer/trainee/assistant/skirt = 10,
				/obj/item/clothing/under/rank/atmospheric_technician = 3,
				/obj/item/clothing/under/rank/atmospheric_technician/skirt = 3,
			),
		),
		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/storage/hazardvest = 10,
				/obj/item/clothing/suit/storage/suragi_jacket/eng = 5,
				/obj/item/clothing/suit/hooded/wintercoat/engineering = 5,
				/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 5,
				/obj/item/clothing/suit/storage/suragi_jacket/atmos = 5,
			),
		),
		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/workboots = 10,
			),
		),
		list(
			"name" = "Сумки",
			"icon" = "suitcase",
			"products" = list(
				/obj/item/storage/backpack/industrial = 5,
				/obj/item/storage/backpack/satchel_eng = 5,
				/obj/item/storage/backpack/duffel/engineering = 5,
				/obj/item/storage/backpack/duffel/atmos = 3,
			),
		),
	)

/obj/machinery/vending/department_clothesmate/engineering/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Engineering ClothesMat",
		GENITIVE = "торгового автомата Departament Engineering ClothesMat",
		DATIVE = "торговому автомату Departament Engineering ClothesMat",
		ACCUSATIVE = "торговый автомат Departament Engineering ClothesMat",
		INSTRUMENTAL = "торговым автоматом Departament Engineering ClothesMat",
		PREPOSITIONAL = "торговом автомате Departament Engineering ClothesMat",
	)

/obj/machinery/vending/department_clothesmate/science
	name = "Departament Science ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Научного отдела."
	icon_state = "clothes-dep-sci_off"
	screen_overlay = "clothes-dep-sci"
	broken_overlay = "clothes-dep-sci_broken"
	req_access = list(ACCESS_RESEARCH)
	refill_canister = /obj/item/vending_refill/clothing/science

	product_categories = list(
		list(
			"name" = "Головные уборы",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/beret/purple_normal = 10,
				/obj/item/clothing/head/beret/purple = 10,
				/obj/item/clothing/head/soft/black = 10,
			),
		),
		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/gloves/color/latex = 10,
				/obj/item/clothing/gloves/color/white = 10,
				/obj/item/clothing/gloves/color/purple = 10,
				/obj/item/clothing/gloves/fingerless = 10,
				/obj/item/clothing/accessory/armband/science = 10,
				/obj/item/clothing/accessory/armband/yb = 10,
				/obj/item/clothing/accessory/scarf/purple = 10,
				/obj/item/radio/headset/headset_sci = 10,
			),
		),
		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/rank/scientist = 10,
				/obj/item/clothing/under/rank/scientist/skirt = 10,
				/obj/item/clothing/under/rank/scientist/student = 10,
				/obj/item/clothing/under/rank/scientist/student/skirt = 10,
				/obj/item/clothing/under/rank/scientist/student/assistant = 10,
				/obj/item/clothing/under/rank/scientist/student/assistant/skirt = 10,
				/obj/item/clothing/under/rank/roboticist = 10,
				/obj/item/clothing/under/rank/roboticist/skirt = 10,
			),
		),
		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/storage/labcoat/science = 10,
				/obj/item/clothing/suit/storage/labcoat = 10,
				/obj/item/clothing/suit/storage/suragi_jacket/sci = 5,
				/obj/item/clothing/suit/hooded/wintercoat/medical/science = 5,
			),
		),
		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/white = 10,
				/obj/item/clothing/shoes/slippers = 10,
				/obj/item/clothing/shoes/sandal/white = 10,
				/obj/item/clothing/shoes/black = 10,
			),
		),
		list(
			"name" = "Сумки",
			"icon" = "suitcase",
			"products" = list(
				/obj/item/storage/backpack/science = 5,
				/obj/item/storage/backpack/satchel_tox = 5,
				/obj/item/storage/backpack/duffel/science = 5,
			),
		),
	)

/obj/machinery/vending/department_clothesmate/science/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Science ClothesMate",
		GENITIVE = "торгового автомата Departament Science ClothesMate",
		DATIVE = "торговому автомату Departament Science ClothesMate",
		ACCUSATIVE = "торговый автомат Departament Science ClothesMate",
		INSTRUMENTAL = "торговым автоматом Departament Science ClothesMate",
		PREPOSITIONAL = "торговом автомате Departament Science ClothesMate",
	)

/obj/machinery/vending/department_clothesmate/cargo
	name = "Departament Cargo ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Отд+ела снабжения."
	icon_state = "clothes-dep-car_off"
	screen_overlay = "clothes-dep-car"
	broken_overlay = "clothes-dep-car_broken"
	req_access = list(ACCESS_MINING)
	refill_canister = /obj/item/vending_refill/clothing/cargo

	product_categories = list(
		list(
			"name" = "Головные уборы",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/soft = 10,
			),
		),
		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/gloves/color/brown/cargo = 10,
				/obj/item/clothing/gloves/color/light_brown = 10,
				/obj/item/clothing/gloves/fingerless = 10,
				/obj/item/clothing/gloves/color/black = 10,
				/obj/item/clothing/accessory/armband/cargo = 10,
				/obj/item/radio/headset/headset_cargo = 10,
			),
		),
		list(
			"name" = "Маски",
			"icon" = "mask-face",
			"products" = list(
				/obj/item/clothing/mask/bandana/black = 10,
				/obj/item/clothing/mask/bandana/orange = 10,
			),
		),
		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/rank/cargotech = 10,
				/obj/item/clothing/under/rank/cargotech/skirt = 10,
				/obj/item/clothing/under/rank/cargotech/alt = 5,
				/obj/item/clothing/under/rank/miner/lavaland = 10,
				/obj/item/clothing/under/overalls = 10,
				/obj/item/clothing/under/rank/miner/alt = 5,
				/obj/item/clothing/under/pants/tan = 10,
				/obj/item/clothing/under/pants/track = 10,
			),
		),
		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/storage/cargotech = 5,
				/obj/item/clothing/suit/hooded/wintercoat/cargo = 5,
				/obj/item/clothing/suit/hooded/wintercoat/miner = 5,
			),
		),
		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/brown = 10,
				/obj/item/clothing/shoes/workboots/mining = 10,
				/obj/item/clothing/shoes/jackboots = 10,
				/obj/item/clothing/shoes/jackboots/jacksandals = 10,
			),
		),
		list(
			"name" = "Сумки",
			"icon" = "suitcase",
			"products" = list(
				/obj/item/storage/backpack/cargo = 10,
				/obj/item/storage/backpack/explorer = 5,
				/obj/item/storage/backpack/satchel_explorer = 5,
				/obj/item/storage/backpack/duffel = 5,
			),
		),
	)

/obj/machinery/vending/department_clothesmate/cargo/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Cargo ClothesMate",
		GENITIVE = "торгового автомата Departament Cargo ClothesMate",
		DATIVE = "торговому автомату Departament Cargo ClothesMate",
		ACCUSATIVE = "торговый автомат Departament Cargo ClothesMate",
		INSTRUMENTAL = "торговым автоматом Departament Cargo ClothesMate",
		PREPOSITIONAL = "торговом автомате Departament Cargo ClothesMate",
	)

/obj/machinery/vending/department_clothesmate/law
	name = "Departament Law ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Юридического отдела."
	icon_state = "clothes-dep-sec_off"
	screen_overlay = "clothes-dep-sec"
	broken_overlay = "clothes-dep-sec_broken"
	req_access = list(ACCESS_LAWYER)
	refill_canister = /obj/item/vending_refill/clothing/law

	product_categories = list(
		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/gloves/color/white = 10,
				/obj/item/clothing/gloves/fingerless = 10,
				/obj/item/clothing/accessory/blue = 10,
				/obj/item/clothing/accessory/red = 10,
				/obj/item/clothing/accessory/black = 10,
				/obj/item/clothing/accessory/waistcoat = 5,
				/obj/item/radio/headset/headset_iaa = 10,
			),
		),
		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/rank/internalaffairs = 10,
				/obj/item/clothing/under/lawyer/female = 10,
				/obj/item/clothing/under/lawyer/black = 10,
				/obj/item/clothing/under/lawyer/red = 10,
				/obj/item/clothing/under/lawyer/blue = 10,
				/obj/item/clothing/under/lawyer/bluesuit = 10,
				/obj/item/clothing/under/lawyer/purpsuit = 10,
				/obj/item/clothing/under/lawyer/oldman = 10,
				/obj/item/clothing/under/blackskirt = 10,
				/obj/item/clothing/under/suit_jacket = 5,
				/obj/item/clothing/under/suit_jacket/really_black = 5,
				/obj/item/clothing/under/suit_jacket/female = 5,
				/obj/item/clothing/under/suit_jacket/red = 5,
				/obj/item/clothing/under/suit_jacket/navy = 5,
				/obj/item/clothing/under/suit_jacket/tan = 5,
				/obj/item/clothing/under/suit_jacket/burgundy = 5,
				/obj/item/clothing/under/suit_jacket/charcoal = 5,
			),
		),
		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/storage/internalaffairs = 10,
				/obj/item/clothing/suit/storage/lawyer/bluejacket = 5,
				/obj/item/clothing/suit/storage/lawyer/purpjacket = 5,
			),
		),
		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/laceup = 10,
				/obj/item/clothing/shoes/centcom = 10,
				/obj/item/clothing/shoes/brown = 10,
				/obj/item/clothing/shoes/sandal/fancy = 10,
			),
		),
		list(
			"name" = "Сумки",
			"icon" = "suitcase",
			"products" = list(
				/obj/item/storage/backpack/satchel = 10,
				/obj/item/storage/briefcase = 5,
			),
		),
	)

/obj/machinery/vending/department_clothesmate/law/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Law ClothesMate",
		GENITIVE = "торгового автомата Departament Law ClothesMate",
		DATIVE = "торговому автомату Departament Law ClothesMate",
		ACCUSATIVE = "торговый автомат Departament Law ClothesMate",
		INSTRUMENTAL = "торговым автоматом Departament Law ClothesMate",
		PREPOSITIONAL = "торговом автомате Departament Law ClothesMate",
	)

/obj/machinery/vending/department_clothesmate/service
	name = "Departament Service ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Отдела обслуживания."
	req_access = list()
	products = list()
	refill_canister = /obj/item/vending_refill/clothing/service

/obj/machinery/vending/department_clothesmate/service/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Service ClothesMate",
		GENITIVE = "торгового автомата Departament Service ClothesMate",
		DATIVE = "торговому автомату Departament Service ClothesMate",
		ACCUSATIVE = "торговый автомат Departament Service ClothesMate",
		INSTRUMENTAL = "торговым автоматом Departament Service ClothesMate",
		PREPOSITIONAL = "торговом автомате Departament Service ClothesMate",
	)

/obj/machinery/vending/department_clothesmate/service/chaplain
	name = "Departament Service ClothesMate Chaplain"
	desc = "Автомат-помощник по выдаче одежды для священнослужителей."
	icon_state = "clothes-dep-car_off"
	screen_overlay = "clothes-dep-car"
	broken_overlay = "clothes-dep-car_broken"
	req_access = list(ACCESS_CHAPEL_OFFICE)
	refill_canister = /obj/item/vending_refill/clothing/service/chaplain

	product_categories = list(
		list(
			"name" = "Головные уборы",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/witchhunter_hat = 2,
				/obj/item/clothing/head/helmet/riot/knight/templar = 1,
				/obj/item/clothing/head/bishopmitre = 2,
				/obj/item/clothing/head/blackbishopmitre = 2,
			),
		),
		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/gloves/ring/gold = 2,
				/obj/item/clothing/gloves/ring/silver = 2,
				/obj/item/clothing/neck/cloak/bishop = 2,
				/obj/item/clothing/neck/cloak/bishopblack = 2,
				/obj/item/radio/headset/headset_service = 5,
			),
		),
		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/rank/chaplain = 5,
				/obj/item/clothing/under/rank/chaplain/skirt = 5,
				/obj/item/clothing/under/wedding/bride_white = 1,
			),
		),
		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/witchhunter = 2,
				/obj/item/clothing/suit/armor/riot/knight/templar = 1,
				/obj/item/clothing/suit/hooded/chaplain_hoodie = 2,
				/obj/item/clothing/suit/hooded/nun = 2,
				/obj/item/clothing/suit/holidaypriest = 2,
			),
		),
		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/black = 5,
				/obj/item/clothing/shoes/laceup = 2,
			),
		),
		list(
			"name" = "Сумки",
			"icon" = "suitcase",
			"products" = list(
				/obj/item/storage/backpack/cultpack = 5,
			),
		),
	)

/obj/machinery/vending/department_clothesmate/service/chaplain/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Service ClothesMate Chaplain",
		GENITIVE = "торгового автомата Departament Service ClothesMate Chaplain",
		DATIVE = "торговому автомату Departament Service ClothesMate Chaplain",
		ACCUSATIVE = "торговый автомат Departament Service ClothesMate Chaplain",
		INSTRUMENTAL = "торговым автоматом Departament Service ClothesMate Chaplain",
		PREPOSITIONAL = "торговом автомате Departament Service ClothesMate Chaplain",
	)

/obj/machinery/vending/department_clothesmate/service/botanical
	name = "Departament Service ClothesMate Botanical"
	desc = "Автомат-помощник по выдаче ботанической одежды."
	req_access = list(ACCESS_HYDROPONICS)
	refill_canister = /obj/item/vending_refill/clothing/service/botanical

	product_categories = list(
		list(
			"name" = "Головные уборы",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/flatcap = 2,
			),
		),
		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/gloves/botanic_leather = 5,
				/obj/item/clothing/gloves/fingerless = 3,
				/obj/item/clothing/gloves/color/brown = 3,
				/obj/item/clothing/accessory/scarf/green = 2,
				/obj/item/radio/headset/headset_service = 5,
			),
		),
		list(
			"name" = "Маски",
			"icon" = "mask-face",
			"products" = list(
				/obj/item/clothing/mask/bandana/botany = 4,
			),
		),
		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/rank/hydroponics = 5,
				/obj/item/clothing/under/rank/hydroponics/skirt = 5,
			),
		),
		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/storage/suragi_jacket/botany = 3,
				/obj/item/clothing/suit/apron = 4,
				/obj/item/clothing/suit/apron/overalls = 2,
				/obj/item/clothing/suit/hooded/wintercoat/hydro = 5,
			),
		),
		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/brown = 4,
				/obj/item/clothing/shoes/sandal = 2,
				/obj/item/clothing/shoes/leather = 2,
			),
		),
		list(
			"name" = "Сумки",
			"icon" = "suitcase",
			"products" = list(
				/obj/item/storage/backpack/botany = 5,
				/obj/item/storage/backpack/satchel_hyd = 5,
				/obj/item/storage/backpack/duffel/hydro = 5,
			),
		),
	)

/obj/machinery/vending/department_clothesmate/service/botanical/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Departament Service ClothesMate Botanical",
		GENITIVE = "торгового автомата Departament Service ClothesMate Botanical",
		DATIVE = "торговому автомату Departament Service ClothesMate Botanical",
		ACCUSATIVE = "торговый автомат Departament Service ClothesMate Botanical",
		INSTRUMENTAL = "торговым автоматом Departament Service ClothesMate Botanical",
		PREPOSITIONAL = "торговом автомате Departament Service ClothesMate Botanical",
	)
