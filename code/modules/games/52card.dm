/obj/item/deck/holder
	name = "card box"
	desc = "A small leather case to show how classy you are compared to everyone else."
	icon_state = "card_holder"


/obj/item/deck/cards
	name = "deck of cards"
	desc = "Простая колода игральных карт."
	ru_names = list(
		NOMINATIVE = "колода карт",
		GENITIVE = "колоды карт",
		DATIVE = "колоде карт",
		ACCUSATIVE = "колоду карт",
		INSTRUMENTAL = "колодой карт",
		PREPOSITIONAL = "колоде карт"
	)
	gender = FEMALE
	icon_state = "deck_nanotrasen_full"
	card_style = "nanotrasen"


/obj/item/deck/cards/build_deck()
	var/list/ru_name = list(
		"Spades" = "Пики",
		"Clubs" = "Трефы",
		"Diamonds" = "Бубны",
		"Hearts" = "Червы",
		"Ace" = "Туз",
		"Jack" = "Валет",
		"Queen" = "Дама",
		"King" = "Король",
		"2" = "2",
		"3" = "3",
		"4" = "4",
		"5" = "5",
		"6" = "6",
		"7" = "7",
		"8" = "8",
		"9" = "9",
		"10" = "10",
	)
	for(var/suit in list("Spades","Clubs","Diamonds","Hearts"))
		var/card_appearance
		var/colour
		var/rank
		if(simple_deck)
			if(suit in list("Spades","Clubs"))
				colour = "black"
			else
				colour = "red"
		for(var/number in list("Ace","2","3","4","5","6","7","8","9","10","Jack","Queen","King"))
			if(simple_deck)
				if(number in list("Jack","Queen","King"))
					rank = "col"
				else
					rank = "num"
				card_appearance = "sc_[colour]_[rank]_[card_style]"
			else
				card_appearance = "sc_[number] of [suit]_[card_style]"
			cards += new /datum/playingcard("[ru_name[number]] [ru_name[suit]]", card_appearance, "singlecard_down_[card_style]")

	for(var/jokers in 1 to 2)
		cards += new /datum/playingcard("Джокер", "sc_Joker_[card_style]", "singlecard_down_[card_style]")


/obj/item/deck/cards/update_icon_state()
	if(!LAZYLEN(cards))
		icon_state = "deck_[card_style]_empty"
		return
	var/percent = round((LAZYLEN(cards) / deck_total) * 100) // Rounding due to switch freaking out
	switch(percent)
		if(0 to 20)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_low"
		if(21 to 50)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_half"
		else
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_full"


/obj/item/deck/cards/doublecards
	name = "double deck of cards"
	desc = "Простая колода игральных карт. Удвоенная. Может быть, играть с такой будет в два раза интереснее?"
	ru_names = list(
		NOMINATIVE = "двойная колода карт",
		GENITIVE = "двойной колоды карт",
		DATIVE = "двойной колоде карт",
		ACCUSATIVE = "двойную колоду карт",
		INSTRUMENTAL = "двойной колодой карт",
		PREPOSITIONAL = "двойной колоде карт"
	)
	icon_state = "deck_double_nanotrasen_full"
	deck_size = 2
	deck_style = "double"


/obj/item/deck/cards/syndicate
	name = "suspicious looking deck of cards"
	desc = "Колода тёмно-красных игральных карт. Они кажутся необычно жёсткими."
	ru_names = list(
		NOMINATIVE = "подозрительная колода карт",
		GENITIVE = "подозрительной колоды карт",
		DATIVE = "подозрительной колоде карт",
		ACCUSATIVE = "подозрительную колоду карт",
		INSTRUMENTAL = "подозрительной колодой карт",
		PREPOSITIONAL = "подозрительной колоде карт"
	)
	icon_state = "deck_syndicate_full"
	card_style = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 10
	card_throw_speed = 3
	card_attack_verb = list("атаковал", "полоснул", "порезал")
	card_resistance_flags = NONE


/obj/item/deck/cards/black
	card_style = "black"


/obj/item/deck/cards/syndicate/black
	card_style = "black"


/obj/item/deck/cards/tiny
	name = "deck of tiny cards"
	desc = "Простая колода миниатюрных игральных карт."
	ru_names = list(
		NOMINATIVE = "колода миниатюрных карт",
		GENITIVE = "колоды миниатюрных карт",
		DATIVE = "колоде миниатюрных карт",
		ACCUSATIVE = "колоду миниатюрных карт",
		INSTRUMENTAL = "колодой миниатюрных карт",
		PREPOSITIONAL = "колоде миниатюрных карт"
	)
	icon_state = "deck"
	card_style = "simple"
	simple_deck = TRUE


/obj/item/deck/cards/tiny/update_icon_state()
	return


/obj/item/deck/cards/tiny/doublecards
	name = "double deck of tiny cards"
	desc = "Простая колода миниатюрных игральных карт. Удвоенная. Может быть, играть с такой будет в два раза интереснее?"
	ru_names = list(
		NOMINATIVE = "двойная колода миниатюрных карт",
		GENITIVE = "двойной колоды миниатюрных карт",
		DATIVE = "двойной колоде миниатюрных карт",
		ACCUSATIVE = "двойную колоду миниатюрных карт",
		INSTRUMENTAL = "двойной колодой миниатюрных карт",
		PREPOSITIONAL = "двойной колоде миниатюрных карт"
	)
	icon_state = "doubledeck"
	deck_size = 2

