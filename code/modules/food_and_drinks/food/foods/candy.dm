

// ***********************************************************
// Candy! Delicious and sugary candy!
// Separated for organization and such
// ***********************************************************

//Candy / Candy Ingredients
//Subclass so we can pass on values
/obj/item/reagent_containers/food/snacks/candy
	name = "generic candy"
	desc = "Конфета с базовым вкусом... Эй, как она тут оказалась?!"
	ru_names = list(
		NOMINATIVE = "обычная конфета",
		GENITIVE = "обычной конфеты",
		DATIVE = "обычной конфете",
		ACCUSATIVE = "обычную конфету",
		INSTRUMENTAL = "обычной конфетой",
		PREPOSITIONAL = "обычной конфете"
	)
	icon = 'icons/obj/food/candy.dmi'
	icon_state = "candy"
	tastes = list("конфет" = 1)
	foodtype = SUGAR

// ***********************************************************
// Candy Ingredients / Flavorings / Byproduct
// ***********************************************************

/obj/item/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Сладкая и калорийная еда."
	ru_names = list(
		NOMINATIVE = "шоколадный батончик",
		GENITIVE = "шоколадного батончика",
		DATIVE = "шоколадному батончику",
		ACCUSATIVE = "шоколадный батончик",
		INSTRUMENTAL = "шоколадным батончиком",
		PREPOSITIONAL = "шоколадном батончике"
	)
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 2, "chocolate" = 4)
	tastes = list("шоколада" = 1)

/obj/item/reagent_containers/food/snacks/candy/caramel
	name = "caramel"
	desc = "Вязкая и плотная, но буквально тает во рту!"
	ru_names = list(
		NOMINATIVE = "карамель",
		GENITIVE = "карамели",
		DATIVE = "карамели",
		ACCUSATIVE = "карамель",
		INSTRUMENTAL = "карамелью",
		PREPOSITIONAL = "карамели"
	)
	icon_state = "caramel"
	filling_color = "#DB944D"
	list_reagents = list("cream" = 2, "sugar" = 2)


/obj/item/reagent_containers/food/snacks/candy/toffee
	name = "toffee"
	desc = "Твёрдая хрустящая конфета с характерным вкусом."
	ru_names = list(
		NOMINATIVE = "ириска",
		GENITIVE = "ириски",
		DATIVE = "ириске",
		ACCUSATIVE = "ириску",
		INSTRUMENTAL = "ириской",
		PREPOSITIONAL = "ириске"
	)
	icon_state = "toffee"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/nougat
	name = "nougat"
	desc = "Мягкая жевательная конфета, часто встречается в шоколадных батончиках."
	ru_names = list(
		NOMINATIVE = "нуга",
		GENITIVE = "нуги",
		DATIVE = "нуге",
		ACCUSATIVE = "нугу",
		INSTRUMENTAL = "нугой",
		PREPOSITIONAL = "нуге"
	)
	icon_state = "nougat"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 5)

/obj/item/reagent_containers/food/snacks/candy/taffy
	name = "saltwater taffy"
	desc = "Старомодная солёная ириска. Очень тягучая!"
	ru_names = list(
		NOMINATIVE = "солёная ириска",
		GENITIVE = "солёной ириски",
		DATIVE = "солёной ириске",
		ACCUSATIVE = "солёную ириску",
		INSTRUMENTAL = "солёной ириской",
		PREPOSITIONAL = "солёной ириске"
	)
	icon_state = "candy1"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 5)

/obj/item/reagent_containers/food/snacks/candy/taffy/New()
	..()
	icon_state = pick("candy1", "candy2", "candy3", "candy4", "candy5")

/obj/item/reagent_containers/food/snacks/candy/fudge
	name = "fudge"
	desc = "Шоколадная помадка – вечная классика."
	ru_names = list(
		NOMINATIVE = "помадка",
		GENITIVE = "помадки",
		DATIVE = "помадке",
		ACCUSATIVE = "помадку",
		INSTRUMENTAL = "помадкой",
		PREPOSITIONAL = "помадке"
	)
	icon_state = "fudge"
	filling_color = "#7D5F46"
	bitesize = 3
	list_reagents = list("cream" = 3, "chocolate" = 6)

/obj/item/reagent_containers/food/snacks/candy/fudge/peanut
	name = "peanut fudge"
	desc = "Шоколадная помадка с кусочками арахиса. Не для людей с аллергией на орехи."
	ru_names = list(
		NOMINATIVE = "помадка с арахисом",
		GENITIVE = "помадки с арахисом",
		DATIVE = "помадке с арахисом",
		ACCUSATIVE = "помадку с арахисом",
		INSTRUMENTAL = "помадкой с арахисом",
		PREPOSITIONAL = "помадке с арахисом"
	)
	icon_state = "fudge_peanut"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/fudge/cherry
	name = "chocolate cherry fudge"
	desc = "Шоколадная помадка со сладкими вишнями. Хороший способ заставить детей есть фрукты."
	ru_names = list(
		NOMINATIVE = "шоколадная помадка с вишней",
		GENITIVE = "шоколадной помадки с вишней",
		DATIVE = "шоколадной помадке с вишней",
		ACCUSATIVE = "шоколадную помадку с вишней",
		INSTRUMENTAL = "шоколадной помадкой с вишней",
		PREPOSITIONAL = "шоколадной помадке с вишней"
	)
	icon_state = "fudge_cherry"
	filling_color = "#7D5F46"
	foodtype = SUGAR | FRUIT

/obj/item/reagent_containers/food/snacks/candy/fudge/cookies_n_cream
	name = "cookies 'n' cream fudge"
	desc = "Особенно кремовая помадка с кусочками печенья. Хрустит!"
	ru_names = list(
		NOMINATIVE = "помадка \"печенье-крем\"",
		GENITIVE = "помадки \"печенье-крем\"",
		DATIVE = "помадке \"печенье-крем\"",
		ACCUSATIVE = "помадку \"печенье-крем\"",
		INSTRUMENTAL = "помадкой \"печенье-крем\"",
		PREPOSITIONAL = "помадке \"печенье-крем\""
	)
	icon_state = "fudge_cookies_n_cream"
	filling_color = "#7D5F46"
	list_reagents = list("cream" = 6, "chocolate" = 6)

/obj/item/reagent_containers/food/snacks/candy/fudge/turtle
	name = "turtle fudge"
	desc = "Шоколадная помадка с карамелью и орехами. Настоящих черепах не содержит, к счастью."
	ru_names = list(
		NOMINATIVE = "помадка \"черепашка\"",
		GENITIVE = "помадки \"черепашка\"",
		DATIVE = "помадке \"черепашка\"",
		ACCUSATIVE = "помадку \"черепашка\"",
		INSTRUMENTAL = "помадкой \"черепашка\"",
		PREPOSITIONAL = "помадке \"черепашка\""
	)
	icon_state = "fudge_turtle"
	filling_color = "#7D5F46"

// ***********************************************************
// Candy Products (Pre-existing)
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/mre
	name = "MRE"
	desc = "Готовый к употреблению рацион."
	ru_names = list(
		NOMINATIVE = "ИРП",
		GENITIVE = "ИРП",
		DATIVE = "ИРП",
		ACCUSATIVE = "ИРП",
		INSTRUMENTAL = "ИРП",
		PREPOSITIONAL = "ИРП"
	)
	trash = /obj/item/trash/candy
	bitesize = 5
	list_reagents = list("nutriment" = 30, "sugar" = 10)

/obj/item/reagent_containers/food/snacks/candy/donor
	name = "donor candy"
	desc = "Небольшое угощение для доноров крови."
	ru_names = list(
		NOMINATIVE = "конфета донора",
		GENITIVE = "конфеты донора",
		DATIVE = "конфете донора",
		ACCUSATIVE = "конфету донора",
		INSTRUMENTAL = "конфетой донора",
		PREPOSITIONAL = "конфете донора"
	)
	trash = /obj/item/trash/candy
	bitesize = 5
	list_reagents = list("nutriment" = 10, "sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/candy_corn
	name = "candy corn"
	desc = "Горсть конфет в форме кукурузы. Увы, в шляпе детектива не поместится."
	ru_names = list(
		NOMINATIVE = "конфета-кукурузка",
		GENITIVE = "конфеты-кукурузки",
		DATIVE = "конфете-кукурузке",
		ACCUSATIVE = "конфету-кукурузку",
		INSTRUMENTAL = "конфетой-кукурузкой",
		PREPOSITIONAL = "конфете-кукурузке"
	)
	icon_state = "candycorn"
	filling_color = "#FFFCB0"
	list_reagents = list("nutriment" = 4, "sugar" = 1)
	tastes = list("сахарной кукурузы" = 1)

// ***********************************************************
// Candy Products (plain / unflavored)
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/cotton
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	ru_names = list(
		NOMINATIVE = "сахарная вата",
		GENITIVE = "сахарной ваты",
		DATIVE = "сахарной вате",
		ACCUSATIVE = "сахарную вату",
		INSTRUMENTAL = "сахарной ватой",
		PREPOSITIONAL = "сахарной вате"
	)
	icon_state = "cottoncandy_plain"
	trash = /obj/item/c_tube
	filling_color = "#FFFFFF"
	bitesize = 4
	list_reagents = list("sugar" = 10)

/obj/item/reagent_containers/food/snacks/candy/candybar
	name = "candy"
	desc = "Шоколадная конфета в фольге."
	ru_names = list(
		NOMINATIVE = "конфета",
		GENITIVE = "конфеты",
		DATIVE = "конфете",
		ACCUSATIVE = "конфету",
		INSTRUMENTAL = "конфетой",
		PREPOSITIONAL = "конфете"
	)
	icon_state = "candy"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"
	bitesize = 3
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "chocolate" = 1)
	tastes = list("шоколада" = 1)


/obj/item/reagent_containers/food/snacks/candy/candycane
	name = "candy cane"
	desc = "Праздничный мятный леденец в форме трости."
	ru_names = list(
		NOMINATIVE = "леденец-трость",
		GENITIVE = "леденца-трости",
		DATIVE = "леденцу-трости",
		ACCUSATIVE = "леденец-трость",
		INSTRUMENTAL = "леденцом-тростью",
		PREPOSITIONAL = "леденце-трости"
	)
	icon_state = "candycane"
	filling_color = "#F2F2F2"
	list_reagents = list("minttoxin" = 1, "sugar" = 5)

/obj/item/reagent_containers/food/snacks/candy/gummybear
	name = "gummy bear"
	desc = "Маленький съедобный мишка. Мягкий и тягучий!"
	ru_names = list(
		NOMINATIVE = "жевательный мишка",
		GENITIVE = "жевательного мишки",
		DATIVE = "жевательному мишке",
		ACCUSATIVE = "жевательный мишка",
		INSTRUMENTAL = "жевательным мишкой",
		PREPOSITIONAL = "жевательном мишке"
	)
	icon_state = "gbear"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("sugar" = 5)

/obj/item/reagent_containers/food/snacks/candy/gummyworm
	name = "gummy worm"
	desc = "Съедобный червяк из желатина."
	ru_names = list(
		NOMINATIVE = "жевательный червячок",
		GENITIVE = "жевательного червячка",
		DATIVE = "жевательному червячку",
		ACCUSATIVE = "жевательный червячок",
		INSTRUMENTAL = "жевательным червячком",
		PREPOSITIONAL = "жевательном червячке"
	)
	icon_state = "gworm"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("sugar" = 5)

/obj/item/reagent_containers/food/snacks/candy/jellybean
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования."
	ru_names = list(
		NOMINATIVE = "желейная конфета",
		GENITIVE = "желейной конфеты",
		DATIVE = "желейной конфете",
		ACCUSATIVE = "желейную конфету",
		INSTRUMENTAL = "желейной конфетой",
		PREPOSITIONAL = "желейной конфете"
	)
	icon_state = "jbean"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/jawbreaker
	name = "jawbreaker"
	desc = "Невероятно твёрдый леденец. Название говорит само за себя."
	ru_names = list(
		NOMINATIVE = "сокрушитель зубов",
		GENITIVE = "сокрушителя зубов",
		DATIVE = "сокрушителю зубов",
		ACCUSATIVE = "сокрушитель зубов",
		INSTRUMENTAL = "сокрушителем зубов",
		PREPOSITIONAL = "сокрушителе зубов"
	)
	icon_state = "jawbreaker"
	filling_color = "#ED0758"
	bitesize = 0.1	//this is gonna take a while, you'll be working at this all shift.
	list_reagents = list("sugar" = 5)

/obj/item/reagent_containers/food/snacks/candy/cash
	name = "candy cash"
	desc = "Не является платёжным средством. Зато вкусная."
	ru_names = list(
		NOMINATIVE = "конфета-деньги",
		GENITIVE = "конфеты-деньги",
		DATIVE = "конфете-деньги",
		ACCUSATIVE = "конфету-деньги",
		INSTRUMENTAL = "конфетой-деньги",
		PREPOSITIONAL = "конфете-деньги"
	)
	icon_state = "candy_cash"
	filling_color = "#302000"
	list_reagents = list("nutriment" = 2, "chocolate" = 4)
	tastes = list("шоколада" = 1)


/obj/item/reagent_containers/food/snacks/candy/coin
	name = "chocolate coin"
	desc = "В торговых автоматах, наверное, не сработает."
	ru_names = list(
		NOMINATIVE = "шоколадная монета",
		GENITIVE = "шоколадной монеты",
		DATIVE = "шоколадной монете",
		ACCUSATIVE = "шоколадную монету",
		INSTRUMENTAL = "шоколадной монетой",
		PREPOSITIONAL = "шоколадной монете"
	)
	icon_state = "choc_coin"
	filling_color = "#302000"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "chocolate" = 4)
	tastes = list("шоколада" = 1)


/obj/item/reagent_containers/food/snacks/candy/gum
	name = "bubblegum"
	desc = "Тянется!"
	ru_names = list(
		NOMINATIVE = "жвачка",
		GENITIVE = "жвачки",
		DATIVE = "жвачке",
		ACCUSATIVE = "жвачку",
		INSTRUMENTAL = "жвачкой",
		PREPOSITIONAL = "жвачке"
	)
	icon_state = "bubblegum"
	trash = /obj/item/trash/gum
	filling_color = "#FF7495"
	bitesize = 0.2
	list_reagents = list("sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/sucker
	name = "sucker"
	desc = "Для тех, кто хорошо себя ведёт!"
	ru_names = list(
		NOMINATIVE = "леденец",
		GENITIVE = "леденца",
		DATIVE = "леденцу",
		ACCUSATIVE = "леденец",
		INSTRUMENTAL = "леденцом",
		PREPOSITIONAL = "леденце"
	)
	icon_state = "sucker"
	filling_color = "#FFFFFF"
	list_reagents = list("sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/sucker/lollipop
	name = "lollipop"
	desc = "Для самых храбрых пациентов!"
	ru_names = list(
		NOMINATIVE = "леденец на палочке",
		GENITIVE = "леденца на палочке",
		DATIVE = "леденцу на палочке",
		ACCUSATIVE = "леденец на палочке",
		INSTRUMENTAL = "леденцом на палочке",
		PREPOSITIONAL = "леденце на палочке"
	)
	icon_state = "sucker"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 2)

/obj/item/reagent_containers/food/snacks/candy/sucker/lollipop/New()
	. = ..()
	icon_state = pick("sucker_blue", "sucker_green", "sucker_orange", "sucker_purple", "sucker_red", "sucker_yellow")

// ***********************************************************
// Gummy Bear Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/gummybear/red
	name = "gummy bear"
	desc = "Маленький съедобный мишка. Красный!"
	icon_state = "gbear_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 5, "cherryjelly" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/blue
	name = "gummy bear"
	desc = "Маленький съедобный мишка. Синий!"
	icon_state = "gbear_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 5, "berryjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/poison
	name = "gummy bear"
	desc = "Маленький съедобный мишка. Синий!"
	icon_state = "gbear_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)

/obj/item/reagent_containers/food/snacks/candy/gummybear/green
	name = "gummy bear"
	desc = "Маленький съедобный мишка. Зелёный!"
	icon_state = "gbear_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 5, "limejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/yellow
	name = "gummy bear"
	desc = "Маленький съедобный мишка. Желтый!"
	icon_state = "gbear_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 5, "lemonjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/orange
	name = "gummy bear"
	desc = "Маленький съедобный мишка. Оранжевый!"
	icon_state = "gbear_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 5, "orangejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/purple
	name = "gummy bear"
	desc = "Маленький съедобный мишка. Фиолетовый!"
	icon_state = "gbear_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 5, "grapejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/wtf
	name = "gummy bear"
	desc = "Маленький мишка... Погодите... чего?"
	icon_state = "gbear_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 5, "space_drugs" = 2)

// ***********************************************************
// Gummy Worm Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "Съедобный червякок из желатина. Красный!"
	icon_state = "gworm_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 5, "cherryjelly" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "Съедобный червякок из желатина. Синий!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 5, "berryjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/poison
	name = "gummy worm"
	desc = "Съедобный червякок из желатина. Синий!"
	icon_state = "gworm_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)
	foodtype = SUGAR | TOXIC

/obj/item/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "Съедобный червякок из желатина. Зелёный!"
	icon_state = "gworm_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 5, "limejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "Съедобный червякок из желатина. Желтый!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 5, "lemonjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "Съедобный червякок из желатина. Оранжевый!"
	icon_state = "gworm_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 5, "orangejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "Съедобный червякок из желатина. Фиолетовый!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 5, "grapejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "Съедобный червякок из желатина. Он только что дёрнулся?"
	icon_state = "gworm_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 5, "space_drugs" = 2)

// ***********************************************************
// Jelly Bean Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/jellybean/red
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Красная!"
	icon_state = "jbean_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 3, "cherryjelly" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/blue
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Синяя!"
	icon_state = "jbean_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 3, "berryjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/poison
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Синяя!"
	icon_state = "jbean_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)

/obj/item/reagent_containers/food/snacks/candy/jellybean/green
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Зелёная!"
	icon_state = "jbean_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 3, "limejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/yellow
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Желтая!"
	icon_state = "jbean_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 3, "lemonjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/orange
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Оранжевая!"
	icon_state = "jbean_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 3, "orangejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/purple
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Фиолетовая!"
	icon_state = "jbean_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 3, "grapejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/chocolate
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Шоколадная!"
	icon_state = "jbean_choc"
	filling_color = "#302000"
	list_reagents = list("sugar" = 3, "chocolate" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/popcorn
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Со вкусом попкорна.!"
	icon_state = "jbean_popcorn"
	filling_color = "#664330"
	list_reagents = list("sugar" = 3, "nutriment" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/cola
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Со вкусом колы.!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	list_reagents = list("sugar" = 3, "cola" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/drgibb
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Со вкусом Др.Гибб!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	list_reagents = list("sugar" = 3, "dr_gibb" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/coffee
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Кофейная!"
	icon_state = "jbean_choc"
	filling_color = "#482000"
	list_reagents = list("sugar" = 3, "coffee" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/wtf
	name = "jelly bean"
	desc = "Конфета в форме боба. Гарантированно не вызывает газообразования. Вы не уверены, какого это цвета."
	icon_state = "jbean_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 3, "space_drugs" = 2)

// ***********************************************************
// Cotton Candy Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/cotton/red
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_red"
	trash = /obj/item/c_tube
	filling_color = "#801E28"
	list_reagents = list("sugar" = 15, "cherryjelly" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/blue
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_blue"
	trash = /obj/item/c_tube
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "berryjuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/poison
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_blue"
	trash = /obj/item/c_tube
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 20)

/obj/item/reagent_containers/food/snacks/candy/cotton/green
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_green"
	trash = /obj/item/c_tube
	filling_color = "#365E30"
	list_reagents = list("sugar" = 15, "limejuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/yellow
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_yellow"
	trash = /obj/item/c_tube
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "lemonjuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/orange
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_orange"
	trash = /obj/item/c_tube
	filling_color = "#E78108"
	list_reagents = list("sugar" = 15, "orangejuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/purple
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_purple"
	trash = /obj/item/c_tube
	filling_color = "#993399"
	list_reagents = list("sugar" = 15, "grapejuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/pink
	name = "cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_pink"
	trash = /obj/item/c_tube
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "watermelonjuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/rainbow
	name = "rainbow cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_rainbow"
	trash = /obj/item/c_tube
	filling_color = "#C8A5DC"
	list_reagents = list("omnizine" = 20)

/obj/item/reagent_containers/food/snacks/candy/cotton/bad_rainbow
	name = "bad rainbow cotton candy"
	desc = "Лёгкая и воздушная, словно ешь сахарное облако!"
	icon_state = "cottoncandy_rainbow"
	trash = /obj/item/c_tube
	filling_color = "#32127A"
	list_reagents = list("sulfonal" = 20)
	log_eating = TRUE

// ***********************************************************
// Candybar Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/confectionery
	list_reagents = list("nutriment" = 1, "chocolate" = 1)

/obj/item/reagent_containers/food/snacks/candy/confectionery/rice
	name = "Asteroid Crunch Bar"
	desc = "Хрустящие рисовые шарики в шоколаде! Любимец шахтёров по всей галактике."
	ru_names = list(
		NOMINATIVE = "батончик \"Хруст костей\"",
		GENITIVE = "батончика \"Хруст костей\"",
		DATIVE = "батончику \"Хруст костей\"",
		ACCUSATIVE = "батончик \"Хруст костей\"",
		INSTRUMENTAL = "батончиком \"Хруст костей\"",
		PREPOSITIONAL = "батончике \"Хруст костей\""
	)
	icon_state = "asteroidcrunch"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/confectionery/toffee
	name = "Yum-Baton Bar"
	desc = "Шоколад и ириски в форме дубинки. Сотрудники СБ, несомненно, обожают их!"
	ru_names = list(
		NOMINATIVE = "батончик \"Вкусная дубинка\"",
		GENITIVE = "батончика \"Вкусная дубинка\"",
		DATIVE = "батончику \"Вкусная дубинка\"",
		ACCUSATIVE = "батончик \"Вкусная дубинка\"",
		INSTRUMENTAL = "батончиком \"Вкусная дубинка\"",
		PREPOSITIONAL = "батончике \"Вкусная дубинка\""
	)
	icon_state = "yumbaton"
	belt_icon = "yumbaton"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/confectionery/caramel
	name = "Malper Bar"
	desc = "Шоколадный шприц с карамельной начинкой. То, что доктор прописал!"
	ru_names = list(
		NOMINATIVE = "батончик \"Мальпер\"",
		GENITIVE = "батончика \"Мальпер\"",
		DATIVE = "батончику \"Мальпер\"",
		ACCUSATIVE = "батончик \"Мальпер\"",
		INSTRUMENTAL = "батончиком \"Мальпер\"",
		PREPOSITIONAL = "батончике \"Мальпер\""
	)
	icon_state = "malper"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/confectionery/caramel_nougat
	name = "Toxins Test Bar"
	desc = "Взрывное сочетание шоколада, карамели и нуги. Наука никогда не была такой вкусной!"
	ru_names = list(
		NOMINATIVE = "батончик \"Тест токсинов\"",
		GENITIVE = "батончика \"Тест токсинов\"",
		DATIVE = "батончику \"Тест токсинов\"",
		ACCUSATIVE = "батончик \"Тест токсинов\"",
		INSTRUMENTAL = "батончиком \"Тест токсинов\"",
		PREPOSITIONAL = "батончике \"Тест токсинов\""
	)
	icon_state = "toxinstest"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/confectionery/nougat
	name = "Tool-erone Bar"
	desc = "Нуга в шоколаде в форме гаечного ключа. Идеально для инженера в пути!"
	ru_names = list(
		NOMINATIVE = "батончик \"Гаечный\"",
		GENITIVE = "батончика \"Гаечный\"",
		DATIVE = "батончику \"Гаечный\"",
		ACCUSATIVE = "батончик \"Гаечный\"",
		INSTRUMENTAL = "батончиком \"Гаечный\"",
		PREPOSITIONAL = "батончике \"Гаечный\""
	)
	icon_state = "toolerone"
	filling_color = "#7D5F46"

// ***********************************************************
// Carbon dulce
// ***********************************************************

/obj/item/reagent_containers/food/snacks/sugar_coal
	name = "Sugar coal"
	desc = "Это же сладкий уголь! Вы хорошо вели себя в этом году – это сладкая шутка от Волхвов. С Рождеством и Новым Годом!"
	ru_names = list(
		NOMINATIVE = "сахарный уголь",
		GENITIVE = "сахарного угля",
		DATIVE = "сахарному углю",
		ACCUSATIVE = "сахарный уголь",
		INSTRUMENTAL = "сахарным углём",
		PREPOSITIONAL = "сахарном угле"
	)
	icon = 'icons/obj/items.dmi'
	icon_state = "sugar_coal"
	tastes = list("сахара" = 2, "шоколада" = 1)
	list_reagents = list("nutriment" = 2, "sugar" = 4, "charcoal" = 2)
	bitecount = 1
	bitesize = 4
	filling_color = "#2c2b2b"

/obj/item/reagent_containers/food/snacks/sugar_coal/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5,5)
	pixel_y = rand(-5,5)
