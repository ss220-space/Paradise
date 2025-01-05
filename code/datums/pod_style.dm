/// Datum holding information about pod type visuals, VFX, name and description
/// These are not created anywhere and thus should not be assigned procs, only being used as data storage
/datum/pod_style
	/// Name that pods of this style will be named by default
	var/name = "supply pod"
	/// Name that is displayed to admins in pod config panel
	var/ui_name = "Стандартная"
	/// Description assigned to droppods of this style
	var/desc = "Капсула снабжения «Nanotrasen»."
	/// Determines if this pod can use animations/masking/overlays
	var/shape = POD_SHAPE_NORMAL
	/// Base icon state assigned to this pod
	var/icon_state = "pod"
	/// Whenever this pod should have a door overlay added to it. Uses [icon_state]_door sprite
	var/has_door = TRUE
	/// Decals added to this pod, if any
	var/decal_icon = "default"
	/// Color that this pod glows when landing
	var/glow_color = "yellow"
	/// Type of rubble that this pod creates upon landing
	var/rubble_type = RUBBLE_NORMAL
	/// ID for TGUI data
	var/id = "standard"

	var/list/ru_names = list(
		NOMINATIVE = "капсула снабжения",
		GENITIVE = "капсулы снабжения",
		DATIVE = "капсуле снабжения",
		ACCUSATIVE = "капсулу снабжения",
		INSTRUMENTAL = "капсулой снабжения",
		PREPOSITIONAL = "капсуле снабжения"
	)


/datum/pod_style/advanced
	name = "bluespace supply pod"
	ui_name = "Продвинутая"
	desc = "Блюспейс капсула снабжения Nanotrasen. После доставки телепортируется обратно."
	decal_icon = "bluespace"
	glow_color = "blue"
	id = "bluespace"
	ru_names = list(
		NOMINATIVE = "блюспейс капсула снабжения",
		GENITIVE = "блюспейс капсулы снабжения",
		DATIVE = "блюспейс капсуле снабжения",
		ACCUSATIVE = "блюспейс капсулу снабжения",
		INSTRUMENTAL = "блюспейс капсулой снабжения",
		PREPOSITIONAL = "блюспейс капсуле снабжения"
	)

/datum/pod_style/centcom
	name = "\improper CentCom supply pod"
	ui_name = "Nanotrasen"
	desc = "Капсула снабжения «Nanotrasen», отмеченный обозначениями Центрального командования. После доставки телепортируется обратно."
	decal_icon = "centcom"
	glow_color = "blue"
	id = "centcom"
	ru_names = list(
		NOMINATIVE = "капсула снабжения Центрального командования",
		GENITIVE = "капсулы снабжения Центрального командования",
		DATIVE = "капсуле снабжения Центрального командования",
		ACCUSATIVE = "капсулу снабжения Центрального командования",
		INSTRUMENTAL = "капсулой снабжения Центрального командования",
		PREPOSITIONAL = "капсуле снабжения Центрального командования"
	)

/datum/pod_style/syndicate
	name = "blood-red supply pod"
	ui_name = "Синдиката"
	desc = "Устрашающая капсула снабжения, покрытая кроваво-красными знаками Синдиката. Наверное, лучше держаться подальше."
	icon_state = "darkpod"
	decal_icon = "syndicate"
	glow_color = "red"
	id = "syndicate"
	ru_names = list(
		NOMINATIVE = "кроваво-красная капсула снабжения",
		GENITIVE = "кроваво-красной капсулы снабжения",
		DATIVE = "кроваво-красной капсуле снабжения",
		ACCUSATIVE = "кроваво-красную капсулу снабжения",
		INSTRUMENTAL = "кроваво-красной капсулой снабжения",
		PREPOSITIONAL = "кроваво-красной капсуле снабжения"
	)

/datum/pod_style/deathsquad
	name = "\improper Deathsquad drop pod"
	ui_name = "Отряда Смерти"
	desc = "Капсула Nanotrasen. На ней отмечена маркировка элитной ударной группы Nanotrasen."
	icon_state = "darkpod"
	decal_icon = "deathsquad"
	glow_color = "blue"
	id = "deathsquad"
	ru_names = list(
		NOMINATIVE = "капсула Отряда Смерти",
		GENITIVE = "капсулы Отряда Смерти",
		DATIVE = "капсуле Отряда Смерти",
		ACCUSATIVE = "капсулу Отряда Смерти",
		INSTRUMENTAL = "капсулой Отряда Смерти",
		PREPOSITIONAL = "капсуле Отряда Смерти"
	)

/datum/pod_style/cultist
	name = "bloody supply pod"
	ui_name = "Кльтистская"
	desc = "Капсула снабжения Nanotrasen, вся в царапинах, крови и странных рунах."
	decal_icon = "cultist"
	glow_color = "red"
	id = "cultist"
	ru_names = list(
		NOMINATIVE = "кровавая капсула снабжения",
		GENITIVE = "кровавой капсулы снабжения",
		DATIVE = "кровавой капсуле снабжения",
		ACCUSATIVE = "кровавую капсулу снабжения",
		INSTRUMENTAL = "кровавой капсулой снабжения",
		PREPOSITIONAL = "кровавой капсуле снабжения"
	)

/datum/pod_style/missile
	name = "cruise missile"
	ui_name = "Ракета"
	desc = "Огромная ракета, которая, похоже, не взорвалась полностью. Вероятно, она была запущена из какой-то далекой ракетной шахты в дальнем космосе. Судя по всему, сбоку имеется люк для вспомогательной полезной нагрузки, хотя открыть его вручную, скорее всего, невозможно."
	shape = POD_SHAPE_OTHER
	icon_state = "missile"
	has_door = FALSE
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_THIN
	id = "missile"
	ru_names = list(
		NOMINATIVE = "крылатая ракета",
		GENITIVE = "крылатой ракеты",
		DATIVE = "крылатой ракете",
		ACCUSATIVE = "крылатую ракету",
		INSTRUMENTAL = "крылатой ракете",
		PREPOSITIONAL = "крылатой ракетой"
	)

/datum/pod_style/missile/syndicate
	name = "\improper Syndicate cruise missile"
	ui_name = "Ракета Синдиката"
	desc = "Огромная кроваво-красная ракета, которая, похоже, не взорвалась полностью. Вероятно, она была запущена из какой-то ракетной шахты Синдиката в дальнем космосе. Судя по всему, сбоку имеется люк для вспомогательной полезной нагрузки, хотя открыть его вручную, скорее всего, невозможно."
	icon_state = "smissile"
	id = "syndie_missile"
	ru_names = list(
		NOMINATIVE = "крылатая ракета Синдиката",
		GENITIVE = "крылатой ракеты Синдиката",
		DATIVE = "крылатой ракете Синдиката",
		ACCUSATIVE = "крылатую ракету Синдиката",
		INSTRUMENTAL = "крылатой ракете Синдиката",
		PREPOSITIONAL = "крылатой ракетой Синдиката"
	)

/datum/pod_style/box
	name = "\improper Aussec supply crate"
	ui_name = "Ящик припасов"
	desc = "Невероятно прочный ящик с припасами, рассчитанный на то, чтобы выдержать возвращение на орбиту. Сбоку выгравирована надпись «Aussec Armory — 2532»."
	shape = POD_SHAPE_OTHER
	icon_state = "box"
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_WIDE
	id = "supply_box"
	ru_names = list(
		NOMINATIVE = "ящик с припасами Aussec",
		GENITIVE = "ящика с припасами Aussec",
		DATIVE = "ящику с припасами Aussec",
		ACCUSATIVE = "ящик с припасами Aussec",
		INSTRUMENTAL = "ящиком с припасами Aussec",
		PREPOSITIONAL = "ящике с припасами Aussec"
	)

/datum/pod_style/clown
	name = "\improper HONK pod"
	ui_name = "Капсула Клоунов"
	desc = "Яркая капсула снабжения. Вероятно, она отправлена Федерацией клоунов."
	icon_state = "clownpod"
	decal_icon = "clown"
	glow_color = "green"
	id = "clown"
	ru_names = list(
		NOMINATIVE = "ХОНК капсула",
		GENITIVE = "ХОНК капсулы",
		DATIVE = "ХОНК капсуле",
		ACCUSATIVE = "ХОНК капсулу",
		INSTRUMENTAL = "ХОНК капсулой",
		PREPOSITIONAL = "ХОНК капсуле"
	)

/datum/pod_style/orange
	name = "\improper Orange"
	ui_name = "Фрукт"
	desc = "Злой апельсин."
	shape = POD_SHAPE_OTHER
	icon_state = "orange"
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_WIDE
	id = "orange"
	ru_names = list(
		NOMINATIVE = "апельсин",
		GENITIVE = "апельсина",
		DATIVE = "апельсину",
		ACCUSATIVE = "апельсин",
		INSTRUMENTAL = "апельсином",
		PREPOSITIONAL = "апельсине"
	)

/datum/pod_style/invisible
	name =  "\improper S.T.E.A.L.T.H. pod MKVII"
	ui_name = "Невидимый"
	desc = "Капсула снабжения, которая при нормальных обстоятельствах совершенно невидима для обычных методов обнаружения. Как ты вообще её видишь?"
	shape = POD_SHAPE_OTHER
	has_door = FALSE
	icon_state = null
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_NONE
	id = "invisible"
	ru_names = list(
		NOMINATIVE = "капсула S.T.E.A.L.T.H. MKVII",
		GENITIVE = "капсулы S.T.E.A.L.T.H. MKVII",
		DATIVE = "капсуле S.T.E.A.L.T.H. MKVII",
		ACCUSATIVE = "капсулу S.T.E.A.L.T.H. MKVII",
		INSTRUMENTAL = "капсулой S.T.E.A.L.T.H. MKVII",
		PREPOSITIONAL = "капсуле S.T.E.A.L.T.H. MKVII"
	)

/datum/pod_style/gondola
	name = "gondola"
	ui_name = "Гандола"
	desc = "Бесшумный ходок. Кажется, это сотрудник агентства доставки."
	shape = POD_SHAPE_OTHER
	icon_state = "gondola"
	has_door = FALSE
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_NONE
	id = "gondola"
	ru_names = list(
		NOMINATIVE = "гандола",
		GENITIVE = "гандолы",
		DATIVE = "гандоле",
		ACCUSATIVE = "гандолу",
		INSTRUMENTAL = "гандолой",
		PREPOSITIONAL = "гандоле"
	)


/datum/pod_style/seethrough
	name = null
	ui_name = "Смотрящий насквозь"
	desc = null
	shape = POD_SHAPE_OTHER
	has_door = FALSE
	icon_state = null
	decal_icon = null
	glow_color = null
	rubble_type = RUBBLE_NONE
	id = "seethrough"
