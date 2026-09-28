/area/planetoid
	name = "planetoid Surface"
	icon_state = "planet"
	outdoors = TRUE
	holomap_should_draw = FALSE
	has_gravity = STANDARD_GRAVITY
	sound_environment = SOUND_ENVIRONMENT_MOUNTAINS
	ambience_index = AMBIENCE_PLANETOID
	ambient_buzz = null

/area/planetoid/caves
	name = "planetoid caves"
	icon_state = "cave"
	outdoors = FALSE
	sound_environment = SOUND_ENVIRONMENT_CAVE
	ambience_index = AMBIENCE_REEBE

/area/planetoid/lazarus
	name = "lazarus"
	holomap_should_draw = TRUE
	sound_environment = SOUND_AREA_STANDARD_STATION
	outdoors = FALSE

// MARK: Command Nexus
/area/planetoid/lazarus/nexus
	name = "Command Nexus"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND
	sound_environment = SOUND_ENVIRONMENT_HALLWAY

/area/planetoid/lazarus/nexus/maintenance
	name = "Command Nexus maintenance"
	icon_state = "central"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

// MARK: Escape
/area/planetoid/escape
	name = "Escape Shuttle"
	icon_state = "escape"
	holomap_should_draw = TRUE
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE
	outdoors = FALSE

/area/planetoid/escape_shuttle
	name = "LZ Escape Shuttle"

/area/planetoid/escape/command
	name = "LZ Command Checkpoint"

/area/planetoid/escape/security
	name = "LZ Escape Security Checkpoint"

// MARK: Satellite
/area/planetoid/lazarus/ai/satellite/hallway
	name = "AI Satellite Hallway"
	icon_state = "yellow"

/area/planetoid/lazarus/ai/satellite/teleporter
	name = "AI Satellite Teleporter"
	icon_state = "yellow"

/area/planetoid/lazarus/ai/satellite/exterior
	name = "AI Satellite Exterior Hallway"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/planetoid/lazarus/ai/satellite/maintenance
	name = "AI Satellite Service"
	icon_state = "storage"

/area/planetoid/lazarus/ai/satellite/atmos
	name = "AI Satellite Atmospherics"
	icon_state = "storage"

/area/planetoid/lazarus/ai
	ambientsounds = list(
		'sound/ambience/engineering/ambitech.ogg',
		'sound/ambience/engineering/ambitech2.ogg',
		'sound/ambience/engineering/ambiatmos.ogg',
		'sound/ambience/engineering/ambiatmos2.ogg',
	)
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

// MARK: Turret
/area/planetoid/lazarus/ai/upload/chamber
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/planetoid/lazarus/ai/satellite/chamber
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/planetoid/lazarus/ai/satellite
	name = "AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/planetoid/lazarus/ai/satellite/interior
	name = "AI Satellite Antechamber"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/planetoid/lazarus/ai/satellite/interior/secondary
	name = "AI Satellite Secondary Antechamber"

// MARK: Cargo
/area/planetoid/lazarus/cargo
	name = "Quartermasters"
	icon_state = "quart"
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/planetoid/lazarus/cargo/sorting
	name = "Delivery Office"
	icon_state = "quartstorage"

/area/planetoid/lazarus/cargo/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/planetoid/lazarus/cargo/lobby
	name = "Cargo Lobby"
	icon_state = "quartoffice"

/area/planetoid/lazarus/cargo/delivery
	name = "Cargo Delivery"
	icon_state = "quartoffice"

/area/planetoid/lazarus/cargo/storage
	name = "Cargo Bay"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/planetoid/lazarus/cargo/restroom
	name = "Cargo Restroom"
	icon_state = "quartoffice"

/area/planetoid/lazarus/cargo/dock
	name = "Cargo Dock"
	icon_state = "quartstorage"

/area/planetoid/lazarus/command/office/qm
	name = "Quartermaster's Office"

/area/planetoid/lazarus/cargo/miningdock
	name = "Mining Dock"
	icon_state = "mining"

/area/planetoid/lazarus/cargo/storage/mining
	name = "Mining Storage"
	icon_state = "green"

// MARK: Command
/area/planetoid/lazarus/command/gateway
	name = "Gateway"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/command/teleporter
	name = "Teleporter"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/command/teleporter/abandoned
	name = "Abandoned Teleporter"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/planetoid/lazarus/legal/office/magistrate
	name = "Magistrate's Office"
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/planetoid/lazarus/command/office/ntrep
	name = "Nanotrasen Representative's Office"
	icon_state = "ntrep"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/command/office/blueshield
	name = "Blueshield's Office"
	icon_state = "blueshield"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/command/server
	name = "Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/planetoid/lazarus/command/bridge
	name = "Bridge"
	icon_state = "bridge"
	ambientsounds = list(
		'sound/ambience/misc/signal.ogg',
	)
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/command/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/planetoid/lazarus/command/vip
	name = "VIP Area"
	icon_state = "meeting"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/planetoid/lazarus/command/office/captain
	name = "Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/command/office/captain/bedroom
	name = "Captain's Bedroom"

/area/planetoid/lazarus/legal/courtroom
	name = "Courtroom"
	icon_state = "courtroom"
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/planetoid/lazarus/command/office/hop
	name = "Head of Personnel's Office"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/command/office/rd
	name = "Research Director's Office"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/planetoid/lazarus/command/office/hos
	name = "Head of Security's Office"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/planetoid/lazarus/command/office/ce
	name = "Chief Engineer's Office"
	icon_state = "head_quarters"
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/planetoid/lazarus/command/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

// MARK: Common
/area/planetoid/lazarus/commons/vacant_office
	name = "Vacant Office"
	icon_state = "green"

/area/planetoid/lazarus/commons/pet_store
	name = "Pet Store"
	icon_state = "pet_store"

/area/planetoid/lazarus/commons
	name = "Dormitories"
	icon_state = "Sleep"
	holomap_color = HOLOMAP_AREACOLOR_DORMS
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/planetoid/lazarus/commons/serviceyard
	name = "Service Yard"

/area/planetoid/lazarus/commons/cabin/one
	name = "First Cabin"

/area/planetoid/lazarus/commons/cabin/two
	name = "Second Cabin"

/area/planetoid/lazarus/commons/cabin/three
	name = "Third Cabin"

/area/planetoid/lazarus/commons/cabin/four
	name = "Fourth Cabin"

/area/planetoid/lazarus/commons/toilet/one
	name = "Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/planetoid/lazarus/commons/toilet/two
	name = "West Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/planetoid/lazarus/commons/toilet/three
	name = "Theatre Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/planetoid/lazarus/commons/toilet/four
	name = "Arrivals Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/planetoid/lazarus/commons/mrchangs
	name = "Mr Chang's"
	icon_state = "Theatre"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/planetoid/lazarus/commons/fishing_room
	name = "Fishing room"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/planetoid/lazarus/commons/arcade
	name = "Arcade"
	icon_state = "arcade"

/area/planetoid/lazarus/commons/sleep
	valid_territory = FALSE

/area/planetoid/lazarus/commons/sleep/secondary
	name = "Secondary Dormitories"

/area/planetoid/lazarus/commons/locker
	name = "Locker Room"
	icon_state = "locker"

/area/planetoid/lazarus/commons/toilet/locker_toilet
	name = "Locker Toilets"
	icon_state = "toilet"

/area/planetoid/lazarus/commons/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/planetoid/lazarus/commons/dorms
	name = "Dorms"
	icon_state = "dorms"

/area/planetoid/lazarus/commons/trading
	name = "Abandoned Tradiders Room"
	icon_state = "blue"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/planetoid/lazarus/commons/storage/office
	name = "Office Supplies"
	icon_state = "office_supplies"
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/planetoid/lazarus/commons/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/planetoid/lazarus/commons/storage
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

// MARK: Engineering
/area/planetoid/lazarus/engineering
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/planetoid/lazarus/engineering/engine
	name = "Engineering"
	icon_state = "engine_smes"

/area/planetoid/lazarus/engineering/engine/reactor
	name = "Fission Reactor"
	icon_state = "engine_nuke"

/area/planetoid/lazarus/engineering/monitor
	name = "Engineering Monitoring Room"
	icon_state = "engine_control"

/area/planetoid/lazarus/engineering/break_room
	name = "Engineering Foyer"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/planetoid/lazarus/engineering/transit_tube
	name = "AI Sattelit Access Point"
	icon_state = "engine"

/area/planetoid/lazarus/engineering/storage
	name = "Engineering Hardsuit Storage"
	icon_state = "storage"

/area/planetoid/lazarus/engineering/supermatter/room
	name = "Engineering Control Room"
	icon_state = "engine_control"

/area/planetoid/lazarus/engineering/gravity_generator
	name = "Gravity Generator"
	icon_state = "engine"

/area/planetoid/lazarus/engineering/mechanic_workshop
	name = "Mechanic Workshop"
	icon_state = "engine"
	holomap_color = HOLOMAP_AREACOLOR_HANGAR

/area/planetoid/lazarus/engineering/mechanic_workshop/expedition
	name = "Hangar Expedition"

/area/planetoid/lazarus/engineering/mechanic_workshop/hangar
	name = "Hangаr Bay"
	sound_environment = SOUND_ENVIRONMENT_MOUNTAINS

/area/planetoid/lazarus/engineering/supermatter/engine
	name = "Supermatter Engine"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/planetoid/lazarus/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/planetoid/lazarus/engineering/atmos/control
	name = "Atmospherics Control Room"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/planetoid/lazarus/engineering/atmos/distribution
	name = "Atmospherics Distribution Loop"

/area/planetoid/lazarus/engineering/atmos/mixing_atmos
	name = "Atmospherics Mixing Room"
	icon_state = "atmos_mixing"

/area/planetoid/lazarus/engineering/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/planetoid/lazarus/engineering/storage/secure
	name = "Secure Storage"
	ambience_index = AMBIENCE_DANGER

/area/planetoid/lazarus/engineering/hallway
	name = "Engineering Hallway"

/area/planetoid/lazarus/engineering/smes
	name = "Engineering SMES"

/area/planetoid/lazarus/engineering/teg
	name = "Engineering TEG"

// MARK: Hallway
/area/planetoid/lazarus/hallway
	valid_territory = FALSE //too many areas with similar/same names, also not very interesting summon spots
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/planetoid/lazarus/hallway/primary/fore
	name = "North Primary Hallway"
	icon_state = "hallF"

/area/planetoid/lazarus/hallway/primary/fore/west
	name = "North-West Hallway"

/area/planetoid/lazarus/hallway/primary/fore/east
	name = "North-East Hallway"

/area/planetoid/lazarus/hallway/primary/fore/north
	name = "North-North Hallway"

/area/planetoid/lazarus/hallway/primary/fore/south
	name = "North-South Hallway"

/area/planetoid/lazarus/hallway/primary/starboard
	name = "East Primary Hallway"
	icon_state = "hallS"

/area/planetoid/lazarus/hallway/primary/starboard/west
	name = "East-West Hallway"

/area/planetoid/lazarus/hallway/primary/starboard/east
	name = "East-East Hallway"

/area/planetoid/lazarus/hallway/primary/starboard/north
	name = "East-North Hallway"

/area/planetoid/lazarus/hallway/primary/starboard/south
	name = "East-South Hallway"

/area/planetoid/lazarus/hallway/primary/aft
	name = "South Primary Hallway"
	icon_state = "hallA"

/area/planetoid/lazarus/hallway/primary/aft/west
	name = "South-West Hallway"

/area/planetoid/lazarus/hallway/primary/aft/east
	name = "South-East Hallway"

/area/planetoid/lazarus/hallway/primary/aft/north
	name = "South-North Hallway"

/area/planetoid/lazarus/hallway/primary/aft/south
	name = "South-South Hallway"

/area/planetoid/lazarus/hallway/primary/port
	name = "West Primary Hallway"
	icon_state = "hallP"

/area/planetoid/lazarus/hallway/primary/port/west
	name = "West-West Hallway"

/area/planetoid/lazarus/hallway/primary/port/east
	name = "West-East Hallway"

/area/planetoid/lazarus/hallway/primary/port/north
	name = "West-North Hallway"

/area/planetoid/lazarus/hallway/primary/port/south
	name = "West-South Hallway"

/area/planetoid/lazarus/hallway/primary/central //pay attention to THIS SHIT
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/planetoid/lazarus/hallway/primary/central/north

/area/planetoid/lazarus/hallway/primary/central/south

/area/planetoid/lazarus/hallway/primary/central/west

/area/planetoid/lazarus/hallway/primary/central/east

/area/planetoid/lazarus/hallway/primary/central/nw

/area/planetoid/lazarus/hallway/primary/central/ne

/area/planetoid/lazarus/hallway/primary/central/sw

/area/planetoid/lazarus/hallway/primary/central/se

/area/planetoid/lazarus/hallway/primary/command
	name = "Command Primary Hallway"
	icon_state = "hallC"

/area/planetoid/lazarus/hallway/primary/command/north

/area/planetoid/lazarus/hallway/primary/command/south

/area/planetoid/lazarus/hallway/primary/command/west

/area/planetoid/lazarus/hallway/primary/command/east

/area/planetoid/lazarus/hallway/primary/central/second
	name = "Second Floor Central Primary Hallway"

/area/planetoid/lazarus/hallway/primary/central/second/north

/area/planetoid/lazarus/hallway/primary/central/second/south

/area/planetoid/lazarus/hallway/primary/central/second/west

/area/planetoid/lazarus/hallway/primary/central/second/east

/area/planetoid/lazarus/hallway/spacebridge/somsec
	name = "Comand-Security Bridge"

/area/planetoid/lazarus/hallway/spacebridge/comcar
	name = "Command-Cargo Bridge"

/area/planetoid/lazarus/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE

/area/planetoid/lazarus/hallway/secondary/exit/escape_pod
	name = "Escape Shuttle Hallway Pod Bay"
	holomap_color = HOLOMAP_AREACOLOR_HANGAR

/area/planetoid/lazarus/hallway/secondary/exit/maint
	name = "Abandoned Escape Shuttle Hallway"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/planetoid/lazarus/hallway/secondary/garden
	name = "Garden"
	icon_state = "hydro"

/area/planetoid/lazarus/hallway/secondary/entry
	name = "Arrivals Hallway"
	icon_state = "entry"
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/planetoid/lazarus/hallway/secondary/entry/eastarrival
	name = "Arrival Shuttle East Hallway"

/area/planetoid/lazarus/hallway/secondary/entry/westarrival
	name = "Arrival Shuttle West Hallway"

/area/planetoid/lazarus/hallway/secondary/entry/additional
	name = "Arrival Additional West Hallway"

/area/planetoid/lazarus/hallway/secondary/entry/commercial
	name = "Arrival Commercial West Hallway"

/area/planetoid/lazarus/hallway/secondary/entry/north

/area/planetoid/lazarus/hallway/secondary/entry/south

/area/planetoid/lazarus/hallway/secondary/entry/lounge
	name = "Arrivals Lounge"
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

// MARK: Meintenance
/area/planetoid/lazarus/maintenance
	name = "Generic Maintenance"
	ambience_index = AMBIENCE_MAINT
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE
	forced_ambience = TRUE
	ambient_buzz = 'sound/ambience/maintenance/source_corridor2.ogg'
	ambient_buzz_vol = 20
	///A list of rare sound effects to fuck with players. No, it does not contain actual minecraft sounds anymore.
	var/static/list/minecraft_cave_noises = list(
		'sound/machines/airlock_open.ogg',
		'sound/effects/snap.ogg',
		'sound/effects/clownstep1.ogg',
		'sound/effects/clownstep2.ogg',
		'sound/items/welder.ogg',
		'sound/items/welder2.ogg',
		'sound/items/crowbar.ogg',
		'sound/items/deconstruct.ogg',
		'sound/ambience/misc/source_holehit3.ogg',
		'sound/ambience/misc/cavesound3.ogg',
	)

/area/planetoid/lazarus/maintenance/play_ambience(mob/target, sound/override_sound, volume)
	if(!target.has_light_nearby() && prob(0.5))
		return ..(target, pick(minecraft_cave_noises))
	return ..()

/area/planetoid/lazarus/maintenance/ai
	name = "AI Maintenance"
	icon_state = "green"

/area/planetoid/lazarus/maintenance/fore //should be refactored
	name = "North Maintenance"
	icon_state = "fmaint"

/area/planetoid/lazarus/maintenance/fore2
	name = "North Secondary Maintenance"
	icon_state = "fmaint"

/area/planetoid/lazarus/maintenance/fpmaint
	name = "North-West Maintenance"
	icon_state = "fpmaint"

/area/planetoid/lazarus/maintenance/fsmaint
	name = "Dormitory Maintenance"
	icon_state = "fsmaint"

/area/planetoid/lazarus/maintenance/fsmaint2
	name = "Bar Maintenance"
	icon_state = "fsmaint"

/area/planetoid/lazarus/maintenance/fsmaint3
	name = "Cargo East Maintenance"
	icon_state = "fsmaint"

/area/planetoid/lazarus/maintenance/tourist
	name = "Tourist Area Maintenance"
	icon_state = "fsmaint"

/area/planetoid/lazarus/maintenance/asmaint
	name = "Medbay Maintenance"
	icon_state = "asmaint"

/area/planetoid/lazarus/maintenance/asmaint2
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/planetoid/lazarus/maintenance/asmaint3
	name = "Research Maintenance"
	icon_state = "asmaint"

/area/planetoid/lazarus/maintenance/asmaint4
	name = "Virology Maintenance"
	icon_state = "asmaint"

/area/planetoid/lazarus/maintenance/asmaint6
	name = "RnD Restroom Maintenance"
	icon_state = "asmaint"

/area/planetoid/lazarus/maintenance/apmaint
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/planetoid/lazarus/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "central"

/area/planetoid/lazarus/maintenance/starboard
	name = "East Maintenance"
	icon_state = "smaint"

/area/planetoid/lazarus/maintenance/port
	name = "West Maintenance"
	icon_state = "pmaint"

/area/planetoid/lazarus/maintenance/brig
	name = "Brig Maintenance"
	icon_state = "pmaint"

/area/planetoid/lazarus/maintenance/perma
	name = "Prison Maintenance"
	icon_state = "green"

/area/planetoid/lazarus/maintenance/atmospherics
	name = "Atmospherics Maintenance"
	icon_state = "green"

/area/planetoid/lazarus/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"

/area/planetoid/lazarus/maintenance/turbine
	name = "Turbine"
	icon_state = "disposal"

/area/planetoid/lazarus/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/planetoid/lazarus/maintenance/genetics
	name = "Genetics Maintenance"
	icon_state = "asmaint"

/area/planetoid/lazarus/maintenance/electrical
	name = "Electrical Maintenance"
	icon_state = "elec"

/area/planetoid/lazarus/maintenance/engineering
	name = "Engineering Maintenance"
	icon_state = "green"

/area/planetoid/lazarus/maintenance/bar
	name = "Maintenance Bar"
	icon_state = "oldbar"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/planetoid/lazarus/maintenance/electrical_shop
	name = "Electronics Den"
	icon_state = "elec"

/area/planetoid/lazarus/maintenance/gambling_den
	name = "Abandoned Fight Club"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/casino
	name = "Abandoned Casino"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/consarea
	name = "Alternate Construction Area"
	icon_state = "construction"

/area/planetoid/lazarus/maintenance/consarea_virology
	name = "Virology Maintenance Construction Area"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/detectives_office
	name = "Abandoned Detective's Office"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
	)

/area/planetoid/lazarus/maintenance/library
	name = "Abandoned Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/planetoid/lazarus/maintenance/secpost
	name = "Abandoned Security Post"
	icon_state = "security"

/area/planetoid/lazarus/maintenance/banya
	name = "Abandoned Banya"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/medroom
	name = "Abandoned Medical Emergency Ward"
	icon_state = "medbay3"

/area/planetoid/lazarus/maintenance/chapel
	name = "Abandoned Chapel"
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	is_haunted = TRUE

/area/planetoid/lazarus/maintenance/livingcomplex
	name = "Abandoned Living Complex Lobby"
	icon_state = "quart"

/area/planetoid/lazarus/maintenance/cafeteria
	name = "Abandoned Cafeteria"
	icon_state = "cafeteria"

/area/planetoid/lazarus/maintenance/xenozoo
	name = "Maintenance Xeno Zoo"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/club
	name = "Old Poker Club"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/backstage
	name = "Backstage"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/trading
	name = "Trading area"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/server
	name = "Abandoned Server Room"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/abandonedwarehouse
	name = "Abandoned Warehouse"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/abandonedoffices
	name = "Abandoned Offices"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/abandonedclub
	name = "Abandoned Club"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/abandonedhangar
	name = "Abandoned Hangar"
	icon_state = "yellow"

/area/planetoid/lazarus/maintenance/garden
	name = "Old Garden"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/planetoid/lazarus/maintenance/kitchen
	name = "Old Restaurant"
	icon_state = "kitchen"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/planetoid/lazarus/maintenance/research
	name = "Research Maintenance"

/area/planetoid/lazarus/maintenance/research/electrical
	name = "Research Electrical Maintenance"

/area/planetoid/lazarus/maintenance/research/robotics
	name = "Robotics Maintenance"

/area/planetoid/lazarus/maintenance/research/science
	name = "Science Maintenance"

/area/planetoid/lazarus/maintenance/water_purification
	name = "Water Purification Plant"

// MARK: Medical
/area/planetoid/lazarus/medical
	ambience_index = AMBIENCE_MEDICAL
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/planetoid/lazarus/medical/medbay
	name = "Medbay"
	icon_state = "medbay"

// Medbay is a large area, these additional areas help level out APC load. wtf dude, nobody use THIS MUCH ZONES
/area/planetoid/lazarus/medical/secondary
	name = "Medbay"
	icon_state = "medbay2"

/area/planetoid/lazarus/medical/storage/bio
	name = "Medical Storage"

/area/planetoid/lazarus/medical/reception
	name = "Medbay Reception"
	icon_state = "medbay"

/area/planetoid/lazarus/medical/psych
	name = "Psych Room"
	icon_state = "medbaypsych"

/area/planetoid/lazarus/medical/break_room
	name = "Med Restroom"
	icon_state = "medbaybreak"

/area/planetoid/lazarus/medical/patients_rooms
	name = "Patient's Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/planetoid/lazarus/medical/ward
	name = "Medbay Patient Ward"
	icon_state = "patientsward"

/area/planetoid/lazarus/command/office/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "CMO"

/area/planetoid/lazarus/medical/storage
	name = "Medical Secondary Storage"
	icon_state = "medbaysecstorage"

/area/planetoid/lazarus/medical/west_hallway
	name = "West Medbay Hallway"

/area/planetoid/lazarus/medical/east_hallway
	name = "East Medbay Hallway"

/area/planetoid/lazarus/medical/virology
	name = "Virology"
	icon_state = "virology"
	ambience_index = AMBIENCE_VIROLOGY

/area/planetoid/lazarus/medical/virology/lab
	name = "Virology Laboratory"

/area/planetoid/lazarus/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	is_haunted = TRUE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/planetoid/lazarus/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/planetoid/lazarus/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/planetoid/lazarus/medical/surgery/north
	name = "Surgery 1"
	icon_state = "surgery1"

/area/planetoid/lazarus/medical/surgery/south
	name = "Surgery 2"
	icon_state = "surgery2"

/area/planetoid/lazarus/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/planetoid/lazarus/science/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/planetoid/lazarus/medical/cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/planetoid/lazarus/medical/sleeper
	name = "Medical Treatment Center"
	icon_state = "exam_room"

/area/planetoid/lazarus/medical/paramedic
	name = "Paramedic"
	icon_state = "medbay"

// MARK: Science
/area/planetoid/lazarus/science
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/planetoid/lazarus/science/rnd
	name = "Research and Development"
	icon_state = "toxlab"

/area/planetoid/lazarus/science/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxmix"
	xenobiology_compatible = TRUE

/area/planetoid/lazarus/science/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"

/area/planetoid/lazarus/science/toxins/test
	name = "Toxins Test Area"
	icon_state = "toxtest"
	valid_territory = FALSE

/area/planetoid/lazarus/science/toxins/mixing
	name = "Toxins Mixing Room"
	icon_state = "toxmix"

/area/planetoid/lazarus/science/toxins/launch
	name = "Toxins Launch Room"
	icon_state = "toxlaunch"

/area/planetoid/lazarus/science/chem_lab
	name = "Research Testing Lab"
	icon_state = "toxmisc"

/area/planetoid/lazarus/science/chem_lab/chamber
	name = "Research Testing Chamber"
	icon_state = "toxtest"

/area/planetoid/lazarus/science/server
	name = "Server Room"
	icon_state = "server"

/area/planetoid/lazarus/science/sm_chamber
	name = "Supermatter Testing Lab"
	icon_state = "toxtest"
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/planetoid/lazarus/science/explab
	name = "E.X.P.E.R.I-MENTOR Lab"
	icon_state = "toxmisc"

/area/planetoid/lazarus/science/explab/chamber
	name = "E.X.P.E.R.I-MENTOR Chamber"

/area/planetoid/lazarus/science/robotics/chargebay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/planetoid/lazarus/science/robotics/showroom
	name = "Robotics Showroom"
	icon_state = "showroom"

/area/planetoid/lazarus/science/security
	name = "Research Security Room"
	icon_state = "red"

/area/planetoid/lazarus/science/smes
	name = "Research SMES"

/area/planetoid/lazarus/science/hallway
	name = "Research Hallway"

/area/planetoid/lazarus/science/hallway/arrivals
	name = "Research Arrivals Hallway"

/area/planetoid/lazarus/science/hallway/aest_arrivals
	name = "Research West Arrivals Hallway"

/area/planetoid/lazarus/science/hallway/main
	name = "Research Main Hallway"

/area/planetoid/lazarus/science/storage
	name = "Research Tool Storage"

/area/planetoid/lazarus/science/research
	name = "Research North Hallway"

/area/planetoid/lazarus/science/research/lobby
	name = "Research Division"
	icon_state = "research"

/area/planetoid/lazarus/science/robotics
	name = "Research South Hallway"

/area/planetoid/lazarus/science/break_room
	name = "Research Restroom"

// MARL: Security
/area/planetoid/lazarus/security
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/planetoid/lazarus/security/main
	name = "Security Office"
	icon_state = "securityoffice"

/area/planetoid/lazarus/security/lobby
	name = "Security Lobby"
	icon_state = "securitylobby"

/area/planetoid/lazarus/security/brig
	name = "Brig"
	icon_state = "brig"

/area/planetoid/lazarus/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	return ..()

/area/planetoid/lazarus/security/prison/perma
	name = "Perma Prison Wing"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE

/area/planetoid/lazarus/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	can_get_auto_cryod = FALSE

/area/planetoid/lazarus/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	return ..()

/area/planetoid/lazarus/security/prison/cell_block
	name = "Prison Cell Block"
	icon_state = "brig"

/area/planetoid/lazarus/security/prison/cell_block/secondary
	name = "Prison Cell Block A"
	icon_state = "brigcella"

/area/planetoid/lazarus/security/hallway/reception
	name = "Brig Reception"
	icon_state = "brig"

/area/planetoid/lazarus/security/hallway/execution
	name = "Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/planetoid/lazarus/security/hallway/perma
	name = "Permabrig Hallway"
	icon_state = "sec_prison_perma"

/area/planetoid/lazarus/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/planetoid/lazarus/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"
	can_get_auto_cryod = FALSE

/area/planetoid/lazarus/security/storage
	name = "Security Equipment Storage"
	icon_state = "securityequipmentstorage"

/area/planetoid/lazarus/security/courtroom
	name = "Brig Staff Room"
	icon_state = "brig"

/area/planetoid/lazarus/security/evidence
	name = "Evidence Room"
	icon_state = "evidence"

/area/planetoid/lazarus/security/prison/visit
	name = "Visiting Room"
	icon_state = "visiting-room"

/area/planetoid/lazarus/security/prison/lockers
	name = "Prisoner Lockers"
	icon_state = "sec_prison_lockers"

/area/planetoid/lazarus/security/medical
	name = "Security Medbay"
	icon_state = "security_medbay"

/area/planetoid/lazarus/security/prisoner_shuttle
	name = "Security Prisoner Shuttle"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/planetoid/lazarus/security/warden
	name = "Warden's Office"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/planetoid/lazarus/security/hallway/armory
	name = "Secure Armory"
	icon_state = "secarmory"

/area/planetoid/lazarus/security/hallway/secure
	name = "Brig Secure Hallway"
	icon_state = "securehall"

/area/planetoid/lazarus/security/podbay
	name = "Security Podbay"
	icon_state = "securitypodbay"

/area/planetoid/lazarus/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
	)

/area/planetoid/lazarus/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/planetoid/lazarus/command/vault
	name = "Vault"
	icon_state = "nuke_storage"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/security/customs
	name = "Customs"
	icon_state = "checkpoint1"

/area/planetoid/lazarus/security/customs/secondary
	name = "Customs Secondary"
	icon_state = "security"

/area/planetoid/lazarus/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/planetoid/lazarus/security/checkpoint/south
	name = "Escape Security Checkpoint"
	icon_state = "security"

/area/planetoid/lazarus/legal/office/law
	name = "Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/planetoid/lazarus/security/checkpoint/customs
	name = "Command Checkpoint"

/area/planetoid/lazarus/security/checkpoint/fore
	name = "North Command Checkpoint"

/area/planetoid/lazarus/security/checkpoint/aft
	name = "South Command Checkpoint"

// MARK: Service
/area/planetoid/lazarus/janitor
	name = "Custodial Closet"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/planetoid/lazarus/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/planetoid/lazarus/service/barber
	name = "Barber Shop"
	icon_state = "barber"

/area/planetoid/lazarus/service/clown
	name = "Clown's Office"
	icon_state = "clown_office"
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/planetoid/lazarus/service/mime
	name = "Mime's Office"
	icon_state = "mime_office"
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/planetoid/lazarus/service/library
	name = "Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/planetoid/lazarus/service/library/game_zone
	name = "Library Games Room"

/area/planetoid/lazarus/service/chapel
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	is_haunted = TRUE
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/planetoid/lazarus/service/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"

/area/planetoid/lazarus/service/chapel/morgue
	name = "Chapel Morgue"

/area/planetoid/lazarus/service/chapel/massdriver
	name = "Chapel Mass Driver"

/area/planetoid/lazarus/service/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/planetoid/lazarus/service/bar
	name = "Bar"
	icon_state = "barstation"
	sound_environment = SOUND_AREA_WOODFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/planetoid/lazarus/service/bar/atrium
	name = "Atrium"
	icon_state = "bar"

/area/planetoid/lazarus/service/theatre
	name = "Theatre"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

// MARK: Telecomms
// Telecommunications Satellite
/area/planetoid/lazarus/telecomms
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
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/planetoid/lazarus/telecomms/chamber
	name = "Telecoms Central Compartment"
	icon_state = "tcomms"

// On-Station Telecommunications Areas
/area/planetoid/lazarus/telecomms/server
	name = "Telecoms Server Room"
	icon_state = "tcomms"

// Another
/area/planetoid/spaceport
	name = "Spaceport"

/area/planetoid/lz_ert
	name = "LZ ERT"

/area/planetoid/lz_sol
	name = "LZ Sol"

/area/planetoid/lz_addition_goals
	name = "LZ Addition Goals"

/area/planetoid/lz_ferry
	name = "LZ Ferry"

/area/planetoid/lz_centcomm
	name = "LZ CentComm"

/area/planetoid/lz_escape_pod_one
	name = "LZ Escape Pod One"

/area/planetoid/lz_escape_pod_two
	name = "LZ Escape Pod Two"

/area/planetoid/lz_escape_pod_tree
	name = "LZ Escape Pod Tree"

/area/planetoid/lz_escape_pod_four
	name = "LZ Escape Pod Four"

/area/planetoid/lz_pods_ship
	name = "LZ Pods Ship"

//
/area/planetoid/caves/central_cave_network
	name = "Central Cave Network"

/area/planetoid/caves/east_rnd_cave
	name = "East RnD Cave"

/area/planetoid/caves/north_rnd_cave
	name = "North RnD Cave"

/area/planetoid/caves/west_eng_cave
	name = "West Eng Cave"

/area/planetoid/caves/north_eng_cave
	name = "North Eng Cave"

/area/planetoid/caves/underground_lake
	name = "Underground Lake"
	sound_environment = SOUND_ENVIRONMENT_ALLEY
	ambience_index = null

//
/area/planetoid/lakes
	ambient_buzz = 'sound/ambience/misc/riverbuzz.ogg'
	ambient_buzz_vol = 60

/area/planetoid/lakes/central
	name = "Central Of The River"

/area/planetoid/lakes/west
	name = "West Of The River"

/area/planetoid/lakes/east
	name = "East Of The River"

/area/planetoid/lakes/beach
	name = "Beach"

/area/planetoid/lakes/west_bridge
	name = "Weast Bridge"

/area/planetoid/lakes/central_bridge
	name = "Central Bridge"

/area/planetoid/lakes/east_brig
	name = "East Brid"

/area/planetoid/lakes/containers_street
	name = "Container's Street Storage"

/area/planetoid/jungle
	ambient_buzz = 'sound/ambience/misc/ambience_strata.ogg'
	ambient_buzz_vol = 60
	sound_environment = SOUND_ENVIRONMENT_FOREST

/area/planetoid/jungle/west
	name = "West Jungle"

/area/planetoid/jungle/north
	name = "North Jungle"

/area/planetoid/jungle/east
	name = "East Jungle"

/area/planetoid/jungle/south
	name = "South Jungle"

/area/planetoid/jungle/colony
	name = "Colony Jungle"

/area/planetoid/jungle/colony_roads
	name = "Colony Roads"

/area/planetoid/jungle/orbital_strike
	name = "Orbital strike impact site"

/area/planetoid/jungle/temple_inner
	name = "Temple Inner"
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/planetoid/jungle/temple_outer
	name = "Temple Outer"

/area/planetoid/jungle/test_jungle
	name = "Test Jungle"

/area/planetoid/lazarus/abandoned_building
	holomap_should_draw = FALSE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/planetoid/lazarus/abandoned_building/weather_station
	name = "Abandoned Weather Station"

/area/planetoid/lazarus/abandoned_building/barracks
	name = "Abandoned Barracks"

/area/planetoid/lazarus/abandoned_building/temple_room
	name = "Temple room"
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/planetoid/lazarus/abandoned_building/secpost
	name = "Abandoned Security room"
