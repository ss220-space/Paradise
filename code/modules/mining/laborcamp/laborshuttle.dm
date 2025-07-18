/obj/machinery/computer/shuttle/labor
	name = "labor shuttle console"
	desc = "Используется для вызова и отправки шаттла каторги."
	ru_names = list(
		NOMINATIVE = "консоль управления шаттлом каторги",
		GENITIVE = "консоли управления шаттлом каторги",
		DATIVE = "консоли управления шаттлом каторги",
		ACCUSATIVE = "консоль управления шаттлом каторги",
		INSTRUMENTAL = "консолью управления шаттлом каторги",
		PREPOSITIONAL = "консоли управления шаттлом каторги"
	)
	circuit = /obj/item/circuitboard/labor_shuttle
	shuttleId = "laborcamp"
	possible_destinations = "laborcamp_home;laborcamp_away"
	lockdown_affected = TRUE
	req_access = list(ACCESS_BRIG)


/obj/machinery/computer/shuttle/labor/one_way
	name = "prisoner shuttle console"
	desc = "Консоль управления шаттлом в одну сторону, используемый для вызова шаттла на каторгу."
	ru_names = list(
		NOMINATIVE = "консоль управления заключёнными каторги",
		GENITIVE = "консоли управления заключёнными каторги",
		DATIVE = "консоли управления заключёнными каторги",
		ACCUSATIVE = "консоль управления заключёнными каторги",
		INSTRUMENTAL = "консолью управления заключёнными каторги",
		PREPOSITIONAL = "консоли управления заключёнными каторги"
	)
	possible_destinations = "laborcamp_away"
	circuit = /obj/item/circuitboard/labor_shuttle/one_way
	req_access = list( )
