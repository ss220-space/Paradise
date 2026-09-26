/area/coldcolony
	name = "coldcolony"
	holomap_should_draw = FALSE
	has_gravity = TRUE
	ignore_gravgen = TRUE

/area/coldcolony/ruin
	name = "ruin"

/area/coldcolony/ruin/sm_division
	name = "Abandoned SM Research Division"
	icon_state = "research"

/area/coldcolony/ruin/sm_maintenance
	name = "Abandoned SM Maintenance"
	icon_state = "asmaint"

/area/coldcolony/ruin/sm_lab
	name = "Abandoned SM Laboratory"
	icon_state = "toxlab"

/area/coldcolony/ruin/sm_chamber
	name = "Abandoned SM Chamber"
	icon_state = "toxtest"

/area/coldcolony/ruin/abandoned_banya
	name = "Abandoned Banya"
	icon_state = "barstation"

/area/coldcolony/ruin/syndie_outpost
	name = "Syndicate Recruiter Outpost"
	icon_state = "red"

/area/coldcolony/ruin/abandoned_house
	name = "House"
	icon_state = "red"

/area/coldcolony/ruin/abandoned_garage
	name = "Mech Garage"
	icon_state = "mining"

// MARK: Malta
/area/coldcolony/malta
	name = "malta"
	holomap_should_draw = TRUE
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/coldcolony/malta/outer
	name = "outer"

/area/coldcolony/malta/outer/roadblock
	name = "Roadblock"
	icon_state = "entry"
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

// MARK: Malta Cargo
/area/coldcolony/malta/quartermaster
	name = "Quartermasters"
	icon_state = "quart"
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/coldcolony/malta/quartermaster/miningbar
	name = "Miner's bar"
	icon_state = "mining_living"

/area/coldcolony/malta/quartermaster/ore_production
	name = "Mining Production"
	icon_state = "mining_production"

/area/coldcolony/malta/quartermaster/miningeva
	name = "Mining EVA"
	icon_state = "mining_eva"

/area/coldcolony/malta/quartermaster/mining_post1
	name = "Mining"
	icon_state = "mining"

/area/coldcolony/malta/quartermaster/sorting
	name = "Delivery Office"
	icon_state = "quartstorage"

/area/coldcolony/malta/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/coldcolony/malta/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/coldcolony/malta/quartermaster/qm
	name = "Quartermaster's Office"

// MARK: Malta Other
/area/coldcolony/malta/chapel
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	is_haunted = TRUE
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/coldcolony/malta/chapel/main
	name = "Chapel"

/area/coldcolony/malta/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"

/area/coldcolony/malta/escape_toilet
	name = "Arrivals Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/coldcolony/malta/civilian
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/coldcolony/malta/civilian/vacantoffice
	name = "Vacant Office"
	icon_state = "green"

/area/coldcolony/malta/civilian/trading
	name = "Abandoned Tradiders Room"
	icon_state = "blue"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/coldcolony/malta/civilian/mrchangs
	name = "Mr Chang's"
	icon_state = "Theatre"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

// MARK: Malta Residental
/area/coldcolony/malta/resid_serv
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/coldcolony/malta/resid_serv/crew_quarters
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	icon_state = "Sleep"
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/coldcolony/malta/resid_serv/crew_quarters/cabin1
	name = "First Cabin"

/area/coldcolony/malta/resid_serv/crew_quarters/cabin2
	name = "Second Cabin"

/area/coldcolony/malta/resid_serv/crew_quarters/sleep
	name = "Dormitories"
	valid_territory = FALSE

/area/coldcolony/malta/resid_serv/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/coldcolony/malta/resid_serv/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"

/area/coldcolony/malta/resid_serv/crew_quarters/locker_toilet
	name = "Locker Toilets"
	icon_state = "toilet"

/area/coldcolony/malta/resid_serv/crew_quarters/barber
	name = "Barber Shop"
	icon_state = "barber"

/area/coldcolony/malta/resid_serv/crew_quarters/theatre
	name = "Theatre"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/resid_serv/clownoffice
	name = "Clown's Office"
	icon_state = "clown_office"
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL

/area/coldcolony/malta/resid_serv/mimeoffice
	name = "Mime's Office"
	icon_state = "mime_office"

/area/coldcolony/malta/resid_serv/bar
	name = "Bar"
	icon_state = "barstation"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/resid_serv/bar/atrium
	name = "Atrium"
	icon_state = "bar"

/area/coldcolony/malta/resid_serv/janitor
	name = "Custodial Closet"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/resid_serv/library
	name = "Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/coldcolony/malta/resid_serv/library/game_zone
	name = "Library Games Room"

/area/coldcolony/malta/resid_serv/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

/area/coldcolony/malta/resid_serv/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

// MARK: Malta Hallways
/area/coldcolony/malta/hallway
	valid_territory = FALSE
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/coldcolony/malta/hallway/service
	icon_state = "hallP"

/area/coldcolony/malta/hallway/bridge
	name = "Command Entrance"
	icon_state = "hallC"

/area/coldcolony/malta/hallway/cargo_escape
	icon_state = "hallS"

/area/coldcolony/malta/hallway/service/north
	name = "North Service Entrance"

/area/coldcolony/malta/hallway/service/nw
	name = "Abandoned Service Hallway"

/area/coldcolony/malta/hallway/service/central
	name = "Central Service Hallway"

/area/coldcolony/malta/hallway/service/east
	name = "East Service Hallway"

/area/coldcolony/malta/hallway/service/south
	name = "South Service Entrance"

/area/coldcolony/malta/hallway/cargo_escape/north
	name = "North Escape Hallway"

/area/coldcolony/malta/hallway/cargo_escape/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE

/area/coldcolony/malta/hallway/cargo_escape/entrance
	name = "Escape Entrance"

/area/coldcolony/malta/hallway/cargo_escape/port
	icon_state = "entry"

/area/coldcolony/malta/hallway/cargo_escape/port/west
	name = "Port Commercial West Hallway"

/area/coldcolony/malta/hallway/cargo_escape/port/central
	name = "Port Central Hallway"

/area/coldcolony/malta/hallway/cargo_escape/port/east
	name = "Port East Hallway"

// MARK: Malta Maintenance
/area/coldcolony/malta/maintenance
	ambience_index = AMBIENCE_MAINT
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/coldcolony/malta/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"

/area/coldcolony/malta/maintenance/kitchen
	name = "Old Restaurant"
	icon_state = "kitchen"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/coldcolony/malta/maintenance/garden
	name = "Old Garden"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/coldcolony/malta/maintenance/servicegen
	name = "Generator Service"
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/dormitory
	name = "Dormitory Maintenance"
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/bar
	name = "Bar Maintenance"
	icon_state = "fmaint"

/area/coldcolony/malta/maintenance/casino
	name = "Abandoned Casino"
	icon_state = "yellow"

/area/coldcolony/malta/maintenance/brig
	name = "Brig Maintenance"
	icon_state = "pmaint"

/area/coldcolony/malta/maintenance/medbay
	name = "Medbay Maintenance"
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/bridge
	name = "Bridge Maintenance"
	icon_state = "central"

/area/coldcolony/malta/maintenance/cargo
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/coldcolony/malta/maintenance/research
	name = "Research Maintenance"
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/science
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/coldcolony/malta/maintenance/engineering
	name = "Engineering Maintenance"
	icon_state = "green"

/area/coldcolony/malta/maintenance/perma
	name = "Prison Maintenance"
	icon_state = "green"

// MARK: Malta Medical
/area/coldcolony/malta/medical
	ambience_index = AMBIENCE_MEDICAL
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/coldcolony/malta/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE

/area/coldcolony/malta/medical/sleeper
	name = "Medical Treatment Center"
	icon_state = "exam_room"

/area/coldcolony/malta/medical/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "CMO"

/area/coldcolony/malta/medical/cmostore
	name = "Medical Secondary Storage"
	icon_state = "medbaysecstorage"

/area/coldcolony/malta/medical/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/coldcolony/malta/medical/paramedic
	name = "Paramedic"
	icon_state = "medbay"

/area/coldcolony/malta/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/coldcolony/malta/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/coldcolony/malta/medical/surgery/west
	name = "Surgery 1"
	icon_state = "surgery1"

/area/coldcolony/malta/medical/surgery/east
	name = "Surgery 2"
	icon_state = "surgery2"

/area/coldcolony/malta/medical/biostorage
	name = "Medical Storage"
	icon_state = "medbaysecstorage"

/area/coldcolony/malta/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/coldcolony/malta/medical/virology
	name = "Virology Laboratory"
	icon_state = "virology"
	ambience_index = AMBIENCE_VIROLOGY

// MARK: Malta Security
/area/coldcolony/malta/security
	ambience_index = AMBIENCE_DANGER
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/coldcolony/malta/security/lobby
	name = "Security Lobby"
	icon_state = "securitylobby"

/area/coldcolony/malta/security/magistrateoffice
	name = "Magistrate's Office"
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/coldcolony/malta/security/reception
	name = "Brig Reception"
	icon_state = "brig"

/area/coldcolony/malta/security/brig
	name = "Brig"
	icon_state = "brig"

/area/coldcolony/malta/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = FALSE
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	..()

/area/coldcolony/malta/security/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brigcella"

/area/coldcolony/malta/security/customs
	name = "Customs"
	icon_state = "checkpoint1"

/area/coldcolony/malta/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
	)

/area/coldcolony/malta/security/brigstaff
	name = "Brig Staff Room"
	icon_state = "brig"

/area/coldcolony/malta/security/medbay
	name = "Security Medbay"
	icon_state = "security_medbay"

/area/coldcolony/malta/security/evidence
	name = "Evidence Room"
	icon_state = "evidence"

/area/coldcolony/malta/security/hos
	name = "Head of Security's Office"
	icon_state = "sec_hos"

/area/coldcolony/malta/security/main
	name = "Security Office"
	icon_state = "securityoffice"

/area/coldcolony/malta/security/securehallway
	name = "Brig Secure Hallway"
	icon_state = "securehall"

/area/coldcolony/malta/security/warden
	name = "Warden's Office"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/coldcolony/malta/security/securearmory
	name = "Secure Armory"
	icon_state = "secarmory"

/area/coldcolony/malta/security/execution
	name = "Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/permahallway
	name = "Permabrig Hallway"
	icon_state = "sec_prison_perma"

/area/coldcolony/malta/security/permabrig
	name = "Prison Wing"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/coldcolony/malta/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

// MARK: Malta Bridge
/area/coldcolony/malta/bridge
	name = "Bridge"
	icon_state = "bridge"
	ambientsounds = list(
		'sound/ambience/misc/signal.ogg',
	)
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/coldcolony/malta/bridge/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/coldcolony/malta/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/coldcolony/malta/bridge/hop
	name = "Head of Personnel's Quarters"
	icon_state = "head_quarters"

/area/coldcolony/malta/bridge/ntrep
	name = "Nanotrasen Representative's Office"
	icon_state = "ntrep"

/area/coldcolony/malta/bridge/vip
	name = "VIP Area"
	icon_state = "meeting"

/area/coldcolony/malta/bridge/blueshield
	name = "Blueshield's Office"
	icon_state = "blueshield"

/area/coldcolony/malta/bridge/captain
	name = "Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/coldcolony/malta/bridge/captain/bedroom
	name = "Captain's Bedroom"

/area/coldcolony/malta/bridge/tcomm
	ambientsounds = list(
		'sound/ambience/engineering/ambisin2.ogg',
		'sound/ambience/misc/signal.ogg',
		'sound/ambience/misc/signal.ogg',
		'sound/ambience/general/ambigen9.ogg',
		'sound/ambience/engineering/ambitech.ogg',
		'sound/ambience/engineering/ambitech2.ogg',
		'sound/ambience/engineering/ambitech3.ogg',
		'sound/ambience/misc/ambimystery.ogg',
	)
	name = "Telecoms Central Compartment"
	icon_state = "tcomms"

/area/coldcolony/malta/bridge/checkpoint
	name = "Command Checkpoint"

// MARK: Malta AI
/area/coldcolony/malta/turret_protected
	ambientsounds = list(
		'sound/ambience/misc/ambimalf.ogg',
		'sound/ambience/engineering/ambitech.ogg',
		'sound/ambience/engineering/ambitech2.ogg',
		'sound/ambience/engineering/ambiatmos.ogg',
		'sound/ambience/engineering/ambiatmos2.ogg',
	)
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/coldcolony/malta/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/coldcolony/malta/turret_protected/aisat
	name = "AI Hallway"
	icon_state = "ai"

// MARK: Malta Research
/area/coldcolony/malta/research
	name = "Research Division"
	icon_state = "research"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/coldcolony/malta/research/lab
	name = "Research and Development"
	icon_state = "toxlab"

/area/coldcolony/malta/research/hor
	name = "Research Director's Office"
	icon_state = "head_quarters"

/area/coldcolony/malta/research/chargebay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/coldcolony/malta/research/hallway
	name = "RnD Hallway"

/area/coldcolony/malta/research/robotics
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/coldcolony/malta/research/server
	name = "Server Room"
	icon_state = "server"

/area/coldcolony/malta/research/shallway
	name = "RnD South Hallway"

/area/coldcolony/malta/research/explab
	name = "Experimentation Lab"
	icon_state = "toxmisc"

/area/coldcolony/malta/research/test_chamber
	name = "Research Testing Chamber"
	icon_state = "toxtest"

/area/coldcolony/malta/research/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"

/area/coldcolony/malta/research/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxmix"
	xenobiology_compatible = TRUE

// MARK: Malta Engineering
/area/coldcolony/malta/engineering
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/coldcolony/malta/engineering/break_room
	name = "Engineering Foyer"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/coldcolony/malta/engineering/control
	name = "Atmospherics Control Room"
	icon_state = "atmos"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/coldcolony/malta/engineering/monitor
	name = "Engineering Monitoring Room"
	icon_state = "engine_control"

/area/coldcolony/malta/engineering/engine
	name = "Engineering SMES"
	icon_state = "engine_smes"

/area/coldcolony/malta/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/coldcolony/malta/engineering/storage
	name = "Secure Storage"
	icon_state = "storage"
	ambience_index = AMBIENCE_DANGER

/area/coldcolony/malta/engineering/chief
	name = "Chief Engineer's Office"
	icon_state = "head_quarters"

/area/coldcolony/malta/engineering/teg
	name = "Engineering Thermo Generator"
	icon_state = "engine"

// MARK: Malta event map
/area/ruin/unpowered/coldcolony_outside
	name = "Surface"
	ignore_gravgen = TRUE
	outdoors = TRUE
