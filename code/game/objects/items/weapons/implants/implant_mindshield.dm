/obj/item/implant/mindshield
	name = "mindshield bio-chip"
	desc = "Stops people messing with your mind."
	origin_tech = "materials=2;biotech=4;programming=4"
	implant_state = "implant-nanotrasen"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/mindshield

/obj/item/implant/mindshield/implant(mob/living/target, mob/user, force = FALSE)
	. = ..()
	if(!.)
		return .

	if(is_shadow_or_thrall(target))
		target.visible_message(
			span_warning("[target] seems to resist the implant!"),
			span_warning("You feel the corporate tendrils of Nanotrasen try to invade your mind!"),
		)
		removed(target, silent = TRUE)
		qdel(src)

	else if(iscultist(target) || is_head_revolutionary(target))
		to_chat(target, span_warning("You feel the corporate tendrils of Nanotrasen try to invade your mind!"))

	else if(is_revolutionary(target))
		SSticker.mode.remove_revolutionary(target.mind)

	else
		to_chat(target, span_notice("Your mind feels hardened - more resistant to brainwashing."))
		ADD_TRAIT(target, TRAIT_MINDSHIELD_HUD, UNIQUE_TRAIT_SOURCE(src))

	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		human.sec_hud_set_implants()

	var/obj/item/implant/fake_mindshield/fake_shield = locate() in imp_in

	if(!fake_shield)
		return .

	to_chat(target, span_warning("Вы чувствуете, что [fake_shield.declent_ru(ACCUSATIVE)] перегружен и вышел из строя!"))
	qdel(fake_shield)

/obj/item/implant/mindshield/removed(mob/target, silent = FALSE)
	. = ..()
	if(. && target.stat != DEAD && !silent)
		to_chat(target, span_boldnotice("Your mind softens. You feel susceptible to the effects of brainwashing once more."))

	REMOVE_TRAIT(target, TRAIT_MINDSHIELD_HUD, UNIQUE_TRAIT_SOURCE(src))

	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		human.sec_hud_set_implants()

/obj/item/implanter/mindshield
	name = "bio-chip implanter (mindshield)"
	imp = /obj/item/implant/mindshield

/obj/item/implantcase/mindshield
	name = "bio-chip case - 'mindshield'"
	desc = "A glass case containing a mindshield bio-chip."
	imp = /obj/item/implant/mindshield

/**
 * ERT mindshield
 */
/obj/item/implant/mindshield/ert
	name = "ERT-mindshield bio-chip"
	desc = "Stops people messing with your mind and allows to use some high-tech weapons."
	implant_data = /datum/implant_fluff/mindshield/ert

/obj/item/implanter/mindshield/ert
	name = "bio-chip implanter (ERT-mindshield)"
	imp = /obj/item/implant/mindshield/ert

/obj/item/implantcase/mindshield/ert
	name = "bio-chip case - 'ERT-mindshield'"
	desc = "A glass case containing an ERT mindshield bio-chip."
	imp = /obj/item/implant/mindshield/ert

/**
 * Fake (traitor's) mindshield
 */
/obj/item/implant/fake_mindshield
	name = "fake mindshield bio-chip"
	desc = "Имитирует имплант защиты разума, управляя его отображением на ИЛС службы безопасности. Может быть включён и выключен владельцем."
	origin_tech = "materials=3;biotech=5;syndicate=2"
	implant_state = "implant-syndicate"
	implant_data = /datum/implant_fluff/fake_mindshield
	icon_state = "fake_mindshield0"

/obj/item/implant/fake_mindshield/get_ru_names()
	return list(
		NOMINATIVE = "фальшивый имплант защиты разума",
		GENITIVE = "фальшивого импланта защиты разума",
		DATIVE = "фальшивому импланту защиты разума",
		ACCUSATIVE = "фальшивый имплант защиты разума",
		INSTRUMENTAL = "фальшивым имплантом защиты разума",
		PREPOSITIONAL = "фальшивом импланте защиты разума",
	)

/obj/item/implant/fake_mindshield/implant(mob/living/target, mob/user, force = FALSE)
	. = ..()
	if(!.)
		return .

	var/obj/item/implant/mindshield/real_mindshield = locate() in imp_in
	if(!real_mindshield)
		return .

	to_chat(target, span_warning("Вы чувствуете, что [declent_ru(ACCUSATIVE)] сразу же был перегружен и вышел из строя!"))
	qdel(src)

/obj/item/implant/fake_mindshield/activate()
	if(!imp_in)
		return

	var/is_active = HAS_TRAIT_FROM(imp_in, TRAIT_MINDSHIELD_HUD, UNIQUE_TRAIT_SOURCE(src))

	if(!is_active)
		ADD_TRAIT(imp_in, TRAIT_MINDSHIELD_HUD, UNIQUE_TRAIT_SOURCE(src))
	else
		REMOVE_TRAIT(imp_in, TRAIT_MINDSHIELD_HUD, UNIQUE_TRAIT_SOURCE(src))

	update_appearance(UPDATE_ICON_STATE)

	if(ishuman(imp_in))
		var/mob/living/carbon/human/H = imp_in
		H.sec_hud_set_implants()

/obj/item/implant/fake_mindshield/update_icon_state()
	var/is_active = HAS_TRAIT(imp_in, TRAIT_MINDSHIELD_HUD)
	icon_state = "fake_mindshield[is_active ? 1 : 0]"

/obj/item/implanter/fake_mindshield
	name = "bio-chip implanter (fake mindshield)"
	imp = /obj/item/implant/fake_mindshield

/obj/item/implantcase/fake_mindshield
	name = "bio-chip case - 'fake mindshield'"
	desc = "Стеклянный контейнер, содержащий фальшивый имплант защиты разума."
	imp = /obj/item/implant/fake_mindshield
