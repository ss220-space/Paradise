/datum/fake_administrator
	var/admin_name = ""
	var/admin_rank = ""
	var/type_admin_help = "PM"

	var/list/fake_msgs = list()

/datum/fake_administrator/proc/send_random_msg(target)
	fake_admin_pm(target, pick(fake_msgs), admin_name, admin_rank, type_admin_help)

/datum/fake_administrator/momongo
	admin_name = "Momong0"
	admin_rank = "Админ"

	fake_msgs = list("Ебать рецедивов. Перма")


/datum/fake_administrator/jaba
	admin_name = "jaba213"
	admin_rank = "Админ"

	fake_msgs = list("Здравствуйте. Информируем вас, что охота за ролью антогониста, не приветсвуется на нашем сервере. За вами это замечается не впервые")