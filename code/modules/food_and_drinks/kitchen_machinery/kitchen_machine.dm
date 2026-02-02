#define NO_DIRT 0
#define MAX_DIRT 100

#define BROKEN_NONE 0
#define BROKEN_NEEDS_WRENCH 1
#define BROKEN_NEEDS_SCREWDRIVER 2

/obj/machinery/kitchen_machine
	name = "Base Kitchen Machine"
	desc = "If you are seeing this, a coder/mapper messed up. Please report it."
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5
	active_power_usage = 100
	container_type = OPENCONTAINER
	/// Is it on?
	var/operating = FALSE
	/// = {0..100} Does it need cleaning?
	var/dirty = NO_DIRT
	/// Can our machine be dirty?
	var/can_be_dirty = TRUE
	/// How broken is it???
	var/broken = BROKEN_NONE
	/// Can our machine be broken?
	var/can_broke = TRUE
	var/transfer_reagents_from_ingredients = TRUE
	var/efficiency = 0
	var/list/cook_verbs = list("Готовится")
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

/obj/machinery/kitchen_machine/Initialize(mapload)
	. = ..()
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
		balloon_alert(user, "работает!")
		return ATTACK_CHAIN_PROCEED

	if(broken == BROKEN_NONE && dirty != MAX_DIRT && exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	// The machine is all dirty so can't be used!
	if(dirty == MAX_DIRT)
		// If they're trying to clean it then let them
		if(istype(I, /obj/item/reagent_containers/spray/cleaner) || istype(I, /obj/item/soap))
			user.visible_message(
				span_notice("[user] начина[PLUR_ET_YUT(user)] чистить [declent_ru(ACCUSATIVE)]."),
				span_notice("Вы начинаете чистить [declent_ru(ACCUSATIVE)]..."),
			)
			if(!do_after(user, 2 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
				return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
			dirty = NO_DIRT // It's clean!
			update_icon(UPDATE_ICON_STATE)
			if(broken == BROKEN_NONE)
				container_type = OPENCONTAINER
			user.visible_message(
				span_notice("[user] заканчива[PLUR_ET_YUT(user)] чистить [declent_ru(ACCUSATIVE)]."),
				span_notice("Вы заканчиваете чистить [declent_ru(ACCUSATIVE)]."),
			)
			return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

		//Otherwise bad luck!!
		balloon_alert(user, "нужно почистить!")
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

	if(is_type_in_list(I, GLOB.cooking_ingredients[recipe_type]) || istype(I, /obj/item/mixing_bowl))
		if(length(contents) >= max_n_of_items)
			balloon_alert(user, "нет места!")
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		var/obj/item/stack/stack = I
		if(!isstack(I) || stack.get_amount() <= 1)
			if(!add_item(I, user))
				return ..()
			SStgui.update_uis(src)
			return ATTACK_CHAIN_BLOCKED_ALL
		var/obj/item/stack/to_add = stack.split(user, 1)
		to_add.forceMove(src)
		SStgui.update_uis(src)
		user.visible_message(
			span_notice("[user] добавля[PLUR_ET_YUT(user)] [stack.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы добавили один [stack.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."),
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
			balloon_alert(user, "ёмкость пуста!")
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		for(var/datum/reagent/reagent as anything in container.reagents.reagent_list)
			if(!(reagent.id in GLOB.cooking_reagents[recipe_type]))
				balloon_alert(user, "содержит непригодные вещества!")
				return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		container.reagents.trans_to(src, container.amount_per_transfer_from_this)
		user.visible_message(
			span_notice("[user] добавля[PLUR_ET_YUT(user)] несколько ингредиентов из [container.declent_ru(GENITIVE)]."),
			span_notice("Вы добавляете несколько ингредиентов из [container.declent_ru(GENITIVE)]."),
		)
		SStgui.update_uis(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	to_chat(user, span_warning("Вы не представляете, как готовить [I.declent_ru(GENITIVE)]..."))
	return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

/obj/machinery/kitchen_machine/examine(mob/user)
	. = ..()
	if(in_range(src, user))
		. += span_notice("\nИспользуйте <b>Alt+ЛКМ</b> для активации.<br/><b>Ctrl+Shift+ЛКМ</b> для удаления содержимого.")

/obj/machinery/kitchen_machine/click_alt(mob/living/carbon/human/human)
	if(operating)
		return NONE

	add_fingerprint(human)
	cook()
	return CLICK_ACTION_SUCCESS

/obj/machinery/kitchen_machine/CtrlShiftClick(mob/living/carbon/human/human)
	if(!istype(human) || !human.Adjacent(src))
		return

	if(human.incapacitated() || HAS_TRAIT(human, TRAIT_HANDS_BLOCKED))
		return

	if(operating)
		return

	add_fingerprint(human)
	dispose(human)

/obj/machinery/kitchen_machine/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(operating)
		balloon_alert(user, "работает!")
		return .
	if(broken == BROKEN_NONE)
		if(dirty == MAX_DIRT)
			balloon_alert(user, "нужно почистить!")
			return .
		return default_deconstruction_screwdriver(user, open_icon, off_icon, I)
	if(broken != BROKEN_NEEDS_SCREWDRIVER)
		return FALSE
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] чинить [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете чинить [declent_ru(ACCUSATIVE)]..."),
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || operating || broken != BROKEN_NEEDS_SCREWDRIVER)
		return .
	if(can_broke)
		broken = BROKEN_NEEDS_WRENCH // Fix it a bit
	update_icon(UPDATE_ICON_STATE)
	user.visible_message(
		span_notice("[user] заканчива[PLUR_ET_YUT(user)] чинить [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы заканчиваете чинить [declent_ru(ACCUSATIVE)]."),
	)

/obj/machinery/kitchen_machine/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(operating)
		balloon_alert(user, "работает!")
		return .
	if(broken == BROKEN_NONE)
		return default_unfasten_wrench(user, I)
	if(broken != BROKEN_NEEDS_WRENCH)
		return FALSE
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] чинить [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете чинить [declent_ru(ACCUSATIVE)]..."),
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || operating || broken != BROKEN_NEEDS_WRENCH)
		return .
	broken = BROKEN_NONE // Fix it!
	if(dirty != MAX_DIRT)
		container_type = OPENCONTAINER
	update_icon(UPDATE_ICON_STATE)
	user.visible_message(
		span_notice("[user] заканчива[PLUR_ET_YUT(user)] чинить [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы заканчиваете чинить [declent_ru(ACCUSATIVE)]."),
	)

/obj/machinery/kitchen_machine/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(operating)
		balloon_alert(user, "работает!")
		return .
	return default_deconstruction_crowbar(user, I)

/obj/machinery/kitchen_machine/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE)
		return .
	special_grab_attack(grabbed_thing, grabber)

/obj/machinery/kitchen_machine/proc/special_grab_attack(atom/movable/grabbed_thing, mob/living/grabber)
	to_chat(grabber, span_warning("Вы не можете просто взять и поместить [grabbed_thing.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))

/obj/machinery/kitchen_machine/proc/add_item(obj/item/I, mob/user)
	if(I.loc == user)
		if(!user.drop_transfer_item_to_loc(I, src))
			return FALSE
	else
		I.forceMove(src)
	. = TRUE
	user.visible_message(
		span_notice("[user] добавля[PLUR_ET_YUT(user)] [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы добавляете [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."),
	)

/obj/machinery/kitchen_machine/attack_ai(mob/user)
	return 0

/obj/machinery/kitchen_machine/attack_hand(mob/user)
	add_fingerprint(user)
	user.set_machine(src)
	ui_interact(user)

/obj/machinery/kitchen_machine/on_deconstruction()
	dropContents()

/********************
*   Machine Menu	*
********************/

/obj/machinery/kitchen_machine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KitchenMachine", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/machinery/kitchen_machine/ui_data(mob/user)
	var/list/data = list()
	data["name"] = DECLENT_RU_CAP(src, NOMINATIVE)
	data["operating"] = operating
	data["dirty"] = dirty
	data["broken"] = broken
	data["cookVerb"] = pick(cook_verbs)

	var/list/items_counts = new

	for(var/obj/O in contents)
		var/display_name = DECLENT_RU_CAP(O, NOMINATIVE)
		items_counts[display_name]++

	data["ingredients"] += list()
	for(var/item_name in items_counts)
		var/count = items_counts[item_name]

		data["ingredients"] += list(list(
			"name" = item_name,
			"amount" = count,
		))

	data["reagents"] = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		var/display_name = R.name
		if(R.id == "capsaicin")
			display_name = "Hotsauce"
		else if(R.id == "frostoil")
			display_name = "Coldsauce"

		data["reagents"] += list(list(
			"name" = display_name,
			"volume" = R.volume,
		))

	return data

/obj/machinery/kitchen_machine/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("start")
			cook()
			return TRUE
		if("eject")
			dispose(usr)
			return TRUE

/************************************
*   Machine Menu Handling/Cooking	*
************************************/

/obj/machinery/kitchen_machine/proc/cook()
	if(use_power != NO_POWER_USE && stat & (NOPOWER|BROKEN))
		return
	start()
	if(reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if(!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/list/recipes_to_make = choose_recipes()

	if(length(recipes_to_make) == 1 && recipes_to_make[1][2] == RECIPE_FAIL)
		//This only runs if there is a single recipe source to be made and it is a failure (the machine was loaded with only 1 mixing bowl that results in failure OR was directly loaded with ingredients that results in failure).
		//If there are multiple sources, this bit gets skipped.
		if(can_be_dirty)
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
	else if(!length(recipes_to_make))	//if the machine has no mixing bowls to make recipes from AND also doesn't have a valid recipe of directly-inserted ingredients, return a failure so we can make a burned mess
		recipes_to_make.Add(list(list(src, RECIPE_FAIL)))
	return recipes_to_make

//make_recipes(recipes_to_make): cycles through the supplied list of recipes and creates each recipe associated with the "source" for that entry
/obj/machinery/kitchen_machine/proc/make_recipes(list/recipes_to_make)
	if(!recipes_to_make)
		return
	var/datum/reagents/temp_reagents = new(500)
	for(var/i=1 to length(recipes_to_make))		//cycle through each entry on the recipes_to_make list for processing
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
				if(transfer_reagents_from_ingredients)
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
		if(use_power == NO_POWER_USE)
			sleep(10)
			continue
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
	visible_message(
		span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] включается."),
		span_notice("Вы слышите [declent_ru(ACCUSATIVE)].")
	)
	operating = TRUE
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/machinery/kitchen_machine/proc/abort()
	operating = FALSE // Turn it off again aferwards
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/machinery/kitchen_machine/proc/stop()
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	operating = FALSE // Turn it off again aferwards
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/machinery/kitchen_machine/proc/dispose(mob/user)
	for(var/obj/O in contents)
		O.forceMove(loc)

	if(reagents.total_volume && can_be_dirty)
		dirty++

	reagents.clear_reagents()
	to_chat(user, span_notice("Вы удаляете содержимое [declent_ru(GENITIVE)]."))

	SStgui.update_uis(src)

/obj/machinery/kitchen_machine/proc/muck_start()
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE) // Play a splat sound

/obj/machinery/kitchen_machine/proc/muck_finish()
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	visible_message(span_alert("[DECLENT_RU_CAP(src, NOMINATIVE)] покрывается грязью!"))
	if(can_be_dirty) //this vars are much more easy than copy-paste all that code to tribal oven
		dirty = MAX_DIRT // Make it dirty so it can't be used util cleaned
	container_type = NONE
	operating = FALSE // Turn it off again afterwards
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/machinery/kitchen_machine/proc/broke()
	do_sparks(2, TRUE, src)
	visible_message(span_alert("[DECLENT_RU_CAP(src, NOMINATIVE)] ломается!")) //Let them know they're stupid
	if(can_broke)
		broken = BROKEN_NEEDS_SCREWDRIVER // Make it broken so it can't be used util fixed
	container_type = NONE
	operating = FALSE // Turn it off again aferwards
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

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
	if(reagents?.total_volume)	//this is directly-added reagents (like water added directly into the machine)
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
		SStgui.update_uis(src)
		return

	switch(href_list["action"])
		if("cook")
			cook()

		if("dispose")
			dispose(usr)

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

