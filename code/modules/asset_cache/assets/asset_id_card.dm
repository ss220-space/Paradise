/// Id cards sprites for UIs
/datum/asset/spritesheet/id_card
	name = "id_card"

/datum/asset/spritesheet/id_card/create_spritesheets()
	for(var/card_type in list("data","id","gold","silver","centcom","centcom_old","security","medical",
							  "HoS","research","cargo","engineering","CMO","RD","CE","clown","mime",
							  "rainbow","prisoner","commander","syndie","syndierd","syndiebotany",
							  "syndiecargo","syndiernd","syndieengineer","syndiechef","syndiemedical",
							  "deathsquad","ERT_leader","ERT_security","ERT_engineering","ERT_medical",
							  "ERT_janitorial"))
		Insert(card_type, 'icons/obj/card.dmi', card_type)

/datum/asset/spritesheet/id_card/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	return pre_asset
