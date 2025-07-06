
//////////////////////
//		Mexican		//
//////////////////////

/obj/item/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Откуси кусочек!"
	ru_names = list(
		NOMINATIVE = "тако",
		GENITIVE = "тако",
		DATIVE = "тако",
		ACCUSATIVE = "тако",
		INSTRUMENTAL = "тако",
		PREPOSITIONAL = "тако"
	)
	icon_state = "taco"
	bitesize = 3
	list_reagents = list("nutriment" = 7, "vitamin" = 1)
	tastes = list("тако" = 4, "мяса" = 2, "сыра" = 2, "салата" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/burrito
	name = "burrito"
	desc = "Мясо, бобы, сыр и рис, завернутые в удобную для держания лепёшку."
	ru_names = list(
		NOMINATIVE = "буррито",
		GENITIVE = "буррито",
		DATIVE = "буррито",
		ACCUSATIVE = "буррито",
		INSTRUMENTAL = "буррито",
		PREPOSITIONAL = "буррито"
	)
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("тортильи" = 2, "мяса" = 3)
	foodtype = MEAT | VEGETABLES


/obj/item/reagent_containers/food/snacks/chimichanga
	name = "chimichanga"
	desc = "Время сожрать эту ёбанную чимичангу."
	ru_names = list(
		NOMINATIVE = "чимичанга",
		GENITIVE = "чимичанги",
		DATIVE = "чимичанге",
		ACCUSATIVE = "чимичангу",
		INSTRUMENTAL = "чимичангой",
		PREPOSITIONAL = "чимичанге"
	)
	icon_state = "chimichanga"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list("omnizine" = 4, "cheese" = 2) //Deadpool reference. Deal with it.
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva la Mexico!"
	ru_names = list(
		NOMINATIVE = "энчилада",
		GENITIVE = "энчилады",
		DATIVE = "энчиладе",
		ACCUSATIVE = "энчиладу",
		INSTRUMENTAL = "энчиладой",
		PREPOSITIONAL = "энчиладе"
	)
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#A36A1F"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "capsaicin" = 6)
	tastes = list("острого перца" = 1, "мяса" = 3, "сыра" = 1, "сметаны" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/cornchips
	name = "corn chips"
	desc = "Отлично сочетается с сальсой! ¡Olé!"
	ru_names = list(
		NOMINATIVE = "кукурузные чипсы",
		GENITIVE = "кукурузных чипсов",
		DATIVE = "кукурузным чипсам",
		ACCUSATIVE = "кукурузные чипсы",
		INSTRUMENTAL = "кукурузными чипсами",
		PREPOSITIONAL = "кукурузных чипсах"
	)
	icon_state = "chips"
	bitesize = 1
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 3)
	foodtype = FRIED | GRAIN

/obj/item/reagent_containers/food/snacks/tortilla
	name = "Tortilla"
	desc = "Hasta la vista, baby"
	ru_names = list(
		NOMINATIVE = "тортилья",
		GENITIVE = "тортильи",
		DATIVE = "тортилье",
		ACCUSATIVE = "тортилью",
		INSTRUMENTAL = "тортильей",
		PREPOSITIONAL = "тортилье"
	)
	icon_state = "tortilla"
	trash = /obj/item/trash/plate
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 4)
	tastes = list("кукурузы" = 2)
	bitesize = 2
	foodtype = FRIED | GRAIN

/obj/item/reagent_containers/food/snacks/nachos
	name = "Nachos"
	desc = "Hola!"
	ru_names = list(
		NOMINATIVE = "начос",
		GENITIVE = "начоса",
		DATIVE = "начосу",
		ACCUSATIVE = "начос",
		INSTRUMENTAL = "начосом",
		PREPOSITIONAL = "начосе"
	)
	icon_state = "nachos"
	trash = /obj/item/trash/plate
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 5, "salt" = 1)
	tastes = list("кукурузы" = 2)
	bitesize = 3
	foodtype = FRIED | GRAIN

/obj/item/reagent_containers/food/snacks/cheesenachos
	name = "Cheese nachos"
	desc = "Cheese hola!"
	ru_names = list(
		NOMINATIVE = "сырные начос",
		GENITIVE = "сырных начоса",
		DATIVE = "сырным начосу",
		ACCUSATIVE = "сырные начос",
		INSTRUMENTAL = "сырными начосом",
		PREPOSITIONAL = "сырных начосе"
	)
	icon_state = "cheesenachos"
	trash = /obj/item/trash/plate
	filling_color = "#f1d65c"
	list_reagents = list("nutriment" = 7, "salt" = 1)
	tastes = list("кукурузы" = 1, "сыра" = 2)
	bitesize = 4
	foodtype = FRIED | GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/cubannachos
	name = "Cuban nachos"
	desc = "Very hot hola!"
	ru_names = list(
		NOMINATIVE = "кубинские начос",
		GENITIVE = "кубинских начоса",
		DATIVE = "кубинским начосу",
		ACCUSATIVE = "кубинские начос",
		INSTRUMENTAL = "кубинскими начосом",
		PREPOSITIONAL = "кубинских начосе"
	)
	icon_state = "cubannachos"
	trash = /obj/item/trash/plate
	filling_color = "#ec5c23"
	list_reagents = list("nutriment" = 7, "salt" = 1, "capsaicin" = 3, "plantmatter" = 1)
	tastes = list("кукурузы" = 1, "чили" = 2)
	bitesize = 4
	foodtype = FRIED | GRAIN

/obj/item/reagent_containers/food/snacks/carneburrito
	name = "Carne de burrito asado"
	desc = "Как классическое буррито, но с мясом."
	ru_names = list(
		NOMINATIVE = "карне асада буррито",
		GENITIVE = "карне асада буррито",
		DATIVE = "карне асада буррито",
		ACCUSATIVE = "карне асада буррито",
		INSTRUMENTAL = "карне асада буррито",
		PREPOSITIONAL = "карне асада буррито"
	)
	icon_state = "carneburrito"
	filling_color = "#69250b"
	list_reagents = list("nutriment" = 8, "protein" = 3, "soysauce" = 1)
	tastes = list("кукурузы" = 1, "мяса" = 2, "бобов" = 1)
	bitesize = 4
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/cheeseburrito
	name = "Cheese burrito"
	desc = "Нужно ли что-то говорить?"
	ru_names = list(
		NOMINATIVE = "сырное буррито",
		GENITIVE = "сырного буррито",
		DATIVE = "сырному буррито",
		ACCUSATIVE = "сырное буррито",
		INSTRUMENTAL = "сырным буррито",
		PREPOSITIONAL = "сырном буррито"
	)
	icon_state = "cheeseburrito"
	filling_color = "#f1d65c"
	list_reagents = list("nutriment" = 10, "soysauce" = 2)
	tastes = list("кукурузы" = 1, "бобов" = 1, "сыра" = 2)
	bitesize = 4
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/plasmaburrito
	name = "Fuego Plasma Burrito"
	desc = "¡Muy picante, amigos!"
	ru_names = list(
		NOMINATIVE = "фуэго плазма буррито",
		GENITIVE = "фуэго плазма буррито",
		DATIVE = "фуэго плазма буррито",
		ACCUSATIVE = "фуэго плазма буррито",
		INSTRUMENTAL = "фуэго плазма буррито",
		PREPOSITIONAL = "фуэго плазма буррито"
	)
	icon_state = "plasmaburrito"
	filling_color = "#f35a46"
	list_reagents = list("nutriment" = 4, "plantmatter" = 4, "capsaicin" = 4)
	tastes = list("кукуруза" = 1, "бобы" = 1, "чили" = 2)
	bitesize = 4
	foodtype = GRAIN | VEGETABLES

//////////////////////
//		Chinese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chinese/chowmein
	name = "chow mein"
	desc = "Что в этом вообще?"
	ru_names = list(
		NOMINATIVE = "чау-мейн",
		GENITIVE = "чау-мейна",
		DATIVE = "чау-мейну",
		ACCUSATIVE = "чау-мейн",
		INSTRUMENTAL = "чау-мейном",
		PREPOSITIONAL = "чау-мейне"
	)
	icon_state = "chinese1"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "beans" = 3, "msg" = 4, "sugar" = 1)
	tastes = list("лапши" = 1, "овощей" = 1)
	foodtype = FRIED | VEGETABLES

/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball
	name = "sweet & sour chicken balls"
	desc = "Эта курица точно приготовлена? Шансы лучше, чем в \"камень-ножницы-бумага\""
	ru_names = list(
		NOMINATIVE = "курица в кисло-сладком соусе",
		GENITIVE = "курицы в кисло-сладком соусе",
		DATIVE = "курице в кисло-сладком соусе",
		ACCUSATIVE = "курицу в кисло-сладком соусе",
		INSTRUMENTAL = "курицей в кисло-сладком соусе",
		PREPOSITIONAL = "курице в кисло-сладком соусе"
	)
	icon_state = "chickenball"
	item_state = "chinese3"
	junkiness = 25
	list_reagents = list("nutriment" = 2, "msg" = 4, "sugar" = 5)
	tastes = list("курицы" = 1, "сладкого" = 1)
	foodtype = FRIED | MEAT

/obj/item/reagent_containers/food/snacks/chinese/tao
	name = "Admiral Yamamoto carp"
	desc = "На вкус как курица."
	ru_names = list(
		NOMINATIVE = "карп адмирала Ямамото",
		GENITIVE = "карпа адмирала Ямамото",
		DATIVE = "карпу адмирала Ямамото",
		ACCUSATIVE = "карпа адмирала Ямамото",
		INSTRUMENTAL = "карпом адмирала Ямамото",
		PREPOSITIONAL = "карпе адмирала Ямамото"
	)
	icon_state = "chinese2"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "protein" = 1, "msg" = 4, "sugar" = 5)
	tastes = list("курицы" = 1)
	foodtype = FRIED | MEAT

/obj/item/reagent_containers/food/snacks/chinese/newdles
	name = "chinese newdles"
	desc = "Свежеприготовлено... на этой неделе!"
	ru_names = list(
		NOMINATIVE = "китайская лапша",
		GENITIVE = "китайской лапши",
		DATIVE = "китайской лапше",
		ACCUSATIVE = "китайскую лапшу",
		INSTRUMENTAL = "китайской лапшой",
		PREPOSITIONAL = "китайской лапше"
	)
	icon_state = "chinese3"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "msg" = 4, "sugar" = 3)
	tastes = list("лапши" = 1)
	foodtype = FRIED | GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/chinese/rice
	name = "fried rice"
	desc = "Вневременная классика."
	ru_names = list(
		NOMINATIVE = "жареный рис",
		GENITIVE = "жареного риса",
		DATIVE = "жареному рису",
		ACCUSATIVE = "жареный рис",
		INSTRUMENTAL = "жареным рисом",
		PREPOSITIONAL = "жареном рисе"
	)
	icon_state = "chinese4"
	item_state = "chinese2"
	junkiness = 20
	antable = FALSE
	list_reagents = list("nutriment" = 1, "rice" = 3, "msg" = 4, "sugar" = 1)
	tastes = list("риса" = 1)
	foodtype = FRIED | GRAIN | VEGETABLES


//////////////////////
//	Japanese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "Легендарный яичный крем, превращающий врагов в друзей. Слишком горячо для кошки."
	ru_names = list(
		NOMINATIVE = "тяванмуси",
		GENITIVE = "тяванмуси",
		DATIVE = "тяванмуси",
		ACCUSATIVE = "тяванмуси",
		INSTRUMENTAL = "тяванмуси",
		PREPOSITIONAL = "тяванмуси"
	)
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F0F2E4"
	list_reagents = list("nutriment" = 5)
	tastes = list("крема" = 1)
	foodtype = DAIRY

/obj/item/reagent_containers/food/snacks/yakiimo
	name = "yaki imo"
	desc = "Приготовлен с жареным сладким картофелем!"
	ru_names = list(
		NOMINATIVE = "якиимо",
		GENITIVE = "якиимо",
		DATIVE = "якиимо",
		ACCUSATIVE = "якиимо",
		INSTRUMENTAL = "якиимо",
		PREPOSITIONAL = "якиимо"
	)
	icon_state = "yakiimo"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 5, "vitamin" = 4)
	filling_color = "#8B1105"
	tastes = list("сладкой картошки" = 1)
	foodtype = VEGETABLES | SUGAR


//////////////////////
//	Middle Eastern	//
//////////////////////

/obj/item/reagent_containers/food/snacks/kabob
	name = "-kabob"
	desc = "Человечина на палочке."
	ru_names = list(
		NOMINATIVE = "кебаб",
		GENITIVE = "кебаба",
		DATIVE = "кебабу",
		ACCUSATIVE = "кебаб",
		INSTRUMENTAL = "кебабом",
		PREPOSITIONAL = "кебабе"
	)
	icon_state = "kabob"
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)
	foodtype = MEAT | FRIED

/obj/item/reagent_containers/food/snacks/monkeykabob
	name = "meat-kabob"
	desc = "Вкусное мясо на палочке."
	ru_names = list(
		NOMINATIVE = "мясной кебаб",
		GENITIVE = "мясного кебаба",
		DATIVE = "мясному кебабу",
		ACCUSATIVE = "мясной кебаб",
		INSTRUMENTAL = "мясным кебабом",
		PREPOSITIONAL = "мясном кебабе"
	)
	icon_state = "kabob"
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)
	foodtype = MEAT | FRIED

/obj/item/reagent_containers/food/snacks/tofukabob
	name = "tofu-kabob"
	desc = "Веганское мясо на палочке."
	ru_names = list(
		NOMINATIVE = "тофу-кебаб",
		GENITIVE = "тофу-кебаба",
		DATIVE = "тофу-кебабу",
		ACCUSATIVE = "тофу-кебаб",
		INSTRUMENTAL = "тофу-кебабом",
		PREPOSITIONAL = "тофу-кебабе"
	)
	icon_state = "kabob"
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	list_reagents = list("nutriment" = 8)
	foodtype = VEGETABLES | FRIED

//////////////////////////////////
//	North-Eastern Mediterranean	//
//////////////////////////////////

/obj/item/reagent_containers/food/snacks/shawarma
	name = "shawarma"
	desc = "Потрясающая смесь жареного мяса и свежих овощей. Не спрашивайте про мясо."
	icon_state = "shawarma"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 4, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("мяса" = 3, "овощей" = 2, "помидоров" = 1, "перца" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/shawarma/New()
	..()
	var/randname = pick("шаурм","шаварм","шаверм")
	name = pick("shaurma","shawarma","shawerma")
	ru_names = list(
		NOMINATIVE = "[randname]а",
		GENITIVE = "[randname]ы",
		DATIVE = "[randname]е",
		ACCUSATIVE = "[randname]а",
		INSTRUMENTAL = "[randname]ой",
		PREPOSITIONAL = "[randname]е"
	)

/obj/item/reagent_containers/food/snacks/doner_cheese
	name = "cheese doner"
	desc = "Фирменное блюдо – жареное мясо с овощами и тёплым сырным соусом. Вкусно!"
	ru_names = list(
		NOMINATIVE = "сырный донер",
		GENITIVE = "сырного донера",
		DATIVE = "сырному донеру",
		ACCUSATIVE = "сырный донер",
		INSTRUMENTAL = "сырным донером",
		PREPOSITIONAL = "сырном донере"
	)
	icon_state = "doner_cheese"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 6, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("мяса" = 3, "сыра" = 2, "овощей" = 2, "томатов" = 1, "перца" = 1)
	foodtype = MEAT | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/doner_mushroom
	name = "mushroom doner"
	desc = "Мясо, приготовленное на гриле, и свежие овощи. Можно также заметить грибы."
	ru_names = list(
		NOMINATIVE = "грибной донер",
		GENITIVE = "грибного донера",
		DATIVE = "грибному донеру",
		ACCUSATIVE = "грибной донер",
		INSTRUMENTAL = "грибным донером",
		PREPOSITIONAL = "грибном донере"
	)
	icon_state = "doner_mushroom"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 4, "plantmatter" = 2, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("мяса" = 3, "грибов" = 2, "овощей" = 2, "томатов" = 1, "перца" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/doner_vegan
	name = "vegan doner"
	desc = "Фирменное блюдо – жареное мясо с овощами и тёплым сырным соусом. Вкусно!"
	ru_names = list(
		NOMINATIVE = "веганский донер",
		GENITIVE = "веганского донера",
		DATIVE = "веганскому донеру",
		ACCUSATIVE = "веганский донер",
		INSTRUMENTAL = "веганским донером",
		PREPOSITIONAL = "веганском донере"
	)
	icon_state = "doner_vegan"
	filling_color = "#c0720c"
	list_reagents = list("nutriment" = 4, "plantmatter" = 4, "vitamin" = 4, "tomatojuice" = 8)
	tastes = list("овощей" = 2, "томатов" = 1, "перца" = 1)
	foodtype = VEGETABLES

//////////////////////////////////
//		North Mediterranean	//
//////////////////////////////////

/obj/item/reagent_containers/food/snacks/risotto
	name = "Risotto"
	desc = "Предложение, от которого нельзя отказаться."
	ru_names = list(
		NOMINATIVE = "ризотто",
		GENITIVE = "ризотто",
		DATIVE = "ризотто",
		ACCUSATIVE = "ризотто",
		INSTRUMENTAL = "ризотто",
		PREPOSITIONAL = "ризотто"
	)
	icon_state = "risotto"
	filling_color = "#cfae89"
	list_reagents = list("nutriment" = 5, "plantmatter" = 2, "wine" = 5)
	tastes = list("сыра" = 1, "риса" = 2, "вина" = 1)
	bitesize = 3
	foodtype = DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/bruschetta
	name = "Bruschetta"
	desc = "..."
	ru_names = list(
		NOMINATIVE = "брускетта",
		GENITIVE = "брускетты",
		DATIVE = "брускетте",
		ACCUSATIVE = "брускетту",
		INSTRUMENTAL = "брускеттой",
		PREPOSITIONAL = "брускетте"
	)
	icon_state = "bruschetta"
	trash = /obj/item/trash/plate
	filling_color = "#a30e0e"
	list_reagents = list("nutriment" = 2, "plantmatter" = 2, "tomatojucie" = 2, "garlicjucie" = 1, "salt" = 1)
	tastes = list("хлеба" = 1, "томатов" = 2, "чеснока" = 1, "сыра" = 1)
	bitesize = 4
	foodtype = DAIRY | VEGETABLES | GRAIN

/obj/item/reagent_containers/food/snacks/quiche
	name = "Quiche"
	desc = "Делает вас умнее. Давайте низшим формам жизни! Не путать с названием музыкальной группы."
	ru_names = list(
		NOMINATIVE = "киш",
		GENITIVE = "киша",
		DATIVE = "кишу",
		ACCUSATIVE = "киш",
		INSTRUMENTAL = "кишем",
		PREPOSITIONAL = "кише"
	)
	icon_state = "quiche"
	trash = /obj/item/trash/plate
	filling_color = "#cfae89"
	list_reagents = list("nutriment" = 7, "plantmatter" = 2, "tomatojucie" = 2, "garlicjucie" = 1)
	tastes = list("сыра" = 1, "томатов" = 1, "чеснока" = 1, "яиц" = 1)
	bitesize = 4
	foodtype = DAIRY | VEGETABLES
