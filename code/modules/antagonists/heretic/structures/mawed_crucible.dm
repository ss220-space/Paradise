// The mawed crucible, a heretic structure that can create potions from bodyparts and organs.
/obj/structure/destructible/eldritch_crucible
	name = "Котёл Страданий"
	desc = "Глубокий чугунный котёл, удерживаемый стальными шипами. \
			Смотря на мерзкий экстракт внутри, вы чувствуете как ваш разум наполняется ужасными идеями."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "crucible"
	base_icon_state = "crucible"
	break_sound = 'sound/effects/wail.ogg'
	anchored = TRUE
	density = TRUE
	gender = MALE
	///How much mass this currently holds
	var/current_mass = 10
	///Maximum amount of mass
	var/max_mass = 10
	///Check to see if it is currently being used.
	var/struct_in_use = FALSE
	///Cooldown for the crucible to create mass from the eldritch
	COOLDOWN_DECLARE(refill_cooldown)


/obj/structure/destructible/eldritch_crucible/get_ru_names()
	return list(
		NOMINATIVE = "Котёл Страданий",
		GENITIVE = "Котла Страданий",
		DATIVE = "Котлу Страданий",
		ACCUSATIVE = "Котёл Страданий",
		INSTRUMENTAL = "Котлом Страданий",
		PREPOSITIONAL = "Котле Страданий",
	)


/obj/structure/destructible/eldritch_crucible/Initialize(mapload)
	. = ..()
	break_message = span_warning("[declent_ru(NOMINATIVE)] с грохотом разваливается!")
	START_PROCESSING(SSobj, src)


/obj/structure/destructible/eldritch_crucible/process(seconds_per_tick)
	if(COOLDOWN_TIMELEFT(src, refill_cooldown))
		return

	if(current_mass >= max_mass)
		return

	COOLDOWN_START(src, refill_cooldown, 15 SECONDS)
	current_mass++
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	update_appearance(UPDATE_ICON_STATE)


/obj/structure/destructible/eldritch_crucible/Destroy(force)
	// Create a spillage if we were destroyed with leftover mass
	if(current_mass)
		break_message = span_warning("[declent_ru(NOMINATIVE)] с грохотом разваливается, разливая повсюду блестящий экстракт!")
		var/turf/our_turf = get_turf(src)

		new /obj/effect/decal/cleanable/greenglow(our_turf)
		for(var/turf/nearby_turf as anything in get_adjacent_open_turfs(our_turf))
			if(!prob(10 * current_mass))
				continue

			new /obj/effect/decal/cleanable/greenglow(nearby_turf)

		playsound(our_turf, 'sound/effects/bubbles/bubbles2.ogg', 50, TRUE)

	return ..()


/obj/structure/destructible/eldritch_crucible/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	if(current_mass > 0)
		. += span_notice("Содержимым можно наполнить Жуткую Колбу.")

	if(current_mass < max_mass)
		var/to_fill = max_mass - current_mass
		. += span_notice("[declent_ru(DATIVE)] необходимо еще <b>[to_fill]</b> орган[to_fill == 1 ? "" : (to_fill <= 4 ? "а" : "ов")] или част[to_fill == 1 ? "ь" : (to_fill <= 4 ? "и" : "ей")] тела.")
	else
		. += span_boldnotice("[declent_ru(NOMINATIVE)] наполнен вязкой субстанцией и готов к использованию.")

	. += span_notice("Вы можете <b>[anchored ? "прикрепить к полу":"открепить от пола"]</b> [declent_ru(ACCUSATIVE)] используя <b>Кодекс Истезания</b> или <b>Прикосновение Мансуса</b>.")
	. += span_notice("Можно сварить следующие зелья:")
	for(var/obj/item/eldritch_potion/potion as anything in subtypesof(/obj/item/eldritch_potion))
		var/potion_string = span_notice(initial(potion.name) + " - " + initial(potion.crucible_tip))
		. += potion_string


/obj/structure/destructible/eldritch_crucible/examine_status(mob/user)
	if(IS_HERETIC_OR_MONSTER(user) || isobserver(user))
		return span_notice("Он цел на <b>[round(obj_integrity * 100 / max_integrity)]%</b>.")

	return ..()


// no breaky herety thingy
/obj/structure/destructible/eldritch_crucible/rust_heretic_act()
	return


/obj/structure/destructible/eldritch_crucible/attackby(obj/item/tool, mob/living/user, params)
	if(isorgan(tool))
		var/obj/item/organ/consumed = tool
		if(consumed.status & ORGAN_ROBOT)
			balloon_alert(user, "не орган!")
			return ATTACK_CHAIN_BLOCKED_ALL

		if(isbrain(consumed)) // Basically, don't eat organs like brains
			balloon_alert(user, "не подходит!")
			return ATTACK_CHAIN_BLOCKED_ALL

		if(!IS_HERETIC_OR_MONSTER(user))
			if(user.a_intent == INTENT_HARM)
				return ATTACK_CHAIN_PROCEED

			bite_the_hand(user)
			return ATTACK_CHAIN_BLOCKED_ALL

		consume_fuel(user, consumed)
		return ATTACK_CHAIN_BLOCKED_ALL


	if(istype(tool, /obj/item/codex_cicatrix) || istype(tool, /obj/item/melee/touch_attack/mansus_fist))
		playsound(src, 'sound/items/deconstruct.ogg', 30, TRUE, ignore_walls = FALSE)
		set_anchored(!anchored)
		balloon_alert(user, "[anchored ? "при":"от"]крученно")
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!istype(tool, /obj/item/reagent_containers/glass/beaker/eldritch))
		return ..()

	if(current_mass < max_mass)
		balloon_alert(user, "мало содержимого!")
		return ATTACK_CHAIN_BLOCKED_ALL

	var/obj/item/reagent_containers/glass/beaker/eldritch/to_fill = tool
	if(to_fill.reagents.total_volume >= to_fill.reagents.maximum_volume)
		balloon_alert(user, "колба полна!")
		return ATTACK_CHAIN_BLOCKED_ALL

	to_fill.reagents.add_reagent(/datum/reagent/eldritch, 50)
	current_mass--
	balloon_alert(user, "колба заполненна")
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/structure/destructible/eldritch_crucible/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!isliving(user))
		return

	if(!IS_HERETIC_OR_MONSTER(user))
		if(iscarbon(user))
			bite_the_hand(user)

		return TRUE

	if(struct_in_use)
		balloon_alert(user, "уже используется!")
		return TRUE

	if(current_mass < max_mass)
		balloon_alert(user, "недостаточно содержимого!")
		return TRUE

	INVOKE_ASYNC(src, PROC_REF(show_radial), user)
	return TRUE

/*
 * Wrapper for show_radial() to ensure struct_in_use is enabled and disabled correctly.
 */
/obj/structure/destructible/eldritch_crucible/proc/show_radial(mob/living/user)
	struct_in_use = TRUE
	create_potion(user)
	struct_in_use = FALSE

/*
 * Shows the user of radial of possible potions,
 * and create the potion they chose.
 */
/obj/structure/destructible/eldritch_crucible/proc/create_potion(mob/living/user)

	// Assoc list of [name] to [image] for the radial
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial, to spawn it
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/item/eldritch_potion/potion as anything in subtypesof(/obj/item/eldritch_potion))
			names_to_path[initial(potion.name)] = potion
			choices[initial(potion.name)] = image(icon = initial(potion.icon), icon_state = initial(potion.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		src,
		choices,
		require_near = TRUE,
		//tooltips = TRUE,
	)

	if(isnull(picked_choice))
		return

	var/spawned_type = names_to_path[picked_choice]
	if(!ispath(spawned_type, /obj/item/eldritch_potion))
		CRASH("[type] attempted to create a potion that wasn't an eldritch potion! (got: [spawned_type])")

	var/obj/item/spawned_pot = new spawned_type(drop_location())

	playsound(src, 'sound/effects/desecration/desecration-02.ogg', 75, TRUE)
	visible_message(span_notice("Сияющая субстанция из [declent_ru(GENITIVE)] перетекает в колбу, создавая [spawned_pot.declent_ru(ACCUSATIVE)]!"))
	balloon_alert(user, "зелье создано")

	current_mass = 0
	update_appearance(UPDATE_ICON_STATE)

/*
 * "Bites the hand that feeds it", except more literally.
 * Called when a non-heretic interacts with the crucible,
 * causing them to lose their active hand to it.
 */
/obj/structure/destructible/eldritch_crucible/proc/bite_the_hand(mob/living/carbon/user)
	var/obj/item/organ/external/arm = user.get_active_hand()
	if(QDELETED(arm))
		return

	to_chat(user, span_userdanger("[declent_ru(NOMINATIVE)] пожирает вашу [arm.declent_ru(ACCUSATIVE)]!"))
	arm.dismember()
	consume_fuel(consumed = arm)

/*
 * Consumes an organ or bodypart and increases the mass of the crucible.
 * If feeder is supplied, gives some feedback.
 */
/obj/structure/destructible/eldritch_crucible/proc/consume_fuel(mob/living/feeder, obj/item/consumed)
	if(current_mass >= max_mass)
		if(feeder)
			balloon_alert(feeder, "котёл полон!")

		return

	current_mass++
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	visible_message(span_notice("[declent_ru(NOMINATIVE)] пожирает [consumed.declent_ru(ACCUSATIVE)] и наполняется небольшим количеством таинственной субстанции!"))

	if(feeder)
		balloon_alert(feeder, "заполненность: [current_mass] / [max_mass]")

	qdel(consumed)
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/destructible/eldritch_crucible/update_icon_state()
	icon_state = "[base_icon_state][(current_mass == max_mass) ? null : "_empty"]"
	return ..()


// no breaky herety thingy
/obj/structure/destructible/eldritch_crucible/rust_heretic_act()
	return


// Potions created by the mawed crucible.
/obj/item/eldritch_potion
	name = "Варево дня и ночи"
	//No ru_names, because its not for game.
	desc = "Вы не должны были это увидеть."
	icon = 'icons/obj/eldritch.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// When a heretic examines a mawed crucible, shows a list of possible potions by name + includes this tip to explain what it does.
	var/crucible_tip = "Не делает абсолютно ничего."
	/// Typepath to the status effect this applies
	var/status_effect

/obj/item/eldritch_potion/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	. += span_notice(crucible_tip)

/obj/item/eldritch_potion/attack_self(mob/living/carbon/user)
	. = ..()
	if(.)
		return

	if(!iscarbon(user))
		return

	playsound(src, 'sound/effects/bubbles/bubbles.ogg', 50, TRUE)

	if(!IS_HERETIC_OR_MONSTER(user))
		to_chat(user, span_danger("Вы осторожно выливаете немного субстанции из [declent_ru(GENITIVE)] себе в рот. Вкус вызывает тошноту, а стакан внезапно исчезает."))
		user.reagents?.add_reagent(/datum/reagent/eldritch, 10)
		user.Disgust(50)
		qdel(src)
		return TRUE

	to_chat(user, span_notice("Вы пьете вязкую субстанцию из [declent_ru(GENITIVE)], в результате чего стакан дематериализуется."))
	potion_effect(user)
	qdel(src)
	return TRUE


/**
 * The effect of the potion, if it has any special one.
 * In general try not to override this
 * and utilize the status_effect var to make custom effects.
 */
/obj/item/eldritch_potion/proc/potion_effect(mob/user)
	var/mob/living/carbon/carbon_user = user
	carbon_user.apply_status_effect(status_effect)


/obj/item/eldritch_potion/crucible_soul
	name = "Зелье Блуждающей Души"
	desc = "Стеклянная бутылка с ярко-оранжевой полупрозрачной жидкостью."
	icon_state = "crucible_soul"
	status_effect = /datum/status_effect/crucible_soul
	crucible_tip = "Позволяет проходить сквозь стены. После окончания действия вы телепортируетесь в исходное местоположение. Длится 15 секунд."


/obj/item/eldritch_potion/crucible_soul/get_ru_names()
	return list(
		NOMINATIVE = "Зелье Блуждающей Души",
		GENITIVE = "Зелья Блуждающей Души",
		DATIVE = "Зелью Блуждающей Души",
		ACCUSATIVE = "Зелье Блуждающей Души",
		INSTRUMENTAL = "Зельем Блуждающей Души",
		PREPOSITIONAL = "Зелье Блуждающей Души",
	)


/obj/item/eldritch_potion/duskndawn
	name = "Зелье Заката и Рассвета"
	desc = "Стеклянная бутылка с мутно-желтой жидкостью. Содержимое то появляется, то исчезает."
	icon_state = "clarity"
	status_effect = /datum/status_effect/duskndawn
	crucible_tip = "Позволяет видеть сквозь преграды. Длится 90 секунд."


/obj/item/eldritch_potion/duskndawn/get_ru_names()
	return list(
		NOMINATIVE = "Зелье Заката и Рассвета",
		GENITIVE = "Зелья Заката и Рассвета",
		DATIVE = "Зелью Заката и Рассвета",
		ACCUSATIVE = "Зелье Заката и Рассвета",
		INSTRUMENTAL = "Зельем Заката и Рассвета",
		PREPOSITIONAL = "Зелье Заката и Рассвета",
	)


/obj/item/eldritch_potion/wounded
	name = "Зелье Раненого Солдата"
	desc = "Стеклянный бутылек, содержащая бесцветную темную жидкость."
	icon_state = "marshal"
	status_effect = /datum/status_effect/marshal
	crucible_tip = "Постепенно исцеляет полученные вами раны. Переломы и внутренние кровотечения заживут. \
					Чем серьезнее раны, тем сильнее заживление. Кроме того, предотвращает замедление от повреждений. \
					Длится 60 секунд."


/obj/item/eldritch_potion/wounded/get_ru_names()
	return list(
		NOMINATIVE = "Зелье Раненого Солдата",
		GENITIVE = "Зелья Раненого Солдата",
		DATIVE = "Зелью Раненого Солдата",
		ACCUSATIVE = "Зелье Раненого Солдата",
		INSTRUMENTAL = "Зельем Раненого Солдата",
		PREPOSITIONAL = "Зелье Раненого Солдата",
	)
