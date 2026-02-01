#define DONATIONS_COUNT "donations_count"
#define DONATIONS_AMOUNT "donations_amount"

SUBSYSTEM_DEF(donations)
	name = "Donations"
	wait = 10 MINUTES
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_DONATIONS
	init_order = INIT_ORDER_DONATIONS
	var/list/donators = list()
	var/month_donations = 0
	var/target_donation = 0
	var/tts_target_donation = 0
	var/donations_text
	var/boosty_url
	var/kofi_url
	var/discord_url

/datum/controller/subsystem/donations/vv_edit_var(var_name, var_value)
	if(!check_rights(R_PERMISSIONS))
		log_and_message_admins("trying to replace [var_name] with [var_value] without R_PERMISSIONS.")
		return
	. = ..()

/datum/controller/subsystem/donations/OnConfigLoad()
	target_donation = CONFIG_GET(number/target_donation)
	tts_target_donation = CONFIG_GET(number/tts_target_donation)
	boosty_url = CONFIG_GET(string/boosty_url)
	kofi_url = CONFIG_GET(string/kofi_url)
	discord_url = CONFIG_GET(string/discord_url)
	. = ..()


/datum/controller/subsystem/donations/Initialize()
	if(!SSdbcore?.IsConnected())
		can_fire = FALSE
		return SS_INIT_SUCCESS

	donations_text = html_decode(file2text("[config.directory]/donations_text.txt"))
	load_month_donations()
	load_donators()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/donations/proc/load_month_donations()
	var/datum/db_query/query = SSdbcore.NewQuery(
		{"SELECT DATE_FORMAT(date_start, '%Y-%m') AS month,CAST(SUM(amount) as UNSIGNED INTEGER) AS total_amount
		FROM [CONFIG_GET(string/utility_database)].budget
		WHERE source NOT IN ('creator', 'virtual', 'contributor') AND is_valid IS TRUE AND DATE_FORMAT(date_start, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
		GROUP BY month
		ORDER BY month DESC;"}
	)
	if(query.Execute(async = TRUE))
		while(query.NextRow())
			month_donations = text2num(query.item[2])
			break
	qdel(query)

/datum/controller/subsystem/donations/proc/load_donators()
	var/datum/db_query/query = SSdbcore.NewQuery(
		{"SELECT ckey, CAST(SUM(amount) as UNSIGNED INTEGER) AS total_amount, COUNT(*) AS donations_count FROM [CONFIG_GET(string/utility_database)].budget
		WHERE source NOT IN ('creator', 'virtual', 'contributor') AND is_valid IS TRUE
		GROUP BY ckey
		ORDER BY total_amount DESC;"}
	)
	if(query.Execute(async = TRUE))
		while(query.NextRow())
			var/ckey = query.item[1]
			donators[ckey] = list(DONATIONS_AMOUNT = text2num(query.item[2]), DONATIONS_COUNT = text2num(query.item[3]))
	qdel(query)

/datum/controller/subsystem/donations/proc/get_donations_count(ckey)
	return donators[ckey]?[DONATIONS_COUNT] || 0

/datum/controller/subsystem/donations/proc/get_donations_amount(ckey)
	return donators[ckey]?[DONATIONS_AMOUNT] || 0

/datum/controller/subsystem/donations/fire(resumed)
	INVOKE_ASYNC(src, PROC_REF(load_month_donations))
	INVOKE_ASYNC(src, PROC_REF(load_donators))

#undef DONATIONS_COUNT
#undef DONATIONS_AMOUNT

