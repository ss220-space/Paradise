/datum/event/dust
	var/qnty = 1

/datum/event/dust/setup()
	qnty = rand(1, 5)

/datum/event/dust/start()
	while(qnty-- > 0)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_meteors), 1, GLOB.meteors_space_dust)

