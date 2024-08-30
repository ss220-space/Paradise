
/obj/item/mixing_bowl
	name = "mixing bowl"
	desc = "Mixing it up in the kitchen."
	flags = OPENCONTAINER
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mixing_bowl"
	var/max_n_of_items = 25
	var/dirty = FALSE
	var/clean_icon = "mixing_bowl"
	var/dirty_icon = "mixing_bowl_dirty"
	var/is_GUI_opened = FALSE


/obj/item/mixing_bowl/Initialize(mapload)
	. = ..()
	create_reagents(100)


/obj/item/mixing_bowl/attackby(obj/item/stack/I, mob/user, params)
	if(istype(I, /obj/item/soap))
		add_fingerprint(user)
		if(!dirty)
			to_chat(user, span_warning("The [name] is not dirty!"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] starts to scrub [src]."),
			span_notice("You start to scrub [src]."),
		)
		if(!do_after(user, 2 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || !dirty)
			return ATTACK_CHAIN_PROCEED
		clean()
		user.visible_message(
			span_notice("[user] has scrubbed [src] clean."),
			span_notice("You have scrubbed [src] clean."),
		)
		update_dialog(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_type_in_list(I, GLOB.cooking_ingredients[RECIPE_MICROWAVE]) || is_type_in_list(I, GLOB.cooking_ingredients[RECIPE_GRILL]) || is_type_in_list(I, GLOB.cooking_ingredients[RECIPE_OVEN]) || is_type_in_list(I, GLOB.cooking_ingredients[RECIPE_CANDY]))
		add_fingerprint(user)
		if(dirty)
			to_chat(user, span_warning("You should clean [src] before you use it for food prep."))
			return ATTACK_CHAIN_PROCEED
		if(length(contents) >= max_n_of_items)
			to_chat(user, span_warning("This [name] is full of ingredients, you cannot put more."))
			return ATTACK_CHAIN_PROCEED
		if(isstack(I) && I.get_amount() > 1)
			var/obj/item/stack/to_add = I.split_stack(user, 1)
			to_add.forceMove(src)
			user.visible_message(
				span_notice("[user] adds one of [I] to [src]."),
				span_notice("You add one of [I] to [src]."),
			)
			update_dialog(user)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		user.visible_message(
			span_notice("[user] adds [I] to [src]."),
			span_notice("You add [I] to [src]."),
		)
		update_dialog(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	var/static/list/containers = list(
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/food/drinks,
		/obj/item/reagent_containers/food/condiment,
	)
	if(is_type_in_list(I, containers))
		add_fingerprint(user)
		if(dirty)
			to_chat(user, span_warning("You should clean [src] before you use it for food prep."))
			return ATTACK_CHAIN_PROCEED
		if(!I.reagents)
			to_chat(user, span_warning("The [I.name] is empty!"))
			return ATTACK_CHAIN_PROCEED
		for(var/datum/reagent/reagent as anything in I.reagents.reagent_list)
			if(!(reagent.id in GLOB.cooking_reagents[RECIPE_MICROWAVE]) && !(reagent.id in GLOB.cooking_reagents[RECIPE_GRILL]) && !(reagent.id in GLOB.cooking_reagents[RECIPE_OVEN]) && !(reagent.id in GLOB.cooking_reagents[RECIPE_CANDY]))
				to_chat(user, span_warning("Your [I.name] contains components unsuitable for cookery."))
				return ATTACK_CHAIN_PROCEED
		var/obj/item/reagent_containers/container = I
		var/cached_name = "[container]"
		var/transfered_amount = container.reagents.trans_to(src, container.amount_per_transfer_from_this)
		user.visible_message(
			span_notice("[user] transfer some solution from [cached_name] to [src]."),
			span_notice("You transfer [transfered_amount] units of the solution to [src]."),
		)
		update_dialog(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	to_chat(user, span_warning("You have no idea what you can cook with [I]."))
	return ..()


/obj/item/mixing_bowl/attack_self(mob/user)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	if(dirty)
		dat = {"<code>This [src] is dirty!<BR>Please clean it before use!</code>"}
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
		dat += {"<HR><BR> <a href='byond://?src=[UID()];action=dispose'>Eject ingredients!</A><BR>"}

	var/datum/browser/popup = new(user, "[name][UID()]", "[name]", 400, 400, src)
	popup.set_content(dat)
	popup.open()
	is_GUI_opened = TRUE
	return

/obj/item/mixing_bowl/Topic(href, href_list)
	if(..())
		return
	if(href_list["action"] == "dispose")
		dispose()
	if(href_list["close"] == "1")
		is_GUI_opened = FALSE
	return

/obj/item/mixing_bowl/proc/dispose()
	for(var/obj/O in contents)
		O.forceMove(usr.loc)
	if(reagents.total_volume)
		make_dirty(5)
	reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of [src]'s contents.</span>")
	update_dialog(usr)

/obj/item/mixing_bowl/proc/update_dialog(mob/user)
	if(is_GUI_opened)
		src.attack_self(user)

/obj/item/mixing_bowl/proc/make_dirty(chance)
	if(!chance)
		return
	if(prob(chance))
		dirty = TRUE
		flags = null
		update_icon(UPDATE_ICON_STATE)

/obj/item/mixing_bowl/proc/clean()
	dirty = FALSE
	flags = OPENCONTAINER
	update_icon(UPDATE_ICON_STATE)

/obj/item/mixing_bowl/wash(mob/user, atom/source)
	if(..())
		clean()
		update_dialog(user)

/obj/item/mixing_bowl/proc/fail(obj/source)
	if(!source)
		source = src
	var/amount = 0
	for(var/obj/O in contents)
		amount++
		if(O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if(id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	if(reagents && reagents.total_volume)
		var/id = reagents.get_master_reagent_id()
		if(id)
			amount += reagents.get_reagent_amount(id)
	reagents.clear_reagents()
	var/obj/item/reagent_containers/food/snacks/badrecipe/ffuu = new(get_turf(source))
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("????", amount/10)
	make_dirty(75)


/obj/item/mixing_bowl/update_icon_state()
	icon_state = dirty ? dirty_icon : clean_icon

