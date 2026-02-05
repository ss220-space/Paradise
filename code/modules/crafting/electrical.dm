//ASSEMBLY

/datum/crafting_recipe/assemble_drill
	name = "собрать термосверло"
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/mecha_parts/mecha_equipment/drill = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stack/rods = 2,
		/obj/item/assembly/timer = 1
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
		/obj/item/assembly/timer = 1
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
		/obj/item/assembly/prox_sensor = 1
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
		/obj/item/stack/cable_coil = 5
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
		/obj/item/assembly/voice/noise = 1,
		/obj/item/assembly/voice = 1,
		/obj/item/stack/cable_coil = 5
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
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stack/sheet/metal = 5
	)
	result = /obj/item/flashlight/lamp
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_ASSEMBLY

//DISASSEMBLY

/datum/crafting_recipe/disassemble_stunprod
	name = "разобрать оглушающий прут"
	result = list(
		/obj/item/stack/rods = 1,
		/obj/item/assembly/igniter = 1
	)
	reqs = list(/obj/item/melee/baton/security/cattleprod = 1)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_voice_modulator
	name = "разобрать маску для модуляции голоса"
	result = list(
		/obj/item/clothing/mask/gas = 1,
		/obj/item/assembly/voice = 1
	)
	reqs =  list(/obj/item/clothing/mask/gas/voice_modulator)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_radio
	name = "разобрать радио"
	result = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/assembly/voice = 1
	)
	reqs = list(/obj/item/radio = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 20
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY

/datum/crafting_recipe/disassemble_flashlight
	name = "разобрать фонарик"
	result = list(
		/obj/item/light/bulb = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stock_parts/capacitor = 1
	)
	reqs = list(/obj/item/flashlight = 1)
	blacklist = list(
		/obj/item/flashlight/slime,
		/obj/item/flashlight/pen,
		/obj/item/flashlight/lantern,
		/obj/item/flashlight/flare/glowstick,
		/obj/item/flashlight/flare
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
		/obj/item/stack/ore/iron = 5
	)
	reqs = list(/obj/item/flashlight/lamp = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 40
	category = CAT_ELECTRICAL
	subcategory = CAT_ELECTRICAL_DISASSEMBLY
