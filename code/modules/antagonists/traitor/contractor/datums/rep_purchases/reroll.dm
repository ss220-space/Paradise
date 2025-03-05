/**
  * # Rep Purchase - Contract Reroll
  */
/datum/rep_purchase/reroll
	name = "Обновление контрактов"
	description = "Заменяет неактивные контракты на новые, содержащие новую цель и зоны для эвакуации."
	cost = 0
	stock = 2

/datum/rep_purchase/reroll/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	var/eligible = FALSE
	for(var/c in hub.contracts)
		var/datum/syndicate_contract/C = c
		if(C.status == CONTRACT_STATUS_INACTIVE)
			eligible = TRUE
			break
	if(!eligible)
		to_chat(user, span_warning("Нет неактивных контрактов, которые можно было бы заменить."))
		return FALSE
	return ..()

/datum/rep_purchase/reroll/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	var/changed = 0
	for(var/c in hub.contracts)
		var/datum/syndicate_contract/C = c
		if(C.status == CONTRACT_STATUS_INACTIVE && C.generate())
			changed++
	hub.contractor_uplink?.message_holder("Агент, мы заменили [changed] контракт[declension_ru(changed, "", "а", "ов")] на новы[declension_ru(changed, "й", "е", "е")].")
