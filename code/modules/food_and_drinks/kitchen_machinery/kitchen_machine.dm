#define NO_DIRT 0
#define MAX_DIRT 100

#define BROKEN_NONE 0
#define BROKEN_NEEDS_WRENCH 1
#define BROKEN_NEEDS_SCREWDRIVER 2

/obj/machinery/kitchen_machine
	name = "Base Kitchen Machine"
	desc = "If you are seeing this, a coder/mapper messed up. Please report it."
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	container_type = OPENCONTAINER
	var/operating = FALSE // Is it on?
	var/dirty = NO_DIRT // = {0..100} Does it need cleaning?
	var/broken = BROKEN_NONE //  How broken is it???
	var/efficiency = 0
	var/list/cook_verbs = list("Cooking")
	//Recipe & Item vars
	var/recipe_type		//Make sure to set this on the machine definition, or else you're gonna runtime on New()
	var/max_n_of_items = 25
	//Icon states
	var/off_icon
	var/on_icon
	var/broken_icon
	var/dirty_icon
	var/open_icon

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/New()
	..()
	create_reagents(100)
	reagents.set_reacting(FALSE)
	init_lists()

/obj/machinery/kitchen_machine/proc/init_lists()
	if(!GLOB.cooking_recipes[recipe_type])
		GLOB.cooking_recipes[recipe_type] = list()
		GLOB.cooking_ingredients[recipe_type] = list()
		GLOB.cooking_reagents[recipe_type] = list()
	if(!length(GLOB.cooking_recipes[recipe_type]))
		for(var/type in subtypesof(GLOB.cooking_recipe_types[recipe_type]))
			var/datum/recipe/recipe = new type
			if(recipe in GLOB.cooking_recipes[recipe_type])
				qdel(recipe)
				continue
			if(recipe.result) // Ignore recipe subtypes that lack a result
				GLOB.cooking_recipes[recipe_type] += recipe
				for(var/item in recipe.items)
					GLOB.cooking_ingredients[recipe_type] |= item
				for(var/reagent in recipe.reagents)
					GLOB.cooking_reagents[recipe_type] |= reagent
			else
				qdel(recipe)
		GLOB.cooking_ingredients[recipe_type] |= /obj/item/reagent_containers/food/snacks/grown

/*******************
*   Item Adding
********************/

/obj/machinery/kitchen_machine/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		if(istype(I, /obj/item/reagent_containers))
			return ..() | ATTACK_CHAIN_NO_AFTERATTACK
		return ..()

	add_fingerprint(user)
	if(operating)
		to_chat(user, span_warning("The [name] is working."))
		return ATTACK_CHAIN_PROCEED

	if(broken == BROKEN_NONE && dirty != MAX_DIRT && exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	// The machine is all dirty so can't be used!
	if(dirty == MAX_DIRT)
		// If they're trying to clean it then let them
		if(istype(I, /obj/item/reagent_containers/spray/cleaner) || istype(I, /obj/item/soap))
			user.visible_message(
				span_notice("[user] starts to clean [src]."),
				span_notice("You start to clean [src]..."),
			)
			if(!do_after(user, 2 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
				return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
			dirty = NO_DIRT // It's clean!
			update_icon(UPDATE_ICON_STATE)
			if(broken == BROKEN_NONE)
				container_type = OPENCONTAINER
			user.visible_message(
				span_notice("[user] has cleaned [src]."),
				span_notice("You have cleaned [src]."),
			)
			return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

		//Otherwise bad luck!!
		to_chat(user, span_warning("It's dirty!"))
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

	if(is_type_in_list(I, GLOB.cooking_ingredients[recipe_type]) || istype(I, /obj/item/mixing_bowl))
		if(length(contents) >= max_n_of_items)
			to_chat(user, span_warning("The [name] is full of ingredients, you cannot put more."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		var/obj/item/stack/stack = I
		if(!isstack(I) || stack.get_amount() <= 1)
			if(!add_item(I, user))
				return ..()
			updateUsrDialog()
			return ATTACK_CHAIN_BLOCKED_ALL
		var/obj/item/stack/to_add = stack.split_stack(user, 1)
		to_add.forceMove(src)
		updateUsrDialog()
		user.visible_message(
			span_notice("[user] adds one of [stack] to [src]."),
			span_notice("You have added one of [stack] to [src]."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	var/static/list/acceptable_containers = typecacheof(list(
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/food/drinks,
		/obj/item/reagent_containers/food/condiment,
	))
	if(is_type_in_typecache(I, acceptable_containers))
		var/obj/item/reagent_containers/container = I
		if(!container.reagents || !container.reagents.total_volume)
			to_chat(user, span_warning("The [container.name] is empty."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		for(var/datum/reagent/reagent as anything in container.reagents.reagent_list)
			if(!(reagent.id in GLOB.cooking_reagents[recipe_type]))
				to_chat(user, span_warning("The [container.name] contains components unsuitable for cookery."))
				return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		container.reagents.trans_to(src, container.amount_per_transfer_from_this)
		user.visible_message(
			span_notice("[user] adds few ingreendients from [container]."),
			span_notice("You have added few ingreendients from [container]."),
		)
		updateUsrDialog()
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	to_chat(user, span_warning("You have no idea how to cook with [I]."))
	return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK


/obj/machinery/kitchen_machine/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(operating)
		to_chat(user, span_warning("The [name] is working."))
		return .
	if(broken == BROKEN_NONE)
		if(dirty == MAX_DIRT)
			to_chat(user, span_warning("The [name] is too dirty."))
			return .
		return default_deconstruction_screwdriver(user, open_icon, off_icon, I)
	if(broken != BROKEN_NEEDS_SCREWDRIVER)
		return FALSE
	user.visible_message(
		span_notice("[user] starts to fix the internal parts of [src]."),
		span_notice("You start to fix the internal parts of [src]..."),
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || operating || broken != BROKEN_NEEDS_SCREWDRIVER)
		return .
	broken = BROKEN_NEEDS_WRENCH // Fix it a bit
	update_icon(UPDATE_ICON_STATE)
	user.visible_message(
		span_notice("[user] fixes the internal parts of [src]."),
		span_notice("You have fixed the internal parts of [src]."),
	)


/obj/machinery/kitchen_machine/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(operating)
		to_chat(user, span_warning("The [name] is working."))
		return .
	if(broken == BROKEN_NONE)
		return default_unfasten_wrench(user, I)
	if(broken != BROKEN_NEEDS_WRENCH)
		return FALSE
	user.visible_message(
		span_notice("[user] starts to fix external parts of [src]."),
		span_notice("You start to fix external parts of [src]..."),
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || operating || broken != BROKEN_NEEDS_WRENCH)
		return .
	broken = BROKEN_NONE // Fix it!
	if(dirty != MAX_DIRT)
		container_type = OPENCONTAINER
	update_icon(UPDATE_ICON_STATE)
	user.visible_message(
		span_notice("[user] fixes the external parts of [src]."),
		span_notice("You have fixed the external parts of [src]."),
	)


/obj/machinery/kitchen_machine/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(operating)
		to_chat(user, span_warning("The [name] is working."))
		return .
	return default_deconstruction_crowbar(user, I)


/obj/machinery/kitchen_machine/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE)
		return .
	special_grab_attack(grabbed_thing, grabber)


/obj/machinery/kitchen_machine/proc/special_grab_attack(atom/movable/grabbed_thing, mob/living/grabber)
	to_chat(grabber, span_warning("This is ridiculous. You can not fit [grabbed_thing] in [src]."))


/obj/machinery/kitchen_machine/proc/add_item(obj/item/I, mob/user)
	if(I.loc == user)
		if(!user.drop_transfer_item_to_loc(I, src))
			return FALSE
	else
		I.forceMove(src)
	. = TRUE
	user.visible_message(
		span_notice("[user] adds [I] to [src]."),
		span_notice("You add [I] to [src]."),
	)


/obj/machinery/kitchen_machine/attack_ai(mob/user)
	return 0

/obj/machinery/kitchen_machine/attack_hand(mob/user)
	add_fingerprint(user)
	user.set_machine(src)
	interact(user)


/obj/machinery/kitchen_machine/on_deconstruction()
	dropContents()

/********************
*   Machine Menu	*
********************/

/obj/machinery/kitchen_machine/interact(mob/user) // The microwave Menu
	if(panel_open || !anchored)
		return
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	if(broken)
		dat = {"<code>Bzzzzttttt</code>"}
	else if(operating)
		dat = {"<code>[pick(cook_verbs)] in progress!<BR>Please wait...!</code>"}
	else if(dirty==100)
		dat = {"<code>This [name] is dirty!<BR>Please clean it before use!</code>"}
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for(var/obj/O in contents)
			var/display_name = O.name
			if(istype(O,/obj/item/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if(istype(O,/obj/item/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if(istype(O,/obj/item/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if(istype(O,/obj/item/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if(istype(O,/obj/item/reagent_containers/food/snacks/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for(var/O in items_counts)
			var/N = items_counts[O]
			if(!(O in items_measures))
				dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
			else
				if(N==1)
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
				else
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

		for(var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if(R.id == "capsaicin")
				display_name = "Hotsauce"
			if(R.id == "frostoil")
				display_name = "Coldsauce"
			dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}

		if(items_counts.len==0 && reagents.reagent_list.len==0)
			dat = {"<B>The [src] is empty</B><BR>"}
		else
			dat = {"<b>Ingredients:</b><br>[dat]"}
		dat += {"<HR><BR>\
<a href='byond://?src=[UID()];action=cook'>Turn on!</A><BR>\
<a href='byond://?src=[UID()];action=dispose'>Eject ingredients!</A><BR>\
"}

	var/datum/browser/popup = new(user, name, name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "[name]")
	return



/************************************
*   Machine Menu Handling/Cooking	*
************************************/

/obj/machinery/kitchen_machine/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if(reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if(!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/list/recipes_to_make = choose_recipes()

	if(recipes_to_make.len == 1 && recipes_to_make[1][2] == RECIPE_FAIL)
		//This only runs if there is a single recipe source to be made and it is a failure (the machine was loaded with only 1 mixing bowl that results in failure OR was directly loaded with ingredients that results in failure).
		//If there are multiple sources, this bit gets skipped.
		dirty += 1
		if(prob(max(10,dirty*5)))	//chance to get so dirty we require cleaning before next use
			if(!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			fail()
			return
		else if(has_extra_item())	//if extra items present, break down and require repair before next use
			if(!wzhzhzh(4))
				abort()
				return
			broke()
			fail()
			return
		else	//otherwise just stop without requiring cleaning/repair
			if(!wzhzhzh(10))
				abort()
				return
			stop()
			fail()
			return
	else
		if(!wzhzhzh(5))
			abort()
			return
		if(!wzhzhzh(5))
			abort()
			fail()
			return
		make_recipes(recipes_to_make)

//choose_recipes(): picks out recipes for the machine and any mixing bowls it may contain.
	//builds a list of the selected recipes to be made in a later proc by associating the "source" of the ingredients (mixing bowl, machine) with the recipe for that source
/obj/machinery/kitchen_machine/proc/choose_recipes()
	var/list/recipes_to_make = list()
	for(var/obj/item/mixing_bowl/mb in contents)	//if we have mixing bowls present, check each one for possible recipes from its respective contents. Mixing bowls act like a wrapper for recipes and ingredients, isolating them from other ingredients and mixing bowls within a machine.
		var/datum/recipe/recipe = select_recipe(GLOB.cooking_recipes[recipe_type], mb)
		if(recipe)
			recipes_to_make.Add(list(list(mb, recipe)))
		else	//if the ingredients of the mixing bowl don't make a valid recipe, we return a fail recipe to generate the burned mess
			recipes_to_make.Add(list(list(mb, RECIPE_FAIL)))

	var/datum/recipe/recipe_src = select_recipe(GLOB.cooking_recipes[recipe_type], src, ignored_items = list(/obj/item/mixing_bowl))	//check the machine's directly-inserted ingredients for possible recipes as well, ignoring the mixing bowls when selecting recipe
	if(recipe_src)	//if we found a valid recipe for directly-inserted ingredients, add that to our list
		recipes_to_make.Add(list(list(src, recipe_src)))
	else if(!recipes_to_make.len)	//if the machine has no mixing bowls to make recipes from AND also doesn't have a valid recipe of directly-inserted ingredients, return a failure so we can make a burned mess
		recipes_to_make.Add(list(list(src, RECIPE_FAIL)))
	return recipes_to_make

//make_recipes(recipes_to_make): cycles through the supplied list of recipes and creates each recipe associated with the "source" for that entry
/obj/machinery/kitchen_machine/proc/make_recipes(list/recipes_to_make)
	if(!recipes_to_make)
		return
	var/datum/reagents/temp_reagents = new(500)
	for(var/i=1 to recipes_to_make.len)		//cycle through each entry on the recipes_to_make list for processing
		var/list/L = recipes_to_make[i]
		var/obj/source = L[1]	//this is the source of the recipe entry (mixing bowl or the machine)
		var/datum/recipe/recipe = L[2]	//this is the recipe associated with the source (a valid recipe or null)
		if(recipe == RECIPE_FAIL)		//we have a failure and create a burned mess
			//failed recipe
			fail()
		else	//we have a valid recipe to begin making
			for(var/obj/O in source.contents)	//begin processing the ingredients supplied
				if(istype(O, /obj/item/mixing_bowl))	//ignore mixing bowls present among the ingredients in our source (only really applies to machine sourced recipes)
					continue
				if(O.reagents)
					O.reagents.del_reagent("nutriment")
					O.reagents.update_total()
					O.reagents.trans_to(temp_reagents, O.reagents.total_volume, no_react = TRUE) // Don't react with the abstract holder please
				qdel(O)
			source.reagents.clear_reagents()
			for(var/e=1 to efficiency)		//upgraded machine? make additional servings and split the ingredient reagents among each serving equally.
				var/obj/cooked = new recipe.result()
				temp_reagents.trans_to(cooked, temp_reagents.total_volume/efficiency, no_react = TRUE) // Don't react with the abstract holder please
				cooked.forceMove(loc)
			temp_reagents.clear_reagents()
			var/obj/byproduct = recipe.get_byproduct()	//if the recipe has a byproduct, handle returning that (such as re-usable candy moulds)
			if(byproduct)
				new byproduct(loc)
			if(istype(source, /obj/item/mixing_bowl))	//if the recipe's source was a mixing bowl, make it a little dirtier and return that for re-use.
				var/obj/item/mixing_bowl/mb = source
				mb.make_dirty(5 * efficiency)
				mb.forceMove(loc)
	stop()
	return

/obj/machinery/kitchen_machine/proc/wzhzhzh(seconds)
	for(var/i=1 to seconds)
		if(stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(10)
	return 1

/obj/machinery/kitchen_machine/proc/has_extra_item()
	for(var/obj/O in contents)
		if(!is_type_in_list(O, list(/obj/item/reagent_containers/food, /obj/item/grown, /obj/item/mixing_bowl)))
			return 1
	return 0

/obj/machinery/kitchen_machine/proc/start()
	visible_message("<span class='notice'>\The [src] turns on.</span>", "<span class='notice'>You hear \a [src].</span>")
	operating = TRUE
	update_icon(UPDATE_ICON_STATE)
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/abort()
	operating = FALSE // Turn it off again aferwards
	update_icon(UPDATE_ICON_STATE)
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/stop()
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	operating = FALSE // Turn it off again aferwards
	update_icon(UPDATE_ICON_STATE)
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/dispose()
	for(var/obj/O in contents)
		O.forceMove(loc)
	if(reagents.total_volume)
		dirty++
	reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of \the [src]'s contents.</span>")
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/muck_start()
	playsound(loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound

/obj/machinery/kitchen_machine/proc/muck_finish()
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	visible_message("<span class='alert'>\The [src] gets covered in muck!</span>")
	dirty = MAX_DIRT // Make it dirty so it can't be used util cleaned
	container_type = NONE
	operating = FALSE // Turn it off again afterwards
	update_icon(UPDATE_ICON_STATE)
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/broke()
	do_sparks(2, 1, src)
	visible_message("<span class='alert'>The [src] breaks!</span>") //Let them know they're stupid
	broken = BROKEN_NEEDS_SCREWDRIVER // Make it broken so it can't be used util fixed
	container_type = NONE
	operating = FALSE // Turn it off again aferwards
	update_icon(UPDATE_ICON_STATE)
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/fail()
	var/amount = 0
	for(var/obj/item/mixing_bowl/mb in contents)	//fail and remove any mixing bowls present before making the burned mess from the machine itself (to avoid them being destroyed as part of the failure)
		mb.fail(src)
		mb.forceMove(get_turf(src))
	for(var/obj/O in contents)
		amount++
		if(O.reagents)	//this is reagents in inserted objects (like chems in produce)
			var/id = O.reagents.get_master_reagent_id()
			if(id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	if(reagents && reagents.total_volume)	//this is directly-added reagents (like water added directly into the machine)
		var/id = reagents.get_master_reagent_id()
		if(id)
			amount += reagents.get_reagent_amount(id)
	reagents.clear_reagents()
	if(amount)
		var/obj/item/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
		ffuu.reagents.add_reagent("carbon", amount)
		ffuu.reagents.add_reagent("????", amount/10)
		ffuu.forceMove(get_turf(src))

/obj/machinery/kitchen_machine/Topic(href, href_list)
	if(..() || panel_open)
		return

	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return

	switch(href_list["action"])
		if("cook")
			cook()

		if("dispose")
			dispose()
	return


/obj/machinery/kitchen_machine/update_icon_state()
	if(broken)
		icon_state = broken_icon
		return
	if(dirty == MAX_DIRT)
		icon_state = dirty_icon
		return
	icon_state = operating ? on_icon : off_icon


#undef NO_DIRT
#undef MAX_DIRT
#undef BROKEN_NONE
#undef BROKEN_NEEDS_WRENCH
#undef BROKEN_NEEDS_SCREWDRIVER

