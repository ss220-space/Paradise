///amount of seconds before liver failure reaches a new stage
#define LIVER_FAILURE_STAGE_SECONDS 60
#define LIVER_DEFAULT_TOX_HEALING -0.1
///liver failure stages
#define LIVER_FAILURE_STAGE_GOOD 0
#define LIVER_FAILURE_STAGE_PAIN 1
#define LIVER_FAILURE_STAGE_BURN 2
#define LIVER_FAILURE_STAGE_ACID 3
#define LIVER_FAILURE_STAGE_COLLAPSE 4
#define LIVER_FAILURE_STAGE_MELT 5

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
	/// How long has our liver been failing
	var/failure_time = 0
	/// Can the liver regenerate itself
	var/regeneration = FALSE

/obj/item/organ/internal/liver/get_ru_names()
	return alist(
		NOMINATIVE = "печень человека",
		GENITIVE = "печени человека",
		DATIVE = "печени человека",
		ACCUSATIVE = "печень человека",
		INSTRUMENTAL = "печенью человека",
		PREPOSITIONAL = "печени человека",
	)

/obj/item/organ/internal/liver/insert(mob/living/carbon/human/target)
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_owner_examine))

/obj/item/organ/internal/liver/remove(mob/living/user, special)
	UnregisterSignal(owner, COMSIG_ATOM_EXAMINE)
	return ..()

/obj/item/organ/internal/liver/on_life()
	if(germ_level > INFECTION_LEVEL_ONE && prob(1))
		to_chat(owner, span_warning("Ваша кожа зудит."))
	if(germ_level > INFECTION_LEVEL_TWO && prob(1))
		owner.vomit()

	if(owner.life_tick % PROCESS_ACCURACY != 0)
		return

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

	if(damage)
		//Detox can heal small amounts of damage
		if((damage < min_bruised_damage && owner.reagents.has_reagent("charcoal")))
			internal_receive_damage(-0.2 * PROCESS_ACCURACY)
		//Upgraded cyber liver heals all the time when we dont have toxins
		if(regeneration && (owner.getToxLoss() == 0))
			internal_receive_damage(-0.2 * PROCESS_ACCURACY)

	// Damaged liver means some chemicals are very dangerous
	if(damage >= min_bruised_damage)
		for(var/datum/reagent/reagent in owner.reagents.reagent_list)
			// Ethanol and all drinks are bad
			if(istype(reagent, /datum/reagent/consumable/ethanol))
				owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)

		// Can't cope with toxins at all
		for(var/toxin in GLOB.liver_toxins)
			if(owner.reagents.has_reagent(toxin))
				owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)

	if(owner.undergoing_liver_failure())
		failure_time += PROCESS_ACCURACY
		organ_failure(PROCESS_ACCURACY)
	else
		failure_time = 0

/obj/item/organ/liver/handle_failing_organs(seconds_per_tick)
	if(owner.stat == DEAD)
		return

	if(HAS_TRAIT(owner, TRAIT_LIVERLESS_METABOLISM))
		return
	return ..()

/obj/item/organ/internal/liver/organ_failure(seconds_per_tick)
	var/obj/item/organ/internal/organ = safepick(owner.internal_organs)
	switch(failure_time/LIVER_FAILURE_STAGE_SECONDS)
		if(LIVER_FAILURE_STAGE_PAIN)
			to_chat(owner, span_userdanger("Вы чувствуете острую боль в животе."))
		if(LIVER_FAILURE_STAGE_BURN)
			to_chat(owner, span_userdanger("Вы чувствуете жжение в животе!"))
			owner.vomit()
		if(LIVER_FAILURE_STAGE_ACID)
			to_chat(owner, span_userdanger("Вы чувствуете болезненное ощущение кислоты в горле!"))
			owner.vomit(0, VOMIT_BLOOD, 0 SECONDS)
		if(LIVER_FAILURE_STAGE_COLLAPSE)
			to_chat(owner, span_userdanger("Невыносимая боль сбивает вас с ног!"))
			owner.vomit(0, VOMIT_BLOOD, distance = rand(1,2))
			owner.emote("Scream")
			owner.AdjustDizzy(2.5 SECONDS)
		if(LIVER_FAILURE_STAGE_MELT)
			to_chat(owner, span_userdanger("У вас ощущение, будто ваши внутренности вот-вот расплавятся!"))
			owner.vomit(0, VOMIT_BLOOD, distance = rand(1,3))
			owner.emote("Scream")
			owner.AdjustDizzy(5 SECONDS)

	switch(failure_time)
		//After 60 seconds we begin to feel the effects
		if(LIVER_FAILURE_STAGE_PAIN * LIVER_FAILURE_STAGE_SECONDS to LIVER_FAILURE_STAGE_BURN * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.2 * seconds_per_tick,forced = TRUE)
			owner.AdjustDisgust(0.1 * seconds_per_tick)

		if(LIVER_FAILURE_STAGE_BURN * LIVER_FAILURE_STAGE_SECONDS to LIVER_FAILURE_STAGE_ACID * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.4 * seconds_per_tick,forced = TRUE)
			owner.AdjustDrowsy(0.5 SECONDS * seconds_per_tick)
			owner.AdjustDisgust(0.3 * seconds_per_tick)

		if(LIVER_FAILURE_STAGE_ACID * LIVER_FAILURE_STAGE_SECONDS to LIVER_FAILURE_STAGE_COLLAPSE * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.6 * seconds_per_tick,forced = TRUE)
			organ.internal_receive_damage(0.2  * seconds_per_tick)
			owner.AdjustDrowsy(1 SECONDS * seconds_per_tick)
			owner.AdjustDisgust(0.6 * seconds_per_tick)

			if(SPT_PROB(1.5, seconds_per_tick))
				owner.emote("drool")

		if(LIVER_FAILURE_STAGE_COLLAPSE * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			owner.adjustToxLoss(0.8 * seconds_per_tick,forced = TRUE)
			organ.internal_receive_damage(0.2  * seconds_per_tick)
			owner.AdjustDrowsy(1.6 SECONDS * seconds_per_tick)
			owner.AdjustDisgust(1.2 * seconds_per_tick)

			if(SPT_PROB(3, seconds_per_tick))
				owner.emote("drool")

/obj/item/organ/internal/liver/proc/on_owner_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner || failure_time <= 0)
		return

	if(human_owner.is_eyes_covered())
		return

	var/failure_stage = floor(failure_time / LIVER_FAILURE_STAGE_SECONDS)

	switch(failure_stage)
		if(LIVER_FAILURE_STAGE_GOOD to LIVER_FAILURE_STAGE_BURN)
			examine_list += span_notice("[GEND_HIS_HER_CAP(human_owner)] глаза выглядят слегка жёлтыми.")

		if(LIVER_FAILURE_STAGE_ACID)
			examine_list += span_notice("[GEND_HIS_HER_CAP(human_owner)] глаза полностью жёлтые и [GEND_HE_SHE(human_owner)] явно страдает.")

		if(LIVER_FAILURE_STAGE_COLLAPSE to INFINITY)
			examine_list += span_danger("[GEND_HIS_HER_CAP(human_owner)] глаза полностью жёлтые и опухшие от гноя. [GEND_HE_SHE_CAP(human_owner)] долго не продержится.")

/obj/item/organ/internal/liver/cybernetic
	name = "cybernetic liver"
	desc = "Электронное устройство, имитирующее работу органической печени. Функционально не имеет никаких отличий от органического аналога, кроме производственных затрат."
	icon_state = "liver-c"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	pickup_sound = 'sound/items/handling/pickup/component_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/component_drop.ogg'

/obj/item/organ/internal/liver/cybernetic/get_ru_names()
	return alist(
		NOMINATIVE = "кибернетическая печень",
		GENITIVE = "кибернетической печени",
		DATIVE = "кибернетической печени",
		ACCUSATIVE = "кибернетическую печень",
		INSTRUMENTAL = "кибернетической печенью",
		PREPOSITIONAL = "кибернетической печени",
	)

/obj/item/organ/internal/liver/cybernetic/upgraded
	name = "upgraded cybernetic liver"
	desc = "Продвинутая версия кибернетической печени. Имеет большую прочность по сравнению с аналогами, лучше перерабатывает токсины и самовосстанавливается во время бездействия."
	icon_state = "liver-c-u"
	origin_tech = "biotech=4, materials=4, engineering=4"
	max_damage = 120
	min_bruised_damage = 30
	min_broken_damage = 90
	toxin_healing = 2 * LIVER_DEFAULT_TOX_HEALING
	regeneration = TRUE

/obj/item/organ/internal/liver/cybernetic/upgraded/get_ru_names()
	return alist(
		NOMINATIVE = "улучшенная кибернетическая печень",
		GENITIVE = "улучшенной кибернетической печени",
		DATIVE = "улучшенной кибернетической печени",
		ACCUSATIVE = "улучшенную кибернетическую печень",
		INSTRUMENTAL = "улучшенной кибернетической печенью",
		PREPOSITIONAL = "улучшенной кибернетической печени",
	)

/obj/item/organ/internal/liver/cybernetic/upgraded/insert(mob/living/carbon/target, special)
	. = ..()

	if(HAS_TRAIT(target, TRAIT_ADVANCED_CYBERIMPLANTS))
		toxin_healing += LIVER_DEFAULT_TOX_HEALING // better tox healing
		ADD_TRAIT(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src))

/obj/item/organ/internal/liver/cybernetic/upgraded/remove(mob/living/carbon/human/target, special)
	if(HAS_TRAIT_FROM(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src)))
		toxin_healing = initial(toxin_healing)
		REMOVE_TRAIT(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src))

	return ..()

#undef LIVER_FAILURE_STAGE_SECONDS
#undef LIVER_DEFAULT_TOX_HEALING
#undef LIVER_FAILURE_STAGE_GOOD
#undef LIVER_FAILURE_STAGE_PAIN
#undef LIVER_FAILURE_STAGE_BURN
#undef LIVER_FAILURE_STAGE_ACID
#undef LIVER_FAILURE_STAGE_COLLAPSE
#undef LIVER_FAILURE_STAGE_MELT
