
/proc/send_insurance_alert(datum/money_account/acc, amount_spent)
	var/obj/machinery/message_server/message_server = find_pda_server()
	if (message_server)
		message_server.send_pda_message(acc.owner_name, "Insurance NT Department", "Медицинской страховки недостаточно на покрытие расходов на лечение. С вашего счета списанно [amount_spent] кредитов.")

// if have id -> acc from id
// else -> dna acc

/proc/get_insurance_account(mob/living/carbon/human/user)
	var/obj/item/card/id/user_id = user.get_id_card()
	if (istype(user_id) && user_id.associated_account_number)
		return get_money_account(user_id.associated_account_number)
	if (user.dna in GLOB.dna2account)
		return GLOB.dna2account[user.dna]
	else
		return null

/proc/do_insurance_collection(mob/living/carbon/human/user, datum/money_account/connected_acc)
	if(!istype(user))
		user.visible_message("Некорректная цель списания страховки.")
		return FALSE

	var/req = get_req_insurance(user)

	var/datum/money_account/acc = get_insurance_account(user)

	if (!acc)
		user.visible_message("Аккаунт не обнаружен.")
		return FALSE

	if (!COOLDOWN_FINISHED(acc, insurance_collecting))
		user.visible_message("С цели недавно уже списывалась страховка. Подождите немного.")
		return FALSE
	COOLDOWN_START(acc, insurance_collecting, 60 SECONDS)

	var/from_insurance = min(acc.insurance, req)
	var/from_money_acc = (req - from_insurance) * 2

	if (from_money_acc)
		if (!acc.insurance_auto_replen)
			user.visible_message(span_warning("Страховки не хватает на оплату лечения. Автопополнение страховки отключено."))
			return FALSE
		if (!acc.charge(from_money_acc))
			user.visible_message(span_warning("Страховки не хватает на оплату лечения. Автопополнение страховки провалилось."))
			return FALSE

	if (from_money_acc)
		send_insurance_alert(acc)

	acc.addInsurancePoints(-from_insurance)

	if (connected_acc)
		var/datum/money_account/money_account = attempt_account_access_nosec(connected_acc)
		if (money_account)
			money_account.money += round(round(req / 2))

	user.visible_message("Страховка списанна в размере: [req].")
	if (from_money_acc)
		user.visible_message("Страховки не хватило. [from_money_acc / 2] недостающих очков страховки восполнено за счет [from_money_acc] кредитов со счета пациента.")

	return TRUE
