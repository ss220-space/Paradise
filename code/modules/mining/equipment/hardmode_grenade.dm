/obj/item/grenade/megafauna_hardmode
	name = "HRD-MDE Scanning Grenade"
	desc = "Передовая граната, выпускающая наномашины, которые проникают в ближайшую мегафауну. Это сильно разъярит её, но позволит НаноТрейзен полностью изучить её способности."
	icon_state = "enrager"
	item_state = "grenade"

/obj/item/grenade/megafauna_hardmode/get_ru_names()
	return list(
		NOMINATIVE = "сканирующая граната HRD-MDE",
		GENITIVE = "сканирующей гранаты HRD-MDE",
		DATIVE = "сканирующей гранате HRD-MDE",
		ACCUSATIVE = "сканирующую гранату HRD-MDE",
		INSTRUMENTAL = "сканирующей гранатой HRD-MDE",
		PREPOSITIONAL = "сканирующей гранате HRD-MDE"
	)

/obj/item/grenade/megafauna_hardmode/prime()
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, TRUE)
	for(var/mob/living/simple_animal/hostile/megafauna/M in range(7, src))
		M.enrage()
		visible_message(span_userdanger("[capitalize(M.declent_ru(NOMINATIVE))] начинает пробуждаться, когда наномашины проникают в него, он выглядит разъярённым!"))
	qdel(src)

/obj/item/paper/hardmode
	name = "Инструкции по использованию гранаты типа \"HRD-MDE\"" //no joke on russian, uh-oh
	icon_state = "paper"
	info = {"<b> Добро пожаловать в исследовательскую программу НТ \"HRD-MDE\""</b><br>
	<br>
	Данный инструктаж расскажет вам об основах использования экспериментальных научно-исследовательских гранатах.<br>
	<br>
	При использовании, данные гранаты выпускают облако практически безопасных* для человеческого организма наномашин, которые, при соприкосновении с фауной, позволяют пристально изучить строение их тела при жизни. Мы будем использовать эти данные для создания новых товаров широкого потребления, и для этого нам понадобится ваша помощь!<br>
	<br>
	Нам необходимо изучить фауну в своей полной, всеобъемлющей силе, пока в них находятся наномашины, поэтому вам необходимо будет с ними сразиться. Предупреждаем, что этот тип наномашин вызывает сильное раздражение у агрессию у фауны, а так же вводит в их тела боевой коктейль военного образца, заставляющий их тела работать на ранее невиданных мощностях."<br>
	<br>
	Мы работаем с очень огрниченным бюджетом, однако мы предоставим вам оплату за участие в программе: вы получите до 0.01% прибыли** от продажи всех товаров, полученных в результате этого исследования, а так же медали, демонстрирующие ваше стремление к идеалам НТ и продвижение науки вперед.
	<br><hr>
	<font size =\"1\"><i>*НТ не несет ответственности за возможные последствия при контакте нанитов с кожей.<br>
	<br>**95% средств, полученных вами за участие в эксперименте, будет изъято в счёт погашения долга за перелёт на шаттле Харон, проживание на станциях НТ и страхование жизни класса А-5.<br>
	<br>Учавствуя в данном эксперименте, вы отказываетесь от всех прав на получение компенсации в случае смерть на рабочем месте.</font></i>
"}

/obj/item/disk/fauna_research
	name = "empty HRD-MDE project disk"
	desc = "Диск, используемый проектом HRD-MDE. Кажется, пуст?"
	icon_state = "holodisk"
	var/obj/item/clothing/accessory/medal/output

/obj/item/disk/fauna_research/get_ru_names()
	return list(
		NOMINATIVE = "пустой диск проекта HRD-MDE",
		GENITIVE = "пустого диска проекта HRD-MDE",
		DATIVE = "пустому диску проекта HRD-MDE",
		ACCUSATIVE = "пустой диск проекта HRD-MDE",
		INSTRUMENTAL = "пустым диском проекта HRD-MDE",
		PREPOSITIONAL = "пустом диске проекта HRD-MDE"
	)

/obj/item/disk/fauna_research/Initialize(mapload)
	. = ..()
	for(var/obj/structure/closet/C in get_turf(src))
		forceMove(C)
		return

/obj/item/disk/fauna_research/blood_drunk_miner
	name = "blood drunk HRD-MDE project disk"
	desc = "Диск, используемый проектом HRD-MDE. Содержит данные о рывке и сопротивлении Кровожадного Шахтёра."
	output = /obj/item/clothing/accessory/medal/blood_drunk

/obj/item/disk/fauna_research/blood_drunk_miner/get_ru_names()
	return list(
		NOMINATIVE = "диск проекта HRD-MDE \"Кровожадный Шахтёр\"",
		GENITIVE = "диска проекта HRD-MDE \"Кровожадный Шахтёр\"",
		DATIVE = "диску проекта HRD-MDE \"Кровожадный Шахтёр\"",
		ACCUSATIVE = "диск проекта HRD-MDE \"Кровожадный Шахтёр\"",
		INSTRUMENTAL = "диском проекта HRD-MDE \"Кровожадный Шахтёр\"",
		PREPOSITIONAL = "диске проекта HRD-MDE \"Кровожадный Шахтёр\""
	)

/obj/item/disk/fauna_research/hierophant
	name = "Hierophant HRD-MDE project disk"
	desc = "Диск, используемый проектом HRD-MDE. Содержит данные о манипуляции энергией и материальном составе Иерофанта."
	output = /obj/item/clothing/accessory/medal/plasma/hierophant

/obj/item/disk/fauna_research/hierophant/get_ru_names()
	return list(
		NOMINATIVE = "диск проекта HRD-MDE \"Иерофант\"",
		GENITIVE = "диска проекта HRD-MDE \"Иерофант\"",
		DATIVE = "диску проекта HRD-MDE \"Иерофант\"",
		ACCUSATIVE = "диск проекта HRD-MDE \"Иерофант\"",
		INSTRUMENTAL = "диском проекта HRD-MDE \"Иерофант\"",
		PREPOSITIONAL = "диске проекта HRD-MDE \"Иерофант\""
	)

/obj/item/disk/fauna_research/ash_drake
	name = "ash drake HRD-MDE project disk"
	desc = "Диск, используемый проектом HRD-MDE. Содержит данные о методах создания огня и быстрой регенерации Пепельных Дрейков."
	output = /obj/item/clothing/accessory/medal/plasma/ash_drake

/obj/item/disk/fauna_research/ash_drake/get_ru_names()
	return list(
		NOMINATIVE = "диск проекта HRD-MDE \"Пепельный Дрейк\"",
		GENITIVE = "диска проекта HRD-MDE \"Пепельный Дрейк\"",
		DATIVE = "диску проекта HRD-MDE \"Пепельный Дрейк\"",
		ACCUSATIVE = "диск проекта HRD-MDE \"Пепельный Дрейк\"",
		INSTRUMENTAL = "диском проекта HRD-MDE \"Пепельный Дрейк\"",
		PREPOSITIONAL = "диске проекта HRD-MDE \"Пепельный Дрейк\""
	)

/obj/item/disk/fauna_research/vetus
	name = "Vetus Speculator HRD-MDE project disk"
	desc = "Диск, используемый проектом HRD-MDE. Содержит данные о манипуляции аномалиями и вычислительных процессах Ветус Спекулятора."
	output = /obj/item/clothing/accessory/medal/alloy/vetus

/obj/item/disk/fauna_research/vetus/get_ru_names()
	return list(
		NOMINATIVE = "диск проекта HRD-MDE \"Ветус Спекулятор\"",
		GENITIVE = "диска проекта HRD-MDE \"Ветус Спекулятор\"",
		DATIVE = "диску проекта HRD-MDE \"Ветус Спекулятор\"",
		ACCUSATIVE = "диск проекта HRD-MDE \"Ветус Спекулятор\"",
		INSTRUMENTAL = "диском проекта HRD-MDE \"Ветус Спекулятор\"",
		PREPOSITIONAL = "диске проекта HRD-MDE \"Ветус Спекулятор\""
	)

/obj/item/disk/fauna_research/colossus
	name = "colossus HRD-MDE project disk"
	desc = "Диск, используемый проектом HRD-MDE. Содержит данные о мощном голосе и А-поле Колоссов."
	output = /obj/item/clothing/accessory/medal/silver/colossus

/obj/item/disk/fauna_research/colossus/get_ru_names()
	return list(
		NOMINATIVE = "диск проекта HRD-MDE \"Колосс\"",
		GENITIVE = "диска проекта HRD-MDE \"Колосс\"",
		DATIVE = "диску проекта HRD-MDE \"Колосс\"",
		ACCUSATIVE = "диск проекта HRD-MDE \"Колосс\"",
		INSTRUMENTAL = "диском проекта HRD-MDE \"Колосс\"",
		PREPOSITIONAL = "диске проекта HRD-MDE \"Колосс\""
	)

/obj/item/disk/fauna_research/legion
	name = "Legion HRD-MDE project disk"
	desc = "Диск, используемый проектом HRD-MDE. Содержит данные о бесконечной регенерации и дезинтегрирующем лазере Легиона."
	output = /obj/item/clothing/accessory/medal/silver/legion

/obj/item/disk/fauna_research/legion/get_ru_names()
	return list(
		NOMINATIVE = "диск проекта HRD-MDE \"Легион\"",
		GENITIVE = "диска проекта HRD-MDE \"Легион\"",
		DATIVE = "диску проекта HRD-MDE \"Легион\"",
		ACCUSATIVE = "диск проекта HRD-MDE \"Легион\"",
		INSTRUMENTAL = "диском проекта HRD-MDE \"Легион\"",
		PREPOSITIONAL = "диске проекта HRD-MDE \"Легион\""
	)

/obj/item/disk/fauna_research/bubblegum
	name = "Bubblegum HRD-MDE project disk"
	desc = "Диск, используемый проектом HRD-MDE. Содержит данные о ████████████ и \[ЗАСЕКРЕЧЕНО\] Бубльгума."
	output = /obj/item/clothing/accessory/medal/gold/bubblegum

/obj/item/disk/fauna_research/bubblegum/get_ru_names()
	return list(
		NOMINATIVE = "диск проекта HRD-MDE \"Бубльгум\"",
		GENITIVE = "диска проекта HRD-MDE \"Бубльгум\"",
		DATIVE = "диску проекта HRD-MDE \"Бубльгум\"",
		ACCUSATIVE = "диск проекта HRD-MDE \"Бубльгум\"",
		INSTRUMENTAL = "диском проекта HRD-MDE \"Бубльгум\"",
		PREPOSITIONAL = "диске проекта HRD-MDE \"Бубльгум\""
	) //I hate this so much
