//MARK: ASSEMBLY

/datum/crafting_recipe/assemble_makeshift_flashlight
	name = "изготовить самодельный фонарик"
	reqs = list(
		/obj/item/stack/tape_roll = 5,
		/obj/item/stack/cable_coil = 2,
		/obj/item/light/bulb = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/mounted/frame/light_switch = 1,
	)
	result = /obj/item/flashlight/makeshift
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_mod_health_analyzer
	name = "изготовить модуль сканера тела (МЭК)"
	reqs = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/usb_cable = 1,
	)
	result = /obj/item/mod/module/health_analyzer
	time = 20
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_drill
	name = "собрать термосверло"
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/mecha_parts/mecha_equipment/drill = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stack/rods = 2,
		/obj/item/assembly/timer = 1,
	)
	result = /obj/item/thermal_drill
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 60
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_alternative_drill
	name = "собрать термосверло (хирургическая дрель)"
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/surgicaldrill = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stack/rods = 2,
		/obj/item/assembly/timer = 1,
	)
	result = /obj/item/thermal_drill
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 60
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_diamond_drill
	name = "собрать термосверло с алмазным наконечником"
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stack/rods = 2,
		/obj/item/assembly/prox_sensor = 1,
	) // Not a timer because the system sees a diamond drill as a drill too, letting you make both otherwise.
	result = /obj/item/thermal_drill/diamond_drill
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 60
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_tuned_anomalous_teleporter
	name = "настроить аномальный телепортер"
	reqs = list(
		/obj/item/relict_production/strange_teleporter = 1,
		/obj/item/gps = 1,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stack/sheet/metal = 2,
		/obj/item/stack/cable_coil = 5,
	)
	result = /obj/item/assembly/tuned_anomalous_teleporter
	tools = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 300
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_voice_modulator
	name = "собрать маску для модуляции голоса"
	reqs = list(
		/obj/item/clothing/mask/gas = 1,
		/obj/item/assembly/voice = 1,
		/obj/item/stack/cable_coil = 5,
	)
	result = /obj/item/clothing/mask/gas/voice_modulator
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_lamp
	name = "собрать настольную лампу"
	reqs = list(
		/obj/item/light/bulb = 1,
		/obj/item/mounted/frame/light_fixture/small = 1,
		/obj/item/stack/cable_coil = 10,
		/obj/item/stock_parts/cell = 1,
		/obj/item/mounted/frame/light_switch = 1,
		/obj/item/lamp_disassembled = 1,
		/obj/item/circuit_component/light_switch = 1,
	)
	result = /obj/item/flashlight/lamp
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_green_lamp
	name = "собрать зелёную настольную лампу"
	reqs = list(
		/obj/item/light/bulb = 1,
		/obj/item/mounted/frame/light_fixture/small = 1,
		/obj/item/stack/cable_coil = 10,
		/obj/item/stock_parts/cell = 1,
		/obj/item/mounted/frame/light_switch = 1,
		/obj/item/lamp_disassembled/green = 1,
		/obj/item/circuit_component/light_switch = 1,
	)
	result = /obj/item/flashlight/lamp/green
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

/datum/crafting_recipe/assemble_banana_lamp
	name = "собрать банановую настольную лампу"
	reqs = list(
		/obj/item/light/bulb = 1,
		/obj/item/mounted/frame/light_fixture/small = 1,
		/obj/item/stack/cable_coil = 10,
		/obj/item/stock_parts/cell = 1,
		/obj/item/mounted/frame/light_switch = 1,
		/obj/item/lamp_disassembled/bananalamp = 1,
		/obj/item/circuit_component/light_switch = 1,
	)
	result = /obj/item/flashlight/lamp/bananalamp
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

//MARK: DISASSEMBLY

/datum/crafting_recipe/disassemble_stunprod
	name = "разобрать оглушающий прут"
	result = list(
		/obj/item/stack/rods = 1,
		/obj/item/assembly/igniter = 1,
	)
	reqs = list(/obj/item/melee/baton/security/cattleprod = 1)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_voice_modulator
	name = "разобрать маску для модуляции голоса"
	result = list(
		/obj/item/clothing/mask/gas = 1,
		/obj/item/assembly/voice = 1,
	)
	reqs =  list(/obj/item/clothing/mask/gas/voice_modulator)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_flashlight
	name = "разобрать фонарик"
	result = list(
		/obj/item/light/bulb = 1,
		/obj/item/stock_parts/cell = 1,
	)
	reqs = list(/obj/item/flashlight = 1)
	blacklist = list(
		/obj/item/flashlight/slime,
		/obj/item/flashlight/pen,
		/obj/item/flashlight/lantern,
		/obj/item/flashlight/flare/glowstick,
		/obj/item/flashlight/flare,
	)
	tools = list(TOOL_SCREWDRIVER)
	time = 20
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_lamp
	name = "разобрать настольную лампу"
	result = list(
		/obj/item/light/bulb = 1,
		/obj/item/mounted/frame/light_fixture/small = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 1,
		/obj/item/lamp_disassembled = 1,
		/obj/item/circuit_component/light_switch = 1,
	)
	reqs = list(/obj/item/flashlight/lamp = 1)
	blacklist = list(
		/obj/item/flashlight/lamp/green,
		/obj/item/flashlight/lamp/bananalamp,
	)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_green_lamp
	name = "разобрать зелёную настольную лампу"
	result = list(
		/obj/item/light/bulb = 1,
		/obj/item/mounted/frame/light_fixture/small = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 1,
		/obj/item/lamp_disassembled/green = 1,
		/obj/item/circuit_component/light_switch = 1,
	)
	reqs = list(/obj/item/flashlight/lamp/green = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_banana_lamp
	name = "разобрать банановую настольную лампу"
	result = list(
		/obj/item/light/bulb = 1,
		/obj/item/mounted/frame/light_fixture/small = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 1,
		/obj/item/lamp_disassembled/bananalamp = 1,
		/obj/item/grown/bananapeel = 1,
		/obj/item/circuit_component/light_switch = 1,
	)
	reqs = list(/obj/item/flashlight/lamp/bananalamp = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_pda
	name = "разобрать КПК"
	result = list(
		/obj/item/circuit_component/keyboard_shell = 1,
		/obj/item/circuit_component/arithmetic = 1,
		/obj/item/circuit_component/id_info_reader = 1,
		/obj/item/circuit_component/clock = 1,
		/obj/item/circuit_component/light = 1,
		/obj/item/stack/sheet/plastic = 2,
		/obj/item/stack/ore/gold = 2,
		/obj/item/stock_parts/scanning_module/adv = 1,
	)
	reqs = list(/obj/item/pda = 1)
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	time = 60
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_multitool
	name = "разобрать мультитул"
	result = list(
		/obj/item/circuit_component/arithmetic = 1,
		/obj/item/circuit_component/assembly_input = 1,
		/obj/item/circuit_component/assembly_output = 1,
	)
	reqs = list(/obj/item/multitool = 1)
	blacklist = list(
		/obj/item/multitool/abductor,
	)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_cameraflash
	name = "разобрать фотоаппарат"
	result = list(
		/obj/item/circuit_component/camera = 1,
		/obj/item/circuit_component/light = 1,
	)
	reqs = list(/obj/item/flash/cameraflash = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_gps
	name = "разобрать ГПС"
	result = list(
		/obj/item/circuit_component/gps = 1,
		/obj/item/circuit_component/keyboard_shell = 1,
		/obj/item/circuit_component/light = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	reqs = list(/obj/item/gps = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_healthanalyzer
	name = "разобрать ручной сканер тела"
	result = list(
		/obj/item/assembly/health = 1,
		/obj/item/circuit_component/light = 1,
		/obj/item/stock_parts/scanning_module = 1,
	)
	reqs = list(/obj/item/healthanalyzer = 1)
	tools = list(TOOL_SCREWDRIVER)
	blacklist = list(
		/obj/item/healthanalyzer/abductor,
		/obj/item/healthanalyzer/gem_analyzer,
	)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY


