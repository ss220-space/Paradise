
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/food/condiment
	name = "condiment container"
	desc = "Обычная ёмкость для приправ."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "emptycondiment"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	container_type = OPENCONTAINER
	possible_transfer_amounts = list(1, 5)
	visible_transfer_rate = TRUE
	volume = 50
	//Possible_states has the reagent id as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change() to change names, descs and sprites.
	var/list/possible_states = list(
	 "ketchup" = list("ketchup", "ketchup bottle", "Вы уже ощущаете себя как настоящий американец."),
	 "capsaicin" = list("hotsauce", "hotsauce bottle", "Теперь вы почти ЧУВСТВУЕТЕ, что такое язва желудка!"),
	 "enzyme" = list("enzyme", "universal enzyme bottle", "Используется для приготовления разнообразных блюд."),
	 "soysauce" = list("soysauce", "soy sauce bottle", "Солёная приправа на основе сои."),
	 "frostoil" = list("coldsauce", "coldsauce bottle", "Из-за этого язык немеет."),
	 "sodiumchloride" = list("saltshakersmall", "salt shaker", "Соль. Предположительно, из космических океанов."),
	 "blackpepper" = list("peppermillsmall", "pepper mill", "Часто используется для придания аромата пище или для того, чтобы заставить людей чихать."),
	 "cornoil" = list("oliveoil", "corn oil bottle", "Вкусное масло, используемое в кулинарии. Готовится из кукурузы."),
	 "oliveoil" = list("oliveoil", "olive oil bottle", "Вкусное масло, используемое в кулинарии. Готовится из оливок.s"),
	 "sugar" = list("emptycondiment", "sugar bottle", "Вкусный космический сахар!"))
	var/originalname = "приправа" //Can't use initial(name) for this. This stores the name set by condimasters.

/obj/item/reagent_containers/food/condiment/attack_self(mob/user)
	return

/obj/item/reagent_containers/food/condiment/set_APTFT()
	set hidden = FALSE
	..()

/obj/item/reagent_containers/food/condiment/empty()
	set hidden = FALSE
	..()


/obj/item/reagent_containers/food/condiment/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(target))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] пуст, вот незадача!"))
		return .

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			to_chat(user, span_warning("Ваше лицо закрыто."))
		else
			to_chat(user, span_warning("Лицо [target] закрыто."))
		return .

	if(target == user)
		to_chat(target, span_notice("Вы проглатываете часть содержимого [declent_ru(GENITIVE)]."))
	else
		user.visible_message(
			span_warning("[user] пыта[pluralize_ru(user.gender,"ет","ют")]ся накормить [target] из [declent_ru(GENITIVE)]."),
			span_notice("Вы пытаетесь накормить [target] из [declent_ru(GENITIVE)]..."),
		)
		if(!do_after(user, 3 SECONDS, target, NONE) || !get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH) || !reagents || !reagents.total_volume)
			return .
		user.visible_message(
			span_warning("[user] корм[pluralize_ru(user.gender,"ит","ят")] [target] из [declent_ru(GENITIVE)]."),
			span_notice("Вы накормили [target] из [declent_ru(GENITIVE)]."),
		)
		add_attack_logs(user, target, "Fed [src] containing [reagents.log_list()]", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)

	var/fraction = min(10/reagents.total_volume, 1)
	reagents.reaction(target, REAGENT_INGEST, fraction)
	reagents.trans_to(target, 10)
	playsound(target.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	return .|ATTACK_CHAIN_SUCCESS


/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[capitalize(target.declent_ru(NOMINATIVE))] пуст!"))
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] заполнен!"))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, span_notice("Вы наполняете [declent_ru(NOMINATIVE)] [trans] единиц[declension_ru(trans,"ей","ами","ами")] содержимого из [target.declent_ru(GENITIVE)]."))

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_drainable() || istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] пуст!"))
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, span_warning("Вы не можете добавить больше в [target.declent_ru(GENITIVE)]!"))
			return
		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, span_notice("Вы переливаете [trans] единиц[declension_ru(trans,"У","ы","")] приправы в [target.declent_ru(GENITIVE)]."))

/obj/item/reagent_containers/food/condiment/on_reagent_change()
	if(!possible_states.len)
		return
	if(reagents.reagent_list.len > 0)
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
				desc = "Похоже, это [lowertext(main_reagent)], но вы не уверены."
			else
				desc = "Смесь различных приправ. [capitalize(main_reagent)] — одна из них."
			icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "Пустая бутылка для приправ."
		ru_names = list(
			NOMINATIVE = "бутылка для приправ",
			GENITIVE = "бутылки для приправ",
			DATIVE = "бутылке для приправ",
			ACCUSATIVE = "бутылку для приправ",
			INSTRUMENTAL = "бутылкой для приправ",
			PREPOSITIONAL = "бутылке для приправ"
		)

/obj/item/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Используется для приготовления разнообразных блюд."
	ru_names = list(
		NOMINATIVE = "универсальный фермент",
		GENITIVE = "универсального фермента",
		DATIVE = "универсальному ферменту",
		ACCUSATIVE = "универсальный фермент",
		INSTRUMENTAL = "универсальным ферментом",
		PREPOSITIONAL = "универсальном ферменте"
	)
	icon_state = "enzyme"
	list_reagents = list("enzyme" = 50)

/obj/item/reagent_containers/food/condiment/sugar
	name = "sugar bottle"
	desc = "Вкусный космический сахар!"
	ru_names = list(
		NOMINATIVE = "сахарница",
		GENITIVE = "сахарницы",
		DATIVE = "сахарнице",
		ACCUSATIVE = "сахарницу",
		INSTRUMENTAL = "сахарницей",
		PREPOSITIONAL = "сахарнице"
	)
	list_reagents = list("sugar" = 50)

/obj/item/reagent_containers/food/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = "Соль. Предположительно, из космических океанов."
	ru_names = list(
		NOMINATIVE = "солонка",
		GENITIVE = "солонки",
		DATIVE = "солонке",
		ACCUSATIVE = "солонку",
		INSTRUMENTAL = "солонкой",
		PREPOSITIONAL = "солонке"
	)
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,5,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("sodiumchloride" = 20)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/saltshaker/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] начина[pluralize_ru(user.gender,"ет","ют")] меняться местами с солонкой! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся покончить с собой."))
	var/newname = "[name]"
	name = "[user.name]"
	user.name = newname
	user.real_name = newname
	desc = "Соль. Вероятно, из мёртвыго членов экипажа."
	return BRUTELOSS

/obj/item/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Часто используется для придания аромата пище или для того, чтобы заставить людей чихать."
	ru_names = list(
		NOMINATIVE = "перечница",
		GENITIVE = "перечницы",
		DATIVE = "перечнице",
		ACCUSATIVE = "перечницу",
		INSTRUMENTAL = "перечницей",
		PREPOSITIONAL = "перечнице"
	)
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,5,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/milk
	name = "space milk"
	desc = "Это молоко. Белая и питательная полезность!"
	ru_names = list(
		NOMINATIVE = "космическое молоко",
		GENITIVE = "космического молока",
		DATIVE = "космическому молоку",
		ACCUSATIVE = "космическое молоко",
		INSTRUMENTAL = "космическим молоком",
		PREPOSITIONAL = "космическом молоке"
	)
	icon_state = "milk"
	item_state = "carton"
	list_reagents = list("milk" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "Большая упаковка муки. Отлично подходит для выпечки!"
	ru_names = list(
		NOMINATIVE = "упаковка муки",
		GENITIVE = "упаковки муки",
		DATIVE = "упаковке муки",
		ACCUSATIVE = "упаковку муки",
		INSTRUMENTAL = "упаковкой муки",
		PREPOSITIONAL = "упаковке муки"
	)
	icon_state = "flour"
	item_state = "flour"
	list_reagents = list("flour" = 30)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/soymilk
	name = "soy milk"
	desc = "Это соевое молоко. Белая и питательная полезность!"
	ru_names = list(
		NOMINATIVE = "соевое молоко",
		GENITIVE = "соевого молока",
		DATIVE = "соевому молоку",
		ACCUSATIVE = "соевое молоко",
		INSTRUMENTAL = "соевым молоком",
		PREPOSITIONAL = "соевом молоке"
	)
	icon_state = "soymilk"
	item_state = "carton"
	list_reagents = list("soymilk" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "Большой упаковка риса. Отлично подходит для готовки!"
	ru_names = list(
		NOMINATIVE = "упаковка риса",
		GENITIVE = "упаковки риса",
		DATIVE = "упаковке риса",
		ACCUSATIVE = "упаковку риса",
		INSTRUMENTAL = "упаковкой риса",
		PREPOSITIONAL = "упаковке риса"
	)
	icon_state = "rice"
	item_state = "flour"
	list_reagents = list("rice" = 30)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = "Солёная приправа на основе сои."
	ru_names = list(
		NOMINATIVE = "соевый соус",
		GENITIVE = "соевого соуса",
		DATIVE = "соевому соусу",
		ACCUSATIVE = "соевый соус",
		INSTRUMENTAL = "соевым соусом",
		PREPOSITIONAL = "соевом соусе"
	)
	icon_state = "soysauce"
	list_reagents = list("soysauce" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/syndisauce
	name = "Chef Excellence's Special Sauce"
	desc = "Этот ароматный соус, приготовленный из мухоморов, просто восхитителен! Смерть никогда не была такой приятной на вкус."
	ru_names = list(
		NOMINATIVE = "элитарный соус шефа",
		GENITIVE = "элитарного соуса шефа",
		DATIVE = "элитарному соусу шефа",
		ACCUSATIVE = "элитарный соус шефа",
		INSTRUMENTAL = "элитарным соусом шефа",
		PREPOSITIONAL = "элитарном соусе шефа"
	)
	list_reagents = list("amanitin" = 50)
	possible_states = list()
	log_eating = TRUE

//Tomato sauce
/obj/item/reagent_containers/food/condiment/tomatosauce
	name = "tomato sauce"
	desc = "Отец всех соусов. Томаты, немного специй и ничего лишнего."
	ru_names = list(
		NOMINATIVE = "томатный соус",
		GENITIVE = "томатного соуса",
		DATIVE = "томатному соусу",
		ACCUSATIVE = "томатный соус",
		INSTRUMENTAL = "томатным соусом",
		PREPOSITIONAL = "томатном соусе"
	)
	icon_state = "tomatosauce"
	list_reagents = list("tsauce" = 50)
	possible_states = list()

//Diablo sauce
/obj/item/reagent_containers/food/condiment/diablosauce
	name = "diablo sauce"
	desc = "Древний обжигающий соус, его рецепт почти не изменился со времён создания."
	ru_names = list(
		NOMINATIVE = "соус диабло",
		GENITIVE = "соуса диабло",
		DATIVE = "соусу диабло",
		ACCUSATIVE = "соус диабло",
		INSTRUMENTAL = "соусом диабло",
		PREPOSITIONAL = "соусе диабло"
	)
	icon_state = "diablosauce"
	list_reagents = list("dsauce" = 50)
	possible_states = list()

//Cheese sauce
/obj/item/reagent_containers/food/condiment/cheesesauce
	name = "cheese sauce"
	desc = "Сыр, сливки и молоко... максимальная концентрация белка!"
	ru_names = list(
		NOMINATIVE = "сырный соус",
		GENITIVE = "сырного соуса",
		DATIVE = "сырному соусу",
		ACCUSATIVE = "сырный соус",
		INSTRUMENTAL = "сырным соусом",
		PREPOSITIONAL = "сырном соусе"
	)
	icon_state = "cheesesauce"
	list_reagents = list("csauce" = 50)
	possible_states = list()

//Mushroom sauce
/obj/item/reagent_containers/food/condiment/mushroomsauce
	name = "mushroom sauce"
	desc = "Сливочный соус с грибами, имеет довольно резкий запах."
	ru_names = list(
		NOMINATIVE = "грибной соус",
		GENITIVE = "грибного соуса",
		DATIVE = "грибному соусу",
		ACCUSATIVE = "грибной соус",
		INSTRUMENTAL = "грибным соусом",
		PREPOSITIONAL = "грибном соусе"
	)
	icon_state = "mushroomsauce"
	list_reagents = list("msauce" = 50)
	possible_states = list()

//Garlic sauce
/obj/item/reagent_containers/food/condiment/garlicsauce
	name = "garlic sauce"
	desc = "Крепкий соус с чесноком, его запах бьёт в нос. Некоторые члены экипажа, вероятно, будут шипеть на вас и уходить."
	ru_names = list(
		NOMINATIVE = "чесночный соус",
		GENITIVE = "чесночного соуса",
		DATIVE = "чесночному соусу",
		ACCUSATIVE = "чесночный соус",
		INSTRUMENTAL = "чесночным соусом",
		PREPOSITIONAL = "чесночном соусе"
	)
	icon_state = "garlicsauce"
	list_reagents = list("gsauce" = 50)
	possible_states = list()

//Custard
/obj/item/reagent_containers/food/condiment/custard
	name = "Custard"
	desc = "Мягкая и сладкая масса, используется в кондитерских изделиях."
	ru_names = list(
		NOMINATIVE = "заварной крем",
		GENITIVE = "заварного крема",
		DATIVE = "заварному крему",
		ACCUSATIVE = "заварной крем",
		INSTRUMENTAL = "заварным кремом",
		PREPOSITIONAL = "заварном креме"
	)
	icon_state = "custard"
	list_reagents = list("custard" = 50)
	possible_states = list()

//Herbs
/obj/item/reagent_containers/food/condiment/herbs
	name = "Herbs mix"
	desc = "Смесь различных трав. Идеально для пиццы!"
	ru_names = list(
		NOMINATIVE = "смесь трав",
		GENITIVE = "смеси трав",
		DATIVE = "смеси трав",
		ACCUSATIVE = "смесь трав",
		INSTRUMENTAL = "смесью трав",
		PREPOSITIONAL = "смеси трав"
	)
	icon_state = "herbs"
	list_reagents = list("herbsmix" = 50)
	possible_states = list()

//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/food/condiment/pack
	name = "condiment pack"
	desc = "Небольшой пластиковый пакетик с приправами для вашей еды."
	ru_names = list(
		NOMINATIVE = "пакет с приправой",
		GENITIVE = "пакета с приправой",
		DATIVE = "пакету с приправой",
		ACCUSATIVE = "пакет с приправой",
		INSTRUMENTAL = "пакетом с приправой",
		PREPOSITIONAL = "пакете с приправой"
	)
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	possible_states = list(
	 "ketchup" = list("condi_ketchup", "Ketchup", "Вы уже ощущаете себя как настоящий американец."),
	 "capsaicin" = list("condi_hotsauce", "Hotsauce", "Теперь вы почти ЧУВСТВУЕТЕ, что такое язва желудка!"),
	 "soysauce" = list("condi_soysauce", "Soy Sauce", "Солёная приправа на основе сои."),
	 "frostoil" = list("condi_frostoil", "Coldsauce", "Из-за этого язык немеет"),
	 "sodiumchloride" = list("condi_salt", "Salt Shaker", "Соль. Предположительно, из космических океанов."),
	 "blackpepper" = list("condi_pepper", "Pepper Mill", "Часто используется для придания аромата пище или для того, чтобы заставить людей чихать"),
	 "cornoil" = list("condi_cornoil", "Corn Oil", "Вкусное масло, используемое в кулинарии. Готовится из кукурузы."),
	 "oliveoil" = list("condi_oliveoil", "Olive Oil", "Вкусное масло, используемое в кулинарии. Готовится из оливок.s"),
	 "sugar" = list("condi_sugar", "Sugar", "Вкусный космический сахар!")
	)


/obj/item/reagent_containers/food/condiment/pack/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED	// Can't feed these to people directly.


/obj/item/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return

	//You can tear the bag open above food to put the condiments on it, obviously.
	if(istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, span_warning("Вы разрываете [declent_ru(ACCUSATIVE)], но внутри ничего нет."))
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, span_warning("Вы разрываете [declent_ru(ACCUSATIVE)], но [target.declent_ru(NOMINATIVE)] настолько переполнен, что содержимое просто стекает!")) //Not sure if food can ever be full, but better safe than sorry.
			qdel(src)
			return
		else
			to_chat(user, span_notice("Вы разрываете [declent_ru(ACCUSATIVE)] над [target.declent_ru(INSTRUMENTAL)], и приправы капают на него."))
			reagents.trans_to(target, amount_per_transfer_from_this)
			qdel(src)


/obj/item/reagent_containers/food/condiment/pack/update_desc(updates = ALL)
	. = ..()
	if(length(reagents.reagent_list))
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			desc = temp_list[3]
		else
			desc = "Небольшой пакетик с приправой. На этикетке указано, что внутри [originalname]."
	else
		desc = "Небольшой пакетик с приправой. Он пуст."


/obj/item/reagent_containers/food/condiment/pack/update_icon_state()
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


/obj/item/reagent_containers/food/condiment/pack/on_reagent_change()
	update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)


//Ketchup
/obj/item/reagent_containers/food/condiment/pack/ketchup
	name = "ketchup pack"
	ru_names = list(
		NOMINATIVE = "пакет кетчупа",
		GENITIVE = "пакета кетчупа",
		DATIVE = "пакету кетчупа",
		ACCUSATIVE = "пакет кетчупа",
		INSTRUMENTAL = "пакетом кетчупа",
		PREPOSITIONAL = "пакете кетчупа"
	)
	originalname = "кетчуп"
	list_reagents = list("ketchup" = 10)

//Hot sauce
/obj/item/reagent_containers/food/condiment/pack/hotsauce
	name = "hotsauce pack"
	ru_names = list(
		NOMINATIVE = "пакет острого соуса",
		GENITIVE = "пакета острого соуса",
		DATIVE = "пакету острого соуса",
		ACCUSATIVE = "пакет острого соуса",
		INSTRUMENTAL = "пакетом острого соуса",
		PREPOSITIONAL = "пакете острого соуса"
	)
	originalname = "острый соус"
	list_reagents = list("capsaicin" = 10)

/obj/item/reagent_containers/food/condiment/animalfeed
	name = "pet food package"
	desc = "Корм для домашних животных. Вы же точно не хотите это пробовать?.."
	ru_names = list(
		NOMINATIVE = "упаковка корма для питомцев",
		GENITIVE = "упаковки корма для питомцев",
		DATIVE = "упаковке корма для питомцев",
		ACCUSATIVE = "упаковку корма для питомцев",
		INSTRUMENTAL = "упаковкой корма для питомцев",
		PREPOSITIONAL = "упаковке корма для питомцев"
	)
	icon = 'icons/obj/pet_bowl.dmi'
	icon_state = "pet_food"
	volume = 80
	list_reagents = list("afeed" = 80)

/obj/item/reagent_containers/food/condiment/animalfeed/on_reagent_change()
	return
