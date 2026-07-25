/datum/subscription/station_donations
	subscription_name = "Фонд развития станции"
	description = " Регулярное перечисление средств на модернизацию систем жизнеобеспечения. Поощряется руководством НТ и отделом кадров."
	cost = 100
	interval = SALARY_MODIFIER_INTERVAL

/datum/subscription/station_donations/New(subscriber, extra_params=null)
	set_recipient_account(GLOB.station_account)
	..(subscriber)
