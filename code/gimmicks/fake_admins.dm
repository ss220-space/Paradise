#define ADMIN "Админ"
#define CA "Старший Админ"
#define MEGA_CA "Главный Администратор Проекта"
#define TRIAL "Триал Админ"

/datum/fake_administrator
	var/admin_name = ""
	var/admin_rank = ADMIN
	var/type_admin_help = "PM"
	var/list/fake_msgs = list()

/datum/fake_administrator/proc/send_random_msg(target)
	if(!target)
		return
	fake_admin_pm(target, pick(fake_msgs), admin_name, admin_rank, type_admin_help)

/datum/fake_administrator/momongo
	admin_name = "Momong0"
	fake_msgs = list("Ебать рецедивов. Перма")

/datum/fake_administrator/jaba
	admin_name = "jaba213"
	fake_msgs = list("Здравствуйте. Информируем вас, что охота за ролью антогониста, не приветсвуется на нашем сервере. За вами это замечается не впервые")

/datum/fake_administrator/cerano
	admin_name = "Archangel Cerano"
	admin_rank = CA
	type_admin_help = "Помощь Админа"
	fake_msgs = list("Ноулак, поплач")

/datum/fake_administrator/onik
	admin_name = "Oni3288"
	fake_msgs = list("ДЖЕК ГРЕЙ Я С КАДЕТОМ БЕГУ НЕ ВЗРВiАЙ ХРИСТА РАДИ")


/datum/fake_administrator/shade_of
	admin_name = "Shade of t1d"
	fake_msgs = list("похрюкай 7 раз, покрутись, выпей стакан воды, похлопай в ладоши и под подушкой найдешь разбан")

/datum/fake_administrator/kronosdyx
	admin_name = "Kronosdyx"
	fake_msgs = list("Объясните пожалуйста ваше совпдаение IP с сикеями: Archangel Cerano, Denchigo, Hait, AmikoAnary")

/datum/fake_administrator/dokana
	admin_name = "Dokana"
	fake_msgs = list("Сосал?", "Пидорасом для этого быть не обязательно")

/datum/fake_administrator/daneilflamel
	admin_name = "DanielFlamel"
	fake_msgs = list("Привет, как дела? Смотрю ты у нас новенький. С правилами ознакомился?")

/datum/fake_administrator/yarida
	admin_name = "Yarida"
	admin_rank = CA
	fake_msgs = list("Дарова, уебище.")

/datum/fake_administrator/denchigo
	admin_name = "Denchigo"
	admin_rank = MEGA_CA
	fake_msgs = list("Ты же понимаешь что это р0?")
	var/list/special_for_admins = list("Заебал, снят", "Снят нахуй", "Лови аварн")

/datum/fake_administrator/denchigo/send_random_msg(target)
	var/client/target_client

	if(isclient(target))
		target_client = target
	else if(ismob(target))
		var/mob/temp = target
		target_client = temp.client
	else
		return

	if(!target_client.holder)
		. = ..(target)
		return

	fake_admin_pm(target, pick(special_for_admins), admin_name, admin_rank, type_admin_help)

/datum/fake_administrator/alexsandoor
	admin_name = "AlexsanDOOR"
	admin_rank = TRIAL
	fake_msgs = list("Привет, объяснишь что было?")

/datum/fake_administrator/hrober
	admin_name = "Hrober"
	fake_msgs = list("Ну че, на недельку тебя ушатать, или попробуешь оправдаться?", "Ниче не перепутал?")

/datum/fake_administrator/flynfox
	admin_name = "Fly1nFOx"
	fake_msgs = list("Видел тебя на блюмуне. У нас таких не любят. Обжалование через 3 месяца.",
	 "Короче, пиши тикеты более нормально и подробно. А по рофлотикету - нельзя",
	 "Вместо антажки я могу дать тебе перму")

/datum/fake_administrator/qvabro
	admin_name = "Qvabro"
	fake_msgs = list("на клыка будешь брать?")

/datum/fake_administrator/smailfeed
	admin_name = "Smailfeed"
	fake_msgs = list("ВатерПотасиумович, тебе не надоело?")

/datum/fake_administrator/smileycom
	admin_name = "SmiLeYcom"
	fake_msgs = list("Я смотрю ты страх потерял, да?", "Приветы. Побеждает тот, кто принесёт диск на ЦК.")

/datum/fake_administrator/dimasina
	admin_name = "D1masina"
	fake_msgs = list("разрешите доебаться?", "Skill issue", "Сгорел - проиграл")

/datum/fake_administrator/blanedancer
	admin_name = "BlaneDancer"
	admin_rank = TRIAL
	fake_msgs = list("Пермой в глаз? Или \"под-расстрелом\" раз?", "сразу по шапке дать или объяснишься?")

/datum/fake_administrator/amikpanary
	admin_name = "AmikoAnary"
	admin_rank = CA
	fake_msgs = list("Ты чего творишь то?")

/datum/fake_administrator/twojadezero
	admin_name = "2Jade0"
	fake_msgs = list("А вы че думали? Не думайте.")

/datum/fake_administrator/dageavtobusik
	admin_name = "Dageavtobusnik"
	fake_msgs = list("Тогда я нихуя не понимаю")
	var/static/list/target_ranks = list("Разработчик", "Контрибьютор")
	var/static/list/special_msgs = list("Do not merge", "Такое говно в билд не пойдет", "Хуйня переделывай")


/datum/fake_administrator/dageavtobusik/send_random_msg(target)
	var/client/target_client

	if(isclient(target))
		target_client = target
	else if(ismob(target))
		var/mob/temp = target
		target_client = temp.client
	else
		return

	if(!target_client.holder)
		. = ..(target)
		return	
	if(!(target_client.holder.rank in target_ranks))
		. = ..(target)
		return

	fake_admin_pm(target, pick(special_msgs), admin_name, admin_rank, type_admin_help)

#undef TRIAL
#undef CA
#undef ADMIN
#undef MEGA_CA
