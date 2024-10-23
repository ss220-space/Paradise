////////////////////////////////////////
/////////// Mecha Designs //////////////
////////////////////////////////////////
//Cyborg
/datum/design/borg_suit
	name = "Cyborg Endoskeleton"
	id = "borg_suit"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_suit
	materials = list(MAT_METAL=15000)
	construction_time = 50 SECONDS
	category = list("Cyborg")

/datum/design/borg_chest
	name = "Cyborg Torso"
	id = "borg_chest"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/chest
	materials = list(MAT_METAL=40000)
	construction_time = 35 SECONDS
	category = list("Cyborg")

/datum/design/borg_head
	name = "Cyborg Head"
	id = "borg_head"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/head
	materials = list(MAT_METAL=5000)
	construction_time = 35 SECONDS
	category = list("Cyborg")

/datum/design/borg_l_arm
	name = "Cyborg Left Arm"
	id = "borg_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_arm
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list("Cyborg")

/datum/design/borg_r_arm
	name = "Cyborg Right Arm"
	id = "borg_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_arm
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list("Cyborg")

/datum/design/borg_l_leg
	name = "Cyborg Left Leg"
	id = "borg_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_leg
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list("Cyborg")

/datum/design/borg_r_leg
	name = "Cyborg Right Leg"
	id = "borg_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_leg
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list("Cyborg")

/datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "A synthetic flash used mostly in borg construction."
	id = "sflash"
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	construction_time = 10 SECONDS
	build_path = /obj/item/flash/synthetic
	category = list("Cyborg")

//Robot repair
/datum/design/borg_binary_communication
	name = "Cyborg Binary Communication Device"
	id = "borg_binary_communication"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/binary_communication_device
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 20 SECONDS
	category = list("Cyborg Repair")

/datum/design/borg_radio
	name = "Cyborg Radio"
	id = "borg_radio"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/radio
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 20 SECONDS
	category = list("Cyborg Repair")

/datum/design/borg_actuator
	name = "Cyborg Actuator"
	id = "borg_actuator"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/actuator
	materials = list(MAT_METAL=3500)
	construction_time = 20 SECONDS
	category = list("Cyborg Repair")

/datum/design/borg_diagnosis_unit
	name = "Cyborg Diagnosis Unit"
	id = "borg_diagnosis_unit"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/diagnosis_unit
	materials = list(MAT_METAL=3500)
	construction_time = 20 SECONDS
	category = list("Cyborg Repair")

/datum/design/borg_camera
	name = "Cyborg Camera"
	id = "borg_camera"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/camera
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 20 SECONDS
	category = list("Cyborg Repair")

/datum/design/borg_armor
	name = "Cyborg Armor"
	id = "borg_armor"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/armour
	materials = list(MAT_METAL=5000)
	construction_time = 20 SECONDS
	category = list("Cyborg Repair")

//Ripley
/datum/design/ripley_chassis
	name = "Exosuit Chassis (APLU \"Ripley\")"
	id = "ripley_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ripley
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list("Ripley")

//Firefighter subtype
/datum/design/firefighter_chassis
	name = "Exosuit Chassis (APLU \"Firefighter\")"
	id = "firefighter_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/firefighter
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list("Firefighter")

/datum/design/ripley_torso
	name = "Exosuit Torso (APLU \"Ripley\")"
	id = "ripley_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_torso
	materials = list(MAT_METAL=20000, MAT_GLASS=7500)
	construction_time = 20 SECONDS
	category = list("Ripley","Firefighter")

/datum/design/ripley_left_arm
	name = "Exosuit Left Arm (APLU \"Ripley\")"
	id = "ripley_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	materials = list(MAT_METAL=15000)
	construction_time = 15 SECONDS
	category = list("Ripley","Firefighter")

/datum/design/ripley_right_arm
	name = "Exosuit Right Arm (APLU \"Ripley\")"
	id = "ripley_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	materials = list(MAT_METAL=15000)
	construction_time = 15 SECONDS
	category = list("Ripley","Firefighter")

/datum/design/ripley_left_leg
	name = "Exosuit Left Leg (APLU \"Ripley\")"
	id = "ripley_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	materials = list(MAT_METAL=15000)
	construction_time = 15 SECONDS
	category = list("Ripley","Firefighter")

/datum/design/ripley_right_leg
	name = "Exosuit Right Leg (APLU \"Ripley\")"
	id = "ripley_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	materials = list(MAT_METAL=15000)
	construction_time = 15 SECONDS
	category = list("Ripley","Firefighter")

//Clarke

/datum/design/clarke_chassis
	name = "Exosuit Chassis (\"Clarke\")"
	id = "clarke_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/clarke
	materials = list(MAT_METAL=25000,MAT_SILVER=10000,MAT_PLASMA=5000)
	construction_time = 10 SECONDS
	category = list("Clarke")

/datum/design/clarke_torso
	name = "Exosuit Torso (\"Clarke\")"
	id = "clarkee_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_torso
	materials = list(MAT_METAL=20000)
	construction_time = 18 SECONDS
	category = list("Clarke")

/datum/design/clarke_head
	name = "Exosuit Head (\"Clarke\")"
	id = "clarke_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_head
	materials = list(MAT_METAL=10000,MAT_GLASS=10000)
	construction_time = 10 SECONDS
	category = list("Clarke")

/datum/design/clarke_left_arm
	name = "Exosuit Left Arm (\"Clarke\")"
	id = "clarke_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_left_arm
	materials = list(MAT_METAL=12000)
	construction_time = 12 SECONDS
	category = list("Clarke")

/datum/design/clarke_right_arm
	name = "Exosuit Right Arm (\"Clarke\")"
	id = "clarke_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_right_arm
	materials = list(MAT_METAL=12000)
	construction_time = 12 SECONDS
	category = list("Clarke")

/datum/design/clarke_left_leg
	name = "Exosuit Left Tread (\"Clarke\")"
	id = "clarke_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_left_leg
	materials = list(MAT_METAL=15000,MAT_TITANIUM=20000)
	construction_time = 13  SECONDS
	category = list("Clarke")

/datum/design/clarke_right_leg
	name = "Exosuit Right Tread (\"Clarke\")"
	id = "clarke_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_right_leg
	materials = list(MAT_METAL=15000,MAT_TITANIUM=20000)
	construction_time = 13 SECONDS
	category = list("Clarke")


//Odysseus
/datum/design/odysseus_chassis
	name = "Exosuit Chassis (\"Odysseus\")"
	id = "odysseus_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/odysseus
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list("Odysseus")

/datum/design/odysseus_torso
	name = "Exosuit Torso (\"Odysseus\")"
	id = "odysseus_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	materials = list(MAT_METAL=12000)
	construction_time = 18 SECONDS
	category = list("Odysseus")

/datum/design/odysseus_head
	name = "Exosuit Head (\"Odysseus\")"
	id = "odysseus_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_head
	materials = list(MAT_METAL=6000,MAT_GLASS=10000)
	construction_time = 10 SECONDS
	category = list("Odysseus")

/datum/design/odysseus_left_arm
	name = "Exosuit Left Arm (\"Odysseus\")"
	id = "odysseus_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	materials = list(MAT_METAL=6000)
	construction_time = 12 SECONDS
	category = list("Odysseus")

/datum/design/odysseus_right_arm
	name = "Exosuit Right Arm (\"Odysseus\")"
	id = "odysseus_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	materials = list(MAT_METAL=6000)
	construction_time = 12 SECONDS
	category = list("Odysseus")

/datum/design/odysseus_left_leg
	name = "Exosuit Left Leg (\"Odysseus\")"
	id = "odysseus_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	materials = list(MAT_METAL=7000)
	construction_time = 13 SECONDS
	category = list("Odysseus")

/datum/design/odysseus_right_leg
	name = "Exosuit Right Leg (\"Odysseus\")"
	id = "odysseus_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	materials = list(MAT_METAL=7000)
	construction_time = 13 SECONDS
	category = list("Odysseus")

//Gygax
/datum/design/gygax_chassis
	name = "Exosuit Chassis (\"Gygax\")"
	id = "gygax_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/gygax
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list("Gygax")

/datum/design/gygax_torso
	name = "Exosuit Torso (\"Gygax\")"
	id = "gygax_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_DIAMOND=2000)
	construction_time = 30 SECONDS
	category = list("Gygax")

/datum/design/gygax_head
	name = "Exosuit Head (\"Gygax\")"
	id = "gygax_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list("Gygax")

/datum/design/gygax_left_arm
	name = "Exosuit Left Arm (\"Gygax\")"
	id = "gygax_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 20 SECONDS
	category = list("Gygax")

/datum/design/gygax_right_arm
	name = "Exosuit Right Arm (\"Gygax\")"
	id = "gygax_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 20 SECONDS
	category = list("Gygax")

/datum/design/gygax_left_leg
	name = "Exosuit Left Leg (\"Gygax\")"
	id = "gygax_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list("Gygax")

/datum/design/gygax_right_leg
	name = "Exosuit Right Leg (\"Gygax\")"
	id = "gygax_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list("Gygax")

/datum/design/gygax_armor
	name = "Exosuit Armor (\"Gygax\")"
	id = "gygax_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_armour
	materials = list(MAT_METAL=15000,MAT_DIAMOND=10000,MAT_TITANIUM=10000)
	construction_time = 60 SECONDS
	category = list("Gygax")

//Durand
/datum/design/durand_chassis
	name = "Exosuit Chassis (\"Durand\")"
	id = "durand_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/durand
	materials = list(MAT_METAL=25000)
	construction_time = 10 SECONDS
	category = list("Durand")

/datum/design/durand_torso
	name = "Exosuit Torso (\"Durand\")"
	id = "durand_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_torso
	materials = list(MAT_METAL=25000,MAT_GLASS=10000,MAT_SILVER=10000)
	construction_time = 30 SECONDS
	category = list("Durand")

/datum/design/durand_head
	name = "Exosuit Head (\"Durand\")"
	id = "durand_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_head
	materials = list(MAT_METAL=10000,MAT_GLASS=15000,MAT_SILVER=2000)
	construction_time = 20 SECONDS
	category = list("Durand")

/datum/design/durand_left_arm
	name = "Exosuit Left Arm (\"Durand\")"
	id = "durand_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	materials = list(MAT_METAL=10000,MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list("Durand")

/datum/design/durand_right_arm
	name = "Exosuit Right Arm (\"Durand\")"
	id = "durand_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	materials = list(MAT_METAL=10000,MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list("Durand")

/datum/design/durand_left_leg
	name = "Exosuit Left Leg (\"Durand\")"
	id = "durand_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	materials = list(MAT_METAL=15000,MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list("Durand")

/datum/design/durand_right_leg
	name = "Exosuit Right Leg (\"Durand\")"
	id = "durand_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	materials = list(MAT_METAL=15000,MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list("Durand")

/datum/design/durand_armor
	name = "Exosuit Armor (\"Durand\")"
	id = "durand_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_armor
	materials = list(MAT_METAL=30000,MAT_URANIUM=25000,MAT_TITANIUM=20000)
	construction_time = 60 SECONDS
	category = list("Durand")

//Rover(DarkDurand)
/datum/design/rover_chassis
	name = "Exosuit Chassis (\"Rover\")"
	id = "rover_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/rover
	materials = list(MAT_METAL=25000)
	construction_time = 10 SECONDS
	category = list("Rover")

/datum/design/rover_torso
	name = "Exosuit Torso (\"Rover\")"
	id = "rover_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_torso
	materials = list(MAT_METAL=25000,MAT_GLASS=10000,MAT_SILVER=10000)
	construction_time = 30 SECONDS
	category = list("Rover")

/datum/design/rover_head
	name = "Exosuit Head (\"Rover\")"
	id = "rover_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_head
	materials = list(MAT_METAL=10000,MAT_GLASS=15000,MAT_SILVER=2000)
	construction_time = 20 SECONDS
	category = list("Rover")

/datum/design/rover_left_arm
	name = "Exosuit Left Arm (\"Rover\")"
	id = "rover_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_left_arm
	materials = list(MAT_METAL=10000,MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list("Rover")

/datum/design/rover_right_arm
	name = "Exosuit Right Arm (\"Rover\")"
	id = "rover_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_right_arm
	materials = list(MAT_METAL=10000,MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list("Rover")

/datum/design/rover_left_leg
	name = "Exosuit Left Leg (\"Rover\")"
	id = "rover_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_left_leg
	materials = list(MAT_METAL=15000,MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list("Rover")

/datum/design/rover_right_leg
	name = "Exosuit Right Leg (\"Rover\")"
	id = "rover_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_right_leg
	materials = list(MAT_METAL=15000,MAT_SILVER=4000)
	construction_time = 20 SECONDS
	category = list("Rover")

/datum/design/rover_armor
	name = "Exosuit Armor (\"Rover\")"
	id = "rover_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/rover_armor
	materials = list(MAT_METAL=30000,MAT_URANIUM=25000,MAT_PLASMA=15000,MAT_TITANIUM=15000)
	construction_time = 60 SECONDS
	category = list("Rover")

//Dark Gygax
/datum/design/darkgygax_chassis
	name = "Exosuit Chassis (\"Dark Gygax\")"
	id = "darkgygax_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/darkgygax
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list("Dark Gygax")

/datum/design/darkgygax_torso
	name = "Exosuit Torso (\"Dark Gygax\")"
	id = "darkgygax_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_DIAMOND=2000)
	construction_time = 30 SECONDS
	category = list("Dark Gygax")

/datum/design/darkgygax_head
	name = "Exosuit Head (\"Dark Gygax\")"
	id = "darkgygax_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list("Dark Gygax")

/datum/design/darkgygax_left_arm
	name = "Exosuit Left Arm (\"Dark Gygax\")"
	id = "darkgygax_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_left_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 20 SECONDS
	category = list("Dark Gygax")

/datum/design/darkgygax_right_arm
	name = "Exosuit Right Arm (\"Dark Gygax\")"
	id = "darkgygax_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_right_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 20 SECONDS
	category = list("Dark Gygax")

/datum/design/darkgygax_left_leg
	name = "Exosuit Left Leg (\"Dark Gygax\")"
	id = "darkgygax_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_left_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list("Dark Gygax")

/datum/design/darkgygax_right_leg
	name = "Exosuit Right Leg (\"Dark Gygax\")"
	id = "darkgygax_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_right_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 20 SECONDS
	category = list("Dark Gygax")

/datum/design/darkgygax_armor
	name = "Exosuit Armor (\"Dark Gygax\")"
	id = "darkgygax_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/darkgygax_armour
	materials = list(MAT_METAL=15000,MAT_DIAMOND=10000,MAT_TITANIUM=5000,MAT_PLASMA=5000)
	construction_time = 60 SECONDS
	category = list("Dark Gygax")

//H.O.N.K
/datum/design/honk_chassis
	name = "Exosuit Chassis (\"H.O.N.K\")"
	id = "honk_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/honker
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list("H.O.N.K")

/datum/design/honk_torso
	name = "Exosuit Torso (\"H.O.N.K\")"
	id = "honk_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_BANANIUM=10000)
	construction_time = 30 SECONDS
	category = list("H.O.N.K")

/datum/design/honk_head
	name = "Exosuit Head (\"H.O.N.K\")"
	id = "honk_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list("H.O.N.K")

/datum/design/honk_left_arm
	name = "Exosuit Left Arm (\"H.O.N.K\")"
	id = "honk_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_left_arm
	materials = list(MAT_METAL=15000,MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list("H.O.N.K")

/datum/design/honk_right_arm
	name = "Exosuit Right Arm (\"H.O.N.K\")"
	id = "honk_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_arm
	materials = list(MAT_METAL=15000,MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list("H.O.N.K")

/datum/design/honk_left_leg
	name = "Exosuit Left Leg (\"H.O.N.K\")"
	id = "honk_left_leg"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/honker_left_leg
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list("H.O.N.K")

/datum/design/honk_right_leg
	name = "Exosuit Right Leg (\"H.O.N.K\")"
	id = "honk_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_leg
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 20 SECONDS
	category = list("H.O.N.K")

//Reticence
/datum/design/reticence_chassis
	name = "Exosuit Chassis (\"Reticence\")"
	id = "reticence_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/reticence
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list("Reticence")

/datum/design/reticence_torso
	name = "Exosuit Torso (\"Reticence\")"
	id = "reticence_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_TRANQUILLITE=10000)
	construction_time = 30 SECONDS
	category = list("Reticence")

/datum/design/reticence_head
	name = "Exosuit Head (\"Reticence\")"
	id = "reticence_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list("Reticence")

/datum/design/reticence_left_arm
	name = "Exosuit Left Arm (\"Reticence\")"
	id = "reticence_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_left_arm
	materials = list(MAT_METAL=15000,MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list("Reticence")

/datum/design/reticence_right_arm
	name = "Exosuit Right Arm (\"Reticence\")"
	id = "reticence_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_right_arm
	materials = list(MAT_METAL=15000,MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list("Reticence")

/datum/design/reticence_left_leg
	name = "Exosuit Left Leg (\"Reticence\")"
	id = "reticence_left_leg"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/reticence_left_leg
	materials = list(MAT_METAL=20000,MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list("Reticence")

/datum/design/reticence_right_leg
	name = "Exosuit Right Leg (\"Reticence\")"
	id = "reticence_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_right_leg
	materials = list(MAT_METAL=20000,MAT_TRANQUILLITE=5000)
	construction_time = 20 SECONDS
	category = list("Reticence")

//Phazon
/datum/design/phazon_chassis
	name = "Exosuit Chassis (\"Phazon\")"
	id = "phazon_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/phazon
	materials = list(MAT_METAL=20000)
	construction_time = 10 SECONDS
	category = list("Phazon")

/datum/design/phazon_torso
	name = "Exosuit Torso (\"Phazon\")"
	id = "phazon_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_torso
	materials = list(MAT_METAL=35000,MAT_GLASS=10000,MAT_PLASMA=20000)
	construction_time = 30 SECONDS
	category = list("Phazon")

/datum/design/phazon_head
	name = "Exosuit Head (\"Phazon\")"
	id = "phazon_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_head
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list("Phazon")

/datum/design/phazon_left_arm
	name = "Exosuit Left Arm (\"Phazon\")"
	id = "phazon_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_arm
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list("Phazon")

/datum/design/phazon_right_arm
	name = "Exosuit Right Arm (\"Phazon\")"
	id = "phazon_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_arm
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list("Phazon")

/datum/design/phazon_left_leg
	name = "Exosuit Left Leg (\"Phazon\")"
	id = "phazon_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_leg
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list("Phazon")

/datum/design/phazon_right_leg
	name = "Exosuit Right Leg (\"Phazon\")"
	id = "phazon_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_leg
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 20 SECONDS
	category = list("Phazon")

/datum/design/phazon_armor
	name = "Exosuit Armor (\"Phazon\")"
	id = "phazon_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_armor
	materials = list(MAT_METAL=25000,MAT_PLASMA=20000,MAT_TITANIUM=20000)
	construction_time = 30 SECONDS
	category = list("Phazon")

//Exosuit Equipment

/datum/design/mech_drill
	name = "Exosuit Working Equipment (Drill)"
	id = "mech_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/drill
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_kineticgun
	name = "Exosuit Working Equipment (Proto-kinetic Accelerator)"
	id = "mech_kineticgun"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/mecha_kineticgun
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_diamond_drill
	name = "Exosuit Working Equipment (Diamond Mining Drill)"
	desc = "An upgraded version of the standard drill."
	id = "mech_diamond_drill"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	materials = list(MAT_METAL=10000,MAT_DIAMOND=6500)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_plasma_cutter
	name = "Exosuit Working Equipment (217-D Plasma Cutter)"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demolishing solid obstacles."
	id = "mech_plasma_cutter"
	build_type = MECHFAB
	req_tech = list("engineering" = 4, "materials" = 5, "plasmatech" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_PLASMA = 6000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_mining_scanner
	name = "Exosuit Working Equipment (Mining Scanner)"
	id = "mech_mscanner"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mining_scanner
	materials = list(MAT_METAL=5000,MAT_GLASS=2500)
	construction_time = 5 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_hydraulic_clamp
	name = "Exosuit Working Equipment (Hydraulic Clamp)"
	id = "mech_hydraulic_clamp"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_atmos_module
	name = "Exosuit Working Module (ATMOS module)"
	id = "mech_atmos_module"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/multimodule/atmos_module
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_rcd
	name = "Exosuit Working Equipment (RCD Module)"
	desc = "An exosuit-mounted Rapid Construction Device."
	id = "mech_rcd"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "bluespace" = 3, "magnets" = 4, "powerstorage"=4, "engineering" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/rcd
	materials = list(MAT_METAL=30000,MAT_GOLD=20000,MAT_PLASMA=25000,MAT_SILVER=20000)
	construction_time = 30 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_eng_toolset
	name = "Exosuit Working Equipment (Engineering Toolset)"
	desc = "Exosuit toolset. Gives a set of good tools."
	id = "mech_eng_toolset"
	build_type = MECHFAB
	req_tech = list("materials" = 6, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/eng_toolset
	materials = list(MAT_METAL=10000,MAT_TITANIUM =2000,MAT_PLASMA=2000)
	construction_time = 20 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_cargo_update
	name = "Exosuit Working Equipment (Cargo Capacity Upgrade)"
	desc = "Cargo capacity upgrade module for working mecha, allow you carry more stuffs and even living beings. Turn your Ripley into walking hearse!"
	id = "mech_cargo_update"
	build_type = MECHFAB
	req_tech = list("materials" = 6, "programming" = 6, "bluespace" = 7)
	build_path = /obj/item/mecha_parts/mecha_equipment/cargo_upgrade
	materials = list(MAT_METAL=15000,MAT_TITANIUM =5000,MAT_BLUESPACE=3000)
	construction_time = 15 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_gravcatapult
	name = "Exosuit Common Equipment (Gravitational Catapult Module)"
	desc = "An exosuit mounted Gravitational Catapult."
	id = "mech_gravcatapult"
	build_type = MECHFAB
	req_tech = list("bluespace" = 4, "magnets" = 3, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_wormhole_gen
	name = "Exosuit Common Equipment (Localized Wormhole Generator)"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	req_tech = list("bluespace" = 4, "magnets" = 4, "plasmatech" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_teleporter
	name = "Exosuit Common Equipment (Teleporter Module)"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	id = "mech_teleporter"
	build_type = MECHFAB
	req_tech = list("bluespace" = 8, "magnets" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	materials = list(MAT_METAL=10000,MAT_DIAMOND=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_servo_hydra_actuator
	name = "Exosuit Common Equipment (Strafe Module)"
	desc = "Exosuit servo-motors. Allows strafe mode."
	id = "mech_servo_hydra_actuator"
	build_type = MECHFAB
	req_tech = list("powerstorage" = 7, "programming" = 7, "engineering" = 7,"combat" = 7)
	build_path = /obj/item/mecha_parts/mecha_equipment/servo_hydra_actuator
	materials = list(MAT_METAL=40000,MAT_TITANIUM =10000,MAT_URANIUM=10000,MAT_DIAMOND=10000)
	construction_time = 30 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_sleeper
	name = "Exosuit Medical Equipment (Mounted Sleeper)"
	id = "mech_sleeper"
	build_type = MECHFAB
	req_tech = list("biotech" = 3, "engineering" = 3, "plasmatech" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/sleeper
	materials = list(MAT_METAL=5000,MAT_GLASS=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_syringe_gun
	name = "Exosuit Medical Equipment (Syringe Gun)"
	id = "mech_syringe_gun"
	build_type = MECHFAB
	req_tech = list("magnets" = 4,"biotech" = 4, "combat" = 3, "materials" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	materials = list(MAT_METAL=3000,MAT_GLASS=2000)
	construction_time = 20 SECONDS
	category = list("Exosuit Equipment")

/datum/design/syringe_gun_upgrade
	name = "Exosuit Medical Equipment (Syringe Gun Upgrade)"
	id = "mech_syringe_gun_upgrade"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade
	req_tech = list("materials" = 7, "engineering" = 6, "biotech" = 7, "bluespace" = 6, "toxins" = 6)
	materials = list(MAT_METAL=8000,MAT_DIAMOND=1000,MAT_GLASS=1000,MAT_GOLD=1000,MAT_URANIUM=500,MAT_BLUESPACE=1000)
	construction_time = 20 SECONDS
	category = list("Exosuit Equipment")

/datum/design/medical_jaw
	name = "Exosuit Medical Equipment (Rescue Jaw)"
	id = "mech_medical_jaw"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw
	req_tech = list("materials" = 4, "engineering" = 6, "magnets" = 6)	//now same as jaws of life
	materials = list(MAT_METAL=5000,MAT_SILVER=2000,MAT_TITANIUM=1500)
	construction_time = 20 SECONDS
	category = list("Exosuit Equipment")

/datum/design/improved_exosuit_control_system
    name = "Exosuit Common Equipment (Control System Upgrade)"
    id = "mech_improved_exosuit_control_system"
    build_type = MECHFAB
    build_path = /obj/item/mecha_parts/mecha_equipment/improved_exosuit_control_system
    req_tech = list("engineering" = 7, "materials" = 6, "magnets" = 5, "powerstorage"= 5)
    materials = list(MAT_METAL=20000,MAT_TITANIUM=10000,MAT_SILVER=2000,MAT_URANIUM=2000)
    construction_time = 20 SECONDS
    category = list("Exosuit Equipment")

/datum/design/mech_repair_droid
	name = "Exosuit Defence Module (Repair Droid)"
	desc = "Automated Repair Droid. BEEP BOOP"
	id = "mech_repair_droid"
	build_type = MECHFAB
	req_tech = list("magnets" = 3, "programming" = 3, "engineering" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_GOLD=1000,MAT_SILVER=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_ccw_armor
	name = "Exosuit Defence Module (Armor Booster (Close Combat))"
	desc = "Exosuit-mounted armor booster."
	id = "mech_ccw_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	materials = list(MAT_METAL=20000,MAT_SILVER=5000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_proj_armor
	name = "Exosuit Defence Module (Armor Booster (Range Combat))"
	desc = "Exosuit-mounted armor booster."
	id = "mech_proj_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 5, "engineering"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	materials = list(MAT_METAL=20000,MAT_GOLD=5000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

// Exosuit Weapons

/datum/design/mech_grenade_launcher
	name = "Exosuit Non-lethal Weapon (SGL-6 Flashbang Launcher)"
	desc = "Allows for the construction of SGL-6 Flashbang Launcher."
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	materials = list(MAT_METAL=22000,MAT_GOLD=6000,MAT_SILVER=8000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/clusterbang_launcher
	name = "Exosuit Non-lethal Weapon (SOB-3 Clusterbang Flashbang Launcher)"
	desc = "A weapon that violates the Geneva Convention at 3 rounds per minute"
	id = "clusterbang_launcher"
	build_type = MECHFAB
	req_tech = list("combat"= 5, "materials" = 5, "syndicate" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang
	materials = list(MAT_METAL=20000,MAT_GOLD=10000,MAT_URANIUM=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_bola
	name = "Exosuit Non-lethal Weapon (PCMK-6 Bola Launcher)"
	desc = "Allows for the construction of PCMK-6 Bola Launcher."
	id = "mech_bola"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_taser
	name = "Exosuit Non-lethal Weapon (PBT \"Pacifier\" Mounted Taser)"
	id = "mech_taser"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_disabler
	name = "Exosuit Non-lethal Weapon (CH-PD Disabler)"
	desc = "Allows for the construction of CH-PD Disabler."
	id = "mech_disabler"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_scattershot_riot
	name = "Exosuit Non-lethal Weapon (LBX AC 9 \"Riot Scattershot\")"
	desc = "Allows for the construction of LBX AC 9."
	id = "mech_scattershot_riot"
	build_type = MECHFAB
	req_tech = list("combat" = 3, "materials" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/riot
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_laser_heavy
	name = "Exosuit Lethal Weapon (CH-LC \"Solaris\" Laser Cannon)"
	desc = "Allows for the construction of CH-LC Laser Cannon."
	id = "mech_laser_heavy"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "magnets" = 4, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_lmg
	name = "Exosuit Lethal Weapon (\"Ultra AC 2\" LMG)"
	id = "mech_lmg"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_almg
	name = "Exosuit Lethal Weapon (ALMG-90)"
	desc = "Allows for the construction of ALMG-90."
	id = "mech_ALMG"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/amlg
	materials = list(MAT_METAL=8000,MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_scattershot
	name = "Exosuit Lethal Weapon (LBX AC 10 \"Scattershot\")"
	desc = "Allows for the construction of LBX AC 10."
	id = "mech_scattershot"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_ion
	name = "Exosuit Lethal Weapon (MKIV Ion Heavy Cannon)"
	desc = "Allows for the construction of MKIV Ion Heavy Cannon."
	id = "mech_ion"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	materials = list(MAT_METAL=20000,MAT_SILVER=6000,MAT_URANIUM=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_missile_rack
	name = "Exosuit Lethal Weapon (SRM-8 Missile Rack)"
	desc = "Allows for the construction of SRM-8 Missile Rack."
	id = "mech_missile_rack"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "materials" = 5, "engineering" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	materials = list(MAT_METAL=22000,MAT_GOLD=6000,MAT_SILVER=8000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_tesla
	name = "Exosuit Lethal Weapon (P-X Tesla Cannon)"
	desc = "Allows for the construction of P-X Tesla Cannon."
	id = "mech_tesla"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	materials = list(MAT_METAL=20000,MAT_SILVER=8000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_laser
	name = "Exosuit Lethal Weapon (CH-PL \"Firedart\" Laser)"
	desc = "Allows for the construction of CH-PS Laser."
	id = "mech_laser"
	build_type = MECHFAB
	req_tech = list("combat" = 3, "magnets" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_carbine
	name = "Exosuit Lethal Weapon (FNX-99 \"Hades\" Carbine)"
	desc = "Allows for the construction of FNX-99 \"Hades\" Carbine."
	id = "mech_carbine"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "materials" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	materials = list(MAT_METAL=10000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/xray_mecha
	name = "Exosuit Lethal Weapon (S-1 X-Ray Projector)"
	desc = "A weapon for combat exosuits. Fires beams of X-Rays that pass through solid matter."
	id = "mech_xray"
	req_tech = list("combat" = 7, "magnets" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = MECHFAB
	materials = list(MAT_GOLD = 5000, MAT_URANIUM = 4000, MAT_METAL = 5000, MAT_TITANIUM = 2000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/xray
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_immolator
	name = "Exosuit Lethal Weapon (ZFI Immolation Beam Gun)"
	desc = "Allows for the construction of ZFI Immolation Beam Gun."
	id = "mech_immolator"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator
	materials = list(MAT_METAL = 10000, MAT_SILVER = 8000, MAT_PLASMA = 8000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")
	locked = TRUE

/datum/design/mech_energy_relay
	name = "Exosuit Generator Equipment (Tesla Generator)"
	desc = "Tesla Energy Relay"
	id = "mech_energy_relay"
	build_type = MECHFAB
	req_tech = list("magnets" = 4, "powerstorage" = 5, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	materials = list(MAT_METAL=10000,MAT_GLASS=2000,MAT_GOLD=2000,MAT_SILVER=3000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_generator
	name = "Exosuit Generator Equipment (Plasma Generator)"
	id = "mech_generator"
	req_tech = list("powerstorage" = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	materials = list(MAT_METAL=10000,MAT_GLASS=1000,MAT_SILVER=2000,MAT_PLASMA=5000)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_generator_nuclear
	name = "Exosuit Generator Equipment (Nuclear Reactor)"
	desc = "Compact nuclear reactor module."
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	req_tech = list("powerstorage"= 5, "engineering" = 4, "materials" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	materials = list(MAT_METAL=10000,MAT_GLASS=1000,MAT_SILVER=500)
	construction_time = 10 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_banana_mortar
	name = "H.O.N.K Banana Mortar"
	id = "mech_banana_mortar"
	req_tech = list("combat" = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 30 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_honker
	name = "HoNkER BlAsT 5000"
	id = "mech_honker"
	req_tech = list("combat" = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/honker
	materials = list(MAT_METAL=20000,MAT_BANANIUM=10000)
	construction_time = 50 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_mousetrap_mortar
	name = "H.O.N.K Mousetrap Mortar"
	id = "mech_mousetrap_mortar"
	req_tech = list("combat" = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 30 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_silentgun
	name = "Mime Module (\"Quietus\" Carbine)"
	id = "mech_silentgun"
	req_tech = list("combat" = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	materials = list(MAT_METAL=20000,MAT_TRANQUILLITE=10000)
	construction_time = 50 SECONDS
	category = list("Exosuit Equipment")

/datum/design/mech_mimercd
	name = "Mime Module (MRCD)"
	desc = "An exosuit-mounted Mime Rapid Construction Device."
	id = "mech_mrcd"
	req_tech = list("combat" = 2)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mimercd
	materials = list(MAT_METAL=30000,MAT_TRANQUILLITE=10000)
	construction_time = 70 SECONDS
	category = list("Exosuit Equipment")

//Cyborg Upgrade Modules

/datum/design/borg_upgrade_reset
	name = "Cyborg Maintenance Module (Reset)"
	id = "borg_upgrade_reset"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/reset
	materials = list(MAT_METAL=10000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_rename
	name = "Cyborg Maintenance Module (Rename)"
	id = "borg_upgrade_rename"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	materials = list(MAT_METAL=35000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_restart
	name = "Cyborg Maintenance Module (Restart)"
	id = "borg_upgrade_restart"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	materials = list(MAT_METAL=60000 , MAT_GLASS=5000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_vtec
	name = "Cyborg Common Upgrade (VTEC)"
	id = "borg_upgrade_vtec"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	req_tech = list("engineering" = 4, "materials" = 5, "programming" = 4)
	materials = list(MAT_METAL=80000 , MAT_GLASS=6000 , MAT_URANIUM= 5000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_magboots
	name = "Cyborg Common Upgrade (F-Magnet)"
	id = "borg_update_magboots"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/magboots
	req_tech = list("engineering" = 5, "materials" = 5, "powerstorage" = 5)
	materials = list(MAT_METAL=5000, MAT_SILVER=3000, MAT_GOLD=4000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_thrusters
	name = "Cyborg Common Upgrade (Ion Thrusters)"
	id = "borg_upgrade_thrusters"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/thrusters
	req_tech = list("engineering" = 4, "powerstorage" = 4)
	materials = list(MAT_METAL=10000, MAT_PLASMA=5000, MAT_URANIUM = 6000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_selfrepair
	name = "Cyborg Common Upgrade (Self-Repair)"
	id = "borg_upgrade_selfrepair"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/selfrepair
	req_tech = list("materials" = 4, "engineering" = 4)
	materials = list(MAT_METAL=15000, MAT_GLASS=15000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_gps
	name = "Cyborg Common Upgrade (GPS Upgrade)"
	id = "borg_upgrade_gps"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/gps
	req_tech = list("engineering" = 7, "programming" = 7, "materials" = 5, "magnets" = 6)
	materials = list(MAT_METAL = 10000, MAT_GOLD = 2000, MAT_SILVER = 2000, MAT_TITANIUM = 500)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_syndicate_module
	name = "Cyborg Common Upgrade (Safety Override)"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	req_tech = list("combat" = 7, "programming" = 7)
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(MAT_METAL=10000,MAT_GLASS=15000,MAT_DIAMOND = 10000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_storageincreaser
	name = "Cyborg Common Upgrade (Storage Increaser)"
	id = "borg_upgrade_storageincreaser"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/storageincreaser
	req_tech = list("bluespace" = 5, "materials" = 7, "engineering" = 5)
	materials = list(MAT_METAL=15000, MAT_BLUESPACE=2000, MAT_SILVER=6000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/service_bs_beaker
	name = "Cyborg Service Upgrade (Bluespace Beaker)"
	id = "service_bs_beaker"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/bs_beaker
	req_tech = list("bluespace" = 6, "materials" = 5, "plasmatech" = 4)
	materials = list(MAT_GLASS = 3000, MAT_PLASMA = 3000, MAT_DIAMOND = 250, MAT_BLUESPACE = 250)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_abductor_engi
	name = "Engineer Cyborg Upgrade (Abductor Engineering Equipment)"
	id = "borg_upgade_abductor_engi"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/abductor_engi
	req_tech = list("engineering" = 7, "materials" = 7, "abductor" = 4)
	materials = list(MAT_METAL = 25000, MAT_SILVER = 12500, MAT_PLASMA = 5000, MAT_TITANIUM = 10000, MAT_DIAMOND = 10000) //Base abductor engineering tools * 4
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_hypospray
	name = "Medical Cyborg Upgrade (Upgraded Hypospray)"
	id = "borg_upgrade_hypospray"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray
	req_tech = list("biotech" = 7, "materials" = 7)
	materials = list(MAT_METAL=15000, MAT_URANIUM=2000, MAT_DIAMOND=5000, MAT_SILVER=10000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_hypospray_pierce
	name = "Medical Cyborg Upgrade (Hypospray Advanced Injector)"
	id = "borg_upgrade_hypospray_pierce"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray_pierce
	req_tech = list("materials" = 5, "biotech" = 6, "engineering" = 6)
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_DIAMOND = 500, MAT_TITANIUM = 10000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_abductor_medi
	name = "Medical Cyborg Upgrade (Abductor Medical Equipment)"
	id = "borg_upgade_abductor_medi"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/abductor_medi
	req_tech = list("biotech" = 7, "materials" = 7, "abductor" = 3)
	materials = list(MAT_METAL = 18000, MAT_GLASS = 1500, MAT_SILVER = 13000, MAT_GOLD = 1000, MAT_PLASMA = 4000, MAT_TITANIUM = 12000, MAT_DIAMOND = 1000) //Base abductor engineering tools *8 + IMS cost
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_disablercooler
	name = "Security Cyborg Upgrade (Rapid Disabler Cooling)"
	id = "borg_upgrade_disablercooler"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/disablercooler
	req_tech = list("combat" = 5, "powerstorage" = 4, "engineering" = 4)
	materials = list(MAT_METAL=80000 , MAT_GLASS=6000 , MAT_GOLD= 2000, MAT_DIAMOND = 500)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_damage_mod
	name = "Mining Cyborg Upgrade (KA Damage Mod)"
	id = "borg_damagemod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/damage/borg
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_cooldown_mod
	name = "Mining Cyborg Upgrade (KA Cooldown Mod)"
	id = "borg_cooldownmod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/haste/borg
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_range_mod
	name = "Mining Cyborg Upgrade (KA Range Mod)"
	id = "borg_rangemod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/range/borg
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_hardness_mod
	name = "Mining Cyborg Upgrade (KA Hardness Mod)"
	id = "borg_hardnessmod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2800, MAT_GLASS = 2100, MAT_GOLD = 2100, MAT_URANIUM = 1400)
	build_path = /obj/item/borg/upgrade/modkit/hardness/borg
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_hyperaccelerator
	name = "Mining Cyborg Upgrade (KA Mining AoE Mod)"
	id = "borg_hypermod"
	req_tech = list("materials" = 7, "powerstorage" = 5, "engineering" = 5, "magnets" = 5, "combat" = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 8000, MAT_GLASS = 1500, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/borg
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_offensive_turf_aoe
	name = "Mining Cyborg Upgrade (KA Offensive Mining Explosion Mod)"
	id = "borg_hyperaoemod"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 2, "magnets" = 2, "combat" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 7000, MAT_GLASS = 3000, MAT_SILVER= 3000, MAT_GOLD = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs/borg
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_rapid_repeater
	name = "Mining Cyborg Upgrade (KA Rapid Repeater Mod)"
	id = "borg_repeatermod"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 2, "magnets" = 2, "combat" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_URANIUM = 8000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater/borg
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_resonator_blast
	name = "Mining Cyborg Upgrade (KA Resonator Blast Mod)"
	id = "borg_resonatormod"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 2, "magnets" = 2, "combat" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_SILVER= 5000, MAT_URANIUM = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts/borg
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_diamonddrill
	name = "Mining Cyborg Upgrade (Diamond Drill)"
	id = "borg_upgrade_diamonddrill"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ddrill
	req_tech = list("engineering" = 5, "materials" = 6)
	materials = list(MAT_METAL=10000, MAT_DIAMOND=2000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_lavaproof
	name = "Mining Cyborg Upgrade (Lavaproof Chassis)"
	id = "borg_upgrade_lavaproof"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 2, "magnets" = 2, "combat" = 2)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/lavaproof
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 4000, MAT_TITANIUM = 5000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_holding
	name = "Mining Cyborg Upgrade (Ore Satchel of Holding)"
	id = "borg_upgrade_holding"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/soh
	req_tech = list("engineering" = 4, "materials" = 4, "bluespace" = 4)
	materials = list(MAT_METAL = 10000, MAT_GOLD = 250, MAT_URANIUM = 500)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

//IPC

/datum/design/integrated_robotic_chassis
	name = "Integrated Robotic Chassis"
	id = "integrated_robotic_chassis"
	build_type = MECHFAB
	build_path = /mob/living/carbon/human/machine/created
	materials = list(MAT_METAL = 40000, MAT_TITANIUM = 7000) //for something made from lego, they sure need a lot of metal
	construction_time = 40 SECONDS
	category = list("IPC")

/datum/design/ipc_cell
	name = "IPC Microbattery"
	id = "ipc_cell"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/cell
	materials = list(MAT_METAL=2000, MAT_GLASS=750)
	construction_time = 20 SECONDS
	category = list("IPC")

/datum/design/ipc_head
	name = "IPC Head"
	id = "ipc_head"
	build_type = MECHFAB
	build_path = /obj/item/organ/external/head/ipc
	materials = list(MAT_METAL=5000)
	construction_time = 35 SECONDS
	category = list("IPC")

/datum/design/ipc_optics
	name = "IPC Optical Sensor"
	id = "ipc_optics"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/eyes/optical_sensor
	materials = list(MAT_METAL=1000, MAT_GLASS=2500)
	construction_time = 20 SECONDS
	category = list("IPC")

/datum/design/ipc_microphone
	name = "IPC Microphone"
	id = "ipc_microphone"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/ears/microphone
	materials = list(MAT_METAL = 1000, MAT_GLASS = 2500)
	construction_time = 20 SECONDS
	category = list("IPC")

/datum/design/ipc_r_arm
	name = "IPC Right Arm"
	id = "ipc_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_arm
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list("IPC")

/datum/design/ipc_charger
	name = "IPC Charger Arm Implant"
	id = "ipc_cahrger"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/cyberimp/arm/power_cord
	materials = list(MAT_METAL=2000, MAT_GLASS=1000)
	construction_time = 20 SECONDS
	category = list("IPC")

/datum/design/ipc_l_arm
	name = "IPC Left Arm"
	id = "ipc_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_arm
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list("IPC")


/datum/design/ipc_l_leg
	name = "IPC Left Leg"
	id = "ipc_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_leg
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list("IPC")

/datum/design/ipc_r_leg
	name = "IPC Right Leg"
	id = "ipc_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_leg
	materials = list(MAT_METAL=10000)
	construction_time = 20 SECONDS
	category = list("IPC")

//Misc

/datum/design/mecha_tracking
	name = "Exosuit Tracking Beacon"
	id = "mecha_tracking"
	req_tech = list("magnets" = 2)
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/mecha_tracking
	materials = list(MAT_METAL=500)
	construction_time = 5 SECONDS
	category = list("Misc")

/datum/design/mecha_tracking_ai_control
	name = "AI Control Beacon"
	id = "mecha_tracking_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_tracking/ai_control
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 200)
	req_tech = list("programming" = 3, "magnets" = 2, "engineering" = 2)
	construction_time = 5 SECONDS
	category = list("Misc")

/datum/design/voice_standard
	name = "Voice Modkit : Standard"
	desc = "A modification kit that updates a mech's onboard voice to Standard."
	id = "voice_standard"
	req_tech = list("magnets" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice
	category = list("Misc")

/datum/design/voice_nanotrasen
	name = "Voice Modkit : Nanotrasen"
	desc = "A modification kit that updates a mech's onboard voice to Nanotrasen."
	id = "voice_nanotrasen"
	req_tech = list("magnets" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice/nanotrasen
	category = list("Misc")

/datum/design/voice_silent
	name = "Voice Modkit : Silent"
	desc = "A modification kit that silences a mech's onboard voice."
	id = "voice_silent"
	req_tech = list("magnets" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice/silent
	category = list("Misc")

/datum/design/voice_honk
	name = "Voice Modkit : Honk"
	desc = "A modification kit that updates a mech's onboard voice to Honk. This is a terrible idea."
	id = "voice_honk"
	req_tech = list("magnets" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 400, MAT_BANANIUM = 100)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice/honk
	category = list("Misc")

/datum/design/voice_syndicate
	name = "Voice Modkit : Syndicate"
	desc = "A modification kit that updates a mech's onboard voice to Syndicate."
	id = "voice_syndicate"
	build_type = MECHFAB
	materials = list(MAT_METAL = 400, MAT_TITANIUM = 100)
	req_tech = list("syndicate" = 2)
	construction_time = 5 SECONDS
	build_path = /obj/item/mecha_modkit/voice/syndicate
	category = list("Misc")

//Syndie

/datum/design/syndicate_robotic_brain
	name = "Syndicate Robotic Brain"
	desc = "The latest in Anti-Monopolistic non-sentient Artificial Intelligences. Property of the Syndicate!"
	id = "mmi_robotic_syndicate"
	req_tech = list("programming" = 4, "biotech" = 3, "plasmatech" = 2,"syndicate" = 6)
	build_type = MECHFAB
	materials = list(MAT_METAL = 1700, MAT_GLASS = 2700, MAT_GOLD = 1000, MAT_TITANIUM = 1000)
	construction_time = 7.5 SECONDS
	build_path = /obj/item/mmi/robotic_brain/syndicate
	category = list("Syndicate")

/datum/design/syndicate_quantumpad
	name = "Syndicate Quantumpad Curcuit"
	desc = "Circuit board for constructing special redspace quantumpad capable of ignoring bluespace interference! Property of the Syndicate!"
	id = "syndicate_quantumpad"
	req_tech = list("programming" = 3, "engineering" = 3, "plasmatech" = 3,"syndicate" = 6)
	build_type = MECHFAB
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 2000)
	construction_time = 5 SECONDS
	build_path = /obj/item/circuitboard/quantumpad/syndiepad
	category = list("Syndicate")

/datum/design/syndicate_cargo_console
	name = "Syndicate Supply Pad Console Curcuit"
	desc = "Circuit board for constructing your own black market console! Property of the Syndicate!"
	id = "syndicate_supply_pad"
	req_tech = list("programming" = 3, "syndicate" = 3)
	build_type = MECHFAB
	materials = list(MAT_GLASS = 1000)
	construction_time = 5 SECONDS
	build_path = /obj/item/circuitboard/syndicatesupplycomp
	category = list("Syndicate")

/datum/design/syndicate_public_cargo_console
	name = "Syndicate Public Supply Pad Console Curcuit"
	desc = "Circuit board for constructing your own public black market console! Property of the Syndicate!"
	id = "syndicate_public_supply_pad"
	req_tech = list("programming" = 3, "syndicate" = 3)
	build_type = MECHFAB
	materials = list(MAT_GLASS = 1000)
	construction_time = 5 SECONDS
	build_path = /obj/item/circuitboard/syndicatesupplycomp/public
	category = list("Syndicate")

/datum/design/syndicate_borg_RCD_upgrade
	name = "Syndicate cyborg RCD upgrade"
	desc = "An experimental upgrade that replaces cyborgs RCDs with the syndicate version."
	id = "syndicate_cyborg_RCD_upgrade"
	req_tech = list("engineering" = 6, "materials" = 6, "syndicate" = 5)
	build_type = MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_GOLD = 1000, MAT_TITANIUM = 5000, MAT_PLASMA = 5000)
	construction_time = 5 SECONDS
	build_path = /obj/item/borg/upgrade/syndie_rcd
	category = list("Syndicate")

//Paintkits
/datum/design/paint_ripley_titan
	name = "Ripley, Firefighter \"Titan's Fist\""
	id = "p_titan"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "engineering" = 5, "materials" = 5, "programming" = 5)
	build_path = /obj/item/paintkit/ripley_titansfist
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_ripley_earth
	name = "Ripley, Firefighter \"Strike the Earth!\""
	id = "p_earth"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "engineering" = 5, "materials" = 5, "programming" = 5)
	build_path = /obj/item/paintkit/ripley_mercenary
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_ripley_red
	name = "Ripley, Firefighter \"Firestarter\""
	id = "p_red"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "materials" = 5, "toxins" = 5)
	build_path = /obj/item/paintkit/ripley_red
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_hauler
	name = "Ripley, Firefighter \"Hauler\""
	id = "p_hauler"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "materials" = 5, "programming" = 5)
	build_path = /obj/item/paintkit/firefighter_Hauler
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_zairjah
	name = "Ripley, Firefighter \"Zairjah\""
	id = "p_zairjah"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "materials" = 5, "programming" = 5, "toxins" = 5)
	build_path = /obj/item/paintkit/firefighter_zairjah
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_combat
	name = "Ripley, Firefighter \"Combat Ripley\""
	id = "p_combat"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "engineering" = 5, "materials" = 5, "programming" = 5)
	build_path = /obj/item/paintkit/firefighter_combat
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_reaper
	name = "Ripley, Firefighter \"Reaper\""
	id = "p_reaper"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "engineering" = 5, "materials" = 5, "programming" = 5,"toxins" = 5)
	build_path = /obj/item/paintkit/firefighter_Reaper
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_aluminizer
	name = "Ripley, Firefighter \"Aluminizer\""
	id = "p_aluminizer"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "materials" = 5, "programming" = 5,"toxins" = 5)
	build_path = /obj/item/paintkit/firefighter_aluminizer
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_ripley_nt
	name = "Ripley, Firefighter \"NT Special\""
	id = "p_ripleynt"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "engineering" = 5, "materials" = 5, "programming" = 5)
	build_path = /obj/item/paintkit/ripley_nt
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 2000, MAT_GLASS = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_clarke_orangey
	name = "Clarke \"Orangey\""
	id = "p_orangey"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "materials" = 5, "toxins" = 5)
	build_path = /obj/item/paintkit/clarke_orangey
	materials = list(MAT_METAL = 20000, MAT_DIAMOND = 2000, MAT_URANIUM = 2000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_clarke_spiderclarke
	name = "Clarke \"Spiderclarke\""
	id = "p_spiderclarke"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "engineering" = 5, "materials" = 5, "toxins" = 5)
	build_path = /obj/item/paintkit/clarke_spiderclarke
	materials = list(MAT_METAL = 20000, MAT_DIAMOND = 2000, MAT_URANIUM = 2000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_odysseus_hermes
	name = "Odysseus \"Hermes\""
	id = "p_hermes"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "materials" = 5, "programming" = 5,"biotech" = 5)
	build_path = /obj/item/paintkit/odysseus_hermes
	materials = list(MAT_METAL = 20000, MAT_DIAMOND = 2000, MAT_URANIUM = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_odysseus_reaper
	name = "Odysseus \"Reaper\""
	id = "p_odyreaper"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "engineering" = 5, "materials" = 5, "programming" = 5, "toxins" = 5)
	build_path = /obj/item/paintkit/odysseus_death
	materials = list(MAT_METAL = 20000, MAT_DIAMOND = 2000, MAT_URANIUM = 2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_alt
	name = "Gygax \"Old\""
	id = "p_altgygax"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "engineering" = 5, "materials" = 5, "programming" = 4)
	build_path = /obj/item/paintkit/gygax_alt
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_pobeda
	name = "Gygax \"Pobeda\""
	id = "p_pobedagygax"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "engineering" = 4, "materials" = 4, "programming" = 6)
	build_path = /obj/item/paintkit/gygax_pobeda
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_white
	name = "Gygax \"White\""
	id = "p_whitegygax"
	build_type = MECHFAB
	req_tech = list("biotech" = 4, "engineering" = 4, "materials" = 5, "programming" = 3 )
	build_path = /obj/item/paintkit/gygax_white
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_medgax
	name = "Gygax \"Medgax\""
	id = "p_medgax"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "materials" = 5, "programming" = 6,"biotech" = 6, "toxins" = 6)
	build_path = /obj/item/paintkit/gygax_medgax
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_black
	name = "Gygax \"Syndicate\""
	id = "p_blackgygax"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 5, "materials" = 6, "programming" = 5, "syndicate" = 3)
	build_path = /obj/item/paintkit/gygax_syndie
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_pirate
	name = "Gygax \"Pirate\""
	id = "p_pirategygax"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/gygax_pirate
	materials = list(MAT_METAL = 30000, MAT_DIAMOND = 3000, MAT_URANIUM = 3000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_unathi
	name = "Durand \"Kharn MK. IV\""
	id = "p_unathi"
	build_type = MECHFAB
	req_tech = list("materials" = 6, "biotech" = 6)
	build_path = /obj/item/paintkit/durand_unathi
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_shire
	name = "Durand \"Shire\""
	id = "p_shire"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/durand_shire
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_pirate
	name = "Durand \"Pirate\""
	id = "p_durandpirate"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/durand_pirate
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_nt
	name = "Durand \"NT Special\""
	id = "p_durandnt"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/durand_nt
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_soviet
	name = "Durand \"Dollhouse\""
	id = "p_soviet"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 6, "materials" = 6, "programming" = 6, "toxins" = 6)
	build_path = /obj/item/paintkit/durand_soviet
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_URANIUM = 4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_executor
	name = "Durand \"mk.V Executioner\""
	id = "p_executor"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/durand_executor
	materials = list(MAT_METAL = 40000, MAT_DIAMOND = 4000, MAT_SILVER = 4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_imperion
	name = "Phazon \"Imperion\""
	id = "p_imperion"
	build_type = MECHFAB
	req_tech = list("bluespace" = 6, "engineering" = 6, "materials" = 6, "programming" = 6, "toxins" = 5)
	build_path = /obj/item/paintkit/phazon_imperion
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_janus
	name = "Phazon \"Janus\""
	id = "p_janus"
	build_type = MECHFAB
	req_tech = list("bluespace" = 6, "engineering" = 6, "materials" = 6, "programming" = 6, "toxins" = 5)
	build_path = /obj/item/paintkit/phazon_janus
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_plazmus
	name = "Phazon \"Plazmus\""
	id = "p_plazmus"
	build_type = MECHFAB
	req_tech = list("bluespace" = 6, "engineering" = 6, "materials" = 6, "toxins" = 5)
	build_path = /obj/item/paintkit/phazon_plazmus
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_PLASMA = 5000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_blanco
	name = "Phazon \"Blanco\""
	id = "p_blanco"
	build_type = MECHFAB
	req_tech = list("bluespace" = 7, "engineering" = 7, "materials" = 7, "toxins" = 6)
	build_path = /obj/item/paintkit/phazon_blanco
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_nt
	name = "Phazon \"NT Special\""
	id = "p_phazonnt"
	build_type = MECHFAB
	req_tech = list("bluespace" = 7, "engineering" = 7, "materials" = 7, "toxins" = 6)
	build_path = /obj/item/paintkit/phazon_nt
	materials = list(MAT_METAL = 50000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_ashed
	name = "Ashed \"Mechs\""
	id = "p_ashed"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "materials" = 6)
	build_path = /obj/item/paintkit/ashed
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 8000, MAT_GLASS = 8000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")
