/obj/item/anomaly_analyzer
	name = "сканер аномалий"
	ru_names = list(
		NOMINATIVE = "сканер аномалий", \
		GENITIVE = "сканера аномалий", \
		DATIVE = "сканеру аномалий", \
		ACCUSATIVE = "сканер аномалий", \
		INSTRUMENTAL = "сканером аномалий", \
		PREPOSITIONAL = "сканере аномалий"
	)
	desc = "Продвинутое устройство предназначенное для сканирования аномалий. \
			Выводит достаточно полную информацию о сканируемой аномалии. \
			Может сканировать аномалии на расстоянии."
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	item_state = "analyzer"
	gender = MALE
	origin_tech = "programming=3;magnets=1"
	/// Title of scan window.
	var/scan_title
	/// Anomaly info in scan window.
	var/scan_data

/obj/item/anomaly_analyzer/proc/scan(obj/effect/anomaly/target)
	scan_title = "Сканирование [target.declent_ru(GENITIVE)]"
	scan_data = list()
	scan_data += "Сила аномалии: [target.strenght]"
	scan_data += "Стабильность аномалии: [target.stability]"
	if(target.stability < ANOMALY_GROW_STABILITY)
		scan_data += "Состояние аномалии: " + span_warning("Рост")
	else if(target.stability > ANOMALY_DECREASE_STABILITY)
		scan_data += "Состояние аномалии: Уменьшение"
	else
		scan_data += "Состояние аномалии: Стабильное"
	scan_data += "<hr>Импульсы:\n"
	for(var/datum/anomaly_impulse/impulse in target.impulses)
		scan_data += "  [impulse.name]"
		scan_data += "  &emsp;Описание: [impulse.desc]"
		scan_data += "  &emsp;Время между импульсами: [impulse.scale_by_strenght(impulse.period_low, impulse.period_high) / 10]"
		scan_data += "  &emsp;Блокируящая стабильность: [impulse.stability_high]"

/obj/item/anomaly_analyzer/proc/show(mob/user)
	var/datum/browser/popup = new(user, "anomalyscanner", scan_title, 400, 600)
	popup.set_content(span_highlight("[jointext(scan_data, "<br>")]"))
	popup.open(no_focus = 1)

/obj/item/anomaly_analyzer/attack_self(mob/user)
	show(user)

/obj/item/anomaly_analyzer/afterattack(atom/target, mob/user, proximity, params, status)
	if(target == user || !isanomaly(target) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	scan(target)
	show(user)
