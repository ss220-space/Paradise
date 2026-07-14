#define STATION_CREATION_DATE "2 April, 2555"
#define STATION_CREATION_TIME "11:24:30"
#define STATION_START_CASH 75000
#define STATION_SOURCE_TERMINAL "Biesel GalaxyNet Terminal #227"
#define DEPARTMENT_START_CASH 5000
#define NISHEBROD_SALARY 0

GLOBAL_VAR_INIT(num_financial_terminals, 1)
GLOBAL_DATUM(station_account, /datum/money_account)
GLOBAL_LIST_EMPTY(department_accounts)
GLOBAL_LIST_EMPTY(active_salary_system)
GLOBAL_VAR_INIT(next_account_number, 0)
GLOBAL_DATUM(centcomm_account_db, /obj/machinery/computer/account_database) // this being an object hurts me deeply on the inside
GLOBAL_DATUM(vendor_account, /datum/money_account)
GLOBAL_LIST_EMPTY(all_money_accounts)
GLOBAL_LIST_EMPTY(dna2account)

GLOBAL_DATUM(CC_account, /datum/money_account)

/proc/create_CC_account()
	if(!GLOB.CC_account)
		GLOB.next_account_number = rand(111111, 999999)

		GLOB.CC_account = new()
		GLOB.CC_account.owner_name = "Account of the personnel department of the Central Command"
		GLOB.CC_account.account_number = rand(111111, 999999)
		GLOB.CC_account.remote_access_pin = rand(111111, 999999)
		GLOB.CC_account.money = INFINITY
		GLOB.CC_account.security_level = 2

/proc/create_station_account()
	if(!GLOB.station_account)
		GLOB.next_account_number = rand(111111, 999999)

		GLOB.station_account = new()
		GLOB.station_account.owner_name = "[station_name()] Station Account"
		GLOB.station_account.account_number = rand(111111, 999999)
		GLOB.station_account.remote_access_pin = rand(111111, 999999)
		GLOB.station_account.money = STATION_START_CASH * 2

		//create an entry in the account transaction log for when it was created
		GLOB.station_account.makeTransactionLog(
			STATION_START_CASH, "Account Creation", STATION_SOURCE_TERMINAL, GLOB.station_account.owner_name, FALSE,
			STATION_CREATION_DATE, STATION_CREATION_TIME
		)

		//add the account
		GLOB.all_money_accounts.Add(GLOB.station_account)

/proc/create_department_account(department)
	GLOB.next_account_number = rand(111111, 999999)

	var/datum/money_account/department_account = new()
	department_account.owner_name = "[department] Account"
	department_account.account_number = rand(111111, 999999)
	department_account.remote_access_pin = rand(111111, 999999)
	department_account.money = DEPARTMENT_START_CASH

	//create an entry in the account transaction log for when it was created
	department_account.makeTransactionLog(
		DEPARTMENT_START_CASH, "Account Creation", STATION_SOURCE_TERMINAL, department_account.owner_name, FALSE,
		STATION_CREATION_DATE, STATION_CREATION_TIME
	)

	//add the account
	GLOB.all_money_accounts.Add(department_account)

	GLOB.department_accounts[department] = department_account

//the current ingame time (hh:mm:ss) can be obtained by calling:
//station_time_timestamp("hh:mm:ss")

/proc/create_account(new_owner_name = "Default user", starting_funds = 0, obj/machinery/computer/account_database/source_db, datum/job/link_job = /datum/job , salary_active = FALSE)

	//create a new account
	var/datum/money_account/money_account = new()
	money_account.owner_name = new_owner_name
	money_account.remote_access_pin = rand(111111, 999999)
	money_account.money = starting_funds
	money_account.linked_job = link_job
	money_account.salary_payment_active = salary_active

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/transaction = new()
	transaction.target_name = new_owner_name
	transaction.purpose = "Account creation"
	transaction.amount = starting_funds
	if(!source_db)
		//set a random date, time and location some time over the past few decades
		transaction.date = "[num2text(rand(1,31))] [pick(GLOB.month_names)], [rand(GLOB.game_year - 20,GLOB.game_year - 1)]"
		transaction.time = "[rand(0,23)]:[rand(0,59)]:[rand(0,59)]"
		transaction.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

		money_account.account_number = rand(111111, 999999)
	else
		transaction.date = GLOB.current_date_string
		transaction.time = station_time_timestamp()
		transaction.source_terminal = source_db.machine_id

		money_account.account_number = GLOB.next_account_number
		GLOB.next_account_number += rand(1,25)

		//create a sealed package containing the account details
		var/obj/item/smallDelivery/smallDelivery = new /obj/item/smallDelivery(source_db.loc)

		var/obj/item/paper/paper = new /obj/item/paper(smallDelivery)
		playsound(source_db.loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
		smallDelivery.wrapped = paper
		smallDelivery.w_class = paper.w_class
		smallDelivery.update_icon(UPDATE_ICON_STATE)

		paper.name = "Account information: [money_account.owner_name]"

		var/overseer = UNKNOWN_NAME_RUS
		var/datum/ui_login/ui_login = source_db.ui_login_get()
		if(ui_login.id)
			overseer = ui_login.id.registered_name
		paper.info = {"<b>Account details (confidential)</b><br><hr><br>
			<i>Account holder:</i> [money_account.owner_name]<br>
			<i>Account number:</i> [money_account.account_number]<br>
			<i>Account pin:</i> [money_account.remote_access_pin]<br>
			<i>Starting balance:</i> $[money_account.money]<br>
			<i>Date and time:</i> [station_time_timestamp()], [GLOB.current_date_string]<br><br>
			<i>Creation terminal ID:</i> [source_db.machine_id]<br>
			<i>Authorised NT officer overseeing creation:</i> [overseer]<br>"}

		//stamp the paper
		paper.stamp(/obj/item/stamp, TRUE, "<i>This paper has been stamped by the Accounts Database.</i>", "stamp-cent")

	//add the account
	money_account.transaction_log.Add(transaction)
	GLOB.all_money_accounts.Add(money_account)

	return money_account

/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/suspended = 0
	var/list/transaction_log = list()
	var/insurance = INSURANCE_NONE
	var/insurance_type = INSURANCE_TYPE_NONE
	var/insurance_auto_replen = TRUE
	var/security_level = 0	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login
	COOLDOWN_DECLARE(insurance_collecting)

	var/datum/job/linked_job = /datum/job
	var/salary_payment_active = FALSE

/datum/money_account/New()
	..()

/datum/money_account/proc/addInsurancePoints(amount)
	insurance += amount

/datum/money_account/proc/notify_pda_owner(text, noti = FALSE)
	. = FALSE
	for(var/obj/item/pda/send_pda as anything in GLOB.name_to_PDAs?[owner_name])
		var/datum/data/pda/app/messenger/PM = send_pda.find_program(/datum/data/pda/app/messenger)
		if(!PM || !PM.can_receive())
			continue
		PM.notify(text, noti)
		. = TRUE

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/obj/machinery/computer/account_database/proc/charge_to_account(attempt_account_number, datum/money_account/source, purpose, terminal_id, amount)
	if(!activated)
		return 0
	for(var/datum/money_account/money_account in GLOB.all_money_accounts)
		if(money_account.account_number == attempt_account_number && !money_account.suspended)
			source.charge(amount, money_account, purpose, terminal_id, "Account #[money_account.account_number]", "Transfer from [source.owner_name]",
			"[money_account.owner_name]")
			return 1

	return 0

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(attempt_account_number, attempt_pin_number, security_level_passed = 0, pin_needed=1)
	for(var/datum/money_account/money_account in GLOB.all_money_accounts)
		if(money_account.account_number == attempt_account_number)
			if(money_account.security_level <= security_level_passed && (!money_account.security_level || money_account.remote_access_pin == attempt_pin_number || !pin_needed))
				return money_account

/obj/machinery/computer/account_database/proc/get_account(account_number)
	for(var/datum/money_account/money_account in GLOB.all_money_accounts)
		if(money_account.account_number == account_number)
			return money_account

/proc/get_account_with_name(name_owner)
	for(var/datum/money_account/money_account in GLOB.all_money_accounts)
		if(money_account.owner_name == name_owner)
			return money_account

/proc/attempt_account_access_nosec(attempt_account_number)
	for(var/datum/money_account/money_account in GLOB.all_money_accounts)
		if(money_account.account_number == attempt_account_number)
			return money_account

#undef STATION_CREATION_DATE
#undef STATION_CREATION_TIME
#undef STATION_START_CASH
#undef STATION_SOURCE_TERMINAL
#undef DEPARTMENT_START_CASH
#undef NISHEBROD_SALARY
