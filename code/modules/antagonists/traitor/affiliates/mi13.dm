/datum/affiliate/mi13
	name = "MI13"
	affil_info = list("Преимущества: ",
			"Бесплатный набор \"Бонд\"",
			"Недостатки: ",
			"Вы не можете купить оружие для громкой деятельности.",
			"Вы не можете купить Хардсьют Синдиката и Хамелеон Хардсьют.",
			"Количество ТК сокращено до 20",
			"Стандартные цели:",
			"Украсть секретные документы",
			"Украсть пару ценных вещей",
			"Убить пару членов экипажа",
			"Обменяться секретными документами с другим агентом",
			"Выглядеть стильно")
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
	traitor.assign_exchange_role(SSticker.mode.exchange_red)
	uplink.get_intelligence_data = TRUE

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
		new /obj/item/toy/plushie/blahaj/twohanded(src)

/obj/item/pen/intel_data/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(target != user)
		return .

	for(var/obj/item/implant/uplink/uplink_imp in user)
		if(uplink_imp.imp_in != user)
			continue

		if (uplink_imp.hidden_uplink.get_intelligence_data)
			user.balloon_alert(user, "Уже улучшено")
			return ATTACK_CHAIN_PROCEED

		user.balloon_alert(user, "Улучшено")
		uplink_imp.hidden_uplink.get_intelligence_data = TRUE
		SStgui.update_uis(uplink_imp.hidden_uplink)

		to_chat(user, span_notice("You press [src] onto yourself upgraded hidden uplink."))
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/pen/intel_data/afterattack(obj/item/I, mob/user, proximity, params)
	if(!proximity)
		return

	if(istype(I) && I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
		if (I.hidden_uplink.get_intelligence_data)
			user.balloon_alert(user, "Уже улучшено")
			return

		user.balloon_alert(user, "Улучшено")
		I.hidden_uplink.get_intelligence_data = TRUE
		SStgui.update_uis(I.hidden_uplink)
		qdel(src)

