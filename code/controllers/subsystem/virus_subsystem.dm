SUBSYSTEM_DEF(virus)
	name = "virus dna"
	ss_id = "virus_process"

	priority = FIRE_PRIORITY_VIRUS
	init_order = INIT_ORDER_VIRUS_PROCESS
	runlevels = RUNLEVEL_GAME

	//var/list = list()

	//var/static/list/all_hex_codes = list()

/datum/controller/subsystem/virus/Initialize()
	//for(var/i; i <= 255; i++)
	//	all_hex_codes += i