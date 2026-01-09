////////////////////////////////////////
/////////// Mecha Designs //////////////
////////////////////////////////////////
//Cyborg
/datum/design/borg_suit
	id = "borg_suit"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_suit
	materials = list(MAT_METAL=15000)
	construction_time = 50 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG)

/datum/design/borg_chest
	id = "borg_chest"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/chest
	materials = list(MAT_METAL=40000)
	construction_time = 35 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG)

/datum/design/borg_head
	id = "borg_head"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/head
	materials = list(MAT_METAL=5000)
	construction_time = 35 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG)

/datum/design/borg_l_arm
	id = "borg_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_arm
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG)

/datum/design/borg_r_arm
	id = "borg_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_arm
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG)

/datum/design/borg_l_leg
	id = "borg_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_leg
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG)

/datum/design/borg_r_leg
	id = "borg_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_leg
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG)

/datum/design/synthetic_flash
	id = "sflash"
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	construction_time = 10 SECONDS
	build_path = /obj/item/flash/synthetic
	category = list(MECH_FAB_CATEGORY_CYBORG)

//Robot repair
/datum/design/borg_binary_communication
	id = "borg_binary_communication"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/binary_communication_device
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_REPAIR)

/datum/design/borg_radio
	id = "borg_radio"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/radio
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_REPAIR)

/datum/design/borg_actuator
	id = "borg_actuator"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/actuator
	materials = list(MAT_METAL=3500)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_REPAIR)

/datum/design/borg_diagnosis_unit
	id = "borg_diagnosis_unit"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/diagnosis_unit
	materials = list(MAT_METAL=3500)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_REPAIR)

/datum/design/borg_camera
	id = "borg_camera"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/camera
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_REPAIR)

/datum/design/borg_armor
	id = "borg_armor"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/armour
	materials = list(MAT_METAL=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_REPAIR)

//Ripley
/datum/design/ripley_chassis
	id = "ripley_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ripley
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_RIPLEY)

//Firefighter subtype
/datum/design/firefighter_chassis
	id = "firefighter_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/firefighter
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_FIREFIGHTER)

/datum/design/ripley_torso
	id = "ripley_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_torso
	materials = list(MAT_METAL=20000, MAT_GLASS=7500)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_RIPLEY, MECH_FAB_CATEGORY_FIREFIGHTER)

/datum/design/ripley_left_arm
	id = "ripley_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	materials = list(MAT_METAL=15000)
	construction_time = 15 SECONDS
	category = list(MECH_FAB_CATEGORY_RIPLEY, MECH_FAB_CATEGORY_FIREFIGHTER)

/datum/design/ripley_right_arm
	id = "ripley_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	materials = list(MAT_METAL=15000)
	construction_time = 15 SECONDS
	category = list(MECH_FAB_CATEGORY_RIPLEY, MECH_FAB_CATEGORY_FIREFIGHTER)

/datum/design/ripley_left_leg
	id = "ripley_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	materials = list(MAT_METAL=15000)
	construction_time = 15 SECONDS
	category = list(MECH_FAB_CATEGORY_RIPLEY, MECH_FAB_CATEGORY_FIREFIGHTER)

/datum/design/ripley_right_leg
	id = "ripley_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	materials = list(MAT_METAL=15000)
	construction_time = 15 SECONDS
	category = list(MECH_FAB_CATEGORY_RIPLEY, MECH_FAB_CATEGORY_FIREFIGHTER)

//Clarke

/datum/design/clarke_chassis
	id = "clarke_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/clarke
	materials = list(MAT_METAL=25000, MAT_SILVER=10000, MAT_PLASMA=5000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_CLARKE)

/datum/design/clarke_torso
	id = "clarkee_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_torso
	materials = list(MAT_METAL=20000)
	construction_time = 18 SECONDS
	category = list(MECH_FAB_CATEGORY_CLARKE)

/datum/design/clarke_head
	id = "clarke_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_head
	materials = list(MAT_METAL=10000, MAT_GLASS=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_CLARKE)

/datum/design/clarke_left_arm
	id = "clarke_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_left_arm
	materials = list(MAT_METAL=12000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CLARKE)

/datum/design/clarke_right_arm
	id = "clarke_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_right_arm
	materials = list(MAT_METAL=12000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CLARKE)

/datum/design/clarke_left_leg
	id = "clarke_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_left_leg
	materials = list(MAT_METAL=15000, MAT_TITANIUM=20000)
	construction_time = 13  SECONDS
	category = list(MECH_FAB_CATEGORY_CLARKE)

/datum/design/clarke_right_leg
	id = "clarke_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_right_leg
	materials = list(MAT_METAL=15000, MAT_TITANIUM=20000)
	construction_time = 13 SECONDS
	category = list(MECH_FAB_CATEGORY_CLARKE)

//Odysseus
/datum/design/odysseus_chassis
	id = "odysseus_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/odysseus
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_ODYSSEUS)

/datum/design/odysseus_torso
	id = "odysseus_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	materials = list(MAT_METAL=12000)
	construction_time = 18 SECONDS
	category = list(MECH_FAB_CATEGORY_ODYSSEUS)

/datum/design/odysseus_head
	id = "odysseus_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_head
	materials = list(MAT_METAL=6000, MAT_GLASS=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_ODYSSEUS)

/datum/design/odysseus_left_arm
	id = "odysseus_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	materials = list(MAT_METAL=6000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_ODYSSEUS)

/datum/design/odysseus_right_arm
	id = "odysseus_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	materials = list(MAT_METAL=6000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_ODYSSEUS)

/datum/design/odysseus_left_leg
	id = "odysseus_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	materials = list(MAT_METAL=7000)
	construction_time = 13 SECONDS
	category = list(MECH_FAB_CATEGORY_ODYSSEUS)

/datum/design/odysseus_right_leg
	id = "odysseus_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	materials = list(MAT_METAL=7000)
	construction_time = 13 SECONDS
	category = list(MECH_FAB_CATEGORY_ODYSSEUS)

//Gygax
/datum/design/gygax_chassis
	id = "gygax_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/gygax
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_GYGAX)

/datum/design/gygax_torso
	id = "gygax_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_torso
	materials = list(MAT_METAL=20000, MAT_GLASS=10000, MAT_DIAMOND=2000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_GYGAX)

/datum/design/gygax_head
	id = "gygax_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_head
	materials = list(MAT_METAL=10000, MAT_GLASS=5000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_GYGAX)

/datum/design/gygax_left_arm
	id = "gygax_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_GYGAX)

/datum/design/gygax_right_arm
	id = "gygax_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_GYGAX)

/datum/design/gygax_left_leg
	id = "gygax_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_GYGAX)

/datum/design/gygax_right_leg
	id = "gygax_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_GYGAX)

/datum/design/gygax_armor
	id = "gygax_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_armour
	materials = list(MAT_METAL=15000, MAT_DIAMOND=10000, MAT_TITANIUM=10000)
	construction_time = 60 SECONDS
	category = list(MECH_FAB_CATEGORY_GYGAX)

//Durand
/datum/design/durand_chassis
	id = "durand_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/durand
	materials = list(MAT_METAL=25000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_DURAND)

/datum/design/durand_torso
	id = "durand_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_torso
	materials = list(MAT_METAL=25000, MAT_GLASS=10000, MAT_SILVER=10000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_DURAND)

/datum/design/durand_head
	id = "durand_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_head
	materials = list(MAT_METAL=10000, MAT_GLASS=15000, MAT_SILVER=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DURAND)

/datum/design/durand_left_arm
	id = "durand_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	materials = list(MAT_METAL=10000, MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DURAND)

/datum/design/durand_right_arm
	id = "durand_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	materials = list(MAT_METAL=10000, MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DURAND)

/datum/design/durand_left_leg
	id = "durand_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	materials = list(MAT_METAL=15000, MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DURAND)

/datum/design/durand_right_leg
	id = "durand_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	materials = list(MAT_METAL=15000, MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DURAND)

/datum/design/durand_armor
	id = "durand_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_armor
	materials = list(MAT_METAL=30000, MAT_URANIUM=25000, MAT_TITANIUM=20000)
	construction_time = 60 SECONDS
	category = list(MECH_FAB_CATEGORY_DURAND)

//Rover(DarkDurand)
/datum/design/rover_chassis
	id = "rover_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/rover
	materials = list(MAT_METAL=25000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_ROVER)

/datum/design/rover_torso
	id = "rover_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_torso
	materials = list(MAT_METAL=25000, MAT_GLASS=10000, MAT_SILVER=10000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_ROVER)

/datum/design/rover_head
	id = "rover_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_head
	materials = list(MAT_METAL=10000, MAT_GLASS=15000, MAT_SILVER=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_ROVER)

/datum/design/rover_left_arm
	id = "rover_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_left_arm
	materials = list(MAT_METAL=10000, MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_ROVER)

/datum/design/rover_right_arm
	id = "rover_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_right_arm
	materials = list(MAT_METAL=10000, MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_ROVER)

/datum/design/rover_left_leg
	id = "rover_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_left_leg
	materials = list(MAT_METAL=15000, MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_ROVER)

/datum/design/rover_right_leg
	id = "rover_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_right_leg
	materials = list(MAT_METAL=15000, MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_ROVER)

/datum/design/rover_armor
	id = "rover_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_armor
	materials = list(MAT_METAL=30000, MAT_URANIUM=25000, MAT_PLASMA=15000, MAT_TITANIUM=15000)
	construction_time = 60 SECONDS
	category = list(MECH_FAB_CATEGORY_ROVER)

//Dark Gygax
/datum/design/darkgygax_chassis
	id = "darkgygax_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/darkgygax
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_DARK_GYGAX)

/datum/design/darkgygax_torso
	id = "darkgygax_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_torso
	materials = list(MAT_METAL=20000, MAT_GLASS=10000, MAT_DIAMOND=2000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_DARK_GYGAX)

/datum/design/darkgygax_head
	id = "darkgygax_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_head
	materials = list(MAT_METAL=10000, MAT_GLASS=5000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DARK_GYGAX)

/datum/design/darkgygax_left_arm
	id = "darkgygax_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_left_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DARK_GYGAX)

/datum/design/darkgygax_right_arm
	id = "darkgygax_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_right_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DARK_GYGAX)

/datum/design/darkgygax_left_leg
	id = "darkgygax_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_left_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DARK_GYGAX)

/datum/design/darkgygax_right_leg
	id = "darkgygax_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_right_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_DARK_GYGAX)

/datum/design/darkgygax_armor
	id = "darkgygax_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_armour
	materials = list(MAT_METAL=15000, MAT_DIAMOND=10000, MAT_TITANIUM=5000, MAT_PLASMA=5000)
	construction_time = 60 SECONDS
	category = list(MECH_FAB_CATEGORY_DARK_GYGAX)

//H.O.N.K
/datum/design/honk_chassis
	id = "honk_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/honker
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_HONKER)

/datum/design/honk_torso
	id = "honk_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_torso
	materials = list(MAT_METAL=20000, MAT_GLASS=10000, MAT_BANANIUM=10000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_HONKER)

/datum/design/honk_head
	id = "honk_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_head
	materials = list(MAT_METAL=10000, MAT_GLASS=5000, MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_HONKER)

/datum/design/honk_left_arm
	id = "honk_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_left_arm
	materials = list(MAT_METAL=15000, MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_HONKER)

/datum/design/honk_right_arm
	id = "honk_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_arm
	materials = list(MAT_METAL=15000, MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_HONKER)

/datum/design/honk_left_leg
	id = "honk_left_leg"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/honker_left_leg
	materials = list(MAT_METAL=20000, MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_HONKER)

/datum/design/honk_right_leg
	id = "honk_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_leg
	materials = list(MAT_METAL=20000, MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_HONKER)

//Reticence
/datum/design/reticence_chassis
	id = "reticence_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/reticence
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_RETICENCE)

/datum/design/reticence_torso
	id = "reticence_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_torso
	materials = list(MAT_METAL=20000, MAT_GLASS=10000, MAT_TRANQUILLITE=10000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_RETICENCE)

/datum/design/reticence_head
	id = "reticence_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_head
	materials = list(MAT_METAL=10000, MAT_GLASS=5000, MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_RETICENCE)

/datum/design/reticence_left_arm
	id = "reticence_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_left_arm
	materials = list(MAT_METAL=15000, MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_RETICENCE)

/datum/design/reticence_right_arm
	id = "reticence_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_right_arm
	materials = list(MAT_METAL=15000, MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_RETICENCE)

/datum/design/reticence_left_leg
	id = "reticence_left_leg"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/reticence_left_leg
	materials = list(MAT_METAL=20000, MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_RETICENCE)

/datum/design/reticence_right_leg
	id = "reticence_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_right_leg
	materials = list(MAT_METAL=20000, MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_RETICENCE)

//Phazon
/datum/design/phazon_chassis
	id = "phazon_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/phazon
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_PHAZON)

/datum/design/phazon_torso
	id = "phazon_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_torso
	materials = list(MAT_METAL=35000, MAT_GLASS=10000, MAT_PLASMA=20000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_PHAZON)

/datum/design/phazon_head
	id = "phazon_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_head
	materials = list(MAT_METAL=15000, MAT_GLASS=5000, MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_PHAZON)

/datum/design/phazon_left_arm
	id = "phazon_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_arm
	materials = list(MAT_METAL=20000, MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_PHAZON)

/datum/design/phazon_right_arm
	id = "phazon_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_arm
	materials = list(MAT_METAL=20000, MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_PHAZON)

/datum/design/phazon_left_leg
	id = "phazon_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_leg
	materials = list(MAT_METAL=20000, MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_PHAZON)

/datum/design/phazon_right_leg
	id = "phazon_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_leg
	materials = list(MAT_METAL=20000, MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_PHAZON)

/datum/design/phazon_armor
	id = "phazon_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_armor
	materials = list(MAT_METAL=25000, MAT_PLASMA=20000, MAT_TITANIUM=20000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_PHAZON)

//Exosuit Equipment

/datum/design/mech_drill
	id = "mech_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/drill
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_kineticgun
	id = "mech_kineticgun"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/mecha_kineticgun
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_diamond_drill
	id = "mech_diamond_drill"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	materials = list(MAT_METAL=10000, MAT_DIAMOND=6500)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_plasma_cutter
	id = "mech_plasma_cutter"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PLASMA = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_PLASMA = 6000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_mining_scanner
	id = "mech_mscanner"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mining_scanner
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	construction_time = 5 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_hydraulic_clamp
	id = "mech_hydraulic_clamp"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_atmos_module
	id = "mech_atmos_module"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/multimodule/atmos_module
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_rcd
	id = "mech_rcd"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_BLUESPACE = 3, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_POWERSTORAGE=4, RESEARCH_TREE_ENGINEERING = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/rcd
	materials = list(MAT_METAL=30000, MAT_GOLD=20000, MAT_PLASMA=25000, MAT_SILVER=20000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_eng_toolset
	id = "mech_eng_toolset"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_ENGINEERING = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/eng_toolset
	materials = list(MAT_METAL=10000, MAT_TITANIUM =2000, MAT_PLASMA=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_cargo_update
	id = "mech_cargo_update"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_BLUESPACE = 7)
	build_path = /obj/item/mecha_parts/mecha_equipment/cargo_upgrade
	materials = list(MAT_METAL=15000, MAT_TITANIUM =5000, MAT_BLUESPACE=3000)
	construction_time = 15 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_gravcatapult
	id = "mech_gravcatapult"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BLUESPACE = 4, RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_ENGINEERING = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_wormhole_gen
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BLUESPACE = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_PLASMA = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_teleporter
	id = "mech_teleporter"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BLUESPACE = 8, RESEARCH_TREE_MAGNETS = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	materials = list(MAT_METAL=10000, MAT_DIAMOND=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_servo_hydra_actuator
	id = "mech_servo_hydra_actuator"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ENGINEERING = 7,RESEARCH_TREE_COMBAT = 7)
	build_path = /obj/item/mecha_parts/mecha_equipment/servo_hydra_actuator
	materials = list(MAT_METAL=40000, MAT_TITANIUM =10000, MAT_URANIUM=10000, MAT_DIAMOND=10000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_sleeper
	id = "mech_sleeper"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_PLASMA = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/sleeper
	materials = list(MAT_METAL=5000, MAT_GLASS=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_syringe_gun
	id = "mech_syringe_gun"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MAGNETS = 4,RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MATERIALS = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	materials = list(MAT_METAL=3000, MAT_GLASS=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/syringe_gun_upgrade
	id = "mech_syringe_gun_upgrade"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_TOXINS = 6)
	materials = list(MAT_METAL=8000, MAT_DIAMOND=1000, MAT_GLASS=1000, MAT_GOLD=1000, MAT_URANIUM=500, MAT_BLUESPACE=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/medical_jaw
	id = "mech_medical_jaw"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MAGNETS = 6)	//now same as jaws of life
	materials = list(MAT_METAL=5000, MAT_SILVER=2000, MAT_TITANIUM=1500)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/medbeamgun
	id = "mech_medical_beamgun"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/beamgun
	req_tech = list(RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_POWERSTORAGE = 7)
	materials = list(MAT_METAL=5000, MAT_DIAMOND=600, MAT_GLASS=600, MAT_GOLD=600, MAT_URANIUM=300, MAT_BLUESPACE=650)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/improved_exosuit_control_system
	id = "mech_improved_exosuit_control_system"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/improved_exosuit_control_system
	req_tech = list(RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_POWERSTORAGE= 5)
	materials = list(MAT_METAL=20000, MAT_TITANIUM=10000, MAT_SILVER=2000, MAT_URANIUM=2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_repair_droid
	id = "mech_repair_droid"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	materials = list(MAT_METAL=10000, MAT_GLASS=5000, MAT_GOLD=1000, MAT_SILVER=2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_ccw_armor
	id = "mech_ccw_armor"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_COMBAT = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	materials = list(MAT_METAL=20000, MAT_SILVER=5000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_cage
	id = "mech_cage"
	build_type = MECHFAB
	req_tech = (list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_COMBAT = 7))
	build_path = /obj/item/mecha_parts/mecha_equipment/cage
	materials = list(MAT_METAL=10000, MAT_TITANIUM=4000, MAT_SILVER=2000, MAT_DIAMOND=1000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_proj_armor
	id = "mech_proj_armor"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	materials = list(MAT_METAL=20000, MAT_GOLD=5000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

// Exosuit Weapons

/datum/design/mech_grenade_launcher
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	materials = list(MAT_METAL=22000, MAT_GOLD=6000, MAT_SILVER=8000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/clusterbang_launcher
	id = "clusterbang_launcher"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT= 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ILLEGAL = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang
	materials = list(MAT_METAL=20000, MAT_GOLD=10000, MAT_URANIUM=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_bola
	id = "mech_bola"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_taser
	id = "mech_taser"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_disabler
	id = "mech_disabler"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_scattershot_riot
	id = "mech_scattershot_riot"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MATERIALS = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/riot
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_laser_heavy
	id = "mech_laser_heavy"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_lmg
	id = "mech_lmg"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_almg
	id = "mech_ALMG"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/amlg
	materials = list(MAT_METAL=8000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_scattershot
	id = "mech_scattershot"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_ion
	id = "mech_ion"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_MATERIALS = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	materials = list(MAT_METAL=20000, MAT_SILVER=6000, MAT_URANIUM=2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_missile_rack
	id = "mech_missile_rack"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	materials = list(MAT_METAL=22000, MAT_GOLD=6000, MAT_SILVER=8000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_tesla
	id = "mech_tesla"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_MATERIALS = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	materials = list(MAT_METAL=20000, MAT_SILVER=8000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_laser
	id = "mech_laser"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_carbine
	id = "mech_carbine"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MATERIALS = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/xray_mecha
	id = "mech_xray"
	req_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_BIOTECH = 5, RESEARCH_TREE_POWERSTORAGE = 4)
	build_type = MECHFAB
	materials = list(MAT_GOLD = 5000, MAT_URANIUM = 4000, MAT_METAL = 5000, MAT_TITANIUM = 2000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/xray
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_immolator
	id = "mech_immolator"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_MATERIALS = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator
	materials = list(MAT_METAL = 10000, MAT_SILVER = 8000, MAT_PLASMA = 8000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)
	locked = TRUE

/datum/design/mech_energy_relay
	id = "mech_energy_relay"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	materials = list(MAT_METAL=10000, MAT_GLASS=2000, MAT_GOLD=2000, MAT_SILVER=3000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_generator
	id = "mech_generator"
	req_tech = list(RESEARCH_TREE_POWERSTORAGE = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	materials = list(MAT_METAL=10000, MAT_GLASS=1000, MAT_SILVER=2000, MAT_PLASMA=5000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_generator_nuclear
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_POWERSTORAGE= 5, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MATERIALS = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	materials = list(MAT_METAL=10000, MAT_GLASS=1000, MAT_SILVER=500)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_banana_mortar
	id = "mech_banana_mortar"
	req_tech = list(RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	materials = list(MAT_METAL=20000, MAT_BANANIUM=5000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_honker
	id = "mech_honker"
	req_tech = list(RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/honker
	materials = list(MAT_METAL=20000, MAT_BANANIUM=10000)
	construction_time = 50 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_mousetrap_mortar
	id = "mech_mousetrap_mortar"
	req_tech = list(RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	materials = list(MAT_METAL=20000, MAT_BANANIUM=5000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_silentgun
	id = "mech_silentgun"
	req_tech = list(RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	materials = list(MAT_METAL=20000, MAT_TRANQUILLITE=10000)
	construction_time = 50 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

/datum/design/mech_mimercd
	id = "mech_mrcd"
	req_tech = list(RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mimercd
	materials = list(MAT_METAL=30000, MAT_TRANQUILLITE=10000)
	construction_time = 70 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT)

//Cyborg Upgrade Modules

/datum/design/borg_upgrade_reset
	id = "borg_upgrade_reset"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/reset
	materials = list(MAT_METAL=10000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_rename
	id = "borg_upgrade_rename"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	materials = list(MAT_METAL=35000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_restart
	id = "borg_upgrade_restart"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	materials = list(MAT_METAL=60000 , MAT_GLASS=5000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_vtec
	id = "borg_upgrade_vtec"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 4)
	materials = list(MAT_METAL=80000 , MAT_GLASS=6000 , MAT_URANIUM= 5000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_magboots
	id = "borg_update_magboots"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/magboots
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 5)
	materials = list(MAT_METAL=5000, MAT_SILVER=3000, MAT_GOLD=4000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_thrusters
	id = "borg_upgrade_thrusters"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/thrusters
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_POWERSTORAGE = 4)
	materials = list(MAT_METAL=10000, MAT_PLASMA=5000, MAT_URANIUM = 6000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_selfrepair
	id = "borg_upgrade_selfrepair"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/selfrepair
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 4)
	materials = list(MAT_METAL=15000, MAT_GLASS=15000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_gps
	id = "borg_upgrade_gps"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/gps
	req_tech = list(RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_MAGNETS = 6)
	materials = list(MAT_METAL = 10000, MAT_GOLD = 2000, MAT_SILVER = 2000, MAT_TITANIUM = 500)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_syndicate_module
	id = "borg_syndicate_module"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_PROGRAMMING = 7)
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(MAT_METAL=10000, MAT_GLASS=15000, MAT_DIAMOND = 10000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_storageincreaser
	id = "borg_upgrade_storageincreaser"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/storageincreaser
	req_tech = list(RESEARCH_TREE_BLUESPACE = 5, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_ENGINEERING = 5)
	materials = list(MAT_METAL=15000, MAT_BLUESPACE=2000, MAT_SILVER=6000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/service_bs_beaker
	id = "service_bs_beaker"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/bs_beaker
	req_tech = list(RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PLASMA = 4)
	materials = list(MAT_GLASS = 3000, MAT_PLASMA = 3000, MAT_DIAMOND = 250, MAT_BLUESPACE = 250)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_abductor_engi
	id = "borg_upgade_abductor_engi"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/abductor_engi
	req_tech = list(RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_ALIEN = 4)
	materials = list(MAT_METAL = 25000, MAT_SILVER = 12500, MAT_PLASMA = 5000, MAT_TITANIUM = 10000, MAT_DIAMOND = 10000) //Base abductor engineering tools * 4
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_hypospray
	id = "borg_upgrade_hypospray"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray
	req_tech = list(RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_MATERIALS = 7)
	materials = list(MAT_METAL=15000, MAT_URANIUM=2000, MAT_DIAMOND=5000, MAT_SILVER=10000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_hypospray_pierce
	id = "borg_upgrade_hypospray_pierce"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray_pierce
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_ENGINEERING = 6)
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_DIAMOND = 500, MAT_TITANIUM = 10000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_abductor_medi
	id = "borg_upgade_abductor_medi"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/abductor_medi
	req_tech = list(RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_ALIEN = 3)
	materials = list(MAT_METAL = 18000, MAT_GLASS = 1500, MAT_SILVER = 13000, MAT_GOLD = 1000, MAT_PLASMA = 4000, MAT_TITANIUM = 12000, MAT_DIAMOND = 1000) //Base abductor engineering tools *8 + IMS cost
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_disablercooler
	id = "borg_upgrade_disablercooler"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/disablercooler
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 4)
	materials = list(MAT_METAL=80000 , MAT_GLASS=6000 , MAT_GOLD= 2000, MAT_DIAMOND = 500)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_damage_mod
	id = "borg_damagemod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_COMBAT = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/damage/borg
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_cooldown_mod
	id = "borg_cooldownmod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_COMBAT = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/haste/borg
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_range_mod
	id = "borg_rangemod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_COMBAT = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/range/borg
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_hardness_mod
	id = "borg_hardnessmod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_COMBAT = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2800, MAT_GLASS = 2100, MAT_GOLD = 2100, MAT_URANIUM = 1400)
	build_path = /obj/item/borg/upgrade/modkit/hardness/borg
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_hyperaccelerator
	id = "borg_hypermod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_COMBAT = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 8000, MAT_GLASS = 1500, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/borg
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_offensive_turf_aoe
	id = "borg_hyperaoemod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 7000, MAT_GLASS = 3000, MAT_SILVER= 3000, MAT_GOLD = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs/borg
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_rapid_repeater
	id = "borg_repeatermod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_URANIUM = 8000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater/borg
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_resonator_blast
	id = "borg_resonatormod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_SILVER= 5000, MAT_URANIUM = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts/borg
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_diamonddrill
	id = "borg_upgrade_diamonddrill"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ddrill
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 6)
	materials = list(MAT_METAL=10000, MAT_DIAMOND=2000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_lavaproof
	id = "borg_upgrade_lavaproof"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_COMBAT = 2)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/lavaproof
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 4000, MAT_TITANIUM = 5000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_holding
	id = "borg_upgrade_holding"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/soh
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_BLUESPACE = 4)
	materials = list(MAT_METAL = 10000, MAT_GOLD = 250, MAT_URANIUM = 500)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

/datum/design/borg_upgrade_mounted_seat
	id = "borg_upgrade_mounted_seat"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/mounted_seat
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MATERIALS = 4)
	materials = list(MAT_METAL = 80000)
	construction_time = 12 SECONDS
	category = list(MECH_FAB_CATEGORY_CYBORG_EQUIPMENT)

//IPC

/datum/design/integrated_robotic_chassis
	id = "integrated_robotic_chassis"
	build_type = MECHFAB
	build_path = /mob/living/carbon/human/machine/created
	materials = list(MAT_METAL = 40000, MAT_TITANIUM = 7000) //for something made from lego, they sure need a lot of metal
	construction_time = 40 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_cell
	id = "ipc_cell"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/cell
	materials = list(MAT_METAL=2000, MAT_GLASS=750)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_head
	id = "ipc_head"
	build_type = MECHFAB
	build_path = /obj/item/organ/external/head/ipc
	materials = list(MAT_METAL=5000)
	construction_time = 35 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_optics
	id = "ipc_optics"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/eyes/optical_sensor
	materials = list(MAT_METAL=1000, MAT_GLASS=2500)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_microphone
	id = "ipc_microphone"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/ears/microphone
	materials = list(MAT_METAL = 1000, MAT_GLASS = 2500)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_r_arm
	id = "ipc_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_arm
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_charger
	id = "ipc_cahrger"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/cyberimp/arm/power_cord
	materials = list(MAT_METAL=2000, MAT_GLASS=1000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_l_arm
	id = "ipc_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_arm
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_l_leg
	id = "ipc_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_leg
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/ipc_r_leg
	id = "ipc_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_leg
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

//Misc

/datum/design/mecha_tracking
	id = "mecha_tracking"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2)
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/mecha_tracking
	materials = list(MAT_METAL=500)
	construction_time = 5 SECONDS
	category = list(MECH_FAB_CATEGORY_MISC)

/datum/design/mecha_tracking_ai_control
	id = "mecha_tracking_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_tracking/ai_control
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 200)
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_ENGINEERING = 2)
	construction_time = 5 SECONDS
	category = list(MECH_FAB_CATEGORY_MISC)

/datum/design/voice_standard
	id = "voice_standard"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice
	category = list(MECH_FAB_CATEGORY_MISC)

/datum/design/voice_nanotrasen
	id = "voice_nanotrasen"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice/nanotrasen
	category = list(MECH_FAB_CATEGORY_MISC)

/datum/design/voice_silent
	id = "voice_silent"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice/silent
	category = list(MECH_FAB_CATEGORY_MISC)

/datum/design/voice_honk
	id = "voice_honk"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 400, MAT_BANANIUM = 100)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice/honk
	category = list(MECH_FAB_CATEGORY_MISC)

/datum/design/voice_syndicate
	id = "voice_syndicate"
	build_type = MECHFAB
	materials = list(MAT_METAL = 400, MAT_TITANIUM = 100)
	req_tech = list(RESEARCH_TREE_ILLEGAL = 2)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice/syndicate
	category = list(MECH_FAB_CATEGORY_MISC)

//Syndie

/datum/design/syndicate_robotic_brain
	id = "mmi_robotic_syndicate"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_PLASMA = 2,RESEARCH_TREE_ILLEGAL = 6)
	build_type = MECHFAB
	materials = list(MAT_METAL = 1700, MAT_GLASS = 2700, MAT_GOLD = 1000, MAT_TITANIUM = 1000)
	construction_time = 7.5 SECONDS
	build_path = /obj/item/mmi/robotic_brain/syndicate
	category = list(MECH_FAB_CATEGORY_SYNDICATE)

/datum/design/syndicate_quantumpad
	id = "syndicate_quantumpad"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_PLASMA = 3,RESEARCH_TREE_ILLEGAL = 6)
	build_type = MECHFAB
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 2000)
	construction_time = 5 SECONDS
	build_path = /obj/item/circuitboard/quantumpad/syndiepad
	category = list(MECH_FAB_CATEGORY_SYNDICATE)

/datum/design/syndicate_cargo_console
	id = "syndicate_supply_pad"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ILLEGAL = 3)
	build_type = MECHFAB
	materials = list(MAT_GLASS = 1000)
	construction_time = 5 SECONDS
	build_path = /obj/item/circuitboard/syndicatesupplycomp
	category = list(MECH_FAB_CATEGORY_SYNDICATE)

/datum/design/syndicate_public_cargo_console
	id = "syndicate_public_supply_pad"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ILLEGAL = 3)
	build_type = MECHFAB
	materials = list(MAT_GLASS = 1000)
	construction_time = 5 SECONDS
	build_path = /obj/item/circuitboard/syndicatesupplycomp/public
	category = list(MECH_FAB_CATEGORY_SYNDICATE)

/datum/design/syndicate_borg_RCD_upgrade
	id = "syndicate_cyborg_RCD_upgrade"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_ILLEGAL = 5)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_GOLD = 1000, MAT_TITANIUM = 5000, MAT_PLASMA = 5000)
	construction_time = 5 SECONDS
	build_path = /obj/item/borg/upgrade/syndie_rcd
	category = list(MECH_FAB_CATEGORY_SYNDICATE)

//Paintkits
/datum/design/paint_ripley_titan
	id = "p_titan"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5)
	build_path = /obj/item/paintkit/ripley_titansfist
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_ripley_earth
	id = "p_earth"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5)
	build_path = /obj/item/paintkit/ripley_mercenary
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_ripley_red
	id = "p_red"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/ripley_red
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_firefighter_hauler
	id = "p_hauler"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5)
	build_path = /obj/item/paintkit/firefighter_Hauler
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_firefighter_zairjah
	id = "p_zairjah"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/firefighter_zairjah
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_firefighter_combat
	id = "p_combat"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5)
	build_path = /obj/item/paintkit/firefighter_combat
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_firefighter_reaper
	id = "p_reaper"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5,RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/firefighter_Reaper
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_firefighter_aluminizer
	id = "p_aluminizer"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5,RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/firefighter_aluminizer
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_ripley_nt
	id = "p_ripleynt"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5)
	build_path = /obj/item/paintkit/ripley_nt
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_clarke_orangey
	id = "p_orangey"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/clarke_orangey
	materials = list(MAT_METAL = 20000, MAT_DIAMOND = 2000, MAT_URANIUM = 2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_clarke_spiderclarke
	id = "p_spiderclarke"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/clarke_spiderclarke
	materials = list(MAT_METAL = 20000, MAT_DIAMOND = 2000, MAT_URANIUM = 2000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_odysseus_hermes
	id = "p_hermes"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5,RESEARCH_TREE_BIOTECH = 5)
	build_path = /obj/item/paintkit/odysseus_hermes
	materials = list(MAT_METAL = 20000, MAT_DIAMOND = 2000, MAT_URANIUM = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_odysseus_reaper
	id = "p_odyreaper"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/odysseus_death
	materials = list(MAT_METAL = 20000, MAT_DIAMOND = 2000, MAT_URANIUM = 2000)
	construction_time = 10 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_gygax_alt
	id = "p_altgygax"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 4)
	build_path = /obj/item/paintkit/gygax_alt
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_gygax_pobeda
	id = "p_pobedagygax"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_PROGRAMMING = 6)
	build_path = /obj/item/paintkit/gygax_pobeda
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_gygax_white
	id = "p_whitegygax"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 3 )
	build_path = /obj/item/paintkit/gygax_white
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_gygax_medgax
	id = "p_medgax"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 6,RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_TOXINS = 6)
	build_path = /obj/item/paintkit/gygax_medgax
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_gygax_black
	id = "p_blackgygax"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ILLEGAL = 3)
	build_path = /obj/item/paintkit/gygax_syndie
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_gygax_pirate
	id = "p_pirategygax"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6)
	build_path = /obj/item/paintkit/gygax_pirate
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_durand_unathi
	id = "p_unathi"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_BIOTECH = 6)
	build_path = /obj/item/paintkit/durand_unathi
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_durand_shire
	id = "p_shire"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6)
	build_path = /obj/item/paintkit/durand_shire
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_durand_pirate
	id = "p_durandpirate"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6)
	build_path = /obj/item/paintkit/durand_pirate
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_durand_nt
	id = "p_durandnt"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6)
	build_path = /obj/item/paintkit/durand_nt
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_durand_soviet
	id = "p_soviet"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_TOXINS = 6)
	build_path = /obj/item/paintkit/durand_soviet
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_durand_executor
	id = "p_executor"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6)
	build_path = /obj/item/paintkit/durand_executor
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_SILVER = 4000)
	construction_time = 30 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_phazon_imperion
	id = "p_imperion"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/phazon_imperion
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 40 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_phazon_janus
	id = "p_janus"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/phazon_janus
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 40 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_phazon_plazmus
	id = "p_plazmus"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_TOXINS = 5)
	build_path = /obj/item/paintkit/phazon_plazmus
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_PLASMA = 5000)
	construction_time = 40 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_phazon_blanco
	id = "p_blanco"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_TOXINS = 6)
	build_path = /obj/item/paintkit/phazon_blanco
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 40 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_phazon_nt
	id = "p_phazonnt"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_TOXINS = 6)
	build_path = /obj/item/paintkit/phazon_nt
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 40 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/paint_ashed
	id = "p_ashed"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 6)
	build_path = /obj/item/paintkit/ashed
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 8000, MAT_GLASS = 8000)
	construction_time = 20 SECONDS
	category = list(MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS)

/datum/design/exoframe_reinforced
	id = "exo_reinforced"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 5)
	build_path = /obj/item/organ/internal/cyberimp/chest/exoframe/reinforced
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 4000)
	construction_time = 50 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)

/datum/design/exoframe_industrial
	id = "exo_industrial"
	build_type = MECHFAB
	req_tech = list(RESEARCH_TREE_MATERIALS = 4,RESEARCH_TREE_ENGINEERING = 5)
	build_path = /obj/item/organ/internal/cyberimp/chest/exoframe/industrial
	materials = list(MAT_METAL = 20000, MAT_TITANIUM = 6000)
	construction_time = 50 SECONDS
	category = list(MECH_FAB_CATEGORY_IPC)
