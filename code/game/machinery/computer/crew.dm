#define NAME "имя"
#define ASSIGNMENT "должность"
#define STAT "статус"
#define OXY "удушье"
#define TOX "токсины"
#define FIRE "ожоги"
#define BRUTE "травмы"
#define AREA "местоположение"
#define HEALTH "здоровье"

/obj/machinery/computer/crew
	name = "crew monitoring computer"
	desc = "Консоль, используемая для контроля активных датчиков состояния здоровья, встроенных в униформу большинства членов экипажа."
	icon_keyboard = "med_key"
	icon_screen = "crew"
	idle_power_usage = 250
	active_power_usage = 500
	light_color = LIGHT_COLOR_DARK_BLUE
	circuit = /obj/item/circuitboard/crew
	var/datum/ui_module/crew_monitor/crew_monitor

/obj/machinery/computer/crew/get_ru_names()
	return list(
		NOMINATIVE = "консоль наблюдения за экипажем",
		GENITIVE = "консоли наблюдения за экипажем",
		DATIVE = "консоли наблюдения за экипажем",
		ACCUSATIVE = "консоль наблюдения за экипажем",
		INSTRUMENTAL = "консолью наблюдения за экипажем",
		PREPOSITIONAL = "консоли наблюдения за экипажем",
	)

/obj/machinery/computer/crew/Initialize(mapload)
	. = ..()
	crew_monitor = new(src)

	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/medical_console_data,
	))

/obj/machinery/computer/crew/Destroy()
	QDEL_NULL(crew_monitor)
	return ..()

/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/crew/ui_interact(mob/user, datum/tgui/ui = null)
	crew_monitor.ui_interact(user, ui)

/obj/machinery/computer/crew/interact(mob/user)
	crew_monitor.ui_interact(user)

/obj/machinery/computer/crew/old_frame
	icon = 'icons/obj/machines/computer3.dmi'
	icon_screen = "med_oldframe"
	icon_state = "frame-med"
	icon_keyboard = "kb3"

/obj/item/circuit_component/medical_console_data
	display_name = "Данные мониторинга экипажа"
	desc = "Выводит информацию о медицинском состоянии людей на компьютер мониторинга экипажа, где ее затем можно отфильтровать с помощью компонента «Выбрать запрос»."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The records retrieved
	var/datum/port/output/records

	var/obj/machinery/computer/crew/attached_console

/obj/item/circuit_component/medical_console_data/populate_ports()
	records = add_output_port("Данные мониторинга экипажа", PORT_TYPE_TABLE)

/obj/item/circuit_component/medical_console_data/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/crew))
		attached_console = shell

/obj/item/circuit_component/medical_console_data/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/medical_console_data/get_ui_notices()
	. = ..()
	. += create_table_notices(list(
		NAME,
		ASSIGNMENT,
		STAT,
		OXY,
		TOX,
		FIRE,
		BRUTE,
		AREA,
		HEALTH,
	))


/obj/item/circuit_component/medical_console_data/input_received(datum/port/input/port)
	if(!attached_console || !GLOB.crew_repository)
		return

	var/turf/T = get_turf(attached_console)

	var/list/new_table = list()
	for(var/list/player_record as anything in GLOB.crew_repository.health_data(T))
		var/list/entry = list()
		entry[NAME] = player_record["name"]
		entry[ASSIGNMENT] = player_record["assignment"]
		entry[STAT] = player_record["stat"]
		entry[OXY] = player_record["oxy"]
		entry[TOX] = player_record["tox"]
		entry[FIRE] = player_record["fire"]
		entry[BRUTE] = player_record["brute"]
		entry[AREA] = player_record["area"]
		entry[HEALTH] = player_record["health"]
		new_table += list(entry)

	records.set_output(new_table)

#undef NAME
#undef ASSIGNMENT
#undef STAT
#undef OXY
#undef TOX
#undef FIRE
#undef BRUTE
#undef AREA
#undef HEALTH