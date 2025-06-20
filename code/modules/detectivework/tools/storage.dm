/obj/item/storage/box/swabs
	name = "box of swab kits"
	desc = "Содержимое стерильно. Не загрязнять!"
	ru_names = list(
		NOMINATIVE = "коробка с наборами ватных палочек",
		GENITIVE = "коробки с наборами ватных палочек",
		DATIVE = "коробке с наборами ватных палочек",
		ACCUSATIVE = "коробку с наборами ватных палочек",
		INSTRUMENTAL = "коробкой с наборами ватных палочек",
		PREPOSITIONAL = "коробке с наборами ватных палочек"
	)
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnakit"

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
	desc = "Содержимое стерильно. Не загрязнять!"
	ru_names = list(
		NOMINATIVE = "коробка с картами для снятия отпечатков пальцев",
		GENITIVE = "коробки с картами для снятия отпечатков пальцев",
		DATIVE = "коробке с картами для снятия отпечатков пальцев",
		ACCUSATIVE = "коробку с картами для снятия отпечатков пальцев",
		INSTRUMENTAL = "коробкой с картами для снятия отпечатков пальцев",
		PREPOSITIONAL = "коробке с картами для снятия отпечатков пальцев"
	)
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnakit"

/obj/item/storage/box/fingerprints/New()
	..()
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
