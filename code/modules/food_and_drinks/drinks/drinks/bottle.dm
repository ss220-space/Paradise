

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
		B.desc = "A carton with the bottom half burst open. Might give you a papercut."
	transfer_fingerprints_to(B)

	qdel(src)


/obj/item/reagent_containers/food/drinks/bottle/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent != INTENT_HARM || !isGlass)
		return ..()

	if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(user, span_warning("You don't want to harm [target]!"))
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
		head_attack_message = " on the head"
		//Knockdown the target for the duration that we calculated and divide it by 5.
		if(armor_duration)
			var/knock_time = (min(armor_duration, 10)) STATUS_EFFECT_CONSTANT
			target.Knockdown(knock_time)

	//Display an attack message.
	if(target != user)
		target.visible_message(
			span_danger("[user] has hit [target][head_attack_message] with a bottle of [name]!"),
			span_userdanger("[user] has hit [target][head_attack_message] with a bottle of [name]!"),
		)
	else
		user.visible_message(
			span_danger("[target] hits [target.p_them()]self with a bottle of [name][head_attack_message]!"),
			span_userdanger("[target] hits [target.p_them()]self with a bottle of [name][head_attack_message]!"),
		)

	//Attack logs
	add_attack_logs(user, target, "Hit with [src]")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	SplashReagents(target)

	//Finally, smash the bottle. This kills (qdel) the bottle.
	smash(target, user)


/obj/item/reagent_containers/food/drinks/bottle/proc/SplashReagents(mob/M)
	if(reagents && reagents.total_volume)
		M.visible_message("<span class='danger'>The contents of \the [src] splashes all over [M]!</span>")
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
	ru_names = list(
		NOMINATIVE = "разбитая бутылка",
		GENITIVE = "разбитой бутылки",
		DATIVE = "разбитой бутылке",
		ACCUSATIVE = "разбитую бутылку",
		INSTRUMENTAL = "разбитой бутылкой",
		PREPOSITIONAL = "разбитой бутылке"
 	)
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

/obj/item/broken_bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["glass"] += 3
	qdel(src)
	return TRUE

/obj/item/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "Бутылка высококачественного джина, произведённого в Новом Лондоне."
	ru_names = list(
		NOMINATIVE = "бутылка джина \"Гриффитер\"",
		GENITIVE = "бутылки джина \"Гриффитер\"",
		DATIVE = "бутылке джина \"Гриффитер\"",
		ACCUSATIVE = "бутылку джина \"Гриффитер\"",
		INSTRUMENTAL = "бутылкой джина \"Гриффитер\"",
		PREPOSITIONAL = "бутылке джина \"Гриффитер\""
 	)
	icon_state = "ginbottle"
	list_reagents = list("gin" = 100)

/obj/item/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "Односолодовый виски премиум-класса, бережно выдержанный в туннелях ядерного бомбоубежища. ТУННЕЛЬНЫЙ ВИСКИ РУЛИТ."
	ru_names = list(
		NOMINATIVE = "бутылка виски \"Особые Запасы Дяди Гита\"",
		GENITIVE = "бутылки виски \"Особые Запасы Дяди Гита\"",
		DATIVE = "бутылке виски \"Особые Запасы Дяди Гита\"",
		ACCUSATIVE = "бутылку виски \"Особые Запасы Дяди Гита\"",
		INSTRUMENTAL = "бутылкой виски \"Особые Запасы Дяди Гита\"",
		PREPOSITIONAL = "бутылке виски \"Особые Запасы Дяди Гита\""
 	)
	icon_state = "whiskeybottle"
	list_reagents = list("whiskey" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Высококачественная водка тройной перегонки, импортированная прямо из СССП."
	ru_names = list(
		NOMINATIVE = "бутылка водки \"Тунгуска Тройной Перегонки\"",
		GENITIVE = "бутылки водки \"Тунгуска Тройной Перегонки\"",
		DATIVE = "бутылке водки \"Тунгуска Тройной Перегонки\"",
		ACCUSATIVE = "бутылку водки \"Тунгуска Тройной Перегонки\"",
		INSTRUMENTAL = "бутылкой водки \"Тунгуска Тройной Перегонки\"",
		PREPOSITIONAL = "бутылке водки \"Тунгуска Тройной Перегонки\""
 	)
	icon_state = "vodkabottle"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka
	name = "Badminka Vodka"
	desc = "Может и не самая дорогая, но всё ещё пригодная для употребления водка, производимая на окраинах СССП. Чёрт возьми, водка есть водка!"
	ru_names = list(
		NOMINATIVE = "бутылка водки \"Бадминка\"",
		GENITIVE = "бутылки водки \"Бадминка\"",
		DATIVE = "бутылке водки \"Бадминка\"",
		ACCUSATIVE = "бутылку водки \"Бадминка\"",
		INSTRUMENTAL = "бутылкой водки \"Бадминка\"",
		PREPOSITIONAL = "бутылке водки \"Бадминка\""
 	)
	icon_state = "badminka"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Изготовлена из высококачественных нефтяных дистиллятов, чистого талидомида и других высококачественных ингредиентов!"
	ru_names = list(
		NOMINATIVE = "бутылка текилы \"Гарантированно Качественная Текила Каккаво\"",
		GENITIVE = "бутылки текилы \"Гарантированно Качественная Текила Каккаво\"",
		DATIVE = "бутылке текилы \"Гарантированно Качественная Текила Каккаво\"",
		ACCUSATIVE = "бутылку текилы \"Гарантированно Качественная Текила Каккаво\"",
		INSTRUMENTAL = "бутылкой текилы \"Гарантированно Качественная Текила Каккаво\"",
		PREPOSITIONAL = "бутылке текилы \"Гарантированно Качественная Текила Каккаво\""
 	)
	icon_state = "tequilabottle"
	list_reagents = list("tequila" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "Бутылка, наполненная ничем."
	ru_names = list(
		NOMINATIVE = "бутылка \"Ничего\"",
		GENITIVE = "бутылки \"Ничего\"",
		DATIVE = "бутылке \"Ничего\"",
		ACCUSATIVE = "бутылку \"Ничего\"",
		INSTRUMENTAL = "бутылкой \"Ничего\"",
		PREPOSITIONAL = "бутылке \"Ничего\""
 	)
	icon_state = "bottleofnothing"
	list_reagents = list("nothing" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana
	name = "Jolly Jug"
	desc = "Кувшин, наполненный банановым соком. Хонк!"
	ru_names = list(
		NOMINATIVE = "кувшин бананового сока",
		GENITIVE = "кувшина бананового сока",
		DATIVE = "кувшину бананового сока",
		ACCUSATIVE = "кувшин бананового сока",
		INSTRUMENTAL = "кувшином бананового сока",
		PREPOSITIONAL = "кувшине бананового сока"
 	)
	icon_state = "bottleofjolly"
	list_reagents = list("banana" = 100)

/obj/item/reagent_containers/food/drinks/bottle/patron
	name = "Roca Patron Silver"
	desc = "Премиальная текила с серебряным отливом, которую подают в ночных клубах по всей галактике."
	ru_names = list(
		NOMINATIVE = "бутылка текилы \"Рока Патрон Сильвер\"",
		GENITIVE = "бутылки текилы \"Рока Патрон Сильвер\"",
		DATIVE = "бутылке текилы \"Рока Патрон Сильвер\"",
		ACCUSATIVE = "бутылку текилы \"Рока Патрон Сильвер\"",
		INSTRUMENTAL = "бутылкой текилы \"Рока Патрон Сильвер\"",
		PREPOSITIONAL = "бутылке текилы \"Рока Патрон Сильвер\""
 	)
	icon_state = "patronbottle"
	list_reagents = list("patron" = 100)

/obj/item/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "Как сказал однажды мой шкипер: \"Если бледная смерть с трепетным ужасом сделает космическую пустоту нашим последним пристанищем, Бог, слышащий, как клубится тьма космоса, соизволит спасти нашу молящуюся душу\"."
	ru_names = list(
		NOMINATIVE = "бутылка рома \"Кубинский Пряный Ром Капитана Пита\"",
		GENITIVE = "бутылки рома \"Кубинский Пряный Ром Капитана Пита\"",
		DATIVE = "бутылке рома \"Кубинский Пряный Ром Капитана Пита\"",
		ACCUSATIVE = "бутылку рома \"Кубинский Пряный Ром Капитана Пита\"",
		INSTRUMENTAL = "бутылкой рома \"Кубинский Пряный Ром Капитана Пита\"",
		PREPOSITIONAL = "бутылке рома\"Кубинский Пряный Ром Капитана Пита\""
 	)
	icon_state = "rumbottle"
	list_reagents = list("rum" = 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater
	name = "flask of holy water"
	desc = "Кувшин со святой водой, такие обычно стоят в церквях."
	ru_names = list(
		NOMINATIVE = "кувшин святой воды",
		GENITIVE = "кувшина святой воды",
		DATIVE = "кувшину святой воды",
		ACCUSATIVE = "кувшин святой воды",
		INSTRUMENTAL = "кувшином святой воды",
		PREPOSITIONAL = "кувшине святой воды"
 	)
	icon_state = "holyflask"
	list_reagents = list("holywater" = 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater/hell
	desc = "Кувшин со святой водой... который пробыл в чреве Некрополя слишком долго."
	list_reagents = list("hell_water" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Сладкая, сладкая сухость..."
	ru_names = list(
		NOMINATIVE = "бутылка вермута \"Золотой Глаз\"",
		GENITIVE = "бутылки вермута \"Золотой Глаз\"",
		DATIVE = "бутылке вермута \"Золотой Глаз\"",
		ACCUSATIVE = "бутылку вермута \"Золотой Глаз\"",
		INSTRUMENTAL = "бутылкой вермута \"Золотой Глаз\"",
		PREPOSITIONAL = "бутылке вермута \"Золотой Глаз\""
 	)
	icon_state = "vermouthbottle"
	list_reagents = list("vermouth" = 100)

/obj/item/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "Широко известный мексиканский ликёр со вкусом кофе. Производится с 1936 года."
	ru_names = list(
		NOMINATIVE = "бутылка ликёра Калуа \"Кофейный ликёр Роберта Робаста\"",
		GENITIVE = "бутылки ликёра Калуа \"Кофейный ликёр Роберта Робаста\"",
		DATIVE = "бутылке ликёра Калуа \"Кофейный ликёр Роберта Робаста\"",
		ACCUSATIVE = "бутылку ликёра Калуа \"Кофейный ликёр Роберта Робаста\"",
		INSTRUMENTAL = "бутылкой ликёра Калуа \"Кофейный ликёр Роберта Робаста\"",
		PREPOSITIONAL = "бутылке ликёра Калуа \"Кофейный ликёр Роберта Робаста\""
 	)
	icon_state = "kahluabottle"
	list_reagents = list("kahlua" = 100)

/obj/item/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Потому что они единственные, кто будет пить шнапс с корицей 100%-ой пробы."
	ru_names = list(
		NOMINATIVE = "бутылка шнапса \"Голдшлягер Студенческий\"",
		GENITIVE = "бутылки шнапса \"Голдшлягер Студенческий\"",
		DATIVE = "бутылке шнапса \"Голдшлягер Студенческий\"",
		ACCUSATIVE = "бутылку шнапса \"Голдшлягер Студенческий\"",
		INSTRUMENTAL = "бутылкой шнапса \"Голдшлягер Студенческий\"",
		PREPOSITIONAL = "бутылке шнапса \"Голдшлягер Студенческий\""
 	)
	icon_state = "goldschlagerbottle"
	list_reagents = list("goldschlager" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "Коньяк премиального качества, изготовленный путём многочисленных дистилляций и многолетней выдержки."
	ru_names = list(
		NOMINATIVE = "бутылка коньяка \"Шато Дэ Батон\"",
		GENITIVE = "бутылки коньяка \"Шато Дэ Батон\"",
		DATIVE = "бутылке коньяка \"Шато Дэ Батон\"",
		ACCUSATIVE = "бутылку коньяка \"Шато Дэ Батон\"",
		INSTRUMENTAL = "бутылкой коньяка \"Шато Дэ Батон\"",
		PREPOSITIONAL = "бутылке коньяка \"Шато Дэ Батон\""
 	)
	icon_state = "cognacbottle"
	list_reagents = list("cognac" = 100)

/obj/item/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "Слабая аура беспокойства и боли в заднице окружает эту бутылку."
	ru_names = list(
		NOMINATIVE = "бутылка вина \"Особое Двухбородое\"",
		GENITIVE = "бутылки вина \"Особое Двухбородое\"",
		DATIVE = "бутылке вина \"Особое Двухбородое\"",
		ACCUSATIVE = "бутылку вина \"Особое Двухбородое\"",
		INSTRUMENTAL = "бутылкой вина \"Особое Двухбородое\"",
		PREPOSITIONAL = "бутылке вина \"Особое Двухбородое\""
 	)
	icon_state = "winebottle"
	list_reagents = list("wine" = 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe
	name = "Yellow Marquee Absinthe"
	desc = "Крепкий алкогольный напиток, сваренный и распространяемый компанией \"Жёлтый Шатёр\"."
	ru_names = list(
		NOMINATIVE = "бутылка абсента \"Жёлтый Шатёр\"",
		GENITIVE = "бутылки абсента \"Жёлтый Шатёр\"",
		DATIVE = "бутылке абсента \"Жёлтый Шатёр\"",
		ACCUSATIVE = "бутылку абсента \"Жёлтый Шатёр\"",
		INSTRUMENTAL = "бутылкой абсента \"Жёлтый Шатёр\"",
		PREPOSITIONAL = "бутылке абсента \"Жёлтый Шатёр\""
 	)
	icon_state = "absinthebottle"
	list_reagents = list("absinthe" = 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium
	name = "Gwyn's Premium Absinthe"
	desc = "Крепкий алкогольный напиток, почти заставляющий забыть о пепле в лёгких."
	ru_names = list(
		NOMINATIVE = "бутылка абсента \"Премиальный Абсент Гвена\"",
		GENITIVE = "бутылки абсента \"Премиальный Абсент Гвена\"",
		DATIVE = "бутылке абсента \"Премиальный Абсент Гвена\"",
		ACCUSATIVE = "бутылку абсента \"Премиальный Абсент Гвена\"",
		INSTRUMENTAL = "бутылкой абсента \"Премиальный Абсент Гвена\"",
		PREPOSITIONAL = "бутылке абсента \"Премиальный Абсент Гвена\""
 	)
	icon_state = "absinthepremium"

/obj/item/reagent_containers/food/drinks/bottle/hcider
	name = "Jian Hard Cider"
	desc = "Яблочный сок для взрослых."
	ru_names = list(
		NOMINATIVE = "бутылка сидра \"Цзянь Крепкий\"",
		GENITIVE = "бутылки сидра \"Цзянь Крепкий\"",
		DATIVE = "бутылке сидра \"Цзянь Крепкий\"",
		ACCUSATIVE = "бутылку сидра \"Цзянь Крепкий\"",
		INSTRUMENTAL = "бутылкой сидра \"Цзянь Крепкий\"",
		PREPOSITIONAL = "бутылке сидра \"Цзянь Крепкий\""
 	)
	icon_state = "hcider"
	volume = 50
	list_reagents = list("suicider" = 50)

/obj/item/reagent_containers/food/drinks/bottle/fernet
	name = "Fernet Bronca"
	desc = "Бутылка фернета, произведенного на космической станции \"Кордоба\"."
	ru_names = list(
		NOMINATIVE = "бутылка фернета \"Фернет Бронка\"",
		GENITIVE = "бутылки фернета \"Фернет Бронка\"",
		DATIVE = "бутылке фернета \"Фернет Бронка\"",
		ACCUSATIVE = "бутылку фернета \"Фернет Бронка\"",
		INSTRUMENTAL = "бутылкой фернета \"Фернет Бронка\"",
		PREPOSITIONAL = "бутылке фернета \"Фернет Бронка\""
 	)
	icon_state = "fernetbottle"
	list_reagents = list("fernet" = 100)

/obj/item/reagent_containers/food/drinks/bottle/champagne
	name = "Sparkling Sunny Champagne"
	desc = "Бутылка чистого обжигающего солнца, готовая поразить ваш мозг."
	ru_names = list(
		NOMINATIVE = "бутылка шампанского \"Сверкающее Солнце\"",
		GENITIVE = "бутылки шампанского \"Сверкающее Солнце\"",
		DATIVE = "бутылке шампанского \"Сверкающее Солнце\"",
		ACCUSATIVE = "бутылку шампанского \"Сверкающее Солнце\"",
		INSTRUMENTAL = "бутылкой шампанского \"Сверкающее Солнце\"",
		PREPOSITIONAL = "бутылке шампанского \"Сверкающее Солнце\""
 	)
	icon_state = "champagnebottle"
	list_reagents = list("champagne" = 100)

/obj/item/reagent_containers/food/drinks/bottle/aperol
	name = "Jungle Aperol Aperitivo"
	desc = "Настоящая засажа для вашей печени."
	ru_names = list(
		NOMINATIVE = "бутылка апероля \"Джунгли Аперитив\"",
		GENITIVE = "бутылки апероля \"Джунгли Аперитив\"",
		DATIVE = "бутылке апероля \"Джунгли Аперитив\"",
		ACCUSATIVE = "бутылку апероля \"Джунгли Аперитив\"",
		INSTRUMENTAL = "бутылкой апероля \"Джунгли Аперитив\"",
		PREPOSITIONAL = "бутылке апероля \"Джунгли Аперитив\""
 	)
	icon_state = "aperolbottle"
	list_reagents = list("aperol" = 100)

/obj/item/reagent_containers/food/drinks/bottle/jagermeister
	name = "Infused Space Jaegermeister"
	desc = "Das ist des Jägers Ehrenschild, daß er beschützt und hegt sein Wild, weidmännisch jagt, wie sich gehört, den Schöpfer im Geschöpfe ehrt."
	ru_names = list(
		NOMINATIVE = "бутылка ягермейстера \"Космически Настоенный\"",
		GENITIVE = "бутылки ягермейстера \"Космически Настоенный\"",
		DATIVE = "бутылке ягермейстера \"Космически Настоенный\"",
		ACCUSATIVE = "бутылку ягермейстера \"Космически Настоенный\"",
		INSTRUMENTAL = "бутылкой ягермейстера \"Космически Настоенный\"",
		PREPOSITIONAL = "бутылке ягермейстера \"Космически Настоенный\""
 	)
	icon_state = "jagermeisterbottle"
	list_reagents = list("jagermeister" = 100)

/obj/item/reagent_containers/food/drinks/bottle/schnaps
	name = "Grainy Mint Schnapps"
	desc = "Настоящий ужас для истинного ценителя, высококачественный мятный шнапс."
	ru_names = list(
		NOMINATIVE = "бутылка шнапса \"Мятный Зерновой\"",
		GENITIVE = "бутылки шнапса \"Мятный Зерновой\"",
		DATIVE = "бутылке шнапса \"Мятный Зерновой\"",
		ACCUSATIVE = "бутылку шнапса \"Мятный Зерновой\"",
		INSTRUMENTAL = "бутылкой шнапса \"Мятный Зерновой\"",
		PREPOSITIONAL = "бутылке шнапса \"Мятный Зерновой\""
 	)
	icon_state = "schnapsbottle"
	list_reagents = list("schnaps" = 100)

/obj/item/reagent_containers/food/drinks/bottle/sheridan
	name = "Sheridan's Coffee Layered"
	desc = "Двойное чудо с новой инновационной шеей, намного лучше, чем у вас."
	ru_names = list(
		NOMINATIVE = "бутылка ликёра \"Шериданс Кофейный\"",
		GENITIVE = "бутылки ликёра \"Шериданс Кофейный\"",
		DATIVE = "бутылке ликёра \"Шериданс Кофейный\"",
		ACCUSATIVE = "бутылку ликёра \"Шериданс Кофейный\"",
		INSTRUMENTAL = "бутылкой ликёра \"Шериданс Кофейный\"",
		PREPOSITIONAL = "бутылке ликёра \"Шериданс Кофейный\""
 	)
	icon_state = "sheridanbottle"
	list_reagents = list("sheridan" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bitter
	name = "Vacuum Cherry Bitter"
	desc = "Постарайтесь не задохнуться, выпив такую чудесную горечь."
	ru_names = list(
		NOMINATIVE = "бутылка битера \"Вауумный Вишнёвый\"",
		GENITIVE = "бутылки битера \"Вауумный Вишнёвый\"",
		DATIVE = "бутылке битера \"Вауумный Вишнёвый\"",
		ACCUSATIVE = "бутылку битера \"Вауумный Вишнёвый\"",
		INSTRUMENTAL = "бутылкой битера \"Вауумный Вишнёвый\"",
		PREPOSITIONAL = "бутылке битера \"Вауумный Вишнёвый\""
 	)
	icon_state = "bitterbottle"
	list_reagents = list("bitter" = 50)

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Grenadier Blue Curacao"
	desc = "Взрыв - это искусство, но синий взрыв намного лучше."
	ru_names = list(
		NOMINATIVE = "бутылка кюрасао \"Гренадёрский Синий\"",
		GENITIVE = "бутылки кюрасао \"Гренадёрский Синий\"",
		DATIVE = "бутылке кюрасао \"Гренадёрский Синий\"",
		ACCUSATIVE = "бутылку кюрасао \"Гренадёрский Синий\"",
		INSTRUMENTAL = "бутылкой кюрасао \"Гренадёрский Синий\"",
		PREPOSITIONAL = "бутылке кюрасао \"Гренадёрский Синий\""
 	)
	icon_state = "bluecuracao"
	list_reagents = list("bluecuracao" = 100)

/obj/item/reagent_containers/food/drinks/bottle/sambuka
	name = "The Headless Horseman's Sambuka"
	desc = "Я не пил самбуку с тех пор, как мне было двадцать."
	ru_names = list(
		NOMINATIVE = "бутылка самбуки \"Безголовый Всадник\"",
		GENITIVE = "бутылки самбуки \"Безголовый Всадник\"",
		DATIVE = "бутылке самбуки \"Безголовый Всадник\"",
		ACCUSATIVE = "бутылку самбуки \"Безголовый Всадник\"",
		INSTRUMENTAL = "бутылкой самбуки \"Безголовый Всадник\"",
		PREPOSITIONAL = "бутылке самбуки \"Безголовый Всадник\""
 	)
	icon_state = "sambukabottle"
	list_reagents = list("sambuka" = 100)

/obj/item/reagent_containers/food/drinks/bottle/arrogant_green_rat
	name = "Arrogant Green Rat"
	desc = "Лучшее вино из райского города, где трава зелёная, а девушки красивые."
	ru_names = list(
		NOMINATIVE = "бутылка вина \"Высокомерная Зелёная Крыса\"",
		GENITIVE = "бутылки вина \"Высокомерная Зелёная Крыса\"",
		DATIVE = "бутылке вина \"Высокомерная Зелёная Крыса\"",
		ACCUSATIVE = "бутылку вина \"Высокомерная Зелёная Крыса\"",
		INSTRUMENTAL = "бутылкой вина \"Высокомерная Зелёная Крыса\"",
		PREPOSITIONAL = "бутылке вина \"Высокомерная Зелёная Крыса\""
 	)
	icon_state = "arrogant_green_rat"
	list_reagents = list("wine" = 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/orangejuice
	name = "orange juice"
	desc = "Полон витаминов и вкусностей!"
	ru_names = list(
		NOMINATIVE = "пачка апельсинового сока",
		GENITIVE = "пачки апельсинового сока",
		DATIVE = "пачке апельсинового сока",
		ACCUSATIVE = "пачку апельсинового сока",
		INSTRUMENTAL = "пачкой апельсинового сока",
		PREPOSITIONAL = "пачке апельсинового сока"
 	)
	icon_state = "orangejuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("orangejuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cream
	name = "milk cream"
	desc = "Это сливки. Сделаны из молока. А что ещё вы думали там найти?"
	ru_names = list(
		NOMINATIVE = "пачка сливок",
		GENITIVE = "пачки сливок",
		DATIVE = "пачке сливок",
		ACCUSATIVE = "пачку сливок",
		INSTRUMENTAL = "пачкой сливок",
		PREPOSITIONAL = "пачке сливок"
 	)
	icon_state = "cream"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("cream" = 100)

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	name = "tomato juice"
	desc = "Ну, по крайней мере, это выглядит как томатный сок. Слишком красное, чтобы сказать точно."
	ru_names = list(
		NOMINATIVE = "пачка томатного сока",
		GENITIVE = "пачки томатного сока",
		DATIVE = "пачке томатного сока",
		ACCUSATIVE = "пачку томатного сока",
		INSTRUMENTAL = "пачкой томатного сока",
		PREPOSITIONAL = "пачке томатного сока"
 	)
	icon_state = "tomatojuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("tomatojuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/limejuice
	name = "lime juice"
	desc = "Кисло-сладкая вкуснятина."
	ru_names = list(
		NOMINATIVE = "пачка лаймового сока",
		GENITIVE = "пачки лаймового сока",
		DATIVE = "пачке лаймового сока",
		ACCUSATIVE = "пачку лаймового сока",
		INSTRUMENTAL = "пачкой лаймового сока",
		PREPOSITIONAL = "пачке лаймового сока"
 	)
	icon_state = "limejuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("limejuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/milk
	name = "milk"
	desc = "Мягкое, вкусно и полезное молоко."
	ru_names = list(
		NOMINATIVE = "пачка молока",
		GENITIVE = "пачки молока",
		DATIVE = "пачке молока",
		ACCUSATIVE = "пачку молока",
		INSTRUMENTAL = "пачкой молока",
		PREPOSITIONAL = "пачке молока"
 	)
	icon_state = "milk"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("milk" = 100)

////////////////////////// MOLOTOV ///////////////////////
/obj/item/reagent_containers/food/drinks/bottle/molotov
	name = "molotov cocktail"
	desc = "A throwing weapon used to ignite things, typically filled with an accelerant. Recommended highly by rioters and revolutionaries. Light and toss."
	icon_state = "vodkabottle"
	list_reagents = list()
	var/list/accelerants = list(/datum/reagent/consumable/ethanol,/datum/reagent/fuel,/datum/reagent/clf3,/datum/reagent/phlogiston,
							/datum/reagent/napalm,/datum/reagent/hellwater,/datum/reagent/plasma,/datum/reagent/plasma_dust)
	var/active = FALSE


/obj/item/reagent_containers/food/drinks/bottle/molotov/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)
	if(!isGlass)
		desc += " You're not sure if making this out of a carton was the brightest idea."


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
		to_chat(user, span_warning("The [name] is already lit."))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	active = TRUE
	var/turf/bombturf = get_turf(src)
	message_admins("[ADMIN_LOOKUP(user)] has primed a [name] for detonation at [ADMIN_COORDJMP(bombturf)].")
	add_game_logs("has primed a [name] for detonation at [AREACOORD(bombturf)].", user)
	user.visible_message(
		span_danger("[user] lights [src] on fire!"),
		span_notice("You light [src] on fire."),
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
			to_chat(user, "<span class='danger'>The flame's spread too far on it!</span>")
			return
		to_chat(user, "<span class='info'>You snuff out the flame on \the [src].</span>")
		active = FALSE
		update_icon(UPDATE_OVERLAYS)
