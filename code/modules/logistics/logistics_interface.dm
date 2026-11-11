/obj/item/logistics_interface
	name = "logistics interface board"
	desc = "Плата логистического интерфейса. Вставляется в совместимую машинерию с открытой панелью."
	icon = 'icons/obj/module.dmi'
	icon_state = "circuit_map"
	item_state = "electronic"
	origin_tech = "programming=2;engineering=2"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	var/mode = LOGISTICS_MODE_SEND

/obj/item/logistics_interface/get_ru_names()
	return alist(
		NOMINATIVE = "плата логистического интерфейса",
		GENITIVE = "платы логистического интерфейса",
		DATIVE = "плате логистического интерфейса",
		ACCUSATIVE = "плату логистического интерфейса",
		INSTRUMENTAL = "платой логистического интерфейса",
		PREPOSITIONAL = "плате логистического интерфейса",
	)

/obj/item/logistics_interface/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_NAME | UPDATE_DESC)

/obj/item/logistics_interface/update_name(updates = ALL)
	. = ..()
	name = (mode == LOGISTICS_MODE_SEND) ? "logistics interface board (export)" : "logistics interface board (import)"

/obj/item/logistics_interface/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)
	desc += (mode == LOGISTICS_MODE_SEND) ? " Сейчас настроена на отправку ресурсов." : " Сейчас настроена на приём ресурсов."

/obj/item/logistics_interface/examine(mob/user)
	. = ..()
	. += span_notice("Режим: [mode == LOGISTICS_MODE_SEND ? "отправка" : "приём"].")

/obj/item/logistics_interface/attack_self(mob/user)
	if(loc != user)
		return
	mode = (mode == LOGISTICS_MODE_SEND) ? LOGISTICS_MODE_RECEIVE : LOGISTICS_MODE_SEND
	update_appearance(UPDATE_NAME | UPDATE_DESC)
	to_chat(user, span_notice("Режим платы переключён на [mode == LOGISTICS_MODE_SEND ? "отправку" : "приём"]."))
	playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)

/obj/item/logistics_interface/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ismachinery(interacting_with))
		return NONE
	var/obj/machinery/machine = interacting_with
	if(!HAS_TRAIT(machine, TRAIT_LOGISTICS_COMPATIBLE))
		return NONE
	if(!machine.panel_open)
		balloon_alert(user, "откройте панель!")
		return ITEM_INTERACT_BLOCKING
	if(machine.GetComponent(/datum/component/logistics_interface))
		balloon_alert(user, "интерфейс уже установлен!")
		return ITEM_INTERACT_BLOCKING
	if(!user.drop_transfer_item_to_loc(src, machine))
		return ITEM_INTERACT_BLOCKING
	if(!machine.component_parts)
		machine.component_parts = list()
	machine.component_parts += src
	machine.AddComponent(/datum/component/logistics_interface, src)
	balloon_alert(user, "интерфейс установлен")
	playsound(machine, 'sound/items/deconstruct.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/proc/try_open_logistics(mob/user)
	var/datum/component/logistics_interface/interface = GetComponent(/datum/component/logistics_interface)
	if(!interface)
		return FALSE
	interface.ui_interact(user)
	return TRUE

/obj/machinery/proc/logistics_board_installed()
	return !!GetComponent(/datum/component/logistics_interface)

/obj/machinery/proc/install_logistics_interface(mode = LOGISTICS_MODE_SEND)
	if(!HAS_TRAIT(src, TRAIT_LOGISTICS_COMPATIBLE))
		return null
	if(GetComponent(/datum/component/logistics_interface))
		return null
	if(!component_parts)
		component_parts = list()
	var/obj/item/logistics_interface/board = new(src)
	board.mode = mode
	board.update_appearance(UPDATE_NAME | UPDATE_DESC)
	component_parts += board
	return AddComponent(/datum/component/logistics_interface, board)

/obj/machinery/proc/try_logistics_ui_act(action, mob/user)
	if(action != "open_logistics")
		return FALSE
	try_open_logistics(user)
	return TRUE
