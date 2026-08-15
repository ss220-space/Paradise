/obj/item/reagent_containers/food
	possible_transfer_amounts = null
	volume = 50 //Sets the default container amount for all food items.
	visible_transfer_rate = FALSE
	righthand_file = 'icons/mob/inhands/foods_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/foods_lefthand.dmi'
	var/filling_color = "#FFFFFF" //Used by sandwiches.
	var/junkiness = 0  //for junk food. used to lower human satiety.
	var/bitesize = 2
	var/has_special_eating_effects = FALSE
	var/eat_time = 0 SECONDS
	var/consume_sound = 'sound/items/eatfood.ogg'
	var/apply_type = REAGENT_INGEST
	var/apply_method = "проглоти"
	var/transfer_efficiency = 1.0
	var/instant_application = 0 //if we want to bypass the forcedfeed delay
	var/can_taste = TRUE//whether you can taste eating from this
	var/antable = TRUE // Will ants come near it?
	var/ant_location = null
	// Time we last checked for ants
	var/last_ant_time = 0
	var/foodtype = NONE
	var/last_check_time
	resistance_flags = FLAMMABLE
	container_type = INJECTABLE
	var/log_eating = FALSE // do we log if someone eats us?
	light_system = OVERLAY_LIGHT
	light_on = FALSE
	var/randomize_position = TRUE

/obj/item/reagent_containers/food/get_short_name()
	return declent_ru(NOMINATIVE)

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(randomize_position)
		pixel_x = rand(-5, 5) //Randomizes postion
		pixel_y = rand(-5, 5)

	if(!antable)
		return

	START_PROCESSING(SSobj, src)
	ant_location = get_turf(src)
	last_ant_time = world.time

/obj/item/reagent_containers/food/Destroy()
	ant_location = null
	if(datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/food/process()
	if(!antable)
		return PROCESS_KILL
	if(world.time > last_ant_time + 5 MINUTES)
		check_for_ants()

/obj/item/reagent_containers/food/empty()
	set hidden = TRUE
	return

/obj/item/reagent_containers/food/proc/check_for_ants()
	var/turf/T = get_turf(src)
	if(isturf(loc) && (T.temperature in 280 to 325) && !locate(/obj/structure/table) in T)
		if(ant_location == T)
			if(prob(15))
				if(!locate(/obj/effect/decal/ants) in T)
					new /obj/effect/decal/ants(T)
					antable = FALSE
					desc += " It appears to be infested with space ants. Yuck!"
					reagents.add_reagent("ants", 1) // Don't eat things with ants in i you weirdo.
		else
			ant_location = T

	last_ant_time = world.time

/obj/item/reagent_containers/food/proc/check_liked(fraction, mob/M)
	if(last_check_time + 50 > world.time)
		return FALSE
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M

	var/food_taste_reaction

	if(!food_taste_reaction)
		if(foodtype & H.dna.species.toxic_food)
			food_taste_reaction = FOOD_TOXIC
		else if(foodtype & H.dna.species.disliked_food)
			food_taste_reaction = FOOD_DISLIKED
		else if(foodtype & H.dna.species.liked_food)
			food_taste_reaction = FOOD_LIKED

	switch(food_taste_reaction)
		if(FOOD_TOXIC)
			to_chat(H, span_danger("Это было отвратительно! Мерзость!"))
			H.AdjustDisgust((25 + 30 * fraction) STATUS_EFFECT_CONSTANT)
		if(FOOD_DISLIKED)
			to_chat(H, span_warning("Это было очень невкусно. Фу."))
			H.AdjustDisgust((15 + 16 * fraction) STATUS_EFFECT_CONSTANT)
		if(FOOD_LIKED)
			to_chat(H, span_notice("Какой замечательный вкус!"))
			H.AdjustDisgust((-12 + -8 * fraction) STATUS_EFFECT_CONSTANT)

	last_check_time = world.time

/obj/item/reagent_containers/food/proc/format_message(type, list/messages, datum/species/species)
	var/plural = cmptext(type[length(type)], "s") ? "are" : "is"

	var/with_type = replacetext(pick(messages), "$TYPE", type)
	var/with_capital_type = replacetext(with_type, "$CAPITALTYPE", capitalize(type))
	var/with_species = replacetext(with_capital_type, "$SPECIES", species.name)
	var/with_plural_species = replacetext(with_species, "$PLURALSPECIES", species.name_plural)
	var/with_a_species = replacetext(with_plural_species, "$ASPECIES", "[species.a] [species.name]")
	return replacetext(with_a_species, "$IS", plural)

/obj/item/reagent_containers/food/proc/on_mob_eating_effect(mob/user)
	return

/obj/item/reagent_containers/food/examine(mob/user)
	. = ..()
	if(foodtype & MEAT)
		. += span_notice("Содержит мясо.")
	if(foodtype & VEGETABLES)
		. += span_notice("Содержит овощи.")
	if(foodtype & RAW)
		. += span_notice("Оно сырое.")
	if(foodtype & JUNKFOOD)
		. += span_notice("Это фаст-фуд.")
	if(foodtype & GRAIN)
		. += span_notice("Содержит злаки.")
	if(foodtype & FRUIT)
		. += span_notice("Содержит фрукты.")
	if(foodtype & DAIRY)
		. += span_notice("Это молочный продукт.")
	if(foodtype & FRIED)
		. += span_notice("Зажарено до корочки.")
	if(foodtype & SUGAR)
		. += span_notice("Содержит сахар.")
	if(foodtype & EGG)
		. += span_notice("Содержит яйца.")
	if(foodtype & GROSS)
		. += span_notice("Эта еда походит на помои.")
	if(foodtype & TOXIC)
		. += span_notice("Это буквально отрава.")
	if(user.can_see_food()) //Show each individual reagent
		. += span_notice("Содержит:")
		for(var/I in reagents.reagent_list)
			var/datum/reagent/R = I
			. += span_notice("[R.name] — [R.volume] ед.")
