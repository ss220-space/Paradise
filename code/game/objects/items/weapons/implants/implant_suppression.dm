/obj/item/implant/suppression
	name = "suppression bio-chip"
	desc = "Подавляет навыки боевых искусств, сохраняя при этом их ограничения."
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_state = "implant-nanotrasen"
	implant_data = /datum/implant_fluff/suppression

/obj/item/implant/suppression/get_ru_names()
	return list(
		NOMINATIVE = "био-чип подавления",
		GENITIVE = "био-чипа подавления",
		DATIVE = "био-чипу подавления",
		ACCUSATIVE = "био-чип подавления",
		INSTRUMENTAL = "био-чипом подавления",
		PREPOSITIONAL = "био-чипе подавления",
	)

/obj/item/implant/suppression/implant(mob/living/carbon/human/target, mob/user, force = FALSE)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(target, TRAIT_MARTIAL_ARTS_SUPPRESSED, UNIQUE_TRAIT_SOURCE(src))
	if(target.mind && LAZYLEN(target.mind.known_martial_arts))
		to_chat(target, span_warning("Ваши навыки боевых искусств кажутся... подавленными."))
	else
		to_chat(target, span_warning("Вы чувствуете лёгкое покалывание в затылке, но ничего не происходит."))

/obj/item/implant/suppression/removed(mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return

	REMOVE_TRAIT(target, TRAIT_MARTIAL_ARTS_SUPPRESSED, UNIQUE_TRAIT_SOURCE(src))
	if(target.mind && LAZYLEN(target.mind.known_martial_arts))
		to_chat(target, span_notice("Ваши навыки боевых искусств возвращаются в норму."))
	else
		to_chat(target, span_notice("Вы чувствуете лёгкость в груди, словно что-то исчезло."))

/obj/item/implanter/suppression
	name = "bio-chip implanter (suppression)"
	imp = /obj/item/implant/suppression

/obj/item/implanter/suppression/get_ru_names()
	return list(
		NOMINATIVE = "имплантер био-чипов \"Подавление\"",
		GENITIVE = "имплантера био-чипов \"Подавление\"",
		DATIVE = "имплантеру био-чипов \"Подавление\"",
		ACCUSATIVE = "имплантер био-чипов \"Подавление\"",
		INSTRUMENTAL = "имплантером био-чипов \"Подавление\"",
		PREPOSITIONAL = "имплантере био-чипов \"Подавление\"",
	)

/obj/item/implantcase/suppression
	name = "bio-chip case - 'Suppression'"
	desc = "Стеклянный кейс, содержащий био-чип \"Подавление\"."
	imp = /obj/item/implant/suppression

/obj/item/implantcase/suppression/get_ru_names()
	return list(
		NOMINATIVE = "контейнер для био-чипа — \"Подавление\"",
		GENITIVE = "контейнера для био-чипа — \"Подавление\"",
		DATIVE = "контейнеру для био-чипа — \"Подавление\"",
		ACCUSATIVE = "контейнер для био-чипа — \"Подавление\"",
		INSTRUMENTAL = "контейнером для био-чипа — \"Подавление\"",
		PREPOSITIONAL = "контейнере для био-чипа — \"Подавление\"",
	)
