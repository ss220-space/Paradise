/datum/affiliate/mi13
	name = "MI13"
	desc = "Вы - элитный агент MI13, глаза и уши Синдиката. \n\
			Вы были внедрены в структуру NanoTrasen для поиска и получения секретных сведений; однако возможно, что придется испачкать перчатки в крови. \n\
			Как вам стоит работать: действуйте скрытно и осторожно, не вызывайте подозрений со стороны службы безопасности станции. \n\
			Если вы и решитесь пойти на открытую конфронтацию - не забудьте прибрать следы, сменить тройку на двойку не будет ошибкой. \n\
			Особые условия: агентам Корпорации не положено тяжелое и шумное снаряжение, однако набор \"Бонда\" уже ваш - не забудье забрать его.\n\
			Стандартные цели: Украсть секретные документы, украсть пару вещей, убить пару гуманойдов, обменяться секретными документами с другим агентом, выглядеть стильно."
	tgui_icon = "mi13"
	objectives = list(/datum/objective/steal/documents,
					list(/datum/objective/steal = 30, /datum/objective/maroon = 70),
					list(/datum/objective/steal = 30, /datum/objective/maroon/blueshield = 70), // blueshield also has CQC.
					/datum/objective/steal,
					/datum/objective/escape
					)

/datum/affiliate/mi13/finalize_affiliate(datum/mind/owner)
	. = ..()
	uplink.uses = 20
	var/datum/antagonist/traitor/traitor = owner.has_antag_datum(/datum/antagonist/traitor)
	traitor.assign_exchange_role()

/obj/item/storage/box/bond_bundle
	icon = 'icons/obj/affiliates.dmi'
	desc = "Невероятно стильная коробка."
	icon_state = "bond_bundle"

/obj/item/storage/box/bond_bundle/populate_contents()
	new /obj/item/clothing/glasses/hud/security/chameleon(src)
	new /obj/item/pen/fancy/bomb(src)
	new /obj/item/gun/projectile/automatic/pistol(src)
	new /obj/item/suppressor(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm/hp(src)
	new /obj/item/ammo_box/magazine/m10mm/ap(src)
	new /obj/item/ammo_box/magazine/m10mm/ap(src)
	new /obj/item/clothing/under/suit_jacket/really_black(src)
	new /obj/item/card/id/syndicate(src)
	new /obj/item/clothing/suit/storage/lawyer/blackjacket/armored(src)
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail(src)
	new /obj/item/storage/box/syndie_kit/emp(src)
	new /obj/item/CQC_manual(src)

/obj/item/storage/box/bond_bundle/New()
	. = ..()
	if (prob(5))
		icon_state = "joker"
