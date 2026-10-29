/datum/element/braineater

/datum/element/braineater/Attach(datum/target)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_HUMAN_UNARMED_ATTACK, PROC_REF(eat_brains))

/datum/element/braineater/proc/eat_brains(mob/living/carbon/user, mob/living/carbon/human/target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(eat_brains_async), user, target)

/datum/element/braineater/proc/eat_brains_async(mob/living/carbon/user, mob/living/carbon/human/target)

	if(ismachineperson(target))
		to_chat(user, span_warning(span_zombie("Мы не чуем мозгов в [target.declent_ru(PREPOSITIONAL)].")))
		return FALSE

	if(user.pulling == target)
		if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
			to_chat(user, span_warning(span_zombie("Наш укус не может пробить кожу [target.declent_ru(GENITIVE)]!")))
			return FALSE

		user.visible_message(span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] жестоко куса[PLUR_ET_UT(user)] [target.declent_ru(ACCUSATIVE)]!"))
		playsound(user.loc, 'sound/weapons/bite.ogg', 20, TRUE)
		playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
		user.do_attack_animation(target, ATTACK_EFFECT_BITE)
		target.apply_damage(20, BRUTE, user.zone_selected)

		for(var/datum/disease/virus/virus in user.diseases)
			virus.Contract(target, BLOOD|BITES, need_protection_check = TRUE, zone = user.zone_selected)

		target.Dizzy(10 SECONDS)
		target.Confused(10 SECONDS)

		if(!HAS_TRAIT(user, TRAIT_NON_INFECTIOUS_ZOMBIE))
			for(var/datum/disease/virus/zombie/zomb in target.diseases)
				zomb.stage = max(rand(3, 4), zomb.stage)
		return TRUE

	if(HAS_TRAIT(target, TRAIT_I_WANT_BRAINS))
		to_chat(user, span_warning(span_zombie("Мы не чуем свежих мозгов в [target.declent_ru(PREPOSITIONAL)].")))
		return

	var/obj/item/organ/internal/brain/eat_brain = target.get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!eat_brain)
		to_chat(user, span_warning(span_zombie("Мы не чуем мозгов в [target.declent_ru(PREPOSITIONAL)].")))
		return FALSE
	var/obj/item/organ/external/brain_house = target.get_organ(eat_brain.parent_organ_zone)
	if(!brain_house)
		to_chat(user, span_warning(span_zombie("Мы не чуем мозгов в [target.declent_ru(PREPOSITIONAL)].")))
		return FALSE

	if(brain_house.limb_zone != user.zone_selected || !brain_house.open)
		return FALSE

	if(target.getarmor(brain_house, MELEE) > 0) // dont count negative armor
		to_chat(user, span_warning(span_zombie("Мозги [target.declent_ru(GENITIVE)] заблокированы.")))
		return FALSE // Armor blocks zombies trying to eat your brains!

	if(target.getBrainLoss() >= 120)
		to_chat(user, span_warning(span_zombie("Мозгов не осталось...")))
		return TRUE

	eat_brain.custom_pain("О, БОЖЕ!!! ОНИ ЕДЯТ МОИ [uppertext(eat_brain.declent_ru(NOMINATIVE))]!!") // gnarly
	user.visible_message(span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] вонзает когти в [brain_house.declent_ru(ACCUSATIVE)] [target.declent_ru(GENITIVE)], поедая [eat_brain.declent_ru(ACCUSATIVE)]!"), span_danger(span_zombie("Мы пируем мозгами [target].")))

	for(var/datum/disease/virus/virus in user.diseases)
		virus.Contract(target, BLOOD|BITES, need_protection_check = FALSE, zone = user.zone_selected)

	if(!HAS_TRAIT(user, TRAIT_NON_INFECTIOUS_ZOMBIE))
		for(var/datum/disease/virus/zombie/zomb in target.diseases)
			zomb.stage = max(5, zomb.stage)

	if(!do_after(user, 1 SECONDS, target))
		return

	playsound(user.loc, 'sound/items/eatfood.ogg', 20, TRUE)
	playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
	user.do_attack_animation(target, ATTACK_EFFECT_BITE)
	target.adjustBrainLoss(5)
	if(target.stat == CONSCIOUS && prob(33))
		// Ouch, eaten alive.
		target.emote("scream")

	if(user.nutrition < NUTRITION_LEVEL_FULL - 10) // no fat zombies
		user.set_nutrition(user.nutrition + 10)

	user.heal_overall_damage(2, 2)
	return TRUE
