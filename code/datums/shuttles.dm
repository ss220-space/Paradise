/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/map_files/shuttles/"
	var/suffix
	var/port_id
	var/shuttle_id

	var/description
	var/admin_notes

/datum/map_template/shuttle/New()
	if(port_id && suffix)
		shuttle_id = "[port_id]_[suffix]"
		mappath = "[prefix][shuttle_id].dmm"
	. = ..()

/datum/map_template/shuttle/emergency
	port_id = "emergency"
	name = "Base Shuttle Template (Emergency)"

/datum/map_template/shuttle/cargo
	port_id = "cargo"
	name = "Base Shuttle Template (Cargo)"

/datum/map_template/shuttle/ferry
	port_id = "ferry"
	name = "Base Shuttle Template (Ferry)"

/datum/map_template/shuttle/admin
	port_id = "admin"
	name = "Base Shuttle Template (Admin)"

// Shuttles start here:

/datum/map_template/shuttle/emergency/bar
	suffix = "bar"
	name = "Бар шаттл"
	description = "Маленький эвакуационный шаттл, включающий в себя: барную стойку, туалеты, мостик и бриг с медом. "

/datum/map_template/shuttle/emergency/clown
	suffix = "clown"
	name = "Клоунский шаттл"
	description = "Шаттл с клоунскими хлопушками."

/datum/map_template/shuttle/emergency/cramped
	suffix = "cramped"
	name = "Безопасное транспортное судно 5 (БТС5)"
	description = "Маленький грузовой шаттл, занимающейся перевозками особых грузов в секторе Эпсилон Лукусты."
	admin_notes = "Маршрутка."

/datum/map_template/shuttle/emergency/old
	suffix = "old"
	name = "Шаттл снятый с эксплуатации"
	description = "Старая модель эвакуационного шаттла, что видел лучшие времена."

/datum/map_template/shuttle/emergency/cyb
	suffix = "cyb"
	description = "Маленький эвакуационный шаттл, включающий в себя: барную стойку, туалеты, мостик и бриг с медом."
	name = "ТКН «Харон» (Кибериада)"
	admin_notes = "Вторые доки справа на севере."

/datum/map_template/shuttle/emergency/dept
	suffix = "dept"
	name = "ТКН «Харон» (Расширенный)"
	description = "Особенности: зоны для каждого отдела и небольшой бар."
	admin_notes = "Разработан для уменьшения хаоса. Каждый департамент имеет личный отсек на шаттле."

/datum/map_template/shuttle/emergency/military
	suffix = "mil"
	name = "ТКН «Ахерон» (Военный)"
	description = "Транспортный шаттл военной модели, предназначенный для эвакуации персонала из зон боевых действий."
	admin_notes = "Основное предназначение: эвак персонала во время биоугроз или когда всё очень печально. НЕ СПАВНИТЕ, ЕСЛИ В РАУНДЕ ЕСТЬ АНТАГ С УГОНОМ."

/* В текущих реалиях шаттл не работает, да и делать его рабочим смысла особо нет ибо это будет уже другой шаттл
/datum/map_template/shuttle/emergency/meta
	suffix = "meta"
	name = "emergency shuttle (Metastation)"
*/
/datum/map_template/shuttle/ferry/base
	suffix = "base"
	name = "ТКН «Ферри»"
	description = "Транспортное судно повышенной манёвренности, предназначенное для перевозки \
	особо важного персонала в пределах системы Эпсилон Лукусты. \
	В основном используется дипломатами, а также полевыми офицерами Центрального командования."

/datum/map_template/shuttle/ferry/meat
	suffix = "meat"
	name = "\"Мясной\" ТКН «Ферри»"
	description = "Привет! У нас есть все виды мяса. Мясо человеческого происхождения: \
		белые, черные, не в расистском смысле, просто темнокожие. \
		О, и мясо унати тоже, оно очень популярно. Определенно, \
		100% свежее, просто спросите у этого парня. *человек на мясорубке стонет* Видите? \
		Мясо, безусловно, высокого качества, в нем нет ничего плохого, ничего добавленного, \
		никаких зомбирующих реагентов!"

//Комплекс неполноferrности калеки

/datum/map_template/shuttle/ferry/cargo
	suffix = "cargo"
	name = "ТКН «Ферри» для доставки грузов"
	description = "Грузовой малый шаттл, снабженный всем по немногу."

/datum/map_template/shuttle/ferry/chem
	suffix = "chem"
	name = "ТКН «Ферри» с хим. лабой"
	description = "Грузовой малый шаттл, оснащенный хим. лабораторией на 2 рабочих места."

/datum/map_template/shuttle/ferry/clown
	suffix = "clown"
	name = "Клоунский ТКН «Ферри»"
	description = "Клоунская делегация! МЫ ИДЕМ К ВАМ, ХОНК!"

/datum/map_template/shuttle/ferry/cult
	suffix = "cult"
	name = "ТКН «Ферри-666»"
	description = "Малый шаттл делегации неизвестного культа."

/datum/map_template/shuttle/ferry/deepdarkdungeon
	suffix = "deepdarkdungeon"
	name = "ТКН «Ферри» ГАЧИ версия"
	description = "Дип Драк Фентези."

/datum/map_template/shuttle/ferry/doomsday
	suffix = "doomsday"
	name = "ТКН «Ферри» с мегафауной"
	description = "Особенный груз для зачистки.\
	После подготовки, НЕМЕДЛЕННО ОТПРАВИТЬ во избежания несчастных случаев. \
	Пассажиры крайне агрессивны."
	admin_notes = "Шаттл с мегафауной. Не советую спавнить! Не знаю, зачем он вообще сущетсвует."

/datum/map_template/shuttle/ferry/medical
	suffix = "medical"
	name = "ТКН «Ферри» (мед)"
	description = "Небольшой шаттл медицинской помощи, оснащенный базовым \
	комплектом и операционной."

/datum/map_template/shuttle/ferry/meteorshelp
	suffix = "meteorshelp"
	name = "ТКН «Ферри» (инж)"
	description = "Корабль, расчитанный на инженерную команду."

/datum/map_template/shuttle/ferry/mime
	suffix = "mime"
	name = "Мимский ТКН «Ферри»"
	description = "..."

/datum/map_template/shuttle/ferry/prisoner
	suffix = "prisoner"
	name = "ТКН «Ферри» (сб)"
	description = "Шаттл, оснащенный просторной камерой для транспортировки \
	особенных заключенных."

/datum/map_template/shuttle/ferry/slave
	suffix = "slave"
	name = "Рабовладельческий шаттл"
	description = "Шаттл, оснащенный шестью камерами для транспортировки рабов \
	С целью дальнейшей продажи."

/datum/map_template/shuttle/ferry/SMgen
	suffix = "SMgen"
	name = "Шаттл-двигатель"
	description = "Шаттл экстренной подпидки станции. \
	ВНИМАНИЕ! Содержит мобильный двигатель на СУПЕРМАТЕРИИ."

/datum/map_template/shuttle/ferry/theatrehelp
	suffix = "theatrehelp"
	name = "Театральный ТКН «Ферри»"
	description = "Делегация помощи в организации мероприятий."

/datum/map_template/shuttle/ferry/ussp
	suffix = "ussp"
	name = "Челнок СССП"
	description = "Делегационный челнок СССП, для дип. и не очень миссий."

/datum/map_template/shuttle/ferry/vip
	suffix = "vip"
	name = "VIP ТКН «Ферри»"
	description = "Шаттл для транспортировки VIP-персон."

/datum/map_template/shuttle/ferry/zoo
	suffix = "zoo"
	name = "ТКН «Ферри» с зоопарком"
	description = "Шаттл для транспортировки различных форм жизни."

/datum/map_template/shuttle/admin/hospital
	suffix = "hospital"
	name = "МКН «Асклепий»"
	description = "Экстренный корабль, снаряжённый медицинским инструментарием. Используется при чрезвычайных ситуациях."
	admin_notes = "Шаттл для щитспавна мед ОБР. ПОСЛЕ СПАВНА УДАЛИТЕ В КОНСОЛИ НАВИГАЦИИ НЕНУЖНЫЕ ЗОНЫ ДЛЯ ПРЫЖКА (jumpto_ports)!!! Корабль ШТУРМОВОЙ,\
	он может ПРОБИВАТЬ СТАНЦИЮ НАСКВОЗЬ"

/datum/map_template/shuttle/admin/admin
	suffix = "admin"
	name = "ТКН «Аргос»"
	description = "Многоцелевое транспортное судно. Несмотря на малые размеры, является полностью автономным судном, \
	позволяющим использовать его для дальних перелётов."
	admin_notes = "ПОСЛЕ СПАВНА УДАЛИТЕ В КОНСОЛИ НАВИГАЦИИ НЕНУЖНЫЕ ЗОНЫ ДЛЯ ПРЫЖКА (jumpto_ports)!!! Корабль ШТУРМОВОЙ, \
	он может ПРОБИВАТЬ СТАНЦИЮ НАСКВОЗЬ."

/datum/map_template/shuttle/admin/armory
	suffix = "armory"
	name = "ОКН «Спарта»"
	description = "Оборонный корабль исключительной мобильности, используется во время специальных операций."
	admin_notes = "Вообщем, этот шаттл задумывался как аналог нюкерского инфильтратора, но \
	только для ОБР от уровня ГАММА и ЭПСИЛОН. ПОСЛЕ СПАВНА УДАЛИТЕ В КОНСОЛИ НАВИГАЦИИ НЕНУЖНЫЕ ЗОНЫ ДЛЯ ПРЫЖКА (jumpto_ports)!!! Корабль ШТУРМОВОЙ, \
	он может ПРОБИВАТЬ СТАНЦИЮ НАСКВОЗЬ."

/datum/map_template/shuttle/admin/club
	suffix = "club"
	name = "ККН «Парнас»"
	description = "Коммерческий корабль \"Нанотрейзен\", направленный на получение прибыли при помощи сферы развлечений."
	admin_notes = "ПОСЛЕ СПАВНА УДАЛИТЕ В КОНСОЛИ НАВИГАЦИИ НЕНУЖНЫЕ ЗОНЫ ДЛЯ ПРЫЖКА (jumpto_ports)!!! Корабль ШТУРМОВОЙ, \
	он может ПРОБИВАТЬ СТАНЦИЮ НАСКВОЗЬ."

/datum/map_template/shuttle/admin/interview
	suffix = "interview"
	name = "АКН «Афина»"
	description = "Административный корабль \"Нанотрейзен\". Используется для проведения опросов и бесед."
	admin_notes = "ПОСЛЕ СПАВНА УДАЛИТЕ В КОНСОЛИ НАВИГАЦИИ НЕНУЖНЫЕ ЗОНЫ ДЛЯ ПРЫЖКА (jumpto_ports)!!! Корабль ШТУРМОВОЙ, \
	он может ПРОБИВАТЬ СТАНЦИЮ НАСКВОЗЬ."
