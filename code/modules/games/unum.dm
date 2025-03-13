/// A deck of unum cards. Classic.
/obj/item/deck/unum
	name = "\improper UNUM! deck"
	desc = "Колода карт UNUM! Правила для домашних ссор не входят в комплект."
	ru_names = list(
		NOMINATIVE = "колода карт UNUM",
		GENITIVE = "колоды карт UNUM",
		DATIVE = "колоде карт UNUM",
		ACCUSATIVE = "колоду карт UNUM",
		INSTRUMENTAL = "колодой карт UNUM",
		PREPOSITIONAL = "колоде карт UNUM"
	)
	icon_state = "deck_unum_full"
	card_style = "unum"


/obj/item/deck/unum/build_deck()
	var/list/ru_color = list(
		"Red" = "Красная",
		"Yellow" = "Жёлтая",
		"Green" = "Зелёная",
		"Blue" = "Синяя"
	)
	for(var/color in list("Red", "Yellow", "Green", "Blue"))
		cards += new /datum/playingcard("[ru_color[color]] 0", "sc_[color] 0_[card_style]", "singlecard_down_[card_style]")
		for(var/k in 0 to 1)
			cards += new /datum/playingcard("[ru_color[color]] Пропуск", "sc_[color] skip_[card_style]", "singlecard_down_[card_style]")
			cards += new /datum/playingcard("[ru_color[color]] Реверс", "sc_[color] reverse_[card_style]", "singlecard_down_[card_style]")
			cards += new /datum/playingcard("[ru_color[color]] +2", "sc_[color] draw 2_[card_style]", "singlecard_down_[card_style]")
			for(var/i in 1 to 9)
				cards += new /datum/playingcard("[ru_color[color]] [i]", "sc_[color] [i]_[card_style]", "singlecard_down_[card_style]")
	for(var/k in 0 to 3)
		cards += new /datum/playingcard("Дикая карта", "sc_Wildcard_[card_style]", "singlecard_down_[card_style]")
		cards += new /datum/playingcard("Дикая +4", "sc_Draw 4_[card_style]", "singlecard_down_[card_style]")


/obj/item/deck/unum/update_icon_state()
	if(!LAZYLEN(cards))
		icon_state = "deck_[card_style]_empty"
		return
	var/percent = round((LAZYLEN(cards) / deck_total) * 100)
	switch(percent)
		if(0 to 20)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_low"
		if(21 to 50)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_half"
		else
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_full"

