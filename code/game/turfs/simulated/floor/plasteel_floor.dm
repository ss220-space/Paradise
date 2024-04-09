/turf/simulated/floor/plasteel
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/simulated/floor/plasteel/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/simulated/floor/plasteel/burnt_states()
	return list("floorscorched1", "floorscorched2")

/turf/simulated/floor/plasteel/update_icon_state()
	if(!broken && !burnt)
		icon_state = icon_regular_floor
		dir = floor_regular_dir

/turf/simulated/floor/plasteel/airless
	name = "airless floor"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plasteel/airless/Initialize(mapload)
	. = ..()
	name = "floor"

/turf/simulated/floor/plasteel/airless/indestructible // For bomb testing range

/turf/simulated/floor/plasteel/airless/indestructible/ex_act(severity)
	return

/turf/simulated/floor/plasteel/goonplaque
	icon_state = "plaque"
	name = "Commemorative Plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."

//TODO: Make subtypes for all normal turf icons
/turf/simulated/floor/plasteel/white
	icon_state = "white"

/turf/simulated/floor/plasteel/white/side
	icon_state = "whitehall"

/turf/simulated/floor/plasteel/white/corner
	icon_state = "whitecorner"

/turf/simulated/floor/plasteel/white/square
	icon_state = "whitehall_square"

/turf/simulated/floor/plasteel/dark
	icon_state = "darkfull"

/turf/simulated/floor/plasteel/dark/telecomms
	nitrogen = 100
	oxygen = 0
	temperature = 80

/turf/simulated/floor/plasteel/freezer
	icon_state = "freezerfloor"

/turf/simulated/floor/plasteel/stairs
	icon_state = "stairs"
/turf/simulated/floor/plasteel/stairs/left
	icon_state = "stairs-l"
/turf/simulated/floor/plasteel/stairs/medium
	icon_state = "stairs-m"
/turf/simulated/floor/plasteel/stairs/right
	icon_state = "stairs-r"
/turf/simulated/floor/plasteel/stairs/old
	icon_state = "stairs-old"

/turf/simulated/floor/plasteel/stairs/ramp
	icon_state = "ramptop"

/turf/simulated/floor/plasteel/stairs/ramp/down
	icon_state = "rampbottom"

/turf/simulated/floor/plasteel/grimy
	icon_state = "grimy"

/turf/simulated/floor/plasteel/dirty
	icon_state = "floorgrime"

/turf/simulated/floor/plasteel/darkgrey
	icon_state = "darkgrey"

/turf/simulated/floor/plasteel/black
	icon_state = "dark"

/turf/simulated/floor/plasteel/black/marked
	icon_state = "darkmarked_square"

/turf/simulated/floor/plasteel/black/marked/left
	icon_state = "darkmarked_left"

/turf/simulated/floor/plasteel/black/marked/right
	icon_state = "darkmarked_right"

/turf/simulated/floor/plasteel/red_white
	icon_state = "stage_bleft"

/turf/simulated/floor/plasteel/red_white/white_red
	icon_state = "stage_left"
/turf/simulated/floor/plasteel/darkred
	icon_state = "darkredfull"

/turf/simulated/floor/plasteel/darkred/side
	icon_state = "darkred"

/turf/simulated/floor/plasteel/darkred/corner
	icon_state = "darkredcorner"

/turf/simulated/floor/plasteel/darkred/square
	icon_state = "darkredsquare"

/turf/simulated/floor/plasteel/darkred/line
	icon_state = "darkredalt"

/turf/simulated/floor/plasteel/darkred/line/corner
	icon_state = "darkredaltcorner"

/turf/simulated/floor/plasteel/darkred/line/square
	icon_state = "darkredaltsquare"

/turf/simulated/floor/plasteel/darkred/line/strip
	icon_state = "darkredaltstrip"

/turf/simulated/floor/plasteel/darkblue
	icon_state = "darkbluefull"

/turf/simulated/floor/plasteel/darkblue/side
	icon_state = "darkblue"

/turf/simulated/floor/plasteel/darkblue/corner
	icon_state = "darkbluecorner"

/turf/simulated/floor/plasteel/darkblue/square
	icon_state = "darkbluesquare"
