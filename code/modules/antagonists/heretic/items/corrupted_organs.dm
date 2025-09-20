/// Renders you unable to see people who were heretics at the time that this organ is gained
/obj/item/organ/internal/eyes/corrupt
	name = "искаженные сферы"
	desc = "Эти глаза увидели то, чего им видеть не следовало."
	icon_state = "eyes_voidwalker"
	color = COLOR_VOID_PURPLE
	//iris_overlay = null
	//eye_color_left = COLOR_VOID_PURPLE
	//eye_color_right = COLOR_VOID_PURPLE
	//organ_flags.status = parent_type:://organ_flags.status | ORGAN_HAZARDOUS
	/// The override images we are applying
	var/list/hallucinations


/obj/item/organ/internal/eyes/corrupt/get_ru_names()
	return list(
		NOMINATIVE = "искажённые сферы",
		GENITIVE = "искажённых сфер",
		DATIVE = "искажённым сферам",
		ACCUSATIVE = "искажённые сферы",
		INSTRUMENTAL = "искажёнными сферами",
		PREPOSITIONAL = "искажённых сферах"
	)


/obj/item/organ/internal/eyes/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ, FALSE)
	AddElement(/datum/element/noticable_organ, "Зрачки широко раскрыты, радужки нет. В их глубинах что-то движется.", BODY_ZONE_PRECISE_EYES)


/obj/item/organ/internal/eyes/corrupt/insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(!organ_owner.client)
		return

	var/list/human_mobs = GLOB.human_list.Copy()
	human_mobs -= organ_owner
	for(var/mob/living/carbon/human/check_human as anything in human_mobs)
		if(!isheretic(check_human) && !prob(5)) // Throw in some false positives
			continue

		var/image/invisible_man = image('icons/blanks/32x32.dmi', check_human, "nothing")
		invisible_man.override = TRUE
		LAZYADD(hallucinations, invisible_man)

	if(!LAZYLEN(hallucinations))
		return

	organ_owner.client.images |= hallucinations


/obj/item/organ/internal/eyes/corrupt/remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(!LAZYLEN(hallucinations))
		return

	organ_owner.client?.images -= hallucinations
	QDEL_NULL(hallucinations)


/// Sometimes speak in incomprehensible tongues
/obj/item/organ/internal/vocal_cords/corrupt
	name = "искаженные голосовые связки"
	desc = "Эти только лгут."
	gender = PLURAL
	//organ_flags.status = parent_type:://organ_flags.status | ORGAN_HAZARDOUS


/obj/item/organ/internal/vocal_cords/corrupt/get_ru_names()
	return list(
		NOMINATIVE = "искажённые голосовые связки",
		GENITIVE = "искажённых голосовых связок",
		DATIVE = "искажённым голосовым связкам",
		ACCUSATIVE = "искажённые голосовые связки",
		INSTRUMENTAL = "искажёнными голосовыми связками",
		PREPOSITIONAL = "искажённых голосовых связках"
	)


/obj/item/organ/internal/vocal_cords/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	//AddElement(/datum/element/noticable_organ, "The inside of %PRONOUN_Their mouth is full of stars.", BODY_ZONE_PRECISE_MOUTH)


/obj/item/organ/internal/vocal_cords/corrupt/insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_MOB_SAY, PROC_REF(on_spoken))


/obj/item/organ/internal/vocal_cords/corrupt/remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_MOB_SAY)


/// When the mob speaks, sometimes put it in a different language
/obj/item/organ/internal/vocal_cords/corrupt/proc/on_spoken(mob/living/organ_owner, list/speech_args)
	SIGNAL_HANDLER
	/*
	if(organ_owner.has_reagent("holywater") || prob(60))
		return

	speech_args[SPEECH_LANGUAGE] = /datum/language/shadowtongue
*/

/// Randomly secretes alcohol or hallucinogens when you're drinking something
/obj/item/organ/internal/liver/corrupt
	name = "искаженная печень"
	desc = "После увиденного вам действительно захочется выпить."
	//organ_flags.status = parent_type:://organ_flags.status | ORGAN_HAZARDOUS
	/// How much extra ingredients to add?
	var/amount_added = 5
	/// What extra ingredients can we add?
	var/list/extra_ingredients = list(
		"rum", "vodka", "whiskey", "ale", "beer", "laughter", "bath_salts", "lsd", "krokodil"
	)


/obj/item/organ/internal/liver/corrupt/get_ru_names()
	return list(
		NOMINATIVE = "искажённая печень",
		GENITIVE = "искажённой печени",
		DATIVE = "искажённой печени",
		ACCUSATIVE = "искажённую печень",
		INSTRUMENTAL = "искажённой печенью",
		PREPOSITIONAL = "искажённой печени"
	)


/obj/item/organ/internal/liver/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)


/obj/item/organ/internal/liver/corrupt/insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_drank))


/obj/item/organ/internal/liver/corrupt/remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_ATOM_EXPOSE_REAGENTS)


/// If we drank something, add a little extra
/obj/item/organ/internal/liver/corrupt/proc/on_drank(mob/living/carbon/human, list/reagents, methods)
	SIGNAL_HANDLER
	if(!(methods & REAGENT_INGEST))
		return

	if(human.reagents.has_reagent("holywater"))
		return

	var/datum/reagents/extra_reagents = new()
	extra_reagents.add_reagent(pick(extra_ingredients), amount_added)
	extra_reagents.trans_to(human, amount_added)
	if(!prob(20))
		return

	to_chat(human, span_warning("Сделав глоток, вы чувствуете, как в желудке что-то бурлит..."))


/// Occasionally bombards you with spooky hands and lets everyone hear your pulse.
/obj/item/organ/internal/heart/corrupt
	name = "искажённое сердце"
	desc = "Какая порча распространяется вместе с кровью?"
	//organ_flags.status = parent_type:://organ_flags.status | ORGAN_HAZARDOUS
	/// How long until the next heart?
	COOLDOWN_DECLARE(hand_cooldown)


/obj/item/organ/internal/heart/corrupt/get_ru_names()
	return list(
		NOMINATIVE = "искажённое сердце",
		GENITIVE = "искажённого сердца",
		DATIVE = "искажённому сердцу",
		ACCUSATIVE = "искажённое сердце",
		INSTRUMENTAL = "искажённым сердцем",
		PREPOSITIONAL = "искажённом сердце"
	)


/obj/item/organ/internal/heart/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)


/obj/item/organ/internal/heart/corrupt/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(!COOLDOWN_FINISHED(src, hand_cooldown) || IS_IN_MANSUS(owner) || !owner.needs_heart() || !beating || owner.reagents.has_reagent("holywater"))
		return

	fire_curse_hand(owner)
	COOLDOWN_START(src, hand_cooldown, rand(6 SECONDS, 45 SECONDS)) // Wide variance to put you off guard


/// Sometimes cough out some kind of dangerous gas
/obj/item/organ/internal/lungs/corrupt
	name = "искаженные лёгкие"
	desc = "Некоторые вещи ДОЛЖНЫ утонуть в смоле."
	//organ_flags.status = parent_type:://organ_flags.status | ORGAN_HAZARDOUS
	/// How likely are we not to cough every time we take a breath?
	var/cough_chance = 15
	/// How much gas to emit?
	var/gas_amount = 30
	/// What can we cough up?
	/*var/list/gas_types = list(
		/datum/gas/bz = 30,
		/datum/gas/miasma = 50,
		/datum/gas/plasma = 20,
	)*/


/obj/item/organ/internal/lungs/corrupt/get_ru_names()
	return list(
		NOMINATIVE = "искажённые лёгкие",
		GENITIVE = "искажённых лёгких",
		DATIVE = "искажённым лёгким",
		ACCUSATIVE = "искажённые лёгкие",
		INSTRUMENTAL = "искажёнными лёгкими",
		PREPOSITIONAL = "искажённых лёгких"
	)


/obj/item/organ/internal/lungs/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)


/obj/item/organ/internal/lungs/corrupt/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather)
	. = ..()
	if(!. || IS_IN_MANSUS(owner) || breather.reagents.has_reagent("holywater") || !prob(cough_chance))
		return

	breather.emote("cough");
	/*
	var/chosen_gas = pick_weight_classic(gas_types)
	var/datum/gas_mixture/mix_to_spawn = new()
	mix_to_spawn.add_gas(pick(chosen_gas))
	mix_to_spawn.gases[chosen_gas][MOLES] = gas_amount
	mix_to_spawn.temperature = breather.bodytemperature
	log_atmos("[owner] coughed some gas into the air due to their corrupted lungs.", mix_to_spawn)
	var/turf/simulated/our_turf = get_turf(breather)
	*/
	atmos_spawn_air(pick(LINDA_SPAWN_TOXINS, LINDA_SPAWN_N2O, LINDA_SPAWN_N2O), 20)


/// It's full of worms
/obj/item/organ/internal/appendix/corrupt
	name = "искажённый аппендикс"
	desc = "Какая темная космическая сила вообще может захотеть испортить аппендикс?"
	//organ_flags.status = parent_type:://organ_flags.status | ORGAN_HAZARDOUS
	/// How likely are we to spawn worms?
	var/worm_chance = 2


/obj/item/organ/internal/appendix/corrupt/get_ru_names()
	return list(
		NOMINATIVE = "искажённый аппендикс",
		GENITIVE = "искажённого аппендикса",
		DATIVE = "искажённому аппендиксу",
		ACCUSATIVE = "искажённый аппендикс",
		INSTRUMENTAL = "искажённым аппендиксом",
		PREPOSITIONAL = "искажённом аппендиксе"
	)


/obj/item/organ/internal/appendix/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "Живот вздут... и шевелится.", BODY_ZONE_PRECISE_GROIN)


/obj/item/organ/internal/appendix/corrupt/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(owner.stat != CONSCIOUS || owner.reagents.has_reagent("holywater") || IS_IN_MANSUS(owner) || !SPT_PROB(worm_chance, seconds_per_tick))
		return

	owner.vomit(distance = 0)
	owner.Knockdown(0.5 SECONDS)
