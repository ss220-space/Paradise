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


// // MARK: Spacepod guns

// /datum/design/pod_gun_taser
// 	construction_time = 200
// 	name = "Spacepod Equipment (Disabler)"
// 	desc = "Allows for the construction of a spacepod mounted disabler."
// 	id = "podgun_taser"
// 	build_type = PODFAB
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_COMBAT = 2)
// 	build_path = /obj/item/spacepod_equipment/weaponry/taser
// 	category = list(POD_FAB_CATEGORY_WEAPONRY)
// 	materials = list(MAT_METAL = 15000)
// 	locked = 1

// /datum/design/pod_gun_btaser
// 	construction_time = 200
// 	name = "Spacepod Equipment (Burst Disabler)"
// 	desc = "Allows for the construction of a spacepod mounted disabler. This is the burst-fire model."
// 	id = "podgun_btaser"
// 	build_type = PODFAB
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_COMBAT = 3)
// 	build_path = /obj/item/spacepod_equipment/weaponry/burst_taser
// 	category = list(POD_FAB_CATEGORY_WEAPONRY)
// 	materials = list(MAT_METAL = 15000,MAT_PLASMA=2000)
// 	locked = 1

// /datum/design/pod_gun_laser
// 	construction_time = 200
// 	name = "Spacepod Equipment (Laser)"
// 	desc = "Allows for the construction of a spacepod mounted laser."
// 	id = "podgun_laser"
// 	build_type = PODFAB
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_PLASMA = 2)
// 	build_path = /obj/item/spacepod_equipment/weaponry/laser
// 	category = list(POD_FAB_CATEGORY_WEAPONRY)
// 	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_GOLD=1000,MAT_SILVER=2000)
// 	locked = 1

// /datum/design/pod_gun_solaris
// 	construction_time = 200
// 	name = "Spacepod Equipment (Heavy laser)"
// 	desc = "Allows for the construction of a spacepod mounted  heavy laser."
// 	id = "podgun_solaris"
// 	build_type = PODFAB
// 	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_ENGINEERING = 4)
// 	build_path = /obj/item/spacepod_equipment/weaponry/solaris
// 	category = list(POD_FAB_CATEGORY_WEAPONRY)
// 	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_GOLD=2000,MAT_SILVER=4000)
// 	locked = 1

// /datum/design/pod_mining_laser_basic
// 	construction_time = 200
// 	name = "Spacepod Equipment (Kinetic Accelerator)"
// 	desc = "Allows for the construction of a kinetic accelerator"
// 	id = "pod_mining_laser_basic"
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_COMBAT = 2)
// 	build_type = PODFAB
// 	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 2000, MAT_URANIUM = 2000)
// 	build_path = /obj/item/spacepod_equipment/weaponry/mining_laser_basic
// 	category = list(POD_FAB_CATEGORY_WEAPONRY)

// /datum/design/pod_mining_laser
// 	construction_time = 200
// 	name = "Spacepod Equipment (Industrial Kinetic Accelerator)"
// 	desc = "Allows for the construction of a industrial kinetic accelerator."
// 	id = "pod_mining_laser"
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 6, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_COMBAT = 4)
// 	build_type = PODFAB
// 	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 2000)
// 	build_path = /obj/item/spacepod_equipment/weaponry/mining_laser
// 	category = list(POD_FAB_CATEGORY_WEAPONRY)


// // MARK: Pacepod misc

// /datum/design/pod_misc_tracker
// 	construction_time = 100
// 	name = "Spacepod Tracking Module"
// 	desc = "Allows for the construction of a Space Pod Tracking Module."
// 	id = "podmisc_tracker"
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 2) //Materials 2: easy to get, no trackers with 0 science progress
// 	build_type = PODFAB
// 	materials = list(MAT_METAL=5000)
// 	build_path = /obj/item/spacepod_equipment/misc/tracker
// 	category = list(POD_FAB_CATEGORY_PARTS)


// // MARK: Spacepod cargo

// /datum/design/pod_cargo_ore
// 	construction_time = 100
// 	name = "Spacepod Ore Storage Module"
// 	desc = "Allows for the construction of a Space Pod Ore Storage Module."
// 	id = "podcargo_ore"
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_ENGINEERING = 2)
// 	build_type = PODFAB
// 	materials = list(MAT_METAL=20000, MAT_GLASS=2000)
// 	build_path = /obj/item/spacepod_equipment/cargo/ore
// 	category = list(POD_FAB_CATEGORY_CARGO)

// /datum/design/pod_cargo_crate
// 	construction_time = 100
// 	name = "Spacepod Crate Storage Module"
// 	desc = "Allows the construction of a Space Pod Crate Storage Module."
// 	id = "podcargo_crate"
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 2) //hollowing out this much of the pod without compromising structural integrity is hard
// 	build_type = PODFAB
// 	materials = list(MAT_METAL=25000)
// 	build_path = /obj/item/spacepod_equipment/cargo/crate
// 	category = list(POD_FAB_CATEGORY_CARGO)


// // MARK: Sec spacepod cargo

// /datum/design/passenger_seat
// 	construction_time = 100
// 	name = "Spacepod Passenger Seat"
// 	desc = "Allows the construction of a Space Pod Passenger Seat Module."
// 	id = "podcargo_sec_seat"
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 1) // Because rule number one of refactoring
// 	build_type = PODFAB
// 	materials = list(MAT_METAL=7500, MAT_GLASS=2500)
// 	build_path = /obj/item/spacepod_equipment/sec_cargo/chair
// 	category = list(POD_FAB_CATEGORY_CARGO)

// /datum/design/loot_box
// 	construction_time = 100
// 	name = "Spacepod Loot Storage Module"
// 	desc = "Allows the construction of a Space Pod Auxillary Cargo Module."
// 	id = "podcargo_sec_lootbox"
// 	req_tech = list(RESEARCH_TREE_MATERIALS = 1) //it's just a set of shelves, It's not that hard to make
// 	build_type = PODFAB
// 	materials = list(MAT_METAL=7500, MAT_GLASS=2500)
// 	build_path = /obj/item/spacepod_equipment/sec_cargo/loot_box
// 	category = list(POD_FAB_CATEGORY_CARGO)

// MARK: Spacepod locators

// /datum/design/pod_basic_locator
// 	construction_time = 100
// 	name = "Модуль поиска астероидов"
// 	desc = "Сканирующее устройство позволяющее определять координаты астероидов в секторе."
// 	id = "pod_locator_basic"
// 	req_tech = list(RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MAGNETS= 5) //Materials 2: easy to get, no trackers with 0 science progress
// 	build_type = PODFAB
// 	materials = list(MAT_METAL=1000, MAT_GLASS=2000, MAT_SILVER=1000)
// 	build_path = /obj/item/spacepod_equipment/locators/basic_pod_locator
// 	category = list(POD_FAB_CATEGORY_PARTS)


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
	name = "Аккумуляторная батареия челнока"
	desc = "Аккумуляторная батареия челнока на 5 КВатт. Необходимый модуль для электропитания челнока."
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
	name = "Формажный двигатель челнока"
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
	desc = "Турель устанавливаемая на челнок для ведения кругового обстрела с установленного оружия. Имеет два универсальных слота под оружие."
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
	build_path = /obj/item/spacepod_equipment/key
	category = list(POD_FAB_CATEGORY_PARTS)

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
