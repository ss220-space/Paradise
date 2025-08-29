
/proc/send_insurance_alert(datum/money_account/acc, amount_spent)
	var/obj/machinery/message_server/message_server = find_pda_server()
	if(message_server)
		message_server.send_pda_message(acc.owner_name, "Insurance NT Department", "Медицинской страховки недостаточно на покрытие расходов на лечение. С вашего счета списанно [amount_spent] кредитов.")

// if have id -> acc from id
// else -> dna acc

/proc/get_insurance_account(mob/living/carbon/human/user)
	var/obj/item/card/id/user_id = user.get_id_card()
	if(istype(user_id) && user_id.associated_account_number)
		return get_money_account(user_id.associated_account_number)
	if(user.dna in GLOB.dna2account)
		return GLOB.dna2account[user.dna]
	else
		return null

/proc/get_insurance_account_DNA(mob/living/carbon/human/user)
	if(user.dna in GLOB.dna2account)
		return GLOB.dna2account[user.dna]
	return null

/proc/do_insurance_collection(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/money_account/connected_acc)
	if(!istype(target))
		user.balloon_alert(user, "цель не обнаружена")
		return FALSE

	var/list/access = user?.get_access()
	if(user && !(ACCESS_MEDICAL in access))
		user.balloon_alert(user, "нет доступа")
		return FALSE

	var/req = get_req_insurance(target)
	var/datum/money_account/acc = get_insurance_account(target)

	if(!acc)
		user.balloon_alert(user, "нет аккаунта")
		return FALSE

	if(!COOLDOWN_FINISHED(acc, insurance_collecting))
		user.balloon_alert(user, "слишком рано")
		to_chat(user, span_warning("С цели недавно уже списывалась страховка. Подождите немного."))
		return FALSE
	COOLDOWN_START(acc, insurance_collecting, 60 SECONDS)

	var/from_insurance = min(acc.insurance, req)
	var/from_money_acc = (req - from_insurance) * 2


	if(from_money_acc)
		if(!acc.insurance_auto_replen || !acc.charge(from_money_acc))
			to_chat(user, span_warning("Страховки не хватает на оплату лечения. Автопополнение страховки отключено или провалилось."))
			target.visible_message(
				span_danger("[user] безуспешно пыта[pluralize_ru(user.gender, "ет", "ют")]ся списать страховку у [target]!"),
				span_userdanger("[user] безуспешно пыта[pluralize_ru(user.gender, "ет", "ют")]ся списать вашу страховку!"),
				ignored_mobs = user,
			)
			return FALSE
		send_insurance_alert(acc)

	acc.addInsurancePoints(-from_insurance)

	var/datum/money_account/money_account = null
	if(connected_acc)
		money_account = attempt_account_access_nosec(connected_acc)
	else
		to_chat(user, span_warning("Привязанного аккаунта к сканеру не обнаружено. Рекомендуется авторизоваться."))
		var/obj/item/card/id/user_id = user.get_id_card()
		if(istype(user_id) && user_id.associated_account_number)
			money_account = get_money_account(user_id.associated_account_number)

	if(money_account)
		money_account.money += round(round(req / 2))

	to_chat(user, span_notice("Вы списали страховку у [target] в размере: [req]."))
	target.visible_message(
		span_danger("[user] списыва[pluralize_ru(user.gender, "ет", "ют")] страховку у [target] в размере: [req]."),
		span_userdanger("[user] списыва[pluralize_ru(user.gender, "ет", "ют")] вашу страховку в размере: [req]."),
		ignored_mobs = user,
	)
	if(from_money_acc)
		to_chat(user,(span_notice("Страховки не хватило. [from_money_acc / 2] недостающих очков страховки восполнено за счет [from_money_acc] кредитов со счета пациента. Уведомите пациента о его состоянии страховки")))

	return TRUE

/proc/get_req_insurance(mob/living/carbon/human/user)
	var/insurance = 0

	insurance += user.getBruteLoss() * REQ_INSURANCE_BRUT
	insurance += user.getFireLoss() * REQ_INSURANCE_BURN
	insurance += user.getOxyLoss() * REQ_INSURANCE_OXY
	insurance += user.getToxLoss() * REQ_INSURANCE_TOX
	insurance += user.getCloneLoss() * REQ_INSURANCE_CLONE

	var/internal_organs_damage = 0
	for(var/obj/item/organ/internal/organ as anything in user.internal_organs)
		internal_organs_damage += organ.damage

	insurance += internal_organs_damage * REQ_INSURANCE_ORGAN

	insurance += user.radiation * REQ_INSURANCE_RAD
	insurance += max(0, round((BLOOD_VOLUME_NORMAL - user.blood_volume) / BLOOD_VOLUME_NORMAL * 100)) * REQ_INSURANCE_BLOOD

	var/internal_bleedings = 0
	for(var/obj/item/organ/external/bodypart as anything in user.bodyparts)
		if(bodypart.has_internal_bleeding())
			internal_bleedings++

	insurance += internal_bleedings * REQ_INSURANCE_INTBLEED

	var/broken_bones = 0
	for(var/obj/item/organ/external/bodypart as anything in user.bodyparts)
		if(bodypart.has_fracture())
			broken_bones++

	insurance += broken_bones * REQ_INSURANCE_BONE

	var/missed_organs = 0
	for (var/organ in user.dna.species.has_organ)
		if(!(organ in user.internal_organs_slot))
			missed_organs++

	insurance += missed_organs * REQ_INSURANCE_LOST_ORGAN

	var/missed_limbs = 0
	for (var/limb in user.dna.species.has_limbs)
		if(!(user.bodyparts_by_name[limb] in user.bodyparts))
			missed_limbs++

	insurance += missed_limbs * REQ_INSURANCE_LOST_LIMB

	if(user.health < HEALTH_THRESHOLD_CRIT)
		insurance += REQ_INSURANCE_CRIT

	if(user.stat == DEAD)
		insurance += REQ_INSURANCE_DEATH

	return insurance
