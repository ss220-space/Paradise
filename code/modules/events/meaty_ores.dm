/datum/event/dust/meaty


/datum/event/dust/meaty/setup()
	qnty = rand(45,125)


/datum/event/dust/meaty/announce()
	GLOB.event_announcement.Announce("Ожидайте важное сообщение от нашего сотрудника.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.", 'sound/announcer/meaty.ogg')



/datum/event/dust/meaty/start()
	while(qnty-- > 0)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/spawn_meteors, 1, GLOB.meteors_pigs)
		if(prob(10))
			sleep(rand(1 SECONDS, 1.5 SECONDS))

