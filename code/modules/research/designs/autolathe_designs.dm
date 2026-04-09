///////////////////////////////////
//////////Autolathe Designs ///////
///////////////////////////////////

/datum/design/bucket
	id = "bucket"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/reagent_containers/glass/bucket
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/crowbar
	id = "crowbar"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/crowbar
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/flashlight
	id = "flashlight"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/flashlight
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/extinguisher
	id = "extinguisher"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 90)
	build_path = /obj/item/extinguisher
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/multitool
	id = "multitool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/multitool
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/analyzer
	id = "analyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/analyzer
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/tscanner
	id = "tscanner"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/t_scanner
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/weldingtool
	id = "welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 70, MAT_GLASS = 30)
	build_path = /obj/item/weldingtool
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/mini_weldingtool
	id = "mini_welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weldingtool/mini
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/screwdriver
	id = "screwdriver"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75)
	build_path = /obj/item/screwdriver
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/wirecutters
	id = "wirecutters"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/wirecutters
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/wrench
	id = "wrench"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/wrench
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/welding_helmet
	id = "welding_helmet"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1750, MAT_GLASS = 400)
	build_path = /obj/item/clothing/head/welding
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/cable_coil
	id = "cable_coil"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 5)
	build_path = /obj/item/stack/cable_coil
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)
	maxstack = 30

/datum/design/toolbox
	id = "tool_box"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/storage/toolbox
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/surgery
	id = "sur_kit"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/storage/toolbox/surgery/empty
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/apc_board
	id = "power control"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/apc_electronics
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/access_board
	id = "access_board"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/access_control
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/airlock_board
	id = "airlock_board"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/airlock_electronics
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/syndie_access_control
	id = "syndie_access_board"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/access_control/syndicate
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/firelock_board
	id = "firelock_board"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/firelock_electronics
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/airalarm_electronics
	id = "airalarm_electronics"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/airalarm_electronics
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/firealarm_electronics
	id = "firealarm_electronics"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/firealarm_electronics
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/intercom_electronics
	id = "intercom_electronics"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/intercom_electronics
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/airlock_controller
	id = "airlock_controller"
	build_type = AUTOLATHE
	materials = list(MAT_METAL=100, MAT_GLASS=50)
	build_path = /obj/item/assembly/control/airlock
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/earmuffs
	id = "earmuffs"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/ears/earmuffs
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/pipe_painter
	id = "pipe_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000)
	build_path = /obj/item/pipe_painter
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/window_painter
	id = "window_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000)
	build_path = /obj/item/pipe_painter/window_painter
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/floorpainter
	id = "floor_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 125)
	build_path = /obj/item/floor_painter
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/airlock_painter
	id = "airlock_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/airlock_painter
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/pet_bowl
	id = "pet_bowl"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/glass/pet_bowl
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/metal
	id = "metal"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/metal
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)
	maxstack = 50

/datum/design/glass
	id = "glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/glass
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)
	maxstack = 50

/datum/design/rglass
	desc = "Сталь + Стекло" // because this design is used in ore redemption
	id = "rglass"
	build_type = AUTOLATHE | SMELTER
	materials = list(MAT_METAL = 1000, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/rglass
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)
	maxstack = 50

/datum/design/rods
	id = "rods"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/stack/rods
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)
	maxstack = 50

/datum/design/rcd_ammo
	id = "rcd_ammo"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 48000, MAT_GLASS=24000)
	build_path = /obj/item/rcd_ammo
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/kitchen_knife
	id = "kitchen_knife"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 12000)
	build_path = /obj/item/kitchen/knife
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/fork
	id = "fork"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/kitchen/utensil/fork
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/spoon
	id = "spoon"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/kitchen/utensil/spoon
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/spork
	id = "spork"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/kitchen/utensil/spork
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/tray
	id = "tray"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/storage/bag/tray
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/drinking_glass
	id = "drinking_glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/shot_glass
	id = "shot_glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass/shotglass
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/shaker
	id = "shaker"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1500)
	build_path = /obj/item/reagent_containers/food/drinks/shaker
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/coffeepot
	id = "coffeepot"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 3500)
	build_path = /obj/item/reagent_containers/glass/coffeepot
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/syrup_bottle
	id = "syrup_bottle"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/glass/bottle/syrup_bottle
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/cultivator
	id = "cultivator"
	build_type = AUTOLATHE
	materials = list(MAT_METAL=50)
	build_path = /obj/item/cultivator
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/plant_analyzer
	id = "plant_analyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/plant_analyzer
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/shovel
	id = "shovel"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/shovel
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/spade
	id = "spade"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/shovel/spade
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/hatchet
	id = "hatchet"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 15000)
	build_path = /obj/item/hatchet
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/beaker
	id = "beaker"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/glass/beaker
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/large_beaker
	id = "large_beaker"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 2500)
	build_path = /obj/item/reagent_containers/glass/beaker/large
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/vial
	id = "vial"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 250)
	build_path = /obj/item/reagent_containers/glass/beaker/vial
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/vial_storage_box
	id = "vial_storage_box"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 1500)
	build_path = /obj/item/storage/fancy/vials
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/secure_vial_storage_box
	id = "secure_vial_storage_box"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1500)
	build_path = /obj/item/storage/lockbox/vials
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/healthanalyzer
	id = "healthanalyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/healthanalyzer
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/pillbottle
	id = "pillbottle"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 20)
	build_path = /obj/item/storage/pill_bottle
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/beanbag_slug
	id = "beanbag_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/ammo_casing/shotgun/beanbag
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/rubbershot
	id = "rubber_shot"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/ammo_casing/shotgun/rubbershot
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/c38
	id = "c38"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5900)
	build_path = /obj/item/ammo_box/speedloader/c38
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/c38hp
	id = "c38hp"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 32000)
	build_path = /obj/item/ammo_box/speedloader/c38/hp
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/speedloader45colt
	id = "speedloader9mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/ammo_box/speedloader/rubber45colt/empty
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/c45colt
	id = "c45colt"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30500)
	build_path = /obj/item/ammo_box/c45colt
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/rubber45colt
	id = "rubber45colt"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20000)
	build_path = /obj/item/ammo_box/rubber45colt
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/ap45colt
	id = "ap45colt"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 35000)
	build_path = /obj/item/ammo_box/ap45colt
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/recorder
	id = "recorder"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 60, MAT_GLASS = 30)
	build_path = /obj/item/taperecorder/empty
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/tape
	id = "tape"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 5)
	build_path = /obj/item/tape/random
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/igniter
	id = "igniter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/igniter
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/signaler
	id = "signaler"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 120)
	build_path = /obj/item/assembly/signaler
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_COMMUNICATION)

/datum/design/radio_headset
	id = "radio_headset"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75)
	build_path = /obj/item/radio/headset
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_COMMUNICATION)

/datum/design/bounced_radio
	id = "bounced_radio"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75, MAT_GLASS = 25)
	build_path = /obj/item/radio/off
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_COMMUNICATION)

/datum/design/infrared_emitter
	id = "infrared_emitter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/assembly/infra
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/health_sensor
	id = "health_sensor"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/assembly/health
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/stethoscope
	id = "stethoscope"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/clothing/accessory/stethoscope
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/timer
	id = "timer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/timer
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/voice_analyzer
	id = "voice_analyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/voice
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/noise_analyser
	id = "Noise_analyser"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 10)
	build_path = /obj/item/assembly/voice/noise
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/light_tube
	id = "light_tube"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/light/tube
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/light_bulb
	id = "light_bulb"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/light/bulb
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/camera_assembly
	id = "camera_assembly"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 250)
	build_path = /obj/item/camera_assembly
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/newscaster_frame
	id = "newscaster_frame"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 14000, MAT_GLASS = 8000)
	build_path = /obj/item/mounted/frame/newscaster_frame
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/syringe
	id = "syringe"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 20)
	build_path = /obj/item/reagent_containers/syringe
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/safety_hypo
	id = "safetyhypo"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/hypospray/safety
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/automender
	id = "automender"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/reagent_containers/applicator
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/iv_bag
	id = "iv_bag"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 3000)
	build_path = /obj/item/reagent_containers/iv_bag
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/handheld_defib
	id = "handheld_defibrillator"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000)
	build_path = /obj/item/handheld_defibrillator
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MEDICAL)

/datum/design/prox_sensor
	id = "prox_sensor"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/assembly/prox_sensor
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/foam_dart
	id = "foam_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 900)
	build_path = /obj/item/ammo_box/foambox
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/foam_dart_sniper
	id = "foam_dart_sniper"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1300)
	build_path = /obj/item/ammo_box/foambox/sniper
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/rubber9mm
	id = "rubber9mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20000)
	build_path = /obj/item/ammo_box/rubber9mm
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/enforcermag
	id = "rubber9mmmag"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/ammo_box/magazine/enforcer/empty
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/flamethrower
	id = "flamethrower"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/flamethrower/full
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/rpd
	id = "rpd"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500)
	build_path = /obj/item/rpd
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/rcl
	id = "rcl"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/twohanded/rcl
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/electropack
	id = "electropack"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2500)
	build_path = /obj/item/radio/electropack
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/large_welding_tool
	id = "large_welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 70, MAT_GLASS = 60)
	build_path = /obj/item/weldingtool/largetank
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/handcuffs
	id = "handcuffs"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/restraints/handcuffs
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/receiver
	id = "receiver"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 15000)
	build_path = /obj/item/weaponcrafting/receiver
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/cylinder
	id = "icylinder"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 6000)
	build_path = /obj/item/ammo_box/magazine/internal/cylinder/improvised
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/shotgun_slug
	id = "shotgun_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/sp8box
	id = "fortynrbox"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 45000)
	build_path = /obj/item/ammo_box/fortynr
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/sp8mag
	id = "fortynrmag"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 2500)
	build_path = /obj/item/ammo_box/magazine/sp8/empty
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/sp91rc_box
	id = "9mmTEbox"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30500)
	build_path = /obj/item/ammo_box/dot45NR
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/enforcer/disable
	id = "enforcer_disable"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 25000)
	build_path = /obj/item/ammo_box/enforcer/disabler
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/spectermag_disabler
	id = "spectermag"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 35000)
	build_path = /obj/item/weapon_cell/specter
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/sp91rc_mag
	id = "9mm-te"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/ammo_box/magazine/sp91rc/empty
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/sparkle_a12_mag
	name = "Sparkle-A12 magazine (9mm)"
	id = "sparkle-a12-9mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/ammo_box/magazine/sparkle_a12/empty
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/buckshot_shell
	id = "buckshot_shell"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/buckshot
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/dragonsbreath
	id = "dragonsbreath_shell"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/shotgun_dart
	id = "shotgun_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	build_path = /obj/item/ammo_casing/shotgun/dart
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/incendiary_slug
	id = "incendiary_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/incendiary
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/riot_dart
	id = "riot_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/ammo_casing/caseless/foam_dart/riot
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/riot_dart_sniper
	id = "riot_dart_sniper"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1800)
	build_path = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/riot_darts
	id = "riot_darts"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 26500)
	build_path = /obj/item/ammo_box/foambox/riot
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/riot_darts_sniper
	id = "riot_darts_sniper"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 72500)
	build_path = /obj/item/ammo_box/foambox/sniper/riot
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/a357
	id = "a357"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 79250)
	build_path = /obj/item/ammo_box/a357
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/c10mm
	id = "c10mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 45500)
	build_path = /obj/item/ammo_box/m10mm
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/c45
	id = "c45"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30500)
	build_path = /obj/item/ammo_box/c45
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/c9mm
	id = "c9mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30500)
	build_path = /obj/item/ammo_box/c9mm
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/knuckles
	id = "knuckles"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 18000)
	build_path = /obj/item/clothing/gloves/knuckles
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/cleaver
	id = "cleaver"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 18000)
	build_path = /obj/item/kitchen/knife/butcher
	category = list(PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_DINNERWARE)

/datum/design/spraycan
	id = "spraycan"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/toy/crayon/spraycan
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/Spray
	id = "Spray"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 5000)
	build_path = /obj/item/reagent_containers/spray
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_TOOLS)

/datum/design/desttagger
	id = "desttagger"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 125)
	build_path = /obj/item/destTagger
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/handlabeler
	id = "handlabel"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 125)
	build_path = /obj/item/hand_labeler
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/conveyor_belt
	id = "conveyor_belt"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/conveyor_construct
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/conveyor_switch
	id = "conveyor_switch"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 450, MAT_GLASS = 190)
	build_path = /obj/item/conveyor_switch_construct
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/conveyor_belt_placer
	id = "conveyor_belt_placer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000) //This thing doesn't need to be very resource-intensive as the belts are already expensive
	build_path = /obj/item/storage/conveyor
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/mousetrap
	id = "mousetrap"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/assembly/mousetrap
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/vendor
	id = "vendor"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 750, MAT_METAL = 250)
	build_path = /obj/item/circuitboard/vendor
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_ELECTRONICS)

/datum/design/mirror
	id = "mirror"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 2500)	//1.25 glass sheets, broken mirrors will return a shard (1 sheet)
	build_path = /obj/item/mounted/mirror
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/safe_internals
	id = "safe"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/safe_internals
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_CONSTRUCTION)

/datum/design/golem_shell
	id = "golem"
	req_tech = null	// Unreachable by tech researching.
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 40000)
	build_path = /obj/item/golem_shell
	category = list(AUTOLATHE_CATEGORY_IMPORTED)

/datum/design/tts
	id = "tts"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/ttsdevice
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/desk_bell
	id = "desk_bell"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/desk_bell
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)

/datum/design/cap_ammo
	id = "cap_ammo"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100)
	build_path = /obj/item/ammo_box/speedloader/caps
	category = list(PRINTER_CATEGORY_INITIAL, AUTOLATHE_CATEGORY_MISC)
