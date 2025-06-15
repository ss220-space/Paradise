/datum/robot_skin
	var/name = "Это баг"
	var/icon_file = 'icons/mob/robots.dmi'
	var/icon_base_prefix = "robot"
	var/panelprefix = "ov"
	var/eye_prefix = "robot"
	var/required_permit
	var/donator_tier

/datum/robot_skin/tall
	icon_file = 'icons/mob/tallrobot.dmi'

/datum/robot_skin/tall/meka
	name = "Meka"
	required_permit = MEKA_PERMISSION

/datum/robot_skin/tall/fmeka
	name = "Female Meka"
	required_permit = FMEKA_PERMISSION

/datum/robot_skin/tall/mmeka
	name = "Male Meka"
	required_permit = MMEKA_PERMISSION

/datum/robot_skin/robot
	name = "Robot"
	icon_base_prefix = "robot"

/datum/robot_skin/basic
	name = "Basic"
	eye_prefix = "Robot"

/datum/robot_skin/default
	name = "Standard"
	eye_prefix = "Standard"

/datum/robot_skin/noble
	panelprefix = "Noble"
	eye_prefix = "Noble"

/datum/robot_skin/cricket
	name = "Cricket"
	panelprefix = "Cricket"
	eye_prefix = "Cricket"

/datum/robot_skin/basic/std
	icon_base_prefix = "Robot-STD"

/datum/robot_skin/default/std
	name = "Default"
	icon_base_prefix = "Standard"

/datum/robot_skin/noble/std
	name = "Noble-STD"
	icon_base_prefix = "Noble-STD"

/datum/robot_skin/android
	name = "Android"
	icon_base_prefix = "droid"
	eye_prefix = "droid"

/datum/robot_skin/default/medical
	icon_base_prefix = "Standard-Medi"

/datum/robot_skin/basic/medical
	icon_base_prefix = "Robot-MED"

/datum/robot_skin/noble/medical
	name = "Noble-MED"
	icon_base_prefix = "Noble-MED"

/datum/robot_skin/cricket/medical
	icon_base_prefix = "Cricket-MEDI"

/datum/robot_skin/tall/meka/medical
	icon_base_prefix = "mekamed"
	eye_prefix = "mekamed"
	panelprefix = "ov-med"

/datum/robot_skin/tall/fmeka/medical
	icon_base_prefix = "fmekamed"
	eye_prefix = "fmekamed"
	panelprefix = "ov-med"

/datum/robot_skin/tall/mmeka/medical
	icon_base_prefix = "mmekamed"
	eye_prefix = "mmekamed"
	panelprefix = "ov-med"

/datum/robot_skin/surgeon
	name = "Surgeon"
	icon_base_prefix = "surgeon"
	eye_prefix = "surgeon"

/datum/robot_skin/chiefbot
	name = "Chiefbot"
	icon_base_prefix = "chiefbot"
	eye_prefix = "chiefbot"

/datum/robot_skin/droid_medical
	name = "Advanced Droid"
	icon_base_prefix = "droid-medical"
	eye_prefix = "droid-medical"

/datum/robot_skin/basic/needles
	name = "Needles"
	icon_base_prefix = "Robot-SRG"

/datum/robot_skin/default/eng
	icon_base_prefix = "Standard-Engi"

/datum/robot_skin/basic/eng
	icon_base_prefix = "Robot-ENG"

/datum/robot_skin/noble/eng
	name = "Noble-ENG"
	icon_base_prefix = "Noble-ENG"

/datum/robot_skin/cricket/eng
	icon_base_prefix = "Cricket-ENGI"

/datum/robot_skin/tall/meka/eng
	icon_base_prefix = "mekaengi"
	eye_prefix = "mekaengi"
	panelprefix = "ov-engi"

/datum/robot_skin/tall/fmeka/eng
	icon_base_prefix = "fmekaengi"
	eye_prefix = "fmekaengi"
	panelprefix = "ov-engi"

/datum/robot_skin/tall/mmeka/eng
	icon_base_prefix = "mmekaengi"
	eye_prefix = "mmekaengi"
	panelprefix = "ov-engi"

/datum/robot_skin/basic/antique
	name = "Antique"
	icon_base_prefix = "Robot-ENG2"

/datum/robot_skin/landmate
	name = "Landmate"
	icon_base_prefix = "landmate"
	eye_prefix = "landmate"

/datum/robot_skin/chiefmate
	name = "Сhiefmate"
	icon_base_prefix = "chiefmate"
	eye_prefix = "chiefmate"

/datum/robot_skin/default/sec
	icon_base_prefix = "Standard-Secy"

/datum/robot_skin/basic/sec
	icon_base_prefix = "Robot-SEC"

/datum/robot_skin/noble/sec
	name = "Noble-SEC"
	icon_base_prefix = "Noble-SEC"

/datum/robot_skin/cricket/sec
	icon_base_prefix = "Cricket-SEC"

/datum/robot_skin/tall/meka/sec
	icon_base_prefix = "mekasec"
	eye_prefix = "mekasec"
	panelprefix = "ov-sec"

/datum/robot_skin/tall/fmeka/sec
	icon_base_prefix = "fmekasec"
	eye_prefix = "fmekasec"
	panelprefix = "ov-sec"

/datum/robot_skin/tall/mmeka/sec
	icon_base_prefix = "mmekasec"
	eye_prefix = "mmekasec"
	panelprefix = "ov-sec"

/datum/robot_skin/redknight
	name = "Red Knight"
	icon_base_prefix = "Security"
	eye_prefix = "Security"

/datum/robot_skin/blackknight
	name = "Black Knight"
	icon_base_prefix = "securityrobot"
	eye_prefix = "securityrobot"

/datum/robot_skin/bloodhound
	name = "Bloodhound"
	icon_base_prefix = "bloodhound"
	eye_prefix = "bloodhound"

/datum/robot_skin/default/jan
	icon_base_prefix = "Standard-Jani"

/datum/robot_skin/basic/jan
	icon_base_prefix = "Robot-JAN"

/datum/robot_skin/noble/jan
	name = "Noble-CLN"
	icon_base_prefix = "Noble-CLN"

/datum/robot_skin/cricket/jan
	icon_base_prefix = "Cricket-JANI"

/datum/robot_skin/tall/meka/jan
	icon_base_prefix = "mekajani"
	eye_prefix = "mekajani"
	panelprefix = "ov-jani"

/datum/robot_skin/tall/fmeka/jan
	icon_base_prefix = "fmekajani"
	eye_prefix = "fmekajani"
	panelprefix = "ov-jani"

/datum/robot_skin/tall/mmeka/jan
	icon_base_prefix = "mmekajani"
	eye_prefix = "mmekajani"
	panelprefix = "ov-jani"

/datum/robot_skin/basic/mopbot
	name = "Mopbot"
	icon_base_prefix = "Robot-JAN2"

/datum/robot_skin/mopgearrex
	name = "Mop Gear Rex"
	icon_base_prefix = "mopgearrex"
	eye_prefix = "mopgearrex"

/datum/robot_skin/default/srv
	icon_base_prefix = "Standard-Serv"

/datum/robot_skin/basic/default
	name = "Default"
	icon_base_prefix = "Robot-MAN"

/datum/robot_skin/noble/srv
	name = "Noble-SRV"
	icon_base_prefix = "Noble-SRV"

/datum/robot_skin/cricket/srv
	icon_base_prefix = "Cricket-SERV"

/datum/robot_skin/tall/meka/srv
	icon_base_prefix = "mekaserve"
	eye_prefix = "mekaserve"
	panelprefix = "ov-serve"

/datum/robot_skin/tall/meka/srv_alt
	icon_base_prefix = "mekaserve_alt"
	eye_prefix = "mekaserve_alt"
	panelprefix = "ov-serve"

/datum/robot_skin/tall/fmeka/srv
	icon_base_prefix = "fmekaserve"
	eye_prefix = "fmekaserve"
	panelprefix = "ov-serve"

/datum/robot_skin/tall/mmeka/srv
	icon_base_prefix = "mmekaserve"
	eye_prefix = "mmekaserve"
	panelprefix = "ov-serve"

/datum/robot_skin/basic/waitress
	name = "Waitress"
	icon_base_prefix = "Robot-LDY"

/datum/robot_skin/basic/bro
	name = "Bro"
	icon_base_prefix = "Robot-RLX"

/datum/robot_skin/toiletbot
	name = "Kent"
	icon_base_prefix = "toiletbot"
	eye_prefix = "toiletbot"

/datum/robot_skin/maximillion
	name = "Rich"
	icon_base_prefix = "maximillion"
	eye_prefix = "maximillion"

/datum/robot_skin/default/mnr
	icon_base_prefix = "Standard-Mine"

/datum/robot_skin/basic/mnr
	icon_base_prefix = "Robot-MNR"

/datum/robot_skin/noble/mnr
	name = "Noble-DIG"
	icon_base_prefix = "Noble-DIG"

/datum/robot_skin/cricket/mnr
	icon_base_prefix = "Cricket-MINE"

/datum/robot_skin/tall/meka/mnr
	icon_base_prefix = "mekamine"
	eye_prefix = "mekamine"
	panelprefix = "ov-mine"

/datum/robot_skin/tall/fmeka/mnr
	icon_base_prefix = "fmekamine"
	eye_prefix = "fmekamine"
	panelprefix = "ov-mine"

/datum/robot_skin/tall/mmeka/mnr
	icon_base_prefix = "mmekamine"
	eye_prefix = "mmekamine"
	panelprefix = "ov-mine"

/datum/robot_skin/droid_miner
	name = "Advanced Droid"
	icon_base_prefix = "droid-miner"
	eye_prefix = "droid-miner"

/datum/robot_skin/treadhead
	name = "Treadhead"
	icon_base_prefix = "Miner"
	eye_prefix = "Miner"

/datum/robot_skin/lavaland
	name = "Lavaland"
	icon_base_prefix = "lavaland"
	eye_prefix = "lavaland"

/datum/robot_skin/deathsquad
	name = "Deathsquad"
	icon_base_prefix = "nano_bloodhound"
	eye_prefix = "nano_bloodhound"

/datum/robot_skin/syndie_bloodhound
	name = "Syndicate Bloodhound"
	icon_base_prefix = "syndie_bloodhound"
	eye_prefix = "syndie_bloodhound"

/datum/robot_skin/syndie_medi
	name = "Syndicate Medical"
	icon_base_prefix = "syndi-medi"
	eye_prefix = "syndi-medi"

/datum/robot_skin/syndi_engi
	name = "Syndicate Saboteur"
	icon_base_prefix = "syndi-engi"
	eye_prefix = "syndi-engi"

/datum/robot_skin/tall/meka/syndi
	icon_base_prefix = "mekasyndi"
	eye_prefix = "mekasyndi"
	panelprefix = "ov-syndi"

/datum/robot_skin/tall/fmeka/syndi
	icon_base_prefix = "fmekasyndi"
	eye_prefix = "fmekasyndi"
	panelprefix = "ov-syndi"

/datum/robot_skin/tall/mmeka/syndi
	icon_base_prefix = "mmekasyndi"
	eye_prefix = "mmekasyndi"
	panelprefix = "ov-syndi"

/datum/robot_skin/droidcombat
	name = "Destroyer"
	icon_base_prefix = "droidcombat"
	eye_prefix = "droidcombat"

/datum/robot_skin/ertgamma
	name = "ERT-GAMMA"
	icon_base_prefix = "ertgamma"
	eye_prefix = "ertgamma"

/datum/robot_skin/xenoborg
	name = "Xenoborg"
	icon_base_prefix = "xenoborg"
	eye_prefix = "xenoborg"

/datum/robot_skin/clockwork
	name = "Clockwork"
	icon_file = 'icons/mob/clockwork_mobs.dmi'
	icon_base_prefix = "cyborg"
	eye_prefix = "cyborg"

/datum/robot_skin/ninja
	name = "Ninja"
	icon_base_prefix = "ninja"
	eye_prefix = "ninja"

/datum/robot_skin/tall/meka/ninja
	icon_base_prefix = "mekaninja"
	eye_prefix = "mekaninja"
	panelprefix = "ov-ninja"

/datum/robot_skin/tall/fmeka/ninja
	icon_base_prefix = "fmekaninja"
	eye_prefix = "fmekaninja"
	panelprefix = "ov-ninja"

/datum/robot_skin/tall/mmeka/ninja
	icon_base_prefix = "mmekaninja"
	eye_prefix = "mmekaninja"
	panelprefix = "ov-ninja"
