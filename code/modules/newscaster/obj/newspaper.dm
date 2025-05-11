#define SCREEN_COVER 0
#define SCREEN_PAGE_INNER 1
#define SCREEN_PAGE_LAST 2

/**
  * # Newspaper
  *
  * A newspaper displaying the stories of all channels contained within.
  */
/obj/item/newspaper
	name = "newspaper"
	desc = "Выпуск газеты \"Грифон\", распространяемой на объектах НаноТрейзен."
	ru_names = list(
        NOMINATIVE = "газета",
        GENITIVE = "газеты",
        DATIVE = "газете",
        ACCUSATIVE = "газету",
        INSTRUMENTAL = "газетой",
        PREPOSITIONAL = "газете"
	)
	gender = FEMALE
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	item_state = "newspaper"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("стукнул")
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'

	///The page in the newspaper currently being read. 0 is the title screen while the last is the security screen.
	var/current_page = 1
	///Stored information of the wanted criminal's name, if one existed at the time of creation.
	var/wanted
	///Whether the newspaper is rolled or not, making it a deadly weapon.
	var/rolled = FALSE
	///Advertisements text
	var/advertisements
	///Scribble sheet
	var/list/scribble = list()
	///News list
	var/list/stories = list()

	/// Possible advertising post
	var/list/adsList = list("Wetskrell.nt — лучший сайт для проведения мужского досуга! Только здесь вы найдёте по настоящему эксклюзивный контент!",
		"На Wetskrell.nt стартовала акция — 3 месяца подписки по цене двух! Только для настоящих ценителей культуры!",
		"Онлайн Казино МегаСтавка: Мы не чешем колоду, гарантируем честную раздачу! Наши колоды заряжены не в киосках, как у конкурентов!",
		"Космический бар \"Гравитация\": Лучшие коктейли в системе Тау Кита! Приходите и попробуйте наш фирменный \"Блюспейс Бум\"!",
		"Клуб \"Синдикатская Тень\": Только для избранных. Лучшие вечеринки, эксклюзивные напитки и никаких вопросов.",
		"Магазин \"КиберЛом\": Продажа и покупка б/у кибернетических имплантов. Дешевле, чем у конкурентов, и с гарантией!",
		"Галактический такси-сервис \"Метеор\": Быстро, надёжно, без лишних вопросов. Довезём вас куда угодно!",
		"Продам гараж – анонимный рекламодатель.",
		"Хотите улучшить свои навыки? Запишитесь на курсы по вольной борьбе! Скидка 20% для сотрудников службы безопасности.",
		"Пиво и раки от мистера Ченга – большие раки по 5 кредитов, маленькие по 3!",
		"Waffle Corporation: Вафли, которые заряжают энергией на весь день! Теперь с добавлением блюспейс-кристаллов!",
		"Одинокий вульпканин в 300 метрах от Вас! Установите наше приложение себе на КПК и напишите ему!",
		"Скучаете на смене? Закажите пиццу с плазмой от \"Пицца-Экспресс\"! Доставка в любую точку станции за 15 минут!",
		"Ресторан \"Звёздный Вкус\": Блюда, которые вы никогда не пробовали! И, возможно, никогда не захотите попробовать снова.",
		"Клуб \"Нулевая Гравитация\": Танцуйте до тех пор, пока не упадёте! Или пока вас не выбросит за борт.",
		"Офицеры дуреют от этой кожуры! Самые скользкие кожурки во всей система Тау Кита...")

/obj/item/newspaper/Initialize(mapload)
	. = ..()

	advertisements = pick(adsList)

	///Enter all current news into a list
	for(var/datum/feed_message/feed_messages as anything in GLOB.news_network.stories)
		stories += list(list(
			uid = feed_messages.UID(),
			author = feed_messages.author,
			title = feed_messages.title,
			body = feed_messages.body,
			photo = !isnull(feed_messages.img),
	))

	if(!GLOB.news_network.wanted_issue)
		return
	wanted = list(list(
		uid = GLOB.news_network.wanted_issue.UID(),
		title = GLOB.news_network.wanted_issue.title,
		body = GLOB.news_network.wanted_issue.body,
		photo = GLOB.news_network.wanted_issue.img,
	))

/obj/item/newspaper/examine(mob/user)
	. = ..()
	if(rolled)
		. += span_notice("Вы должны развернуть её, если хотите прочитать.")
	else
		if(user.is_literate())
			if(in_range(user, src) || istype(user, /mob/dead/observer))
				attack_self(user)
			else
				. += span_notice("Вам нужно подойти поближе, если вы хотите это прочитать.")
		else
			. += span_warning("Вы не умеете читать!")

/obj/item/newspaper/attack_self(mob/user)
	if(rolled)
		balloon_alert(user, "сначала разверните!")
		return
	if(user.is_literate())
		ui_interact(user)
	else
		to_chat(user, span_warning("Бумага заполнена непонятными символами!"))

/obj/item/newspaper/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Newspaper", name)
		ui.open()

/obj/item/newspaper/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("next_page")
			current_page++
		if("prev_page")
			current_page--
		else
			return TRUE
	SStgui.update_uis(src)
	playsound(loc, "pageturn", 50, TRUE)
	return TRUE

/obj/item/newspaper/ui_data(mob/user)
	var/list/data = list()
	data["wanted"] = wanted
	data["current_page"] = current_page
	data["stories"] = stories

	// Display 8 news entries
	var/total_pages = length(stories) == 0 ? 1 : ceil(length(stories) / 8)
	data["total_pages"] = total_pages
	data["advertisements"] = advertisements
	data["scribble"] = scribble
	return data

/obj/item/newspaper/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		add_fingerprint(user)
		if(rolled)
			balloon_alert(user, "сначала разверните!")
			return ATTACK_CHAIN_PROCEED
		var/page_exists = FALSE
		for(var/entry in scribble)
			if(entry["id"] == current_page)
				page_exists = TRUE
				break
		if(page_exists)
			to_chat(user, span_notice("На этой странице уже есть пометка... Вы же не хотите сделать всё слишком запутанным, правда?"))
			balloon_alert(user, "нет места!")
			return ATTACK_CHAIN_PROCEED
		var/new_scribble = tgui_input_text(user, "Напишите что-то", "Оставить заметку")
		if(!new_scribble || !Adjacent(user))
			return ATTACK_CHAIN_PROCEED
		scribble += list(list(
			id = current_page,
			text = new_scribble
		))
		user.visible_message(
			span_notice("[user] дела[pluralize_ru(user.gender, "ет", "ют")] пометку в газете."),
			span_notice("Вы делаете пометку на [current_page] странице [declent_ru(GENITIVE)]."),
		)
		attack_self(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/newspaper/click_alt(mob/user)
	rolled = !rolled
	icon_state = "newspaper[rolled ? "_rolled" : ""]"
	update_icon()
	user.visible_message(span_notice("[user] [rolled ? "с" : "раз"]ворачива[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."),\
							span_notice("Вы [rolled ? "с" : "раз"]ворачиваете [declent_ru(ACCUSATIVE)]."))
	name = "[rolled ? "rolled" : ""] [initial(name)]"
	ru_names = list(
        NOMINATIVE = "[rolled ? "свёрнутая " : ""]газета",
        GENITIVE = "[rolled ? "свёрнутой " : ""]газеты",
        DATIVE = "[rolled ? "свёрнутой " : ""]газете",
        ACCUSATIVE = "[rolled ? "свёрнутую" : ""]газету",
        INSTRUMENTAL = "[rolled ? "свёрнутой " : ""]газетой",
        PREPOSITIONAL = "[rolled ? "свёрнутой " : ""]газете"
	)
	return CLICK_ACTION_SUCCESS

#undef SCREEN_COVER
#undef SCREEN_PAGE_INNER
#undef SCREEN_PAGE_LAST
