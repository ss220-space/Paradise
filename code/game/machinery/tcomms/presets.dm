/*
	All machine presets go in here
*/

// STATION CORE //
/obj/machinery/tcomms/core/station
	network_id = "СТАНЦИЯ-ЯДРО"

// MINING RELAY //
/obj/machinery/tcomms/relay/mining
	network_id = "АВАНПОСТ-ЯДРО"
	autolink_id = "СТАНЦИЯ-ЯДРО"

// ENGINEERING RELAY //
/obj/machinery/tcomms/relay/engineering
	network_id = "ИНЖЕНЕРИЯ-РЕЛЕ"
	autolink_id = "СТАНЦИЯ-ЯДРО"
	active = FALSE

// RUSKIE RELAY //
/obj/machinery/tcomms/relay/ruskie
	network_id = "РУССКИЕ-ЯДРО"
	autolink_id = "СТАНЦИЯ-ЯДРО"
	active = FALSE
	hidden_link = TRUE

// CC RELAY //
/obj/machinery/tcomms/relay/cc
	network_id = "ЦЕНТКОМ-ЯДРО"
	autolink_id = "СТАНЦИЯ-ЯДРО"
	hidden_link = TRUE

// USSP CORE //
/obj/machinery/tcomms/core/ussp
	network_id = "СССП-ЯДРО"

// GORKY17 RELAY //
/obj/machinery/tcomms/relay/gorky17
	network_id = "ГОРКИ17-РЕЛЕ"
	autolink_id = "СССП-ЯДРО"
	active = TRUE
	hidden_link = TRUE
