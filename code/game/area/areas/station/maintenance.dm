/area/station/maintenance
	name = "Generic Maintenance"
	ambience_index = AMBIENCE_MAINT
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE
	forced_ambience = TRUE
	ambient_buzz = 'sound/ambience/maintenance/source_corridor2.ogg'
	ambient_buzz_vol = 20
	///A list of rare sound effects to fuck with players. Yes, now it contains minecraft sounds again(for halloween)
	var/static/list/minecraft_cave_noises = list(
		'sound/ambience/halloween/Cave1.ogg',
		'sound/ambience/halloween/Cave2.ogg',
		'sound/ambience/halloween/Cave3.ogg',
		'sound/ambience/halloween/Cave4.ogg',
		'sound/ambience/halloween/Cave5.ogg',
		'sound/ambience/halloween/Cave6.ogg',
		'sound/ambience/halloween/Cave7.ogg',
		'sound/ambience/halloween/Cave8.ogg',
		'sound/ambience/halloween/Cave9.ogg',
		'sound/ambience/halloween/Cave10.ogg',
		'sound/ambience/halloween/Cave11.ogg',
		'sound/ambience/halloween/Cave12.ogg',
		'sound/ambience/halloween/Cave13.ogg',
		'sound/ambience/halloween/Cave14.ogg',
		'sound/ambience/halloween/Cave15.ogg',
		'sound/ambience/halloween/Cave16.ogg',
		'sound/ambience/halloween/Cave17.ogg.mp3',
		'sound/ambience/halloween/Cave18.ogg.mp3',
		'sound/ambience/halloween/Cave19.ogg',
	)

/area/station/maintenance/play_ambience(mob/target, sound/override_sound, volume = 50)
	if(!target.has_light_nearby())
		return ..(target, pick(minecraft_cave_noises))
	return ..()

/area/station/maintenance/ai
	name = "AI Maintenance"
	icon_state = "green"

/area/station/maintenance/fore //should be refactored
	name = "North Maintenance"
	icon_state = "fmaint"

/area/station/maintenance/fore2
	name = "North Secondary Maintenance"
	icon_state = "fmaint"

/area/station/maintenance/fpmaint
	name = "North-West Maintenance"
	icon_state = "fpmaint"

/area/station/maintenance/fsmaint
	name = "Dormitory Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/fsmaint2
	name = "Bar Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/fsmaint3
	name = "Cargo East Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/tourist
	name = "Tourist Area Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/asmaint
	name = "Medbay Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/asmaint2
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/asmaint3
	name = "Research Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/asmaint4
	name = "Virology Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/asmaint6
	name = "RnD Restroom Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/apmaint
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/station/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "central"

/area/station/maintenance/starboard
	name = "East Maintenance"
	icon_state = "smaint"

/area/station/maintenance/port
	name = "West Maintenance"
	icon_state = "pmaint"

/area/station/maintenance/brig
	name = "Brig Maintenance"
	icon_state = "pmaint"

/area/station/maintenance/perma
	name = "Prison Maintenance"
	icon_state = "green"

/area/station/maintenance/atmospherics
	name = "Atmospherics Maintenance"
	icon_state = "green"

/area/station/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"

/area/station/maintenance/turbine
	name = "Turbine"
	icon_state = "disposal"

/area/station/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/station/maintenance/genetics
	name = "Genetics Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/electrical
	name = "Electrical Maintenance"
	icon_state = "elec"

/area/station/maintenance/engineering
	name = "Engineering Maintenance"
	icon_state = "green"

/area/station/maintenance/bar
	name = "Maintenance Bar"
	icon_state = "oldbar"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/station/maintenance/electrical_shop
	name = "Electronics Den"
	icon_state = "elec"

/area/station/maintenance/gambling_den
	name = "Abandoned Fight Club"
	icon_state = "yellow"

/area/station/maintenance/casino
	name = "Abandoned Casino"
	icon_state = "yellow"

/area/station/maintenance/consarea
	name = "Alternate Construction Area"
	icon_state = "construction"

/area/station/maintenance/consarea_virology
	name = "Virology Maintenance Construction Area"
	icon_state = "yellow"

/area/station/maintenance/detectives_office
	name = "Abandoned Detective's Office"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
	)

/area/station/maintenance/library
	name = "Abandoned Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/maintenance/secpost
	name = "Abandoned Security Post"
	icon_state = "security"

/area/station/maintenance/banya
	name = "Abandoned Banya"
	icon_state = "yellow"

/area/station/maintenance/medroom
	name = "Abandoned Medical Emergency Ward"
	icon_state = "medbay3"

/area/station/maintenance/chapel
	name = "Abandoned Chapel"
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	is_haunted = TRUE

/area/station/maintenance/livingcomplex
	name = "Abandoned Living Complex Lobby"
	icon_state = "quart"

/area/station/maintenance/cafeteria
	name = "Abandoned Cafeteria"
	icon_state = "cafeteria"

/area/station/maintenance/xenozoo
	name = "Maintenance Xeno Zoo"
	icon_state = "yellow"

/area/station/maintenance/club
	name = "Old Poker Club"
	icon_state = "yellow"

/area/station/maintenance/backstage
	name = "Backstage"
	icon_state = "yellow"

/area/station/maintenance/trading
	name = "Trading area"
	icon_state = "yellow"

/area/station/maintenance/server
	name = "Abandoned Server Room"
	icon_state = "yellow"

/area/station/maintenance/abandonedwarehouse
	name = "Abandoned Warehouse"
	icon_state = "yellow"

/area/station/maintenance/abandonedoffices
	name = "Abandoned Offices"
	icon_state = "yellow"

/area/station/maintenance/abandonedclub
	name = "Abandoned Club"
	icon_state = "yellow"

/area/station/maintenance/abandonedhangar
	name = "Abandoned Hangar"
	icon_state = "yellow"

/area/station/maintenance/garden
	name = "Old Garden"
	icon_state = "hydro"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE

/area/station/maintenance/kitchen
	name = "Old Restaurant"
	icon_state = "kitchen"
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE
