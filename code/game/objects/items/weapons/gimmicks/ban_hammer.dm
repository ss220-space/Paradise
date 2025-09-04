#define BH_ADMIN "Админ"
#define BH_ADMIN_SA "Старший Админ" // Senior administrator
#define BH_HSA "Главный Администратор Проекта" // Head senior administrator
#define BH_TRIAL "Триал Админ"

/// List of all administrative ranks
#define BH_ALL_ADMINS_RANK list(BH_ADMIN, BH_ADMIN_SA, BH_HSA, BH_TRIAL)

#define BH_DEVELOPER "Разработчик"
#define BH_LEAD_DEVELOPER "Ведущий Разработчик"
#define BH_CONTRIBUTOR "Контрибьютор"

/// List of all development staff ranks
#define BH_DEVELOPENT_STAFF list(BH_DEVELOPER, BH_CONTRIBUTOR, BH_LEAD_DEVELOPER)

#define BH_ADMIN_PM "PM"

/datum/fake_administrator
	/// Name of the fake administrator
	var/admin_name = ""
	/// Rank of the fake administrator
	var/admin_rank = BH_ADMIN
	/// Type of admin help message to display
	var/type_admin_help = BH_ADMIN_PM
	/// List of random messages this fake admin can send
	var/list/fake_msgs = list()
	/// Special messages for specific recipient ranks (assoc list: list(ranks) -> list(messages))
	var/list/special_msgs_for_rank = list()

/// Sends a random message from the fake admin's message list to the target
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
	fake_msgs = list(
		"Ебать рецедивов. Перма"
	)

/datum/fake_administrator/jaba
	admin_name = "jaba213"
	fake_msgs = list(
		"Здравствуйте. Информируем вас, что охота за ролью антогониста, не приветсвуется на нашем сервере. За вами это замечается не впервые"
	)

/datum/fake_administrator/cerano
	admin_name = "Archangel Cerano"
	admin_rank = BH_ADMIN_SA
	type_admin_help = "Помощь Админа"
	fake_msgs = list(
		"Ноулак, поплач"
	)

/datum/fake_administrator/onik
	admin_name = "Oni3288"
	fake_msgs = list(
		"ДЖЕК ГРЕЙ Я С КАДЕТОМ БЕГУ НЕ ВЗРВiАЙ ХРИСТА РАДИ"
	)


/datum/fake_administrator/shade_of
	admin_name = "Shade of t1d"
	fake_msgs = list(
		"похрюкай 7 раз, покрутись, выпей стакан воды, похлопай в ладоши и под подушкой найдешь разбан"
	)

/datum/fake_administrator/kronosdyx
	admin_name = "Kronosdyx"
	fake_msgs = list(
		"Объясните пожалуйста ваше совпдаение IP с сикеями: Archangel Cerano, Denchigo, Hait, AmikoAnary"
	)

/datum/fake_administrator/dokana
	admin_name = "Dokana"
	fake_msgs = list(
		"Сосал?",
		"Пидорасом для этого быть не обязательно"
	)

/datum/fake_administrator/daneilflamel
	admin_name = "DanielFlamel"
	fake_msgs = list(
		"Привет, как дела? Смотрю ты у нас новенький. С правилами ознакомился?"
	)

/datum/fake_administrator/yarida
	admin_name = "Yarida"
	admin_rank = BH_ADMIN_SA
	fake_msgs = list(
		"Дарова, уебище."
	)

/datum/fake_administrator/denchigo
	admin_name = "Denchigo"
	admin_rank = BH_HSA
	fake_msgs = list(
		"Ты же понимаешь что это р0?",
		"Погнали на БМ"
	)
	special_msgs_for_rank = list(BH_ALL_ADMINS_RANK = list(
		"Заебал, снят",
		"Снят нахуй",
		"Лови аварн"
	))

/datum/fake_administrator/alexsandoor
	admin_name = "AlexsanDOOR"
	admin_rank = BH_TRIAL
	fake_msgs = list(
		"Привет, объяснишь что было?"
	)

/datum/fake_administrator/hrober
	admin_name = "Hrober"
	fake_msgs = list(
		"Ну че, на недельку тебя ушатать, или попробуешь оправдаться?",
		"Ниче не перепутал?"
	)

/datum/fake_administrator/flynfox
	admin_name = "Fly1nFOx"
	fake_msgs = list(
		"Видел тебя на блюмуне. У нас таких не любят. Обжалование через 3 месяца.",
		"Короче, пиши тикеты более нормально и подробно. А по рофлотикету - нельзя",
		"Вместо антажки я могу дать тебе перму"
	)

/datum/fake_administrator/qvabro
	admin_name = "Qvabro"
	fake_msgs = list(
		"на клыка будешь брать?"
	)

/datum/fake_administrator/smailfeed
	admin_name = "Smailfeed"
	fake_msgs = list(
		"ВатерПотасиумович, тебе не надоело?"
	)

/datum/fake_administrator/smileycom
	admin_name = "SmiLeYcom"
	fake_msgs = list(
		"Я смотрю ты страх потерял, да?",
		"Приветы. Побеждает тот, кто принесёт диск на ЦК."
	)

/datum/fake_administrator/dimasina
	admin_name = "D1masina"
	fake_msgs = list(
		"разрешите доебаться?",
		"Skill issue",
		"Сгорел – проиграл"
	)

/datum/fake_administrator/blanedancer
	admin_name = "BlaneDancer"
	admin_rank = BH_TRIAL
	fake_msgs = list(
		"Пермой в глаз? Или \"под-расстрелом\" раз?",
		"сразу по шапке дать или объяснишься?"
	)

/datum/fake_administrator/amikpanary
	admin_name = "AmikoAnary"
	admin_rank = BH_ADMIN_SA
	fake_msgs = list(
		"Ты чего творишь то?"
	)

/datum/fake_administrator/twojadezero
	admin_name = "2Jade0"
	fake_msgs = list(
		"А вы че думали? Не думайте."
	)

/datum/fake_administrator/dageavtobusik
	admin_name = "Dageavtobusnik"
	fake_msgs = list(
		"Тогда я нихуя не понимаю"
	)
	special_msgs_for_rank = list(BH_DEVELOPENT_STAFF = list(
		"Do not merge",
		"Такое говно в билд не пойдет",
		"Хуйня переделывай"
	))

// Global list to cache all fake administrator instances
GLOBAL_LIST_EMPTY(cached_fake_admins)

/proc/fake_admin_pm(target, msg = "Привет, есть минутка?", fake_admin_name = "Denchigo", fake_admin_rank = BH_ADMIN, type_admin_help = BH_ADMIN_PM, custom_link = "")
	var/msg_to_target = chat_box_ahelp(span_adminhelp("[type_admin_help] from-<b>[fake_admin_rank] <a href='[custom_link]'>[fake_admin_name]</a></b>:<br><br>[span_emojienabled("[msg]")]<br>"))
	to_chat(target, msg_to_target)
	SEND_SOUND(target, sound('sound/effects/adminhelp.ogg'))

/// Sends a random fake PM from a randomly selected fake administrator
/proc/send_random_fake_pm(target)
	var/datum/fake_administrator/admin = GLOB.cached_fake_admins[pick(GLOB.cached_fake_admins)]
	admin.send_random_msg(target)

#undef BH_ADMIN
#undef BH_ADMIN_SA
#undef BH_HSA
#undef BH_TRIAL
#undef BH_ALL_ADMINS_RANK
#undef BH_DEVELOPER
#undef BH_LEAD_DEVELOPER
#undef BH_CONTRIBUTOR
#undef BH_DEVELOPENT_STAFF
#undef BH_ADMIN_PM
