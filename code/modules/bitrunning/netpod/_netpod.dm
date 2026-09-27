#define SCANNING_TOGGLE_COOLDOWN (0.5 SECONDS)

/obj/machinery/netpod
	name = "netpod"
	desc = "Капсула связи с нетверсом. Пучок кабелей соединяет спящего с виртуальным доменом."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "netpod_open_active"
	base_icon_state = "netpod"
	anchored = TRUE
	max_integrity = 300
	idle_power_usage = 100
	active_power_usage = 500
	var/mob/living/carbon/occupant
	var/state_open = TRUE
	var/connected = FALSE
	var/copy_body = FALSE
	var/datum/outfit/netsuit = /datum/outfit/bit_avatar
	var/datum/weakref/avatar_ref
	var/datum/weakref/server_ref
	COOLDOWN_DECLARE(scanning_cooldown)

/obj/machinery/netpod/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/netpod(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	component_parts += new /obj/item/stack/sheet/glass(null)
	find_server()
	register_context()
	RegisterSignal(src, COMSIG_OBJ_INTEGRITY_CHANGED, PROC_REF(on_integrity_changed))
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/netpod/Destroy()
	sever_connection()
	open_machine()
	server_ref = null
	avatar_ref = null
	return ..()

/obj/machinery/netpod/get_ru_names()
	return alist(
		NOMINATIVE = "нетпод",
		GENITIVE = "нетпода",
		DATIVE = "нетподу",
		ACCUSATIVE = "нетпод",
		INSTRUMENTAL = "нетподом",
		PREPOSITIONAL = "нетподе",
	)

/obj/machinery/netpod/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = copy_body ? "Отключить сканер" : "Включить сканер"
	if(isnull(held_item))
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER && isnull(occupant) && !state_open)
		context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Закрыть панель" : "Открыть панель"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = isnull(occupant) ? "Открыть крышку" : "Вскрыть"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/netpod/examine(mob/user)
	. = ..()
	if(isnull(server_ref?.resolve()))
		. += span_warning("Капсула ни с чем не соединена. Нетпод должен стоять не дальше четырёх плиток от сервера.")
		return

	if(isobserver(user))
		. += span_notice("Нажмите на капсулу, чтобы переместиться к её аватару.")
		return

	. += span_notice("Затащите себя в капсулу, чтобы установить связь.")
	. += span_notice("Капсула поддерживает тело в стазисе и понемногу лечит его.")
	. += span_notice("Сканер внешности [copy_body ? "включён: аватар будет копировать ваше тело" : "выключен: аватар получит случайное тело"]. Alt-клик переключает.")
	. += span_notice("Нажмите на открытую капсулу, чтобы выбрать облик снаряжения аватара.")
	. += span_warning("Её можно вскрыть ломом, но система безопасности предупредит спящего.")

	if(isnull(occupant))
		. += span_notice("Сейчас капсула пуста.")
		return

	. += span_notice("Внутри находится [occupant].")

/obj/machinery/netpod/update_icon_state()
	if(!is_operational())
		icon_state = base_icon_state
		return

	if(state_open)
		icon_state = "[base_icon_state]_open_active"
		return

	if(panel_open)
		icon_state = "[base_icon_state]_panel"
		return

	icon_state = "[base_icon_state]_closed[occupant ? "_active" : ""]"

/obj/machinery/netpod/mouse_drop_receive(atom/dropped, mob/user, params)
	if(!iscarbon(dropped) || dropped != user)
		return

	if(!state_open || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(!Adjacent(user) || !isturf(user.loc))
		return

	close_machine(user)

/obj/machinery/netpod/attack_hand(mob/user)
	if(..())
		return TRUE

	if(!state_open)
		if(user == occupant)
			container_resist_act(user)
		return TRUE

	ui_interact(user)
	return TRUE

/obj/machinery/netpod/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NetpodOutfits", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/netpod/ui_status(mob/user, datum/ui_state/state)
	if(panel_open || occupant)
		return UI_CLOSE

	return ..()

/obj/machinery/netpod/ui_data(mob/user)
	var/list/data = list()
	data["netsuit"] = "[netsuit]"
	return data

/obj/machinery/netpod/ui_static_data(mob/user)
	var/list/data = list()
	data["collections"] = get_outfit_collections()
	return data

/obj/machinery/netpod/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	if(action != "select_outfit")
		return FALSE

	var/datum/outfit/chosen = resolve_outfit(params["outfit"])
	if(isnull(chosen))
		return FALSE

	netsuit = chosen
	return TRUE

/obj/machinery/netpod/proc/get_outfit_collections()
	var/static/list/collections
	if(collections)
		return collections

	collections = list()
	collections += list(build_outfit_collection("Базовые", list(/datum/outfit/bit_avatar)))
	collections += list(build_outfit_collection("Должности", subtypesof(/datum/outfit/job)))
	return collections

/obj/machinery/netpod/proc/build_outfit_collection(identifier, list/outfit_paths)
	var/list/collection = list("name" = identifier, "outfits" = list())

	for(var/datum/outfit/outfit as anything in outfit_paths)
		var/outfit_name = initial(outfit.name)
		if(findtext(outfit_name, "(") || findtext(outfit_name, "-"))
			continue

		collection["outfits"] += list(list("path" = "[outfit]", "name" = outfit_name))

	return collection

/obj/machinery/netpod/proc/resolve_outfit(outfit_text)
	if(!ispath(text2path(outfit_text), /datum/outfit))
		return

	for(var/list/collection as anything in get_outfit_collections())
		for(var/list/entry as anything in collection["outfits"])
			if(entry["path"] == outfit_text)
				return text2path(outfit_text)

	message_admins("[key_name_admin(usr)] tried to select an unavailable netpod outfit: [outfit_text]")

/obj/machinery/netpod/attack_ghost(mob/dead/observer/user)
	var/mob/living/avatar = avatar_ref?.resolve()
	if(isnull(avatar))
		return ..()

	user.forceMove(get_turf(avatar))

/obj/machinery/netpod/container_resist_act(mob/living/user)
	user.visible_message(
		span_notice("[user] выбирается из [declent_ru(GENITIVE)]!"),
		span_notice("Вы выбираетесь из [declent_ru(GENITIVE)]."),
		span_notice("Вы слышите, как с шипением открывается какая-то машина."),
	)
	open_machine()

/obj/machinery/netpod/Exited(atom/movable/gone, direction)
	. = ..()
	if(!state_open && gone == occupant)
		open_machine()

/obj/machinery/netpod/relaymove(mob/living/user, direction)
	if(!state_open)
		container_resist_act(user)

/obj/machinery/netpod/power_change(forced = FALSE)
	..()
	if(is_operational())
		update_icon(UPDATE_ICON_STATE)
		return

	sever_connection()
	open_machine()

/obj/machinery/netpod/obj_break(damage_flag)
	. = ..()
	sever_connection()
	open_machine()

/obj/machinery/netpod/screwdriver_act(mob/living/user, obj/item/tool)
	if(occupant)
		balloon_alert(user, "капсула занята!")
		return ITEM_INTERACT_BLOCKING

	if(state_open)
		balloon_alert(user, "сначала закройте крышку!")
		return ITEM_INTERACT_BLOCKING

	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", "[base_icon_state]_closed", tool))
		update_icon(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/netpod/crowbar_act(mob/living/user, obj/item/tool)
	if(isnull(occupant))
		if(panel_open)
			return default_deconstruction_crowbar(user, tool)

		if(state_open)
			shut_pod()
		else
			open_machine()

		return ITEM_INTERACT_SUCCESS

	user.visible_message(
		span_danger("[user] начинает вскрывать [declent_ru(ACCUSATIVE)]!"),
		span_notice("Вы начинаете вскрывать [declent_ru(ACCUSATIVE)]."),
		span_danger("Вы слышите громкий скрежет металла."),
	)
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_CROWBAR_ALERT, user)

	if(tool.use_tool(src, user, 15 SECONDS, volume = 50))
		sever_connection()
		open_machine()

	return ITEM_INTERACT_SUCCESS

/obj/machinery/netpod/proc/shut_pod()
	state_open = FALSE
	set_density(TRUE)
	playsound(src, 'sound/machines/podclose.ogg', 60, TRUE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/netpod/proc/close_machine(mob/living/carbon/target)
	if(!state_open || panel_open || !is_operational() || !iscarbon(target))
		return

	target.forceMove(src)
	occupant = target
	state_open = FALSE
	set_density(TRUE)
	playsound(src, 'sound/machines/podclose.ogg', 60, TRUE)
	update_use_power(ACTIVE_POWER_USE)
	update_icon(UPDATE_ICON_STATE)

	INVOKE_ASYNC(src, PROC_REF(enter_matrix))

/obj/machinery/netpod/proc/open_machine()
	if(state_open)
		return

	state_open = TRUE
	set_density(FALSE)
	playsound(src, 'sound/machines/podopen.ogg', 60, TRUE)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_OPENED)

	var/mob/living/carbon/leaving = occupant
	occupant = null
	leaving?.forceMove(loc)

	update_use_power(IDLE_POWER_USE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/netpod/click_alt(mob/user)
	if(!COOLDOWN_FINISHED(src, scanning_cooldown))
		return CLICK_ACTION_BLOCKING

	COOLDOWN_START(src, scanning_cooldown, SCANNING_TOGGLE_COOLDOWN)
	copy_body = !copy_body
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	balloon_alert(user, "сканер [copy_body ? "включён" : "выключен"]")
	return CLICK_ACTION_SUCCESS

#undef SCANNING_TOGGLE_COOLDOWN
