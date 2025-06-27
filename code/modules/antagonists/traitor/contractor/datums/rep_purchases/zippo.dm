/**
  * # Rep Purchase - Contractor Zippo Lighter
  */
/datum/rep_purchase/item/zippo
	name = "Зажигалка Контрактника"
	description = "Изящная зажигалка, оформленная в чёрно-золотых тонах и украшенная символикой Контрактников. \
			Чтобы приобрести этот предмет, необходимо сначала выполнить все свои контракты."
	cost = 0
	stock = 1
	item_type = /obj/item/lighter/zippo/contractor

/datum/rep_purchase/item/zippo/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	var/eligible = TRUE
	for(var/c in hub.contracts)
		var/datum/syndicate_contract/C = c
		if(C.status != CONTRACT_STATUS_COMPLETED)
			eligible = FALSE
			break
	if(!eligible)
		to_chat(user, span_warning("Чтобы получить право на эту вещь, все ваши контракты должны быть выполнены."))
		return FALSE
	return ..()
