///////////////////////////////////
//////////Autolathe Designs ///////
///////////////////////////////////

/datum/design/bucket
	name = "Ведро"
	name = "Ведро"
	id = "bucket"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/reagent_containers/glass/bucket
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/crowbar
	name = "Монтировка"
	name = "Монтировка"
	id = "crowbar"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/crowbar
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/flashlight
	name = "Фонарик" // ТУДУ
	id = "flashlight"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/flashlight
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/extinguisher
	name = "Огнетушитель"
	name = "Огнетушитель"
	id = "extinguisher"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 90)
	build_path = /obj/item/extinguisher
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/multitool
	name = "Мультитул"
	name = "Мультитул"
	id = "multitool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/multitool
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/analyzer
	name = "Газовый анализатор"
	id = "analyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/analyzer
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/tscanner
	name = "Сканер Т-лучей"
	name = "Сканер Т-лучей"
	id = "tscanner"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/t_scanner
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/weldingtool
	name = "Сварочный аппарат"
	name = "Сварочный аппарат"
	id = "welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 70, MAT_GLASS = 20)
	build_path = /obj/item/weldingtool
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/mini_weldingtool
	name = "Экстренный сварочный аппарат"
	name = "Экстренный сварочный аппарат"
	id = "mini_welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weldingtool/mini
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/screwdriver
	name = "Отвёртка"
	name = "Отвёртка"
	id = "screwdriver"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75)
	build_path = /obj/item/screwdriver
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/wirecutters
	name = "Кусачки"
	name = "Кусачки"
	id = "wirecutters"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/wirecutters
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/wrench
	name = "Гаечный ключ"
	name = "Гаечный ключ"
	id = "wrench"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/wrench
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/welding_helmet
	name = "Сварочная маска"
	name = "Сварочная маска"
	id = "welding_helmet"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1750, MAT_GLASS = 400)
	build_path = /obj/item/clothing/head/welding
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/cable_coil
	name = "Моток кабелей"
	name = "Моток кабелей"
	id = "cable_coil"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 5)
	build_path = /obj/item/stack/cable_coil
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")
	maxstack = 30

/datum/design/toolbox
	name = "Ящик для инструментов"
	name = "Ящик для инструментов"
	id = "tool_box"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/storage/toolbox
	category = list("initial", "Инструменты")
	category = list("initial", "Инструменты")

/datum/design/surgery
	name = "Хирургический набор (пустой)"
	name = "Хирургический набор (пустой)"
	id = "sur_kit"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/storage/toolbox/surgery/empty
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/apc_board
	name = "Плата ЛКП"
	name = "Плата ЛКП"
	id = "power control"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/apc_electronics
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/access_board
	name = "Плата модуля доступа"
	name = "Плата модуля доступа"
	id = "access_board"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/access_control
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/airlock_board
	name = "Плата управления шлюзом"
	name = "Плата управления шлюзом"
	id = "airlock_board"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/airlock_electronics
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/syndie_access_control
	name = "Подозрительная плата модуля доступа"
	name = "Подозрительная плата модуля доступа"
	id = "syndie_access_board"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/access_control/syndicate
	category = list("hacked", "Электроника")
	category = list("hacked", "Электроника")

/datum/design/firelock_board
	name = "Плата управления пожарным шлюзом"
	name = "Плата управления пожарным шлюзом"
	id = "firelock_board"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/firelock_electronics
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/airalarm_electronics
	name = "Плата воздушной сигнализации"
	name = "Плата воздушной сигнализации"
	id = "airalarm_electronics"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/airalarm_electronics
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/firealarm_electronics
	name = "Плата пожарной сигнализации"
	name = "Плата пожарной сигнализации"
	id = "firealarm_electronics"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/firealarm_electronics
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/intercom_electronics
	name = "Плата интеркома"
	name = "Плата интеркома"
	id = "intercom_electronics"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/intercom_electronics
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/airlock_controller
	name = "Плата удалённого управления шлюзом"
	name = "Плата удалённого управления шлюзом"
	id = "airlock_controller"
	build_type = AUTOLATHE
	materials = list(MAT_METAL=100, MAT_GLASS=50)
	build_path = /obj/item/assembly/control/airlock
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/earmuffs
	name = "Защитные наушники"
	name = "Защитные наушники"
	id = "earmuffs"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/ears/earmuffs
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/pipe_painter
	name = "Покрасчик для труб"
	name = "Покрасчик для труб"
	id = "pipe_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000)
	build_path = /obj/item/pipe_painter
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/window_painter
	name = "Покрасчик для окон"
	name = "Покрасчик для окон"
	id = "window_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000)
	build_path = /obj/item/pipe_painter/window_painter
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/floorpainter
	name = "Покрасчик для пола"
	name = "Покрасчик для пола"
	id = "floor_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 125)
	build_path = /obj/item/floor_painter
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/airlock_painter
	name = "Покрасчик для шлюзов"
	name = "Покрасчик для шлюзов"
	id = "airlock_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/airlock_painter
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/pet_bowl
	name = "Миска для питомцев"
	name = "Миска для питомцев"
	id = "pet_bowl"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/glass/pet_bowl
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/metal
	name = "Сталь"
	name = "Сталь"
	id = "metal"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/metal
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")
	maxstack = 50

/datum/design/glass
	name = "Стекло"
	name = "Стекло"
	id = "glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/glass
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")
	maxstack = 50

/datum/design/rglass
	name = "Укреплённое стекло"
	id = "rglass"
	build_type = AUTOLATHE | SMELTER
	materials = list(MAT_METAL = 1000, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/rglass
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")
	maxstack = 50

/datum/design/rods
	name = "Металлический стержень"
	name = "Металлический стержень"
	id = "rods"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/stack/rods
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")
	maxstack = 50

/datum/design/rcd_ammo
	name = "Картридж со сжатой материей"
	name = "Картридж со сжатой материей"
	id = "rcd_ammo"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 48000, MAT_GLASS=24000)
	build_path = /obj/item/rcd_ammo
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/kitchen_knife
	name = "Кухонный нож"
	name = "Кухонный нож"
	id = "kitchen_knife"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 12000)
	build_path = /obj/item/kitchen/knife
	category = list("initial", "Кухня")
	category = list("initial", "Кухня")

/datum/design/fork
	name = "Вилка"
	name = "Вилка"
	id = "fork"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/kitchen/utensil/fork
	category = list("initial", "Кухня")
	category = list("initial", "Кухня")

/datum/design/spoon
	name = "Ложка"
	name = "Ложка"
	id = "spoon"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/kitchen/utensil/spoon
	category = list("initial", "Кухня")
	category = list("initial", "Кухня")

/datum/design/spork
	name = "Вилколожка" // ТУДУ
	id = "spork"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/kitchen/utensil/spork
	category = list("initial", "Кухня")
	category = list("initial", "Кухня")

/datum/design/tray
	name = "Поднос"
	name = "Поднос"
	id = "tray"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/storage/bag/tray
	category = list("initial", "Кухня")
	category = list("initial", "Кухня")

/datum/design/drinking_glass
	name = "Стакан"
	name = "Стакан"
	id = "drinking_glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass
	category = list("initial", "Кухня")
	category = list("initial", "Кухня")

/datum/design/shot_glass
	name = "Рюмка"
	name = "Рюмка"
	id = "shot_glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass/shotglass
	category = list("initial", "Кухня")
	category = list("initial", "Кухня")

/datum/design/shaker
	name = "Шейкер" // ТУДУ
	id = "shaker"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1500)
	build_path = /obj/item/reagent_containers/food/drinks/shaker
	category = list("initial", "Кухня")
	category = list("initial", "Кухня")

/datum/design/cultivator
	name = "Тяпка"
	name = "Тяпка"
	id = "cultivator"
	build_type = AUTOLATHE
	materials = list(MAT_METAL=50)
	build_path = /obj/item/cultivator
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/plant_analyzer
	name = "Анализатор растений"
	name = "Анализатор растений"
	id = "plant_analyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/plant_analyzer
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/shovel
	name = "Лопата"
	name = "Лопата"
	id = "shovel"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/shovel
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/spade
	name = "Лопатка" // ТУДУ
	id = "spade"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/shovel/spade
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/hatchet
	name = "Топорик"
	name = "Топорик"
	id = "hatchet"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 15000)
	build_path = /obj/item/hatchet
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/beaker
	name = "Мерный стакан"
	name = "Мерный стакан"
	id = "beaker"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/glass/beaker
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/large_beaker
	name = "Большой мерный стакан"
	name = "Большой мерный стакан"
	id = "large_beaker"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 2500)
	build_path = /obj/item/reagent_containers/glass/beaker/large
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/vial
	name = "Пробирка"
	name = "Пробирка"
	id = "vial"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 250)
	build_path = /obj/item/reagent_containers/glass/beaker/vial
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/vial_storage_box
	name = "Бокс для пробирок"
	name = "Бокс для пробирок"
	id = "vial_storage_box"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 1500)
	build_path = /obj/item/storage/fancy/vials
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/secure_vial_storage_box
	name = "Защищённый бокс для пробирок"
	name = "Защищённый бокс для пробирок"
	id = "secure_vial_storage_box"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1500)
	build_path = /obj/item/storage/lockbox/vials
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/healthanalyzer
	name = "Анализатор здоровья"
	name = "Анализатор здоровья"
	id = "healthanalyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/healthanalyzer
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/pillbottle
	name = "Пузырёк для таблеток"
	name = "Пузырёк для таблеток"
	id = "pillbottle"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 20)
	build_path = /obj/item/storage/pill_bottle
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/beanbag_slug
	name = "Патрон \"Погремушка\""
	name = "Патрон \"Погремушка\""
	id = "beanbag_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/ammo_casing/shotgun/beanbag
	category = list("initial", "Безопасность")
	category = list("initial", "Безопасность")

/datum/design/rubbershot
	name = "Резиновая картечь"
	id = "rubber_shot"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/ammo_casing/shotgun/rubbershot
	category = list("initial", "Безопасность")
	category = list("initial", "Безопасность")

/datum/design/c38
	name = "Speed Loader (.38)" // ТУДУ
	id = "c38"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5900)
	build_path = /obj/item/ammo_box/speedloader/c38
	category = list("initial", "Безопасность")
	category = list("initial", "Безопасность")

/datum/design/c38hp
	name = "Speed Loader (.38 Hollow-Point)" // ТУДУ
	id = "c38hp"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30500)
	build_path = /obj/item/ammo_box/speedloader/c38/hp
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/recorder
	name = "Мультифункциональный диктофон" // ТУДУ
	id = "recorder"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 60, MAT_GLASS = 30)
	build_path = /obj/item/taperecorder/empty
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/tape
	name = "Кассета"
	name = "Кассета"
	id = "tape"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 5)
	build_path = /obj/item/tape/random
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/igniter
	name = "Зажигатель" // ТУДУ
	id = "igniter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/igniter
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/signaler
	name = "Сигналер" // ТУДУ
	id = "signaler"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 120)
	build_path = /obj/item/assembly/signaler
	category = list("initial", "Радиосвязь")
	category = list("initial", "Радиосвязь")

/datum/design/radio_headset
	name = "Радиочастотная гарнитура"
	name = "Радиочастотная гарнитура"
	id = "radio_headset"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75)
	build_path = /obj/item/radio/headset
	category = list("initial", "Радиосвязь")
	category = list("initial", "Радиосвязь")

/datum/design/bounced_radio
	name = "Коротковолновая рация"
	id = "bounced_radio"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75, MAT_GLASS = 25)
	build_path = /obj/item/radio/off
	category = list("initial", "Радиосвязь")
	category = list("initial", "Радиосвязь")

/datum/design/infrared_emitter
	name = "Инфракрасный излучатель"
	id = "infrared_emitter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/assembly/infra
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/health_sensor
	name = "Сенсор здоровья"
	id = "health_sensor"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/assembly/health
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/stethoscope
	name = "Стетоскоп"
	name = "Стетоскоп"
	id = "stethoscope"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/clothing/accessory/stethoscope
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/timer
	name = "Таймер"
	name = "Таймер"
	id = "timer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/timer
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/voice_analyzer
	name = "Голосовой сенсор"
	name = "Голосовой сенсор"
	id = "voice_analyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/voice
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/noise_analyser
	name = "Звуковой сенсор"
	name = "Звуковой сенсор"
	id = "Noise_analyser"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 10)
	build_path = /obj/item/assembly/voice/noise
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/light_tube
	name = "Лампа-трубка"
	id = "light_tube"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/light/tube
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/light_bulb
	name = "Лампочка"
	name = "Лампочка"
	id = "light_bulb"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/light/bulb
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/camera_assembly
	name = "Корпус камеры наблюдения"
	id = "camera_assembly"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 250)
	build_path = /obj/item/camera_assembly
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/newscaster_frame
	name = "Корпус новостника"
	id = "newscaster_frame"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 14000, MAT_GLASS = 8000)
	build_path = /obj/item/mounted/frame/newscaster_frame
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/syringe
	name = "Шприц"
	name = "Шприц"
	id = "syringe"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 20)
	build_path = /obj/item/reagent_containers/syringe
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/safety_hypo
	name = "Медицинский гипоспрей"
	name = "Медицинский гипоспрей"
	id = "safetyhypo"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/hypospray/safety
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/automender
	name = "Авто-мендер"
	name = "Авто-мендер"
	id = "automender"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/reagent_containers/applicator
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/iv_bag
	name = "Капельница"
	name = "Капельница"
	id = "iv_bag"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 3000)
	build_path = /obj/item/reagent_containers/iv_bag
	category = list("initial", "Медицина")
	category = list("initial", "Медицина")

/datum/design/prox_sensor
	name = "Датчик движения"
	name = "Датчик движения"
	id = "prox_sensor"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/assembly/prox_sensor
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/foam_dart
	name = "Коробка пенопластовых дротиков"
	id = "foam_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 900)
	build_path = /obj/item/ammo_box/foambox
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/foam_dart_sniper
	name = "Коробка снайперских пенопластовых дротиков"
	id = "foam_dart_sniper"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1300)
	build_path = /obj/item/ammo_box/foambox/sniper
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/rubber9mm
	name = "Коробка патронов 9 мм (Резина)"
	id = "rubber9mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20000)
	build_path = /obj/item/ammo_box/rubber9mm
	category = list("initial", "Безопасность")
	category = list("initial", "Безопасность")

/datum/design/enforcermag
	name = "\"Блюститель\" – магазин 9 мм (Резина)"
	id = "rubber9mmmag"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 7200) //5200 за пули + 2000 за корпус
	build_path = /obj/item/ammo_box/magazine/enforcer
	category = list("initial", "Безопасность")
	category = list("initial", "Безопасность")

//hacked autolathe recipes
/datum/design/enforcermaglethal
	name = "\"Блюститель\" – магазин 9 мм"
	id = "c9mmmag"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000) //8000 за пули + 2000 за корпус
	build_path = /obj/item/ammo_box/magazine/enforcer/lethal
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/flamethrower
	name = "Огнемёт"
	name = "Огнемёт"
	id = "flamethrower"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/flamethrower/full
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/rpd
	name = "Устройство быстрого строительства (УБС)"
	name = "Устройство быстрого строительства (УБС)"
	id = "rpd"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500)
	build_path = /obj/item/rpd
	category = list("hacked", "Конструирование")
	category = list("hacked", "Конструирование")

/datum/design/rcl
	name = "Ручной кабелеукладчик"
	id = "rcl"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/twohanded/rcl
	category = list("hacked", "Конструирование")
	category = list("hacked", "Конструирование")

/datum/design/electropack
	name = "Электро-ранец"
	id = "electropack"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2500)
	build_path = /obj/item/radio/electropack
	category = list("hacked", "Инструменты")

/datum/design/large_welding_tool
	name = "Промышленный сварочный аппарат"
	id = "large_welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 70, MAT_GLASS = 60)
	build_path = /obj/item/weldingtool/largetank
	category = list("hacked", "Инструменты")

/datum/design/handcuffs
	name = "Наручники"
	name = "Наручники"
	id = "handcuffs"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/restraints/handcuffs
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/receiver
	name = "Модульный ресивер"
	id = "receiver"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 15000)
	build_path = /obj/item/weaponcrafting/receiver
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/cylinder
	name = "Цилиндр револьвера"
	id = "icylinder"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 6000)
	build_path = /obj/item/ammo_box/magazine/internal/cylinder/improvised
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/shotgun_slug
	name = "Пуля 12g"
	id = "shotgun_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/sp8box
	name = "Коробка патронов 40n&r"
	id = "fortynrbox"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 45000)
	build_path = /obj/item/ammo_box/fortynr
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/sp8mag
	name = "\"SP8\" – магазин 40n&r"
	id = "fortynrmag"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 13000)
	build_path = /obj/item/ammo_box/magazine/sp8
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/sp91rc_box
	name = "Коробка патронов 9 мм (TE)"
	id = "9mmTEbox"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30500)
	build_path = /obj/item/ammo_box/c9mmte
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/specter/disable
	name = "Коробка патронов \"Спектр\" (Парализующий)"
	id = "specter_disable"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 25000)
	build_path = /obj/item/ammo_box/specter/disabler
	category = list("initial", "Безопасность")
	category = list("initial", "Безопасность")

/datum/design/specter/laser
	name = "Коробка патронов \"Спектр\" (Лазерный)"
	id = "specter_laser"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 35000)
	build_path = /obj/item/ammo_box/specter/laser
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/spectermag_disabler
	name = "\"Спектр\" – магазин (Парализующий)"
	id = "spectermag_disabler"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 8000)
	build_path = /obj/item/ammo_box/magazine/specter
	category = list("initial", "Безопасность")
	category = list("initial", "Безопасность")

//hacked autolathe recipes
/datum/design/spectermag_laser
	name = "\"Спектр\" – магазин (Лазерный)"
	id = "spectermag_laser"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000)
	build_path = /obj/item/ammo_box/magazine/specter/laser
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/sp91rc_mag
	name = "\"SP-91-RC\" – магазин 9 мм (TE)"
	id = "9mm-te"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 12000)
	build_path = /obj/item/ammo_box/magazine/sp91rc
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/buckshot_shell
	name = "Картечь 12g"
	id = "buckshot_shell"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/buckshot
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/shotgun_dart
	name = "Дротик 12g"
	id = "shotgun_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	build_path = /obj/item/ammo_casing/shotgun/dart
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/incendiary_slug
	name = "Пуля 12g (Зажигательная)"
	id = "incendiary_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/incendiary
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/riot_dart
	name = "Пенопластовый дротик (Усиленный)"
	id = "riot_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/ammo_casing/caseless/foam_dart/riot
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/riot_dart_sniper
	name = "Снайперский пенопластовый дротик (Усиленный)"
	id = "riot_dart_sniper"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1800)
	build_path = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/riot_darts
	name = "Коробка пенопластовых дротиков (Усиленные)"
	id = "riot_darts"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 26500)
	build_path = /obj/item/ammo_box/foambox/riot
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/riot_darts_sniper
	name = "Коробка снайперских пенопластовых дротиков (Усиленные)"
	id = "riot_darts_sniper"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 72500)
	build_path = /obj/item/ammo_box/foambox/sniper/riot
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/a357
	name = "Коробка патронов .357"
	id = "a357"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75500)
	build_path = /obj/item/ammo_box/a357
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/c10mm
	name = "Коробка патронов 10 мм"
	id = "c10mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 45750)
	build_path = /obj/item/ammo_box/c10mm
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/c45
	name = "Коробка патронов .45"
	id = "c45"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30500)
	build_path = /obj/item/ammo_box/c45
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/c9mm
	name = "Коробка патронов 9 мм"
	id = "c9mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30500)
	build_path = /obj/item/ammo_box/c9mm
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/knuckles
	name = "Кастеты"
	id = "knuckles"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 18000)
	build_path = /obj/item/clothing/gloves/knuckles
	category = list("hacked", "Безопасность")
	category = list("hacked", "Безопасность")

/datum/design/cleaver
	name = "Тесак для мяса"
	id = "cleaver"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 18000)
	build_path = /obj/item/kitchen/knife/butcher
	category = list("hacked", "Кухня")

/datum/design/spraycan
	name = "Баллон с краской"
	id = "spraycan"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/toy/crayon/spraycan
	category = list("initial", "Инструменты")

/datum/design/Spray
	name = "Распылитель"
	id = "Spray"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 5000)
	build_path = /obj/item/reagent_containers/spray
	category = list("initial", "Инструменты")

/datum/design/desttagger
	name = "Destination tagger" // ТУДУ
	id = "desttagger"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 125)
	build_path = /obj/item/destTagger
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/handlabeler
	name = "Ручной этикетировщик"
	id = "handlabel"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 125)
	build_path = /obj/item/hand_labeler
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/conveyor_belt
	name = "Фрагмент конвеерной ленты"
	id = "conveyor_belt"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/conveyor_construct
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/conveyor_switch
	name = "Переключатель конвеерной ленты"
	id = "conveyor_switch"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 450, MAT_GLASS = 190)
	build_path = /obj/item/conveyor_switch_construct
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/conveyor_belt_placer
	name = "Установщик конвеерных лент"
	id = "conveyor_belt_placer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000) //This thing doesn't need to be very resource-intensive as the belts are already expensive
	build_path = /obj/item/storage/conveyor
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/mousetrap
	name = "Мышеловка"
	id = "mousetrap"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/assembly/mousetrap
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/vendor
	name = "Плата торгового автомата"
	id = "vendor"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 750, MAT_METAL = 250)
	build_path = /obj/item/circuitboard/vendor
	category = list("initial", "Электроника")
	category = list("initial", "Электроника")

/datum/design/mirror
	name = "Зеркало"
	id = "mirror"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 2500)	//1.25 glass sheets, broken mirrors will return a shard (1 sheet)
	build_path = /obj/item/mounted/mirror
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/safe_internals
	name = "Внутренности сейфа"
	id = "safe"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/safe_internals
	category = list("initial", "Конструирование")
	category = list("initial", "Конструирование")

/datum/design/golem_shell
	name = "Оболочка голема"
	id = "golem"
	req_tech = null	// Unreachable by tech researching.
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 40000)
	build_path = /obj/item/golem_shell
	category = list("Импортированное")
	category = list("Импортированное")

/datum/design/tts
	name = "Устройство преобразования текста в речь"
	id = "tts"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/ttsdevice
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/desk_bell
	name = "Настольный звонок"
	id = "desk_bell"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/desk_bell
	category = list("initial", "Разное")
	category = list("initial", "Разное")

/datum/design/cap_ammo
	name = "Speed Loader(caps)" // ТУДУ
	id = "cap_ammo"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100)
	build_path = /obj/item/ammo_box/speedloader/caps
	category = list("initial", "Разное")
	category = list("initial", "Разное")
