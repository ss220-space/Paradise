///////////////////////////////////
//////////Computer Boards//////////
///////////////////////////////////

/datum/design/aicore
	id = "aicore"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/aicore
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/aifixer
	id = "aifixer"
	req_tech = list("programming" = 4, "magnets" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/aifixer
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/aiupload
	id = "aiupload"
	req_tech = list("programming" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/aiupload
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/atmosalerts
	id = "atmosalerts"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/atmos_alert
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/air_management
	id = "air_management"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/air_management
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/seccamera
	id = "seccamera"
	req_tech = list("programming" = 2, "combat" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/camera
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/*	/datum/design/clonecontrol
	id = "clonecontrol"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/cloning
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)
*/
/datum/design/comconsole
	id = "comconsole"
	req_tech = list("programming" = 3, "magnets" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/communications
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/crewconsole
	id = "crewconsole"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/crew
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/borgupload
	id = "borgupload"
	req_tech = list("programming" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/borgupload
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/scan_console
	id = "scan_console"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/scan_consolenew
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/dronecontrol
	id = "dronecontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/drone_control
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/mechacontrol
	id = "mechacontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha_control
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/idcardconsole
	id = "idcardconsole"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/card
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/mechapower
	id = "mechapower"
	req_tech = list("programming" = 3, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mech_bay_power_console
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/med_data
	id = "med_data"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/med_data
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/message_monitor
	id = "message_monitor"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/message_monitor
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/operating
	id = "operating"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/operating
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/pandemic
	id = "pandemic"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pandemic
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/powermonitor
	id = "powermonitor"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/powermonitor
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/prisonmanage
	id = "prisonmanage"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/prisoner
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/brigcells
	id = "brigcells"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/brigcells
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/rdconsole
	id = "rdconsole"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/rdconsole
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/rdservercontrol
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/rdservercontrol
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/robocontrol
	id = "robocontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/robotics
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/roboquest
	id = "roboquest"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/roboquest
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/secdata
	id = "secdata"
	req_tech = list("programming" = 2, "combat" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/secure_data
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/solarcontrol
	id = "solarcontrol"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/solar_control
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/sm_monitor
	id = "sm_monitor"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/sm_monitor
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/spacepodlocator
	id = "spacepodc"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pod_locater
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/ordercomp
	id = "ordercomp"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/ordercomp
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/supplycomp
	id = "supplycomp"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/supplycomp
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/supplyquest
	id = "supplyquest"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/supplyquest
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/questcons
	id = "questcons"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/questcons
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/teleconsole
	id = "teleconsole"
	req_tech = list("programming" = 3, "bluespace" = 3, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/teleconsole_robotics
	id = "teleconsole_robotics"
	req_tech = list("programming" = 2, "bluespace" = 3, "plasmatech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter/robotics
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/GAC
	id = "GAC"
	req_tech = list("programming" = 3, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/air_management
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/tank_control
	id = "tankcontrol"
	req_tech = list("programming" = 3, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/large_tank_control
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/xenobiocamera
	id = "xenobioconsole"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/xenobiology
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)

/datum/design/honkputer
	id = "honkputer"
	req_tech = list("programming" = 5, "bluespace" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000)
	build_path = /obj/item/circuitboard/HONKputer
	category = list(CIRCUIT_IMPRINTER_CATEGORY_COMPUTER)
