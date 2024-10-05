/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME (you can make as many subdivisions as you want)
	name = "NICE NAME" (not required but makes things really nice)
	icon = "ICON FILENAME" (defaults to areas.dmi)
	icon_state = "NAME OF ICON" (defaults to "unknown" (blank))
	requires_power = FALSE (defaults to TRUE)
	music = "music/music.ogg" (defaults to "music/music.ogg")
	sound_environment = SOUND_ENVIRONMENT_NONE (defaults to SOUND_AREA_STANDARD_STATION. Look _DEFINES/sound.dm)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

Numbers in the order will be used to indicate the direction of the sector
This applies to all STANDARD station areas
1 West-North  2 North   3 East-North
4 West        5 Central 6 East
7 West-South  9 South   10 East-South
*/

/*-----------------------------------------------------------------------------*/


/area/admin
	name = "Admin Room"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
	has_gravity = STANDARD_GRAVITY


/area/adminconstruction
	name = "Admin Testing Area"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
	has_gravity = STANDARD_GRAVITY

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	valid_territory = FALSE
	outdoors = TRUE
	ambientsounds = SPACE_SOUNDS
	sound_environment = SOUND_AREA_SPACE
	there_can_be_many = TRUE

/area/space/nearstation
	icon_state = "space_near"
	use_starlight = TRUE

/area/space/planetary
	icon_state = "space_planet"
	use_starlight = FALSE
	static_lighting = TRUE
	ambientsounds = list('sound/ambience/ambimine.ogg')
	sound_environment = SOUND_AREA_ASTEROID

/area/space/atmosalert()
	return

/area/space/firealert(obj/source)
	return

/area/space/firereset(obj/source)
	return

//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	no_teleportlocs = TRUE
	requires_power = FALSE
	valid_territory = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = TRUE
	parallax_movedir = NORTH
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/shuttle/arrival
	name = "Arrival Shuttle"
/*
/area/shuttle/arrival/pre_game //dont have this, but at once...
	icon_state = "shuttle2"
*/
/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/auxillary_base
	icon_state = "shuttle"

/area/shuttle/escape
	name = "Emergency Shuttle"
	icon_state = "shuttle2"
	nad_allowed = TRUE

/area/shuttle/pod_1
	name = "Escape Pod One"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_2
	name = "Escape Pod Two"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_3
	name = "Escape Pod Three"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/pod_4
	name = "Escape Pod Four"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/escape_pod1
	name = "Escape Pod One"
	nad_allowed = TRUE

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod2
	name = "Escape Pod Two"
	nad_allowed = TRUE

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod3
	name = "Escape Pod Three"
	nad_allowed = TRUE

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "Escape Pod Five"
	nad_allowed = TRUE

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"

/area/shuttle/mining
	name = "Mining Shuttle"
	icon_state = "shuttle"

/area/shuttle/transport
	icon_state = "shuttle"
	name = "Transport Shuttle"
	parallax_movedir = EAST

/area/shuttle/transport1
	icon_state = "shuttle"
	name = "Transport Shuttle"

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "Alien Shuttle Base"
	requires_power = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "Alien Shuttle Mine"
	requires_power = 1

/area/shuttle/gamma
	icon_state = "shuttle"
	name = "Gamma Armory"

/area/shuttle/prison/
	name = "Prison Shuttle"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

/area/shuttle/siberia
	name = "Labor Camp Shuttle"
	icon_state = "shuttle"

/area/shuttle/specops
	name = "Special Ops Shuttle"
	icon_state = "shuttlered"
	parallax_movedir = EAST

/area/shuttle/specops/centcom
	name = "Special Ops Shuttle"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "Special Ops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH

/area/shuttle/syndicate_elite/mothership
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_sit
	name = "Syndicate SIT Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH

/area/shuttle/assault_pod
	name = "Steel Rain"
	icon_state = "shuttle"

/area/shuttle/nt_droppod
	name = "Shit rain"
	icon_state = "shuttle"

/area/shuttle/administration
	name = "Nanotrasen Vessel"
	icon_state = "shuttlered"
	parallax_movedir = WEST

/area/shuttle/administration/centcom
	name = "Nanotrasen Vessel Centcom"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "Nanotrasen Vessel"
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "honk"

/area/shuttle/thunderdome/grnshuttle
	name = "Thunderdome GRN Shuttle"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "GRN Shuttle"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "GRN Station"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "Thunderdome RED Shuttle"
	icon_state = "red"

/area/shuttle/thunderdome/redshuttle/dome
	name = "RED Shuttle"
	icon_state = "shuttlered"

/area/shuttle/thunderdome/redshuttle/station
	name = "RED Station"
	icon_state = "shuttlered2"
// === Trying to remove these areas:

/area/shuttle/research
	name = "Research Shuttle"
	icon_state = "shuttle"

/area/shuttle/research/station
	icon_state = "shuttle2"

/area/shuttle/research/outpost
	icon_state = "shuttle"

/area/shuttle/vox
	name = "Vox Skipjack"
	icon_state = "shuttle"

/area/shuttle/vox/station
	name = "Vox Skipjack"
	icon_state = "yellow"

/area/shuttle/salvage
	name = "Salvage Ship"
	icon_state = "yellow"

/area/shuttle/salvage/start
	name = "Middle of Nowhere"
	icon_state = "yellow"

/area/shuttle/salvage/arrivals
	name = "Space Station Auxiliary Docking"
	icon_state = "yellow"

/area/shuttle/salvage/derelict
	name = "Derelict Station"
	icon_state = "yellow"

/area/shuttle/salvage/djstation
	name = "Ruskie DJ Station"
	icon_state = "yellow"

/area/shuttle/salvage/north
	name = "North of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/east
	name = "East of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/south
	name = "South of the Station"
	icon_state = "yellow"

/area/shuttle/salvage/commssat
	name = "The Communications Satellite"
	icon_state = "yellow"

/area/shuttle/salvage/mining
	name = "South-West of the Mining Asteroid"
	icon_state = "yellow"

/area/shuttle/salvage/abandoned_ship
	name = "Abandoned Ship"
	icon_state = "yellow"
	parallax_movedir = WEST

/area/shuttle/salvage/clown_asteroid
	name = "Clown Asteroid"
	icon_state = "yellow"

/area/shuttle/salvage/trading_post
	name = "Trading Post"
	icon_state = "yellow"

/area/shuttle/salvage/transit
	name = "hyperspace"
	icon_state = "shuttle"

/area/shuttle/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/shuttle/ussp
	name = "USSP Shuttle"
	icon_state = "shuttle3"

/area/shuttle/spacebar
	name = "Space Bar Shuttle"
	icon_state = "shuttle3"

/area/shuttle/abandoned
	name = "Abandoned Ship"
	icon_state = "shuttle"

/area/shuttle/syndicate
	name = "Syndicate Nuclear Team Shuttle"
	icon_state = "shuttle"
	nad_allowed = TRUE

/area/shuttle/trade
	name = "Trade Shuttle"
	icon_state = "shuttle"

/area/shuttle/trade/sol
	name = "Sol Freighter"
	parallax_movedir = WEST

/area/shuttle/freegolem
	name = "Free Golem Ship"
	icon_state = "purple"
	xenobiology_compatible = TRUE

/area/shuttle/pirate_corvette
	name = "Pirate Corvette"
	icon_state = "shuttle"

/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = null

// === end remove

// CENTCOM

/area/centcom
	name = "Centcom"
	icon_state = "centcom"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	nad_allowed = TRUE
	has_gravity = STANDARD_GRAVITY

// New CC
/area/centcom/bridge
	name = "Centcom Bridge"
	icon_state = "centcom_bridge"

/area/centcom/court
	name = "Centcom Court"
	icon_state = "centcom_court"

/area/centcom/ferry
	name = "Centcom Ferry Shuttle"
	icon_state = "centcom_ferry"

/area/centcom/gamma
	name = "Centcom Gamma Armory"
	icon_state = "centcom_gamma"

/area/centcom/supply
	name = "Centcom Supply Shuttle"
	icon_state = "centcom_supply"

/area/centcom/jail
	name = "Centcom Jail"
	icon_state = "centcom_jail"

/area/centcom/zone3
	name = "Centcom Zone 3"
	icon_state = "centcom_zone3"

/area/centcom/zone2
	name = "Centcom Zone 2"
	icon_state = "centcom_zone2"

/area/centcom/zone1
	name = "Centcom Zone 1"
	icon_state = "centcom_zone1"

/area/centcom/evac
	name = "Centcom Evacuation Emergency Shuttle"
	icon_state = "centcom_evac"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/centcom/specops
	name = "Centcom Special Operations Forces"
	icon_state = "centcom_specops"

/area/centcom/srtops
	name = "Centcom Special Reaction Team"
	icon_state = "centcom_srtops"

/area/centcom/blops
	name = "Centcom Black Operations Squad"
	icon_state = "centcom_blops"

/area/centcom/shuttle
	name = "Centcom Administration Shuttle"

//SYNDICATES

/area/syndicate_mothership
	name = "Syndicate Forward Base"
	icon_state = "syndie-ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
	nad_allowed = TRUE
	ambientsounds = HIGHSEC_SOUNDS

/area/syndicate_mothership/outside
	name = "Syndicate Controlled Territory"
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	icon_state = "syndie-outside"

/area/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

/area/syndicate_mothership/infteam
	name = "Syndicate Infiltrators"
	icon_state = "syndie-infiltrator"

/area/syndicate_mothership/jail
	name = "Syndicate Jail"
	icon_state = "syndie-jail"

/area/syndicate_mothership/cargo
	name = "Syndicate Cargo"
	icon_state = "syndie-cargo"

// USSP

/area/ussp_ship
	name = "USSP Ship Project 28u"
	icon_state = "ussp_ship"
	requires_power = TRUE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
	ambientsounds = HIGHSEC_SOUNDS

// Chrono

/area/chrono_ship
	name = "Chrono Ship"
	icon_state = "chrono_ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	nad_allowed = TRUE

//EXTRA

/area/event_zone
	name = "Event Zone"
	icon_state = "event_zone"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	nad_allowed = TRUE

/area/asteroid					// -- TLE
	name = "Asteroid"
	icon_state = "asteroid"
	requires_power = FALSE
	valid_territory = FALSE
	ambientsounds = MINING_SOUNDS

/area/asteroid/cave				// -- TLE
	name = "Asteroid - Underground"
	icon_state = "cave"
	requires_power = FALSE
	outdoors = TRUE
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"

/area/tdome
	name = "Thunderdome"
	icon_state = "thunder"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE


/area/tdome/arena_source
	name = "Thunderdome Arena Template"
	icon_state = "thunder"

/area/tdome/arena
	name = "Thunderdome Arena"
	icon_state = "thunder"

/area/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"

/area/tdome/newtdome
	name = "New Thunderdome Arena"
	icon_state = "thunder"

/area/tdome/newtdome/CQC
	name = "New Thunderdome Arena - Close Combat"
	icon_state = "thunderCQC"

/area/exploration/methlab
	name = "Abandoned Drug Lab"
	icon_state = "green"
	there_can_be_many = TRUE
	has_gravity = STANDARD_GRAVITY

//Abductors
/area/abductor_ship
	name = "Abductor Ship"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY

/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/ninja
	name = "Ninja Area Parent"
	icon_state = "ninjabase"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	no_teleportlocs = TRUE
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	nad_allowed = TRUE

/area/ninja/outpost
	name = "SpiderClan Dojo"
	icon_state = "ninja_dojo"

/area/ninja/holding
	name = "SpiderClan Holding Facility"
	icon_state = "ninja_holding"
	ambientsounds = list('sound/ambience/ambifailure.ogg', 'sound/ambience/ambigen4.ogg', 'sound/ambience/ambimaint2.ogg', 'sound/ambience/ambimystery.ogg', 'sound/ambience/ambitech2.ogg')

/area/ninja/outside
	name = "SpiderClan Territory"
	icon_state = "ninja_outside"
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	sound_environment = SOUND_AREA_ASTEROID

/area/vox_station
	name = "Vox Base"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255
	no_teleportlocs = TRUE

/area/trader_station
	name = "Trade Base"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/trader_station/sol
	name = "Jupiter Station 6"

/area/ussp_centcom
	name = "USSP central committee"
	icon_state = "red"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/ussp_centcom/secretariat
	name = "Soviet secretariat"

//Labor camp
/area/mine/laborcamp
	name = "Labor Camp"
	icon_state = "brig"

/area/mine/laborcamp/security
	name = "Labor Camp Security"
	icon_state = "security"

//STATION13

/area/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/atmos/control
	name = "Atmospherics Control Room"
	icon_state = "atmos"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/atmos/distribution
 	name = "Atmospherics Distribution Loop"
 	icon_state = "atmos"

/area/atmos/break_room
	name = "Atmospherics Foyer"
	icon_state = "atmos"

// MAINTENANCE
/area/maintenance
	ambientsounds = MAINTENANCE_SOUNDS
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/maintenance/ai
	name = "AI Maintenance"
	icon_state = "green"

/area/maintenance/fore //should be refactored
	name = "North Maintenance"
	icon_state = "fmaint"

/area/maintenance/fore2
	name = "North Secondary Maintenance"
	icon_state = "fmaint"

/area/maintenance/aft
	name = "West Maintenance"
	icon_state = "amaint"

/area/maintenance/aft2
	name = "West Secondary Maintenance"
	icon_state = "amaint"

/area/maintenance/fpmaint
	name = "North-West Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Dormitory Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Bar Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint3
	name = "Cargo East Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint4
	name = "Cargo North Maintenance"
	icon_state = "fsmaint"

/area/maintenance/tourist
	name = "Tourist Area Maintenance"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Medbay Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint2
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint3
	name = "Research Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint4
	name = "Virology Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint5
	name = "Arrivals Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint6
	name = "RnD Restroom Maintenance"
	icon_state = "asmaint"

/area/maintenance/apmaint
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/maintenance/apmaint2
	name = "South-West Maintenance"
	icon_state = "apmaint"

/area/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "central"

/area/maintenance/maintcentral2
	name = "Central Secondary Maintenance"
	icon_state = "maintcentral"

/area/maintenance/starboard
	name = "East Maintenance"
	icon_state = "smaint"

/area/maintenance/starboard2
	name = "East Secondary Maintenance"
	icon_state = "smaint"

/area/maintenance/port
	name = "West Maintenance"
	icon_state = "pmaint"

/area/maintenance/port2
	name = "West Secondary Maintenance"
	icon_state = "pmaint"

/area/maintenance/brig
	name = "Brig Maintenance"
	icon_state = "pmaint"

/area/maintenance/perma
	name = "Prison Maintenance"
	icon_state = "green"

/area/maintenance/atmospherics
	name = "Atmospherics Maintenance"
	icon_state = "green"

/area/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"

/area/maintenance/turbine
	name = "Turbine"
	icon_state = "disposal"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/maintenance/disposal/southwest
	name = "South Western Disposals"

/area/maintenance/disposal/south
	name = "Southern Disposals"

/area/maintenance/disposal/east
	name = "Eastern Disposals"

/area/maintenance/disposal/northeast
	name = "North Eastern Disposals"

/area/maintenance/disposal/north
	name = "Northern Disposals"

/area/maintenance/disposal/northwest
	name = "North Western Disposals"

/area/maintenance/disposal/west
	name = "Western Disposals"

/area/maintenance/disposal/westalt
	name = "Western Secondary Disposals"

/area/maintenance/disposal/external/southwest
	name = "South-Western External Waste Belt"

/area/maintenance/disposal/external/southeast
	name = "South-Eastern External Waste Belt"

/area/maintenance/disposal/external/east
	name="Eastern External Waste Belt"

/area/maintenance/disposal/external/north
	name = "Northern External Waste Belt"

/area/maintenance/genetics
	name = "Genetics Maintenance"
	icon_state = "asmaint"

/area/maintenance/electrical
	name = "Electrical Maintenance"
	icon_state = "elec"

/area/maintenance/engineering
	name = "Engineering Maintenance"
	icon_state = "green"

/area/maintenance/bar
	name = "Maintenance Bar"
	icon_state = "oldbar"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/maintenance/electrical_shop
	name = "Electronics Den"
	icon_state = "elec"

/area/maintenance/gambling_den
	name = "Abandoned Fight Club"//Отличное соотвествие названия
	icon_state = "yellow"

/area/maintenance/gambling_den2
	name = "Gambling Den"
	icon_state = "yellow"

/area/maintenance/casino
	name = "Abandoned Casino"
	icon_state = "yellow"

/area/maintenance/consarea
	name = "Alternate Construction Area"
	icon_state = "construction"

/area/maintenance/consarea_virology
	name = "Virology Maintenance Construction Area"
	icon_state = "yellow"

/area/maintenance/detectives_office
	name = "Abandoned Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/maintenance/engrooms
	name = "Abandoned Engineers Rooms"
	icon_state = "yellow"

/area/maintenance/library
	name = "Abandoned Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/maintenance/quarters
	name = "Abandoned Living Quarters"
	icon_state = "Sleep"

/area/maintenance/secpost
	name = "Abandoned Security Post"
	icon_state = "security"

/area/maintenance/banya
	name = "Abandoned Banya"
	icon_state = "yellow"

/area/maintenance/medroom
	name = "Abandoned Medical Emergency Ward"
	icon_state = "medbay3"

/area/maintenance/chapel
	name = "Abandoned Chapel"
	icon_state = "chapel"
	ambientsounds = list('sound/ambience/ambimo2.ogg', 'sound/ambience/spooky/moan1.ogg', 'sound/ambience/spooky/muffled_cry1.ogg', 'sound/ambience/spooky/scared_breathing1.ogg', 'sound/ambience/spooky/scared_breathing2.ogg', 'sound/ambience/spooky/scared_sob1.ogg', 'sound/ambience/spooky/scared_sob2.ogg')
	is_haunted = TRUE

/area/maintenance/livingcomplex
	name = "Abandoned Living Complex Lobby"
	icon_state = "quart"

/area/maintenance/livingcomplex/hall
	name = "Abandoned Living Complex Hall"
	icon_state = "quart"

/area/maintenance/cafeteria
	name = "Abandoned Cafeteria"
	icon_state = "cafeteria"

/area/maintenance/xenozoo
	name = "Maintenance Xeno Zoo"
	icon_state = "yellow"

/area/maintenance/club
	name = "Old Poker Club"
	icon_state = "yellow"

/area/maintenance/backstage
	name = "Backstage"
	icon_state = "yellow"

/area/maintenance/trading
	name = "Trading area"
	icon_state = "yellow"

/area/maintenance/server
	name = "Abandoned Server Room"
	icon_state = "yellow"

/area/maintenance/cele //for SDMM group of zones
	icon_state = "green"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/maintenance/cele/command
	name = "Command Basement Maintenance"

/area/maintenance/cele/cargo
	name = "Cargo Basement Maintenance"

/area/maintenance/cele/medbay
	name = "Medical Basement Maintenance"

/area/maintenance/cele/servise
	name = "Servise Basement Maintenance"

/area/maintenance/cele/arrival
	name = "Arrival Basement Maintenance"

/area/maintenance/cele/engineering
	name = "Engineering Basement Maintenance"

//Hallway

/area/hallway
	valid_territory = FALSE //too many areas with similar/same names, also not very interesting summon spots
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hallway/primary/fore
	name = "North Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/fore/west
	name = "North-West Hallway"

/area/hallway/primary/fore/east
	name = "North-East Hallway"

/area/hallway/primary/fore/north
	name = "North-North Hallway"

/area/hallway/primary/fore/south
	name = "North-South Hallway"

/area/hallway/primary/starboard
	name = "East Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/starboard/west
	name = "East-West Hallway"

/area/hallway/primary/starboard/east
	name = "East-East Hallway"

/area/hallway/primary/starboard/north
	name = "East-North Hallway"

/area/hallway/primary/starboard/south
	name = "East-South Hallway"

/area/hallway/primary/aft
	name = "South Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/aft/west
	name = "South-West Hallway"

/area/hallway/primary/aft/east
	name = "South-East Hallway"

/area/hallway/primary/aft/north
	name = "South-North Hallway"

/area/hallway/primary/aft/south
	name = "South-South Hallway"

/area/hallway/primary/port
	name = "West Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/port/west
	name = "West-West Hallway"

/area/hallway/primary/port/east
	name = "West-East Hallway"

/area/hallway/primary/port/north
	name = "West-North Hallway"

/area/hallway/primary/port/south
	name = "West-South Hallway"

/area/hallway/primary/central //pay attention to THIS SHIT
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/central/north
/area/hallway/primary/central/south
/area/hallway/primary/central/west
/area/hallway/primary/central/east
/area/hallway/primary/central/nw
/area/hallway/primary/central/ne
/area/hallway/primary/central/sw
/area/hallway/primary/central/se

/area/hallway/primary/command
	name = "Command Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/command/north
/area/hallway/primary/command/south
/area/hallway/primary/command/west
/area/hallway/primary/command/east
/area/hallway/primary/command/nw
/area/hallway/primary/command/ne

/area/hallway/primary/central/second
	name = "Second Floor Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/central/second/north
/area/hallway/primary/central/second/south
/area/hallway/primary/central/second/west
/area/hallway/primary/central/second/east
/area/hallway/primary/central/second/nw
/area/hallway/primary/central/second/ne
/area/hallway/primary/central/second/sw
/area/hallway/primary/central/second/se

/area/hallway/spacebridge
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	icon_state = "hall_space"

/area/hallway/spacebridge/dockmed
	name = "Docking-Medical Bridge"

/area/hallway/spacebridge/scidock
	name = "Science-Docking Bridge"

/area/hallway/spacebridge/somsec
	name = "Comand-Security Bridge"

/area/hallway/spacebridge/sersec
	name = "Service-Security Bridge"

/area/hallway/spacebridge/engdock
	name = "Engineering-Docking Bridge"

/area/hallway/spacebridge/servsci
	name = "Service-Science Bridge"

/area/hallway/spacebridge/serveng
	name = "Service-Engineering Bridge"

/area/hallway/spacebridge/engmed
	name = "Engineering-Medical Bridge"

/area/hallway/spacebridge/medcargo
	name = "Medical-Cargo Bridge"

/area/hallway/spacebridge/cargocom
	name = "Cargo-AI-Command Bridge"

/area/hallway/spacebridge/sercom
	name = "Command-Service Bridge"

/area/hallway/spacebridge/comeng
	name = "Command-Engineering Bridge"

/area/hallway/spacebridge/comcar
	name = "Command-Cargo Bridge"

/area/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/exit/maint
	name = "Abandoned Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/construction
	name = "Construction Area"
	icon_state = "construction"

/area/hallway/secondary/garden
	name = "Garden"
	icon_state = "hydro"

/area/hallway/secondary/entry
	name = "Arrivals Hallway"
	icon_state = "entry"

/area/hallway/secondary/entry/eastarrival
	name = "Arrival Shuttle East Hallway"

/area/hallway/secondary/entry/westarrival
	name = "Arrival Shuttle West Hallway"

/area/hallway/secondary/entry/additional
	name = "Arrival Additional West Hallway"

/area/hallway/secondary/entry/commercial
	name = "Arrival Commercial West Hallway"

/area/hallway/secondary/entry/north

/area/hallway/secondary/entry/south

/area/hallway/secondary/entry/lounge
	name = "Arrivals Lounge"


//Command

/area/bridge
	name = "Bridge"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/vip
	name = "VIP Area"
	icon_state = "meeting"

/area/crew_quarters
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/crew_quarters/captain
	name = "Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/captain/bedroom
	name = "Captain's Bedroom"
	icon_state = "captain"

/area/crew_quarters/recruit
	name = "Recruitment Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hop
	name = "Head of Personnel's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hor
	name = "Research Director's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/chief
	name = "Chief Engineer's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hos
	name = "Head of Security's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/heads/cmo
	name = "Chief Medical Officer's Quarters"
	icon_state = "head_quarters"

/area/crew_quarters/courtroom
	name = "Courtroom"
	icon_state = "courtroom"

/area/crew_quarters/heads
	name = "Head of Personnel's Office"
	icon_state = "head_quarters"

/area/crew_quarters/hor
	name = "Research Director's Office"
	icon_state = "head_quarters"

/area/crew_quarters/hos
	name = "Head of Security's Office"
	icon_state = "head_quarters"

/area/crew_quarters/chief
	name = "Chief Engineer's Office"
	icon_state = "head_quarters"

/area/mint
	name = "Mint"
	icon_state = "green"

/area/comms
	name = "Communications Relay"
	icon_state = "tcomms"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/server
	name = "Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ntrep
	name = "Nanotrasen Representative's Office"
	icon_state = "ntrep"

/area/blueshield
	name = "Blueshield's Office"
	icon_state = "blueshield"

/area/centcomdocks
	name = "Central Command Docks"
	icon_state = "centcom"

/area/bridge/checkpoint
	name = "Command Checkpoint"
	icon_state = "bridge"

/area/bridge/checkpoint/north
	name = "North Command Checkpoint"
	icon_state = "bridge"

/area/bridge/checkpoint/south
	name = "South Command Checkpoint"
	icon_state = "bridge"
//Crew

/area/crew_quarters
	name = "Dormitories"
	icon_state = "Sleep"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/crew_quarters/serviceyard
	name = "Service Yard"
	icon_state = "Sleep"

/area/crew_quarters/cabin1
	name = "First Cabin"

/area/crew_quarters/cabin2
	name = "Second Cabin"

/area/crew_quarters/cabin3
	name = "Third Cabin"

/area/crew_quarters/cabin4
	name = "Fourth Cabin"

/area/crew_quarters/toilet
	name = "Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet2
	name = "West Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet3
	name = "Theatre Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet4
	name = "Arrivals Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/sleep
	name = "Dormitories"
	icon_state = "Sleep"
	valid_territory = FALSE

/area/crew_quarters/sleep/secondary
	name = "Secondary Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male
	name = "Male Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male/toilet_male
	name = "Male Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep_female
	name = "Female Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_female/toilet_female
	name = "Female Toilets"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/dorms
	name = "Dorms"
	icon_state = "dorms"

/area/crew_quarters/trading
	name = "Abandoned Tradiders Room"
	icon_state = "blue"

/area/crew_quarters/arcade
	name = "Arcade"
	icon_state = "arcade"

/area/crew_quarters/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "Bar"
	icon_state = "barstation"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/bar/atrium
	name = "Atrium"
	icon_state = "bar"

/area/crew_quarters/theatre
	name = "Theatre"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/mrchangs
	name = "Mr Chang's"
	icon_state = "Theatre"

/area/library
	name = "Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/library/game_zone
	name = "Library Games Room"
	icon_state = "library"

/area/chapel
	icon_state = "chapel"
	ambientsounds = HOLY_SOUNDS
	is_haunted = TRUE

/area/chapel/main
	name = "Chapel"

/area/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"

/area/escapepodbay
	name = "Escape Shuttle Hallway Podbay"
	icon_state = "escape"

/area/lawoffice
	name = "Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/magistrateoffice
	name = "Magistrate's Office"
	icon_state = "magistrate"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/clownoffice
	name = "Clown's Office"
	icon_state = "clown_office"
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL

/area/clownoffice/secret
	name = "Top Secret Clown HQ"

/area/mimeoffice
	name = "Mime's Office"
	icon_state = "mime_office"

// CIVILIAN

/area/civilian/vacantoffice
	name = "Vacant Office"
	icon_state = "green"

/area/civilian/barber
	name = "Barber Shop"
	icon_state = "barber"

/area/civilian/clothing
	name = "Clothing Shop"
	icon_state = "Theatre"

/area/civilian/pet_store
	name = "Pet Store"
	icon_state = "pet_store"

/area/holodeck
	name = "Holodeck"
	icon_state = "Holodeck"
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255

/area/holodeck/alphadeck
	name = "Holodeck Alpha"


/area/holodeck/source_plating
	name = "Holodeck - Off"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "Holodeck - Empty Court"

/area/holodeck/source_boxingcourt
	name = "Holodeck - Boxing Court"

/area/holodeck/source_basketball
	name = "Holodeck - Basketball Court"

/area/holodeck/source_thunderdomecourt
	name = "Holodeck - Thunderdome Court"

/area/holodeck/source_beach
	name = "Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/holodeck/source_burntest
	name = "Holodeck - Atmospheric Burn Test"

/area/holodeck/source_wildlife
	name = "Holodeck - Wildlife Simulation"

/area/holodeck/source_meetinghall
	name = "Holodeck - Meeting Hall"

/area/holodeck/source_theatre
	name = "Holodeck - Theatre"

/area/holodeck/source_picnicarea
	name = "Holodeck - Picnic Area"

/area/holodeck/source_snowfield
	name = "Holodeck - Snow Field"

/area/holodeck/source_desert
	name = "Holodeck - Desert"

/area/holodeck/source_space
	name = "Holodeck - Space"

/area/holodeck/source_knightarena
	name = "Holodeck - Knight Arena"


//Embassies
/area/embassy/
	name = "Embassy Hallway"

/area/embassy/tajaran
	name = "Tajaran Embassy"
	icon_state = "tajaran"

/area/embassy/skrell
	name = "Skrell Embassy"
	icon_state = "skrell"

/area/embassy/unathi
	name = "Unathi Embassy"
	icon_state = "unathi"

/area/embassy/kidan
	name = "Kidan Embassy"
	icon_state = "kidan"

/area/embassy/diona
	name = "Diona Embassy"
	icon_state = "diona"

/area/embassy/slime
	name = "Slime Person Embassy"
	icon_state = "slime"

/area/embassy/grey
	name = "Grey Embassy"
	icon_state = "grey"

/area/embassy/vox
	name = "Vox Embassy"
	icon_state = "vox"



//Engineering
/area/engine
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/engine/engine_smes
	name = "Engineering SMES"
	icon_state = "engine_smes"

/area/engine/engineering
	name = "Engineering"
	icon_state = "engine_smes"

/area/engine/engineering/monitor
	name = "Engineering Monitoring Room"
	icon_state = "engine_control"

/area/engine/break_room
	name = "Engineering Foyer"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/aienter
	name = "AI Sattelit Access Point"
	icon_state = "engine"

/area/engine/equipmentstorage
	name = "Engineering Equipment Storage"
	icon_state = "storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/hardsuitstorage
	name = "Engineering Hardsuit Storage"
	icon_state = "storage"

/area/engine/controlroom
	name = "Engineering Control Room"
	icon_state = "engine_control"

/area/engine/gravitygenerator
	name = "Gravity Generator"
	icon_state = "engine"

/area/engine/chiefs_office
	name = "Chief Engineer's Office"
	icon_state = "engine_control"

/area/engine/mechanic_workshop
	name = "Mechanic Workshop"
	icon_state = "engine"

/area/engine/mechanic_workshop/expedition
	name = "Hangar Expedition"
	icon_state = "engine"

/area/engine/mechanic_workshop/hangar
	name = "Hangаr Bay"
	icon_state = "engine"

/area/engine/supermatter
	name = "Supermatter Engine"
	icon_state = "engine"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

//Solars

/area/solar //i hate this macaroni areas
	requires_power = FALSE
	valid_territory = FALSE
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE
	static_lighting = FALSE
	base_lighting_color = COLOR_WHITE
	base_lighting_alpha = 255

/area/solar/auxport
	name = "North-West Solar Array"
	icon_state = "panelsA"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/solar/auxstarboard
	name = "North-East Solar Array"
	icon_state = "panelsA"

/area/solar/fore
	name = "North Solar Array"
	icon_state = "yellow"

/area/solar/aft
	name = "South Solar Array"
	icon_state = "aft"

/area/solar/starboardaux
	name = "East Solar Array"
	icon_state = "panelsS"

/area/solar/starboard
	name = "South-East Solar Array"
	icon_state = "panelsS"

/area/solar/west
	name = "West Solar Array"
	icon_state = "panelsS"

/area/solar/port
	name = "South-West Solar Array"
	icon_state = "panelsP"

/area/maintenance/auxsolarport
	name = "North-West Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/north_solars
	name = "North Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/starboardaux
	name = "East Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/starboardsolar
	name = "South-East Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/portsolar
	name = "South-West Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/auxsolarstarboard
	name = "North-East Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/west_solars
	name = "West Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/assembly/chargebay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/assembly/showroom
	name = "Robotics Showroom"
	icon_state = "showroom"

/area/assembly/robotics
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "Assembly Line"
	icon_state = "ass_line"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

//Teleporter

/area/teleporter
	name = "Teleporter"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS

/area/teleporter/research
	name = "Robotics Teleporter"

/area/teleporter/abandoned
    name = "Abandoned Teleporter"
    icon_state = "teleporter"
    ambientsounds = ENGINEERING_SOUNDS

/area/teleporter/quantum/security
	name = "Security Quantum Pad"

/area/teleporter/quantum/docking
	name = "Docking Quantum Pad"

/area/teleporter/quantum/science
	name = "Science Quantum Pad"

/area/teleporter/quantum/cargo
	name = "Cargo Quantum Pad"

/area/teleporter/quantum/comand
	name = "Comand Quantum Pad"

/area/teleporter/quantum/service
	name = "Service Quantum Pad"

/area/teleporter/quantum/medbay
	name = "Medical Quantum Pad"

/area/teleporter/quantum/engi
	name = "Engineering Quantum Pad"

/area/gateway
	name = "Gateway"
	icon_state = "teleporter"
	ambientsounds = ENGINEERING_SOUNDS

/area/AIsattele
	name = "Unknown Teleporter"
	icon_state = "teleporter"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/signal.ogg')
	there_can_be_many = TRUE

/area/toxins/explab
	name = "E.X.P.E.R.I-MENTOR Lab"
	icon_state = "toxmisc"

/area/toxins/explab_chamber
	name = "E.X.P.E.R.I-MENTOR Chamber"
	icon_state = "toxmisc"

//MedBay

/area/medical
	ambientsounds = MEDICAL_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS

/area/medical/medbay
	name = "Medbay"
	icon_state = "medbay"

//Medbay is a large area, these additional areas help level out APC load. wtf dude, nobody use THIS MUCH ZONES
/area/medical/medbay2
	name = "Medbay"
	icon_state = "medbay2"

/area/medical/medbay3
	name = "Medbay"
	icon_state = "medbay3"


/area/medical/biostorage
	name = "Medical Storage"
	icon_state = "medbaysecstorage"

/area/medical/reception
	name = "Medbay Reception"
	icon_state = "medbay"

/area/medical/psych
	name = "Psych Room"
	icon_state = "medbaypsych"

/area/medical/medbreak
	name = "Break Room"
	icon_state = "medbaybreak"

/area/medical/medrest
	name = "Med Restroom"
	icon_state = "medbaybreak"

/area/medical/patients_rooms
	name = "Patient's Rooms"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/medical/ward
	name = "Medbay Patient Ward"
	icon_state = "patientsward"

/area/medical/patient_a
	name = "Isolation A"
	icon_state = "medbayisoa"

/area/medical/patient_b
	name = "Isolation B"
	icon_state = "medbayisob"

/area/medical/patient_c
	name = "Isolation C"
	icon_state = "medbayisoc"

/area/medical/iso_access
	name = "Isolation Access"
	icon_state = "medbayisoaccess"

/area/medical/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "CMO"

/area/medical/cmostore
	name = "Medical Secondary Storage"
	icon_state = "medbaysecstorage"

/area/medical/robotics //why
	name = "Robotics"
	icon_state = "research"

/area/medical/research
	name = "Research Division"
	icon_state = "research"

/area/medical/research/nhallway
	name = "RnD North Hallway"
	icon_state = "research"

/area/medical/research/shallway
	name = "RnD South Hallway"
	icon_state = "research"

/area/medical/research/restroom
	name = "RnD Restroom"
	icon_state = "research"

/area/medical/research_shuttle_dock
	name = "Research Shuttle Dock"
	icon_state = "medresearch"

/area/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/medical/virology/lab
	name = "Virology Laboratory"
	icon_state = "virology"

/area/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	ambientsounds = SPOOKY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/medical/surgery/north
	name = "Surgery 1"
	icon_state = "surgery1"

/area/medical/surgery/south
	name = "Surgery 2"
	icon_state = "surgery2"

/area/medical/surgery/theatre
	name = "Surgery Theatre"
	icon_state = "surgery_theatre"

/area/medical/surgeryobs
	name = "Surgery Observation"
	icon_state = "surgery"

/area/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/medical/cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Medical Treatment Center"
	icon_state = "exam_room"

/area/medical/paramedic
	name = "Paramedic"
	icon_state = "medbay"

//Security

/area/security
	ambientsounds = HIGHSEC_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/security/main
	name = "Security Office"
	icon_state = "securityoffice"

/area/security/lobby
	name = "Security Lobby"
	icon_state = "securitylobby"

/area/security/brig
	name = "Brig"
	icon_state = "brig"

/area/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	..()

/area/security/permabrig
	name = "Prison Wing"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	can_get_auto_cryod = FALSE

/area/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	..()

/area/security/prison/cell_block
	name = "Prison Cell Block"
	icon_state = "brig"

/area/security/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brigcella"

/area/security/prison/cell_block/B
	name = "Prison Cell Block B"
	icon_state = "brigcellb"

/area/security/prison/cell_block/C
	name = "Prison Cell Block C"
	icon_state = "brig"

/area/security/reception
	name = "Brig Reception"
	icon_state = "brig"

/area/security/execution
	name = "Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/security/permahallway
	name = "Permabrig Hallway"
	icon_state = "sec_prison_perma"

/area/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/security/holding_cell
	name = "Temporary Holding Cell"
	icon_state = "holdingcell"

/area/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"
	can_get_auto_cryod = FALSE

/area/security/seceqstorage
	name = "Security Equipment Storage"
	icon_state = "securityequipmentstorage"

/area/security/brigstaff
	name = "Brig Staff Room"
	icon_state = "brig"

/area/security/interrogationhallway
	name = "Interrogation Hallway"
	icon_state = "interrogationhall"

/area/security/courtroomdandp
	name = "Courtroom Defense and Prosecution"
	icon_state = "seccourt"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/security/interrogationobs
	name = "Interrogation Observation"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/evidence
	name = "Evidence Room"
	icon_state = "evidence"

/area/security/visiting_room
	name = "Visiting Room"
	icon_state = "red"

/area/security/prisonlockers
	name = "Prisoner Lockers"
	icon_state = "sec_prison_lockers"
	can_get_auto_cryod = FALSE

/area/security/medbay
	name = "Security Medbay"
	icon_state = "security_medbay"

/area/security/prisonershuttle
	name = "Security Prisoner Shuttle"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/warden
	name = "Warden's Office"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/armory
	name = "Armory"
	icon_state = "armory"

/area/security/securearmory
	name = "Secure Armory"
	icon_state = "secarmory"

/area/security/securehallway
	name = "Brig Secure Hallway"
	icon_state = "securehall"

/area/security/hos
	name = "Head of Security's Office"
	icon_state = "sec_hos"

/area/security/podbay
	name = "Security Podbay"
	icon_state = "securitypodbay"

/area/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg', 'sound/ambience/ambidet2.ogg')

/area/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/security/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/security/customs
	name = "Customs"
	icon_state = "checkpoint1"

/area/security/customs2
	name = "Customs"
	icon_state = "security"

/area/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint/south
	name = "Escape Security Checkpoint"
	icon_state = "security"

/area/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint1"

/area/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint1"

/area/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint1"

/area/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint1"

/area/civilian/vacantoffice2
	name = "Vacant Office"
	icon_state = "security"

/area/quartermaster
	name = "Quartermasters"
	icon_state = "quart"
	sound_environment = SOUND_AREA_STANDARD_STATION

///////////WORK IN PROGRESS//////////

/area/quartermaster/sorting
	name = "Delivery Office"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_STANDARD_STATION

////////////WORK IN PROGRESS//////////

/area/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/lobby
	name = "Cargo Lobby"
	icon_state = "quartoffice"

/area/quartermaster/delivery
	name = "Cargo Delivery"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/quartermaster/qm
	name = "Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "Mining Storage"
	icon_state = "green"

/area/quartermaster/mechbay
	name = "Mech Bay"
	icon_state = "yellow"

/area/janitor
	name = "Custodial Closet"
	icon_state = "janitor"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/maintenance/garden
	name = "Old Garden"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/maintenance/garden/north
	name = "North Old Garden"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/maintenance/kitchen
	name = "Old Restaurant"
	icon_state = "kitchen"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

//Toxins

/area/toxins
	sound_environment = SOUND_AREA_STANDARD_STATION
/area/toxins/lab
	name = "Research and Development"
	icon_state = "toxlab"

/area/toxins/hallway
	name = "Research Lab"
	icon_state = "toxlab"

/area/toxins/rdoffice
	name = "Research Director's Office"
	icon_state = "head_quarters"

/area/toxins/supermatter
	name = "Supermatter Lab"
	icon_state = "toxlab"

/area/toxins/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxmix"
	xenobiology_compatible = TRUE

/area/toxins/xenobiology/xenoflora_storage
	name = "Xenoflora Storage"
	icon_state = "toxlab"

/area/toxins/xenobiology/xenoflora
	name = "Xenoflora Lab"
	icon_state = "toxlab"

/area/toxins/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"

/area/toxins/test_area
	name = "Toxins Test Area"
	icon_state = "toxtest"
	valid_territory = FALSE

/area/toxins/mixing
	name = "Toxins Mixing Room"
	icon_state = "toxmix"

/area/toxins/launch
	name = "Toxins Launch Room"
	icon_state = "toxlaunch"

/area/toxins/misc_lab
	name = "Research Testing Lab"
	icon_state = "toxmisc"

/area/toxins/test_chamber
	name = "Research Testing Chamber"
	icon_state = "toxtest"

/area/toxins/server
	name = "Server Room"
	icon_state = "server"

/area/toxins/server_coldroom
	name = "Server Coldroom"
	icon_state = "servercold"

/area/toxins/explab
	name = "Experimentation Lab"
	icon_state = "toxmisc"

/area/toxins/sm_test_chamber
	name = "Supermatter Testing Lab"
	icon_state = "toxtest"

//Storage

/area/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/storage/auxillary
	name = "Auxillary Storage"
	icon_state = "auxstorage"

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambientsounds = HIGHSEC_SOUNDS

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"
	ambientsounds = HIGHSEC_SOUNDS

/area/storage/emergency
	name = "East Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "West Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/office
	name = "Office Supplies"
	icon_state = "office_supplies"

// ENGIE OUTPOST

/area/engiestation
	name = "Engineering Outpost"
	icon_state = "construction"
	has_gravity = STANDARD_GRAVITY

/area/engiestation/solars
	name = "Engineering Outpost Solars"
	icon_state = "panelsP"

//DJSTATION

/area/djstation
	name = "Ruskie DJ Station"
	icon_state = "DJ"
	there_can_be_many = TRUE
	has_gravity = STANDARD_GRAVITY

/area/djstation/solars
	name = "Ruskie DJ Station Solars"
	icon_state = "DJ"

//DERELICT

/area/derelict
	name = "Derelict Station"
	icon_state = "storage"
	has_gravity = STANDARD_GRAVITY

/area/derelict/hallway/primary
	name = "Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "Derelict Arrival Centre"
	icon_state = "yellow"

/area/derelict/church
	name = "Derelict Church"
	icon_state = "chapel"

/area/derelict/common
	name = "Derelict Common Area"
	icon_state = "crew_quarters"

/area/derelict/asteroidbelt
	name = "Derelict Asteroids"
	icon_state = "mining"
	requires_power = FALSE
	has_gravity = FALSE

/area/derelict/med
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/garden
	name = "Derelict Hydroponics"
	icon_state = "hydro"

/area/derelict/dining
	name = "Derelict Dining room"
	icon_state = "kitchen"

/area/derelict/dock
	name = "Derelict Docking Area"
	icon_state = "ntrep"

/area/derelict/security
	name = "Derelict Security Area"
	icon_state = "blue"

/area/derelict/rnd
	name = "Derelict Research Area"
	icon_state = "purple"

/area/derelict/engineer_area
	name = "Derelict Engineering Area"
	icon_state = "engine_control"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "Derelict Control Room"
	icon_state = "bridge"

/area/derelict/secret
	name = "Derelict Secret Room"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "Derelict Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "Derelict Solar Control"
	icon_state = "engine"

/area/derelict/se_solar
	name = "South East Solars"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "Derelict Morgue"
	icon_state = "morgue"
	is_haunted = TRUE

/area/derelict/medical/chapel
	name = "Derelict Chapel"
	icon_state = "chapel"
	is_haunted = TRUE

/area/derelict/teleporter
	name = "Derelict Teleporter"
	icon_state = "teleporter"
	there_can_be_many = TRUE

/area/derelict/annex
	name = "Derelict Annex"
	icon_state = "eva"

/area/shuttle/derelict/ship/start
	name = "Abandoned Ship"
	icon_state = "yellow"

/area/shuttle/derelict/ship/transit
	name = "Abandoned Ship"
	icon_state = "yellow"

/area/shuttle/derelict/ship/engipost
	name = "Engineering Outpost"
	icon_state = "yellow"

/area/shuttle/derelict/ship/station
	name = "North of SS13"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "Derelict East Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "Derelict South Solar Array"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "Derelict Singularity Engine"
	icon_state = "engine"

/area/derelict/gravity_generator
	name = "Derelict Gravity Generator Room"
	icon_state = "red"

/area/derelict/atmospherics
	name = "Derelict Atmospherics"
	icon_state = "red"

//Construction

/area/construction
	name = "Construction Area"
	icon_state = "yellow"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/mining_construction
	name = "Auxillary Base Construction"
	icon_state = "yellow"

/area/construction/supplyshuttle
	name = "Supply Shuttle"
	icon_state = "yellow"

/area/construction/quarters
	name = "Engineer's Quarters"
	icon_state = "yellow"

/area/construction/qmaint
	name = "Maintenance"
	icon_state = "yellow"

/area/construction/hallway
	name = "Hallway"
	icon_state = "yellow"

/area/construction/solars
	name = "Solar Panels"
	icon_state = "yellow"

/area/construction/solarscontrol
	name = "Solar Panel Control"
	icon_state = "yellow"

/area/construction/Storage
	name = "Construction Site Storage"
	icon_state = "yellow"


//GAYBAR
/area/secret/gaybar
	name = "Dance Bar"
	icon_state = "dancebar"


//Traitor Station
/area/traitor
	name = "Syndicate Base"
	icon_state = "syndie_hall"
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY

/area/traitor/rnd
	name = "Syndicate Research and Development"
	icon_state = "syndie_rnd"

/area/traitor/chem
	name = "Syndicate Chemistry"
	icon_state = "syndie_chem"

/area/traitor/tox
	name = "Syndicate Toxins"
	icon_state = "syndie_tox"

/area/traitor/atmos
	name = "Syndicate Atmos"
	icon_state = "syndie_atmo"

/area/traitor/inter
	name = "Syndicate Interrogation"
	icon_state = "syndie_inter"

/area/traitor/radio
	name = "Syndicate Eavesdropping Booth"
	icon_state = "syndie_radio"

/area/traitor/surgery
	name = "Syndicate Surgery Theatre"
	icon_state = "syndie_surgery"

/area/traitor/hall
	name = "Syndicate Station"
	icon_state = "syndie_hall"

/area/traitor/kitchen
	name = "Syndicate Kitchen"
	icon_state = "syndie_kitchen"

/area/traitor/empty
	name = "Syndicate Project Room"
	icon_state = "syndie_empty"


//AI
/area/turret_protected/
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/aisat
	name = "AI Satellite Hallway"
	icon_state = "yellow"

/area/aisat/aihallway
	name = "AI Satellite Exterior Hallway"
	icon_state = "yellow"

/area/aisat/entrance
	name = "AI Satellite Entrance"
	icon_state = "ai_foyer"

/area/aisat/maintenance
	name = "AI Satellite Service"
	icon_state = "storage"

/area/aisat/atmospherics
	name = "AI Satellite Atmospherics"
	icon_state = "storage"

/area/turret_protected/aisat_interior
	name = "AI Satellite Antechamber"
	icon_state = "ai"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/turret_protected/aisat_interior/secondary
	name = "AI Satellite Secondary Antechamber"

//Misc

/area/wreck/ai
	name = "AI Chamber"
	icon_state = "ai"

/area/wreck/main
	name = "Wreck"
	icon_state = "storage"

/area/wreck/engineering
	name = "Power Room"
	icon_state = "engine"

/area/wreck/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/generic
	name = "Unknown"
	icon_state = "storage"



// Telecommunications Satellite

/area/tcommsat
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')

/area/tcommsat/chamber
	name = "Telecoms Central Compartment"
	icon_state = "tcomms"

// These areas are needed for MetaStation's AI sat
/area/turret_protected/tcomsat
	name = "Telecoms Satellite"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomfoyer
	name = "Telecoms Foyer"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomwest
	name = "Telecoms West Wing"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/turret_protected/tcomeast
	name = "Telecoms East Wing"
	icon_state = "tcomms"
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')

/area/tcommsat/computer
	name = "Telecoms Control Room"
	icon_state = "tcomms"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/tcommsat/server
	name = "Telecoms Server Room"
	icon_state = "tcomms"

/area/tcommsat/lounge
	name = "Telecoms Lounge"
	icon_state = "tcomms"

/area/tcommsat/powercontrol
	name = "Telecoms Power Control"
	icon_state = "tcomms"

// Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = AWAY_MISSION_SOUNDS
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/example
	name = "Strange Station"
	icon_state = "away"

/area/awaymission/desert
	name = "Sudden Drop"
	icon_state = "away"

/area/awaymission/beach
	name = "Beach"
	icon_state = "beach"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
	requires_power = FALSE
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/ambiodd.ogg', 'sound/ambience/ambinice.ogg')

/area/awaymission/undersea
	name = "Undersea"
	icon_state = "undersea"


// area for AWAY "moonoutpost19"
/area/moonoutpost19
	name = "moonoutpost"
	has_gravity = STANDARD_GRAVITY
	report_alerts = FALSE

/area/moonoutpost19/mo19arrivals
	name = "MO19 Arrivals"
	icon_state = "awaycontent1"

/area/moonoutpost19/mo19research
	name = "MO19 Research"
	icon_state = "awaycontent2"

/area/moonoutpost19/khonsu19
	name = "Khonsu 19"
	icon_state = "awaycontent3"
	always_unpowered = TRUE
	ambientsounds = list('sound/ambience/ambimine.ogg')
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE
	outdoors = TRUE

/area/moonoutpost19/syndicateoutpost
	name = "Syndicate Outpost"
	icon_state = "awaycontent4"

/area/moonoutpost19/hive
	name = "The Hive"
	icon_state = "awaycontent5"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE

/area/moonoutpost19/mo19utilityroom
	name = "MO19 Utility Room"
	icon_state = "awaycontent6"

//area for AWAY "aeterna13"
/area/ae13
	icon_state = "ae13"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	has_gravity = STANDARD_GRAVITY

/area/ae13/medbay
	name = "medbay"
	icon_state = "ae13_ship1"

/area/ae13/energy
	name = "energy"
	icon_state = "ae13_ship2"

/area/ae13/hall
	name = "hall"
	icon_state = "ae13_ship3"

/area/ae13/miner
	name = "miner"
	icon_state = "ae13_ship4"

/area/ae13/epicenter
	name = "epicenter"
	icon_state = "ae13_ship5"

/area/ae13/command
	name = "command"
	icon_state = "ae13_ship6"

/area/ae13/asteroid
	name = "asteroid"
	icon_state = "ae13_asteroid"


////////////////////////AWAY AREAS///////////////////////////////////

/area/awaycontent
	name = "space"
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY

/area/awaycontent/a1
	icon_state = "awaycontent1"

/area/awaycontent/a2
	icon_state = "awaycontent2"

/area/awaycontent/a3
	icon_state = "awaycontent3"

/area/awaycontent/a4
	icon_state = "awaycontent4"

/area/awaycontent/a5
	icon_state = "awaycontent5"

/area/awaycontent/a6
	icon_state = "awaycontent6"

/area/awaycontent/a7
	icon_state = "awaycontent7"

/area/awaycontent/a8
	icon_state = "awaycontent8"

/area/awaycontent/a9
	icon_state = "awaycontent9"

/area/awaycontent/a10
	icon_state = "awaycontent10"

/area/awaycontent/a11
	icon_state = "awaycontent11"

/area/awaycontent/a12
	icon_state = "awaycontent12"

/area/awaycontent/a13
	icon_state = "awaycontent13"

/area/awaycontent/a14
	icon_state = "awaycontent14"

/area/awaycontent/a15
	icon_state = "awaycontent15"

/area/awaycontent/a16
	icon_state = "awaycontent16"

/area/awaycontent/a17
	icon_state = "awaycontent17"

/area/awaycontent/a18
	icon_state = "awaycontent18"

/area/awaycontent/a19
	icon_state = "awaycontent19"

/area/awaycontent/a20
	icon_state = "awaycontent20"

/area/awaycontent/a21
	icon_state = "awaycontent21"

/area/awaycontent/a22
	icon_state = "awaycontent22"

/area/awaycontent/a23
	icon_state = "awaycontent23"

/area/awaycontent/a24
	icon_state = "awaycontent24"

/area/awaycontent/a25
	icon_state = "awaycontent25"

/area/awaycontent/a26
	icon_state = "awaycontent26"

/area/awaycontent/a27
	icon_state = "awaycontent27"

/area/awaycontent/a28
	icon_state = "awaycontent28"

/area/awaycontent/a29
	icon_state = "awaycontent29"

/area/awaycontent/a30
	icon_state = "awaycontent30"

/////////////////////////////////////////////////////////////////////
/*
 Lists of areas to be used with is_type_in_list.
 Used in gamemodes code at the moment. --rastaf0
*/

// CENTCOM
GLOBAL_LIST_INIT(centcom_areas, list(
	/area/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod5/centcom,
	/area/shuttle/transport1,
	/area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
))


//// Special event areas

/area/special_event
	name = "Special event area"
	icon_state = "unknown"
	requires_power = TRUE
	static_lighting = TRUE
	report_alerts = FALSE
	has_gravity = STANDARD_GRAVITY

/area/special_event/alpha
	name = "Special event area Alpha"
	icon_state = "away1"

/area/special_event/beta
	name = "Special event area Beta"
	icon_state = "away2"

/area/special_event/gamma
	name = "Special event area Gamma"
	icon_state = "away3"

/area/special_event/delta
	name = "Special event area Delta"
	icon_state = "away4"

/area/special_event/epsilon
	name = "Special event area Epsilon"
	icon_state = "away5"

//space area
/area/ruin/space/bubblegum_arena
	name = "Bubblegum Arena"


/area/ruin/USSP_SpaceBanya
	name = "Space_abandoned_banya"
	icon_state = "barstation"

//pirate base
/area/ruin/space/pirate_base
	name = "pirates base "
	icon_state = "unknown"

/area/ruin/space/pirate_base/arrivals
	name = "Unknown Arrivals"
	icon_state = "awaycontent1"

/area/ruin/space/pirate_base/atrium
	name = "Prison Atrium"
	icon_state = "awaycontent2"

/area/ruin/space/pirate_base/kitchen
	name = "Prison Kitchen"
	icon_state = "awaycontent3"

/area/ruin/space/pirate_base/mining
	name = "Prison Mining"
	icon_state = "awaycontent4"

/area/ruin/space/pirate_base/prison_maint
	name = "Prison Maintenance"
	icon_state = "awaycontent5"

/area/ruin/space/pirate_base/entertainment
	name = "Prison Entertainment"
	icon_state = "awaycontent6"

/area/ruin/space/pirate_base/security_atrium
	name = "Security Atrium"
	icon_state = "awaycontent7"

/area/ruin/space/pirate_base/security_maint
	name = "Technical Security zone"
	icon_state = "awaycontent8"

/area/ruin/space/pirate_base/security_medical
	name = "Medical and Storage"
	icon_state = "awaycontent9"

/area/ruin/space/pirate_base/observ
	name = "Observation Point"
	icon_state = "awaycontent10"

/area/ruin/space/pirate_base/lab_sec
	name = "Laboratory Security"
	icon_state = "awaycontent11"

/area/ruin/space/pirate_base/lab_hall
	name = "Laboratory Hallway"
	icon_state = "awaycontent12"

/area/ruin/space/pirate_base/laboratory
	name = "Laboratory"
	icon_state = "awaycontent13"

/area/ruin/space/pirate_base/lab_medical
	name = "Medical Bay"
	icon_state = "awaycontent14"

/area/ruin/space/pirate_base/lab_maint
	name = "Laboratory Maintenance"
	icon_state = "awaycontent15"

/area/ruin/space/pirate_base/atmos
	name = "Prison Atmos"
	icon_state = "awaycontent16"

/area/ruin/space/pirate_base/xeno_lab
	name = "Xeno Lab"
	icon_state = "awaycontent17"

/area/ruin/space/pirate_base/virus_lab
	name = "Virus TestLab"
	icon_state = "awaycontent18"

/area/ruin/space/pirate_base/virology
	name = "LP7 Virology"
	icon_state = "awaycontent19"

/area/ruin/space/pirate_base/prison_solar
	name = "Prison Solar"
	icon_state = "awaycontent20"

/area/ruin/space/pirate_base/lab_solar
	name = "Labor Solar"
	icon_state = "awaycontent21"

/area/ruin/space/pirate_base/telecomms
	name = "Telecomms"
	icon_state = "awaycontent22"

/area/ruin/space/pirate_base/black_market
	name = "Black Market"
	icon_state = "awaycontent23"
