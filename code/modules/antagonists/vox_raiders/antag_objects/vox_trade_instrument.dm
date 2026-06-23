/obj/item/hand_valuer
	name = "ручной оценщик"
	desc = "Приспособление воксов для оценки стоимости объекта."
	icon = 'icons/obj/machines/trader_machine.dmi'
	icon_state = "valuer"
	base_icon_state = "valuer"
	item_state = "camera_bug"
	var/datum/weakref/connected_trader

/obj/item/hand_valuer/update_icon_state()
	icon_state = "[base_icon_state]-on"

/obj/item/hand_valuer/examine(mob/user)
	. = ..()
	if(!isvox(user))
		. += span_notice("Выглядит непонятно. Как воксы этим пользуются?")

/obj/item/hand_valuer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()

	if(.)
		return

	if(!isvox(user))
		to_chat(user, span_warning("Кажется вы тыкаете не той стороной... Или [name] не работает? Да как воксы этим пользуются?!"))
		return

	if(!connected_trader)
		to_chat(user, span_warning("Невозможно получить сведения с оценочной базы данных. Подключите устройство."))
		return

	if(!isobj(interacting_with))
		to_chat(user, span_notice("Данный объект не поддается оценке."))
		return

	var/obj/machinery/vox_trader/trader = connected_trader.resolve()

	if(!trader)
		return

	if(!trader.check_usable(user))
		return

	var/value = trader.get_value(user, list(interacting_with), TRUE)
	to_chat(user, custom_boxed_message("blue_box", span_green("Ценность [interacting_with.declent_ru(GENITIVE)]: [value]")))
	return ITEM_INTERACT_SUCCESS

/obj/item/hand_valuer/proc/connect(mob/living/user, obj/machinery/vox_trader/input_trader)
	to_chat(user, span_green("Устройство [connected_trader ? "пере" : ""]инициализировано в системе."))
	playsound(src, 'sound/weapons/m79_unload.ogg', 50, 1)
	connected_trader = WEAKREF(input_trader)
	update_appearance(UPDATE_ICON_STATE)
