/datum/event/money_lotto
	var/winner_name = "Джон Смит"
	var/winner_sum = 0
	var/deposit_success = 0

/datum/event/money_lotto/start()
	winner_sum = pick(5000, 10000, 50000, 100000, 500000, 1000000, 1500000)
	if(GLOB.all_money_accounts.len)
		var/datum/money_account/D = pick(GLOB.all_money_accounts)
		winner_name = D.owner_name

		D.credit(winner_sum, "Winner!", "Терминал \"Бизель\" #[rand(111,333)]", "Звёздная Лотерея Никс Дейли – Гранд Слэм")
		deposit_success = 1

/datum/event/money_lotto/announce()
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = EDITOR_NYX
	newMsg.admin_locked = TRUE

	newMsg.body = "Никс Дейли поздравляет [winner_name] с выигрышем в лотерее \"Никс – Звёздный Слэм\" и получением невероятной суммы в размере [winner_sum] кредитов!"
	if(!deposit_success)
		newMsg.body += "К сожалению, нам не удалось подтвердить предоставленные данные счёта, поэтому мы не смогли перевести деньги. Отправьте чек на сумму $500 в офис НД 'Звёздный Слэм' с обновлёнными данными, и ваш выигрыш будет переведён в течение месяца."

	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_NYX)?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_NYX)
