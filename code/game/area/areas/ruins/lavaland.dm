//Lavaland Ruins

/area/ruin/powered/beach
	name = "Beach Bar"
	icon_state = "dk_yellow"

/area/ruin/powered/clownplanet
	icon_state = "dk_yellow"
	ambientsounds = list(
		'sound/music/clown.ogg',
	)

/area/ruin/powered/animal_hospital
	icon_state = "dk_yellow"

/area/ruin/powered/snow_biodome
	icon_state = "dk_yellow"

/area/ruin/powered/snow_cabin
	icon_state = "bar"

/area/ruin/powered/gluttony
	icon_state = "dk_yellow"

/area/ruin/powered/golem_ship
	name = "Free Golem Ship"
	icon_state = "dk_yellow"

/area/ruin/powered/greed
	icon_state = "dk_yellow"

/area/ruin/unpowered/hierophant
	name = "Hierophant's Arena"
	icon_state = "dk_yellow"

/area/ruin/unpowered/drake
	name = "Ancient Temple"
	icon_state = "dk_yellow"

/area/ruin/powered/pride
	icon_state = "dk_yellow"

/area/ruin/powered/seedvault
	icon_state = "dk_yellow"

/area/ruin/powered/green_bio
	name = "Biodome"
	icon_state = "dk_yellow"

/area/ruin/powered/lavaland
	icon_state = "dk_yellow"

//Xeno Nest

/area/ruin/unpowered/xenonest
	name = "The Hive"
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	poweralm = FALSE
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'

//ash walker nest
/area/ruin/unpowered/ash_walkers
	icon_state = "red"
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'

// This area exists so that lavaland ruins dont overwrite the baseturfs on regular space ruins
/area/ruin/unpowered/misc_lavaruin

//'safe' caves
/area/ruin/unpowered/safe_cave
	icon_state = "dk_yellow"

// pirate ship
/area/ruin/powered/pirateship
	name = "Crashed Pirate Ship"
	icon_state = "green"
