/obj/eventobjects/eventobj
	name = "placehold"
	desc = "abstract"
	density = TRUE
	anchored = TRUE

/obj/eventobjects/eventobj/skeleton
	name = "big skeleton"
	desc = "Огромные скелетированные останки неизвестного существа"
	icon = 'icons/obj/eventicons/skeleton.dmi'
	icon_state = "skeleton"

/obj/eventobjects/eventobj/skeleton/get_ru_names()
	return alist(
		NOMINATIVE = "скелетированные останки",
		GENITIVE = "скелетированных останков",
		DATIVE = "скелетированным останкам",
		ACCUSATIVE = "скелетированные останки",
		INSTRUMENTAL = "скелетированными останками",
		PREPOSITIONAL = "скелетированных останках"
	)
