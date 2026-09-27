/obj/item/bitrunning_debug
	name = "bitrunning debug item"
	desc = "Начисляет очки и сбрасывает время остывания. Нужен для отладки."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk0"
	w_class = WEIGHT_CLASS_TINY

/obj/item/bitrunning_debug/get_ru_names()
	return alist(
		NOMINATIVE = "отладочный диск битраннинга",
		GENITIVE = "отладочного диска битраннинга",
		DATIVE = "отладочному диску битраннинга",
		ACCUSATIVE = "отладочный диск битраннинга",
		INSTRUMENTAL = "отладочным диском битраннинга",
		PREPOSITIONAL = "отладочном диске битраннинга",
	)
