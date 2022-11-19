//===== Vox food =====
//Bad tech
/obj/item/flashlight/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 8
	nutritional_value = 5
	is_only_grab_intent = TRUE	//всё-таки используется в подсвечивании глаз тенеморфам

/obj/item/holosign_creator/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 10

/obj/item/signmaker/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 10

/obj/item/pipe_painter/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 15

/obj/item/airlock_painter/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 15

/obj/item/laser_pointer/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	nutritional_value = 30
	is_only_grab_intent = TRUE	//лазером можно светить в глаза

/obj/item/radio/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 15

/obj/item/gps/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 15
	nutritional_value = 5



//Medium tech
/obj/item/t_scanner/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 2
	nutritional_value = 40

/obj/item/slime_scanner/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 50

/obj/item/sensor_device/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20

/obj/item/mining_scanner/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20

/obj/item/pinpointer/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20

//Используемые на карбонах
/obj/item/healthanalyzer/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 3
	nutritional_value = 40
	is_only_grab_intent = TRUE

/obj/item/bodyanalyzer/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 4
	nutritional_value = 50
	is_only_grab_intent = TRUE

/obj/item/bodyanalyzer/advanced/new_stat_eat()
	. = ..()
	nutritional_value = 150

/obj/item/autopsy_scanner/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 50
	is_only_grab_intent = TRUE

/obj/item/reagent_scanner/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20
	is_only_grab_intent = TRUE

/obj/item/reagent_scanner/adv/new_stat_eat()
	. = ..()
	nutritional_value = 50

/obj/item/analyzer/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20

/obj/item/melee/baton/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 60
	is_only_grab_intent = TRUE

/obj/item/melee/baton/cattleprod/new_stat_eat()
	. = ..()
	nutritional_value = 30



//Good tech
/obj/item/circuitboard/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 3
	nutritional_value = 60

/obj/item/borg/upgrade/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 3
	nutritional_value = 60

/obj/item/multitool/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 5
	nutritional_value = 40

/obj/item/multitool/abductor/new_stat_eat()
	. = ..()
	nutritional_value = 100

/obj/item/multitool/ai_detect/new_stat_eat()
	. = ..()
	nutritional_value = 100

/obj/item/radio/headset/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	nutritional_value = 30
	is_only_grab_intent = TRUE	//чтобы случайно не надкусили

/obj/item/pda/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 15
	is_only_grab_intent = TRUE

/obj/item/paicard/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 30

/obj/item/machineprototype/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 20
	nutritional_value = 30

/obj/item/mobcapsule/new_stat_eat() //lazarus
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 60

/obj/item/camera_bug/new_stat_eat()	//Hakuna matata
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 4
	nutritional_value = 40
	is_only_grab_intent = TRUE

/obj/item/door_remote/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 5
	nutritional_value = 100
	is_only_grab_intent = TRUE

/obj/item/encryptionkey/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	nutritional_value = 15

/obj/item/radio/beacon/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 30

/obj/item/aicard/new_stat_eat()	//тяжело жуется
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 40
	nutritional_value = 5

/obj/item/holder/drone/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 30



//Parts
/obj/item/pod_parts/core/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 20
	nutritional_value = 20

/obj/item/airlock_electronics/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 10

/obj/item/airalarm_electronics/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 10

/obj/item/apc_electronics/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 20

/obj/item/assembly/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 20

/obj/item/stock_parts/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 15

/obj/item/stock_parts/capacitor/adv/new_stat_eat()
	. = ..()
	nutritional_value = 30
/obj/item/stock_parts/scanning_module/adv/new_stat_eat()
	. = ..()
	nutritional_value = 30
/obj/item/stock_parts/manipulator/nano/new_stat_eat()
	. = ..()
	nutritional_value = 30
/obj/item/stock_parts/micro_laser/high/new_stat_eat()
	. = ..()
	nutritional_value = 30
/obj/item/stock_parts/matter_bin/adv/new_stat_eat()
	. = ..()
	nutritional_value = 30

/obj/item/stock_parts/capacitor/super/new_stat_eat()
	. = ..()
	nutritional_value = 60
/obj/item/stock_parts/scanning_module/phasic/new_stat_eat()
	. = ..()
	nutritional_value = 60
/obj/item/stock_parts/manipulator/pico/new_stat_eat()
	. = ..()
	nutritional_value = 60
/obj/item/stock_parts/micro_laser/ultra/new_stat_eat()
	. = ..()
	nutritional_value = 60
/obj/item/stock_parts/matter_bin/super/new_stat_eat()
	. = ..()
	nutritional_value = 60

/obj/item/stock_parts/capacitor/quadratic/new_stat_eat()
	. = ..()
	nutritional_value = 120
/obj/item/stock_parts/scanning_module/triphasic/new_stat_eat()
	. = ..()
	nutritional_value = 120
/obj/item/stock_parts/manipulator/femto/new_stat_eat()
	. = ..()
	nutritional_value = 120
/obj/item/stock_parts/micro_laser/quadultra/new_stat_eat()
	. = ..()
	nutritional_value = 120
/obj/item/stock_parts/matter_bin/bluespace/new_stat_eat()
	. = ..()
	nutritional_value = 120



//Syndie devices
/obj/item/rad_laser/new_stat_eat()	//health analyzer с радиацией. Смаковать таким одно удовольствие. Если конечно найдут.
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 20
	nutritional_value = 30
	is_only_grab_intent = TRUE

/obj/item/jammer/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites =	6
	nutritional_value = 80

/obj/item/teleporter/new_stat_eat()	//Нет, это не хайриск, это синди-телепортер
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 8
	nutritional_value = 120

/obj/item/batterer/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 100
	is_only_grab_intent = TRUE

/obj/item/card/emag/new_stat_eat()		//Каждый кусочек по ощущениям растекается словно мед по твоим воксовым кубам...
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 200
	is_only_grab_intent = TRUE

/obj/item/card/emag_broken/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 50

/obj/item/card/data/clown/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1000
	nutritional_value = 1

