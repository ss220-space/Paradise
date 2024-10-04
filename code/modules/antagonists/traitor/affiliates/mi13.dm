/datum/affiliate/mi13
	name = "MI13"
	affil_info = list("Преимущества: ",
			"Бесплатный набор \"Бонд\"",
			"Вы можете получать разведданные о ситуации на станции в аплинке",
			" ",
			" ",
			"Недостатки: ",
			"Вы не можете купить оружие для громкой деятельности.",
			"Вы не можете купить Хардсьют Синдиката и Хамелеон Хардсьют.",
			"Количество ТК сокращено до 20",
			"Стандартные цели:",
			"Украсть секретные документы",
			"Украсть определенное количество ценных вещей",
			"Убить определенное количество членов экипажа",
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

/datum/affiliate/mi13/give_bonus_objectives(datum/mind/mind)
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)

	traitor.add_objective(/datum/objective/steal)
	traitor.add_objective(/datum/objective/steal)

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
	if (prob(5))
		icon_state = "joker"
		new /obj/item/toy/plushie/blahaj/twohanded(src)

	. = ..()

/obj/item/pen/intel_data/proc/upgrade(obj/item/uplink/U)
	if (!istype(U) || QDELETED(U))
		return

	if (U.get_intelligence_data)
		usr.balloon_alert(usr, "Уже улучшено")
		return ATTACK_CHAIN_PROCEED

	usr.balloon_alert(usr, "Улучшено")
	playsound(src, "sound/machines/boop.ogg", 50, TRUE)
	U.get_intelligence_data = TRUE
	SStgui.update_uis(U)
	qdel(src)

/obj/item/pen/intel_data/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(target != user)
		return .

	for(var/obj/item/implant/uplink/uplink_imp in user)
		if(uplink_imp.imp_in != user)
			continue

		to_chat(user, span_notice("You press [src] onto yourself and upgraded [uplink_imp.hidden_uplink]."))
		upgrade(uplink_imp.hidden_uplink)
		return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/pen/intel_data/afterattack(obj/item/I, mob/user, proximity, params)
	if(!proximity)
		return

	if(istype(I) && I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
		upgrade(I.hidden_uplink)
