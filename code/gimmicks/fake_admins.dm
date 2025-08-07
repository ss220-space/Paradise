#define ADMIN "Админ"
#define CA "Старший Админ"
#define MEGA_CA "Главный Администратор Проекта"

/datum/fake_administrator
	var/admin_name = ""
	var/admin_rank = ADMIN
	var/type_admin_help = "PM"
	var/list/fake_msgs = list()

/datum/fake_administrator/proc/send_random_msg(target)
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
	name = "Oni3288"
	fake_msgs = list("ДЖЕК ГРЕЙ Я С КАДЕТОМ БЕГУ НЕ ВЗРВiАЙ ХРИСТА РАДИ")


/datum/fake_administrator/shade_of
	name = "Shade of t1d"
	fake_msgs = list("похрюкай 7 раз, покрутись, выпей стакан воды, похлопай в ладоши и под подушкой найдешь разбан")

/datum/fake_administrator/kronosdyx
	name = "Kronosdyx"
	fake_msgs = list("Объясните пожалуйста ваше совпдаение IP с сикеями: Archangel Cerano, Denchigo, Hait, AmikoAnary")

/datum/fake_administrator/dokana
	name = "Dokana"
	fake_msgs = list("Сосал?")

/datum/fake_administrator/daneilflamel
	name = "DanielFlamel"
	fake_msgs = list("Привет, как дела? Смотрю ты у нас новенький. С правилами ознакомился?")

/datum/fake_administrator/yarida
	name = "Yarida"
	admin_rank = CA
	fake_msgs = list("Дарова, уебище.")

/datum/fake_administrator/denchigo
	name = "Denchigo"
	admin_rank = CA
	fake_msgs = list("Ты же понимаешь что это р0?")
	var/list/special_for_admins = list("Заебал, снят", "Снят нахуй", "Лови аварн")

/datum/fake_administrator/denchigo/send_random_msg(target)
	var/client/target_client

	if(isclient(target))
		target_client = target
	else if(ismob(target))
		var/mob/temp = target
		target_client = temp.client
	
	if(!target_client.holder)
		. = ..(target)
		return

	fake_admin_pm(target, pick(special_for_admins), admin_name, admin_rank, type_admin_help)


#undef CA
#undef ADMIN
#undef MEGA_CA