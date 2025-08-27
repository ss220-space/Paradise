

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	throwforce = 15
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

/obj/item/reagent_containers/food/drinks/bottle/proc/smash(mob/living/target, mob/living/user, ranged = 0)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	var/new_location = get_turf(loc)
	var/obj/item/broken_bottle/B = new /obj/item/broken_bottle(new_location)
	if(ranged)
		B.loc = new_location
	else
		user.drop_from_active_hand(TRUE, TRUE)
		user.put_in_active_hand(B, silent = TRUE)
	B.icon_state = icon_state

	var/icon/I = new('icons/obj/drinks.dmi', icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	if(isGlass)
		if(prob(33))
			new/obj/item/shard(new_location)
		playsound(src, "shatter", 70, 1)
	else
		B.name = "broken carton"
		B.force = 0
		B.throwforce = 0
		B.desc = "Картонная упаковка с разорванным дном. Можно порезаться."
	transfer_fingerprints_to(B)

	qdel(src)


/obj/item/reagent_containers/food/drinks/bottle/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent != INTENT_HARM || !isGlass)
		return ..()

	if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(user, span_warning("Вы не хотите навредить [target]!"))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_BLOCKED_ALL

	force = 15 //Smashing bottles over someoen's head hurts.

	var/obj/item/organ/external/affecting = user.zone_selected //Find what the player is aiming at

	var/armor_block = 0 //Get the target's armor values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	if(ishuman(target))

		var/mob/living/carbon/human/human_target = target
		var/headarmor = 0 // Target's head armor
		armor_block = human_target.run_armor_check(affecting, MELEE,"","",armour_penetration) // For normal attack damage

		//If they have a hat/helmet and the user is targeting their head.
		if(affecting == BODY_ZONE_HEAD && istype(human_target.head, /obj/item/clothing/head))

			// If their head has an armor value, assign headarmor to it, else give it 0.
			var/armor_get = human_target.head.armor.getRating(MELEE)
			if(armor_get)
				headarmor = armor_get
			else
				headarmor = 0
		else
			headarmor = 0

		//Calculate the weakening duration for the target.
		armor_duration = (duration - headarmor) + force

	else
		//Only humans can have armor, right?
		armor_block = target.run_armor_check(affecting, MELEE)
		if(affecting == BODY_ZONE_HEAD)
			armor_duration = duration + force
	armor_duration /= 10

	//Apply the damage!
	armor_block = min(90, armor_block)
	target.apply_damage(force, BRUTE, affecting, armor_block)

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/head_attack_message = ""
	if(affecting == BODY_ZONE_HEAD && iscarbon(target))
		head_attack_message = " по голове"
		//Knockdown the target for the duration that we calculated and divide it by 5.
		if(armor_duration)
			var/knock_time = (min(armor_duration, 10)) STATUS_EFFECT_CONSTANT
			target.Knockdown(knock_time)

	//Display an attack message.
	if(target != user)
		target.visible_message(
			span_danger("[user] ударил[genderize_ru(user.gender,"","а","о","и")] [target][head_attack_message] [declent_ru(INSTRUMENTAL)]!"),
			span_userdanger("[user] ударил[genderize_ru(user.gender,"","а","о","и")] [target][head_attack_message] [declent_ru(INSTRUMENTAL)]!"),
		)
	else
		user.visible_message(
			span_danger("[target] ударил[genderize_ru(target.gender,"","а","о","и")] себя [declent_ru(INSTRUMENTAL)][head_attack_message]!"),
			span_userdanger("[target] ударил[genderize_ru(target.gender,"","а","о","и")] себя [declent_ru(INSTRUMENTAL)][head_attack_message]!"),
		)

	//Attack logs
	add_attack_logs(user, target, "Hit with [src]")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	SplashReagents(target)

	//Finally, smash the bottle. This kills (qdel) the bottle.
	smash(target, user)


/obj/item/reagent_containers/food/drinks/bottle/proc/SplashReagents(mob/M)
	if(reagents && reagents.total_volume)
		M.visible_message(span_danger("Содержимое [src.declent_ru(GENITIVE)] разбрызгивается по [M.declent_ru(PREPOSITIONAL)]!"))
		reagents.reaction(M, REAGENT_TOUCH)
		reagents.clear_reagents()

/obj/item/reagent_containers/food/drinks/bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!reagents.total_volume)
		C.stored_comms["glass"] += 3
		qdel(src)
		return TRUE
	return ..()

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle
	name = "broken bottle"
	desc = "Бутылка с острым побитым дном."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	item_state = "beer"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("уколол", "полоснул", "поранил")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	sharp = 1
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE

/obj/item/broken_bottle/get_ru_names()
	return list(
		NOMINATIVE = "разбитая бутылка",
		GENITIVE = "разбитой бутылки",
		DATIVE = "разбитой бутылке",
		ACCUSATIVE = "разбитую бутылку",
		INSTRUMENTAL = "разбитой бутылкой",
		PREPOSITIONAL = "разбитой бутылке"
	)

/obj/item/broken_bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["glass"] += 3
	qdel(src)
	return TRUE

/obj/item/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "Бутылка высококачественного джина, произведённого в Новом Лондоне."
	icon_state = "ginbottle"
	list_reagents = list("gin" = 100)

/obj/item/reagent_containers/food/drinks/bottle/gin/get_ru_names()
	return list(
		NOMINATIVE = "джин \"Гриффитер\"",
		GENITIVE = "джина \"Гриффитер\"",
		DATIVE = "джину \"Гриффитер\"",
		ACCUSATIVE = "джина \"Гриффитер\"",
		INSTRUMENTAL = "джином \"Гриффитер\"",
		PREPOSITIONAL = "джине \"Гриффитер\""
	)

/obj/item/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "Односолодовый виски премиум-класса, бережно выдержанный в туннелях ядерного бомбоубежища. ТУННЕЛЬНЫЙ ВИСКИ РУЛИТ!"
	icon_state = "whiskeybottle"
	list_reagents = list("whiskey" = 100)

/obj/item/reagent_containers/food/drinks/bottle/whiskey/get_ru_names()
	return list(
		NOMINATIVE = "виски \"Особые Запасы Дяди Гита\"",
		GENITIVE = "виски \"Особые Запасы Дяди Гита\"",
		DATIVE = "виски \"Особые Запасы Дяди Гита\"",
		ACCUSATIVE = "виски \"Особые Запасы Дяди Гита\"",
		INSTRUMENTAL = "виски \"Особые Запасы Дяди Гита\"",
		PREPOSITIONAL = "виски \"Особые Запасы Дяди Гита\""
	)

/obj/item/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Высококачественная водка тройной перегонки, импортированная прямо из СССП."
	icon_state = "vodkabottle"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka/get_ru_names()
	return list(
		NOMINATIVE = "водка \"Тунгуска Тройной Перегонки\"",
		GENITIVE = "водки \"Тунгуска Тройной Перегонки\"",
		DATIVE = "водке \"Тунгуска Тройной Перегонки\"",
		ACCUSATIVE = "водку \"Тунгуска Тройной Перегонки\"",
		INSTRUMENTAL = "водкой \"Тунгуска Тройной Перегонки\"",
		PREPOSITIONAL = "водке \"Тунгуска Тройной Перегонки\""
	)

/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka
	name = "Badminka Vodka"
	desc = "Может и не самая дорогая, но всё ещё пригодная для употребления водка, производимая на окраинах СССП. Чёрт возьми, водка есть водка!"
	icon_state = "badminka"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka/get_ru_names()
	return list(
		NOMINATIVE = "водка \"Бадминка\"",
		GENITIVE = "водки \"Бадминка\"",
		DATIVE = "водке \"Бадминка\"",
		ACCUSATIVE = "водку \"Бадминка\"",
		INSTRUMENTAL = "водкой \"Бадминка\"",
		PREPOSITIONAL = "водке \"Бадминка\""
	)

/obj/item/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Изготовлена из высококачественных нефтяных дистиллятов, чистого талидомида и других высококачественных ингредиентов!"
	icon_state = "tequilabottle"
	list_reagents = list("tequila" = 100)

/obj/item/reagent_containers/food/drinks/bottle/tequila/get_ru_names()
	return list(
		NOMINATIVE = "текила \"Гарантированно Качественная Каккаво\"",
		GENITIVE = "текилы \"Гарантированно Качественная Каккаво\"",
		DATIVE = "текиле \"Гарантированно Качественная Каккаво\"",
		ACCUSATIVE = "текилу \"Гарантированно Качественная Каккаво\"",
		INSTRUMENTAL = "текилой \"Гарантированно Качественная Каккаво\"",
		PREPOSITIONAL = "текиле \"Гарантированно Качественная Каккаво\""
	)

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "Бутылка, наполненная Ничем."
	icon_state = "bottleofnothing"
	list_reagents = list("nothing" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing/get_ru_names()
	return list(
		NOMINATIVE = "бутылка \"Ничего\"",
		GENITIVE = "бутылки \"Ничего\"",
		DATIVE = "бутылке \"Ничего\"",
		ACCUSATIVE = "бутылку \"Ничего\"",
		INSTRUMENTAL = "бутылкой \"Ничего\"",
		PREPOSITIONAL = "бутылке \"Ничего\""
	)

/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana
	name = "Jolly Jug"
	desc = "Кувшин, наполненный банановым соком. Хонк!"
	icon_state = "bottleofjolly"
	list_reagents = list("banana" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana/get_ru_names()
	return list(
		NOMINATIVE = "кувшин бананового сока",
		GENITIVE = "кувшина бананового сока",
		DATIVE = "кувшину бананового сока",
		ACCUSATIVE = "кувшин бананового сока",
		INSTRUMENTAL = "кувшином бананового сока",
		PREPOSITIONAL = "кувшине бананового сока"
	)

/obj/item/reagent_containers/food/drinks/bottle/patron
	name = "Roca Patron Silver"
	desc = "Премиальная текила с серебряным отливом, которую подают в ночных клубах по всей галактике."
	icon_state = "patronbottle"
	list_reagents = list("patron" = 100)

/obj/item/reagent_containers/food/drinks/bottle/patron/get_ru_names()
	return list(
		NOMINATIVE = "текила \"Рока Патрон Сильвер\"",
		GENITIVE = "текилы \"Рока Патрон Сильвер\"",
		DATIVE = "текиле \"Рока Патрон Сильвер\"",
		ACCUSATIVE = "текилу \"Рока Патрон Сильвер\"",
		INSTRUMENTAL = "текилой \"Рока Патрон Сильвер\"",
		PREPOSITIONAL = "текиле \"Рока Патрон Сильвер\""
	)

/obj/item/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "Как сказал однажды мой шкипер: \"Если бледная смерть с трепетным ужасом сделает космическую пустоту нашим последним пристанищем, Бог, слышащий, как клубится тьма космоса, соизволит спасти нашу молящуюся душу\"."
	icon_state = "rumbottle"
	list_reagents = list("rum" = 100)

/obj/item/reagent_containers/food/drinks/bottle/rum/get_ru_names()
	return list(
		NOMINATIVE = "ром \"Кубинский Пряный Капитана Пита\"",
		GENITIVE = "рома \"Кубинский Пряный Капитана Пита\"",
		DATIVE = "рому \"Кубинский Пряный Капитана Пита\"",
		ACCUSATIVE = "ром \"Кубинский Пряный Капитана Пита\"",
		INSTRUMENTAL = "ромом \"Кубинский Пряный Капитана Пита\"",
		PREPOSITIONAL = "роме \"Кубинский Пряный Капитана Пита\""
	)

/obj/item/reagent_containers/food/drinks/bottle/holywater
	name = "flask of holy water"
	desc = "Кувшин со святой водой, такие обычно стоят в церквях."
	icon_state = "holyflask"
	list_reagents = list("holywater" = 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater/get_ru_names()
	return list(
		NOMINATIVE = "кувшин святой воды",
		GENITIVE = "кувшина святой воды",
		DATIVE = "кувшину святой воды",
		ACCUSATIVE = "кувшин святой воды",
		INSTRUMENTAL = "кувшином святой воды",
		PREPOSITIONAL = "кувшине святой воды"
	)

/obj/item/reagent_containers/food/drinks/bottle/holywater/hell
	desc = "Кувшин со святой водой... который пробыл в чреве Некрополя слишком долго."
	list_reagents = list("hell_water" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Сладкая, сладкая сухость..."
	icon_state = "vermouthbottle"
	list_reagents = list("vermouth" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vermouth/get_ru_names()
	return list(
		NOMINATIVE = "вермут \"Золотой Глаз\"",
		GENITIVE = "вермута \"Золотой Глаз\"",
		DATIVE = "вермуту \"Золотой Глаз\"",
		ACCUSATIVE = "вермут \"Золотой Глаз\"",
		INSTRUMENTAL = "вермутом \"Золотой Глаз\"",
		PREPOSITIONAL = "вермуте \"Золотой Глаз\""
	)

/obj/item/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "Широко известный мексиканский ликёр \"Калуа\" со вкусом кофе. Производится с 1936 года."
	icon_state = "kahluabottle"
	list_reagents = list("kahlua" = 100)

/obj/item/reagent_containers/food/drinks/bottle/kahlua/get_ru_names()
	return list(
		NOMINATIVE = "ликёр \"Роберт Робаст\"",
		GENITIVE = "ликёра \"Роберт Робаст\"",
		DATIVE = "ликёру \"Роберт Робаст\"",
		ACCUSATIVE = "ликёр \"Роберт Робаст\"",
		INSTRUMENTAL = "ликёром \"Роберт Робаст\"",
		PREPOSITIONAL = "ликёре \"Роберт Робаст\""
	)

/obj/item/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Потому что они единственные, кто будет пить шнапс с корицей 100%-ой пробы."
	icon_state = "goldschlagerbottle"
	list_reagents = list("goldschlager" = 100)

/obj/item/reagent_containers/food/drinks/bottle/goldschlager/get_ru_names()
	return list(
		NOMINATIVE = "шнапс \"Голдшлягер Студенческий\"",
		GENITIVE = "шнапса \"Голдшлягер Студенческий\"",
		DATIVE = "шнапсу \"Голдшлягер Студенческий\"",
		ACCUSATIVE = "шнапс \"Голдшлягер Студенческий\"",
		INSTRUMENTAL = "шнапсом \"Голдшлягер Студенческий\"",
		PREPOSITIONAL = "шнапсе \"Голдшлягер Студенческий\""
	)

/obj/item/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "Коньяк премиального качества, изготовленный путём многочисленных дистилляций и многолетней выдержки."
	icon_state = "cognacbottle"
	list_reagents = list("cognac" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cognac/get_ru_names()
	return list(
		NOMINATIVE = "коньяк \"Шато Дэ Батон\"",
		GENITIVE = "коньяка \"Шато Дэ Батон\"",
		DATIVE = "коньяку \"Шато Дэ Батон\"",
		ACCUSATIVE = "коньяк \"Шато Дэ Батон\"",
		INSTRUMENTAL = "коньяком \"Шато Дэ Батон\"",
		PREPOSITIONAL = "коньяке \"Шато Дэ Батон\""
	)

/obj/item/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "Слабая аура беспокойства и боли в заднице окружает эту бутылку."
	icon_state = "winebottle"
	list_reagents = list("wine" = 100)


/obj/item/reagent_containers/food/drinks/bottle/wine/get_ru_names()
	return list(
		NOMINATIVE = "вино \"Особое Двухбородое\"",
		GENITIVE = "вина \"Особое Двухбородое\"",
		DATIVE = "вину \"Особое Двухбородое\"",
		ACCUSATIVE = "вино \"Особое Двухбородое\"",
		INSTRUMENTAL = "вином \"Особое Двухбородое\"",
		PREPOSITIONAL = "вине \"Особое Двухбородое\""
	)

/obj/item/reagent_containers/food/drinks/bottle/absinthe
	name = "Yellow Marquee Absinthe"
	desc = "Крепкий алкогольный напиток, сваренный и распространяемый компанией \"Жёлтый Шатёр\"."
	icon_state = "absinthebottle"
	list_reagents = list("absinthe" = 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe/get_ru_names()
	return list(
		NOMINATIVE = "абсент \"Жёлтый Шахтёр\"",
		GENITIVE = "абсента \"Жёлтый Шахтёр\"",
		DATIVE = "абсенту \"Жёлтый Шахтёр\"",
		ACCUSATIVE = "абсент \"Жёлтый Шахтёр\"",
		INSTRUMENTAL = "абсентом \"Жёлтый Шахтёр\"",
		PREPOSITIONAL = "абсенте \"Жёлтый Шахтёр\""
	)

/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium
	name = "Gwyn's Premium Absinthe"
	desc = "Крепкий алкогольный напиток, почти заставляющий забыть о пепле в лёгких."
	icon_state = "absinthepremium"

/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium/get_ru_names()
	return list(
		NOMINATIVE = "абсент \"Премиальный от Гвена\"",
		GENITIVE = "абсента \"Премиальный от Гвена\"",
		DATIVE = "абсенту \"Премиальный от Гвена\"",
		ACCUSATIVE = "абсент \"Премиальный от Гвена\"",
		INSTRUMENTAL = "абсентом \"Премиальный от Гвена\"",
		PREPOSITIONAL = "абсенте \"Премиальный от Гвена\""
	)

/obj/item/reagent_containers/food/drinks/bottle/hcider
	name = "Jian Hard Cider"
	desc = "Яблочный сок для взрослых."
	icon_state = "hcider"
	volume = 50
	list_reagents = list("suicider" = 50)

/obj/item/reagent_containers/food/drinks/bottle/hcider/get_ru_names()
	return list(
		NOMINATIVE = "сидр \"Цзянь Крепкий\"",
		GENITIVE = "сидра \"Цзянь Крепкий\"",
		DATIVE = "сидру \"Цзянь Крепкий\"",
		ACCUSATIVE = "сидр \"Цзянь Крепкий\"",
		INSTRUMENTAL = "сидром \"Цзянь Крепкий\"",
		PREPOSITIONAL = "сидре \"Цзянь Крепкий\""
	)

/obj/item/reagent_containers/food/drinks/bottle/fernet
	name = "Fernet Bronca"
	desc = "Бутылка фернета, произведенного на космической станции \"Кордоба\"."
	icon_state = "fernetbottle"
	list_reagents = list("fernet" = 100)

/obj/item/reagent_containers/food/drinks/bottle/fernet/get_ru_names()	
	return list(
		NOMINATIVE = "фернет \"Фернет Бронка\"",
		GENITIVE = "фернета \"Фернет Бронка\"",
		DATIVE = "фернету \"Фернет Бронка\"",
		ACCUSATIVE = "фернет \"Фернет Бронка\"",
		INSTRUMENTAL = "фернетом \"Фернет Бронка\"",
		PREPOSITIONAL = "фернете \"Фернет Бронка\""
	)

/obj/item/reagent_containers/food/drinks/bottle/champagne
	name = "Sparkling Sunny Champagne"
	desc = "Бутылка чистого обжигающего солнца, готовая поразить ваш мозг."
	icon_state = "champagnebottle"
	list_reagents = list("champagne" = 100)

/obj/item/reagent_containers/food/drinks/bottle/champagne/get_ru_names()
	return list(
		NOMINATIVE = "шампанское \"Сверкающее Солнце\"",
		GENITIVE = "шампанского \"Сверкающее Солнце\"",
		DATIVE = "шампанскому \"Сверкающее Солнце\"",
		ACCUSATIVE = "шампанское \"Сверкающее Солнце\"",
		INSTRUMENTAL = "шампанским \"Сверкающее Солнце\"",
		PREPOSITIONAL = "шампанском \"Сверкающее Солнце\""
	)

/obj/item/reagent_containers/food/drinks/bottle/aperol
	name = "Jungle Aperol Aperitivo"
	desc = "Настоящая засажа для вашей печени."
	icon_state = "aperolbottle"
	list_reagents = list("aperol" = 100)

/obj/item/reagent_containers/food/drinks/bottle/aperol/get_ru_names()
	return list(
		NOMINATIVE = "апероль \"Джунгли Аперитив\"",
		GENITIVE = "апероля \"Джунгли Аперитив\"",
		DATIVE = "аперолю \"Джунгли Аперитив\"",
		ACCUSATIVE = "апероль \"Джунгли Аперитив\"",
		INSTRUMENTAL = "аперолем \"Джунгли Аперитив\"",
		PREPOSITIONAL = "апероле \"Джунгли Аперитив\""
	)

/obj/item/reagent_containers/food/drinks/bottle/jagermeister
	name = "Infused Space Jaegermeister"
	desc = "Das ist des Jägers Ehrenschild, daß er beschützt und hegt sein Wild, weidmännisch jagt, wie sich gehört, den Schöpfer im Geschöpfe ehrt."
	icon_state = "jagermeisterbottle"
	list_reagents = list("jagermeister" = 100)

/obj/item/reagent_containers/food/drinks/bottle/jagermeister/get_ru_names()
	return list(
		NOMINATIVE = "ягермейстер \"Космически Настоенный\"",
		GENITIVE = "ягермейстера \"Космически Настоенный\"",
		DATIVE = "ягермейстеру \"Космически Настоенный\"",
		ACCUSATIVE = "ягермейстер \"Космически Настоенный\"",
		INSTRUMENTAL = "ягермейстером \"Космически Настоенный\"",
		PREPOSITIONAL = "ягермастере \"Космически Настоенный\""
	)

/obj/item/reagent_containers/food/drinks/bottle/schnaps
	name = "Grainy Mint Schnapps"
	desc = "Настоящий ужас для истинного ценителя, высококачественный мятный шнапс."
	icon_state = "schnapsbottle"
	list_reagents = list("schnaps" = 100)

/obj/item/reagent_containers/food/drinks/bottle/schnaps/get_ru_names()
	return list(
		NOMINATIVE = "шнапс \"Мятный Зерновой\"",
		GENITIVE = "шнапса \"Мятный Зерновой\"",
		DATIVE = "шнапсу \"Мятный Зерновой\"",
		ACCUSATIVE = "шнапс \"Мятный Зерновой\"",
		INSTRUMENTAL = "шнапсом \"Мятный Зерновой\"",
		PREPOSITIONAL = "шнапсе \"Мятный Зерновой\""
	)

/obj/item/reagent_containers/food/drinks/bottle/sheridan
	name = "Sheridan's Coffee Layered"
	desc = "Двойное чудо с новой инновационной шеей, намного лучше, чем у вас."
	icon_state = "sheridanbottle"
	list_reagents = list("sheridan" = 100)

/obj/item/reagent_containers/food/drinks/bottle/sheridan/get_ru_names()
	return list(
		NOMINATIVE = "ликёр \"Шериданс Кофейный\"",
		GENITIVE = "ликёра \"Шериданс Кофейный\"",
		DATIVE = "ликёру \"Шериданс Кофейный\"",
		ACCUSATIVE = "ликёр \"Шериданс Кофейный\"",
		INSTRUMENTAL = "ликёром \"Шериданс Кофейный\"",
		PREPOSITIONAL = "ликёре \"Шериданс Кофейный\""
	)

/obj/item/reagent_containers/food/drinks/bottle/bitter
	name = "Vacuum Cherry Bitter"
	desc = "Постарайтесь не задохнуться, выпив такую чудесную горечь."
	icon_state = "bitterbottle"
	list_reagents = list("bitter" = 50)

/obj/item/reagent_containers/food/drinks/bottle/bitter/get_ru_names()
	return list(
		NOMINATIVE = "битер \"Вакуумный Вишнёвый\"",
		GENITIVE = "битера \"Вакуумный Вишнёвый\"",
		DATIVE = "битеру \"Вакуумный Вишнёвый\"",
		ACCUSATIVE = "битер \"Вакуумный Вишнёвый\"",
		INSTRUMENTAL = "битером \"Вакуумный Вишнёвый\"",
		PREPOSITIONAL = "битере \"Вакуумный Вишнёвый\""
	)

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Grenadier Blue Curacao"
	desc = "Взрыв - это искусство, но синий взрыв намного лучше."
	icon_state = "bluecuracao"
	list_reagents = list("bluecuracao" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao/get_ru_names()
	return list(
		NOMINATIVE = "кюрасао \"Гренадёрский Синий\"",
		GENITIVE = "кюрасао \"Гренадёрский Синий\"",
		DATIVE = "кюрасао \"Гренадёрский Синий\"",
		ACCUSATIVE = "кюрасао \"Гренадёрский Синий\"",
		INSTRUMENTAL = "кюрасао \"Гренадёрский Синий\"",
		PREPOSITIONAL = "кюрасао \"Гренадёрский Синий\""
	)

/obj/item/reagent_containers/food/drinks/bottle/sambuka
	name = "The Headless Horseman's Sambuka"
	desc = "Я не пил самбуку с тех пор, как мне было двадцать."
	icon_state = "sambukabottle"
	list_reagents = list("sambuka" = 100)

/obj/item/reagent_containers/food/drinks/bottle/sambuka/get_ru_names()
	return list(
		NOMINATIVE = "самбука \"Безголовый Всадник\"",
		GENITIVE = "самбуки \"Безголовый Всадник\"",
		DATIVE = "самбуке \"Безголовый Всадник\"",
		ACCUSATIVE = "самбуку \"Безголовый Всадник\"",
		INSTRUMENTAL = "самбукой \"Безголовый Всадник\"",
		PREPOSITIONAL = "самбуке \"Безголовый Всадник\""
	)

/obj/item/reagent_containers/food/drinks/bottle/arrogant_green_rat
	name = "Arrogant Green Rat"
	desc = "Лучшее вино из райского города, где трава зелёная, а девушки красивые."
	icon_state = "arrogant_green_rat"
	list_reagents = list("wine" = 100)

/obj/item/reagent_containers/food/drinks/bottle/arrogant_green_rat/get_ru_names()
	return list(
		NOMINATIVE = "вино \"Высокомерная Зелёная Крыса\"",
		GENITIVE = "вина \"Высокомерная Зелёная Крыса\"",
		DATIVE = "вину \"Высокомерная Зелёная Крыса\"",
		ACCUSATIVE = "вино \"Высокомерная Зелёная Крыса\"",
		INSTRUMENTAL = "вином \"Высокомерная Зелёная Крыса\"",
		PREPOSITIONAL = "вине \"Высокомерная Зелёная Крыса\""
	)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/orangejuice
	name = "orange juice"
	desc = "Полон витаминов и вкусностей!"
	icon_state = "orangejuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("orangejuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/orangejuice/get_ru_names()
	return list(
		NOMINATIVE = "пачка апельсинового сока",
		GENITIVE = "пачки апельсинового сока",
		DATIVE = "пачке апельсинового сока",
		ACCUSATIVE = "пачку апельсинового сока",
		INSTRUMENTAL = "пачкой апельсинового сока",
		PREPOSITIONAL = "пачке апельсинового сока"
	)

/obj/item/reagent_containers/food/drinks/bottle/cream
	name = "milk cream"
	desc = "Это сливки. Сделаны из молока. А что ещё вы думали там найти?"
	icon_state = "cream"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("cream" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cream/get_ru_names()
	return list(
		NOMINATIVE = "пачка сливок",
		GENITIVE = "пачки сливок",
		DATIVE = "пачке сливок",
		ACCUSATIVE = "пачку сливок",
		INSTRUMENTAL = "пачкой сливок",
		PREPOSITIONAL = "пачке сливок"
	)

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	name = "tomato juice"
	desc = "Ну, по крайней мере, это выглядит как томатный сок. Слишком красное, чтобы сказать точно."
	icon_state = "tomatojuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("tomatojuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice/get_ru_names()
	return list(
		NOMINATIVE = "пачка томатного сока",
		GENITIVE = "пачки томатного сока",
		DATIVE = "пачке томатного сока",
		ACCUSATIVE = "пачку томатного сока",
		INSTRUMENTAL = "пачкой томатного сока",
		PREPOSITIONAL = "пачке томатного сока"
	)

/obj/item/reagent_containers/food/drinks/bottle/limejuice
	name = "lime juice"
	desc = "Кисло-сладкая вкуснятина."
	icon_state = "limejuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("limejuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/limejuice/get_ru_names()
	return list(
		NOMINATIVE = "пачка лаймового сока",
		GENITIVE = "пачки лаймового сока",
		DATIVE = "пачке лаймового сока",
		ACCUSATIVE = "пачку лаймового сока",
		INSTRUMENTAL = "пачкой лаймового сока",
		PREPOSITIONAL = "пачке лаймового сока"
	)

/obj/item/reagent_containers/food/drinks/bottle/milk
	name = "milk"
	desc = "Мягкое, вкусно и полезное молоко."
	icon_state = "milk"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("milk" = 100)

/obj/item/reagent_containers/food/drinks/bottle/milk/get_ru_names()
	return list(
		NOMINATIVE = "пачка молока",
		GENITIVE = "пачки молока",
		DATIVE = "пачке молока",
		ACCUSATIVE = "пачку молока",
		INSTRUMENTAL = "пачкой молока",
		PREPOSITIONAL = "пачке молока"
	)

////////////////////////// MOLOTOV ///////////////////////
/obj/item/reagent_containers/food/drinks/bottle/molotov
	name = "molotov cocktail"
	desc = "Бутылка с зажигательной смесью. Обязательный элемент экипировки любого бунтаря или революционера. Поджигайте и бросайте."
	icon_state = "vodkabottle"
	list_reagents = list()
	var/static/list/accelerants = list(
										/datum/reagent/consumable/ethanol,
										/datum/reagent/fuel,
										/datum/reagent/clf3,
										/datum/reagent/phlogiston,
										/datum/reagent/napalm,
										/datum/reagent/hellwater,
										/datum/reagent/plasma,
										/datum/reagent/plasma_dust
									)
	var/active = FALSE

/obj/item/reagent_containers/food/drinks/bottle/molotov/get_ru_names()
	return list(
		NOMINATIVE = "коктейль Молотова",
		GENITIVE = "коктейля Молотова",
		DATIVE = "коктейлю Молотова",
		ACCUSATIVE = "коктейль Молотова",
		INSTRUMENTAL = "коктейлем Молотова",
		PREPOSITIONAL = "коктейле Молотова"
	)


/obj/item/reagent_containers/food/drinks/bottle/molotov/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)
	if(!isGlass)
		desc += " Вы не уверены, что сделать это из коробки было самой удачной идеей."


/obj/item/reagent_containers/food/drinks/bottle/molotov/update_icon_state()
	var/obj/item/reagent_containers/food/drinks/bottle/bottle = locate() in contents
	if(bottle)
		icon_state = bottle.icon_state


/obj/item/reagent_containers/food/drinks/bottle/molotov/update_overlays()
	. = ..()
	if(active)
		. += GLOB.fire_overlay


/obj/item/reagent_containers/food/drinks/bottle/molotov/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/food/drinks/bottle/bottle = locate() in contents
	if(bottle)
		bottle.reagents.copy_to(src, 100)
		if(!bottle.isGlass)
			isGlass = FALSE
		update_appearance(UPDATE_DESC|UPDATE_ICON)


/obj/item/reagent_containers/food/drinks/bottle/molotov/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	var/firestarter = 0
	for(var/datum/reagent/R in reagents.reagent_list)
		for(var/A in accelerants)
			if(istype(R, A))
				firestarter = 1
				break
	SplashReagents(target)
	if(firestarter && active)
		target.fire_act()
		new /obj/effect/hotspot(get_turf(target))
	..()


/obj/item/reagent_containers/food/drinks/bottle/molotov/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !I.get_heat())
		return .

	add_fingerprint(user)
	if(active)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] уже горит."))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	active = TRUE
	var/turf/bombturf = get_turf(src)
	message_admins("[ADMIN_LOOKUP(user)] has primed a [name] for detonation at [ADMIN_COORDJMP(bombturf)].")
	add_game_logs("has primed a [name] for detonation at [AREACOORD(bombturf)].", user)
	user.visible_message(
		span_danger("[user] поджигает [src.declent_ru(ACCUSATIVE)]!"),
		span_notice("Вы поджигаете [src.declent_ru(ACCUSATIVE)]."),
	)
	add_overlay(GLOB.fire_overlay)
	if(!isGlass)
		addtimer(CALLBACK(src, PROC_REF(splash_reagents), 5 SECONDS))


/obj/item/reagent_containers/food/drinks/bottle/molotov/proc/splash_reagents()
	if(!active)
		return
	var/counter
	var/atom/target = loc
	for(counter = 0, counter < 2, counter++)
		if(isstorage(target))
			var/obj/item/storage/storage = target
			target = storage.loc
	if(isatom(target))
		SplashReagents(target)
		target.fire_act()
	qdel(src)


/obj/item/reagent_containers/food/drinks/bottle/molotov/attack_self(mob/user)
	if(active)
		if(!isGlass)
			to_chat(user, span_danger("Пламя распространилось уже слишком далеко!"))
			return
		to_chat(user, span_notice("Вы гасите пламя у [src.declent_ru(GENITIVE)]."))
		active = FALSE
		update_icon(UPDATE_OVERLAYS)
