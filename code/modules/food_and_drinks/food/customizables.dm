/obj/item/proc/make_custom_food(obj/item/reagent_containers/food/snacks/snack, mob/user, custom_type)
	. = TRUE
	if(!istype(snack) || !user.can_unEquip(snack))
		return FALSE

	var/obj/item/reagent_containers/food/snacks/customizable/custom_snack = new custom_type(drop_location())
	custom_snack.add_ingredient(snack, user)
	qdel(src)


/obj/item/reagent_containers/food/snacks/breadslice/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/sandwich))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/snacks/bun/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/burger))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/pizza))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/snacks/boiledspaghetti/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/pasta))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/trash/plate/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/fullycustom))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/trash/bowl
	name = "bowl"
	desc = "Пустая миска. Положите в неё еду, чтобы приготовить суп."
	ru_names = list(
		NOMINATIVE = "миска",
		GENITIVE = "миски",
		DATIVE = "миске",
		ACCUSATIVE = "миску",
		INSTRUMENTAL = "миской",
		PREPOSITIONAL = "миске"
	)
	icon = 'icons/obj/food/custom.dmi'
	icon_state = "soup"


/obj/item/trash/bowl/attackby(obj/item/I, mob/user, params)
	if(make_custom_food(I, user, /obj/item/reagent_containers/food/snacks/customizable/soup))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/reagent_containers/food/snacks/customizable
	name = "sandwich"
	desc = "Сэндвич! Он же бутерброд. Вечная классика."
	ru_names = list(
		NOMINATIVE = "сэндвич",
		GENITIVE = "сэндвича",
		DATIVE = "сэндвичу",
		ACCUSATIVE = "сэндвич",
		INSTRUMENTAL = "сэндвичем",
		PREPOSITIONAL = "сэндвиче"
	)
	icon = 'icons/obj/food/custom.dmi'
	icon_state = "sandwichcustom"
	var/baseicon = "sandwichcustom"
	var/basename = "sandwichcustom"
	bitesize = 4
	var/top = FALSE	//Do we have a top?
	/// The image of the top
	var/image/top_image
	var/snack_overlays = FALSE	//Do we stack?
	var/ingredient_limit = 40
	var/fullycustom = FALSE
	trash = /obj/item/trash/plate
	var/list/ingredients = list()
	list_reagents = list("nutriment" = 8)


/obj/item/reagent_containers/food/snacks/customizable/Initialize(mapload)
	. = ..()
	if(top)
		top_image = new(icon, "[baseicon]_top")
		add_overlay(top_image)
	if(snack_overlays)
		layer = ABOVE_ALL_MOB_LAYER	// all should see our monstrosity

/obj/item/reagent_containers/food/snacks/customizable/sandwich
	name = "sandwich"
	desc = "Сэндвич! Он же бутерброд. Вечная классика."
	ru_names = list(
		NOMINATIVE = "сэндвич",
		GENITIVE = "сэндвича",
		DATIVE = "сэндвичу",
		ACCUSATIVE = "сэндвич",
		INSTRUMENTAL = "сэндвичем",
		PREPOSITIONAL = "сэндвиче"
	)
	icon_state = "breadslice"
	baseicon = "sandwichcustom"
	basename = "sandwich"
	snack_overlays = TRUE

/obj/item/reagent_containers/food/snacks/customizable/pizza
	name = "personal pizza"
	desc = "Пицца на сковороде, предназначенная только для одного человека."
	ru_names = list(
		NOMINATIVE = "персональная пицца",
		GENITIVE = "персональной пиццы",
		DATIVE = "персональной пицце",
		ACCUSATIVE = "персональную пиццу",
		INSTRUMENTAL = "персональной пиццей",
		PREPOSITIONAL = "персональной пицце"
	)
	icon_state = "personal_pizza"
	baseicon = "personal_pizza"
	basename = "personal pizza"
	tastes = list("корочки" = 1, "томатов" = 1, "сыра" = 1)

/obj/item/reagent_containers/food/snacks/customizable/pasta
	name = "spaghetti"
	desc = "Макароны. С чем-то. Вкусно."
	ru_names = list(
		NOMINATIVE = "спагетти",
		GENITIVE = "спагетти",
		DATIVE = "спагетти",
		ACCUSATIVE = "спагетти",
		INSTRUMENTAL = "спагетти",
		PREPOSITIONAL = "спагетти"
	)
	icon_state = "pasta_bot"
	baseicon = "pasta_bot"
	basename = "pasta"

/obj/item/reagent_containers/food/snacks/customizable/cook/bread
	name = "bread"
	desc = "Вкусный хлеб."
	ru_names = list(
		NOMINATIVE = "хлеб",
		GENITIVE = "хлеба",
		DATIVE = "хлебу",
		ACCUSATIVE = "хлеб",
		INSTRUMENTAL = "хлебом",
		PREPOSITIONAL = "хлебе"
	)
	icon_state = "breadcustom"
	baseicon = "breadcustom"
	basename = "bread"
	tastes = list("хлеба" = 10)

/obj/item/reagent_containers/food/snacks/customizable/cook/pie
	name = "pie"
	desc = "Вкусный пирог."
	ru_names = list(
		NOMINATIVE = "пирог",
		GENITIVE = "пирога",
		DATIVE = "пирогу",
		ACCUSATIVE = "пирог",
		INSTRUMENTAL = "пирогом",
		PREPOSITIONAL = "пироге"
	)
	icon_state = "piecustom"
	baseicon = "piecustom"
	basename = "pie"
	tastes = list("пирога" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/cake
	name = "cake"
	desc = "Вкусный торт."
	ru_names = list(
		NOMINATIVE = "торт",
		GENITIVE = "торта",
		DATIVE = "торту",
		ACCUSATIVE = "торт",
		INSTRUMENTAL = "тортом",
		PREPOSITIONAL = "торте"
	)
	icon_state = "cakecustom"
	baseicon = "cakecustom"
	basename = "cake"
	tastes = list("тортика" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/jelly
	name = "jelly"
	desc = "Полностью желеобразно."
	ru_names = list(
		NOMINATIVE = "желе",
		GENITIVE = "желе",
		DATIVE = "желе",
		ACCUSATIVE = "желе",
		INSTRUMENTAL = "желе",
		PREPOSITIONAL = "желе"
	)
	icon_state = "jellycustom"
	baseicon = "jellycustom"
	basename = "jelly"

/obj/item/reagent_containers/food/snacks/customizable/cook/donkpocket
	name = "donk pocket"
	desc = "Хочешь положить круто... Ой, неважно."
	ru_names = list(
		NOMINATIVE = "донк-покет",
		GENITIVE = "донк-покета",
		DATIVE = "донк-покету",
		ACCUSATIVE = "донк-покет",
		INSTRUMENTAL = "донк-покетом",
		PREPOSITIONAL = "донк-покете"
	)
	icon_state = "donkcustom"
	baseicon = "donkcustom"
	basename = "donk pocket"

/obj/item/reagent_containers/food/snacks/customizable/cook/kebab
	name = "kebab"
	desc = "Кебаб или шашлык?"
	ru_names = list(
		NOMINATIVE = "кебаб",
		GENITIVE = "кебаба",
		DATIVE = "кебабу",
		ACCUSATIVE = "кебаб",
		INSTRUMENTAL = "кебабом",
		PREPOSITIONAL = "кебабе"
	)
	icon_state = "kababcustom"
	baseicon = "kababcustom"
	basename = "kebab"
	tastes = list("мяса" = 3, "металла" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/salad
	name = "salad"
	desc = "Очень вкусно."
	ru_names = list(
		NOMINATIVE = "салат",
		GENITIVE = "салата",
		DATIVE = "салату",
		ACCUSATIVE = "салат",
		INSTRUMENTAL = "салатом",
		PREPOSITIONAL = "салате"
	)
	icon_state = "saladcustom"
	baseicon = "saladcustom"
	basename = "salad"
	tastes = list("листьев" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/waffles
	name = "waffles"
	desc = "Сделано с любовью."
	ru_names = list(
		NOMINATIVE = "вафли",
		GENITIVE = "вафель",
		DATIVE = "вафлям",
		ACCUSATIVE = "вафли",
		INSTRUMENTAL = "вафлями",
		PREPOSITIONAL = "вафлях"
	)
	icon_state = "wafflecustom"
	baseicon = "wafflecustom"
	basename = "waffles"
	tastes = list("вафлей" = 1)

/obj/item/reagent_containers/food/snacks/customizable/candy/cookie
	name = "cookie"
	desc = "ПЕЧЕНЬЕ!!1!"
	ru_names = list(
		NOMINATIVE = "печенье",
		GENITIVE = "печенья",
		DATIVE = "печенью",
		ACCUSATIVE = "печенье",
		INSTRUMENTAL = "печеньем",
		PREPOSITIONAL = "печенье"
	)
	icon_state = "cookiecustom"
	baseicon = "cookiecustom"
	basename = "cookie"
	tastes = list("печенья" = 1)

/obj/item/reagent_containers/food/snacks/customizable/candy/cotton
	name = "flavored cotton candy"
	desc = "Who can take a sunrise, sprinkle it with dew,"
	ru_names = list(
		NOMINATIVE = "ароматизированная сахарная вата",
		GENITIVE = "ароматизированной сахарной ваты",
		DATIVE = "ароматизированной сахарной вате",
		ACCUSATIVE = "ароматизированную сахарную вату",
		INSTRUMENTAL = "ароматизированной сахарной ватой",
		PREPOSITIONAL = "ароматизированной сахарной вате"
	)
	icon_state = "cottoncandycustom"
	baseicon = "cottoncandycustom"
	basename = "flavored cotton candy"

/obj/item/reagent_containers/food/snacks/customizable/candy/gummybear
	name = "flavored giant gummy bear"
	desc = "Cover it in chocolate and a miracle or two,"
	ru_names = list(
		NOMINATIVE = "ароматизированный гигантский мармеладный мишка",
		GENITIVE = "ароматизированного гигантского мармеладного мишки",
		DATIVE = "ароматизированному гигантскому мармеладному мишке",
		ACCUSATIVE = "ароматизированный гигантский мармеладный мишка",
		INSTRUMENTAL = "ароматизированным гигантским мармеладным мишкой",
		PREPOSITIONAL = "ароматизированном гигантском мармеладном мишке"
	)
	icon_state = "gummybearcustom"
	baseicon = "gummybearcustom"
	basename = "flavored giant gummy bear"

/obj/item/reagent_containers/food/snacks/customizable/candy/gummyworm
	name = "flavored giant gummy worm"
	desc = "The Candy Man can 'cause he mixes it with love,"
	ru_names = list(
		NOMINATIVE = "ароматизированный гигантский мармеладный червяк",
		GENITIVE = "ароматизированного гигантского мармеладного червяка",
		DATIVE = "ароматизированному гигантскому мармеладному червяку",
		ACCUSATIVE = "ароматизированный гигантский мармеладный червяк",
		INSTRUMENTAL = "ароматизированным гигантским мармеладным червяком",
		PREPOSITIONAL = "ароматизированном гигантском мармеладном червяке"
	)
	icon_state = "gummywormcustom"
	baseicon = "gummywormcustom"
	basename = "flavored giant gummy worm"

/obj/item/reagent_containers/food/snacks/customizable/candy/jellybean
	name = "flavored giant jelly bean"
	desc = "And makes the world taste good."
	ru_names = list(
		NOMINATIVE = "ароматизированный гигантский мармеладный боб",
		GENITIVE = "ароматизированного гигантского мармеладного боба",
		DATIVE = "ароматизированному гигантскому мармеладному бобу",
		ACCUSATIVE = "ароматизированный гигантский мармеладный боб",
		INSTRUMENTAL = "ароматизированным гигантским мармеладным бобом",
		PREPOSITIONAL = "ароматизированном гигантском мармеладном бобе"
	)
	icon_state = "jellybeancustom"
	baseicon = "jellybeancustom"
	basename = "flavored giant jelly bean"

/obj/item/reagent_containers/food/snacks/customizable/candy/jawbreaker
	name = "flavored jawbreaker"
	desc = "Who can take a rainbow, Wrap it in a sigh,"
	ru_names = list(
		NOMINATIVE = "ароматизированный гигантский чупа-чупс",
		GENITIVE = "ароматизированного гигантского чупа-чупса",
		DATIVE = "ароматизированному гигантскому чупа-чупсу",
		ACCUSATIVE = "ароматизированный гигантский чупа-чупс",
		INSTRUMENTAL = "ароматизированным гигантским чупа-чупсом",
		PREPOSITIONAL = "ароматизированном гигантском чупа-чупсе"
	)
	icon_state = "jawbreakercustom"
	baseicon = "jawbreakercustom"
	basename = "flavored jawbreaker"

/obj/item/reagent_containers/food/snacks/customizable/candy/candycane
	name = "flavored candy cane"
	desc = "Soak it in the sun and make strawberry-lemon pie,"
	ru_names = list(
		NOMINATIVE = "ароматизированная леденцовая трость",
		GENITIVE = "ароматизированной леденцовой трости",
		DATIVE = "ароматизированной леденцовой трости",
		ACCUSATIVE = "ароматизированную леденцовую трость",
		INSTRUMENTAL = "ароматизированной леденцовой тростью",
		PREPOSITIONAL = "ароматизированной леденцовой трости"
	)
	icon_state = "candycanecustom"
	baseicon = "candycanecustom"
	basename = "flavored candy cane"

/obj/item/reagent_containers/food/snacks/customizable/candy/gum
	name = "flavored gum"
	desc = "The Candy Man can 'cause he mixes it with love and makes the world taste good. And the world tastes good 'cause the Candy Man thinks it should..."
	ru_names = list(
		NOMINATIVE = "ароматизированная жвачка",
		GENITIVE = "ароматизированной жвачки",
		DATIVE = "ароматизированной жвачке",
		ACCUSATIVE = "ароматизированную жвачку",
		INSTRUMENTAL = "ароматизированной жвачкой",
		PREPOSITIONAL = "ароматизированной жвачке"
	)
	icon_state = "gumcustom"
	baseicon = "gumcustom"
	basename = "flavored gum"

/obj/item/reagent_containers/food/snacks/customizable/candy/donut
	name = "filled donut"
	desc = "Не пончись на этом!" // kill me
	ru_names = list(
		NOMINATIVE = "пончик с начинкой",
		GENITIVE = "пончика с начинкой",
		DATIVE = "пончику с начинкой",
		ACCUSATIVE = "пончик с начинкой",
		INSTRUMENTAL = "пончиком с начинкой",
		PREPOSITIONAL = "пончике с начинкой"
	)
	icon_state = "donutcustom"
	baseicon = "donutcustom"
	basename = "filled donut"

/obj/item/reagent_containers/food/snacks/customizable/candy/bar
	name = "flavored chocolate bar"
	desc = "Сделано на фабрике в центре города."
	ru_names = list(
		NOMINATIVE = "ароматизированная шоколадная плитка",
		GENITIVE = "ароматизированной шоколадной плитки",
		DATIVE = "ароматизированной шоколадной плитке",
		ACCUSATIVE = "ароматизированную шоколадную плитку",
		INSTRUMENTAL = "ароматизированной шоколадной плиткой",
		PREPOSITIONAL = "ароматизированной шоколадной плитке"
	)
	icon_state = "barcustom"
	baseicon = "barcustom"
	basename = "flavored chocolate bar"

/obj/item/reagent_containers/food/snacks/customizable/candy/sucker
	name = "flavored sucker"
	desc = "Пососи."
	ru_names = list(
		NOMINATIVE = "ароматизированный леденец",
		GENITIVE = "ароматизированного леденца",
		DATIVE = "ароматизированному леденцу",
		ACCUSATIVE = "ароматизированный леденец",
		INSTRUMENTAL = "ароматизированным леденцом",
		PREPOSITIONAL = "ароматизированном леденце"
	)
	icon_state = "suckercustom"
	baseicon = "suckercustom"
	basename = "flavored sucker"

/obj/item/reagent_containers/food/snacks/customizable/candy/cash
	name = "flavored chocolate cash"
	desc = "У меня их куча!"
	ru_names = list(
		NOMINATIVE = "ароматизированные шоколадные деньги",
		GENITIVE = "ароматизированных шоколадных денег",
		DATIVE = "ароматизированным шоколадным деньгам",
		ACCUSATIVE = "ароматизированные шоколадные деньги",
		INSTRUMENTAL = "ароматизированными шоколадными деньгами",
		PREPOSITIONAL = "ароматизированных шоколадных деньгах"
	)
	icon_state = "cashcustom"
	baseicon = "cashcustom"
	basename = "flavored cash"

/obj/item/reagent_containers/food/snacks/customizable/candy/coin
	name = "flavored chocolate coin"
	desc = "Дзынь, дзынь, дзынь."
	ru_names = list(
		NOMINATIVE = "ароматизированная шоколадная монета",
		GENITIVE = "ароматизированной шоколадной монеты",
		DATIVE = "ароматизированной шоколадной монете",
		ACCUSATIVE = "ароматизированную шоколадную монету",
		INSTRUMENTAL = "ароматизированной шоколадной монетой",
		PREPOSITIONAL = "ароматизированной шоколадной монете"
	)
	icon_state = "coincustom"
	baseicon = "coincustom"
	basename = "flavored coin"

/obj/item/reagent_containers/food/snacks/customizable/fullycustom // In the event you fuckers find something I forgot to add a customizable food for.
	name = "on a plate"
	desc = "Уникальное блюдо."
	ru_names = list(
		NOMINATIVE = "на тарелке",
		GENITIVE = "на тарелке",
		DATIVE = "на тарелке",
		ACCUSATIVE = "на тарелке",
		INSTRUMENTAL = "на тарелке",
		PREPOSITIONAL = "на тарелке"
	)
	icon_state = "fullycustom"
	baseicon = "fullycustom"
	basename = "on a plate"
	ingredient_limit = 20
	fullycustom = TRUE

/obj/item/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "Миска с жидкостью и... чем-то ещё."
	ru_names = list(
		NOMINATIVE = "суп",
		GENITIVE = "супа",
		DATIVE = "супу",
		ACCUSATIVE = "суп",
		INSTRUMENTAL = "супом",
		PREPOSITIONAL = "супе"
	)
	icon_state = "soup"
	baseicon = "soup"
	basename = "soup"
	trash = /obj/item/trash/bowl
	tastes = list("супа" = 1)

/obj/item/reagent_containers/food/snacks/customizable/burger
	name = "burger bun"
	desc = "Булочка для бургера. Вкусно."
	ru_names = list(
		NOMINATIVE = "булочка для бургера",
		GENITIVE = "булочки для бургера",
		DATIVE = "булочке для бургера",
		ACCUSATIVE = "булочку для бургера",
		INSTRUMENTAL = "булочкой для бургера",
		PREPOSITIONAL = "булочке для бургера"
	)
	icon_state = "burger"
	baseicon = "burgercustom"
	basename = "burger"
	top = TRUE
	snack_overlays = TRUE
	tastes = list("булочки" = 4)


/obj/item/reagent_containers/food/snacks/customizable/Destroy()
	QDEL_LIST(ingredients)
	return ..()


/obj/item/reagent_containers/food/snacks/customizable/examine(mob/user)
	. = ..()
	if(LAZYLEN(ingredients))
		var/whatsinside = pick(ingredients)
		. += span_notice("Кажется, вы различаете [whatsinside] внутри.")


/obj/item/reagent_containers/food/snacks/customizable/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/reagent_containers/food/snacks))
		to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] — не совсем то, что можно съесть."))
		return ..()

	if(!user.can_unEquip(I))
		return ..()

	if(add_ingredient(I, user))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/**
 * Tries to add one ingredient and it's ingredients, if any and applicable, to this snack
 *
 * Arguments:
 * * snack - The ingredient that will be added
 * * user - chef
 */
/obj/item/reagent_containers/food/snacks/customizable/proc/add_ingredient(obj/item/reagent_containers/food/snacks/snack, mob/user)
	. = FALSE

	add_fingerprint(user)
	if(length(ingredients) > ingredient_limit)
		to_chat(user, span_warning("Если вы добавите что-то ещё в [declent_ru(ACCUSATIVE)], получится беспорядок."))
		return .

	// Fully custom snacks don't add the ingredients. So no need to check
	var/fullycustom_check = !fullycustom && istype(snack, /obj/item/reagent_containers/food/snacks/customizable)
	if(fullycustom_check)
		var/obj/item/reagent_containers/food/snacks/customizable/origin = snack
		if(length(ingredients) + length(origin.ingredients) > ingredient_limit)
			to_chat(user, span_warning("Соединение [snack.declent_ru(GENITIVE)] и [declent_ru(GENITIVE)] создаст беспорядок."))
			return .

	. = TRUE

	to_chat(user, span_notice("Вы добавляете [snack.declent_ru(GENITIVE)] в [declent_ru(ACCUSATIVE)]."))
	user.drop_transfer_item_to_loc(snack, src)
	snack.reagents.trans_to(src, snack.reagents.total_volume)

	var/list/added_ingredients = list(snack)

	// Only merge when it is not fullycustom. Else it looks weird
	if(fullycustom_check)
		var/obj/item/reagent_containers/food/snacks/customizable/origin = snack
		added_ingredients += origin.ingredients
		origin.ingredients.Cut()
		origin.name = initial(origin.name) // Reset the name for the examine text

	cooktype[basename] = TRUE
	add_ingredients(added_ingredients)
	name = newname()


/obj/item/reagent_containers/food/snacks/customizable/proc/add_ingredients(list/new_ingredients)
	cut_overlay(top_image) // Remove the top image so we can change it again

	var/ingredient_num = length(ingredients)
	ingredients += new_ingredients
	for(var/obj/item/reagent_containers/food/snacks/food as anything in new_ingredients)
		ingredient_num++
		var/image/ingredient_image
		if(!fullycustom)
			ingredient_image = new(icon, "[baseicon]_filling")
			if(!food.filling_color == "#FFFFFF")
				ingredient_image.color = food.filling_color
			else
				ingredient_image.color = pick("#FF0000", "#0000FF", "#008000", "#FFFF00")
			if(snack_overlays)
				ingredient_image.pixel_x = rand(2) - 1
				ingredient_image.pixel_y = ingredient_num * 2 + 1
		else
			ingredient_image = new(food.icon, food.icon_state)
			ingredient_image.pixel_x = rand(2) - 1
			ingredient_image.pixel_y = rand(2) - 1
			add_overlay(food.overlays)

		add_overlay(ingredient_image)

	if(top_image)
		top_image.pixel_x = rand(2) - 1
		top_image.pixel_y = ingredient_num * 2 + 1
		add_overlay(top_image)


/obj/item/reagent_containers/food/snacks/customizable/proc/newname()
	var/unsorteditems[0]
	var/sorteditems[0]
	var/unsortedtypes[0]
	var/sortedtypes[0]
	var/endpart = ""
	var/c = 0
	var/ci = 0
	var/ct = 0
	var/seperator = ""
	var/sendback = ""
	var/list/levels = list("", "двойной", "тройной", "квадро", "огромный")

	for(var/obj/item/ing in ingredients)
		if(istype(ing, /obj/item/shard))
			continue


		if(istype(ing, /obj/item/reagent_containers/food/snacks/customizable))				// split the ingredients into ones with basenames (sandwich, burger, etc) and ones without, keeping track of how many of each there are
			var/obj/item/reagent_containers/food/snacks/customizable/gettype = ing
			if(unsortedtypes[gettype.basename])
				unsortedtypes[gettype.basename]++
				if(unsortedtypes[gettype.basename] > ct)
					ct = unsortedtypes[gettype.basename]
			else
				(unsortedtypes[gettype.basename]) = 1
				if(unsortedtypes[gettype.basename] > ct)
					ct = unsortedtypes[gettype.basename]
		else
			if(unsorteditems[ing.name])
				unsorteditems[ing.name]++
				if(unsorteditems[ing.name] > ci)
					ci = unsorteditems[ing.name]
			else
				unsorteditems[ing.name] = 1
				if(unsorteditems[ing.name] > ci)
					ci = unsorteditems[ing.name]

	sorteditems = sortlist(unsorteditems, ci)				//order both types going from the lowest number to the highest number
	sortedtypes = sortlist(unsortedtypes, ct)

	for(var/ings in sorteditems)			   //add the non-basename items to the name, sorting out the , and the and
		c++
		if(c == sorteditems.len - 1)
			seperator = " и "
		else if(c == sorteditems.len)
			seperator = " "
		else
			seperator = ", "

		if(sorteditems[ings] > levels.len)
			sorteditems[ings] = levels.len

		if(sorteditems[ings] <= 1)
			sendback +="[ings][seperator]"
		else
			sendback +="[levels[sorteditems[ings]]] [ings][seperator]"

	for(var/ingtype in sortedtypes)   // now add the types basenames, keeping the src one seperate so it can go on the end
		if(sortedtypes[ingtype] > levels.len)
			sortedtypes[ingtype] = levels.len
		if(ingtype == basename)
			if(sortedtypes[ingtype] < levels.len)
				sortedtypes[ingtype]++
			endpart = "[levels[sortedtypes[ingtype]]] decker [basename]"
			continue
		if(sortedtypes[ingtype] >= 2)
			sendback += "[levels[sortedtypes[ingtype]]] decker [ingtype] "
		else
			sendback += "[ingtype] "

	if(endpart)
		sendback += endpart
	else
		sendback += basename

	if(length(sendback) > 80)
		sendback = "[pick(list("абсурдный","колоссальный","огромный","нелепый","массивный","гигантский","вызывающий инфаркт","забивающий артерии","съедобный но тошнотворный","тошнотворный","громадный","мега","разрывающий живот","разрывающий грудь"))] [basename]"
	return sendback


/obj/item/reagent_containers/food/snacks/customizable/proc/sortlist(list/unsorted, highest)
	var/sorted[0]
	for(var/i = 1, i<= highest, i++)
		for(var/it in unsorted)
			if(unsorted[it] == i)
				sorted[it] = i
	return sorted

