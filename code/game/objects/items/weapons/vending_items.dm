/obj/item/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	desc = "A vending machine restock cart."
	usesound = 'sound/items/deconstruct.ogg'
	flags = CONDUCT
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 30)

	// Built automatically from the corresponding vending machine.
	// If null, considered to be full. Otherwise, is list(/typepath = amount).
	var/list/products
	var/list/contraband
	var/list/premium

/obj/item/vending_refill/Initialize(mapload)
	. = ..()
	name = "\improper [machine_name] restocking unit"

/obj/item/vending_refill/examine(mob/user)
	. = ..()
	var/num = get_part_rating()
	if (num == INFINITY)
		. += "<span class='notice'>It's sealed tight, completely full of supplies.</span>"
	else if (num == 0)
		. += "<span class='notice'>It's empty!</span>"
	else
		. += "<span class='notice'>It can restock [num] item\s.</span>"

/obj/item/vending_refill/get_part_rating()
	if (!products || !contraband || !premium)
		return INFINITY
	. = 0
	for(var/key in products)
		. += products[key]
	for(var/key in contraband)
		. += contraband[key]
	for(var/key in premium)
		. += premium[key]

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"

/obj/item/vending_refill/coffee
	machine_name = "hot drinks"
	icon_state = "refill_joe"

/obj/item/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"

/obj/item/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"

/obj/item/vending_refill/cigarette
	machine_name = "cigarette"
	icon_state = "refill_smoke"

/obj/item/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"

/obj/item/vending_refill/hatdispenser
	machine_name = "hat"
	icon_state = "refill_costume"

/obj/item/vending_refill/suitdispenser
	machine_name = "suit"
	icon_state = "refill_costume"

/obj/item/vending_refill/shoedispenser
	machine_name = "shoe"
	icon_state = "refill_costume"

/obj/item/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"

/obj/item/vending_refill/clothing/security
	machine_name = "Security Departament ClothesMate"

/obj/item/vending_refill/clothing/medical
	machine_name = "Medical Departament ClothesMate"

/obj/item/vending_refill/clothing/science
	machine_name = "Science Departament ClothesMate"

/obj/item/vending_refill/clothing/engineering
	machine_name = "Engineering Departament ClothesMate"

/obj/item/vending_refill/clothing/cargo
	machine_name = "Cargo Departament ClothesMate"

/obj/item/vending_refill/clothing/law
	machine_name = "Law Departament ClothesMate"

/obj/item/vending_refill/clothing/service
	machine_name = "Service Departament ClothesMate"

/obj/item/vending_refill/clothing/service/chaplain
	machine_name = "Service Departament ClothesMate Chaplain"

/obj/item/vending_refill/clothing/service/botanical
	machine_name = "Service Departament ClothesMate Botanical"

/obj/item/vending_refill/crittercare
	machine_name = "CritterCare"
	icon_state = "refill_pet"

/obj/item/vending_refill/chinese
	machine_name = "MrChangs"

/obj/item/vending_refill/hydroseeds
	machine_name = "MegaSeed Servitor"
	icon_state = "refill_plant"

/obj/item/vending_refill/assist
	machine_name = "Vendomat"
	icon_state = "refill_engi"

/obj/item/vending_refill/cart
	machine_name = "PTech"
	icon_state = "refill_smoke"

/obj/item/vending_refill/dinnerware
	machine_name = "Plasteel Chef's Dinnerware Vendor"
	icon_state = "refill_smoke"

/obj/item/vending_refill/engineering
	machine_name = "Robco Tool Maker"
	icon_state = "refill_engi"

/obj/item/vending_refill/youtool
	machine_name = "YouTool"
	icon_state = "refill_engi"

/obj/item/vending_refill/engivend
	machine_name = "Engi-Vend"
	icon_state = "refill_engi"

/obj/item/vending_refill/medical
	machine_name = "NanoMed Plus"
	icon_state = "refill_medical"

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"

/obj/item/vending_refill/hydronutrients
	machine_name = "NutriMax"
	icon_state = "refill_plant"

/obj/item/vending_refill/security
	icon_state = "refill_sec"

/obj/item/vending_refill/sovietsoda
	machine_name = "BODA"
	icon_state = "refill_cola"

/obj/item/vending_refill/sustenance
	machine_name = "Sustenance Vendor"
	icon_state = "refill_snack"

/obj/item/vending_refill/donksoft
	machine_name = "Donksoft Toy Vendor"
	icon_state = "refill_donksoft"

/obj/item/vending_refill/robotics
	machine_name = "Robotech Deluxe"
	icon_state = "refill_engi"

/obj/item/vending_refill/nta
	machine_name = "NT Ammunition"
	icon_state = "refill_nta"

/obj/item/vending_refill/pai
	machine_name = "RoboFriends"
	icon_state = "restock_pai"

/obj/item/vending_refill/custom
	machine_name = "Customat"
	icon = 'icons/obj/machines/customat.dmi'
	icon_state = "custommate-refill"
	var/list/datum/money_account/linked_accounts = list()
	var/list/datum/money_account/accounts_weights = list()
	var/sum_of_weigths = 0

/obj/item/vending_refill/custom/Initialize()
	linked_accounts = list(GLOB.station_account)
	accounts_weights = list(100)
	sum_of_weigths = 100
	. = ..()



/obj/item/vending_refill/custom/proc/add_account(datum/money_account/new_account, weight)
	linked_accounts += new_account
	accounts_weights += weight
	sum_of_weigths += weight


/obj/item/vending_refill/custom/proc/clear_accounts(mob/user)
	linked_accounts = list()
	accounts_weights = list()
	sum_of_weigths = 0
	balloon_alert(user, "счета отвязаны")


/obj/item/vending_refill/custom/proc/try_add_account(mob/user)
	. = FALSE
	if (linked_accounts.len >= 150) // better to do it
		balloon_alert(user, "лимит привязки достигнут")
		return

	var/new_acc_number = tgui_input_number(user, "Пожалуйста, введите номер счета, который вы хотите привязать.", "Выбор счета", (user.mind && user.mind.initial_account) ? user.mind.initial_account.account_number : 999999, 999999, 0, ui_state = GLOB.hands_state, ui_source = src)

	if (isnull(new_acc_number))
		balloon_alert(user, "номер не введен")
		return

	var/new_account = attempt_account_access(new_acc_number, pin_needed = FALSE, security_level_passed = 3, pin_needed = FALSE)
	if (!new_account)
		balloon_alert(user, "аккаунт не существует")
		return

	if (new_account in linked_accounts)
		balloon_alert(user, "аккаунт уже привязан")
		return

	var/weight = tgui_input_number(user, "Пожалуйста, введите вес счета от 1 до 1000000.", "Выбор веса", 100, 1000000, 1, ui_state = GLOB.hands_state, ui_source = src)

	if (isnull(weight))
		balloon_alert(user, "вес не введен")
		return

	add_account(new_account, weight)
	balloon_alert(user, "новый счет добавлен")
	return TRUE


/obj/item/vending_refill/custom/proc/try_add_station_account(mob/user)
	. = FALSE
	var/weight = tgui_input_number(user, "Пожалуйста, введите вес для счета станции от 1 до 1000000.", "Выбор веса", 100, 1000000, 1, ui_state = GLOB.hands_state, ui_source = src)

	if (isnull(weight))
		balloon_alert(user, "вес не введен")
		return

	if (GLOB.station_account in linked_accounts)
		balloon_alert(user, "аккаунт станции уже привязан")
		return

	add_account(GLOB.station_account, weight)
	balloon_alert(user, "счет станции привязан")
	return TRUE


/obj/item/vending_refill/custom/attack_self(mob/user) // It works this way not because I'm lazy, but for better immersion.
	var/operation = tgui_input_number(user, "Введите 0 чтобы сбросить список сохраненных счетов, 1 чтобы добавить новый счет в список получателей, 2 чтобы добавить счет станции.", "Настройка счетов", 0, 2, 0, ui_state = GLOB.hands_state, ui_source = src)

	if (isnull(operation))
		balloon_alert(user, "значение не введено")
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 1)
		return


	var/correct = TRUE
	switch (operation)
		if (0)
			correct = clear_accounts(user)
		if (1)
			correct = try_add_account(user)
		if (2)
			correct = try_add_station_account(user)
		if (-INFINITY to -1)
			correct = FALSE
			balloon_alert(user, "значение должно быть больше 0")
		if (3 to INFINITY)
			correct = FALSE
			balloon_alert(user, "значение должно быть меньше 3")

	if (correct)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 30, 0)
	else
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 30, 1)


/obj/item/vending_refill/custom/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if (!linked_accounts.len)
			. += span_notice("К этой канистре не привязанно ни одного счета.")
		else
			. += span_notice("К этой канистре привязанны следующее счета:")
			for (var/i = 1; i <= linked_accounts.len; ++i)
				. += span_notice("Владелец: " + linked_accounts[i].owner_name + ", вес: [accounts_weights[i]], доля: [round(accounts_weights[i]/sum_of_weigths, 0.01)].")

