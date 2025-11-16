/////////////////////////////////////////
///////////////////MOD///////////////////
/////////////////////////////////////////

/datum/design/mod_shell
	name = "Оболочка МЭК"
	id = "mod_shell"
	build_type = MECHFAB
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 5000)
	construction_time = 25 SECONDS
	build_path = /obj/item/mod/construction/shell
	category = list("MODsuit Construction")

/datum/design/mod_helmet
	name = "Шлем МЭК"
	id = "mod_helmet"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/helmet
	category = list("MODsuit Construction")

/datum/design/mod_chestplate
	name = "Нагрудник МЭК"
	id = "mod_chestplate"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/chestplate
	category = list("MODsuit Construction")

/datum/design/mod_gauntlets
	name = "Перчатки МЭК"
	id = "mod_gauntlets"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/gauntlets
	category = list("MODsuit Construction")

/datum/design/mod_boots
	name = "Ботинки МЭК"
	id = "mod_boots"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/boots
	category = list("MODsuit Construction")

/datum/design/mod_plating
	name = "Стандартная обшивка МЭК"
	id = "mod_plating_standard"
	build_type = MECHFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_PLASMA = 1000)
	construction_time = 15 SECONDS
	build_path = /obj/item/mod/construction/plating
	category = list("MODsuit Construction")

/datum/design/mod_plating/engineering
	name = "Обшивка МЭК класса \"Искра\""
	id = "mod_plating_engineering"
	build_path = /obj/item/mod/construction/plating/engineering
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_GOLD = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ENGINE)

/datum/design/mod_plating/atmospheric
	name = "Обшивка МЭК класса \"Пламень\""
	id = "mod_plating_atmospheric"
	build_path = /obj/item/mod/construction/plating/atmospheric
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_TITANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ATMOSPHERICS)

/datum/design/mod_plating/medical
	name = "Обшивка МЭК класса \"Пульс\""
	id = "mod_plating_medical"
	build_path = /obj/item/mod/construction/plating/medical
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_SILVER = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_MEDICAL)

/datum/design/mod_plating/security
	name = "Обшивка МЭК класса \"Страж\""
	id = "mod_plating_security"
	build_path = /obj/item/mod/construction/plating/security
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_URANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ARMORY)

/datum/design/mod_plating/cosmohonk
	name = "Обшивка МЭК класса \"Гогот\""
	id = "mod_plating_cosmohonk"
	build_path = /obj/item/mod/construction/plating/cosmohonk
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_BANANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_CLOWN)

/datum/design/mod_skin
	name = "Устройство покраса МЭК"
	id = "mod_skin_civilian"
	build_type = MECHFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_PLASMA = 1000)
	construction_time = 5 SECONDS
	build_path = /obj/item/mod/universal_modkit
	category = list("MODsuit Construction")

/datum/design/module
	name = "Модуль вместимости"
	id = "mod_storage"
	build_type = MECHFAB
	construction_time = 5 SECONDS
	materials = list(MAT_METAL = 2500, MAT_GLASS = 10000)
	build_path = /obj/item/mod/module/storage
	category = list("MODsuit Modules")

/datum/design/module/mod_storage_expanded
	name = "Модуль повышенной вместимости"
	id = "mod_storage_expanded"
	req_tech = list("materials" = 7, "powerstorage" = 6, "engineering" = 6)
	materials = list(MAT_METAL = 2500, MAT_URANIUM = 10000)
	build_path = /obj/item/mod/module/storage/large_capacity

/datum/design/module/mod_storage_syndicate
	name = "Модуль вместимости Синдиката"
	id = "mod_storage_syndicate"
	req_tech = list("materials" = 7, "powerstorage" = 7, "engineering" = 7, "syndicate" = 3)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Evidence Raid  to function.
	build_path = /obj/item/mod/module/storage/syndicate

/datum/design/module/mod_visor_medhud
	name = "Модуль медицинского ИЛС"
	id = "mod_visor_medhud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4)
	materials = list(MAT_SILVER = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/medhud

/datum/design/module/mod_visor_diaghud
	name = "Модуль диагностического ИЛС"
	id = "mod_visor_diaghud"
	req_tech = list("materials" = 5, "engineering" = 4, "programming" = 4, "biotech" = 4)
	materials = list(MAT_GOLD = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/diaghud

/datum/design/module/mod_visor_sechud
	name = "Модуль охранного ИЛС"
	id = "mod_visor_sechud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4, "combat" = 3)
	materials = list(MAT_TITANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/sechud

/datum/design/module/mod_visor_meson
	name = "Модуль мезонного ИЛС"
	id = "mod_visor_meson"
	req_tech = list("materials" = 4, "biotech" = 4, "engineering" = 4)
	materials = list(MAT_URANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/meson

/datum/design/module/mod_visor_welding
	name = "Модуль защиты от сварки"
	id = "mod_welding"
	req_tech = list("materials" = 4, "biotech" = 4, "engineering" = 5, "plasmatech" = 4)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/welding

/datum/design/module/mod_visor_night
	name = "Модуль ночного видения"
	id = "mod_night_visor"
	req_tech = list("materials" = 6, "biotech" = 7, "engineering" = 6, "plasmatech" = 6)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000)
	build_path =/obj/item/mod/module/visor/night

/datum/design/module/mod_t_ray
	name = "Модуль ТГц сканирования"
	id = "mod_t_ray"
	req_tech = list("materials" = 2, "engineering" = 2)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/t_ray

/datum/design/module/mod_stealth
	name = "Модуль маскировки"
	id = "mod_stealth"
	req_tech = list("combat" = 7, "magnets" = 6, "syndicate" = 3)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //It's a cloaking device, while not foolproof I am making it expencive
	build_path = /obj/item/mod/module/stealth

/datum/design/module/mod_jetpack
	name = "Модуль ионного джетпака"
	id = "mod_jetpack"
	req_tech = list("materials" = 7, "magnets" = 6, "engineering" = 6)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000) //Jetpacks are rare, so might as well make it... sorta expencive, I guess.
	build_path = /obj/item/mod/module/jetpack

/datum/design/module/mod_magboot
	name = "Модуль магбутсов"
	id = "mod_magboot"
	req_tech = list("materials" = 4, "magnets" = 4, "engineering" = 5)
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/mod/module/magboot

/datum/design/module/mod_adv_magboot
	name = "Модуль продвинутых магбутсов"
	id = "mod_adv_magboot"
	req_tech = list("materials" = 7, "magnets" = 7, "engineering" = 7)
	materials = list(MAT_METAL = 15000, MAT_SILVER = 5500, MAT_GOLD = 6500, MAT_TITANIUM = 6500)
	build_path = /obj/item/mod/module/magboot/advanced

/datum/design/module/mod_rad_protection
	name = "Модуль радиационного сканирования"
	id = "mod_rad_protection"
	req_tech = list("materials" = 4, "magnets" = 4, "combat" = 2)
	materials = list(MAT_URANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/rad_protection

/datum/design/module/mod_emp_shield
	name = "Модуль защиты от ЭМИ"
	id = "mod_emp_shield"
	req_tech = list("combat" = 4, "magnets" = 6, "syndicate" = 2)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000) //While you are not EMP proof with this, your modules / cell are, and that is quite strong.
	build_path = /obj/item/mod/module/emp_shield

/datum/design/module/mod_flashlight
	name = "Модуль фонарика"
	id = "mod_flashlight"
	req_tech = list("magnets" = 2, "engineering" = 2, "plasmatech" = 2)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/flashlight

/datum/design/module/mod_flashdark
	name = "Модуль темнарика"
	id = "mod_flashdark"
	req_tech = list("magnets" = 2, "engineering" = 2, "plasmatech" = 2)
	materials = list(MAT_METAL = 400, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/flashlight/darkness

/datum/design/module/mod_tether
	name = "Модуль экстренной крюк-кошки"
	id = "mod_tether"
	req_tech = list("materials" = 3, "magnets" = 2, "engineering" = 3)
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/mod/module/grappling_hook

/datum/design/module/mod_reagent_scanner
	name = "Модуль сканера реагентов"
	id = "mod_reagent_scanner"
	req_tech = list("magnets" = 2, "engineering" = 2, "plasmatech" = 2)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/reagent_scanner

/datum/design/module/mod_gps
	name = "Модуль ГПС"
	id = "mod_gps"
	req_tech = list("materials" = 2, "bluespace" = 2)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/gps

/datum/design/module/mod_thermal_regulator
	name = "Модуль регуляции температуры"
	id = "mod_thermal_regulator"
	req_tech = list("materials" = 5, "plasmatech" = 4, "magnets" = 4)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/thermal_regulator

/datum/design/module/mod_injector
	name = "Модуль инъектора"
	id = "mod_injector"
	req_tech = list("biotech" = 4, "materials" = 4, "magnets" = 5)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/injector

/datum/design/module/mod_monitor
	name = "Модуль монитора экипажа"
	id = "mod_monitor"
	req_tech = list("biotech" = 3, "materials" = 5, "magnets" = 4)
	materials = list(MAT_METAL = 1500, MAT_GLASS = 3000)
	build_path = /obj/item/mod/module/monitor

/datum/design/module/defibrillator
	name = "Модуль дефибриллятора"
	id = "mod_defib"
	req_tech = list("materials" = 5, "biotech" = 6, "powerstorage" = 6)
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/defibrillator

/datum/design/module/mod_bikehorn
	name = "Модуль гудка"
	id = "mod_bikehorn"
	req_tech = list("programming" = 3, "materials" = 3)
	materials = list(MAT_METAL = 2500, MAT_BANANIUM = 2000)
	build_path = /obj/item/mod/module/bikehorn

/datum/design/module/mod_waddle
	name = "Модуль покачивания"
	id = "mod_waddle"
	req_tech = list("programming" = 3, "materials" = 3)
	materials = list(MAT_METAL = 2500, MAT_BANANIUM = 2000)
	build_path = /obj/item/mod/module/waddle

/datum/design/module/mod_clamp
	name = "Модуль гидравлической клешни"
	id = "mod_clamp"
	req_tech = list("programming" = 3, "materials" = 3)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/clamp

/datum/design/module/mod_drill
	name = "Модуль дрели"
	id = "mod_drill"
	req_tech = list("materials" = 4, "powerstorage" = 5, "engineering" = 5)
	materials = list(MAT_METAL = 12500, MAT_DIAMOND = 4000) //This drills **really** fast
	build_path = /obj/item/mod/module/drill

/datum/design/module/mod_orebag
	name = "Модуль хранилища руды"
	id = "mod_orebag"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 3)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/orebag

/datum/design/module/mod_dna_lock
	name = "Модуль ДНК-блокировки"
	id = "mod_dna_lock"
	req_tech = list("materials" = 6, "powerstorage" = 5, "engineering" = 6)
	materials = list(MAT_METAL = 12500, MAT_DIAMOND = 4000) //EMP beats it, but still, anti theft is a premium price in these here parts partner
	build_path = /obj/item/mod/module/dna_lock

/datum/design/module/mod_holster
	name = "Модуль кобуры"
	id = "mod_holster"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 3)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/holster

/datum/design/module/mod_sonar
	name = "Модуль сонара"
	id = "mod_sonar"
	req_tech = list("materials" = 6, "powerstorage" = 5, "engineering" = 5)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/active_sonar

/datum/design/module/pathfinder
	name = "Модуль \"Первопроходец\""
	id = "mod_pathfinder"
	req_tech = list("materials" = 6, "powerstorage" = 5, "engineering" = 5)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/pathfinder

/datum/design/module/plasma_stabilizer
	name = "Модуль стабилизации плазмы"
	id = "mod_plasmastable"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 3)
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/plasma_stabilizer

/datum/design/module/plate_compression
	name = "Модуль уплотнения костюма"
	id = "mod_compression"
	req_tech = list("materials" = 6, "powerstorage" = 5, "engineering" = 6, "syndicate" = 2)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/plate_compression

/datum/design/module/status_readout
	name = "Модуль оценки состояния"
	id = "mod_status_readout"
	req_tech = list("materials" = 5, "powerstorage" = 5, "biotech" = 6)
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/status_readout

/datum/design/module/mod_teleporter
	name = "Модуль телепортера"
	id = "mod_teleporter"
	req_tech = list("combat" = 7, "engineering" = 7, "bluespace" = 7, "plasmatech" = 7, "toxins" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires bluespace anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/teleporter

/datum/design/module/mod_kinesis
	name = "Модуль \"Кинезис\""
	id = "mod_kinesis"
	req_tech = list("combat" = 7, "engineering" = 7, "bluespace" = 7, "plasmatech" = 7, "toxins" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Gravitational anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/kinesis

/datum/design/module/mod_firewall
	name = "Модуль огненного щита"
	id = "mod_firewall"
	req_tech = list("combat" = 7, "engineering" = 7, "bluespace" = 7, "plasmatech" = 7, "toxins" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Pyroclastic anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/firewall

/datum/design/module/mod_arcshield
	name = "Модуль аномальной защиты"
	id = "mod_arcshield"
	req_tech = list("combat" = 7, "engineering" = 7, "bluespace" = 7, "plasmatech" = 7, "toxins" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Flux anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/teslawall

/datum/design/module/mod_vortex
	name = "Модуль вихревого дробовика"
	id = "mod_vortex"
	req_tech = list("combat" = 7, "engineering" = 7, "bluespace" = 7, "plasmatech" = 7, "toxins" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Vortex anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/vortex_shotgun

/datum/design/module/mod_flamethrower
	name = "Модуль огнемёта"
	id = "mod_flamethrower"
	req_tech = list("combat" = 5, "engineering" = 5, "plasmatech" = 4)
	materials = list(MAT_METAL = 5000, MAT_GLASS = 4000, MAT_PLASMA = 6000)
	build_path = /obj/item/mod/module/flamethrower

/datum/design/module/mod_medbeam
	name = "Модуль мед-пушки"
	id = "mod_medbeam"
	req_tech = list("materials" = 7, "engineering" = 7, "powerstorage" = 7, "biotech" = 7)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/medbeam

/datum/design/module/mod_jumpjet
	name = "Модуль прыжковых двигателей"
	id = "mod_jumpjet"
	req_tech = list("materials" = 6, "powerstorage" = 5, "bluespace" = 5, "plasmatech" = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/jump_jet

/datum/design/module/mod_mouthhole
	name = "Модуль пищеприёмника"
	id = "mod_mouthhole"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 3)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/mouthhole

/datum/design/module/mod_longfall
	name = "Модуль амортизации"
	id = "mod_longfall"
	req_tech = list("materials" = 6, "powerstorage" = 5, "bluespace" = 5, "plasmatech" = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/longfall

/datum/design/module/mod_health_analyzer
	name = "Модуль анализатора здоровья"
	id = "mod_health_analyzer"
	req_tech = list("materials" = 2, "powerstorage" = 2, "biotech" = 3)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/health_analyzer

/datum/design/module/mod_quick_carry
	name = "Модуль пожарного хвата"
	id = "mod_quick_carry"
	req_tech = list("materials" = 5, "powerstorage" = 4, "biotech" = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/quick_carry

/datum/design/module/mod_patienttransport
	name = "Модуль мешков для тел пациентов"
	id = "mod_patienttransport"
	req_tech = list("materials" = 5, "powerstorage" = 4, "biotech" = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/criminalcapture/patienttransport

/datum/design/module/mod_antigrav
	name = "Модуль антигравитации"
	id = "mod_antigrav"
	req_tech = list("combat" = 7, "engineering" = 7, "bluespace" = 7, "plasmatech" = 7, "toxins" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000)
	build_path = /obj/item/mod/module/anomaly_locked/antigrav

/datum/design/module/mod_criminalcapture
	name = "Модуль мешков для тел заключённых"
	id = "mod_criminalcapture"
	req_tech = list("materials" = 5, "powerstorage" = 4, "biotech" = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/criminalcapture

/datum/design/module/mod_magnetic_harness
	name = "Модуль магнитного ремня"
	id = "mod_magnetic_harness"
	req_tech = list("materials" = 6, "powerstorage" = 5, "biotech" = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_SILVER = 4000)
	build_path = /obj/item/mod/module/magnetic_harness

/datum/design/module/mod_pepper_shoulders
	name = "Модуль перцового газа"
	id = "mod_pepper_shoulders"
	req_tech = list("materials" = 3, "powerstorage" = 2, "biotech" = 3)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/pepper_shoulders

/datum/design/module/mod_megaphone
	name = "Модуль мегафона"
	id = "mod_megaphone"
	req_tech = list("materials" = 3, "powerstorage" = 5, "biotech" = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/megaphone

/datum/design/module/mod_quick_cuff
	name = "Модуль быстрого сковывания"
	id = "mod_quick_cuff"
	req_tech = list("materials" = 4, "powerstorage" = 5, "engineering" = 4)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/quick_cuff

/datum/design/module/activation_upgrade
	name = "Модуль ускорения запуска костюма"
	id = "mod_activation_upgrade"
	req_tech = list("materials" = 5, "powerstorage" = 5, "engineering" = 6, "biotech" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000)
	build_path = /obj/item/mod/module/activation_upgrade

/datum/design/module/deployed_upgrade
	name = "Модуль ускорения костюма"
	id = "mod_speed_upgrade"
	req_tech = list("materials" = 5, "powerstorage" = 5, "engineering" = 6, "biotech" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000)
	build_path = /obj/item/mod/module/deployed_upgrade

/datum/design/module/organizer
	name = "Модуль замены органов"
	id = "mod_organizer_upgrade"
	req_tech = list("materials" = 5, "powerstorage" = 5, "biotech" = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000)
	build_path = /obj/item/mod/module/organizer
