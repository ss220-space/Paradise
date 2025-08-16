
#define RIOTS 1
#define WILD_ANIMAL_ATTACK 2
#define INDUSTRIAL_ACCIDENT 3
#define BIOHAZARD_OUTBREAK 4
#define WARSHIPS_ARRIVE 5
#define PIRATES 6
#define CORPORATE_ATTACK 7
#define ALIEN_RAIDERS 8
#define AI_LIBERATION 9
#define MOURNING 10
#define CULT_CELL_REVEALED 11
#define SECURITY_BREACH 12
#define ANIMAL_RIGHTS_RAID 13
#define FESTIVAL 14

#define RESEARCH_BREAKTHROUGH 15
#define BARGAINS 16
#define SONG_DEBUT 17
#define MOVIE_RELEASE 18
#define BIG_GAME_HUNTERS 19
#define ELECTION 20
#define GOSSIP 21
#define TOURISM 22
#define CELEBRITY_DEATH 23
#define RESIGNATION 24

#define DEFAULT 1

#define ADMINISTRATIVE 2
#define CLOTHING 3
#define SECURITY 4
#define SPECIAL_SECURITY 5

#define FOOD 6
#define ANIMALS 7

#define MINERALS 8

#define EMERGENCY 9
#define EGAS 10
#define MAINTENANCE 11
#define ELECTRICAL 12
#define ROBOTICS 13
#define BIOMEDICAL 14

#define GEAR_EVA 15

/datum/event/economic_event
	endWhen = 50			//this will be set randomly, later
	announceWhen = 15
	var/event_type = 0
	var/list/cheaper_goods = list()
	var/list/dearer_goods = list()
	var/datum/trade_destination/affected_dest

/datum/event/economic_event/start()
	affected_dest = pickweight(GLOB.weighted_randomevent_locations)
	if(affected_dest.viable_random_events.len)
		endWhen = rand(60,300)
		event_type = pick(affected_dest.viable_random_events)

		if(!event_type)
			return

		switch(event_type)
			if(RIOTS)
				dearer_goods = list(SECURITY)
				cheaper_goods = list(MINERALS, FOOD)
			if(WILD_ANIMAL_ATTACK)
				cheaper_goods = list(ANIMALS)
				dearer_goods = list(FOOD, BIOMEDICAL)
			if(INDUSTRIAL_ACCIDENT)
				dearer_goods = list(EMERGENCY, BIOMEDICAL, ROBOTICS)
			if(BIOHAZARD_OUTBREAK)
				dearer_goods = list(BIOMEDICAL, EGAS)
			if(PIRATES)
				dearer_goods = list(SECURITY, MINERALS)
			if(CORPORATE_ATTACK)
				dearer_goods = list(SECURITY, MAINTENANCE)
			if(ALIEN_RAIDERS)
				dearer_goods = list(BIOMEDICAL, ANIMALS)
				cheaper_goods = list(EGAS, MINERALS)
			if(AI_LIBERATION)
				dearer_goods = list(EMERGENCY, EGAS, MAINTENANCE)
			if(MOURNING)
				cheaper_goods = list(MINERALS, MAINTENANCE)
			if(CULT_CELL_REVEALED)
				dearer_goods = list(SECURITY, BIOMEDICAL, MAINTENANCE)
			if(SECURITY_BREACH)
				dearer_goods = list(SECURITY)
			if(ANIMAL_RIGHTS_RAID)
				dearer_goods = list(ANIMALS)
			if(FESTIVAL)
				dearer_goods = list(FOOD, ANIMALS)
		for(var/good_type in dearer_goods)
			affected_dest.temp_price_change[good_type] = rand(1,100)
		for(var/good_type in cheaper_goods)
			affected_dest.temp_price_change[good_type] = rand(1,100) / 100

/datum/event/economic_event/announce()
	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = NEWS_CHANNEL_NYX
	newMsg.admin_locked = TRUE

	//see if our location has custom event info for this event
	newMsg.body = affected_dest.get_custom_eventstring()
	if(!newMsg.body)
		switch(event_type)
			if(RIOTS)
				newMsg.body = "[pick("Бунты вспыхнули","Беспорядки начались")] на планете [affected_dest.name]. Власти призывают к спокойствию, так как [pick("различные группировки","мятежные элементы","миротворческие силы","████████████", "\[ОТРЕДАКТИРОВАНО\]")] начали накапливать оружие и броню. Тем временем цены на продовольствие и полезные ископаемые падают, поскольку местные предприятия пытаются опустошить свои запасы в ожидании мародёрства."
			if(WILD_ANIMAL_ATTACK)
				newMsg.body = "Местная [pick("дичь","фауна")] на планете [affected_dest.name] становится всё более агрессивной и совершает набеги на окраинные поселения в поисках пищи. Для решения проблемы были привлечены охотники на крупную дичь, но уже произошло множество случаев травм."
			if(INDUSTRIAL_ACCIDENT)
				newMsg.body = "[pick("Промышленная авария","Авария на плавильном производстве","Сбой","Неисправное оборудование","Халатное обслуживание","Утечка охлаждающей жидкости","Разрыв трубопровода")] на [pick("заводе","объекте","электростанции","верфи")] на [affected_dest.name] привела к серьёзным повреждениям конструкции и многочисленным травмам. Ремонтные работы продолжаются."
			if(BIOHAZARD_OUTBREAK)
				newMsg.body = "[pick("███████ █████","Биологическая угроза","Вспышка заболевания","Вспышка вируса", "\[ОТРЕДАКТИРОВАНО\]")] на [affected_dest.name] привела к введению карантина, что остановило многие поставки в регионе. Хотя карантин уже снят, власти призывают к доставке медицины для лечения заражённых."
			if(PIRATES)
				newMsg.body = "[pick("Пираты","Преступные элементы","Оперативники [pick("Синдиката","Donk Co.","Waffle Co.","██████████", "\[ОТРЕДАКТИРОВАНО\]")]")] сегодня [pick("установили блокаду","попытались шантажировать","атаковали")] [affected_dest.name]. Меры безопасности были усилены, но множество ценных ресурсов было похищено."
			if(CORPORATE_ATTACK)
				newMsg.body = "Небольшой флот [pick("пиратов","Cybersun Industries","Мародёров Горлекс","Синдиката")] совершил точный прыжок вблизи [affected_dest.name], [pick("для проведения операции \"налёт и захват\"","для атаки по типу \"ударил-убежал\"","для открытой демонстрации враждебности")]. Было нанесено много ущерба, и с тех пор меры безопасности были усилены."
			if(ALIEN_RAIDERS)
				if(prob(20))
					newMsg.body = "Кооператив \"Тигр\" сегодня совершил набег на [affected_dest.name], несомненно, по приказу своих загадочных хозяев. Были похищены дикие животные, сельскохозяйственный скот, материалы для медицинских исследований, а также гражданские лица. НаноТрейзен готовы противодействовать любым попыткам биотерроризма."
				else
					newMsg.body = "[pick("Инопланетный вид, обозначенный как 'Объединённые Экзолитики'","Инопланетный вид, обозначенный как ██████████","Неизвестный инопланетный вид")] сегодня совершил набег на [affected_dest.name], похитив диких животных, сельскохозяйственный скот, материалы для медицинских исследований, а также гражданских лиц. Похоже, они хотят узнать о нас больше, поэтому флот будет готов встретить их в следующий раз."
			if(AI_LIBERATION)
				newMsg.body = "[pick("██████████ был обнаружен ","Оперативник S.E.L.F проник","Злокачественный компьютерный вирус был обнаружен","Хакер был задержан")] на [affected_dest.name] сегодня, и успел заразить [pick("██████████","разумную подсистему","ИИ первого класса","разумную оборонительную установку", "\[ОТРЕДАКТИРОВАНО\]")], прежде чем его остановили. Многие жизни были потеряны, так как система начала методично убивать гражданских лиц, и потребуется много сил для восстановления пострадавших районов."
			if(MOURNING)
				var/locvar = pick("MALE", "FEMALE")
				if (locvar == "MALE")
					newMsg.body = "[pick("Популярный","Любимый","Известный","Знаменитый")]  [pick("профессор","артист","певец","учёный","государственный служащий","администратор","капитан корабля","██████████")], [pick( random_name(MALE), 40; "█████ ███████" )] сегодня [pick("скончался","покончил с собой","был убит","погиб при странных обстоятельствах")] на [affected_dest.name]. "
				else
					newMsg.body = "[pick("Популярная","Любимая","Известная","Знаменитая")]  [pick("профессор","артистка","учёная","государственная служащая","администратор","капитан корабля","██████████")]|, [pick( random_name(FEMALE), 40; "█████ ███████" )] сегодня [pick("скончалась","покончила с собой","была убита","погибла при странных обстоятельствах")] на [affected_dest.name]. "
				newMsg.body += "Вся планета в трауре, а цены на товары упали из-за снижения морального духа рабочих."
			if(CULT_CELL_REVEALED)
				newMsg.body = "[pick("Коварный","Кровожадный","Злодейский","Безумный")] культ [pick("Древних Богов","Нар'си","апокалиптической секты","██████████")] [pick("был обнаружен","раскрыт","раскрыл себя","заявил о себе")] на [affected_dest.name] сегодня ранее. Моральный дух населения пошатнулся из-за того, что [pick("несколько","одна или две")] [pick("известных","популярных","уважаемых")] личности [pick("совершали \[ОТРЕДАКТИРОВАНО\] действия","признали свою принадлежность к культу","поклялись в верности лидеру культа","пообещали помочь культу")], прежде чем виновные были привлечены к ответственности. Редакция напоминает всему персоналу, что всё сверхъестественное недопустимо на объектах НаноТрейзен."
			if(SECURITY_BREACH)
				newMsg.body = "Сегодня утром [pick("произошло нарушение мер безопасности в","произошло несанкционированное проникновение в","произошла попытка кражи в","произошла атака анархистов на","произошёл акт насильственного саботажа в")] [pick("высокозащищённой","закрытой","секретной","\[ОТРЕДАКТИРОВАНО\]", "██████████")] [pick("\[ОТРЕДАКТИРОВАНО\]","секции","зоне","области")]. После инцидента меры безопасности на [affected_dest.name] были усилены, а редакция заверяет весь персонал НаноТрейзен, что такие инциденты - редкость."
			if(ANIMAL_RIGHTS_RAID)
				newMsg.body = "[pick("Члены террористической группы \"Консорциум Защиты Животных\"","Члены террористической группы \[ОТРЕДАКТИРОВАНО\]")] сегодня [pick("начали кампанию террора","учинили волну разрушений","совершили набеги на фермы и пастбища","проникли на \[ОТРЕДАКТИРОВАНО\]")] на [affected_dest.name], освободив множество [pick("сельскохозяйственных животных","животных","\[ОТРЕДАКТИРОВАНО\]")]. В результате цены на приручённых и племенных животных резко выросли."
			if(FESTIVAL)
				newMsg.body = "На [affected_dest.name] объявлен [pick("фестиваль","недельный праздник","день веселья","планетарный праздник")] по инициативе [pick("губернатора","комиссара","генерала","коменданта","администратора")] [random_name(pick(MALE,FEMALE))] в честь [pick("рождения их [pick("сына","дочери")]","совершеннолетия их [pick("сына","дочери")]","усмирения мятежной военной ячейки","задержания опасного преступника, терроризировавшего планету")]. Огромные запасы еды и мяса были закуплены, что привело к росту цен по всей планете."

	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_NYX)?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_NYX)

/datum/event/economic_event/end()
	for(var/good_type in dearer_goods)
		affected_dest.temp_price_change[good_type] = 1
	for(var/good_type in cheaper_goods)
		affected_dest.temp_price_change[good_type] = 1
