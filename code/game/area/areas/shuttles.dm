/*!
 * These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
 * place to another. Look at escape shuttle for example.
 * All shuttles show now be under shuttle since we have smooth-wall code.
 */
/area/shuttle
	no_teleportlocs = TRUE
	requires_power = FALSE
	valid_territory = FALSE
	has_gravity = STANDARD_GRAVITY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	holomap_should_draw = FALSE

/area/shuttle/arrival
	name = "Arrival Shuttle"
	holomap_should_draw = TRUE
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/auxillary_base
	icon_state = "shuttle"
	area_flags = NONE

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

/area/shuttle/transport1
	icon_state = "shuttle"
	name = "Transport Shuttle"

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "Alien Shuttle Base"
	requires_power = 1
	area_flags = NONE

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "Alien Shuttle Mine"
	requires_power = 1
	area_flags = NONE

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
	area_flags = NONE

/area/shuttle/specops/centcom

/area/shuttle/specops/station
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH
	area_flags = NONE

/area/shuttle/syndicate_elite/mothership

/area/shuttle/syndicate_elite/station
	icon_state = "shuttlered2"

/area/shuttle/syndicate_sit
	name = "Syndicate SIT Shuttle"
	icon_state = "shuttlered"
	nad_allowed = TRUE
	parallax_movedir = SOUTH
	area_flags = NONE

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
	area_flags = NONE

/area/shuttle/administration/centcom
	name = "Nanotrasen Vessel Centcom"

/area/shuttle/administration/station
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "honk"
	area_flags = NONE

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

/area/shuttle/vox
	name = "Vox Skipjack"
	icon_state = "shuttle"
	area_flags = NONE
	parallax_movedir = SOUTH

/area/shuttle/vox/station
	icon_state = "yellow"

/area/shuttle/salvage
	name = "Salvage Ship"
	icon_state = "yellow"
	area_flags = NONE

/area/shuttle/salvage/start
	name = "Middle of Nowhere"

/area/shuttle/salvage/arrivals
	name = "Space Station Auxiliary Docking"

/area/shuttle/salvage/derelict
	name = "Derelict Station"

/area/shuttle/salvage/djstation
	name = "Ruskie DJ Station"

/area/shuttle/salvage/north
	name = "North of the Station"

/area/shuttle/salvage/east
	name = "East of the Station"

/area/shuttle/salvage/south
	name = "South of the Station"

/area/shuttle/salvage/commssat
	name = "The Communications Satellite"

/area/shuttle/salvage/mining
	name = "South-West of the Mining Asteroid"

/area/shuttle/salvage/abandoned_ship
	name = "Abandoned Ship"

/area/shuttle/salvage/clown_asteroid
	name = "Clown Asteroid"

/area/shuttle/salvage/trading_post
	name = "Trading Post"

/area/shuttle/salvage/transit
	name = "hyperspace"
	icon_state = "shuttle"

/area/shuttle/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	area_flags = NONE

/area/shuttle/ussp
	name = "USSP Shuttle"
	icon_state = "shuttle3"
	area_flags = NONE

/area/shuttle/spacebar
	name = "Space Bar Shuttle"
	icon_state = "shuttle3"
	area_flags = NONE

/area/shuttle/abandoned
	name = "Abandoned Ship"
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/syndicate
	name = "Syndicate Nuclear Team Shuttle"
	icon_state = "shuttle"
	nad_allowed = TRUE
	area_flags = NONE

/area/shuttle/trade
	name = "Trade Shuttle"
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/trade/sol
	name = "Sol Freighter"

/area/shuttle/freegolem
	name = "Free Golem Ship"
	icon_state = "purple"
	xenobiology_compatible = TRUE

/area/shuttle/pirate_corvette
	name = "Pirate Corvette"
	requires_power = TRUE
	icon_state = "shuttle"
	area_flags = NONE

/area/shuttle/transit
	name = "Hyperspace"
	desc = "Weeeeee"
	static_lighting = FALSE
	base_lighting_alpha = 255
