/atom/movable/screen/alert/bitrunning
	name = "Сбой соединения"
	desc = "Что-то пошло не так. Сообщите об этом кодерам."
	timeout = 10 SECONDS

/atom/movable/screen/alert/bitrunning/crowbar
	name = "Взлом капсулы"
	desc = "Кто-то вскрывает вашу капсулу ломом. Ищите выход."

/atom/movable/screen/alert/bitrunning/integrity
	name = "Целостность нарушена"
	desc = "Капсула повреждена. Ищите выход."

/atom/movable/screen/alert/bitrunning/shutdown
	name = "Перезагрузка домена"
	desc = "Домен перезагружается. Ищите выход."

/atom/movable/screen/alert/bitrunning/threat
	name = "Обнаружена угроза"
	desc = "В потоке данных завелись помехи."

/atom/movable/screen/alert/bitrunning/breach
	name = "Взлом периметра"
	desc = "Враждебная сущность прорывается наружу. Ищите выход."

/atom/movable/screen/alert/bitrunning/forge_broken
	name = "Источник повреждён"
	desc = "Байткузница, которая держит вас в этом мире, вышла из строя."

/atom/movable/screen/alert/bitrunning/reset
	name = "Помечен на удаление"
	desc = "Сервер перезагружается. Впереди небытие."

/atom/movable/screen/alert/bitrunning/domain_complete
	name = "Домен пройден"
	desc = "Груз доставлен. Нажмите, чтобы безопасно отключиться."
	timeout = 20 SECONDS
	clickable_glow = TRUE
	click_master = FALSE

/atom/movable/screen/alert/bitrunning/domain_complete/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/mob/living/pilot = owner
	if(!isliving(pilot))
		return

	if(tgui_alert(pilot, "Отключиться от аватара?", "Сообщение сервера", list("Отключиться", "Остаться"), 10 SECONDS) != "Отключиться")
		return

	SEND_SIGNAL(pilot, COMSIG_BITRUNNER_ALERT_SEVER)
