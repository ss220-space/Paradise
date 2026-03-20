/datum/subscription/station_donations
	subscription_name = "Фонд развития станции"
	description = " Регулярное перечисление средств на модернизацию систем жизнеобеспечения. Поощряется руководством НТ и отделом кадров."
	cost = 100
	interval = 5 MINUTES

/datum/subscription/station_donations/New(subscriber, extra_params)
	recipient_account = GLOB.station_account
	cost = 100
	interval = 5 MINUTES
	subscription_name = "Фонд развития станции"
	description = "Регулярное перечисление средств на модернизацию систем жизнеобеспечения..."

	..(subscriber, null)
