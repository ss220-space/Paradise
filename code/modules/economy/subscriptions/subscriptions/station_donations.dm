/datum/economy_process/subscription/station_donations
	subscription_name = "Фонд развития станции"
	description = " Регулярное перечисление средств на модернизацию систем жизнеобеспечения. Поощряется руководством НТ и отделом кадров."
	cost = 100
	interval = 3 MINUTES

/datum/economy_process/subscription/station_donations/get_default_account()
	return GLOB.station_account
