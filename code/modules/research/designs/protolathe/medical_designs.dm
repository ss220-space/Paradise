/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/adv_reagent_scanner
	id = "adv_reagent_scanner"
	req_tech = list("biotech" = 3, "magnets" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/reagent_scanner/adv
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/bluespacebeaker
	id = "bluespacebeaker"
	req_tech = list("bluespace" = 6, "materials" = 5, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 3000, MAT_PLASMA = 3000, MAT_DIAMOND = 250, MAT_BLUESPACE = 250)
	build_path = /obj/item/reagent_containers/glass/beaker/bluespace
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/noreactbeaker
	id = "splitbeaker"
	req_tech = list("materials" = 3, "engineering" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/noreact
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyborg_analyzer
	id = "cyborg_analyzer"
	req_tech = list("programming" = 2, "biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/robotanalyzer
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/healthanalyzer_upgrade
	id = "healthanalyzer_upgrade"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 20)
	build_path = /obj/item/healthupgrade
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/dna_notepad
	id = "dna_notepad"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/dna_notepad
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/bodyanalyzer
	id = "handheld_body_analyzer"
	req_tech = list("biotech" = 6, "materials" = 7, "magnets" = 5, "programming" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 2000, MAT_SILVER = 600)
	build_path = /obj/item/bodyanalyzer/rnd
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/handheld_defib_adv
	id = "handheld_defib_adv"
	req_tech = list("biotech" = 7, "materials" = 6, "magnets" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_GOLD = 1000, MAT_TITANIUM = 500)
	build_path = /obj/item/handheld_defibrillator/advanced
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/defib
	id = "defib"
	req_tech = list("materials" = 7, "biotech" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000, MAT_SILVER = 1000)
	build_path = /obj/item/defibrillator
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/compact_defib
	id = "compact_defib"
	req_tech = list("materials" = 7, "biotech" = 7, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 2000)
	build_path = /obj/item/defibrillator/compact
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/defib_mount
	id = "defib_mount"
	req_tech = list("magnets" = 3, "biotech" = 3, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/mounted/frame/defib_mount
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/sensor_device
	id = "sensor_device"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/sensor_device
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/mmi
	id = "mmi"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 2)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	construction_time = 75
	build_path = /obj/item/mmi
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/robotic_brain
	id = "mmi_robotic"
	req_tech = list("programming" = 5, "biotech" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1700, MAT_GLASS = 1350, MAT_GOLD = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/mmi/robotic_brain
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/mmi_radio_upgrade
	id = "mmi_radio_upgrade"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 2)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 200)
	construction_time = 50
	build_path = /obj/item/mmi_radio_upgrade
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/nanopaste
	id = "nanopaste"
	req_tech = list("materials" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/stack/nanopaste
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/reagent_scanner
	id = "reagent_scanner"
	req_tech = list("magnets" = 2, "plasmatech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/reagent_scanner
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/upgraded_hypospray
	id = "upgraded_hypospray"
	req_tech = list("plasmatech" = 4, "biotech" = 6, "materials" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 800, MAT_SILVER = 400, MAT_GOLD = 600)
	build_path = /obj/item/reagent_containers/hypospray/safety/upgraded
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/scalpel_laser1
	id = "scalpel_laser1"
	req_tech = list("biotech" = 2, "materials" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1500)
	build_path = /obj/item/scalpel/laser/laser1
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/scalpel_laser2
	id = "scalpel_laser2"
	req_tech = list("biotech" = 3, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1500, MAT_SILVER = 1000)
	build_path = /obj/item/scalpel/laser/laser2
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/scalpel_laser3
	id = "scalpel_laser3"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/scalpel/laser/laser3
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/scalpel_manager
	id = "scalpel_manager"
	req_tech = list("biotech" = 4, "materials" = 8, "magnets" = 5, "programming" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_GOLD = 1000, MAT_DIAMOND = 1000)
	build_path = /obj/item/scalpel/laser/manager
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/retractor_laser
	id = "retractor_laser"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/retractor/laser
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/hemostat_laser
	id = "hemostat_laser"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2500, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/hemostat/laser
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/surgicaldrill_laser
	id = "surgicaldrill_laser"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 6000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/surgicaldrill/laser
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/circular_laser
	id = "circular_laser"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 6000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/circular_saw/laser
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/bonesetter_laser
	id = "bonesetter_laser"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/bonesetter/laser
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/item/laserfullkit
	id = "laser_fullsurgerykit"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_path = /obj/item/storage/toolbox/surgery/advanced
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 13000, MAT_GLASS = 10000, MAT_SILVER = 6000, MAT_GOLD = 6000)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/alienscalpel
	id = "alien_scalpel"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/scalpel/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/alienhemostat
	id = "alien_hemostat"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/hemostat/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/alienretractor
	id = "alien_retractor"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/retractor/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/aliensaw
	id = "alien_saw"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/circular_saw/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/aliendrill
	id = "alien_drill"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/surgicaldrill/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/aliencautery
	id = "alien_cautery"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/cautery/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/alienbonegel
	id = "alien_bonegel"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/bonegel/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/alienbonesetter
	id = "alien_bonesetter"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/bonesetter/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/alienfixovein
	id = "alien_fixovein"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/FixOVein/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/alienfullkit
	id = "alien_fullsurgerykit"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/storage/toolbox/surgery/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 34500, MAT_SILVER = 16000, MAT_PLASMA = 5500, MAT_TITANIUM = 13500)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_welding
	id = "ci-welding"
	req_tech = list("materials" = 4, "biotech" = 4, "engineering" = 5, "plasmatech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 600, MAT_GLASS = 400)
	build_path = /obj/item/organ/internal/cyberimp/eyes/shield
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_breather
	id = "ci-breather"
	req_tech = list("materials" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 35
	materials = list(MAT_METAL = 600, MAT_GLASS = 250)
	build_path = /obj/item/organ/internal/cyberimp/mouth/breathing_tube
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_surgical
	id = "ci-surgey"
	req_tech = list("materials" = 3, "engineering" = 3, "biotech" = 3, "programming" = 2, "magnets" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/surgery
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_toolset
	id = "ci-toolset"
	req_tech = list("materials" = 3, "engineering" = 4, "biotech" = 4, "powerstorage" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/toolset
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/mantisblade
	id = "ci-mantisblade"
	req_tech = list("materials" = 7, "combat" = 7, "biotech" = 7, "programming" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_TITANIUM = 6000, MAT_DIAMOND = 6000)
	build_path = /obj/item/storage/lockbox/research/mantis
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/tailblade
	id = "ci-laserblade"
	req_tech = null	// Unreachable by tech researching.
	locked = TRUE
	access_requirement = list(ACCESS_ARMORY)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 15000, MAT_URANIUM = 10000, MAT_TITANIUM = 6000, MAT_DIAMOND = 6000)
	build_path = /obj/item/organ/internal/cyberimp/tail/blade/laser
	category = list (PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_atmostoolset
	id = "ci-atmostoolset"
	req_tech = list("materials" = 5, "engineering" = 7, "biotech" = 4, "bluespace" = 6, "powerstorage" = 4, "programming" = 6, "plasmatech" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 8000, MAT_GLASS = 3500, MAT_SILVER = 1500, MAT_TITANIUM = 1000, MAT_DIAMOND = 600, MAT_BLUESPACE = 1000)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/atmostoolset
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_janitorial
	id = "ci-janitorial"
	req_tech = list("materials" = 3, "engineering" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/janitorial
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_botanical
	id = "ci-botanical"
	req_tech = list("materials" = 3, "engineering" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/botanical
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_hacking
	id = "ci-hacking"
	req_tech = list("materials" = 3, "engineering" = 5, "biotech" = 4, "programming" = 4, "abductor" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/hacking
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_diagnostic_hud
	id = "ci-diaghud"
	req_tech = list("materials" = 5, "engineering" = 4, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_medical_hud
	id = "ci-medhud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/medical
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_science_hud
	id = "ci-scihud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/science
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_security_hud
	id = "ci-sechud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4, "combat" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 750, MAT_GOLD = 750)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/security
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_meson
	id = "ci-mesonhud"
	req_tech = list("materials" = 4, "biotech" = 4, "engineering" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_GOLD = 300)
	build_path = /obj/item/organ/internal/cyberimp/eyes/meson
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_xray
	id = "ci-xray"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 8, "magnets" = 5,"plasmatech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_URANIUM = 1000, MAT_DIAMOND = 1000, MAT_BLUESPACE = 1000)
	build_path = /obj/item/organ/internal/cyberimp/eyes/xray
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_thermals
	id = "ci-thermals"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 7, "magnets" = 5,"plasmatech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_DIAMOND = 2000)
	build_path = /obj/item/organ/internal/cyberimp/eyes/thermals
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_antidrop
	id = "ci-antidrop"
	req_tech = list("materials" = 5, "programming" = 6, "biotech" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 400, MAT_GOLD = 400)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_drop
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_antistun
	id = "ci-antistun"
	req_tech = list("materials" = 6, "programming" = 5, "biotech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 1000)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_stun
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_antisleep
	id = "ci-antisleep"
	req_tech = list("materials" = 6, "programming" = 5, "biotech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 1000)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_sleep
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_clownvoice
	id = "ci-clownvoice"
	req_tech = list("materials" = 2, "biotech" = 2)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_BANANIUM = 200)
	build_path = /obj/item/organ/internal/cyberimp/brain/clown_voice
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_nutriment
	id = "ci-nutriment"
	req_tech = list("materials" = 3, "powerstorage" = 4, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_nutriment_plus
	id = "ci-nutrimentplus"
	req_tech = list("materials" = 5, "powerstorage" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_GOLD = 500, MAT_URANIUM = 750)
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment/plus
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cyberimp_reviver
	id = "ci-reviver"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 800, MAT_GLASS = 800, MAT_GOLD = 300, MAT_URANIUM = 500)
	build_path = /obj/item/organ/internal/cyberimp/chest/reviver
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/voice_retranslator
	id = "ci_retranslator"
	req_tech = list("materials" = 5, "programming" = 6, "biotech" = 6, "engineering" = 6, "abductor" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_TITANIUM = 1000, MAT_DIAMOND = 600, MAT_PLASMA = 500)
	build_path = /obj/item/organ/internal/cyberimp/mouth/translator/grey_retraslator
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/implanter
	id = "implanter"
	req_tech = list("materials" = 2, "biotech" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	build_path = /obj/item/implanter
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/implantcase
	id = "implantcase"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/implantcase
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/implant_chem
	id = "implant_chem"
	req_tech = list("materials" = 3, "biotech" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 700)
	build_path = /obj/item/implantcase/chem
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/implant_sadtrombone
	id = "implant_trombone"
	req_tech = list("materials" = 3, "biotech" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_BANANIUM = 500)
	build_path = /obj/item/implantcase/sad_trombone
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/implant_tracking
	id = "implant_tracking"
	req_tech = list("materials" = 2, "biotech" = 3, "magnets" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/implantcase/tracking
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/implant_mindshield
	id = "implant_mindshield"
	req_tech = list("materials" = 3, "biotech" = 5, "magnets" = 4, "programming" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/implantcase/mindshield
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

//Cybernetic organs

/datum/design/cybernetic_eyes
	id = "cybernetic_eyes"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/eyes/cybernetic
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cybernetic_ears
	id = "cybernetic_ears"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/ears/cybernetic
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cybernetic_liver
	id = "cybernetic_liver"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/liver/cybernetic
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cybernetic_kidneys
	id = "cybernetic_kidneys"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/kidneys/cybernetic
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cybernetic_heart
	id = "cybernetic_heart"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/heart/cybernetic
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cybernetic_heart_u
	id = "cybernetic_heart_u"
	req_tech = list("biotech" = 5, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/heart/cybernetic/upgraded
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cybernetic_lungs
	id = "cybernetic_lungs"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/lungs/cybernetic
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cybernetic_lungs_u
	id = "cybernetic_lungs_u"
	req_tech = list("biotech" = 5, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/lungs/cybernetic/upgraded
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/holostretcher
	id = "holo_stretcher"
	req_tech = list("magnets" = 6, "powerstorage" = 4)
	build_path = /obj/item/roller/holo
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_SILVER = 500, MAT_GLASS = 500, MAT_DIAMOND = 200)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/modified_medical_gloves
	id = "modified_medical_gloves"
	req_tech = list("magnets" = 7, "materials" = 7, "programming" = 5, "biotech" = 5)
	build_path = /obj/item/clothing/gloves/color/latex/modified
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_SILVER = 800, MAT_GLASS = 800, MAT_DIAMOND = 600, MAT_GOLD = 400)
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/bbag
	id = "bbag"
	req_tech = null //only for roboquests
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 1200, MAT_GLASS = 800, MAT_DIAMOND = 1200, MAT_GOLD = 400, MAT_BLUESPACE = 2000)
	build_path = /obj/item/bodybag/bluespace
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/adv_drug_storage
	id = "adv_drug_storage"
	req_tech = list("materials" = 4, "bluespace" = 3, "biotech" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 340, MAT_GLASS = 340, MAT_PLASMA = 200, MAT_BLUESPACE = 30)
	build_path = /obj/item/storage/pill_bottle/bluespace
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/inugami_medical_gloves
	id = "medical_gloves_inugami"
	req_tech = list("materials" = 7, "biotech" = 7, "magnets" = 8, "programming" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1200, MAT_GLASS = 1000, MAT_SILVER = 800, MAT_GOLD = 800, MAT_DIAMOND = 1000, MAT_BLUESPACE = 600)
	build_path = /obj/item/clothing/gloves/color/latex/inugami
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/scalpel
	id = "scalpel"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/scalpel
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/circular_saw
	id = "circular_saw"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 6000)
	build_path = /obj/item/circular_saw
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/surgicaldrill
	id = "surgicaldrill"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 6000)
	build_path = /obj/item/surgicaldrill
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/retractor
	id = "retractor"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000)
	build_path = /obj/item/retractor
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/cautery
	id = "cautery"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 750)
	build_path = /obj/item/cautery
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/hemostat
	id = "hemostat"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2500)
	build_path = /obj/item/hemostat
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/bonesetter
	id = "bonesetter"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/bonesetter
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/fixovein
	id = "fixovein"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 3000)
	build_path = /obj/item/FixOVein
	category = list(PROTOLATHE_CATEGORY_MEDICAL)

/datum/design/bonegel
	id = "bonegel"
	req_tech = list("materials" = 1, "biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 6000)
	build_path = /obj/item/bonegel
	category = list(PROTOLATHE_CATEGORY_MEDICAL)
