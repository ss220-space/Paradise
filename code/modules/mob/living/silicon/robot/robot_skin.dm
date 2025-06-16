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

/datum/robot_skin/paladin
	name = "Paladin"
	panelprefix = "paladin"
	eye_prefix = "paladin"
	required_permit = PALADIN_PERMISSION

/datum/robot_skin/robot_drone
	name = "Robot drone"
	panelprefix = "robot_drone"
	eye_prefix = ""
	required_permit = ROBOT_DRONE_PERMISSION

/datum/robot_skin/protectron
	name = "Protectron"
	panelprefix = "protectron"
	eye_prefix = ""
	required_permit = FALLOUT_PERMISSION

/datum/robot_skin/coffin
	name = "Coffin"
	panelprefix = "coffin"
	eye_prefix = ""
	required_permit = COFFIN_PERMISSION

/datum/robot_skin/burger
	name = "Burger"
	panelprefix = "burger"
	eye_prefix = ""
	required_permit = BURGER_PERMISSION

/datum/robot_skin/raptor
	name = "Raptor"
	panelprefix = "raptor"
	eye_prefix = ""
	required_permit = RAPTOR_PERMISSION

/datum/robot_skin/doll
	name = "Doll"
	eye_prefix = ""
	required_permit = DOLL_PERMISSION

/datum/robot_skin/buddy
	name = "Buddy"
	panelprefix = "buddy"
	eye_prefix = ""
	required_permit = BUDDY_PERMISSION

/datum/robot_skin/mine
	name = "Mine"
	required_permit = MINE_PERMISSION

/datum/robot_skin/eyebot
	name = "Eyebot"
	required_permit = EYEBOT_PERMISSION

/datum/robot_skin/seek
	name = "Seek"
	required_permit = SEEK_PERMISSION

/datum/robot_skin/noble_h
	panelprefix = "Noble"
	eye_prefix = "Noble-H"
	required_permit = SEEK_PERMISSION

/datum/robot_skin/mech
	name = "Mech"
	required_permit = MECH_PERMISSION

/datum/robot_skin/heavy
	name = "Heavy"
	required_permit = HEAVY_PERMISSION

/datum/robot_skin/spider
	name = "Spider"
	required_permit = SPIDER_PERMISSION

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

/datum/robot_skin/paladin/std
	icon_base_prefix = "paladin-Standard"
	eye_prefix = "paladin-Standard"

/datum/robot_skin/robot_drone/std
	icon_base_prefix = "robot_drone-Standard"

/datum/robot_skin/protectron/std
	icon_base_prefix = "protectron-Standard"

/datum/robot_skin/coffin/std
	icon_base_prefix = "coffin-Standard"

/datum/robot_skin/burger/std
	icon_base_prefix = "burger-Standard"

/datum/robot_skin/raptor/std
	icon_base_prefix = "raptor-Standard"

/datum/robot_skin/doll/std
	icon_base_prefix = "doll-Standard"

/datum/robot_skin/buddy/std
	icon_base_prefix = "buddy-Standard"
	eye_prefix = "buddy-Standard"

/datum/robot_skin/mine/std
	icon_base_prefix = "mine_standard"
	eye_prefix = "mine_standard"

/datum/robot_skin/eyebot/std
	icon_base_prefix = "eyebotsd"
	eye_prefix = "eyebotsd"

/datum/robot_skin/seek/std
	icon_base_prefix = "sleekstandard"
	eye_prefix = "sleekstandard"

/datum/robot_skin/noble_h/std
	icon_base_prefix = "Noble-STD-H"

/datum/robot_skin/mech/std
	icon_base_prefix = "durin"
	eye_prefix = "durin"

/datum/robot_skin/heavy/std
	icon_base_prefix = "heavysd"
	eye_prefix = "heavysd"

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

/datum/robot_skin/paladin/medical
	icon_base_prefix = "paladin-Medical"
	eye_prefix = "paladin-Medical"

/datum/robot_skin/robot_drone/medical
	icon_base_prefix = "robot_drone-Medical"

/datum/robot_skin/protectron/medical
	icon_base_prefix = "protectron-Medical"

/datum/robot_skin/burger/medical
	icon_base_prefix = "burger-Medical"

/datum/robot_skin/raptor/medical
	icon_base_prefix = "raptor-Medical"

/datum/robot_skin/doll/medical
	icon_base_prefix = "doll-Medical"

/datum/robot_skin/buddy/medical
	icon_base_prefix = "buddy-Medical"
	eye_prefix = "buddy-Medical"

/datum/robot_skin/mine/medical
	icon_base_prefix = "mine_med"
	eye_prefix = "mine_med"

/datum/robot_skin/eyebot/medical
	icon_base_prefix = "eyebotmed"
	eye_prefix = "eyebotmed"

/datum/robot_skin/seek/medical
	icon_base_prefix = "sleekmedic"
	eye_prefix = "sleekmedic"

/datum/robot_skin/noble_h/medical
	icon_base_prefix = "Noble-MED-H"

/datum/robot_skin/mech/medical
	icon_base_prefix = "gibbs"
	eye_prefix = "gibbs"

/datum/robot_skin/heavy/medical
	icon_base_prefix = "heavymed"
	eye_prefix = "heavymed"

/datum/robot_skin/walla
	name = "Wall-a"
	icon_base_prefix = "wall-a"
	eye_prefix = "wall-a"
	required_permit = WALLE_PERMISSION

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
	icon_base_prefix = "fmekaeng"
	eye_prefix = "fmekaeng"
	panelprefix = "ov-engi"

/datum/robot_skin/tall/mmeka/eng
	icon_base_prefix = "mmekaeng"
	eye_prefix = "mmekaeng"
	panelprefix = "ov-engi"

/datum/robot_skin/paladin/eng
	icon_base_prefix = "paladin-Engineering"
	eye_prefix = "paladin-Engineering"

/datum/robot_skin/robot_drone/eng
	icon_base_prefix = "robot_drone-Engineering"

/datum/robot_skin/protectron/eng
	icon_base_prefix = "protectron-Engineering"

/datum/robot_skin/coffin/eng
	icon_base_prefix = "coffin-Engineering"

/datum/robot_skin/burger/eng
	icon_base_prefix = "burger-Engineering"

/datum/robot_skin/raptor/eng
	icon_base_prefix = "raptor-Engineering"

/datum/robot_skin/doll/eng
	icon_base_prefix = "doll-Engineering"

/datum/robot_skin/buddy/eng
	icon_base_prefix = "buddy-Engineering"
	eye_prefix = "buddy-Engineering"

/datum/robot_skin/mine/eng
	icon_base_prefix = "mine_engi"
	eye_prefix = "mine_engi"

/datum/robot_skin/eyebot/eng
	icon_base_prefix = "eyeboteng"
	eye_prefix = "eyeboteng"

/datum/robot_skin/seek/eng
	icon_base_prefix = "sleekengineer"
	eye_prefix = "sleekengineer"

/datum/robot_skin/noble_h/eng
	icon_base_prefix = "Noble-ENG-H"

/datum/robot_skin/mech/eng
	icon_base_prefix = "conagher"
	eye_prefix = "conagher"

/datum/robot_skin/heavy/eng
	icon_base_prefix = "heavyeng"
	eye_prefix = "heavyeng"

/datum/robot_skin/spider/eng
	icon_base_prefix = "spidereng"
	eye_prefix = "spidereng"

/datum/robot_skin/handy_eng
	name = "Mr Handy"
	icon_base_prefix = "handyeng"
	eye_prefix = "handyeng"
	required_permit = FALLOUT_PERMISSION

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

/datum/robot_skin/paladin/sec
	icon_base_prefix = "paladin-Security"
	eye_prefix = "paladin-Security"

/datum/robot_skin/robot_drone/sec
	icon_base_prefix = "robot_drone-Security"

/datum/robot_skin/protectron/sec
	icon_base_prefix = "protectron-Security"

/datum/robot_skin/coffin/sec
	icon_base_prefix = "coffin-Security"

/datum/robot_skin/burger/sec
	icon_base_prefix = "burger-Security"

/datum/robot_skin/raptor/sec
	icon_base_prefix = "raptor-Security"

/datum/robot_skin/doll/sec
	icon_base_prefix = "doll-Security"

/datum/robot_skin/buddy/sec
	icon_base_prefix = "buddy-Security"
	eye_prefix = "buddy-Security"

/datum/robot_skin/mine/sec
	icon_base_prefix = "mine_sec"
	eye_prefix = "mine_sec"

/datum/robot_skin/eyebot/sec
	icon_base_prefix = "eyebotsec"
	eye_prefix = "eyebotsec"

/datum/robot_skin/seek/std
	icon_base_prefix = "sleeksecurity"
	eye_prefix = "sleeksecurity"

/datum/robot_skin/noble_h/std
	icon_base_prefix = "Noble-SEC-H"

/datum/robot_skin/mech/std
	icon_base_prefix = "woody"
	eye_prefix = "woody"

/datum/robot_skin/heavy/std
	icon_base_prefix = "heavysec"
	eye_prefix = "heavysec"

/datum/robot_skin/spider/std
	icon_base_prefix = "spidersec"
	eye_prefix = "spidersec"

/datum/robot_skin/securitron
	name = "Securitron"
	icon_base_prefix = "securitron"
	eye_prefix = "securitron"
	required_permit = FALLOUT_PERMISSION

/datum/robot_skin/eve
	name = "Eve"
	icon_base_prefix = "eve"
	eye_prefix = "eve"
	required_permit = WALLE_PERMISSION

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

/datum/robot_skin/paladin/jan
	icon_base_prefix = "paladin-Janitor"
	eye_prefix = "paladin-Janitor"

/datum/robot_skin/robot_drone/jan
	icon_base_prefix = "robot_drone-Janitor"

/datum/robot_skin/protectron/jan
	icon_base_prefix = "protectron-Janitor"

/datum/robot_skin/burger/jan
	icon_base_prefix = "burger-Janitor"

/datum/robot_skin/raptor/jan
	icon_base_prefix = "raptor-Janitor"

/datum/robot_skin/doll/jan
	icon_base_prefix = "doll-Janitor"

/datum/robot_skin/buddy/jan
	icon_base_prefix = "buddy-Janitor"
	eye_prefix = "buddy-Janitor"

/datum/robot_skin/mine/jan
	icon_base_prefix = "mine_jani"
	eye_prefix = "mine_jani"

/datum/robot_skin/eyebot/jan
	icon_base_prefix = "eyebotjani"
	eye_prefix = "eyebotjani"

/datum/robot_skin/seek/jan
	icon_base_prefix = "sleekjanitor"
	eye_prefix = "sleekjanitor"

/datum/robot_skin/noble_h/jan
	icon_base_prefix = "Noble-JAN-H"

/datum/robot_skin/mech/jan
	icon_base_prefix = "flynn"
	eye_prefix = "flynn"

/datum/robot_skin/heavy/jan
	icon_base_prefix = "heavyres"
	eye_prefix = "heavyres"

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
	eye_prefix = "mekaserve"
	panelprefix = "ov-serve"

/datum/robot_skin/tall/fmeka/srv
	icon_base_prefix = "fmekaserv"
	eye_prefix = "fmekaserv"
	panelprefix = "ov-serve"

/datum/robot_skin/tall/mmeka/srv
	icon_base_prefix = "mmekaserv"
	eye_prefix = "mmekaserv"
	panelprefix = "ov-serve"

/datum/robot_skin/paladin/srv
	icon_base_prefix = "paladin-Service"
	eye_prefix = "paladin-Service"

/datum/robot_skin/robot_drone/srv
	icon_base_prefix = "robot_drone-Service"

/datum/robot_skin/protectron/srv
	icon_base_prefix = "protectron-Service"

/datum/robot_skin/burger/srv
	icon_base_prefix = "burger-Service"

/datum/robot_skin/raptor/srv
	icon_base_prefix = "raptor-Service"

/datum/robot_skin/doll/srv
	icon_base_prefix = "doll-Service"

/datum/robot_skin/buddy/srv
	icon_base_prefix = "buddy-Service"
	eye_prefix = "buddy-Service"

/datum/robot_skin/mine/srv
	icon_base_prefix = "mine_green"
	eye_prefix = "mine_green"

/datum/robot_skin/seek/srv
	icon_base_prefix = "sleekservice"
	eye_prefix = "sleekservice"

/datum/robot_skin/mech/srv
	icon_base_prefix = "lloyd"
	eye_prefix = "lloyd"

/datum/robot_skin/heavy/srv
	icon_base_prefix = "heavyserv"
	eye_prefix = "heavyserv"

/datum/robot_skin/handy_serv
	name = "Mr Handy"
	icon_base_prefix = "handy-service"
	eye_prefix = "handy-service"
	required_permit = FALLOUT_PERMISSION

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

/datum/robot_skin/paladin/mnr
	icon_base_prefix = "paladin-Miner"
	eye_prefix = "paladin-Miner"

/datum/robot_skin/robot_drone/mnr
	icon_base_prefix = "robot_drone-Miner"

/datum/robot_skin/protectron/mnr
	icon_base_prefix = "protectron-Miner"

/datum/robot_skin/burger/mnr
	icon_base_prefix = "burger-Miner"

/datum/robot_skin/raptor/mnr
	icon_base_prefix = "raptor-Miner"

/datum/robot_skin/doll/mnr
	icon_base_prefix = "doll-Miner"

/datum/robot_skin/buddy/mnr
	icon_base_prefix = "buddy-Miner"
	eye_prefix = "buddy-Miner"

/datum/robot_skin/mine/mnr
	icon_base_prefix = "mine_miner"
	eye_prefix = "mine_miner"

/datum/robot_skin/seek/mnr
	icon_base_prefix = "sleekminer"
	eye_prefix = "sleekminer"

/datum/robot_skin/noble_h/mnr
	icon_base_prefix = "Noble-SUP-H"

/datum/robot_skin/mech/mnr
	icon_base_prefix = "ishimura"
	eye_prefix = "ishimura"

/datum/robot_skin/heavy/mnr
	icon_base_prefix = "heavymin"
	eye_prefix = "heavymin"

/datum/robot_skin/spider/mnr
	icon_base_prefix = "spidermin"
	eye_prefix = "spidermin"

/datum/robot_skin/walle
	name = "Wall-e"
	icon_base_prefix = "wall-e"
	eye_prefix = "wall-e"
	required_permit = WALLE_PERMISSION

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

/datum/robot_skin/heavy/syndi
	icon_base_prefix = "syndieheavy"
	eye_prefix = "syndieheavy"

/datum/robot_skin/spider/syndi
	icon_base_prefix = "spidersyndi"
	eye_prefix = "spidersyndi"

/datum/robot_skin/droidcombat
	name = "Destroyer"
	icon_base_prefix = "droidcombat"
	eye_prefix = "droidcombat"

/datum/robot_skin/ertgamma
	name = "ERT-GAMMA"
	icon_base_prefix = "ertgamma"
	eye_prefix = "ertgamma"

/datum/robot_skin/paladin/combat
	icon_base_prefix = "paladin-Combat"
	eye_prefix = "paladin-Combat"

/datum/robot_skin/protectron/combat
	icon_base_prefix = "protectron-Combat"

/datum/robot_skin/coffin/combat
	icon_base_prefix = "coffin-Combat"

/datum/robot_skin/burger/combat
	icon_base_prefix = "burger-Combat"

/datum/robot_skin/raptor/combat
	icon_base_prefix = "burger-Combat"

/datum/robot_skin/buddy/combat
	icon_base_prefix = "buddy-Combat"
	eye_prefix = "buddy-Combat"

/datum/robot_skin/seek/combat
	icon_base_prefix = "sleekcombat"
	eye_prefix = "sleekcombat"

/datum/robot_skin/mech/combat
	icon_base_prefix = "chesty"
	eye_prefix = "chesty"

/datum/robot_skin/mrgutsy
	name = "Mr Gutsy"
	icon_base_prefix = "mrgutsy"
	eye_prefix = "mrgutsy"
	required_permit = FALLOUT_PERMISSION

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

/datum/robot_skin/heavy/ninja
	icon_base_prefix = "ninjaheavy"
	eye_prefix = "ninjaheavy"

/datum/robot_skin/spider/ninja
	icon_base_prefix = "ninjaspider"
	eye_prefix = "ninjaspider"

/datum/robot_skin/ninja_sec
	name = "Ninja sec"
	icon_base_prefix = "ninja_sec"
	eye_prefix = "ninja_sec"
	required_permit = NINJA_ALT_PERMISSION

/datum/robot_skin/ninja_engi
	name = "Ninja engi"
	icon_base_prefix = "ninja_engi"
	eye_prefix = "ninja_engi"
	required_permit = NINJA_ALT_PERMISSION

/datum/robot_skin/ninja_medical
	name = "Ninja medical"
	icon_base_prefix = "ninja_medical"
	eye_prefix = "ninja_medical"
	required_permit = NINJA_ALT_PERMISSION
