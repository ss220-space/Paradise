/datum/design/spacepod_main
	construction_time = 100
	name = "Circuit Design (Space Pod Mainboard)"
	desc = "Allows for the construction of a Space Pod mainboard."
	id = "spacepod_main"
	req_tech = list(RESEARCH_TREE_MATERIALS = 1) //All parts required to build a basic pod have materials 1, so the mechanic can do his damn job.
	build_type = PODFAB
	materials = list(MAT_METAL=5000)
	build_path = /obj/item/circuitboard/mecha/pod
	category = list(POD_FAB_CATEGORY_PARTS)


// MARK: Spacepod parts

/datum/design/podframe_fp
	construction_time = 200
	name = "Fore port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore port component."
	id = "podframefp"
	build_type = PODFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 1)
	build_path = /obj/item/pod_parts/pod_frame/fore_port
	category = list(POD_FAB_CATEGORY_FRAME)
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_ap
	construction_time = 200
	name = "Aft port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft port component."
	id = "podframeap"
	build_type = PODFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 1)
	build_path = /obj/item/pod_parts/pod_frame/aft_port
	category = list(POD_FAB_CATEGORY_FRAME)
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_fs
	construction_time = 200
	name = "Fore starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore starboard component."
	id = "podframefs"
	build_type = PODFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 1)
	build_path = /obj/item/pod_parts/pod_frame/fore_starboard
	category = list(POD_FAB_CATEGORY_FRAME)
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_as
	construction_time = 200
	name = "Aft starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft starboard component."
	id = "podframeas"
	build_type = PODFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 1)
	build_path = /obj/item/pod_parts/pod_frame/aft_starboard
	category = list(POD_FAB_CATEGORY_FRAME)
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)


// MARK: Pod core

/datum/design/pod_core
	construction_time = 700 //Pod core should take a bit to process, after all, it's a big complicated engine and stuff.
	name = "Spacepod Core"
	desc = "Allows for the construction of a spacepod core system, made up of the engine and life support systems."
	id = "podcore"
	build_type = MECHFAB | PODFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 1)
	build_path = /obj/item/pod_parts/core
	category = list(POD_FAB_CATEGORY_PARTS)
	materials = list(MAT_METAL=5000,MAT_URANIUM=1000,MAT_PLASMA=5000)


// MARK: Spacepod armor

/datum/design/pod_armor_civ
	construction_time = 400 //more time than frames, less than pod core
	name = "Pod Armor (civilian)"
	desc = "Allows for the construction of spacepod armor. This is the civilian version."
	id = "podarmor_civ"
	build_type = PODFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 1)
	build_path = /obj/item/pod_parts/armor
	category = list(POD_FAB_CATEGORY_ARMOR)
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000)


// MARK: Spacepod modules
/datum/design/pod_fuel_tank
	construction_time = 100
	name = "Топливный бак челнока"
	desc = "Топливный бак объемом в 1000 литров."
	id = "pod_fuel_tank"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 1, RESEARCH_TREE_MATERIALS = 1)
	build_type = PODFAB
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/spacepod_module/fuel_tank
	category = list(POD_FAB_CATEGORY_PARTS)

/datum/design/pod_fuel_tank_large
	construction_time = 200
	name = "Большой топливный бак челнока"
	desc = "Топливный бак объемом в 2000 литров."
	id = "pod_fuel_tank_large"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_MATERIALS = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 15000)
	build_path = /obj/item/spacepod_module/fuel_tank/large
	category = list(POD_FAB_CATEGORY_PARTS)

/datum/design/pod_battery
	construction_time = 150
	name = "Аккумуляторная батарея челнока"
	desc = "Аккумуляторная батарея челнока на 5 КВатт. Необходимый модуль для электропитания челнока."
	id = "pod_battery"
	req_tech = list(RESEARCH_TREE_MATERIALS = 1, RESEARCH_TREE_POWERSTORAGE = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000)
	build_path = /obj/item/spacepod_module/battery/full
	category = list(POD_FAB_CATEGORY_PARTS)

/datum/design/pod_fuel_pump
	construction_time = 50
	name = "Топливный насос челнока"
	desc = "Топливный насос для перекачки топлива от баков к двигателям."
	id = "pod_fuel_pump"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/spacepod_module/fuel_pump
	category = list(POD_FAB_CATEGORY_PARTS)

/datum/design/pod_engine
	construction_time = 250
	name = "Двигатель челнока"
	desc = "Плазменный реактивно-импульсный двигатель космического челнока."
	id = "pod_engine"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_PROGRAMMING = 3)
	build_type = PODFAB
	materials = list(MAT_METAL = 15000, MAT_GLASS = 2000, MAT_PLASMA = 5000)
	build_path = /obj/item/spacepod_module/fuel_tank/engine
	category = list(POD_FAB_CATEGORY_PARTS)

/datum/design/pod_engine_speedy
	construction_time = 300
	name = "Форсажный двигатель челнока"
	desc = "Плазменный реактивно-импульсный двигатель космического челнока. Двигатель с куда большей тягой, но и с большим расходом топлива."
	id = "pod_engine_speedy"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PROGRAMMING = 3)
	build_type = PODFAB
	materials = list(MAT_METAL = 25000, MAT_GLASS = 5000, MAT_PLASMA = 10000)
	build_path = /obj/item/spacepod_module/fuel_tank/engine/heavy
	category = list(POD_FAB_CATEGORY_PARTS)

/datum/design/pod_apu
	construction_time = 150
	name = "Вспомогательная силовая установка челнока"
	desc = "Вспомогательная силовая установка, необходимый модуль для запуска челнока."
	id = "pod_apu"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_PLASMA = 1000)
	build_path = /obj/item/spacepod_module/fuel_tank/engine/apu
	category = list(POD_FAB_CATEGORY_PARTS)

/datum/design/pod_gyroscope
	construction_time = 150
	name = "Гироскопический стабилизатор"
	desc = "Вспомогательная силовая установка, необходимый модуль для запуска челнока."
	id = "pod_gyroscope"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 1, RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_MAGNETS = 3)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 3000)
	build_path = /obj/item/spacepod_module/gyroscope
	category = list(POD_FAB_CATEGORY_PARTS)

/datum/design/pod_weapon_turret
	construction_time = 250
	name = "Модуль турельного вооружения"
	desc = "Турель, устанавливаемая на челнок для ведения кругового обстрела с установленного оружия. Имеет два универсальных слота под оружие."
	id = "pod_weapon_turret"
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_ENGINEERING = 3)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_GOLD = 1000)
	build_path = /obj/item/spacepod_module/weapon/turret
	category = list(POD_FAB_CATEGORY_WEAPONRY)

/datum/design/pod_armor_light
	construction_time = 100
	name = "Модуль внутренней бронеобшивки."
	desc = "Защищает внутренние модули челнока от повреждений."
	id = "pod_armor_light"
	req_tech = list(RESEARCH_TREE_COMBAT = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_MATERIALS = 3)
	build_type = PODFAB
	materials = list(MAT_METAL = 5000, MAT_PLASMA = 2000)
	build_path = /obj/item/spacepod_module/armor/light
	category = list(POD_FAB_CATEGORY_ARMOR)

/datum/design/pod_armor_heavy
	construction_time = 200
	name = "Модуль тяжелой внутренней бронеобшивки."
	desc = "Защищает внутренние модули челнока от повреждений. Имеет больший запас прочности."
	id = "pod_armor_heavy"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_MATERIALS = 3)
	build_type = PODFAB
	materials = list(MAT_METAL = 15000, MAT_PLASMA = 10000)
	build_path = /obj/item/spacepod_module/armor/heavy
	category = list(POD_FAB_CATEGORY_ARMOR)

/datum/design/pod_life_support
	construction_time = 100
	name = "Модуль жизнеобеспечения."
	desc = "Модуль жизнеобеспечения космического челнока. Необходимый модуль если вы хотите полетать в челноке без скафандра."
	id = "pod_life_support"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2500)
	build_path = /obj/item/spacepod_module/life_support
	category = list(POD_FAB_CATEGORY_MISC)

/datum/design/pod_passenger_seat
	construction_time = 100
	name = "Модуль пассажирского сиденья."
	desc = "Дополнительное сиденье в челноке, увеличивает возможное количество пассажиров."
	id = "pod_passenger_seat"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 7500, MAT_GLASS = 2500)
	build_path = /obj/item/spacepod_module/passenger_seat
	category = list(POD_FAB_CATEGORY_MISC)

/datum/design/pod_extinguisher
	construction_time = 100
	name = "Модуль пожаротушения челнока."
	desc = "Позволяет тушить пожары внутренних модулей. Имеет три одноразовых заряда."
	id = "pod_extinguisher"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_TOXINS = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_GOLD = 1000)
	build_path = /obj/item/spacepod_module/fire_extingusher
	category = list(POD_FAB_CATEGORY_MISC)

/datum/design/pod_key_lock
	construction_time = 50
	name = "Модуль замка челнока."
	desc = "Модуль для запирания челнока ключом."
	id = "pod_key_lock"
	req_tech = list(RESEARCH_TREE_MATERIALS = 1, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/spacepod_module/key_lock/auto_id
	category = list(POD_FAB_CATEGORY_MISC)

/datum/design/pod_key
	construction_time = 100
	name = "Заготовка ключа от челнока"
	desc = "Позволяет изготовить заготовку ключа для замка челнока."
	id = "podkey"
	req_tech = list(RESEARCH_TREE_MATERIALS = 1, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/spacepod_key
	category = list(POD_FAB_CATEGORY_MISC)

/datum/design/pod_catapult
	construction_time = 100
	name = "Модуль экстренного катапультирования."
	desc = "Модуль аварийного катапультирования из челнока в случае критических повреждений."
	id = "pod_catapult"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 4)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000)
	build_path = /obj/item/spacepod_module/catapult_module
	category = list(POD_FAB_CATEGORY_MISC)

/datum/design/pod_misc_tracker
	construction_time = 100
	name = "Модуль маячка"
	desc = "Позволяет найти космический челнок в специальной консоли."
	id = "podmisc_tracker"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2) //Materials 2: easy to get, no trackers with 0 science progress
	build_type = PODFAB
	materials = list(MAT_METAL=5000)
	build_path = /obj/item/spacepod_module/tracker
	category = list(POD_FAB_CATEGORY_MISC)
