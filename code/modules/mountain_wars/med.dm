// Медицина Mountain Wars. Вся механика (турникеты, бинты, шины, стоп-кровь,
// таргет по конечностям) уже есть в билде — здесь только фракционные наборы.
//
// Соответствие ГДД -> существующие предметы:
//   Турникет C-A-T      -> /obj/item/tourniquet/advanced
//   Жгут Эсмарха        -> /obj/item/tourniquet/makeshift
//   QuikClot Gauze      -> /obj/item/stack/medical/bruise_pack/military
//   Грязные бинты       -> /obj/item/stack/medical/bruise_pack/improvised
//   SAM Splint          -> /obj/item/stack/medical/splint
//   Деревянная шина     -> /obj/item/stack/medical/splint/makeshift
//   Целебный подорожник -> /obj/item/stack/medical/bruise_pack/comfrey

// MARK: Аптечка морпеха
// Автоинъектор берём базовый: он в билде уже эпинефриновый и назван соответственно,
// поэтому своего подтипа под режим не нужно.
/obj/item/storage/firstaid/mw_marine
	name = "аптечка морпеха"
	desc = "Индивидуальный перевязочный комплект Корпуса морской пехоты: турникет, гемостатик, шина, эпинефрин."

/obj/item/storage/firstaid/mw_marine/populate_contents()
	new /obj/item/tourniquet/advanced(src)
	new /obj/item/stack/medical/bruise_pack/military(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)

// MARK: Сумка повстанца
/obj/item/storage/firstaid/mw_insurgent
	name = "полевая сумка повстанца"
	desc = "Замызганная сумка с тем, что удалось достать: жгут, тряпьё вместо бинтов, палки и подорожник."

/obj/item/storage/firstaid/mw_insurgent/populate_contents()
	new /obj/item/tourniquet/makeshift(src)
	new /obj/item/stack/medical/bruise_pack/improvised(src)
	new /obj/item/stack/medical/splint/makeshift(src)
	new /obj/item/stack/medical/bruise_pack/comfrey(src)
