// MARK: Condiment container
/obj/item/reagent_containers/condiment
	name = "condiment container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "emptycondiment"
	container_type = OPENCONTAINER
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	//Possible_states has the reagent id as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change() to change names, descs and sprites.
	var/list/possible_states = list(
		"ketchup" = list("ketchup", "ketchup bottle", "You feel more American already."),
		"capsaicin" = list("hotsauce", "hotsauce bottle", "You can almost TASTE the stomach ulcers now!"),
		"enzyme" = list("enzyme", "universal enzyme bottle", "Used in cooking various dishes"),
		"soysauce" = list("soysauce", "soy sauce bottle", "A salty soy-based flavoring"),
		"frostoil" = list("coldsauce", "coldsauce bottle", "Leaves the tongue numb in it's passage"),
		"sodiumchloride" = list("saltshakersmall", "salt shaker", "Salt. From space oceans, presumably"),
		"blackpepper" = list("peppermillsmall", "pepper mill", "Often used to flavor food or make people sneeze"),
		"cornoil" = list("oliveoil", "corn oil bottle", "A delicious oil used in cooking. Made from corn"),
		"oliveoil" = list("oliveoil", "olive oil bottle", "A delicious oil used in cooking. Made from olives"),
		"sugar" = list("emptycondiment", "sugar bottle", "Tasty spacey sugar!")
	)
	var/originalname = "condiment" //Can't use initial(name) for this. This stores the name set by condimasters.

/obj/item/reagent_containers/condiment/proc/try_eat(atom/target, mob/living/user)
	if(!can_consume(target, user))
		return ITEM_INTERACT_BLOCKING

	user.changeNext_move(CLICK_CD_MELEE)
	if(target == user)
		user.visible_message(
			span_notice("[user] глота[PLUR_ET_YUT(user)] содержимое [declent_ru(GENITIVE)]."),
			span_notice("Вы глотаете содержимое [declent_ru(GENITIVE)]."),
		)
	else
		target.visible_message(
			span_danger("[user] пыта[PLUR_ET_YUT(user)]ся скормить [target.declent_ru(ACCUSATIVE)] содержимое [declent_ru(GENITIVE)]!"),
			span_userdanger("[user] пыта[PLUR_ET_YUT(user)]ся скормить вам содержимое [declent_ru(GENITIVE)]!"),
		)
		if(!do_after(user, 3 SECONDS, target, DA_IGNORE_USER_LOC_CHANGE))
			return ITEM_INTERACT_BLOCKING
		if(!reagents || !reagents.total_volume)
			return ITEM_INTERACT_BLOCKING // The condiment might be empty after the delay.
		target.visible_message(
			span_danger("[user] скормил[GEND_A_O_I(user)] [target.declent_ru(ACCUSATIVE)] содержимое [declent_ru(GENITIVE)]!"),
			span_userdanger("[user] скормил[GEND_A_O_I(user)] вам содержимое [declent_ru(GENITIVE)]!"),
		)
	reagents.trans_to(target, 5)
	reagents.reaction(target, REAGENT_INGEST)
	playsound(target, 'sound/items/drink.ogg', rand(10, 50), TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/condiment/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()

	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!is_open_container())
		return NONE

	if(target.is_refillable()) //Something like a glass or a food item. Player probably wants to transfer TO it.
		return try_refill(target, user)

	if(isliving(target)) // Eating directly from the ketchup packet
		return try_eat(target, user)

	return NONE

/obj/item/reagent_containers/condiment/interact_with_atom_secondary(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!is_open_container())
		return NONE

	if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		return try_drain(target, user)

	return NONE

/obj/item/reagent_containers/condiment/on_reagent_change()
	if(!length(possible_states))
		return
	if(length(reagents.reagent_list) > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			name = temp_list[2]
			desc = temp_list[3]

		else
			name = "[originalname] bottle"
			main_reagent = reagents.get_master_reagent_name()
			if(reagents.reagent_list.len==1)
				desc = "Looks like it is [lowertext(main_reagent)], but you are not sure."
			else
				desc = "A mixture of various condiments. [lowertext(main_reagent)] is one of them."
			icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "An empty condiment bottle."

// MARK: Container types
/obj/item/reagent_containers/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list("enzyme" = 50)

/obj/item/reagent_containers/condiment/sugar
	name = "sugar bottle"
	desc = "Tasty spacey sugar!"
	list_reagents = list("sugar" = 50)

/obj/item/reagent_containers/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1, 5, 20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("sodiumchloride" = 20)
	possible_states = list()

/obj/item/reagent_containers/condiment/saltshaker/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] begins to swap forms with the salt shaker! It looks like [user.p_theyre()] trying to commit suicide."))
	var/newname = "[name]"
	name = "[user.name]"
	user.name = newname
	user.real_name = newname
	desc = "Salt. From dead crew, presumably."
	return BRUTELOSS

/obj/item/reagent_containers/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1, 5, 20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)
	possible_states = list()

/obj/item/reagent_containers/condiment/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	list_reagents = list("milk" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	item_state = "flour"
	list_reagents = list("flour" = 30)
	possible_states = list()

/obj/item/reagent_containers/condiment/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	list_reagents = list("soymilk" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/rice
	name = "rice sack"
	desc = "A big bag of rice. Good for cooking!"
	icon_state = "rice"
	item_state = "flour"
	list_reagents = list("rice" = 30)
	possible_states = list()

/obj/item/reagent_containers/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	list_reagents = list("soysauce" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/syndisauce
	name = "Chef Excellence's Special Sauce"
	desc = "Этот ароматный соус, приготовленный из мухоморов, просто восхитителен! Смерть никогда не была такой приятной на вкус."
	list_reagents = list("amanitin" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/syndisauce/get_ru_names()
	return alist(
		NOMINATIVE = "элитарный соус шефа",
		GENITIVE = "элитарного соуса шефа",
		DATIVE = "элитарному соусу шефа",
		ACCUSATIVE = "элитарный соус шефа",
		INSTRUMENTAL = "элитарным соусом шефа",
		PREPOSITIONAL = "элитарном соусе шефа",
	)

//Tomato sauce
/obj/item/reagent_containers/condiment/tomatosauce
	name = "tomato sauce"
	desc = "The father of all sauces. Tomatoes, a little spice and nothing extra."
	icon_state = "tomatosauce"
	list_reagents = list("tsauce" = 50)
	possible_states = list()

//Diablo sauce
/obj/item/reagent_containers/condiment/diablosauce
	name = "diablo sauce"
	desc = "An ancient burning sauce, its recipe has hardly changed since its creation."
	icon_state = "diablosauce"
	list_reagents = list("dsauce" = 50)
	possible_states = list()

//Cheese sauce
/obj/item/reagent_containers/condiment/cheesesauce
	name = "cheese sauce"
	desc = "Cheese, cream and milk... maximum protein concentration!"
	icon_state = "cheesesauce"
	list_reagents = list("csauce" = 50)
	possible_states = list()

//Mushroom sauce
/obj/item/reagent_containers/condiment/mushroomsauce
	name = "mushroom sauce"
	desc = "Creamy sauce with mushrooms, has a rather pungent smell."
	icon_state = "mushroomsauce"
	list_reagents = list("msauce" = 50)
	possible_states = list()

//Garlic sauce
/obj/item/reagent_containers/condiment/garlicsauce
	name = "garlic sauce"
	desc = "A strong sauce with garlic, its smell punches the nose. Some crewmembers will probably hiss at you and walk away."
	icon_state = "garlicsauce"
	list_reagents = list("gsauce" = 50)
	possible_states = list()

//Custard
/obj/item/reagent_containers/condiment/custard
	name = "Custard"
	desc = "Soft and sweet cream, used in confectionery."
	icon_state = "custard"
	list_reagents = list("custard" = 50)
	possible_states = list()

//Herbs
/obj/item/reagent_containers/condiment/herbs
	name = "Herbs mix"
	desc = "A mix of variouse herbs. Perfect for pizza!"
	icon_state = "herbs"
	list_reagents = list("herbsmix" = 50)
	possible_states = list()

// MARK: Condiment pack
/obj/item/reagent_containers/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food."
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	possible_states = list(
		"ketchup" = list("condi_ketchup", "Ketchup", "You feel more American already."),
		"capsaicin" = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"),
		"soysauce" = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring"),
		"frostoil" = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in it's passage"),
		"sodiumchloride" = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably"),
		"blackpepper" = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze"),
		"cornoil" = list("condi_cornoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"),
		"oliveoil" = list("condi_oliveoil", "Olive Oil", "A delicious oil used in cooking. Made from olives"),
		"sugar" = list("condi_sugar", "Sugar", "Tasty spacey sugar!"),
		"aspartame" = list("condi_aspartame", "Aspartame", "The sweetness of a thousand sugars but none of the calories."),
		"cream" = list("condi_creamer", "Creamer", "Better not think about what they're making this from."),
		"chocolate_sprinkle" = list("condi_chocolate", "Chocolate sprinkle", "The amount of sugar that's already there wasn't enough for you?"),
	)

/obj/item/reagent_containers/condiment/pack/try_eat(atom/target, mob/living/user)
	return NONE

/obj/item/reagent_containers/condiment/pack/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	//You can tear the bag open above food to put the condiments on it, obviously.
	if(target.is_refillable() || istype(target, /obj/item/reagent_containers/food))
		if(!reagents.total_volume)
			to_chat(user, span_warning("Вы разрываете [declent_ru(ACCUSATIVE)], но внутри ничего нет!."))
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, span_warning("Вы разрываете [declent_ru(ACCUSATIVE)], но на [target.declent_ru(PREPOSITIONAL)] нет места!")) //Not sure if food can ever be full, but better safe than sorry.
			qdel(src)
			return
		to_chat(user, span_notice("Вы разрываете [declent_ru(ACCUSATIVE)] над [target.declent_ru(PREPOSITIONAL)], высыпая содержимое."))
		reagents.trans_to(target, amount_per_transfer_from_this)
		qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/reagent_containers/condiment/pack/update_desc(updates = ALL)
	. = ..()
	if(length(reagents.reagent_list))
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			desc = temp_list[3]
		else
			desc = "A small condiment pack. The label says it contains [originalname]."
	else
		desc = "A small condiment pack. It is empty."

/obj/item/reagent_containers/condiment/pack/update_icon_state()
	. = ..()
	if(length(reagents.reagent_list))
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
		else
			icon_state = "condi_mixed"
	else
		icon_state = "condi_empty"

/obj/item/reagent_containers/condiment/pack/on_reagent_change()
	update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)

// MARK: Pack types
/obj/item/reagent_containers/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"
	list_reagents = list("ketchup" = 10)

/obj/item/reagent_containers/condiment/pack/ketchup/get_ru_names()
	return alist(
		NOMINATIVE = "пакетик кетчупа",
		GENITIVE = "пакетика кетчупа",
		DATIVE = "пакетику кетчупа",
		ACCUSATIVE = "пакетик кетчупа",
		INSTRUMENTAL = "пакетиком кетчупа",
		PREPOSITIONAL = "пакетике кетчупа"
	)

/obj/item/reagent_containers/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"
	list_reagents = list("capsaicin" = 10)

/obj/item/reagent_containers/condiment/pack/hotsauce/get_ru_names()
	return alist(
		NOMINATIVE = "пакетик острого соуса",
		GENITIVE = "пакетика острого соуса",
		DATIVE = "пакетику острого соуса",
		ACCUSATIVE = "пакетик острого соуса",
		INSTRUMENTAL = "пакетиком острого соуса",
		PREPOSITIONAL = "пакетике острого соуса"
	)

// Animal feed
/obj/item/reagent_containers/condiment/animalfeed
	name = "pet food package"
	desc = "Корм для домашних животных. Вы же точно не хотите это пробовать?.."
	icon = 'icons/obj/pet_bowl.dmi'
	icon_state = "pet_food"
	volume = 80
	list_reagents = list("afeed" = 80)

/obj/item/reagent_containers/condiment/animalfeed/on_reagent_change()
	return

/obj/item/reagent_containers/condiment/pack/creamer
	name = "creamer pack"
	originalname = "creamer"
	list_reagents = list("cream" = 10)

/obj/item/reagent_containers/condiment/pack/creamer/get_ru_names()
	return alist(
		NOMINATIVE = "пакетик сливок",
		GENITIVE = "пакетика сливок",
		DATIVE = "пакетику сливок",
		ACCUSATIVE = "пакетик сливок",
		INSTRUMENTAL = "пакетиком сливок",
		PREPOSITIONAL = "пакетике сливок"
	)

/obj/item/reagent_containers/condiment/pack/creamer/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader, "creamer")

/obj/item/reagent_containers/condiment/pack/sugar
	name = "sugar pack"
	originalname = "sugar"
	list_reagents = list("sugar" = 10)

/obj/item/reagent_containers/condiment/pack/sugar/get_ru_names()
	return alist(
		NOMINATIVE = "пакетик сахара",
		GENITIVE = "пакетика сахара",
		DATIVE = "пакетику сахара",
		ACCUSATIVE = "пакетик сахара",
		INSTRUMENTAL = "пакетиком сахара",
		PREPOSITIONAL = "пакетике сахара"
	)

/obj/item/reagent_containers/condiment/pack/sugar/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader, "sugar")

/obj/item/reagent_containers/condiment/pack/aspartame
	name = "aspartame pack"
	originalname = "aspartame"
	list_reagents = list("aspartame" = 10)

/obj/item/reagent_containers/condiment/pack/aspartame/get_ru_names()
	return alist(
		NOMINATIVE = "пакетик аспартама",
		GENITIVE = "пакетика аспартама",
		DATIVE = "пакетику аспартама",
		ACCUSATIVE = "пакетик аспартама",
		INSTRUMENTAL = "пакетиком аспартама",
		PREPOSITIONAL = "пакетике аспартама"
	)

/obj/item/reagent_containers/condiment/pack/aspartame/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader, "aspartame")

/obj/item/reagent_containers/condiment/pack/chocolate
	name = "chocolate sprinkle pack"
	originalname = "chocolate sprikle"
	list_reagents = list("chocolate_sprinkle" = 10)

/obj/item/reagent_containers/condiment/pack/chocolate/get_ru_names()
	return alist(
		NOMINATIVE = "пакетик шоколадной посыпки",
		GENITIVE = "пакетика шоколадной посыпки",
		DATIVE = "пакетику шоколадной посыпки",
		ACCUSATIVE = "пакетик шоколадной посыпки",
		INSTRUMENTAL = "пакетиком шоколадной посыпки",
		PREPOSITIONAL = "пакетике шоколадной посыпки"
	)
