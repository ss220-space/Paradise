/turf/unsimulated
	intact = 1
	name = "command"
	initial_gas_mix = DEFAULT_ATMOS

/turf/unsimulated/can_lay_cable()
	return 0

/turf/unsimulated/rpd_act()
	return

/turf/unsimulated/acid_act(acidpwr, acid_volume, acid_id)
	return 0

/turf/unsimulated/floor/plating/vox
	icon_state = "plating"
	name = "plating"
	initial_gas_mix = "n2=100"

/turf/unsimulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	initial_gas_mix = "TEMP=[T0C]"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/unsimulated/floor/plating/snow/concrete
	name = "concrete"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"

/turf/unsimulated/floor/plating/snow/ex_act(severity)
	return

/turf/unsimulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	initial_gas_mix = AIRLESS_ATMOS

/turf/unsimulated/floor/plating/airless/Initialize(mapload)
	. = ..()
	name = "plating"
