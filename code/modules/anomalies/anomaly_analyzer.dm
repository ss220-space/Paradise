/obj/item/anomaly_analyzer
	name = "сканер аномалий"
	desc = "Продвинутое устройство предназначенное для сканирования аномалий. \
			Выводит достаточно полную информацию о сканируемой аномалии. \
			Может сканировать аномалии на расстоянии."
	ru_names = list(
		NOMINATIVE = "сканер аномалий", \
		GENITIVE = "сканера аномалий", \
		DATIVE = "сканеру аномалий", \
		ACCUSATIVE = "сканер аномалий", \
		INSTRUMENTAL = "сканером аномалий", \
		PREPOSITIONAL = "сканере аномалий"
	)
	icon = 'icons/obj/anomaly/anomaly_stuff.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "scanner_item"
	item_state = "anom_scanner"
	gender = MALE
	origin_tech = "programming=3;magnets=1"
	/// Title of scan window.
	var/scan_title = "ERROR_NO_DATA"
	/// Anomaly info in scan window.
	var/scan_data= list()

/obj/effect/anomaly/proc/get_data()
	var/list/scan_data = list()
	var/stre = strength
	var/stab = stability
	scan_data += "Сила аномалии: [stre > 70 ? span_warning("[stre]") : stre]"
	scan_data += "Стабильность аномалии: [stab < 30 ? span_warning("[stab]") : stab]"
	var/state
	if(stability < ANOMALY_GROW_STABILITY)
		state = span_warning("Рост")
	else if(stability > ANOMALY_DECREASE_STABILITY)
		state = "Уменьшение"
	else
		state = "Стабильное"

	scan_data += "Состояние аномалии: [state]"
	if(stability > ANOMALY_MOVE_MAX_STABILITY || world.time > move_moment)
		scan_data += span_info("Естественное перемещение прекращено.")

	scan_data += "<hr>Импульсы:\n"
	for(var/datum/anomaly_impulse/impulse as anything in impulses)
		var/blocked = world.time < move_impulse_moment && istype(impulse, /datum/anomaly_impulse/move) || stability > impulse.stability_high
		scan_data += "  [impulse.name]" + (blocked ? " ([span_green("заблокирован")]" : "")
		scan_data += "  &emsp;Описание: [impulse.desc]"
		scan_data += "  &emsp;Время между импульсами: [impulse.scale_by_strength(impulse.period_low, impulse.period_high) / 10]"
		scan_data += "  &emsp;Блокирующая стабильность: [impulse.stability_high]"

	return scan_data

/obj/item/anomaly_analyzer/proc/scan(obj/effect/anomaly/target)
	scan_title = "Сканирование [target.declent_ru(GENITIVE)]"
	scan_data = target.get_data()

/obj/item/anomaly_analyzer/proc/show(mob/user)
	var/datum/browser/popup = new(user, "anomalyscanner", scan_title, 500, 600)
	popup.set_content(chat_box_yellow("[jointext(scan_data, "<br>")]"))
	popup.open(no_focus = 1)

/obj/item/anomaly_analyzer/attack_self(mob/user)
	show(user)

/obj/item/anomaly_analyzer/afterattack(atom/target, mob/user, proximity, params, status)
	if(target == user || !isanomaly(target) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	scan(target)
	show(user)
