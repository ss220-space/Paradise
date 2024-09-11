//===== Vox food =====
//Bad tech

/obj/item/flashlight/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 8, \
	nutritional_value = 2, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/clothing/head/hardhat/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 8, \
	nutritional_value = 2, \
	)

/obj/item/holosign_creator/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 3, \
	)

/obj/item/signmaker/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 3, \
	)

/obj/item/pipe_painter/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 10, \
	nutritional_value = 3, \
	)

/obj/item/airlock_painter/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 10, \
	nutritional_value = 3, \
	)

/obj/item/laser_pointer/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/radio/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 10, \
	nutritional_value = 5, \
	)

/obj/item/gps/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 15, \
	nutritional_value = 3, \
	)


//Medium tech

/obj/item/t_scanner/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 2, \
	)

/obj/item/slime_scanner/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	)

/obj/item/sensor_device/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	)

/obj/item/mining_scanner/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 15, \
	)

/obj/item/pinpointer/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	)

//Используемые на карбонах

/obj/item/healthanalyzer/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 3, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/bodyanalyzer/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 4, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/bodyanalyzer/advanced/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 4, \
	nutritional_value = 50, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/plant_analyzer/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 4, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/autopsy_scanner/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/reagent_scanner/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/reagent_scanner/adv/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 40, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/analyzer/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 15, \
	)

/obj/item/melee/baton/security/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 10, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/melee/baton/security/cattleprod/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 5, \
	is_only_grab_intent = TRUE, \
	)




/obj/item/circuitboard/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 3, \
	)

/obj/item/borg/upgrade/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 3, \
	)

/obj/item/multitool/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 5, \
	nutritional_value = 10, \
	)

/obj/item/multitool/abductor/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 5, \
	nutritional_value = 50, \
	)

/obj/item/multitool/ai_detect/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 5, \
	nutritional_value = 50, \
	)

/obj/item/radio/headset/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/pda/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 10, \
	nutritional_value = 5, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/paicard/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 10, \
	nutritional_value = 15, \
	)

/obj/item/machineprototype/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 20, \
	nutritional_value = 15, \
	)

/obj/item/mobcapsule/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 30, \
	)

/obj/item/camera_bug/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 4, \
	nutritional_value = 30, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/door_remote/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 5, \
	nutritional_value = 80, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/encryptionkey/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 30, \
	)

/obj/item/implanter/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 15, \
	)

/obj/item/radio/beacon/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 30, \
	)

/obj/item/aicard/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 40, \
	nutritional_value = 5, \
	)

/obj/item/holder/drone/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 10, \
	nutritional_value = 15, \
	)

/obj/item/pod_parts/core/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 20, \
	nutritional_value = 10, \
	)

/obj/item/airlock_electronics/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 10, \
	)

/obj/item/airalarm_electronics/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 10, \
	)

/obj/item/apc_electronics/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	)

/obj/item/assembly/ComponentInitialize()
	. = ..()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	)

/obj/item/stock_parts/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 5, \
	)

/obj/item/stock_parts/capacitor/adv/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/scanning_module/adv/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/manipulator/nano/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/micro_laser/high/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/matter_bin/adv/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 15, \
	)

/obj/item/stock_parts/capacitor/super/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/scanning_module/phasic/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/manipulator/pico/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/micro_laser/ultra/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/matter_bin/super/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 30, \
	)	

/obj/item/stock_parts/capacitor/quadratic/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 60, \
	)	

/obj/item/stock_parts/scanning_module/triphasic/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 60, \
	)	
	
/obj/item/stock_parts/manipulator/femto/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 60, \
	)	

/obj/item/stock_parts/micro_laser/quadultra/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 60, \
	)

/obj/item/stock_parts/matter_bin/bluespace/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 60, \
	)

/obj/item/rad_laser/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 20, \
	nutritional_value = 30, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/jammer/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 80, \
	)

/obj/item/teleporter/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 8, \
	nutritional_value = 120, \
	)

/obj/item/batterer/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 6, \
	nutritional_value = 100, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/card/emag/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 10, \
	nutritional_value = 200, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/card/emag_broken/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 10, \
	nutritional_value = 50, \
	)

/obj/item/card/data/clown/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	max_bites = 1000, \
	nutritional_value = 1, \
	)

/obj/item/access_control/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_TECH, \
	nutritional_value = 10, \
	)
