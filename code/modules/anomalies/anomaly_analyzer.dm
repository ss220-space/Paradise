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
	. += "Сила аномалии: [target.strenght]"
	. += "Стабильность аномалии: [target.strenght]"
	if(target.stability < ANOMALY_GROW_STABILITY)
		. += "Состояние аномалии: " + span_warning("Рост")
	else if(target.stability > ANOMALY_DECREASE_STABILITY)
		. += "Состояние аномалии: Уменьшение"
	else
		. += "Состояние аномалии: Стабильное"

	. += "Импульсы:\n"
	for(var/datum/anomaly_impulse/impulse in target.impulses)
		. += "  [impulse.name]"
		. += "  &emsp;Описание: [impulse.desc]"
		. += "  &emsp;Время между импульсами: [impulse.scale_by_strenght(impulse.period_low, impulse.period_high) / 10]"
		. += "  &emsp;Блокируящая стабильность: [impulse.stability_high]"

/obj/item/anomaly_analyzer/proc/show(mob/user)
	var/datum/browser/popup = new(user, "anomalyscanner", scan_title, 400, 600)
	popup.open(no_focus = 1)

/obj/item/anomaly_analyzer/attack_self(mob/user)
	show(user)

/obj/item/anomaly_analyzer/afterattack(atom/target, mob/user, proximity, params, status)
	if(target == user || !isanomaly(target) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	scan(target)
	show(user)
