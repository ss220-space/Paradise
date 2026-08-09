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

// MARK: Автоинъектор морфина (Морпехи)
/obj/item/reagent_containers/hypospray/autoinjector/mw_morphine
	name = "автоинъектор морфина"
	desc = "Армейский автоинъектор с дозой морфина. Позволяет игнорировать боль и не сбавлять шаг с раздробленной ногой."
	list_reagents = list("morphine" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/mw_morphine/get_ru_names()
	return alist(
		NOMINATIVE = "автоинъектор (Морфин)",
		GENITIVE = "автоинъектора (Морфин)",
		DATIVE = "автоинъектору (Морфин)",
		ACCUSATIVE = "автоинъектор (Морфин)",
		INSTRUMENTAL = "автоинъектором (Морфин)",
		PREPOSITIONAL = "автоинъекторе (Морфин)"
	)

// MARK: Аптечка морпеха
/obj/item/storage/firstaid/mw_marine
	name = "аптечка морпеха"
	desc = "Индивидуальный перевязочный комплект Корпуса морской пехоты: турникет, гемостатик, шина, морфин."

/obj/item/storage/firstaid/mw_marine/populate_contents()
	new /obj/item/tourniquet/advanced(src)
	new /obj/item/stack/medical/bruise_pack/military(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/mw_morphine(src)

// MARK: Сумка повстанца
/obj/item/storage/firstaid/mw_insurgent
	name = "полевая сумка повстанца"
	desc = "Замызганная сумка с тем, что удалось достать: жгут, тряпьё вместо бинтов, палки и подорожник."

/obj/item/storage/firstaid/mw_insurgent/populate_contents()
	new /obj/item/tourniquet/makeshift(src)
	new /obj/item/stack/medical/bruise_pack/improvised(src)
	new /obj/item/stack/medical/splint/makeshift(src)
	new /obj/item/stack/medical/bruise_pack/comfrey(src)
