/**
  * # Rep Purchase - Contractor Balloon
  */
/datum/rep_purchase/item/balloon
	name = "Воздушный шарик Контрактора"
	desc = "Изящный воздушный шар, выполненный в черно-золотых тонах и украшенный символикой контрактор. \
			Чтобы приобрести этот предмет, необходимо успешно завершить все предоставленные контракты в самой сложной локации."
	cost = 12
	stock = 1
	item_type = /obj/item/toy/syndicateballoon/contractor

/datum/rep_purchase/item/balloon/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	var/eligible = TRUE
	for(var/c in hub.contracts)
		var/datum/syndicate_contract/C = c
		if(C.status != CONTRACT_STATUS_COMPLETED || C.chosen_difficulty != EXTRACTION_DIFFICULTY_HARD)
			eligible = FALSE
			break
	if(!eligible)
		to_chat(user, span_warning("Чтобы получить право на эту вещь, все ваши контракты должны быть выполнены в самом сложном месте."))
		return FALSE
	return ..()

/obj/item/toy/syndicateballoon/contractor
	name = "contractor balloon"
	desc = "Черно-золотой шар, который носят только легендарные агенты Синдиката."
	ru_names = list(
		NOMINATIVE = "воздушный шарик контрактора",
		GENITIVE = "воздушного шарика контрактора",
		DATIVE = "воздушному шарику контрактора",
		ACCUSATIVE = "воздушный шарик контрактора",
		INSTRUMENTAL = "воздушным шариком контрактора",
		PREPOSITIONAL = "воздушном шарике контрактора"
	)
	gender = MALE
	icon_state = "contractorballoon"
	item_state = "contractorballoon"
