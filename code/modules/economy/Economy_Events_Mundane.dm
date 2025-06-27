
/datum/event/mundane_news
	endWhen = 10

/datum/event/mundane_news/announce()
	var/datum/trade_destination/affected_dest = pickweight(GLOB.weighted_mundaneevent_locations)
	var/event_type = 0
	if(affected_dest.viable_mundane_events.len)
		event_type = pick(affected_dest.viable_mundane_events)

	if(!event_type)
		return

	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = NEWS_CHANNEL_NYX
	newMsg.admin_locked = TRUE

	//see if our location has custom event info for this event
	newMsg.body = affected_dest.get_custom_eventstring()
	if(!newMsg.body)
		newMsg.body = ""

		switch(event_type)
			if(RESEARCH_BREAKTHROUGH)
				newMsg.body = "Крупный прорыв в области [pick("исследования плазмы","сверхсжатых материалов","наноаугментаций","исследования блюспейса", "управления нестабильной энергией")] был объявлен, [pick("вчера","несколько дней назад","на прошлой неделе","ранее в этом месяце")], частной фирмой на [affected_dest.name]. НаноТрейзен отказалась комментировать, может ли это повлиять на её прибыль."

			if(ELECTION)
				newMsg.body = "Сегодня было объявлено о предварительном отборе дополнительных кандидатов на предстоящие выборы в [pick("совет надзирателей","консультативный совет","парламент","коллегию инквизиторов")] на [affected_dest.name]. Среди них — [pick("медиамагнат","веб-знаменитость","титан индустрии","суперзвезда","знаменитый шеф-повар","популярный садовод","бывший армейский офицер","мультимиллиардер")] "
				var/locvar = pick("MALE", "FEMALE")
				if (locvar == "MALE")
					newMsg.body += "[random_name(MALE)]. В заявлении для прессы он сказал: "
				else
					newMsg.body += "[random_name(FEMALE)]. В заявлении для прессы она сказала: "
				newMsg.body += "[pick("Моя единственная цель — помочь [pick("больным","бедным","детям")]","Я буду поддерживать рекордные прибыли НаноТрейзен","Я верю в наше будущее","Мы должны вернуться к нашей моральной основе","Просто... расслабьтесь, ребята")]!"

			if(RESIGNATION)
				var/locvar = pick("MALE", "FEMALE")
				newMsg.body = "НаноТрейзен с сожалением объявляет об отставке [random_name(locvar)] – [pick("секторного адмирала","дивизионного адмирала","корабельного адмирала","вице-адмирала")]."
				if(prob(25))
					var/locstring = pick("Сегунда","Салyса","Цефей","Андромеда","Груис","Корона","Акyила","Аселлyс") + " " + pick("I","II","III","IV","V","VI","VII","VIII")
					newMsg.body += " Сегодня днём на [affected_dest.name] состоится церемония, на которой [locvar == "MALE" ? "ему" : "ей"] будет вручена награда – [pick("Красная Звезда Жертвенности","Пурпурное Сердце Героизма","Синий Орёл Верности","Зелёный Лев Изобретательности")] за "
					if(prob(33))
						newMsg.body += "действия в Битве при [pick(locstring,"██████████")]."
					else if(prob(50))
						newMsg.body += "вклад в развитие колонии [locstring]."
					else
						newMsg.body += "многолетнюю верную службу."
				else if(prob(33))
					newMsg.body += " Ожидается, что он[locvar == "MALE" ? "" : "а"] поселится на [affected_dest.name], где [locvar == "MALE" ? "ему" : "ей"] будет назначена щедрая пенсия."
				else if(prob(50))
					newMsg.body += " Новость была обнародована на [affected_dest.name] сегодня ранее, где он[locvar == "MALE" ? "" : "а"] назвал[locvar == "MALE" ? "" : "а"] причины своего ухода: '[pick("здоровье","семья","██████████")]'."
				else
					newMsg.body += " Аэрокосмическое управление желает удачи на церемонии выхода на пенсию, которая состоится на [affected_dest.name]."

			if(CELEBRITY_DEATH)
				newMsg.body = "С сожалением, мы объявляем о внезапной кончине "
				if(prob(33))
					newMsg.body += "[pick("выдающегося","награждённого","ветерана","высокоуважаемого")] [pick("капитана корабля","вице-адмирала","полковника","подполковника")] "
				else if(prob(50))
					newMsg.body += "[pick("награждённого","популярного","высокоуважаемого","задающего тренды")] [pick("комика","художника","драматурга","телеведущего")] "
				else
					newMsg.body += "[pick("успешного","высокоуважаемого","гениального","уважаемого")] [pick("учёного","профессора","доктора","исследователя")] "

				newMsg.body += "[random_name(MALE,FEMALE)] на [affected_dest.name], [pick("на прошлой неделе","вчера","сегодня утром","два дня назад","три дня назад")],[pick(". Подозревается убийство, но виновные ещё не найдены"," из-за действий агентов Синдиката (с тех пор задержанных)", " во время промышленной аварии", " из-за [pick("сердечной недостаточности","почечной недостаточности","печёночной недостаточности","кровоизлияния в мозг")]")]."

			if(BARGAINS)
				newMsg.body += "РАСПРОДАЖА! РАСПРОДАЖА! РАСПРОДАЖА! Коммерческий контроль [affected_dest.name] сообщает, что всё должно быть распродано! Во всех торговых центрах, цены на все товары снижены — так что приходите и проведите лучший шопинг в своей жизни!"

			if(SONG_DEBUT)
				var/locvar = pick("MALE", "FEMALE")
				if (locvar == "MALE")
					newMsg.body = "[pick("Певец","Певец/автор песен","Саксофонист","Пианист","Гитарист","Телеведущий","Звезда")] [random_name(MALE)] объявил"
				else
					newMsg.body = "[pick("Певица","Певица/автор песен","Саксофонистка","Пианистка","Гитаристка","Телеведущая","Звезда")] [random_name(FEMALE)] объявила"
				newMsg.body += " о дебюте своего нового [pick("сингла","альбома","мини-альбома","лейбла")] под названием \"[pick("Все эти","Посмотри на","Детка, не смотри на","Все эти","Грязные мерзкие")] [pick("розы","три звезды","звёздные корабли","нанороботы","киборги","Скреллы","Срен'дарр")] [pick("на Венере","на Риде","на Могесе","в моей руке","скользят сквозь пальцы","умрут за тебя","спой от души","улетают прочь")]\" [pick("предзаказы уже доступны","с туром в поддержку релиза","с автограф-сессиями","с концертом-презентацией")] на [affected_dest.name]."

			if(MOVIE_RELEASE)
				newMsg.body += "Из [pick("кабинета","родного города","родного мира","ума")] [pick("признанного","награждённого","популярного","звёздного")] [pick("драматурга","автора","режиссёра","актёра","телезвезды")] [random_name(MALE,FEMALE)] выходит новая сенсация: \"[pick("Смертельные","Последние","Потерянные","Мёртвые")] [pick("звёздные корабли","воины","изгои","Таяры","Унатхи","Скреллы")] [pick("посещают","опустошают","грабят","уничтожают")] [pick("Могес","Землю","Бизель","Адомай","С'рандарра","Пустоты","Края Космоса")]\". Приобретите веб-трансляцию уже сегодня или посетите галактическую премьеру на [affected_dest.name]!"

			if(BIG_GAME_HUNTERS)
				newMsg.body += "Охотники [affected_dest.name] "
				if(prob(33))
					newMsg.body += "были удивлены, когда обнаружили необычный вид, который эксперты позже идентифицировали как [pick("подкласс млекопитающих","отклоняющийся вид аблюдей","разумный вид лемуров","органическо-кибернетические гибриды")]. Предполагается, что они были завезены [pick("инопланетными контрабандистами","ранними колонистами","рейдерами Синдиката","туристами")], это первый подобный экземпляр, обнаруженный в дикой природе."
				else if(prob(50))
					newMsg.body += "были атакованы свирепым [pick("нас'ром","дияабом","самаком","хищником, который ещё не идентифицирован")]. Власти призывают к осторожности, а местным жителям рекомендуется запастись оружием."
				else
					newMsg.body += "привезли необычно [pick("ценного","редкого","крупного","свирепого","разумного")] [pick("млекопитающего","хищника","фарву","самака")] для осмотра [pick("сегодня","вчера","на прошлой неделе")]. Спекулянты предполагают, что это может побить несколько рекордов."

			if(GOSSIP)
				var/locvar = pick("MALE", "FEMALE")
				if (locvar == "MALE")
					newMsg.body += "[pick("Телеведущий","Веб-знаменитость","Суперзвезда","Модель","Актёр","Певец")] [random_name(MALE)] и его супруга"
				else
					newMsg.body += "[pick("Телеведущая","Веб-знаменитость","Суперзвезда","Модель","Актриса","Певица")] [random_name(FEMALE)] и её супруг"
				if(prob(33))
					newMsg.body += " объявили о рождении их [pick("первого","второго","третьего")] ребёнка на [affected_dest.name] сегодня рано утром. Врачи сообщают, что ребёнок здоров, а родители рассматривают имя "
					if(prob(50))
						newMsg.body += capitalize(pick(GLOB.first_names_female))
					else
						newMsg.body += capitalize(pick(GLOB.first_names_male))
					newMsg.body += "."
				else if(prob(50))
					if (locvar == "MALE")
						newMsg.body += " объявил о своём [pick("расставании","разрыве","браке")] с [pick("телеведущей","веб-знаменитостью","суперзвездой","моделью","актрисой","певицей")] [random_name(FEMALE)] "
					else
						newMsg.body += " объявила о своём [pick("расставании","разрыве","браке")] с [pick("телеведущим","веб-знаменитостью","суперзвездой","моделью","актёром","певцом")] [random_name(MALE)] "
					newMsg.body += "[pick("на светском балу","на новом открытии","в клубе")] на [affected_dest.name] вчера. Эксперты шокированы."
				else
					newMsg.body += " восстанавливается после пластической операции в клинике на [affected_dest.name] уже [pick("во второй","в третий","в четвертый")] раз. По сообщениям, это решение было принято в ответ на "
					newMsg.body += "[pick("недобрые комментарии","слухи, распущенные завистливыми друзьями","решение крупного спонсора прекратить сотрудничество","катастрофическое интервью на \"Вечерний Никс\"")]."

			if(TOURISM)
				var/locvar = pick("MALE", "FEMALE")
				var/locstring = ""
				if (locvar == "MALE")
					locstring = "туре популярного артиста"
				else
					locstring = "туре популярной артистки"
				newMsg.body += "Туристы стекаются на [affected_dest.name], после неожиданного объявления о [pick("распродажах от крупного ритейлера","новой масштабной AR-игре от популярной развлекательной компании","[locstring]")]. \"Никс Дейли\" предлагает скидочные билеты для двоих на концерт, который проведёт популярный артист [random_name(pick(MALE,FEMALE))], в обмен на репортажи очевидцев и оперативное освещение событий."

	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_NYX)?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_NYX)

/datum/event/trivial_news
	endWhen = 10

/datum/event/trivial_news/announce()
	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = EDITOR_GIB
	//newMsg.is_admin_message = 1
	var/datum/trade_destination/affected_dest = pick(GLOB.weighted_mundaneevent_locations)
	newMsg.body = pick(file2list("config/news/trivial.txt"))
	newMsg.body = replacetext(newMsg.body, "{{AFFECTED}}", affected_dest.name)

	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_GIB)?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_GIB)
