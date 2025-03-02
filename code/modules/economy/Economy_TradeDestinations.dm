
GLOBAL_LIST_EMPTY(weighted_randomevent_locations)
GLOBAL_LIST_EMPTY(weighted_mundaneevent_locations)

/datum/trade_destination
	var/name = ""
	var/description = ""
	var/distance = 0
	var/list/willing_to_buy = list()
	var/list/willing_to_sell = list()
	var/can_shuttle_here = 0		//one day crew from the exodus will be able to travel to this destination
	var/list/viable_random_events = list()
	var/list/temp_price_change[BIOMEDICAL]
	var/list/viable_mundane_events = list()

/datum/trade_destination/proc/get_custom_eventstring(var/event_type)
	return null

//distance is measured in AU and co-relates to travel time
/datum/trade_destination/centcomm
	name = "ЦК"
	description = "Административный центр НаноТрейзен для системы Тау Кита."
	distance = 1.2
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, CORPORATE_ATTACK, AI_LIBERATION)
	viable_mundane_events = list(ELECTION, RESIGNATION, CELEBRITY_DEATH)

/datum/trade_destination/anansi
	name = "ИСН \"Ананси\""
	description = "Медицинская станция, принадлежащая НаноТрейзен и управляемая Вторым Красным Крестом. Предназначена для обработки экстренных случаев с ближайших колоний."
	distance = 1.7
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, CULT_CELL_REVEALED, BIOHAZARD_OUTBREAK, PIRATES, ALIEN_RAIDERS)
	viable_mundane_events = list(RESEARCH_BREAKTHROUGH, RESEARCH_BREAKTHROUGH, BARGAINS, GOSSIP)

/datum/trade_destination/anansi/get_custom_eventstring(var/event_type)
	if(event_type == RESEARCH_BREAKTHROUGH)
		return "Благодаря исследованию, проведенному на МКН Ананси, Второе общество Красного Креста хотело бы объявить о крупном прорыве в области \
		[pick("взаимодействия разума и машины", "нейробиологии", "наноаугментаций", "генетики")]. Ожидается, что в течение двух недель НаноТрейзен объявит о заключении соглашения о сотрудничестве."
	return null

/datum/trade_destination/icarus
	name = "ИКН \"Икар\""
	description = "Корвет, назначенный для патрулирования космического пространства в секторе станции."
	distance = 0.1
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, AI_LIBERATION, PIRATES)

/datum/trade_destination/redolant
	name = "СОА \"Редолант\""
	description = "Станция Осирис Атмосферикс на орбите газового гиганта (пока безымянного). Боевые корабли OA защищают свою установку и контролируют судоходство вблизи планеты, что, собственно говоря, не редкость в Тау Кита. НаноТрейзен со скрипом терпят чужое военно-космическое присутствие в обмен на долю прибыли с этого предприятия."
	distance = 0.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(INDUSTRIAL_ACCIDENT, PIRATES, CORPORATE_ATTACK)
	viable_mundane_events = list(RESEARCH_BREAKTHROUGH, RESEARCH_BREAKTHROUGH)

/datum/trade_destination/redolant/get_custom_eventstring(var/event_type)
	if(event_type == RESEARCH_BREAKTHROUGH)
		return "Благодаря исследованиям, проведенным над НИС Редолант, Осирис Атмосферикс хочет объявить о крупном прорыве в области \
		[pick("исследования плазмы", "емкости потока высокой энергии", "сверхсжатых материалов", "теоретической физики элементарных частиц")]. Ожидается, что в течение двух недель НаноТрейзен объявит о заключении соглашения о сотрудничестве."
	return null

/datum/trade_destination/beltway
	name = "Горнодобывающая цепь \"Белтвей\""
	description = "Совместный проект Белтвей и НаноТрейзен по разработке богатого внешнего пояса астероидов системы Тау Кита."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(PIRATES, INDUSTRIAL_ACCIDENT)
	viable_mundane_events = list(TOURISM)

/datum/trade_destination/biesel
	name = "\"Бизель\""
	description = "Крупные верфи, сильная экономика и стабильное, образованное население. Бизель в основном сохраняет верность Сол и с неохотой терпит НаноТрейзен. Столица – Лоуэлл-Сити."
	distance = 2.3
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RIOTS, INDUSTRIAL_ACCIDENT, BIOHAZARD_OUTBREAK, CULT_CELL_REVEALED, FESTIVAL, MOURNING)
	viable_mundane_events = list(BARGAINS, GOSSIP, SONG_DEBUT, MOVIE_RELEASE, ELECTION, TOURISM, RESIGNATION, CELEBRITY_DEATH)

/datum/trade_destination/new_gibson
	name = "\"Нью-Гибсон\""
	description = "Сильно индустриализированная каменистая планета, содержащая большинство планетарных ресурсов системы. Нью-Гибсон разрывается от беспорядков и имеет мало собственного богатства, кроме того, что находится в руках корпораций, конкурирующих с НаноТрейзен за контроль."
	distance = 6.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RIOTS, INDUSTRIAL_ACCIDENT, BIOHAZARD_OUTBREAK, CULT_CELL_REVEALED, FESTIVAL, MOURNING)
	viable_mundane_events = list(ELECTION, TOURISM, RESIGNATION)

/datum/trade_destination/luthien
	name = "\"Лютиен\""
	description = "Небольшая колония, основанная на диком, необузданном мире (в основном джунгли). Дикари и дикие звери регулярно атакуют аванпост, хотя НаноТрейзен сохраняет жёсткий военный контроль."
	distance = 8.9
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(WILD_ANIMAL_ATTACK, CULT_CELL_REVEALED, FESTIVAL, MOURNING, ANIMAL_RIGHTS_RAID, ALIEN_RAIDERS)
	viable_mundane_events = list(ELECTION, TOURISM, BIG_GAME_HUNTERS, RESIGNATION)

/datum/trade_destination/reade
	name = "\"Рид\""
	description = "Холодный мир с дефицитом металлов. НаноТрейзен поддерживает обширные добывающие комплексы на доступных территориях, пытаясь извлечь хоть что-то из этой бесприбыльной колонии."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(WILD_ANIMAL_ATTACK, CULT_CELL_REVEALED, FESTIVAL, MOURNING, ANIMAL_RIGHTS_RAID, ALIEN_RAIDERS)
	viable_mundane_events = list(ELECTION, TOURISM, BIG_GAME_HUNTERS, RESIGNATION)
