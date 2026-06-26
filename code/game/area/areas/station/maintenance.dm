/area/maintenance
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

/area/maintenance/play_ambience(mob/target, sound/override_sound, volume)
	if(!target.has_light_nearby() && prob(0.5))
		return ..(target, pick(minecraft_cave_noises))
	return ..()

/area/maintenance/ai
	name = "AI Maintenance"
	icon_state = "green"

/area/maintenance/fore //should be refactored
	name = "North Maintenance"
	icon_state = "fmaint"

/area/maintenance/fore2
	name = "North Secondary Maintenance"
	icon_state = "fmaint"

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

/area/maintenance/asmaint6
	name = "RnD Restroom Maintenance"
	icon_state = "asmaint"

/area/maintenance/apmaint
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "central"

/area/maintenance/starboard
	name = "East Maintenance"
	icon_state = "smaint"

/area/maintenance/port
	name = "West Maintenance"
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
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
	)

/area/maintenance/library
	name = "Abandoned Library"
	icon_state = "library"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

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
	ambience_index = AMBIENCE_HOLY
	is_haunted = TRUE

/area/maintenance/livingcomplex
	name = "Abandoned Living Complex Lobby"
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

/area/maintenance/abandonedwarehouse
	name = "Abandoned Warehouse"
	icon_state = "yellow"

/area/maintenance/abandonedoffices
	name = "Abandoned Offices"
	icon_state = "yellow"

/area/maintenance/abandonedclub
	name = "Abandoned Club"
	icon_state = "yellow"

/area/maintenance/abandonedhangar
	name = "Abandoned Hangar"
	icon_state = "yellow"

/area/maintenance/garden
	name = "Old Garden"
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
