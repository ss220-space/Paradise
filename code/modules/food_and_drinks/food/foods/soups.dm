
//////////////////////
//		Soups		//
//////////////////////
// Base object for soups, should never appear ingame.
/obj/item/reagent_containers/food/snacks/soup
	name = "impossible soup"
	desc = "Этот суп настолько хорош, что не должен существовать!"
	icon_state = "beans" // If you don't have a sprite, you get beans.
	consume_sound = 'sound/items/drink.ogg'
	trash = /obj/item/trash/snack_bowl
	bitesize = 5

/obj/item/reagent_containers/food/snacks/soup/meatballsoup
	name = "meatball soup"
	desc = "У тебя есть шары, парень, ШАРЫ!"
	ru_names = list(
		NOMINATIVE = "суп с фрикадельками",
		GENITIVE = "супа с фрикадельками",
		DATIVE = "супу с фрикадельками",
		ACCUSATIVE = "суп с фрикадельками",
		INSTRUMENTAL = "супом с фрикадельками",
		PREPOSITIONAL = "супе с фрикадельками"
	)
	icon_state = "meatballsoup"
	filling_color = "#785210"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)
	tastes = list("фрикаделек" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/soup/slimesoup
	name = "slime soup"
	desc = "Если воды нет, можно заменить слезами."
	ru_names = list(
		NOMINATIVE = "слаймовый суп",
		GENITIVE = "слаймового супа",
		DATIVE = "слаймовому супу",
		ACCUSATIVE = "слаймовый суп",
		INSTRUMENTAL = "слаймовым супом",
		PREPOSITIONAL = "слаймовом супе"
	)
	icon_state = "slimesoup"
	filling_color = "#C4DBA0"
	list_reagents = list("nutriment" = 5, "slimejelly" = 5, "water" = 5, "vitamin" = 4)
	tastes = list("слизи" = 1)
	foodtype = TOXIC

/obj/item/reagent_containers/food/snacks/soup/bloodsoup
	name = "tomato soup"
	desc = "Пахнет медью."
	ru_names = list(
		NOMINATIVE = "томатный суп",
		GENITIVE = "томатного супа",
		DATIVE = "томатному супу",
		ACCUSATIVE = "томатный суп",
		INSTRUMENTAL = "томатным супом",
		PREPOSITIONAL = "томатном супе"
	)
	icon_state = "tomatosoup"
	filling_color = "#FF0000"
	list_reagents = list("nutriment" = 2, "blood" = 10, "water" = 5, "vitamin" = 4)
	tastes = list("железа" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/soup/clownstears
	name = "clown's tears"
	desc = "Не очень смешно."
	ru_names = list(
		NOMINATIVE = "слёзы клоуна",
		GENITIVE = "слёз клоуна",
		DATIVE = "слёзам клоуна",
		ACCUSATIVE = "слёзы клоуна",
		INSTRUMENTAL = "слёзами клоуна",
		PREPOSITIONAL = "слёзах клоуна"
	)
	icon_state = "clownstears"
	filling_color = "#C4FBFF"
	list_reagents = list("nutriment" = 4, "banana" = 5, "water" = 5, "vitamin" = 8)
	tastes = list("плохой шутки" = 1)

/obj/item/reagent_containers/food/snacks/soup/vegetablesoup
	name = "vegetable soup"
	desc = "Настоящая веганская еда."
	ru_names = list(
		NOMINATIVE = "овощной суп",
		GENITIVE = "овощного супа",
		DATIVE = "овощному супу",
		ACCUSATIVE = "овощной суп",
		INSTRUMENTAL = "овощным супом",
		PREPOSITIONAL = "овощном супе"
	)
	icon_state = "vegetablesoup"
	filling_color = "#AFC4B5"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)
	tastes = list("овощей" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/nettlesoup
	name = "nettle soup"
	desc = "Подумать только, ботаник мог бы забить тебя этим насмерть."
	ru_names = list(
		NOMINATIVE = "суп из крапивы",
		GENITIVE = "супа из крапивы",
		DATIVE = "супу из крапивы",
		ACCUSATIVE = "суп из крапивы",
		INSTRUMENTAL = "супом из крапивы",
		PREPOSITIONAL = "супе из крапивы"
	)
	icon_state = "nettlesoup"
	filling_color = "#AFC4B5"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)
	tastes = list("крапивы" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/mysterysoup
	name = "mystery soup"
	desc = "Загадка в том, почему ты его не ешь?"
	ru_names = list(
		NOMINATIVE = "суп-загадка",
		GENITIVE = "супа-загадки",
		DATIVE = "супу-загадке",
		ACCUSATIVE = "суп-загадку",
		INSTRUMENTAL = "супом-загадкой",
		PREPOSITIONAL = "супе-загадке"
	)
	icon_state = "mysterysoup"
	var/extra_reagent = null
	list_reagents = list("nutriment" = 6)
	tastes = list("хаоса" = 1)

/obj/item/reagent_containers/food/snacks/soup/mysterysoup/Initialize(mapload)
	extra_reagent = pick("capsaicin", "frostoil", "omnizine", "banana", "blood", "slimejelly", "toxin", "banana", "carbon", "oculine")
	reagents.add_reagent("[extra_reagent]", 5)
	. = ..()

/obj/item/reagent_containers/food/snacks/soup/wishsoup
	name = "wish soup"
	desc = "Жаль, что это не суп."
	ru_names = list(
		NOMINATIVE = "суп-желание",
		GENITIVE = "супа-желания",
		DATIVE = "супу-желанию",
		ACCUSATIVE = "суп-желание",
		INSTRUMENTAL = "супом-желанием",
		PREPOSITIONAL = "супе-желании"
	)
	icon_state = "wishsoup"
	filling_color = "#D1F4FF"
	list_reagents = list("water" = 10)
	tastes = list("желания" = 1)

/obj/item/reagent_containers/food/snacks/soup/wishsoup/Initialize(mapload)
	if(prob(25))
		desc = "Желание сбылось!" // hue
		reagents.add_reagent("nutriment", 9)
		reagents.add_reagent("vitamin", 1)
	. = ..()

/obj/item/reagent_containers/food/snacks/soup/tomatosoup
	name = "tomato soup"
	desc = "Когда пьёшь это, чувствуешь себя вампиром! Томатным вампиром..."
	ru_names = list(
		NOMINATIVE = "томатный суп",
		GENITIVE = "томатного супа",
		DATIVE = "томатному супу",
		ACCUSATIVE = "томатный суп",
		INSTRUMENTAL = "томатным супом",
		PREPOSITIONAL = "томатном супе"
	)
	icon_state = "tomatosoup"
	filling_color = "#D92929"
	list_reagents = list("nutriment" = 5, "tomatojuice" = 10, "vitamin" = 3)
	tastes = list("томатов" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/misosoup
	name = "miso soup"
	desc = "Лучший суп во вселенной! Ням-ням-ням!!!"
	ru_names = list(
		NOMINATIVE = "мисо-суп",
		GENITIVE = "мисо-супа",
		DATIVE = "мисо-супу",
		ACCUSATIVE = "мисо-суп",
		INSTRUMENTAL = "мисо-супом",
		PREPOSITIONAL = "мисо-супе"
	)
	icon_state = "misosoup"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)
	foodtype = VEGETABLES
	tastes = list("мисо" = 1)

/obj/item/reagent_containers/food/snacks/soup/mushroomsoup
	name = "chantrelle soup"
	desc = "Вкусный и сытный грибной суп."
	ru_names = list(
		NOMINATIVE = "суп из лисичек",
		GENITIVE = "супа из лисичек",
		DATIVE = "супу из лисичек",
		ACCUSATIVE = "суп из лисичек",
		INSTRUMENTAL = "супом из лисичек",
		PREPOSITIONAL = "супе из лисичек"
	)
	icon_state = "mushroomsoup"
	filling_color = "#E386BF"
	list_reagents = list("nutriment" = 8, "vitamin" = 4)
	tastes = list("грибов" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/beetsoup
	name = "beet soup"
	desc = "Погоди, как это снова пишется..?"
	icon_state = "beetsoup"
	filling_color = "#FAC9FF"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)
	tastes = list("свеклы" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/beetsoup/New()
	..()
	var/randname = pick("борщ","боршч","бортч","болщ","борштч","борштч")
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")
	ru_names = list(
		NOMINATIVE = "[randname]",
		GENITIVE = "[randname]а",
		DATIVE = "[randname]у",
		ACCUSATIVE = "[randname]",
		INSTRUMENTAL = "[randname]ом",
		PREPOSITIONAL = "[randname]е"
	)

/obj/item/reagent_containers/food/snacks/soup/rassolnik
	name = "pickle soup"
	desc = "Довольно популярен в СССР."
	ru_names = list(
		NOMINATIVE = "рассольник",
		GENITIVE = "рассольника",
		DATIVE = "рассольнику",
		ACCUSATIVE = "рассольник",
		INSTRUMENTAL = "рассольником",
		PREPOSITIONAL = "рассольнике"
	)
	icon_state = "rassolnik"
	filling_color = "#F1FC72"
	list_reagents = list("nutriment" = 6, "kelotane" = 1, "vitamin" = 2)
	tastes = list("картошки" = 1, "огурцов" = 1, "риса" = 1, "России" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/shavelsoup
	name = "shavel soup"
	desc = "Лёгкий суп со свежим щавелем и овощами."
	ru_names = list(
		NOMINATIVE = "щавелевый суп",
		GENITIVE = "щавелевого супа",
		DATIVE = "щавелевому супу",
		ACCUSATIVE = "щавелевый суп",
		INSTRUMENTAL = "щавелевым супом",
		PREPOSITIONAL = "щавелевом супе"
	)
	icon_state = "shavelsoup"
	filling_color = "#135f13"
	list_reagents = list("nutriment" = 4, "water" = 5, "vitamin" = 5)
	tastes = list("кислой травы" = 1, "картошки" = 1)
//////////////////////
//		Stews		//
//////////////////////

/obj/item/reagent_containers/food/snacks/soup/stew
	name = "stew"
	desc = "Хорошее тёплое рагу. Полезно и сытно."
	ru_names = list(
		NOMINATIVE = "рагу",
		GENITIVE = "рагу",
		DATIVE = "рагу",
		ACCUSATIVE = "рагу",
		INSTRUMENTAL = "рагу",
		PREPOSITIONAL = "рагу"
	)
	icon_state = "stew"
	filling_color = "#9E673A"
	bitesize = 7
	list_reagents = list("nutriment" = 10, "oculine" = 5, "tomatojuice" = 5, "vitamin" = 5)
	tastes = list("помидоров" = 1, "морковки" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/stewedsoymeat
	name = "stewed soy meat"
	desc = "Даже не-вегетарианцы будут в ВОСТОРГЕ!"
	ru_names = list(
		NOMINATIVE = "тушёное соевое мясо",
		GENITIVE = "тушёного соевого мяса",
		DATIVE = "тушёному соевому мясу",
		ACCUSATIVE = "тушёное соевое мясо",
		INSTRUMENTAL = "тушёным соевым мясом",
		PREPOSITIONAL = "тушёном соевом мясе"
	)
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 8)
	tastes = list("сои" = 1, "овощей" = 1)
	foodtype = VEGETABLES

//////////////////////
//		Chili		//
//////////////////////

/obj/item/reagent_containers/food/snacks/soup/hotchili
	name = "hot chili"
	desc = "Техасский чили. Как же жжёт!"
	ru_names = list(
		NOMINATIVE = "острый чили",
		GENITIVE = "острого чили",
		DATIVE = "острому чили",
		ACCUSATIVE = "острый чили",
		INSTRUMENTAL = "острым чили",
		PREPOSITIONAL = "остром чили"
	)
	icon_state = "hotchili"
	filling_color = "#FF3C00"
	list_reagents = list("nutriment" = 5, "capsaicin" = 1, "tomatojuice" = 2, "vitamin" = 2)
	tastes = list("острого чили" = 1, "томатов" = 1)
	foodtype = VEGETABLES | MEAT

/obj/item/reagent_containers/food/snacks/soup/coldchili
	name = "cold chili"
	desc = "Оно достаточно холодное!"
	ru_names = list(
		NOMINATIVE = "холодный чили",
		GENITIVE = "холодного чили",
		DATIVE = "холодному чили",
		ACCUSATIVE = "холодный чили",
		INSTRUMENTAL = "холодным чили",
		PREPOSITIONAL = "холодном чили"
	)
	icon_state = "coldchili"
	filling_color = "#2B00FF"
	list_reagents = list("nutriment" = 5, "frostoil" = 1, "tomatojuice" = 2, "vitamin" = 2)
	tastes = list("томатов" = 1, "мяты" = 1)
	foodtype = VEGETABLES | MEAT
