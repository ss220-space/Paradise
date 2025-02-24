/obj/item/reagent_containers/food/drinks/cans
	var/canopened = FALSE
	container_type = NONE
	var/is_glass = 0
	var/is_plastic = 0
	var/times_shaken = 0
	var/can_shake = TRUE
	var/can_burst = FALSE
	var/burst_chance = 0
	foodtype = SUGAR
	gender = FEMALE

/obj/item/reagent_containers/food/drinks/cans/empty()
	if(!canopened)
		balloon_alert(usr, "сначала откройте!")
		return
	..()

/obj/item/reagent_containers/food/drinks/cans/examine(mob/user)
	. = ..()
	. += span_notice("<b>[canopened ? "Открыто" : "Закрыто"]</b>")
	if(!canopened)
		. += span_info("Используйте <b>Ctrl+ЛКМ</b>, чтобы встряхнуть!")

/obj/item/reagent_containers/food/drinks/cans/attack_self(mob/user)
	if(canopened)
		return ..()
	if(times_shaken)
		fizzy_open(user)
		return ..()
	playsound(loc, 'sound/effects/canopen.ogg', rand(10, 50), 1)
	canopened = TRUE
	container_type |= OPENCONTAINER
	to_chat(user, span_notice("Вы открываете [declent_ru(ACCUSATIVE)] с громким хлопком!"))
	return ..()

/obj/item/reagent_containers/food/drinks/cans/proc/crush(mob/user)
	var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(user.loc)
	crushed_can.icon_state = icon_state
	//inherit material vars for recycling purposes
	crushed_can.is_glass = is_glass
	crushed_can.is_plastic = is_plastic
	if(is_glass)
		playsound(user.loc, 'sound/effects/glassbr3.ogg', rand(10, 50), 1)
		crushed_can.name = "broken bottle"
	else
		playsound(user.loc, 'sound/weapons/pierce.ogg', rand(10, 50), 1)
	qdel(src)
	return crushed_can

/obj/item/reagent_containers/food/drinks/cans/CtrlClick(mob/living/user)
	if(!can_shake || !ishuman(user))
		return ..()
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		balloon_alert(user, "невозможно в данный момент!")
		return ..()
	var/mob/living/carbon/human/H = user
	if(canopened)
		balloon_alert(H, "нельзя встряхнуть после открытия!")
		return
	if(src == H.l_hand || src == H.r_hand)
		can_shake = FALSE
		addtimer(CALLBACK(src, PROC_REF(reset_shakable)), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		to_chat(H, span_notice("Вы начинаете встряхивать [declent_ru(ACCUSATIVE)]."))
		if(do_after(H, 1 SECONDS, H))
			visible_message(span_warning("[user] встряхнул[genderize_ru(user.gender, "", "а", "о", "и")] [declent_ru(ACCUSATIVE)]!"))
			if(times_shaken == 0)
				times_shaken++
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), 1 MINUTES, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
			else if(times_shaken < 5)
				times_shaken++
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), (70 - (times_shaken * 10)) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
			else
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), 20 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
				handle_bursting(user)
	else
		balloon_alert(H, "нужно держать в руке!")


/obj/item/reagent_containers/food/drinks/cans/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!canopened)
		balloon_alert(user, "сначала откройте!")
		return ATTACK_CHAIN_PROCEED
	if(target == user && !reagents.total_volume && user.a_intent == INTENT_HARM && user.zone_selected == BODY_ZONE_HEAD)
		user.visible_message(
			span_warning("[user] смина[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] своим лбом!"),
			span_warning("Вы сминаете [declent_ru(ACCUSATIVE)] своим лбом!"),
		)
		crush(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/drinks/cans/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash/cyborg))
		user.visible_message(
			span_notice("[user] засовыва[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] в свой уплотнитель мусора."),
			span_notice("Вы засовываете [declent_ru(ACCUSATIVE)] в свой уплотнитель мусора."),
		)
		var/obj/can = crush(user)
		can.attackby(I, user, params)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/drinks/cans/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers) && !canopened)
		balloon_alert(user, "сначала откройте!")
		return
	else if(target.is_open_container() && !canopened)
		balloon_alert(user, "сначала откройте!")
		return
	else
		return ..(target, user, proximity)

/obj/item/reagent_containers/food/drinks/cans/throw_impact(atom/A, datum/thrownthing/throwingdatum)
	. = ..()
	if(times_shaken < 5)
		times_shaken++
	else
		handle_bursting()

/obj/item/reagent_containers/food/drinks/cans/proc/fizzy_open(mob/user, burstopen = FALSE)
	playsound(loc, 'sound/effects/canopenfizz.ogg', rand(10, 50), 1)
	canopened = TRUE
	container_type |= OPENCONTAINER

	if(!burstopen && user)
		to_chat(user, span_notice("Вы открываете [declent_ru(ACCUSATIVE)] с громким хлопком!"))
	else
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] оглушительно открывается!"))

	if(times_shaken < 5)
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] громко шипит!"))
	else
		visible_message(span_boldwarning("[capitalize(declent_ru(NOMINATIVE))] оглушительно лопается, разливая своё содержимое!"))
		if(reagents.total_volume)
			var/datum/effect_system/fluid_spread/foam/sodafizz = new
			sodafizz.set_up(amount = 1, location = get_turf(src), carry = reagents)
			sodafizz.start()

	for(var/mob/living/carbon/C in range(1, get_turf(src)))
		to_chat(C, span_warning("Вас облило содержимым [declent_ru(ACCUSATIVE)]!"))
		reagents.reaction(C, REAGENT_TOUCH)
		C.wetlevel = max(C.wetlevel + 1, times_shaken)

	reagents.remove_any(times_shaken / 5 * reagents.total_volume)

/obj/item/reagent_containers/food/drinks/cans/proc/handle_bursting(mob/user)
	if(times_shaken != 5 || canopened)
		return

	if(!can_burst)
		can_burst = TRUE
		burst_chance = 5
		return

	if(burst_chance < 50)
		burst_chance += 5

	if(prob((burst_chance)))
		if(user)
			fizzy_open(user, burstopen = TRUE)
		else
			fizzy_open(burstopen = TRUE)

/obj/item/reagent_containers/food/drinks/cans/proc/reset_shakable()
	can_shake = TRUE

/obj/item/reagent_containers/food/drinks/cans/proc/reset_shaken()
	times_shaken--
	if(can_burst)
		can_burst = FALSE
		burst_chance = 0
	if(times_shaken)
		addtimer(CALLBACK(src, PROC_REF(reset_shaken)), (70 - (times_shaken * 10)) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)

/obj/item/reagent_containers/food/drinks/cans/cola
	name = "space cola"
	desc = "Это кола. Нестареющая классика."
	ru_names = list(
		NOMINATIVE = "банка колы",
		GENITIVE = "банки колы",
		DATIVE = "банке колы",
		ACCUSATIVE = "банку колы",
		INSTRUMENTAL = "банкой колы",
		PREPOSITIONAL = "банке колы"
 	)
	icon_state = "cola"
	list_reagents = list("cola" = 30)

/obj/item/reagent_containers/food/drinks/cans/energy
	name = "heart attack"
	desc = "Пока сердце вам не скажет - \"Моя остановка\"."
	ru_names = list(
		NOMINATIVE = "банка энергетика \"Сердечный Приступ\"",
		GENITIVE = "банки энергетика \"Сердечный Приступ\"",
		DATIVE = "банке энергетика \"Сердечный Приступ\"",
		ACCUSATIVE = "банку энергетика \"Сердечный Приступ\"",
		INSTRUMENTAL = "банкой энергетика \"Сердечный Приступ\"",
		PREPOSITIONAL = "банке энергетика \"Сердечный Приступ\""
 	)
	icon_state = "heart_attack"
	item_state = "heart_attack"
	list_reagents = list("energetik" = 30)

/obj/item/reagent_containers/food/drinks/cans/energy/trop
	name = "tropical spasm"
	desc = "Почувствуйте бодрящий вкус тропических фруктов!"
	ru_names = list(
		NOMINATIVE = "банка энергетика \"Тропический Спазм\"",
		GENITIVE = "банки энергетика \"Тропический Спазм\"",
		DATIVE = "банке энергетика \"Тропический Спазм\"",
		ACCUSATIVE = "банку энергетика \"Тропический Спазм\"",
		INSTRUMENTAL = "банкой энергетика \"Тропический Спазм\"",
		PREPOSITIONAL = "банке энергетика \"Тропический Спазм\""
 	)
	icon_state = "tropical_spasm"
	item_state = "tropical_spasm"
	list_reagents = list("trop_eng" = 30)

/obj/item/reagent_containers/food/drinks/cans/energy/milk
	name = "milk flow"
	desc = "Для самых профессиональных геймеров."
	ru_names = list(
		NOMINATIVE = "банка энергетика \"Молочный Удар\"",
		GENITIVE = "банки энергетика \"Молочный Удар\"",
		DATIVE = "банке энергетика \"Молочный Удар\"",
		ACCUSATIVE = "банку энергетика \"Молочный Удар\"",
		INSTRUMENTAL = "банкой энергетика \"Молочный Удар\"",
		PREPOSITIONAL = "банке энергетика \"Молочный Удар\""
 	)
	icon_state = "milk_flow"
	item_state = "milk_flow"
	list_reagents = list("milk_eng" = 30)

/obj/item/reagent_containers/food/drinks/cans/energy/grey
	name = "GreyPower"
	desc = "Ваши руки будут гореть от \"Грей Энерджи\"."
	ru_names = list(
		NOMINATIVE = "банка энергетика \"Грей Энерджи\"",
		GENITIVE = "банки энергетика \"Грей Энерджи\"",
		DATIVE = "банке энергетика \"Грей Энерджи\"",
		ACCUSATIVE = "банку энергетика \"Грей Энерджи\"",
		INSTRUMENTAL = "банкой энергетика \"Грей Энерджи\"",
		PREPOSITIONAL = "банке энергетика \"Грей Энерджи\""
 	)
	icon_state = "GreyPower"
	item_state = "GreyPower"
	list_reagents = list("grey_eng" = 30)

/obj/item/reagent_containers/food/drinks/cans/beer
	name = "space beer"
	desc = "Вода, солод и хмель - а больше и не требуется."
	ru_names = list(
		NOMINATIVE = "бутылка пива",
		GENITIVE = "бутылки пива",
		DATIVE = "бутылке пива",
		ACCUSATIVE = "бутылку пива",
		INSTRUMENTAL = "бутылкой пива",
		PREPOSITIONAL = "бутылке пива"
 	)
	icon_state = "beer"
	is_glass = 1
	list_reagents = list("beer" = 30)

/obj/item/reagent_containers/food/drinks/cans/non_alcoholic_beer
	name = "non-alcoholic beer"
	desc = "Любимое пойло студентов и тех, кто за рулём."
	ru_names = list(
		NOMINATIVE = "бутылка безалкогольного пива",
		GENITIVE = "бутылки безалкогольного пива",
		DATIVE = "бутылке безалкогольного пива",
		ACCUSATIVE = "бутылку безалкогольного пива",
		INSTRUMENTAL = "бутылкой безалкогольного пива",
		PREPOSITIONAL = "бутылке безалкогольного пива"
 	)
	icon_state = "alcoholfreebeercan"
	list_reagents = list("noalco_beer" = 30)


/obj/item/reagent_containers/food/drinks/cans/adminbooze
	name = "admin booze"
	desc = "Бутылированные слёзы Гриффона. Пить со всей осторожностью."
	ru_names = list(
		NOMINATIVE = "бутылка настойки \"Админово Пойло\"",
		GENITIVE = "бутылки настойки \"Админово Пойло\"",
		DATIVE = "бутылке настойки \"Админово Пойло\"",
		ACCUSATIVE = "бутылку настойки \"Админово Пойло\"",
		INSTRUMENTAL = "бутылкой настойки \"Админово Пойло\"",
		PREPOSITIONAL = "бутылке настойки \"Админово Пойло\""
 	)
	icon_state = "adminbooze"
	is_glass = 1
	list_reagents = list("adminordrazine" = 5, "capsaicin" = 5, "methamphetamine"= 20, "thirteenloko" = 20)

/obj/item/reagent_containers/food/drinks/cans/madminmalt
	name = "madmin malt"
	desc = "Бутылированная эссенция ярости администрации. Пить с <i>ПРЕДЕЛЬНОЙ</i> осторожностью."
	ru_names = list(
		NOMINATIVE = "бутылка настойки \"Ярость Админа\"",
		GENITIVE = "бутылки настойки \"Ярость Админа\"",
		DATIVE = "бутылке настойки \"Ярость Админа\"",
		ACCUSATIVE = "бутылку настойки \"Ярость Админа\"",
		INSTRUMENTAL = "бутылкой настойки \"Ярость Админа\"",
		PREPOSITIONAL = "бутылке настойки \"Ярость Админа\""
 	)
	icon_state = "madminmalt"
	is_glass = 1
	list_reagents = list("hell_water" = 20, "neurotoxin" = 15, "thirteenloko" = 15)

/obj/item/reagent_containers/food/drinks/cans/badminbrew
	name = "badmin brew"
	desc = "Бутылированная эссенция со вкусом щитспавна и ужасных ивентов. Наверное, это вам пить не стоит."
	ru_names = list(
		NOMINATIVE = "бутылка настойки \"Плохой Админ\"",
		GENITIVE = "бутылки настойки \"Плохой Админ\"",
		DATIVE = "бутылке настойки \"Плохой Админ\"",
		ACCUSATIVE = "бутылку настойки \"Плохой Админ\"",
		INSTRUMENTAL = "бутылкой настойки \"Плохой Админ\"",
		PREPOSITIONAL = "бутылке настойки \"Плохой Админ\""
 	)
	icon_state = "badminbrew"
	is_glass = 1
	list_reagents = list("mutagen" = 25, "charcoal" = 10, "thirteenloko" = 15)

/obj/item/reagent_containers/food/drinks/cans/ale
	name = "Tail Tells Tales Ale"
	desc = "К этикетке прикреплён хвостик, который тянется по всей длине банки. Если вы его оторвете, то сможете прочитать короткую легенду на его обратной стороне."
	ru_names = list(
		NOMINATIVE = "бутылка эля \"Хвостатые Истории\"",
		GENITIVE = "бутылки эля \"Хвостатые Истории\"",
		DATIVE = "бутылке эля \"Хвостатые Истории\"",
		ACCUSATIVE = "бутылку эля \"Хвостатые Истории\"",
		INSTRUMENTAL = "бутылкой эля \"Хвостатые Истории\"",
		PREPOSITIONAL = "бутылке эля \"Хвостатые Истории\""
 	)
	icon_state = "alebottle"
	item_state = "beer"
	is_glass = 1
	list_reagents = list("ale" = 30)

/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Проходит насквозь, словно космический ветер."
	ru_names = list(
		NOMINATIVE = "банка газировки \"Космический Маунтин Винд\"",
		GENITIVE = "банки газировки \"Космический Маунтин Винд\"",
		DATIVE = "банке газировки \"Космический Маунтин Винд\"",
		ACCUSATIVE = "банку газировки \"Космический Маунтин Винд\"",
		INSTRUMENTAL = "банкой газировки \"Космический Маунтин Винд\"",
		PREPOSITIONAL = "банке газировки \"Космический Маунтин Винд\""
 	)
	icon_state = "space_mountain_wind"
	list_reagents = list("spacemountainwind" = 30)

/obj/item/reagent_containers/food/drinks/cans/thirteenloko
	name = "Thirteen Loko"
	desc = "Главный Врач предупредил, что употребление этого напитка может привести к судорогам, слепоте, опьянению или даже смерти. Пожалуйста, пейте осторожно."
	ru_names = list(
		NOMINATIVE = "банка алкогольной газировки \"Тринадцатый Локо\"",
		GENITIVE = "банки алкогольной газировки \"Тринадцатый Локо\"",
		DATIVE = "банке алкогольной газировки \"Тринадцатый Локо\"",
		ACCUSATIVE = "банку алкогольной газировки \"Тринадцатый Локо\"",
		INSTRUMENTAL = "банкой алкогольной газировки \"Тринадцатый Локо\"",
		PREPOSITIONAL = "банке алкогольной газировки \"Тринадцатый Локо\""
 	)
	icon_state = "thirteen_loko"
	list_reagents = list("thirteenloko" = 25, "psilocybin" = 5)

/obj/item/reagent_containers/food/drinks/cans/dr_gibb
	name = "Dr. Gibb"
	desc = "Освежающая смесь из 42 различных вкусов!"
	ru_names = list(
		NOMINATIVE = "банка газировки \"Доктор Гибб\"",
		GENITIVE = "банки газировки \"Доктор Гибб\"",
		DATIVE = "банке газировки \"Доктор Гибб\"",
		ACCUSATIVE = "банку газировки \"Доктор Гибб\"",
		INSTRUMENTAL = "банкой газировки \"Доктор Гибб\"",
		PREPOSITIONAL = "банке газировки \"Доктор Гибб\""
 	)
	icon_state = "dr_gibb"
	list_reagents = list("dr_gibb" = 30)


/obj/item/reagent_containers/food/drinks/cans/starkist
	name = "Star-kist"
	desc = "Вкус звёзд в жидком виде. И тунца..?"
	ru_names = list(
		NOMINATIVE = "банка газировки \"Стар-Кист\"",
		GENITIVE = "банки газировки \"Стар-Кист\"",
		DATIVE = "банке газировки \"Стар-Кист\"",
		ACCUSATIVE = "банку газировки \"Стар-Кист\"",
		INSTRUMENTAL = "банкой газировки \"Стар-Кист\"",
		PREPOSITIONAL = "банке газировки \"Стар-Кист\""
 	)
	icon_state = "starkist"
	list_reagents = list("brownstar" = 30)

/obj/item/reagent_containers/food/drinks/cans/space_up
	name = "Space-Up"
	desc = "На вкус как дыра в обшивке у вас во рту. Да, звучит странно."
	ru_names = list(
		NOMINATIVE = "банка газировки \"Спейс-Ап\"",
		GENITIVE = "банки газировки \"Спейс-Ап\"",
		DATIVE = "банке газировки \"Спейс-Ап\"",
		ACCUSATIVE = "банку газировки \"Спейс-Ап\"",
		INSTRUMENTAL = "банкой газировки \"Спейс-Ап\"",
		PREPOSITIONAL = "банке газировки \"Спейс-Ап\""
 	)
	icon_state = "space-up"
	list_reagents = list("space_up" = 30)

/obj/item/reagent_containers/food/drinks/cans/lemon_lime
	name = "Lemon-Lime"
	desc = "Терпкая газировка, состоящяя на 0,5% из натуральных цитрусовых!"
	ru_names = list(
		NOMINATIVE = "банка газировки \"Лимон-Лайм\"",
		GENITIVE = "банки газировки \"Лимон-Лайм\"",
		DATIVE = "банке газировки \"Лимон-Лайм\"",
		ACCUSATIVE = "банку газировки \"Лимон-Лайм\"",
		INSTRUMENTAL = "банкой газировки \"Лимон-Лайм\"",
		PREPOSITIONAL = "банке газировки \"Лимон-Лайм\""
 	)
	icon_state = "lemon-lime"
	list_reagents = list("lemon_lime" = 30)

/obj/item/reagent_containers/food/drinks/cans/iced_tea
	name = "Vrisk Serket Iced Tea"
	desc = "Этот сладкий, освежающий вкус южной земли. Так вот откуда он, да? Южная Земля, верно?"
	ru_names = list(
		NOMINATIVE = "банка чая со льдом \"Вриск Секретный\"",
		GENITIVE = "банки чая со льдом \"Вриск Секретный\"",
		DATIVE = "банке чая со льдом \"Вриск Секретный\"",
		ACCUSATIVE = "банку чая со льдом \"Вриск Секретный\"",
		INSTRUMENTAL = "банкой чая со льдом \"Вриск Секретный\"",
		PREPOSITIONAL = "банке чая со льдом \"Вриск Секретный\""
 	)
	icon_state = "ice_tea_can"
	list_reagents = list("icetea" = 30)

/obj/item/reagent_containers/food/drinks/cans/grape_juice
	name = "Refreshing Purple Grapel Juice"
	desc = "500 страниц правил о том, как начать драку с этим соком!"
	ru_names = list(
		NOMINATIVE = "банка виноградного сока \"Освежающе-Фиолетовый\"",
		GENITIVE = "банки виноградного сока \"Освежающе-Фиолетовый\"",
		DATIVE = "банке виноградного сока \"Освежающе-Фиолетовый\"",
		ACCUSATIVE = "банку виноградного сока \"Освежающе-Фиолетовый\"",
		INSTRUMENTAL = "банкой виноградного сока \"Освежающе-Фиолетовый\"",
		PREPOSITIONAL = "банке виноградного сока \"Освежающе-Фиолетовый\""
 	)
	icon_state = "purple_can"
	list_reagents = list("grapejuice" = 30)

/obj/item/reagent_containers/food/drinks/cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Вкус странный, но, по крайней мере, хинин держит Космическую Малярию на расстоянии."
	ru_names = list(
		NOMINATIVE = "банка тоника \"Т-Борг\"",
		GENITIVE = "банки тоника \"Т-Борг\"",
		DATIVE = "банке тоника \"Т-Борг\"",
		ACCUSATIVE = "банку тоника \"Т-Борг\"",
		INSTRUMENTAL = "банкой тоника \"Т-Борг\"",
		PREPOSITIONAL = "банке тоника \"Т-Борг\""
 	)
	icon_state = "tonic"
	list_reagents = list("tonic" = 50)

/obj/item/reagent_containers/food/drinks/cans/sodawater
	name = "soda water"
	desc = "Вода с газами. Освежает и приятно щекочет во рту."
	ru_names = list(
		NOMINATIVE = "банка содовой",
		GENITIVE = "банки содовой",
		DATIVE = "банке содовой",
		ACCUSATIVE = "банку содовой",
		INSTRUMENTAL = "банкой содовой",
		PREPOSITIONAL = "банке содовой"
 	)
	icon_state = "sodawater"
	list_reagents = list("sodawater" = 50)

/obj/item/reagent_containers/food/drinks/cans/synthanol
	name = "Beep's Classic Synthanol"
	desc = "Бухло для КПБ. Что бы там не находилось внутри, им нравится."
	ru_names = list(
		NOMINATIVE = "банка синтанола \"Биб Классический\"",
		GENITIVE = "банки синтанола \"Биб Классический\"",
		DATIVE = "банке синтанола \"Биб Классический\"",
		ACCUSATIVE = "банку синтанола \"Биб Классический\"",
		INSTRUMENTAL = "банкой синтанола \"Биб Классический\"",
		PREPOSITIONAL = "банке синтанола \"Биб Классический\""
 	)
	icon_state = "synthanolcan"
	list_reagents = list("synthanol" = 50)

/obj/item/reagent_containers/food/drinks/cans/bottler
	name = "generic beverage container"
	desc = "Это даже не должно быть заспавненным. Позор тебе, педаль."
	ru_names = list(
		NOMINATIVE = "ёмкость для стандартного напитка",
		GENITIVE = "ёмкости для стандартного напитка",
		DATIVE = "ёмкости для стандартного напитка",
		ACCUSATIVE = "ёмкость для стандартного напитка",
		INSTRUMENTAL = "ёмкостью для стандартного напитка",
		PREPOSITIONAL = "ёмкости для стандартного напитка"
 	)
	icon_state = "glass_bottle"


/obj/item/reagent_containers/food/drinks/cans/bottler/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/food/drinks/cans/bottler/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		switch(round(reagents.total_volume))
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 19)
				filling.icon_state = "[icon_state]10"
			if(20 to 29)
				filling.icon_state = "[icon_state]20"
			if(30 to 39)
				filling.icon_state = "[icon_state]30"
			if(40 to 49)
				filling.icon_state = "[icon_state]40"
			if(50 to INFINITY)
				filling.icon_state = "[icon_state]50"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling


/obj/item/reagent_containers/food/drinks/cans/bottler/glass_bottle
	name = "glass bottle"
	desc = "Стеклянная бутылка, подходящая для напитков."
	ru_names = list(
		NOMINATIVE = "стеклянная бутылка",
		GENITIVE = "стеклянной бутылки",
		DATIVE = "стеклянной бутылке",
		ACCUSATIVE = "стеклянную бутылку",
		INSTRUMENTAL = "стеклянной бутылкой",
		PREPOSITIONAL = "стеклянной бутылке"
 	)
	icon_state = "glass_bottle"
	is_glass = 1

/obj/item/reagent_containers/food/drinks/cans/bottler/plastic_bottle
	name = "plastic bottle"
	desc = "Пластиковая бутылка, подходящая для напитков."
	ru_names = list(
		NOMINATIVE = "пластиковая бутылка",
		GENITIVE = "пластиковой бутылки",
		DATIVE = "пластиковой бутылке",
		ACCUSATIVE = "пластиковую бутылку",
		INSTRUMENTAL = "пластиковой бутылкой",
		PREPOSITIONAL = "пластиковой бутылке"
 	)
	icon_state = "plastic_bottle"
	is_plastic = 1

/obj/item/reagent_containers/food/drinks/cans/bottler/metal_can
	name = "metal can"
	desc = "A metal can suitable for beverages."
	ru_names = list(
		NOMINATIVE = "металлическая банка",
		GENITIVE = "металлической банки",
		DATIVE = "металлической банке",
		ACCUSATIVE = "металлическую банку",
		INSTRUMENTAL = "металлической банкой",
		PREPOSITIONAL = "металлической банке"
 	)
	icon_state = "metal_can"
