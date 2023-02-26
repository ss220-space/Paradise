/area/engine/engineering/poweralert(state, source)
	if(state != poweralm)
		source.investigate_log("has a power alarm!", INVESTIGATE_ENGINE)
	..()
