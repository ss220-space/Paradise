
//////////////////////
//		Meals		//
//////////////////////

/obj/item/reagent_containers/food/snacks/eggplantparm
	name = "eggplant parmigiana"
	desc = "Единственный хороший рецепт из баклажанов."
	ru_names = list(
		NOMINATIVE = "баклажаны с пармезаном",
		GENITIVE = "баклажанов с пармезаном",
		DATIVE = "баклажанам с пармезаном",
		ACCUSATIVE = "баклажаны с пармезаном",
		INSTRUMENTAL = "баклажанами с пармезаном",
		PREPOSITIONAL = "баклажанах с пармезаном"
	)
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	filling_color = "#4D2F5E"
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("баклажанов" = 2, "сыра" = 2)
	foodtype = VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/soylentgreen
	name = "soylent green"
	desc = "Не сделано из людей. Честно." //Totally people.
	ru_names = list(
		NOMINATIVE = "холодец",
		GENITIVE = "холодца",
		DATIVE = "холодцу",
		ACCUSATIVE = "холодец",
		INSTRUMENTAL = "холодцем",
		PREPOSITIONAL = "холодце"
	)
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	filling_color = "#B8E6B5"
	list_reagents = list("nutriment" = 10, "vitamin" = 1)
	tastes = list("холодца" = 7, "людей" = 1)
	foodtype = GROSS

/obj/item/reagent_containers/food/snacks/soylentviridians
	name = "soylent virdians"
	desc = "Не сделано из людей. Честно." //Actually honest for once.
	ru_names = list(
		NOMINATIVE = "соевый холодец",
		GENITIVE = "соевого холодца",
		DATIVE = "соевому холодцу",
		ACCUSATIVE = "соевый холодец",
		INSTRUMENTAL = "соевым холодцем",
		PREPOSITIONAL = "соевом холодце"
	)
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	filling_color = "#E6FA61"
	list_reagents = list("nutriment" = 10, "vitamin" = 1)
	tastes = list("холодца" = 10)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's delight"
	desc = "У-у-у-у А-а-а-а-а!"
	ru_names = list(
		NOMINATIVE = "обезьяний восторг",
		GENITIVE = "обезьяньего восторга",
		DATIVE = "обезьяньему восторгу",
		ACCUSATIVE = "обезьяний восторг",
		INSTRUMENTAL = "обезьяньим восторгом",
		PREPOSITIONAL = "обезьяньем восторге"
	)
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	filling_color = "#5C3C11"
	bitesize = 6
	list_reagents = list("nutriment" = 10, "banana" = 5, "vitamin" = 5)
	tastes = list("бананов" = 1, "джунглей" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/dionaroast
	name = "roast diona"
	desc = "Похоже на огромную кожистую морковку... С глазом."
	ru_names = list(
		NOMINATIVE = "жареная диона",
		GENITIVE = "жареной дионы",
		DATIVE = "жареной дионе",
		ACCUSATIVE = "жареную диону",
		INSTRUMENTAL = "жареной дионой",
		PREPOSITIONAL = "жареной дионе"
	)
	icon_state = "dionaroast"
	trash = /obj/item/trash/plate
	filling_color = "#75754B"
	list_reagents = list("plantmatter" = 4, "nutriment" = 2, "radium" = 2, "vitamin" = 4)
	tastes = list("овощей" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/tofurkey
	name = "tofurkey"
	desc = "Искусственная индейка из тофу."
	ru_names = list(
		NOMINATIVE = "тофурка",
		GENITIVE = "тофурки",
		DATIVE = "тофурке",
		ACCUSATIVE = "тофурку",
		INSTRUMENTAL = "тофуркой",
		PREPOSITIONAL = "тофурке"
	)
	icon_state = "tofurkey"
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 12, "ether" = 3)
	tastes = list("тофу" = 1)
	foodtype = VEGETABLES


//////////////////////
//		Salads		//
//////////////////////

/obj/item/reagent_containers/food/snacks/aesirsalad
	name = "aesir salad"
	desc = "Вероятно, слишком невероятный для простых смертных."
	ru_names = list(
		NOMINATIVE = "салат асов",
		GENITIVE = "салата асов",
		DATIVE = "салату асов",
		ACCUSATIVE = "салат асов",
		INSTRUMENTAL = "салатом асов",
		PREPOSITIONAL = "салате асов"
	)
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#468C00"
	bitesize = 3
	list_reagents = list("nutriment" = 8, "omnizine" = 8, "vitamin" = 6)
	tastes = list("божества" = 1, "салата" = 1)
	foodtype = VEGETABLES | FRUIT

/obj/item/reagent_containers/food/snacks/herbsalad
	name = "herb salad"
	desc = "Вкусный салат с яблоками."
	ru_names = list(
		NOMINATIVE = "травяной салат",
		GENITIVE = "травяного салата",
		DATIVE = "травяному салату",
		ACCUSATIVE = "травяной салат",
		INSTRUMENTAL = "травяным салатом",
		PREPOSITIONAL = "травяном салате"
	)
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76B87F"
	bitesize = 3
	list_reagents = list("nutriment" = 8, "vitamin" = 2)
	tastes = list("салата" = 1, "яблока" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "Просто травяной салат с фрикадельками и жареной картошкой. Ничего подозрительного."
	ru_names = list(
		NOMINATIVE = "правильный салат",
		GENITIVE = "правильного салата",
		DATIVE = "правильному салату",
		ACCUSATIVE = "правильный салат",
		INSTRUMENTAL = "правильным салатом",
		PREPOSITIONAL = "правильном салате"
	)
	icon_state = "validsalad"
	w_class = WEIGHT_CLASS_SMALL
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76B87F"
	bitesize = 3
	list_reagents = list("nutriment" = 8, "salglu_solution" = 5, "vitamin" = 2)
	tastes = list("жаренной картошки" = 1, "салата" = 1, "мяса" = 1, "правды" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/oliviersalad
	name = "olivier salad"
	desc = "Не трогай, это на Новый год!"
	ru_names = list(
		NOMINATIVE = "салат оливье",
		GENITIVE = "салата оливье",
		DATIVE = "салату оливье",
		ACCUSATIVE = "салат оливье",
		INSTRUMENTAL = "салатом оливье",
		PREPOSITIONAL = "салате оливье"
	)
	icon_state = "oliviersalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "kelotane" = 2, "vitamin" = 3)
	tastes = list("отварного картофеля" = 1, "соленьев" = 1, "морковки" = 1, "яиц" = 1, "Нового Года" = 3)

/obj/item/reagent_containers/food/snacks/vegisalad
	name = "vegetable salad"
	desc = "Идеальное сочетание помидоров и огурцов."
	ru_names = list(
		NOMINATIVE = "овощной салат",
		GENITIVE = "овощного салата",
		DATIVE = "овощному салату",
		ACCUSATIVE = "овощной салат",
		INSTRUMENTAL = "овощным салатом",
		PREPOSITIONAL = "овощном салате"
	)
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "kelotane" = 1, "vitamin" = 1)
	tastes = list("помидоров" = 2, "огурцов" = 2, "сметаны" = 2)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/weirdoliviersalad
	name = "weird olivier salad"
	desc = "Что ты сделал с этим салатом, монстр?"
	ru_names = list(
		NOMINATIVE = "странный салат оливье",
		GENITIVE = "странного салата оливье",
		DATIVE = "странному салату оливье",
		ACCUSATIVE = "странный салат оливье",
		INSTRUMENTAL = "странным салатом оливье",
		PREPOSITIONAL = "странном салате оливье"
	)
	icon_state = "oliviersalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 12, "kelotane" = 2, "vitamin" = 3)
	tastes = list("отварного картофеля" = 1, "огурчиков" = 1, "морковки" = 1, "яиц" = 1, "чего-то странного" = 3, "Нового Года" = 3)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/fruitcup
	name = "Dina's fruit cup"
	desc = "Порция салата со съедобной тарелкой"
	ru_names = list(
		NOMINATIVE = "фруктовый салат Дины",
		GENITIVE = "фруктового салата Дины",
		DATIVE = "фруктовому салату Дины",
		ACCUSATIVE = "фруктовый салат Дины",
		INSTRUMENTAL = "фруктовым салатом Дины",
		PREPOSITIONAL = "фруктовом салате Дины"
	)
	icon_state = "fruitcup"
	filling_color = "#C2CFAB"
	list_reagents = list("nutriment" = 3, "watermelonjuice" = 5, "orangejuice" = 5, "vitamin" = 4)
	tastes = list("яблока" = 2, "бананов" = 2, "арбуза" = 2, "лимноа" = 1, "амброзии" = 1)
	bitesize = 4
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/junglesalad
	name = "Jungle salad"
	desc = "Прямо из глубин джунглей."
	ru_names = list(
		NOMINATIVE = "салат джунглей",
		GENITIVE = "салата джунглей",
		DATIVE = "салату джунглей",
		ACCUSATIVE = "салат джунглей",
		INSTRUMENTAL = "салатом джунглей",
		PREPOSITIONAL = "салате джунглей"
	)
	icon_state = "junglesalad"
	filling_color = "#C2CFAB"
	list_reagents = list("nutriment" = 6, "watermelonjuice" = 3, "vitamin" = 4)
	tastes = list("яблока" = 1, "банана" = 2, "арбуза" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/delightsalad
	name = "Delight salad"
	desc = "Настоящий цитрусовый восторг."
	ru_names = list(
		NOMINATIVE = "салат \"Восторг\"",
		GENITIVE = "салата \"Восторг\"",
		DATIVE = "салату \"Восторг\"",
		ACCUSATIVE = "салат \"Восторг\"",
		INSTRUMENTAL = "салатом \"Восторг\"",
		PREPOSITIONAL = "салате \"Восторг\""
	)
	icon_state = "delightsalad"
	filling_color = "#C2CFAB"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 3, "lemonjuice" = 4, "orangejuice" = 4, "vitamin" = 4, "limejuice" = 4)
	tastes = list("лимона" = 1, "лайма" = 2, "апельсина" = 1)
	bitesize = 4
	foodtype = VEGETABLES

//////////////////////
//	Donk Pockets	//
//////////////////////

/obj/item/reagent_containers/food/snacks/donkpocket
	name = "Donk-pocket"
	desc = "Идеальное блюдо для бывалого предателя."
	ru_names = list(
		NOMINATIVE = "донк-покет",
		GENITIVE = "донк-покета",
		DATIVE = "донк-покету",
		ACCUSATIVE = "донк-покет",
		INSTRUMENTAL = "донк-покетом",
		PREPOSITIONAL = "донк-покете"
	)
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	list_reagents = list("nutriment" = 4)
	tastes = list("мяса" = 2, "теста" = 2, "ленности" = 1)
	foodtype = JUNKFOOD | MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/warmdonkpocket
	name = "warm Donk-pocket"
	desc = "Идеальное блюдо для бывалого предателя."
	ru_names = list(
		NOMINATIVE = "тёплый донк-покет",
		GENITIVE = "тёплого донк-покета",
		DATIVE = "тёплому донк-покету",
		ACCUSATIVE = "тёплый донк-покет",
		INSTRUMENTAL = "тёплым донк-покетом",
		PREPOSITIONAL = "тёплом донк-покете"
	)
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	list_reagents = list("nutriment" = 4)
	tastes = list("мяса" = 2, "теста" = 2, "ленности" = 1)
	foodtype = JUNKFOOD | MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/warmdonkpocket/Post_Consume(mob/living/M)
	M.reagents.add_reagent("omnizine", 15)

/obj/item/reagent_containers/food/snacks/warmdonkpocket_weak
	name = "lukewarm Donk-pocket"
	desc = "Идеальное блюдо для бывалого предателя. Это блюдо чуть теплое."
	ru_names = list(
		NOMINATIVE = "слегка тёплый донк-покет",
		GENITIVE = "слегка тёплого донк-покета",
		DATIVE = "слегка тёплому донк-покету",
		ACCUSATIVE = "слегка тёплый донк-покет",
		INSTRUMENTAL = "слегка тёплым донк-покетом",
		PREPOSITIONAL = "слегка тёплом донк-покете"
	)
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	list_reagents = list("nutriment" = 4, "weak_omnizine" = 3)
	foodtype = JUNKFOOD | MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/syndidonkpocket
	name = "Donk-pocket"
	desc = "Этот донк-покет излучает немного тепла."
	ru_names = list(
		NOMINATIVE = "донк-покет",
		GENITIVE = "донк-покета",
		DATIVE = "донк-покету",
		ACCUSATIVE = "донк-покет",
		INSTRUMENTAL = "донк-покетом",
		PREPOSITIONAL = "донк-покете"
	)
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	bitesize = 100 //nom the whole thing at once.
	list_reagents = list("nutriment" = 1)
	foodtype = JUNKFOOD | MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/syndidonkpocket/Post_Consume(mob/living/M)
	M.reagents.add_reagent("omnizine", 15)
	M.reagents.add_reagent("teporone", 15)
	M.reagents.add_reagent("synaptizine", 15)
	M.reagents.add_reagent("salglu_solution", 15)
	M.reagents.add_reagent("salbutamol", 15)
	M.reagents.add_reagent("methamphetamine", 15)

//////////////////////
//  Buckwheat       //
//////////////////////

/obj/item/reagent_containers/food/snacks/boiledbuckwheat
	name = "boiled buckwheat"
	desc = "\"Гречка\", или варёная гречневая крупа. Родина будет гордиться тобой!"
	ru_names = list(
		NOMINATIVE = "варёная гречка",
		GENITIVE = "варёной гречки",
		DATIVE = "варёной гречке",
		ACCUSATIVE = "варёную гречку",
		INSTRUMENTAL = "варёной гречкой",
		PREPOSITIONAL = "варёной гречке"
	)
	icon_state = "boiledbuckwheat"
	trash = /obj/item/trash/plate
	filling_color = "#8E633C"
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	tastes = list("гречки" = 1, "родины" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/buckwheat_merchant
	name = "merchant's buckwheat porridge"
	desc = "Горячая и ароматная. Советские шпионы тут точно замешаны."
	ru_names = list(
		NOMINATIVE = "гречневая каша по-купечески",
		GENITIVE = "гречневой каши по-купечески",
		DATIVE = "гречневой каше по-купечески",
		ACCUSATIVE = "гречневую кашу по-купечески",
		INSTRUMENTAL = "гречневой кашей по-купечески",
		PREPOSITIONAL = "гречневой каше по-купечески"
	)
	icon_state = "buckwheat_merchant"
	trash = /obj/item/trash/plate
	filling_color = "#8E633C"
	list_reagents = list("nutriment" = 5, "protein" = 2, "vitamin" = 3)
	tastes = list("гречки" = 2, "мяса" = 2, "томатного соуса" = 1)
	foodtype = GRAIN | MEAT

//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/boiledslimecore
	name = "boiled slime core"
	desc = "Варёная красная штука."
	ru_names = list(
		NOMINATIVE = "вареное ядро слайма",
		GENITIVE = "вареного ядра слайма",
		DATIVE = "вареному ядру слайма",
		ACCUSATIVE = "вареное ядро слайма",
		INSTRUMENTAL = "вареным ядром слайма",
		PREPOSITIONAL = "вареном ядре слайма"
	)
	icon_state = "boiledrorocore"
	bitesize = 3
	list_reagents = list("slimejelly" = 5)
	tastes = list("желе" = 3)
	foodtype = MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/pickles
	name = "pickles"
	desc = "Чёрт, тут целая куча солёных огурцов."
	ru_names = list(
		NOMINATIVE = "соленья",
		GENITIVE = "солений",
		DATIVE = "соленьям",
		ACCUSATIVE = "соленья",
		INSTRUMENTAL = "соленьями",
		PREPOSITIONAL = "соленьях"
	)
	icon_state = "pickles"
	trash = /obj/item/reagent_containers/food/snacks/brine
	filling_color = "#C2CFAB"
	bitesize = 8
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	tastes = list("огурчиков" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/brine
	name = "brine"
	desc = "На следующую утро."
	ru_names = list(
		NOMINATIVE = "рассол",
		GENITIVE = "рассола",
		DATIVE = "рассолу",
		ACCUSATIVE = "рассол",
		INSTRUMENTAL = "рассолом",
		PREPOSITIONAL = "рассоле"
	)
	consume_sound = 'sound/items/drink.ogg'
	icon_state = "brine"
	filling_color = "#C2CFAB"
	bitesize = 4
	list_reagents = list("nutriment" = 1, "antihol" = 2)
	tastes = list("рассола" = 3)

/obj/item/reagent_containers/food/snacks/popcorn
	name = "popcorn"
	desc = "Теперь бы найти кинотеатр."
	ru_names = list(
		NOMINATIVE = "попкорн",
		GENITIVE = "попкорна",
		DATIVE = "попкорну",
		ACCUSATIVE = "попкорн",
		INSTRUMENTAL = "попкорном",
		PREPOSITIONAL = "попкорне"
	)
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#FFFAD4"
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	list_reagents = list("nutriment" = 2)
	tastes = list("попкорна" = 3, "сливочного масла" = 1)
	foodtype = JUNKFOOD | FRIED

/obj/item/reagent_containers/food/snacks/popcorn/New()
	..()
	unpopped = rand(1,10)

/obj/item/reagent_containers/food/snacks/popcorn/On_Consume(mob/M, mob/user)
	if(prob(unpopped))	//lol ...what's the point?
		to_chat(user, span_userdanger("Ты откусываешь кусочек от нераскрывшегося зернышка!"))
		unpopped = max(0, unpopped-1)
	..()

/obj/item/reagent_containers/food/snacks/liquidfood
	name = "\improper LiquidFood ration"
	desc = "Готовая серая жижа со всеми необходимыми питательными веществами для космонавта. Должно ли это хрустеть?"
	ru_names = list(
		NOMINATIVE = "рацион \"Жидкая пища\"",
		GENITIVE = "рациона \"Жидкая пища\"",
		DATIVE = "рациону \"Жидкая пища\"",
		ACCUSATIVE = "рацион \"Жидкая пища\"",
		INSTRUMENTAL = "рационом \"Жидкая пища\"",
		PREPOSITIONAL = "рационе \"Жидкая пища\""
	)
	icon_state = "liquidfood"
	trash = /obj/item/trash/liquidfood
	filling_color = "#A8A8A8"
	bitesize = 4
	list_reagents = list("nutriment" = 20, "iron" = 3, "vitamin" = 2)
	foodtype = GROSS
