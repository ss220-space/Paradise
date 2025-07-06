
/obj/item/reagent_containers/food/drinks/mug
	name = "coffee mug"
	desc = "Кружка для горячих напитков."
	ru_names = list(
		NOMINATIVE = "кофейная кружка",
		GENITIVE = "кофейной кружки",
		DATIVE = "кофейной кружке",
		ACCUSATIVE = "кофейную кружку",
		INSTRUMENTAL = "кофейной кружкой",
		PREPOSITIONAL = "кофейной кружке"
	)
	icon = 'icons/obj/mugs.dmi'
	icon_state = "mug"
	var/novelty = FALSE
	var/preset = FALSE

/obj/item/reagent_containers/food/drinks/mug/novelty
	name = "novelty coffee mug"
	desc = "Забавная кружка для кофе и других горячих напитков!"
	ru_names = list(
		NOMINATIVE = "тематическая кофейная кружка",
		GENITIVE = "тематической кофейной кружки",
		DATIVE = "тематической кофейной кружке",
		ACCUSATIVE = "тематическую кофейную кружку",
		INSTRUMENTAL = "тематической кофейной кружкой",
		PREPOSITIONAL = "тематической кофейной кружке"
	)
	novelty = TRUE

/datum/novelty_mug
	var/name = "novelty coffee mug"
	var/description = "Забавная кружка для кофе и других горячих напитков!"
	var/ru_names = list()
	var/state = "mug"

/datum/novelty_mug/peace
	name = "peaceful mug"
	description = "Она такая... спокойная, чувак."
	ru_names = list(
		NOMINATIVE = "умиротворяющая кружка",
		GENITIVE = "умиротворяющей кружки",
		DATIVE = "умиротворяющей кружке",
		ACCUSATIVE = "умиротворяющую кружку",
		INSTRUMENTAL = "умиротворяющей кружкой",
		PREPOSITIONAL = "умиротворяющей кружке"
	)
	state = "mug_peace"

/datum/novelty_mug/fire
	name = "fire mug"
	description = "Осторожно: содержимое и дизайн могут быть очень горячими."
	ru_names = list(
		NOMINATIVE = "огненная кружка",
		GENITIVE = "огненной кружки",
		DATIVE = "огненной кружке",
		ACCUSATIVE = "огненную кружку",
		INSTRUMENTAL = "огненной кружкой",
		PREPOSITIONAL = "огненной кружке"
	)
	state = "mug_fire"

/datum/novelty_mug/best
	name = "best mug"
	description = "Согласно указу этой кружки, вы – лучший!"
	ru_names = list(
		NOMINATIVE = "кружка \"Лучший\"",
		GENITIVE = "кружки \"Лучший\"",
		DATIVE = "кружке \"Лучший\"",
		ACCUSATIVE = "кружку \"Лучший\"",
		INSTRUMENTAL = "кружкой \"Лучший\"",
		PREPOSITIONAL = "кружке \"Лучший\""
	)
	state = "mug_best"

/datum/novelty_mug/best/New()
	var/locale = pick("в комнате", "в отделе", "на станции", "на планете", "в сектора", "в системе", "в галактике", "во вселенной", "в мультивселенной", "в НаноТрейзен", "в синдикате")
	var/what = pick("член экипажа", "космонавт", "сотрудник", "кофеман", "доктор", "учёный", "инженер", "офицер", "гражданский", "капитан", "агент", "шахтёр")
	name = "\"[locale] Best [what]\" mug"
	ru_names = list(
		NOMINATIVE = "кружка \"Лучший [what] [locale]\"",
		GENITIVE = "кружки \"Лучший [what] [locale]\"",
		DATIVE = "кружке \"Лучший [what] [locale]\"",
		ACCUSATIVE = "кружку \"Лучший [what] [locale]\"",
		INSTRUMENTAL = "кружкой \"Лучший [what] [locale]\"",
		PREPOSITIONAL = "кружке \"Лучший [what] [locale]\""
	)

/datum/novelty_mug/worst
	name = "worst mug"
	description = "Согласно указу этой кружки, вы – худший!"
	ru_names = list(
		NOMINATIVE = "кружка \"Худший\"",
		GENITIVE = "кружки \"Худший\"",
		DATIVE = "кружке \"Худший\"",
		ACCUSATIVE = "кружку \"Худший\"",
		INSTRUMENTAL = "кружкой \"Худший\"",
		PREPOSITIONAL = "кружке \"Худший\""
	)
	state = "mug_worst"

/datum/novelty_mug/worst/New()
	var/locale = pick("в комнате", "в отделе", "на станции", "на планете", "в сектора", "в системе", "в галактике", "во вселенной", "в мультивселенной", "в НаноТрейзен", "в синдикате")
	var/what = pick("член экипажа", "космонавт", "сотрудник", "кофеман", "доктор", "учёный", "инженер", "офицер", "гражданский", "капитан", "агент", "шахтёр")
	name = "\"[locale] Worst [what]\" mug"
	ru_names = list(
		NOMINATIVE = "кружка \"Худший [what] [locale]\"",
		GENITIVE = "кружки \"Худший [what] [locale]\"",
		DATIVE = "кружке \"Худший [what] [locale]\"",
		ACCUSATIVE = "кружку \"Худший [what] [locale]\"",
		INSTRUMENTAL = "кружкой \"Худший [what] [locale]\"",
		PREPOSITIONAL = "кружке \"Худший [what] [locale]\""
	)

/datum/novelty_mug/insult
	name = "insulting coffee mug"
	description = "Как грубо!"
	ru_names = list(
		NOMINATIVE = "оскорбительная кофейная кружка",
		GENITIVE = "оскорбительной кофейной кружки",
		DATIVE = "оскорбительной кофейной кружке",
		ACCUSATIVE = "оскорбительную кофейную кружку",
		INSTRUMENTAL = "оскорбительной кофейной кружкой",
		PREPOSITIONAL = "оскорбительной кофейной кружке"
	)
	state = "mug_insult"

/datum/novelty_mug/insult/New()
	var/insult = pick("Здесь недостаточно кофе, чтобы сделать тебя сносным.", "Я пью кофе, чтобы притворяться, что мне нравятся люди.", "Я еще не допил кофе... Такое у тебя оправдание?", "Этот кофе более крепкий, чем твоя самооценка.", "Кофе без кофеина – как раз для таких слабаков, как ты.")
	description = "Здесь надпись:\"[insult]\""

/datum/novelty_mug/pda
	name = "PDA mug"
	description = "Наконец-то достойное применение этим штукам!"
	ru_names = list(
		NOMINATIVE = "кружка-КПК",
		GENITIVE = "кружки-КПК",
		DATIVE = "кружке-КПК",
		ACCUSATIVE = "кружку-КПК",
		INSTRUMENTAL = "кружкой-КПК",
		PREPOSITIONAL = "кружке-КПК"
	)
	state = "mug_pda"

/datum/novelty_mug/rad
	name = "radioactive mug"
	description = "Кофе должен быть зелёным... и светящимся?"
	ru_names = list(
		NOMINATIVE = "радиоактивная кружка",
		GENITIVE = "радиоактивной кружки",
		DATIVE = "радиоактивной кружке",
		ACCUSATIVE = "радиоактивную кружку",
		INSTRUMENTAL = "радиоактивной кружкой",
		PREPOSITIONAL = "радиоактивной кружке"
	)
	state = "mug_rad"

/datum/novelty_mug/tide
	name = "greytide mug"
	description = "Этот кофе бьёт почти так же сильно, как тулбокс по лицу!"
	ru_names = list(
		NOMINATIVE = "грейтайд-кружка",
		GENITIVE = "грейтайд-кружки",
		DATIVE = "грейтайд-кружке",
		ACCUSATIVE = "грейтайд-кружку",
		INSTRUMENTAL = "грейтайд-кружкой",
		PREPOSITIONAL = "грейтайд-кружке"
	)
	state = "mug_tide"

/datum/novelty_mug/happy
	name = "happy mug"
	description = "Даже когда вам грустно, эта кружка помогает выглядеть счастливым перед коллегами."
	ru_names = list(
		NOMINATIVE = "счастливая кружка",
		GENITIVE = "счастливой кружки",
		DATIVE = "счастливой кружке",
		ACCUSATIVE = "счастливую кружку",
		INSTRUMENTAL = "счастливой кружкой",
		PREPOSITIONAL = "счастливой кружке"
	)
	state = "mug_happy"

/datum/novelty_mug/pills
	name = "prescription mug"
	description = "Рецепт: кофеин. Дозировка: сколько потребуется."
	ru_names = list(
		NOMINATIVE = "кружка-рецепт",
		GENITIVE = "кружки-рецепта",
		DATIVE = "кружке-рецепту",
		ACCUSATIVE = "кружку-рецепт",
		INSTRUMENTAL = "кружкой-рецептом",
		PREPOSITIONAL = "кружке-рецепте"
	)
	state = "mug_pill"

/datum/novelty_mug/rainbow
	name = "rainbow mug"
	description = "Так завораживает!"
	ru_names = list(
		NOMINATIVE = "радужная кружка",
		GENITIVE = "радужной кружки",
		DATIVE = "радужной кружке",
		ACCUSATIVE = "радужную кружку",
		INSTRUMENTAL = "радужной кружкой",
		PREPOSITIONAL = "радужной кружке"
	)
	state = "mug_rainbow"

/obj/item/reagent_containers/food/drinks/mug/New()
	..()
	if(preset)
		return
	if(novelty)
		var/novelty_type = pick(subtypesof(/datum/novelty_mug))
		var/datum/novelty_mug/selected = new novelty_type
		name = selected.name
		desc = selected.description
		icon_state = selected.state
	else
		icon_state = pick("mug_black", "mug_white", "mug_red", "mug_blue", "mug_green", "mug_pink")

/obj/item/reagent_containers/food/drinks/mug/eng
	name = "engineer's mug"
	desc = "Дна нет, а верх запаян."
	ru_names = list(
		NOMINATIVE = "инженерная кружка",
		GENITIVE = "инженерной кружки",
		DATIVE = "инженерной кружке",
		ACCUSATIVE = "инженерную кружку",
		INSTRUMENTAL = "инженерной кружкой",
		PREPOSITIONAL = "инженерной кружке"
	)
	icon_state = "mug_eng"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/med
	name = "doctor's mug"
	desc = "Кружка, способная вместить лекарство от всех болезней!"
	ru_names = list(
		NOMINATIVE = "докторская кружка",
		GENITIVE = "докторской кружки",
		DATIVE = "докторской кружке",
		ACCUSATIVE = "докторскую кружку",
		INSTRUMENTAL = "докторской кружкой",
		PREPOSITIONAL = "докторской кружке"
	)
	icon_state = "mug_med"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/sci
	name = "scientist's mug"
	desc = "Ничто так не подпитывает исследования, как кофейная кружка... ну или грантовые деньги!"
	ru_names = list(
		NOMINATIVE = "научная кружка",
		GENITIVE = "научной кружки",
		DATIVE = "научной кружке",
		ACCUSATIVE = "научную кружку",
		INSTRUMENTAL = "научной кружкой",
		PREPOSITIONAL = "научной кружке"
	)
	icon_state = "mug_sci"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/sec
	name = "officer's mug"
	desc = "Идеальный компаньон для пончика с посыпкой, или оглушающей дубинки!"
	ru_names = list(
		NOMINATIVE = "офицерская кружка",
		GENITIVE = "офицерской кружки",
		DATIVE = "офицерской кружке",
		ACCUSATIVE = "офицерскую кружку",
		INSTRUMENTAL = "офицерской кружкой",
		PREPOSITIONAL = "офицерской кружке"
	)
	icon_state = "mug_sec"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/serv
	name = "crewmember's mug"
	desc = "Утоляет жажду лучше, чем вы служите экипажу!"
	ru_names = list(
		NOMINATIVE = "кружка члена экипажа",
		GENITIVE = "кружки члена экипажа",
		DATIVE = "кружке члена экипажа",
		ACCUSATIVE = "кружку члена экипажа",
		INSTRUMENTAL = "кружкой члена экипажа",
		PREPOSITIONAL = "кружке члена экипажа"
	)
	icon_state = "mug_serv"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/ce
	name = "chief engineer's mug"
	desc = "Многократно разбивалась и заваривалась заново – прямо как станция! Наверное, безопасна для микроволновки."
	ru_names = list(
		NOMINATIVE = "кружка старшего инженера",
		GENITIVE = "кружки старшего инженера",
		DATIVE = "кружке старшего инженера",
		ACCUSATIVE = "кружку старшего инженера",
		INSTRUMENTAL = "кружкой старшего инженера",
		PREPOSITIONAL = "кружке старшего инженера"
	)
	icon_state = "mug_ce"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/hos
	name = "head of security's mug"
	desc = "Если бы только ваши офицеры были такими же крепкими, как вкус этого кофе!"
	ru_names = list(
		NOMINATIVE = "кружка ГСБ",
		GENITIVE = "кружки ГСБ",
		DATIVE = "кружке ГСБ",
		ACCUSATIVE = "кружку ГСБ",
		INSTRUMENTAL = "кружкой ГСБ",
		PREPOSITIONAL = "кружке ГСБ"
	)
	icon_state = "mug_hos"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/rd
	name = "research director's mug"
	desc = "Уровень энергетических технологий: 99"
	ru_names = list(
		NOMINATIVE = "кружка директора исследований",
		GENITIVE = "кружки директора исследований",
		DATIVE = "кружке директора исследований",
		ACCUSATIVE = "кружку директора исследований",
		INSTRUMENTAL = "кружкой директора исследований",
		PREPOSITIONAL = "кружке директора исследований"
	)
	icon_state = "mug_rd"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/cmo
	name = "chief medical officer's mug"
	desc = "Наполните её чем-нибудь, что поможет не заснуть, пока вы пытаетесь сохранить экипажу жизнь."
	ru_names = list(
		NOMINATIVE = "кружка главврача",
		GENITIVE = "кружки главврача",
		DATIVE = "кружке главврача",
		ACCUSATIVE = "кружку главврача",
		INSTRUMENTAL = "кружкой главврача",
		PREPOSITIONAL = "кружке главврача"
	)
	icon_state = "mug_cmo"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/hop
	name = "head of personnel's mug"
	desc = "Пятна на дне... Они от кофе, или чернил?"
	ru_names = list(
		NOMINATIVE = "кружка главы персонала",
		GENITIVE = "кружки главы персонала",
		DATIVE = "кружке главы персонала",
		ACCUSATIVE = "кружку главы персонала",
		INSTRUMENTAL = "кружкой главы персонала",
		PREPOSITIONAL = "кружке главы персонала"
	)
	icon_state = "mug_hop"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/cap
	name = "captain's mug"
	desc = "Надпись на боку гласит: \"Лучший капитан 2559\"... В последний раз, когда на станции был достойный капитан."
	ru_names = list(
		NOMINATIVE = "капитанская кружка",
		GENITIVE = "капитанской кружки",
		DATIVE = "капитанской кружке",
		ACCUSATIVE = "капитанскую кружку",
		INSTRUMENTAL = "капитанской кружкой",
		PREPOSITIONAL = "капитанской кружке"
	)
	icon_state = "mug_cap"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/comms
	name = "Comms Officer's mug"
	desc = "Нахуй НТ. И со стилем!"
	ru_names = list(
		NOMINATIVE = "кружка офицера связи",
		GENITIVE = "кружки офицера связи",
		DATIVE = "кружке офицера связи",
		ACCUSATIVE = "кружку офицера связи",
		INSTRUMENTAL = "кружкой офицера связи",
		PREPOSITIONAL = "кружке офицера связи"
	)
	icon_state = "mug_offcomm"
	preset = TRUE
