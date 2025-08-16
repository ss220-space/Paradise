// This system defines news that will be displayed in the course of a round.
// Uses BYOND's type system to put everything into a nice format

/datum/news_announcement

	var/round_time // time of the round at which this should be announced, in seconds
	var/message // body of the message
	var/author = "Редактор НаноТрейзен"
	var/channel_name = NEWS_CHANNEL_NYX
	var/can_be_redacted = FALSE
	var/message_type = "Story"

/datum/news_announcement/revolution_inciting_event/paycuts_suspicion
	round_time = 60*10
	message = {"Утекли сообщения о том, что НаноТрейзен планирует ввести сокращение зарплат
				на многих своих исследовательских станциях в системе Тау Кита. По всей видимости, эти станции
				не смогли принести ожидаемой прибыли, и поэтому необходимы корректировки."}
	author = "Неавторизованный"

/datum/news_announcement/revolution_inciting_event/paycuts_confirmation
	round_time = 60*40
	message = {"Ранее ходившие слухи о сокращении зарплат на исследовательских станциях
				в системе Тау Кита подтвердились. Однако, что шокирует, сокращения затронут только
				персонал низшего звена. По данным наших источников, руководство станций не пострадает."}
	author = "Неавторизованный"

/datum/news_announcement/revolution_inciting_event/human_experiments
	round_time = 60*90
	message = {"Поступили шокирующие сообщения о проведении экспериментов над людьми.
				Согласно беженцу с одной из исследовательских станций в системе Тау Кита, их станция,
				чтобы увеличить доходы, переоборудовала несколько своих лабораторий для проведения экспериментов
				над живыми людьми. Среди них — исследования в вирусологии, генетические манипуляции и \"кормление слаймами,
				чтобы посмотреть, что произойдёт\". По утверждениям, подопытными были не очеловеченные обезьяны и не добровольцы,
				а неквалифицированный персонал, насильно вовлечённый в эксперименты. О их гибели НаноТрейзен сообщала
				как о \"несчастных случаях на производстве\"."}
	author = "Неавторизованный"

/datum/news_announcement/bluespace_research/announcement
	round_time = 60*20
	message = {"Новая область исследований, пытающаяся объяснить несколько интересных аномалий пространства-времени,
				известная как \"Исследование Блюспейса\", достигла новых высот. Из нескольких сотен космических станций, находящихся
				на орбите в системе Тау Кита, пятнадцать теперь специально оборудованы для экспериментов и изучения эффектов Блюспейса.
				Ходят слухи, что на некоторых из этих станций даже есть рабочие \"врата перемещения\", способные мгновенно переносить
				целые исследовательские команды в альтернативные реальности."}

/datum/news_announcement/random_junk/cheesy_honkers
	author = "Помощник редактора Карл Ритц"
	channel_name = NEWS_CHANNEL_GIB
	message = {"Увеличивают ли сырные хонкеры риск выкидыша? Несколько органов здравоохранения утверждают, что да!"}
	round_time = 60 * 15

/datum/news_announcement/random_junk/net_block
	author = "Помощник редактора Карл Ритц"
	channel_name = NEWS_CHANNEL_GIB
	message = {"Несколько корпораций объединились, чтобы заблокировать доступ к сайту \"wetskrell.nt\".
				Администраторы сайта заявляют о нарушении сетевых законов."}
	round_time = 60 * 50

/datum/news_announcement/random_junk/found_ssd
	channel_name = NEWS_CHANNEL_NYX
	author = "Доктор Эрик Ханфилд"

	message = {"Несколько человек были обнаружены без сознания за своими терминалами. Предполагается,
				что это связано с недосыпом или мигренями из-за долгого взгляда на экран. Записи с камер показывают,
				что многие из них играли в игры вместо работы, и их зарплата была сокращена соответствующим образом."}
	round_time = 60 * 90

/datum/news_announcement/lotus_tree/explosions
	channel_name = NEWS_CHANNEL_NYX
	author = "Репортер Леланд Г. Ховардс"

	message = {"Недавно запущенный гражданский транспорт \"Лотосовое Дерево\" сегодня пережил два мощных взрыва
				в районе мостика. По неподтверждённым данным, число погибших превысило 50 человек. Причина взрывов
				остаётся неизвестной, но есть предположения, что это может быть связано с недавним изменением политики
				корпорации Мур-Ли, основного спонсора судна. Корпорация, так-же, объявила о признании межвидовых браков и предоставлении
				налоговых льгот для таких пар."}
	round_time = 60 * 30

/datum/news_announcement/food_riots/breaking_news
	channel_name = NEWS_CHANNEL_NYX
	author = "Репортер Ро'Кии Ар-Ракис"

	message = {"Экстренные новости: В колонии на астероиде \"Убежище\" в системе \"Тенебру Люпус\" вспыхнули продовольственные бунты.
				Это произошло всего через несколько часов после того, как представители НаноТрейзен объявили о прекращении торговли
				с колонией, сославшись на возросшее присутствие \"враждебных фракций\", что сделало торговлю слишком опасной.
				Представители НаноТрейзен не предоставили подробностей об этих фракциях. Подробнее об этом в начале часа."}
	round_time = 60 * 10

/datum/news_announcement/food_riots/more
	channel_name = NEWS_CHANNEL_NYX
	author = "Репортер Ро'Кии Ар-Ракис"

	message = {"Подробнее о продовольственных бунтах в колонии \"Убежище\": Совет Убежища осудил уход НаноТрейзен
				из колонии, заявив, что \"не было никакого увеличения активности против НаноТрейзен\", и что \"единственная причина ухода
				НаноТрейзен — это полное истощение залежей плазмы в системе \"Тенебру Люпус\". Теперь нам почти нечего им предложить\".
				Представители НаноТрейзен опровергли эти обвинения, назвав их \"ещё одним свидетельством\" негативного настроя против НаноТрейзен в колонии.
				Тем временем служба безопасности Убежища не смогла подавить беспорядки. Подробнее об этом в 6 часов."}
	round_time = 60 * 60
GLOBAL_LIST_INIT(newscaster_standard_feeds, list(/datum/news_announcement/bluespace_research, /datum/news_announcement/lotus_tree, /datum/news_announcement/random_junk,  /datum/news_announcement/food_riots))

/proc/process_newscaster()
	check_for_newscaster_updates(SSticker.mode.newscaster_announcements)

GLOBAL_LIST_EMPTY(announced_news_types)

/proc/check_for_newscaster_updates(type)
	for(var/subtype in subtypesof(type))
		var/datum/news_announcement/news = new subtype()
		if(news.round_time * 10 <= world.time && !(subtype in GLOB.announced_news_types))
			GLOB.announced_news_types += subtype
			announce_newscaster_news(news)

/proc/announce_newscaster_news(datum/news_announcement/news)

	var/datum/feed_channel/sendto = GLOB.news_network.get_channel_by_name(news.channel_name)
	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = news.channel_name
		sendto.author = news.author
		sendto.frozen = TRUE
		sendto.admin_locked = TRUE
		GLOB.news_network.channels += sendto

	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = news.author ? news.author : sendto.author
	newMsg.admin_locked = !news.can_be_redacted
	newMsg.body = news.message

	sendto.add_message(newMsg)

	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(news.channel_name)
