//===== Vox food =====
//Bad tech
/obj/item/flashlight
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/flashlight/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 8, \
	nutritional_value = 2, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/clothing/head/hardhat
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/clothing/head/hardhat/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 8, \
	nutritional_value = 2, \
	)

/obj/item/holosign_creator
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/holosign_creator/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 3, \
	)

/obj/item/signmaker
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/signmaker/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 3, \
	)

/obj/item/pipe_painter
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/pipe_painter/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 10, \
	nutritional_value = 3, \
	)

/obj/item/airlock_painter
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/airlock_painter/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 10, \
	nutritional_value = 3, \
	)

/obj/item/laser_pointer
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/laser_pointer/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/radio
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/radio/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 10, \
	nutritional_value = 5, \
	)

/obj/item/gps
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/gps/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 15, \
	nutritional_value = 3, \
	)


//Medium tech
/obj/item/t_scanner
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/t_scanner/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 2, \
	)

/obj/item/slime_scanner
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/slime_scanner/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	)

/obj/item/sensor_device
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/sensor_device/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	)

/obj/item/mining_scanner
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/mining_scanner/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 15, \
	)

/obj/item/pinpointer
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/pinpointer/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	)

//Используемые на карбонах
/obj/item/healthanalyzer
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/healthanalyzer/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 3, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/bodyanalyzer
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/bodyanalyzer/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 4, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/bodyanalyzer/advanced/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 4, \
	nutritional_value = 50, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/plant_analyzer
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/plant_analyzer/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 4, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/autopsy_scanner
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/autopsy_scanner/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/reagent_scanner
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/reagent_scanner/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/reagent_scanner/adv/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 40, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/analyzer
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/analyzer/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 15, \
	)

/obj/item/melee/baton/security
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/melee/baton/security/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 10, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/melee/baton/security/cattleprod/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 5, \
	is_only_grab_intent = TRUE, \
	)



//Good tech
/obj/item/circuitboard
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/circuitboard/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 3, \
	)

/obj/item/borg/upgrade
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/borg/upgrade/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 3, \
	)

/obj/item/multitool
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/multitool/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 5, \
	nutritional_value = 10, \
	)

/obj/item/multitool/abductor/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 5, \
	nutritional_value = 50, \
	)

/obj/item/multitool/ai_detect/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 5, \
	nutritional_value = 50, \
	)

/obj/item/radio/headset
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/radio/headset/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/pda
	material_type = MATERIAL_CLASS_TECH
	light_on = FALSE
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 2
	light_power = 1
	is_eatable = TRUE

/obj/item/pda/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 10, \
	nutritional_value = 5, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/paicard
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/paicard/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 10, \
	nutritional_value = 15, \
	)

/obj/item/machineprototype
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/machineprototype/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 20, \
	nutritional_value = 15, \
	)

/obj/item/mobcapsule //lazarus
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/mobcapsule/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 30, \
	)

/obj/item/camera_bug	//Hakuna matata
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/camera_bug/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 4, \
	nutritional_value = 30, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/door_remote
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/door_remote/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 5, \
	nutritional_value = 80, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/encryptionkey
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/encryptionkey/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 30, \
	)

/obj/item/implanter
	is_eatable = TRUE

/obj/item/implanter/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 15, \
	)

/obj/item/radio/beacon
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/radio/beacon/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 30, \
	)

/obj/item/aicard	//тяжело жуется
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/aicard/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 40, \
	nutritional_value = 5, \
	)

/obj/item/holder/drone
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/holder/drone/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 10, \
	nutritional_value = 15, \
	)

//Parts
/obj/item/pod_parts/core
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/pod_parts/core/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 20, \
	nutritional_value = 10, \
	)

/obj/item/airlock_electronics
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/airlock_electronics/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 10, \
	)

/obj/item/airalarm_electronics
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/airalarm_electronics/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 10, \
	)

/obj/item/apc_electronics
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/apc_electronics/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	)

/obj/item/assembly
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/assembly/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	)

/obj/item/stock_parts
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/stock_parts/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 5, \
	)

/obj/item/stock_parts/capacitor/adv/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/scanning_module/adv/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/manipulator/nano/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/micro_laser/high/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/matter_bin/adv/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/capacitor/super/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/scanning_module/phasic/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/manipulator/pico/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/micro_laser/ultra/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/matter_bin/super/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/capacitor/quadratic/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 60, \
	)	

/obj/item/stock_parts/scanning_module/triphasic/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 60, \
	)	
	
/obj/item/stock_parts/manipulator/femto/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 60, \
	)	

/obj/item/stock_parts/micro_laser/quadultra/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 60, \
	)

/obj/item/stock_parts/matter_bin/bluespace/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 60, \
	)

//Syndie devices
/obj/item/rad_laser	//health analyzer с радиацией. Смаковать таким одно удовольствие. Если конечно найдут.
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/rad_laser/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 20, \
	nutritional_value = 30, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/jammer
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/jammer/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 80, \
	)

/obj/item/teleporter	//Нет, это не хайриск, это синди-телепортер
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/teleporter/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 8, \
	nutritional_value = 120, \
	)

/obj/item/batterer
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/batterer/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 6, \
	nutritional_value = 100, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/card/emag		//Каждый кусочек по ощущениям растекается словно мед по твоим воксовым кубам...
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/card/emag/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 10, \
	nutritional_value = 200, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/card/emag_broken
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/card/emag_broken/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 10, \
	nutritional_value = 50, \
	)

/obj/item/card/data/clown
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/card/data/clown/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	max_bites = 1000, \
	nutritional_value = 1, \
	)

/obj/item/access_control
	material_type = MATERIAL_CLASS_TECH
	is_eatable = TRUE

/obj/item/access_control/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = src.material_type, \
	nutritional_value = 10, \
	)
