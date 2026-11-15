//Wings

/obj/item/clothing/neck/angel_wings
	name = "Angel wings"
	desc = "Эти крылья похожи на ангельские. Не вы обронили?"
	icon_state = "angel_wings"
	species_restricted = list("exclude", SPECIES_DRASK, SPECIES_MOTH, SPECIES_GREY, "lesser form")

/obj/item/clothing/neck/angel_wings/get_ru_names()
	return alist(
		NOMINATIVE = "ангельские крылья",
		GENITIVE = "ангельских крыльев",
		DATIVE = "ангельским крыльям",
		ACCUSATIVE = "ангельские крылья",
		INSTRUMENTAL = "ангельскими крыльями",
		PREPOSITIONAL = "ангельских крыльях"
	)

/obj/item/clothing/neck/devil_wings
	name = "Devil wings"
	desc = "Боже, прости меня, ибо я согрешил..."
	icon_state = "devil_wings"
	species_restricted = list("exclude", SPECIES_DRASK, SPECIES_MOTH, SPECIES_GREY, "lesser form")

/obj/item/clothing/neck/devil_wings/get_ru_names()
	return alist(
		NOMINATIVE = "дьявольские крылья",
		GENITIVE = "дьявольских крыльев",
		DATIVE = "дьявольским крыльям",
		ACCUSATIVE = "дьявольские крылья",
		INSTRUMENTAL = "дьявольскими крыльями",
		PREPOSITIONAL = "дьявольских крыльях"
	)
