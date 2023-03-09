/obj/machinery/syndie_packager
	name = "Syndicate redspace cargo packager"
	desc = "An advanced technology capable of packing inside itself many different types of cargo and transporting them from one such machine to the other in another part of the galaxy."
	icon = 'icons/obj/machines/quest_system/packager.dmi'
	icon_state = "syndie_scanner_open"
	anchored = 1
	opacity = 0
	density = 1
	layer = ABOVE_MOB_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 20000	//Подумать над логичной цифрой

//TODO:
/*
 * Возможность сборки и разборки устройства со своей платой и т.д.
 * Добавление платы в карго синдиката и/или в рнд в нелегал
 * Привязка машины к карго консоли и квест системе
 * Возможность сканировать все атомы кроме турфов в квадрате 3x3 перед собой
 * Отдельная проверка на стены в этой области 3x3 как на помеху(Убери стену, мешает работать)
 * Возможность пихать в себя и выплёвывать из себя обьекты в этой области
 * TGUI интерфейс показывающий содержимое и кнопку для начала сканирования и отправки
 * Код для вызова сканирования для проверки выполнения условий квеста
 * + отправка при успешном выполнении оных
 * Анимации для редспейс компрессии.
 */
