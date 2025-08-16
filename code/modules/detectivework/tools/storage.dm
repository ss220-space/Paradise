/obj/item/storage/box/swabs
	name = "box of swab kits"
	desc = "Коробка, содержащая наборы стерильных ватных палочек для проведения криминалистических исследований."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnakit"

/obj/item/storage/box/swabs/get_ru_names()
	return list(
		NOMINATIVE = "коробка ватных палочек",
		GENITIVE = "коробки ватных палочек",
		DATIVE = "коробке ватных палочек",
		ACCUSATIVE = "коробку ватных палочек",
		INSTRUMENTAL = "коробкой ватных палочек",
		PREPOSITIONAL = "коробке ватных палочек"
	)

/obj/item/storage/box/swabs/New()
	..()
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)

/obj/item/storage/box/fingerprints
	name = "box of fingerprint cards"
	desc = "Коробка, содержащая дактилоскопические карты для снятия отпечатков пальцев."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnakit"

/obj/item/storage/box/fingerprints/get_ru_names()
	return list(
		NOMINATIVE = "коробка карт отпечатков пальцев",
		GENITIVE = "коробки карт отпечатков пальцев",
		DATIVE = "коробке карт отпечатков пальцев",
		ACCUSATIVE = "коробку карт отпечатков пальцев",
		INSTRUMENTAL = "коробкой карт отпечатков пальцев",
		PREPOSITIONAL = "коробке карт отпечатков пальцев"
	)

/obj/item/storage/box/fingerprints/New()
	..()
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
