/datum/event/pda_spam
	endWhen = 36000
	var/last_spam_time = 0
	var/obj/machinery/message_server/useMS

/datum/event/pda_spam/setup()
	last_spam_time = world.time
	pick_message_server()

/datum/event/pda_spam/proc/pick_message_server()
	if(GLOB.message_servers)
		for(var/obj/machinery/message_server/MS in GLOB.message_servers)
			if(MS.active)
				useMS = MS
				break

/datum/event/pda_spam/tick()
	if(world.time > last_spam_time + 3000)
		//if there's no spam managed to get to receiver for five minutes, give up
		kill()
		return

	if(!useMS || !useMS.active)
		useMS = null
		pick_message_server()

	if(useMS)
		if(prob(5))
			// /obj/machinery/message_server/proc/send_pda_message(var/recipient = "",var/sender = "",var/message = "")
			var/list/viables = list()
			for(var/obj/item/pda/check_pda in GLOB.PDAs)
				var/datum/data/pda/app/messenger/check_m = check_pda.find_program(/datum/data/pda/app/messenger)

				if(!check_m || !check_m.can_receive())
					continue
				viables.Add(check_pda)

			if(!viables.len)
				return
			var/obj/item/pda/P = pick(viables)
			var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

			var/sender
			var/message
			switch(pick(1,2,3,4,5,6,7))
				if(1)
					sender = pick("'Богатый Ларри'","Онлайн казино 'Богатый Ларри'","НЕ УПУСТИ МОМЕНТ - РЕГИСТРИРУЙСЯ","Рад, что ты присоединился к нам")
					message = pick("Утрой свои вложения! Всё что нужно - зарегистрироваться в онлайн казино 'Богатый Ларри'",\
					"ТОЛЬКО СЕГОДНЯ! 200% бонус при первом пополнении. Регистрируйся в онлайн казино 'Богатый Ларри'",\
					"Еженедельные и ежемесячные бонусы уже ждут ТЕБЯ! Регистрируйся в онлайн казино 'Богатый Ларри'",\
					"Более чем 450 первоклассных игр ждут ТЕБЯ! Регистрируйся в онлайн казино 'Богатый Ларри'")
				if(2)
					sender = pick(300;"Быстрые свидания 'L.O.V.E'",200;"Найди свою русскую невестку",50;"Таяранские красавицы уже ждут тебя",50;"Горячие скреллы хотят 'согреться' с тобой",50;"Красивые невестки унатхи уже ждут своего жениха")
					message = pick("Хэй, красавчик! Твой аккаунт привлёк меня... Привет ~ Давай встретимся? (Быстрые свидания 'L.O.V.E').",\
					"Если ты напишешь мне на почту - [pick(GLOB.first_names_female)]@[pick(GLOB.last_names_female)].[pick("ru","ck","tj","ur","nt")], то я обязательно скину тебе фоточку ~ <3 (Быстрые свидания 'L.O.V.E').",\
					"Привет, я хочу чтобы мы писали друг другу и... Я надеюсь, что ты лайкнешь мой профиль и ответишь мне. (Быстрые свидания 'L.O.V.E).",\
					"У вас (1) новое сообщение!",\
					"У вас (2) новых посещения профиля!")
				if(3)
					sender = pick("Ассоциация галактических платежей","Бюро 'Лучший бизнес'","Электронные платежи 'XYU'","Финансовый департамент НануТруйзен","Роскошные Копии")
					message = pick("Роскошные часы по броским ценам!",\
					"Ювелирные изделия и аксессуары, сумки и кошельки, а также часы!",\
					"Вложи 100$ и получи 300$ АБСОЛЮТНО БЕСПЛАТНО!",\
					"Украшения в стилистике NanoTrasen? Всего за 89$?!",\
					"Нам поступила жалоба от одного из ваших клиентов. Выплатите компенсацию в размере 49$ на счёт отправителя.",\
					"Убедительная просьба открыть ОТЧЁТ О ЖАЛОБЕ (прилагается к сообщению), чтобы... Ответить на данную жалобу?..")
				if(4)
					sender = pick("Купи Др.Большой Ч","У вас дисфункциональные проблемы?")
					message = pick("ДОКТОР БОЛЬШОЙ Ч: НАСТОЯЩИЕ Доктора, НАСТОЯЩИЕ Учёные, НАСТОЯЩИЕ Результаты!",\
					"Др. Большой Ч был создан Бобом Мелкий Х, доктор медицинских наук, сертицированный ЦК уролог, котороый помог боле чем 70,000 пациентам со всей Галактики справиться с их 'мужскими проблемами'.",\
					"После семи лет исследований доктор Мелкий Х и его команда разработали эту простую революционную формулу улучшения мужских способностей.",\
					"Мужчины всех видов сообщают об УДИВИТЕЛЬНОМ увеличении длины, ширины и выносливости.")
				if(5)
					sender = pick("Доктор","Наследный принц","Король-регент","Профессор","Капитан")
					sender += " " + pick("Роберт","Альфред","Дорин","Карл","Тодд","Жбани")
					sender += " " + pick("Вузави","Серый","Златоволосый","Привелкательный","II Решительный","XXXII Вечноправящий")
					message = pick("ВАШ КАПИТАЛ БЫЛ ПЕРЕВЕДЁН В БАНК РАЗВИТИЯ СИСТЕМЫ [pick("Салуса","Сегунда","Цефей","Андромеда","Груис","Корона","Аквила","АРЕС","Аселлус")].",\
					"Мы рады сообщить вам, что в связи с задержкой нам было поручено НЕМЕДЛЕННО внести все средства на ваш счет",\
					"Уважаемый получатель средств, сообщаем вам, что просроченный платеж окончательно утвержден и выпущен для оплаты",\
					"Так как у меня нет посредников, мне необходим счёт за пределами системы, чтобы срочно внести туда сумму в 1,5 МИЛЛИОНА КРЕДИТОВ!",\
					"Приветствую вас, сэр. Я с сожалением сообщаю вам, что, умирая здесь в отсутсвии наследников, я выбрал вас, чтобы передать полную сумму моих сбережений в размере 1,5 миллиарда кредитов")
				if(6)
					sender = pick("Отдел мотивации NanoTrasen","Чувствуешь себя одиноко?","Скучаешь?","www.wetskrell.nt")
					message = pick("Отдел мотивации NanoTrasen делится с вами лучшим сайтом равзлечений для взрослых",\
					"WetSkrell.nt - это ксенофильный веб-сайт, одобренный NanoTrasen для использования членами экипажа мужского пола среди множества станций и аванпостов.",\
					"Wetskrell.nt предоставляет только высококачественные развлечения для мужчин, сотрудников Nanotrasen.",\
					"Просто введите номер своего банковского счета NanoTrasen и pin-код. Только эти три простых шагов отделяют тебя от океана скользких удовольствий!")
				if(7)
					sender = pick("Вы выиграли БЕСПЛАТНЫЕ билеты!","Нажмите ->СЮДА<- чтобы забрать свой ПРИЗ!","Вы десятитысячный посетитель!","Вы счастливый обладатель главного приза!")
					message = pick("Вы выиграли билеты на новейший экшн фильм 'Крутой сын Джека'!",\
					"Вы выиграли билеты на новейшую криминальную драму 'Тайна детектива-соблазнителя'!",\
					"Вы выиграли билеты на новейшую романтическую комедию '69 правил любви'!",\
					"Вы выиграли билеты на новейший триллер 'Культ спящего Хонка'!")

			if(useMS.send_pda_message("[P.owner]", sender, message))	//Message been filtered by spam filter.
				return

			last_spam_time = world.time

			if(prob(50)) //Give the AI an increased chance to intercept the message
				for(var/mob/living/silicon/ai/ai in GLOB.mob_list)
					// Allows other AIs to intercept the message but the AI won't intercept their own message.
					if(ai.aiPDA != P && ai.aiPDA != src)
						ai.show_message("<i>Перехваченное сообщение от <b>[sender]</b></i> (Unknown / spam?) <i>для <b>[P:owner]</b>: [message]</i>")

			PM.notify("<b>Сообщение от [sender] (Неизвестного / Спам?), </b>\"[message]\" (Не доступно для ответа)", 0)
