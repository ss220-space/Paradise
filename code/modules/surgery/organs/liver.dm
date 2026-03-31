#define LIVER_FAILURE_STAGE_SECONDS 60 //amount of seconds before liver failure reaches a new stage
#define LIVER_DEFAULT_TOX_HEALING -0.1

/obj/item/organ/internal/liver
	name = "liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала человеку."
	gender = FEMALE
	icon_state = "liver"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_LIVER
	/// Affects how fast we getting drunk
	var/alcohol_intensity = 1
	/// Affects how much tox liver heals
	var/toxin_healing = LIVER_DEFAULT_TOX_HEALING
	var/failure_time = 0

/obj/item/organ/internal/liver/get_ru_names()
	return list(
		NOMINATIVE = "печень человека",
		GENITIVE = "печени человека",
		DATIVE = "печени человека",
		ACCUSATIVE = "печень человека",
		INSTRUMENTAL = "печенью человека",
		PREPOSITIONAL = "печени человека",
	)

/obj/item/organ/internal/liver/insert(mob/living/carbon/human/target)
	. = ..()
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_owner_examine))

/obj/item/organ/internal/liver/remove(mob/living/user, special)
	UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)
	return ..()

/obj/item/organ/internal/liver/on_life()
	if(germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, span_warning("Ваша кожа зудит."))
	if(germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			owner.vomit()

	if(owner.life_tick % PROCESS_ACCURACY == 0)

		//Passive toxin healing
		if(!is_traumatized())
			owner.adjustToxLoss(toxin_healing * PROCESS_ACCURACY)

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

		if((damage == max_damage) || (status & ORGAN_DEAD))
			failure_time += PROCESS_ACCURACY
			organ_failure(PROCESS_ACCURACY)
		else
			failure_time = 0


/obj/item/organ/internal/liver/organ_failure(seconds_per_tick)
	var/obj/item/organ/internal/organ = safepick(owner.internal_organs)
	switch(failure_time/LIVER_FAILURE_STAGE_SECONDS)
		if(1)
			to_chat(owner, span_userdanger("You feel stabbing pain in your abdomen!"))
		if(2)
			to_chat(owner, span_userdanger("You feel a burning sensation in your gut!"))
			owner.vomit()
		if(3)
			to_chat(owner, span_userdanger("You feel painful acid in your throat!"))
			owner.vomit(0, VOMIT_BLOOD, 0 SECONDS)
		if(4)
			to_chat(owner, span_userdanger("Overwhelming pain knocks you out!"))
			owner.vomit(0, VOMIT_BLOOD, distance = rand(1,2))
			owner.emote("Scream")
			owner.AdjustDizzy(2.5 SECONDS)
		if(5)
			to_chat(owner, span_userdanger("You feel as if your guts are about to melt!"))
			owner.vomit(0, VOMIT_BLOOD, distance = rand(1,3))
			owner.emote("Scream")
			owner.AdjustDizzy(5 SECONDS)

	switch(failure_time)
		//After 60 seconds we begin to feel the effects
		if(1 * LIVER_FAILURE_STAGE_SECONDS to 2 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.2 * seconds_per_tick,forced = TRUE)
			owner.AdjustDisgust(0.1 * seconds_per_tick)

		if(2 * LIVER_FAILURE_STAGE_SECONDS to 3 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.4 * seconds_per_tick,forced = TRUE)
			owner.AdjustDrowsy(0.5 SECONDS * seconds_per_tick)
			owner.AdjustDisgust(0.3 * seconds_per_tick)

		if(3 * LIVER_FAILURE_STAGE_SECONDS to 4 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.6 * seconds_per_tick,forced = TRUE)
			organ.internal_receive_damage(0.2  * seconds_per_tick)
			owner.AdjustDrowsy(1 SECONDS * seconds_per_tick)
			owner.AdjustDisgust(0.6 * seconds_per_tick)

			if(SPT_PROB(1.5, seconds_per_tick))
				owner.emote("drool")

		if(4 * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			owner.adjustToxLoss(0.8 * seconds_per_tick,forced = TRUE)
			organ.internal_receive_damage(0.2  * seconds_per_tick)
			owner.AdjustDrowsy(1.6 SECONDS * seconds_per_tick)
			owner.AdjustDisgust(1.2 * seconds_per_tick)

			if(SPT_PROB(3, seconds_per_tick))
				owner.emote("drool")

/obj/item/organ/internal/liver/proc/on_owner_examine(datum/source, mob/user, list/examine_list)
	var/mob/living/carbon/human/H = owner
	if(!H || failure_time <= 0)
		return

	if(H.is_eyes_covered())
		return

	switch(failure_time)
		if(0 to 3 * LIVER_FAILURE_STAGE_SECONDS - 1)
			examine_list += span_notice("[H]'s eyes are slightly yellow.")
		if(3 * LIVER_FAILURE_STAGE_SECONDS to 4 * LIVER_FAILURE_STAGE_SECONDS - 1)
			examine_list += span_notice("[H]'s eyes are completely yellow, and [H.p_they()] [H.p_are()] visibly suffering.")
		if(4 * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			examine_list += span_danger("[H]'s eyes are completely yellow and swelling with pus. [H.p_they()] won't last long.")

/obj/item/organ/internal/liver/cybernetic
	name = "cybernetic liver"
	desc = "Электронное устройство, имитирующее работу органической печени. Функционально не имеет никаких отличий от органического аналога, кроме производственных затрат."
	icon_state = "liver-c"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	pickup_sound = 'sound/items/handling/pickup/component_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/component_drop.ogg'

/obj/item/organ/internal/liver/cybernetic/get_ru_names()
	return list(
		NOMINATIVE = "кибернетическая печень",
		GENITIVE = "кибернетической печени",
		DATIVE = "кибернетической печени",
		ACCUSATIVE = "кибернетическую печень",
		INSTRUMENTAL = "кибернетической печенью",
		PREPOSITIONAL = "кибернетической печени",
	)

#undef LIVER_FAILURE_STAGE_SECONDS
#undef LIVER_DEFAULT_TOX_HEALING
