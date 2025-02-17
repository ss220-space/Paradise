////////////////////////////////////////////////////////////////////////////////
/// 								Droppers.								 ///
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "Пипетка, используемая для точного вливания небольших объёмов вещества в виде капель."
	ru_names = list(
        NOMINATIVE = "пипетка",
        GENITIVE = "пипетки",
        DATIVE = "пипетке",
        ACCUSATIVE = "пипетку",
        INSTRUMENTAL = "пипеткой",
        PREPOSITIONAL = "пипетке"
	)
	gender = FEMALE
	icon_state = "dropper"
	item_state = "dropper"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1, 2, 3, 4, 5)
	volume = 5
	pass_open_check = TRUE


/obj/item/reagent_containers/dropper/update_icon_state()
	icon_state = "[initial(icon_state)][reagents.total_volume ? "1" : ""]"


/obj/item/reagent_containers/dropper/on_reagent_change()
	update_icon(UPDATE_ICON_STATE)


/obj/item/reagent_containers/dropper/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/reagent_containers/dropper/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/to_transfer = 0
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(!reagents.total_volume)
			return
		if(user != C)
			visible_message(span_danger("[user] начина[pluralize_ru(user.gender, "ет", "ют")] капать что-то в глаза [C], используя [declent_ru(ACCUSATIVE)]!"))
			if(!do_after(user, 3 SECONDS, C, NONE))
				return
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/obj/item/safe_thing = null

			if(H.glasses)
				safe_thing = H.glasses
			if(H.wear_mask )
				if(H.wear_mask.flags_cover & MASKCOVERSEYES)
					safe_thing = H.wear_mask
			if(H.head)
				if(H.head.flags_cover & MASKCOVERSEYES)
					safe_thing = H.head

			if(safe_thing)
				visible_message(span_danger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся капнуть что-то в глаза [C], используя [declent_ru(ACCUSATIVE)], но [genderize_ru(user.gender, "ему", "ей", "ему", "им")] не удаётся!"))

				reagents.reaction(safe_thing, REAGENT_TOUCH)
				to_transfer = reagents.remove_any(amount_per_transfer_from_this)

				to_chat(user, span_notice("Вы перемещаете <b>[to_transfer]</b> единиц[declension_ru(to_transfer, "у", "ы", "")] вещества, используя [declent_ru(ACCUSATIVE)]."))
				return

		visible_message(span_danger("[user] закапыва[pluralize_ru(user.gender, "ет", "ют")] что-то в глаза [C], используя [declent_ru(ACCUSATIVE)]!"))
		reagents.reaction(C, REAGENT_TOUCH)

		var/list/injected = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			injected += R.name
		var/contained = english_list(injected)
		add_attack_logs(user, C, "Dripped with [src] containing ([contained]), transfering [to_transfer]")

		to_transfer = reagents.trans_to(C, amount_per_transfer_from_this)
		to_chat(user, span_notice("Вы перемещаете <b>[to_transfer]</b> единиц[declension_ru(to_transfer, "у", "ы", "")] вещества, используя [declent_ru(ACCUSATIVE)]."))

	if(isobj(target))
		if(!target.reagents)
			return

		if(reagents.total_volume)
			if(!target.is_open_container() && !(istype(target, /obj/item/reagent_containers/food) && !ispill(target)) && !istype(target, /obj/item/clothing/mask/cigarette))
				balloon_alert(user, "не подходит!")
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				balloon_alert(user, "нет места!")
				return

			to_transfer = reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, span_notice("Вы перемещаете <b>[to_transfer]</b> единиц[declension_ru(to_transfer, "у", "ы", "")] вещества, используя [declent_ru(ACCUSATIVE)]."))

		else
			if(!target.is_open_container() && !istype(target, /obj/structure/reagent_dispensers))
				balloon_alert(user, "не подходит!")
				return

			if(!target.reagents.total_volume)
				balloon_alert(user, "пусто!")
				return

			to_transfer = target.reagents.trans_to(src, amount_per_transfer_from_this)

			to_chat(user, span_notice("Вы заполняете [declent_ru(ACCUSATIVE)] <b>[to_transfer]</b> единиц[declension_ru(to_transfer, "ей", "ами", "ами")] вещества."))

/obj/item/reagent_containers/dropper/cyborg
	name = "Industrial Dropper"
	desc = "Пипетка увеличенного объёма, используемая для точного вливания небольших объёмов вещества в виде капель."
	ru_names = list(
        NOMINATIVE = "промышленная пипетка",
        GENITIVE = "промышленной пипетки",
        DATIVE = "промышленной пипетке",
        ACCUSATIVE = "промышленную пипетку",
        INSTRUMENTAL = "промышленной пипеткой",
        PREPOSITIONAL = "промышленной пипетке"
	)
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	volume = 10

/obj/item/reagent_containers/dropper/precision
	name = "pipette"
	desc = "Высокоточная пипетка уменьшенного объёма, используемая для работы с малыми объёмами вещества. Обычно применяются в биологии и химии."
	ru_names = list(
        NOMINATIVE = "микропипетка",
        GENITIVE = "микропипетки",
        DATIVE = "микропипетке",
        ACCUSATIVE = "микропипетку",
        INSTRUMENTAL = "микропипеткой",
        PREPOSITIONAL = "микропипетке"
	)
	icon_state = "pipette"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)
	volume = 1

//Syndicate item. Virus transmitting mini hypospray
/obj/item/reagent_containers/dropper/precision/viral_injector


/obj/item/reagent_containers/dropper/precision/viral_injector/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!target.can_inject(user, penetrate_thick = TRUE, ignore_pierceimmune = TRUE))
		return .
	if(!reagents.total_volume || !target.reagents)
		return .
	. |= ATTACK_CHAIN_SUCCESS
	to_chat(user, span_warning("Вы делаете укол [target] [declent_ru(INSTRUMENTAL)]."))

	var/list/injected = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		injected += reagent.name
		var/datum/reagent/blood/blood = reagent
		if(istype(blood) && blood.data["diseases"])
			var/virList = list()
			for(var/datum/disease/disease as anything in blood.data["diseases"])
				var/virusData = disease.name
				var/english_symptoms = list()
				var/datum/disease/virus/advance/adv_disease = disease
				if(istype(adv_disease))
					for(var/datum/symptom/symptom as anything in adv_disease.symptoms)
						english_symptoms += symptom.name
					virusData += " ([russian_list(english_symptoms)])"
				virList += virusData
			add_attack_logs(user, target, "Infected with [english_list(virList)].")

		reagents.reaction(target, REAGENT_INGEST, reagents.total_volume)
		reagents.trans_to(target, 1)

	var/contained = english_list(injected)
	add_attack_logs(user, target, "Injected with [src] containing ([contained])")

