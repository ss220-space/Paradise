/obj/machinery/computer/shuttle/labor
	name = "labor shuttle console"
	desc = "Используется для вызова и отправки шаттла каторги."
	circuit = /obj/item/circuitboard/labor_shuttle
	shuttleId = "laborcamp"
	possible_destinations = "laborcamp_home;laborcamp_away"
	req_access = list(ACCESS_BRIG)


/obj/machinery/computer/shuttle/labor/one_way
	name = "prisoner shuttle console"
	desc = "Консоль управления шаттлом в одну сторону, используемый для вызова шаттла на каторгу."
	possible_destinations = "laborcamp_away"
	circuit = /obj/item/circuitboard/labor_shuttle/one_way
	req_access = list( )
