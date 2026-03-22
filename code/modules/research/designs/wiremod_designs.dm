/datum/design/integrated_circuit
	id = "integrated_circuit"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/integrated_circuit
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)
	materials = list(MAT_GLASS = 500, MAT_METAL = 500)

/datum/design/circuit_multitool
	id = "circuit_multitool"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/multitool/circuit
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)
	materials = list(MAT_GLASS = 500, MAT_METAL = 500)

/datum/design/usb_cable
	id = "usb_cable"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/usb_cable
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)
	// Yes, it would make sense to make them take plastic, but then less people would make them, and I think they're cool
	materials = list(MAT_METAL = 1250)

/datum/design/component
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = CIRCUIT_COMPONENT_COST)
	category = list(
		CIRCUIT_IMPRINTER_CATEGORY_CIRCUIT,
	)

/datum/design/component/New()
	. = ..()
	if(!build_path)
		return

	var/obj/item/circuit_component/component_path = build_path
	desc = initial(component_path.desc)

/datum/design/component/arithmetic
	id = "comp_arithmetic"
	build_path = /obj/item/circuit_component/arithmetic

/datum/design/component/trigonometry
	id = "comp_trigonometry"
	build_path = /obj/item/circuit_component/trigonometry

/datum/design/component/arctan2
	id = "comp_arctan2"
	build_path = /obj/item/circuit_component/arctan2

/datum/design/component/clock
	id = "comp_clock"
	build_path = /obj/item/circuit_component/clock

/datum/design/component/comparison
	id = "comp_comparison"
	build_path = /obj/item/circuit_component/compare/comparison

/datum/design/component/logic
	id = "comp_logic"
	build_path = /obj/item/circuit_component/compare/logic

/datum/design/component/toggle
	id = "comp_toggle"
	build_path = /obj/item/circuit_component/compare/toggle

/datum/design/component/delay
	id = "comp_delay"
	build_path = /obj/item/circuit_component/delay

/datum/design/component/format
	id = "comp_format"
	build_path = /obj/item/circuit_component/format

/datum/design/component/format_assoc
	id = "comp_format_assoc"
	build_path = /obj/item/circuit_component/format/assoc

/datum/design/component/index
	id = "comp_index"
	build_path = /obj/item/circuit_component/index

/datum/design/component/index_assoc
	id = "comp_index_assoc"
	build_path = /obj/item/circuit_component/index/assoc_string

/datum/design/component/length
	id = "comp_length"
	build_path = /obj/item/circuit_component/length

/datum/design/component/light
	id = "comp_light"
	build_path = /obj/item/circuit_component/light

/datum/design/component/not
	id = "comp_not"
	build_path = /obj/item/circuit_component/not

/datum/design/component/random
	id = "comp_random"
	build_path = /obj/item/circuit_component/random

/datum/design/component/binary_conversion
	id = "comp_binary_convert"
	build_path = /obj/item/circuit_component/binary_conversion

/datum/design/component/decimal_conversion
	id = "comp_decimal_convert"
	build_path = /obj/item/circuit_component/decimal_conversion

/datum/design/component/species
	id = "comp_species"
	build_path = /obj/item/circuit_component/species

/datum/design/component/speech
	id = "comp_speech"
	build_path = /obj/item/circuit_component/speech

/datum/design/component/laserpointer
	id = "comp_laserpointer"
	build_path = /obj/item/circuit_component/laserpointer

/datum/design/component/timepiece
	id = "comp_timepiece"
	build_path = /obj/item/circuit_component/timepiece

/datum/design/component/tostring
	id = "comp_tostring"
	build_path = /obj/item/circuit_component/tostring

/datum/design/component/tonumber
	id = "comp_tonumber"
	build_path = /obj/item/circuit_component/tonumber

/datum/design/component/typecheck
	id = "comp_typecheck"
	build_path = /obj/item/circuit_component/compare/typecheck

/datum/design/component/concat
	id = "comp_concat"
	build_path = /obj/item/circuit_component/concat

/datum/design/component/textcase
	id = "comp_textcase"
	build_path = /obj/item/circuit_component/textcase

/datum/design/component/hear
	id = "comp_hear"
	build_path = /obj/item/circuit_component/hear

/datum/design/component/contains
	id = "comp_string_contains"
	build_path = /obj/item/circuit_component/compare/contains

/datum/design/component/self
	id = "comp_self"
	build_path = /obj/item/circuit_component/self

/datum/design/component/radio
	id = "comp_radio"
	build_path = /obj/item/circuit_component/radio

/datum/design/component/gps
	id = "comp_gps"
	build_path = /obj/item/circuit_component/gps

/datum/design/component/direction
	id = "comp_direction"
	build_path = /obj/item/circuit_component/direction

/datum/design/component/reagentscanner
	id = "comp_reagents"
	build_path = /obj/item/circuit_component/reagentscanner

/datum/design/component/health
	id = "comp_health"
	build_path = /obj/item/circuit_component/health

/datum/design/component/compare/health_state
	id = "comp_health_state"
	build_path = /obj/item/circuit_component/compare/health_state

// /datum/design/component/matscanner
// 	id = "comp_matscanner"
// 	build_path = /obj/item/circuit_component/matscanner

/datum/design/component/split
	id = "comp_split"
	build_path = /obj/item/circuit_component/split

/datum/design/component/pull
	id = "comp_pull"
	build_path = /obj/item/circuit_component/pull

/datum/design/component/soundemitter
	id = "comp_soundemitter"
	build_path = /obj/item/circuit_component/soundemitter

/datum/design/component/mmi
	id = "comp_mmi"
	build_path = /obj/item/circuit_component/mmi

/datum/design/component/router
	id = "comp_router"
	build_path = /obj/item/circuit_component/router

/datum/design/component/multiplexer
	id = "comp_multiplexer"
	build_path = /obj/item/circuit_component/router/multiplexer

/datum/design/component/get_column
	id = "comp_get_column"
	build_path = /obj/item/circuit_component/get_column

/datum/design/component/index_table
	id = "comp_index_table"
	build_path = /obj/item/circuit_component/index_table

/datum/design/component/concat_list
	id = "comp_concat_list"
	build_path = /obj/item/circuit_component/concat_list

/datum/design/component/list_add
	id = "comp_list_add"
	build_path = /obj/item/circuit_component/variable/list/listadd

/datum/design/component/list_remove
	id = "comp_list_remove"
	build_path = /obj/item/circuit_component/variable/list/listremove

/datum/design/component/assoc_list_set
	id = "comp_assoc_list_set"
	build_path = /obj/item/circuit_component/variable/assoc_list/list_set

/datum/design/component/assoc_list_remove
	id = "comp_assoc_list_remove"
	build_path = /obj/item/circuit_component/variable/assoc_list/list_remove

/datum/design/component/list_clear
	id = "comp_list_clear"
	build_path = /obj/item/circuit_component/variable/list/listclear

/datum/design/component/element_find
	id = "comp_element_find"
	build_path = /obj/item/circuit_component/listin

/datum/design/component/select_query
	id = "comp_select_query"
	build_path = /obj/item/circuit_component/select

/datum/design/component/pathfind
	id = "comp_pathfind"
	build_path = /obj/item/circuit_component/pathfind

/datum/design/component/tempsensor
	id = "comp_tempsensor"
	build_path = /obj/item/circuit_component/tempsensor

/datum/design/component/pressuresensor
	id = "comp_pressuresensor"
	build_path = /obj/item/circuit_component/pressuresensor

/datum/design/component/module
	id = "comp_module"
	build_path = /obj/item/circuit_component/module

/datum/design/component/ntnet_receive
	id = "comp_ntnet_receive"
	build_path = /obj/item/circuit_component/ntnet_receive

/datum/design/component/ntnet_send
	id = "comp_ntnet_send"
	build_path = /obj/item/circuit_component/ntnet_send

/datum/design/component/nfc_send
	id = "comp_nfc_send"
	build_path = /obj/item/circuit_component/nfc_send

/datum/design/component/nfc_receive
	id = "comp_nfc_receive"
	build_path = /obj/item/circuit_component/nfc_receive

/datum/design/component/list_literal/nfc_send
	id = "comp_nfc_send_list_literal"
	build_path = /obj/item/circuit_component/list_literal/nfc_send

/datum/design/component/list_literal/ntnet_send
	id = "comp_ntnet_send_list_literal"
	build_path = /obj/item/circuit_component/list_literal/ntnet_send

/datum/design/component/list_literal
	id = "comp_list_literal"
	build_path = /obj/item/circuit_component/list_literal

/datum/design/component/list_assoc_literal
	id = "comp_list_assoc_literal"
	build_path = /obj/item/circuit_component/assoc_literal

/datum/design/component/typecast
	id = "comp_typecast"
	build_path = /obj/item/circuit_component/typecast

/datum/design/component/pinpointer
	id = "comp_pinpointer"
	build_path = /obj/item/circuit_component/pinpointer

/datum/design/component/equipment_action
	id = "comp_equip_action"
	build_path = /obj/item/circuit_component/equipment_action

/datum/design/component/bci/object_overlay
	id = "comp_object_overlay"
	build_path = /obj/item/circuit_component/object_overlay

/datum/design/component/bci/bar_overlay
	id = "comp_bar_overlay"
	build_path = /obj/item/circuit_component/object_overlay/bar

/datum/design/component/bci/vox
	id = "comp_vox"
	build_path = /obj/item/circuit_component/vox

/datum/design/component/bci/thought_listener
	id = "comp_thought_listener"
	build_path = /obj/item/circuit_component/thought_listener

/datum/design/component/bci/target_intercept
	id = "comp_target_intercept"
	build_path = /obj/item/circuit_component/target_intercept

/datum/design/component/bci/counter_overlay
	id = "comp_counter_overlay"
	build_path = /obj/item/circuit_component/counter_overlay

/datum/design/component/bci/reagent_injector
	id = "comp_reagent_injector"
	build_path = /obj/item/circuit_component/reagent_injector

/datum/design/component/bci/install_detector
	id = "comp_install_detector"
	build_path = /obj/item/circuit_component/install_detector

/datum/design/component/foreach
	id = "comp_foreach"
	build_path = /obj/item/circuit_component/foreach

/datum/design/component/filter_list
	id = "comp_filter_list"
	build_path = /obj/item/circuit_component/filter_list

/datum/design/component/id_getter
	id = "comp_id_getter"
	build_path = /obj/item/circuit_component/id_getter

/datum/design/component/id_info_reader
	id = "comp_id_info_reader"
	build_path = /obj/item/circuit_component/id_info_reader

/datum/design/component/id_access_reader
	id = "comp_id_access_reader"
	build_path = /obj/item/circuit_component/id_access_reader

/datum/design/component/setter_trigger
	id = "comp_set_variable_trigger"
	build_path = /obj/item/circuit_component/variable/setter/trigger

/datum/design/component/view_sensor
	id = "comp_view_sensor"
	build_path = /obj/item/circuit_component/view_sensor

/datum/design/component/access_checker
	id = "comp_access_checker"
	build_path = /obj/item/circuit_component/compare/access

/datum/design/component/list_pick
	id = "comp_list_pick"
	build_path = /obj/item/circuit_component/list_pick

/datum/design/component/list_pick_assoc
	id = "comp_assoc_list_pick"
	build_path = /obj/item/circuit_component/list_pick/assoc

// /datum/design/component/wire_bundle
// 	id = "comp_wire_bundle"
// 	build_path = /obj/item/circuit_component/wire_bundle

/datum/design/component/wirenet_receive
	id = "comp_wirenet_receive"
	build_path = /obj/item/circuit_component/wirenet_receive

/datum/design/component/wirenet_send
	id = "comp_wirenet_send"
	build_path = /obj/item/circuit_component/wirenet_send

/datum/design/component/wirenet_send_literal
	id = "comp_wirenet_send_literal"
	build_path = /obj/item/circuit_component/list_literal/wirenet_send

/datum/design/component/bci/bci_camera
	id = "comp_camera_bci"
	build_path = /obj/item/circuit_component/remotecam/bci

/datum/design/compact_remote_shell
	id = "compact_remote_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/compact_remote
	materials = list(MAT_GLASS = 1000, MAT_METAL = 2500)
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/controller_shell
	id = "controller_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/controller
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_METAL = 3500)
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/scanner_shell
	id = "scanner_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/wiremod_scanner
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_METAL = 3500)
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/keyboard_shell
	id = "keyboard_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/keyboard_shell
	materials = list(MAT_GLASS = 1000, MAT_METAL = 5000)
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/gun_shell
	id = "gun_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/gun/energy/wiremod_gun
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_METAL = 5000, MAT_PLASMA = 500)
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/bot_shell
	id = "bot_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/shell/bot
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_METAL = 5000)
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/money_bot_shell
	id = "money_bot_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	build_path = /obj/item/shell/money_bot
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_METAL = 5000, MAT_GOLD = 200)
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/drone_shell
	id = "drone_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ENGINEERING = 4)
	build_path = /obj/item/shell/drone
	build_type = PROTOLATHE
	materials = list(
		MAT_GLASS = 1000,
		MAT_METAL = 5500,
		MAT_GOLD = 500,
	)
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/manipulator_shell
	id = "manipulator_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ENGINEERING = 4)
	build_path = /obj/item/shell/manipulator
	build_type = PROTOLATHE
	materials = list(
		MAT_GLASS = 1000,
		MAT_METAL = 5500,
		MAT_TITANIUM = 1000,
	)
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/server_shell
	id = "server_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ENGINEERING = 6)
	materials = list(
		MAT_GLASS = 2500,
		MAT_METAL = 7500,
		MAT_GOLD = 1000,
	)
	build_path = /obj/item/shell/server
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/airlock_shell
	id = "door_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 3)
	materials = list(
		MAT_GLASS = 5000,
		MAT_METAL = 10000,
	)
	build_path = /obj/item/shell/airlock
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/dispenser_shell
	id = "dispenser_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ENGINEERING = 4)
	materials = list(
		MAT_GLASS = 2500,
		MAT_METAL = 7500,
	)
	build_path = /obj/item/shell/dispenser
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/bci_shell
	id = "bci_shell"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_BIOTECH = 3)
	materials = list(
		MAT_GLASS = 1000,
		MAT_METAL = 4000,
	)
	build_path = /obj/item/shell/bci
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

// /datum/design/scanner_gate_shell
// 	id = "scanner_gate_shell"
// 	materials = list(
// 		MAT_GLASS = 2000,
// 		MAT_METAL = 6000,
// 	)
// 	build_path = /obj/item/shell/scanner_gate
// 	build_type = PROTOLATHE
// 	category = list(
// 		PROTOLATHE_CATEGORY_CIRCUITRY,
// 	)

/datum/design/bci_implanter
	id = "bci_implanter"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/bci_implanter
	category = list(
		CIRCUIT_IMPRINTER_CATEGORY_MEDICAL,
	)

/datum/design/assembly_shell
	id = "assembly_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	materials = list(MAT_GLASS = 1000, MAT_METAL = 2500)
	build_path = /obj/item/assembly/wiremod
	build_type = PROTOLATHE
	category = list(
		PROTOLATHE_CATEGORY_CIRCUITRY,
	)

/datum/design/module/mod_module_shell
	id = "module_shell"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_PROGRAMMING = 2)
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/mod/module/circuit

// /datum/design/undertile_shell
// 	id = "undertile_shell"
// 	materials = list(
// 		MAT_GLASS= 500,
// 		MAT_METAL= 2500,
// 	)
// 	build_path = /obj/item/undertile_circuit
// 	build_type = PROTOLATHE
// 	category = list(
// 		PROTOLATHE_CATEGORY_CIRCUITRY,
// 	)

// /datum/design/wallmount_shell
// 	id = "wallmount_shell"
// 	materials = list(
// 		MAT_GLASS= 1000,
// 		MAT_METAL= 5000,
// 	)
// 	build_path = /obj/item/wallframe/circuit
// 	build_type = PROTOLATHE
// 	category = list(
// 		PROTOLATHE_CATEGORY_CIRCUITRY,
// 	)
