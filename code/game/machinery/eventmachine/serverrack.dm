/obj/machinery/eventmachine/serverrack
	name = "server rack"
	desc = "Серверная стойка с маркировкой Nanotrasen. Судя по всему, рабочая. И очень старая..."
	icon = 'icons/obj/eventicons/32x48_machinery.dmi'
	icon_state = "serverrack_on"
	density = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	anchored = TRUE

/obj/machinery/eventmachine/serverrack/get_ru_names()
	return alist(
		NOMINATIVE = "серверная стойка",
		GENITIVE = "серверной стойки",
		DATIVE = "серверной стойке",
		ACCUSATIVE = "серверную стойку",
		INSTRUMENTAL = "серверной стойкой",
		PREPOSITIONAL = "серверной стойке"
	)

/obj/machinery/eventmachine/serverrack/oscilograph
	name = "oscillating computer"
	desc = "Серверная стойка со встроенным осциллятором. Волны постоянно колеблются, отчего не ясно, для чего он вообще тут стоит."
	icon_state = "rack"

/obj/machinery/eventmachine/serverrack/oscilograph/get_ru_names()
	return alist(
		NOMINATIVE = "серверная стойка с осцилографом",
		GENITIVE = "серверной стойки с осцилографом",
		DATIVE = "серверной стойке с осцилографом",
		ACCUSATIVE = "серверную стойку с осцилографом",
		INSTRUMENTAL = "серверной стойкой с осцилографом",
		PREPOSITIONAL = "серверной стойке с осцилографом"
	)

/obj/machinery/eventmachine/serverrack/recorder
	name = "server recorder"
	desc = "Самописная стойка. Бобины крутятся, а вы слышите постоянные щелчки, по мере того, как они сами переставляют их."
	icon_state = "recorder_on"


/obj/machinery/eventmachine/serverrack/recorder/get_ru_names()
	return alist(
		NOMINATIVE = "самописная стойка",
		GENITIVE = "самописной стойки",
		DATIVE = "самописной стойке",
		ACCUSATIVE = "самописную стойку",
		INSTRUMENTAL = "самописной стойкой",
		PREPOSITIONAL = "самописной стойке"
	)

/obj/machinery/eventmachine/serverrack/substation
	name = "power substation"
	desc = "Энергоподстанция старого образца. Берёт 380, отдаёт 220, а на остальные гудит."
	icon_state = "substation_rust"


/obj/machinery/eventmachine/serverrack/substation/get_ru_names()
	return alist(
		NOMINATIVE = "электроподстанция",
		GENITIVE = "электроподстанции",
		DATIVE = "электроподстанции",
		ACCUSATIVE = "электроподстанцию",
		INSTRUMENTAL = "электроподстанцией",
		PREPOSITIONAL = "электроподстанции"
	)

/obj/machinery/eventmachine/serverrack/cynosure_core
	name = "cynosure"
	desc = "Ядро проекта Cynosure, официально закрытого Nanotrasen. От него исходит едва слышимый шёпот, словно оно пытается заговорить с вами."
	icon = 'icons/obj/eventicons/cynosure.dmi'
	icon_state = "cynosure"


/obj/machinery/eventmachine/serverrack/substation/get_ru_names()
	return alist(
		NOMINATIVE = "Ядро проекта Cynosure",
		GENITIVE = "Ядра проекта Cynosure",
		DATIVE = "Ядру проекта Cynosure",
		ACCUSATIVE = "Ядро проекта Cynosure",
		INSTRUMENTAL = "Ядром проекта Cynosure",
		PREPOSITIONAL = "Ядре проекта Cynosure"
	)

/obj/machinery/eventmachine/serverrack/cynosure_storage
	name = "cynosure storage"
	desc = "Огромный датабанк-хранилище проекта Cynosure. По официальным данным, именно с помощью данного устройства извлекали человеческую душу для использования при создании ОИИ."
	icon = 'icons/obj/eventicons/storage.dmi'
	icon_state = "storage_of_materials_active1"


/obj/machinery/eventmachine/serverrack/substation/get_ru_names()
	return alist(
		NOMINATIVE = "Хранилище души Cynosure",
		GENITIVE = "Хранилища души Cynosure",
		DATIVE = "Хранилищу души Cynosure",
		ACCUSATIVE = "Хранилище души Cynosure",
		INSTRUMENTAL = "Хранилищем души Cynosure",
		PREPOSITIONAL = "Хранилище души Cynosure"
	)

