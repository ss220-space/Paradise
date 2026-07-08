/obj/item/clothing/shoes/greaves_of_the_prophet
	name = "prophet's greaves"
	desc = "Грубые, изношенные железные башмаки. Кажется, что они прочнее, чем земля, по которой в них ходят. \
			Они покрыты тонким слоем ржавчины, и всё же, её вид почему-то успокаивает вас."
	icon_state = "hereticgreaves"
	// Worn (on-mob) sprite lives in the shared feet.dmi as the "hereticgreaves" state (extracted from tg's
	// feet.dmi), resolved by inheritance - no onmob_sheets override needed.
	resistance_flags = ACID_PROOF | FIRE_PROOF | LAVA_PROOF


/obj/item/clothing/shoes/greaves_of_the_prophet/get_ru_names()
	return alist(
		NOMINATIVE = "поножи пророка",
		GENITIVE = "понож пророка",
		DATIVE = "поножам пророка",
		ACCUSATIVE = "поножи пророка",
		INSTRUMENTAL = "поножами пророка",
		PREPOSITIONAL = "поножах пророка",
	)


/obj/item/clothing/shoes/greaves_of_the_prophet/Initialize(mapload)
	. = ..()
	attach_clothing_traits(list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NO_SLIP_ALL))
