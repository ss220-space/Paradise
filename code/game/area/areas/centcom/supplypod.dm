/area/centcom/central_command_areas/supplypod/supplypod_temp_holding
	name = "Supplypod Shipping Lane"
	icon_state = "supplypod_flight"
	area_flags = UNIQUE_AREA

/area/centcom/central_command_areas/supplypod
	name = "Supplypod Facility"
	icon_state = "supplypod"

/area/centcom/central_command_areas/supplypod/pod_storage
	name = "Supplypod Storage"
	icon_state = "supplypod_holding"

/area/centcom/central_command_areas/supplypod/loading
	name = "Supplypod Loading Facility"
	icon_state = "supplypod_loading"
	var/loading_id = ""

/area/centcom/central_command_areas/supplypod/loading/Initialize(mapload)
	. = ..()
	if(!loading_id)
		CRASH("[type] created without a loading_id")
	if(GLOB.supplypod_loading_bays[loading_id])
		CRASH("Duplicate loading bay area: [type] ([loading_id])")
	GLOB.supplypod_loading_bays[loading_id] = src

/area/centcom/central_command_areas/supplypod/loading/one
	name = "Bay #1"
	loading_id = "1"

/area/centcom/central_command_areas/supplypod/loading/two
	name = "Bay #2"
	loading_id = "2"

/area/centcom/central_command_areas/supplypod/loading/three
	name = "Bay #3"
	loading_id = "3"

/area/centcom/central_command_areas/supplypod/loading/four
	name = "Bay #4"
	loading_id = "4"

/area/centcom/central_command_areas/supplypod/loading/ert
	name = "ERT Bay"
	loading_id = "5"
