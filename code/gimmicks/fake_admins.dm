
//Admins ranks
#define BH_ADMIN "Админ"
#define BH_ADMIN_SA "Старший Админ" //senior admin
#define BH_HSA "Главный Администратор Проекта" //head senior admin
#define BH_TRIAL "Триал Админ"
#define BH_MENTOR "Ментор"

#define BH_ALL_ADMINS_RANK list(BH_ADMIN, BH_ADMIN_SA, BH_HSA, BH_TRIAL, BH_MENTOR)

//Other ranks
#define BH_DEVELOPER "Разработчик"
#define BH_LEAD_DEVELOPER "Ведущий Разработчик" 
#define BH_CONTRIBUTOR "Контрибьютор"

#define BH_DEVELOPENT_STAFF list(BH_DEVELOPER, BH_CONTRIBUTOR, BH_LEAD_DEVELOPER)

//Helpers type
#define BH_MENTOR_HELP "Помощь Ментора"
#define BH_ADMIN_PM "PM"

/datum/fake_administrator
	var/admin_name = ""
	var/admin_rank = BH_ADMIN
	var/type_admin_help = BH_ADMIN_PM
	var/list/fake_msgs = list()
	var/list/special_msgs_for_rank = list() //format: list(list(ADMIN_SA, HADMIN_SA) = list("Снят нахуй"))

/datum/fake_administrator/proc/send_random_msg(target)
	if(!target)
		return
	
	var/client/target_client

	if(isclient(target))
		target_client = target
	else if(ismob(target))
		var/mob/temp = target
		target_client = temp.client
	else
		return
	
	var/fake_msg = pick(fake_msgs)

	if(length(special_msgs_for_rank) && target_client.holder)
		for(var/list/roles_target in special_msgs_for_rank)
			if(target_client.holder.rank in roles_target)
				fake_msg = pick(special_msgs_for_rank[roles_target])
				break

	fake_admin_pm(target, fake_msg, admin_name, admin_rank, type_admin_help)

/datum/fake_administrator/momongo
	admin_name = "Momong0"
	fake_msgs = list("Ебать рецедивов. Перма")

/datum/fake_administrator/jaba
	admin_name = "jaba213"
	fake_msgs = list("Здравствуйте. Информируем вас, что охота за ролью антогониста, не приветсвуется на нашем сервере. За вами это замечается не впервые")

/datum/fake_administrator/cerano
	admin_name = "Archangel Cerano"
	admin_rank = BH_ADMIN_SA
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
	admin_rank = BH_ADMIN_SA
	fake_msgs = list("Дарова, уебище.")

/datum/fake_administrator/denchigo
	admin_name = "Denchigo"
	admin_rank = BH_HSA
	fake_msgs = list("Ты же понимаешь что это р0?", "Погнали на БМ")
	special_msgs_for_rank = list(ALL_ADMINS_RANK = list("Заебал, снят", "Снят нахуй", "Лови аварн"))

/datum/fake_administrator/alexsandoor
	admin_name = "AlexsanDOOR"
	admin_rank = BH_TRIAL
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
	admin_rank = BH_TRIAL
	fake_msgs = list("Пермой в глаз? Или \"под-расстрелом\" раз?", "сразу по шапке дать или объяснишься?")

/datum/fake_administrator/amikpanary
	admin_name = "AmikoAnary"
	admin_rank = BH_ADMIN_SA
	fake_msgs = list("Ты чего творишь то?")

/datum/fake_administrator/twojadezero
	admin_name = "2Jade0"
	fake_msgs = list("А вы че думали? Не думайте.")

/datum/fake_administrator/dageavtobusik
	admin_name = "Dageavtobusnik"
	fake_msgs = list("Тогда я нихуя не понимаю")
	special_msgs_for_rank = list(BH_DEVELOPENT_STAFF = list("Do not merge", "Такое говно в билд не пойдет", "Хуйня переделывай"))

