/obj/item/organ/internal/liver
	name = "liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала человеку."
	ru_names = list(
		NOMINATIVE = "печень человека",
		GENITIVE = "печени человека",
		DATIVE = "печени человека",
		ACCUSATIVE = "печень человека",
		INSTRUMENTAL = "печенью человека",
		PREPOSITIONAL = "печени человека"
	)
	gender = FEMALE
	icon_state = "liver"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_LIVER
	var/alcohol_intensity = 1

/obj/item/organ/internal/liver/on_life()
	if(germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, span_warning("Ваша кожа зудит."))
	if(germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			owner.vomit()

	if(owner.life_tick % PROCESS_ACCURACY == 0)

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("charcoal"))
			//Healthy liver suffers on its own
			if(damage < min_broken_damage)
				internal_receive_damage(0.2 * PROCESS_ACCURACY)
			//Damaged one shares the fun
			else
				var/obj/item/organ/internal/organ = safepick(owner.internal_organs)
				if(organ)
					organ.internal_receive_damage(0.2  * PROCESS_ACCURACY)

		//Detox can heal small amounts of damage
		if(damage && damage < min_bruised_damage && owner.reagents.has_reagent("charcoal"))
			internal_receive_damage(-0.2 * PROCESS_ACCURACY)

		// Get the effectiveness of the liver.
		var/filter_effect = 3
		if(is_bruised())
			filter_effect -= 1
		if(is_traumatized())
			filter_effect -= 2

		// Damaged liver means some chemicals are very dangerous
		if(damage >= min_bruised_damage)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				// Ethanol and all drinks are bad
				if(istype(R, /datum/reagent/consumable/ethanol))
					owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)

			// Can't cope with toxins at all
			for(var/toxin in GLOB.liver_toxins)
				if(owner.reagents.has_reagent(toxin))
					owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)

/obj/item/organ/internal/liver/cybernetic
	name = "cybernetic liver"
	desc = "Электронное устройство, имитирующее работу органической печени. Функционально не имеет никаких отличий от органического аналога, кроме производственных затрат."
	ru_names = list(
		NOMINATIVE = "кибернетическая печень",
		GENITIVE = "кибернетической печени",
		DATIVE = "кибернетической печени",
		ACCUSATIVE = "кибернетическую печень",
		INSTRUMENTAL = "кибернетической печенью",
		PREPOSITIONAL = "кибернетической печени"
	)
	icon_state = "liver-c"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'
