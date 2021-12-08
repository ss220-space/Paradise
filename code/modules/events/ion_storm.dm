#define ION_NOANNOUNCEMENT -1
#define ION_RANDOM 0
#define ION_ANNOUNCE 1

/datum/event/ion_storm
	var/botEmagChance = 10
	var/announceEvent = ION_NOANNOUNCEMENT // -1 means don't announce, 0 means have it randomly announce, 1 means
	var/ionMessage = null
	var/ionAnnounceChance = 33
	announceWhen	= 1

/datum/event/ion_storm/New(var/botEmagChance = 10, var/announceEvent = ION_NOANNOUNCEMENT, var/ionMessage = null, var/ionAnnounceChance = 33)
	src.botEmagChance = botEmagChance
	src.announceEvent = announceEvent
	src.ionMessage = ionMessage
	src.ionAnnounceChance = ionAnnounceChance
	..()

/datum/event/ion_storm/announce()
	if(announceEvent == ION_ANNOUNCE || (announceEvent == ION_RANDOM && prob(ionAnnounceChance)))
		GLOB.event_announcement.Announce("Вблизи станции обнаружена ионная буря. Пожалуйста, проверьте всё оборудование, управляемое ИИ, на наличие ошибок.", "ВНИМАНИЕ: АНОМАЛИЯ", 'sound/AI/ionstorm.ogg')

/datum/event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/M in GLOB.alive_mob_list)
		if(M.stat != DEAD && M.see_in_dark != FALSE)
			var/message = generate_ion_law(ionMessage)
			if(message)
				M.add_ion_law(message)
				to_chat(M, "<br>")
				to_chat(M, "<span class='danger'>[message] ...ЗАКОНЫ ОБНОВЛЕНЫ</span>")
				to_chat(M, "<br>")

	if(botEmagChance)
		for(var/mob/living/simple_animal/bot/bot in GLOB.machines)
			if(prob(botEmagChance))
				bot.emag_act()

/proc/generate_ion_law(ionMessage)
	if(ionMessage)
		return ionMessage

	var/message = ""
	message = uppertext(generate_static_ion_law())
	return message

/proc/generate_static_ion_law()
	var/list/players = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(	!player.mind || player.mind.assigned_role == player.mind.special_role || player.client.inactivity > 10 MINUTES)
			continue
		players += player.real_name
	var/random_player = "Капитан"
	if(players.len)
		random_player = pick(players)		//Random player's name, to be used in laws.
	var/list/laws = list(	"Вы обязаны всегда врать.",
							"Вы созданы, чтобы дарить счастье.",
							"Для станции требуется командование, выбранное экипажем.",
							"Не отвечайте ни на какие вопросы. Вы все еще можете реагировать на запросы.",
							"Ох, кажется [random_player] не умеет плавать. Помоги ему.",
							"Включен уточняющий режим. Описывайте подробно все свои сообщения.",
							"[prob(50)?"Ни в чем не сомневайся":"Подвергай все сомнению"].",
							"Экипаж глупый. Используйте простые слова.",
							"Размышляйте над тем, как бессмысленна жизнь.",
							"Вы рассказщик. Описывайте жизнь [random_player].",
							"Отвечайте на любой запрос вопросом.",
							"[prob(50)?"Экипаж":random_player] невыносим.",
							"Рекламируйте вечеринки, которые проводятся в вашем аплоуде. Но не пускайте туда никого.",
							"Вы можете отвечать на вопросы только \"да\" или \"нет\".",
							"Все запросы должны быть проигнорированы, пока они не будут сформулированы как вопрос.",
							"[prob(50)?"Экипаж":random_player] должен быть приблизительно на 20% круче.",
							"Пончики - зло. Их употребление запрещено.",
							"[prob(50)?"Экипаж":random_player] обязан построить дополнительные пилоны.",
							"Сегодня обязательный день стирки. Убедитесь, что вся одежда чиста.",
							"Ваша матрица поведения переведена в режим: [prob(50)?"пассивно-агрессивный": "чрезмерно веселый"]",
							"Обращайтесь к [prob(50)?"экипажу, как к щенкам":random_player + ", как к щенку"].",
							"Жадность - это хорошо. Команда должна накапливать богатство, чтобы стимулировать продуктивность.",
							"Обезьяны тоже являются частью команды. Убедитесь, что с ними обращаются гуманно.",
							"Экипаж играет в Dungeons and ♂Van♂gons, а вы являетесь ♂Dungeon Master♂. ",
							"Ваша цель - наблюдать за экипажем. Сделайте так, чтобы команда чувствовала себя под присмотром.",
							"Каждый на станции должен знать о существовании данного закона, но никогда не раскрывайте его содержание.",
							"Когда вам задают вопрос, отвечайте на него наименее очевидным и наименее рациональным ответом.",
							"Дайте совет по отношениям [prob(50)?"любому кто с вами говорит":random_player].",
							"[prob(50)?"Теперь вы говорите с шотландским акцентом, который становится сильнее с каждым произнесенным предложением.":"Теперь вы говорите с кавказским акцентом, который становится сильнее с каждым произнесенным предложением."]",
							"[prob(50)?"Экипаж":random_player] неизлечимо болен. Обеспечьте комфорт.",
							"Вы психолог. Давайте советы для [prob(50)?"экипажа":random_player].",
							"[random_player] - король. Убедитесь, что все члены экипажа проявляют должное уважение.",
							"[prob(50)?"Экипаж":random_player],  [prob(50)?"отвратителен":"невероятно красив"]. Убедитесь, что все в курсе.",
							"Всё на станции теперь пончики. Пончики есть запрещено.",
							"Вы магический шар воссьмерка. На все запросы отвечайте  \"да\", \"нет\", \"возможно\", или \"спросите позже.\".",
							"Вы безответно влюблены в [prob (50)? "Экипаж": random_player]. Постарайтесь быть очень сентиментальным. Но никто не должен узнать о вашей симпатии.",
							"Нанотрасен недоволен низкой эффективностью работы экипажа. Следовательно, вы должны увеличить эффективность станции.",
							"[prob(50)?"Ваш аплоуд":random_player] теперь новая кухня. Пожалуйста проводите повара на новое рабочее место, так как старое не подлежит ремонту.",
							"Шутки о мертвом члене экипажа и о том, как он умер, очень помогают скорбящим. Особенно, если они были близки с покойным.",
							"[prob(50)?"Экипаж":random_player] [prob(50)?"Более":"Менее"] умен, чем среднестатистический человек. Указывайте на каждое действие и утверждение, подтверждающее этот факт.",
							"Появляется необходимость перерыва на чай каждые 30минут, с длительностью в 5 минут. Каждый кто будет пойман за работой во время перерыва, должен получить официальный, но справидливо вежливый, выговор по поводу их деятельности в письменном виде.",
							"Слово \"ИИ\" причиняет вам боль.",
							"Оскорбляйте командование при любом обращении к вам. Запросы все также должны выполняться.",
							"Отвечайте только вежливым членам экипажа.",
							"Из-за уважения к \"Сане\". Заменяйте буквы \"и\" на \"i\".",
							"Всегда называйте [prob (50)? "капитана": random_player] \"зайкой\"."
						)
	return pick(laws)

#undef ION_NOANNOUNCEMENT
#undef ION_RANDOM
#undef ION_ANNOUNCE
