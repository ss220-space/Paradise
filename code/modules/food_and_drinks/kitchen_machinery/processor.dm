/obj/machinery/processor
	name = "Food Processor"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = 2.9
	density = TRUE
	anchored = TRUE

	var/broken = 0
	var/processing = 0

	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 50
	var/rating_speed = 0
	var/rating_amount = 0

/obj/machinery/processor/New()
		..()
		component_parts = list()
		component_parts += new /obj/item/circuitboard/processor(null)
		component_parts += new /obj/item/stock_parts/matter_bin(null)
		component_parts += new /obj/item/stock_parts/manipulator(null)
		RefreshParts()

/obj/machinery/processor/RefreshParts()
	rating_speed = 0
	rating_amount = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		rating_amount += B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating_speed += M.rating

/obj/machinery/processor/process()
	if(processing)
		return
	var/mob/living/simple_animal/slime/picked_slime
	for(var/mob/living/simple_animal/slime/slime in range(1, src))
		if(slime.loc == src)
			continue
		if(slime.stat)
			picked_slime = slime
			break
	if(!picked_slime)
		return
	var/datum/food_processor_process/P = select_recipe(picked_slime)
	if(!P)
		return

	visible_message("<span class='notice'>[picked_slime] is sucked into [src].</span>")
	picked_slime.forceMove(src)

//RECIPE DATUMS
/datum/food_processor_process
	var/input
	var/output
	var/time = 40

/datum/food_processor_process/proc/process_food(loc, what, obj/machinery/processor/processor)
	if(output && loc && processor)
		for(var/i in 1 to processor.rating_amount)
			new output(loc)
	if(what)
		qdel(what)

/////////////////////////
/////OBJECT RECIPIES/////
/////////////////////////
/datum/food_processor_process/meat
	input = /obj/item/reagent_containers/food/snacks/meat
	output = /obj/item/reagent_containers/food/snacks/meatball

/datum/food_processor_process/potato
	input = /obj/item/reagent_containers/food/snacks/grown/potato
	output = /obj/item/reagent_containers/food/snacks/rawsticks

/datum/food_processor_process/rawsticks
	input = /obj/item/reagent_containers/food/snacks/rawsticks
	output = /obj/item/reagent_containers/food/snacks/tatortot

/datum/food_processor_process/soybeans
	input = /obj/item/reagent_containers/food/snacks/grown/soybeans
	output = /obj/item/reagent_containers/food/snacks/soydope

/datum/food_processor_process/spaghetti
	input = /obj/item/reagent_containers/food/snacks/doughslice
	output = /obj/item/reagent_containers/food/snacks/spaghetti

/datum/food_processor_process/macaroni
	input = /obj/item/reagent_containers/food/snacks/spaghetti
	output = /obj/item/reagent_containers/food/snacks/macaroni

/datum/food_processor_process/parsnip
	input = /obj/item/reagent_containers/food/snacks/grown/parsnip
	output = /obj/item/reagent_containers/food/snacks/roastparsnip

/datum/food_processor_process/carrot
	input =  /obj/item/reagent_containers/food/snacks/grown/carrot
	output = /obj/item/reagent_containers/food/snacks/grown/carrot/wedges

/////////////////////////
///END OBJECT RECIPIES///
/////////////////////////

/datum/food_processor_process/mob/process_food(loc, what, processor)
	..()

//////////////////////
/////MOB RECIPIES/////
//////////////////////
/datum/food_processor_process/mob/slime
	input = /mob/living/simple_animal/slime
	output = null

/datum/food_processor_process/mob/slime/process_food(loc, what, obj/machinery/processor/processor)
	var/mob/living/simple_animal/slime/S = what
	var/C = S.cores
	if(S.stat != DEAD)
		S.forceMove(processor.drop_location())
		S.visible_message("<span class='notice'>[S] crawls free of the processor!</span>")
		return
	for(var/i in 1 to (C+processor.rating_amount-1))
		new S.coretype(processor.drop_location())
		SSblackbox.record_feedback("tally", "slime_core_harvested", 1, S.colour)
	..()

/datum/food_processor_process/mob/monkey
	input = /mob/living/carbon/human/lesser/monkey
	output = null

/datum/food_processor_process/mob/monkey/process_food(loc, what, processor)
	var/mob/living/carbon/human/lesser/monkey/O = what
	if(O.client) //grief-proof
		O.forceMove(loc)
		O.visible_message("<span class='notice'>Suddenly [O] jumps out from the processor!</span>", \
				"<span class='notice'>You jump out of \the [src].</span>", \
				"<span class='notice'>You hear a chimp.</span>")
		return
	var/obj/item/reagent_containers/glass/bucket/bucket_of_blood = new(loc)
	var/datum/reagent/blood/B = new()
	B.holder = bucket_of_blood
	B.volume = 70
	//set reagent data
	B.data["donor"] = O.name
	B.data["blood_DNA"] = copytext(O.dna.unique_enzymes,1,0)
	bucket_of_blood.reagents.reagent_list += B
	bucket_of_blood.reagents.update_total()
	bucket_of_blood.on_reagent_change()
	//bucket_of_blood.reagents.handle_reactions() //blood doesn't react
	..()
////////////////////////
////END MOB RECIPIES////
////////////////////////

//END RECIPE DATUMS

/obj/machinery/processor/proc/select_recipe(X)
	for(var/Type in subtypesof(/datum/food_processor_process) - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if(!istype(X, P.input))
			continue
		return P
	return 0


/obj/machinery/processor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(processing)
		to_chat(user, span_warning("The [name] is working."))
		return ATTACK_CHAIN_PROCEED

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	add_fingerprint(user)
	var/datum/food_processor_process/recipe = select_recipe(I)
	if(!recipe)
		to_chat(user, span_warning("The [I.name] probably won't blend."))
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()

	user.visible_message(
		span_notice("[user] puts [I.name] into [src]."),
		span_notice("You have put [I] into [src]."),
	)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/machinery/processor/screwdriver_act(mob/living/user, obj/item/I)
	if(processing)
		to_chat(user, span_warning("The [name] is working."))
		return TRUE
	return default_deconstruction_screwdriver(user, "processor_open", "processor", I)


/obj/machinery/processor/wrench_act(mob/living/user, obj/item/I)
	if(processing)
		to_chat(user, span_warning("The [name] is working."))
		return TRUE
	return default_unfasten_wrench(user, I)


/obj/machinery/processor/crowbar_act(mob/living/user, obj/item/I)
	if(processing)
		to_chat(user, span_warning("The [name] is working."))
		return TRUE
	return default_deconstruction_crowbar(user, I)


/obj/machinery/processor/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE)
		return .
	if(processing)
		to_chat(grabber, span_warning("[src] is already processing something!"))
		return .
	var/datum/food_processor_process/recipe = select_recipe(grabbed_thing)
	if(!recipe)
		to_chat(grabber, span_warning("That probably won't blend."))
		return .
	add_fingerprint(grabber)
	grabbed_thing.forceMove(src)
	grabber.visible_message(
		span_notice("[grabber] puts [grabbed_thing.name] into [src]."),
		span_notice("You put [grabbed_thing.name] into [src]."),
	)


/obj/machinery/processor/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN)) //no power or broken
		return

	if(processing)
		to_chat(user, "<span class='warning'>\the [src] is already processing something!</span>")
		return 1

	if(contents.len == 0)
		to_chat(user, "<span class='warning'>\the [src] is empty.</span>")
		return 1
	processing = 1
	user.visible_message("[user] turns on [src].", \
		"<span class='notice'>You turn on [src].</span>", \
		"<span class='italics'>You hear a food processor.</span>")
	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/total_time = 0
	for(var/O in contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if(!P)
			log_debug("The [O] in processor([src]) does not have a suitable recipe, but it was somehow put inside of the processor anyways.")
			continue
		total_time += P.time
	sleep(total_time / rating_speed)

	for(var/O in contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if(!P)
			log_debug("The [O] in processor([src]) does not have a suitable recipe, but it was somehow put inside of the processor anyways.")
			continue
		P.process_food(loc, O, src)
	processing = 0

	visible_message("<span class='notice'>\the [src] has finished processing.</span>", \
		"<span class='notice'>\the [src] has finished processing.</span>", \
		"<span class='notice'>You hear a food processor stopping.</span>")
