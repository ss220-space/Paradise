/obj/item/organ/internal/liver/skrell
	species_type = /datum/species/skrell
	name = "skrell liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала скреллу."
	ru_names = list(
		NOMINATIVE = "печень скрелла",
		GENITIVE = "печени скрелла",
		DATIVE = "печени скрелла",
		ACCUSATIVE = "печень скрелла",
		INSTRUMENTAL = "печенью скрелла",
		PREPOSITIONAL = "печени скрелла"
	)
	icon = 'icons/obj/species_organs/skrell.dmi'
	item_state = "skrell_liver"
	alcohol_intensity = 4

/obj/item/organ/internal/liver/skrell/on_life()
	. = ..()
	var/datum/reagent/alcohol = locate(/datum/reagent/consumable/ethanol) in owner.reagents.reagent_list
	if(alcohol)
		if(is_bruised())
			owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
		else if(is_traumatized())
			owner.adjustToxLoss(5)
		internal_receive_damage(1)


/obj/item/organ/internal/headpocket
	species_type = /datum/species/skrell
	name = "headpocket"
	desc = "Мышечное образование на голове скреллов, которое можно использовать как место хранения небольших предметов."
	ru_names = list(
		NOMINATIVE = "головной карман",
		GENITIVE = "головного кармана",
		DATIVE = "головному карману",
		ACCUSATIVE = "головной карман",
		INSTRUMENTAL = "головным карманом",
		PREPOSITIONAL = "головном кармане"
	)
	icon = 'icons/obj/species_organs/skrell.dmi'
	icon_state = "skrell_headpocket"
	item_state = "skrell_headpocket"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_HEADPOCKET
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/obj/item/storage/internal/pocket

/obj/item/organ/internal/headpocket/New()
	..()
	pocket = new /obj/item/storage/internal(src)
	pocket.storage_slots = 1
	// Allow adjacency calculation to work properly
	loc = owner
	// Fit only pocket sized items
	pocket.max_w_class = WEIGHT_CLASS_SMALL
	pocket.max_combined_w_class = 2

/obj/item/organ/internal/headpocket/on_life()
	..()
	var/obj/item/organ/external/head/head = owner.get_organ(BODY_ZONE_HEAD)
	if(pocket.contents.len && !findtextEx(head.h_style, "Tentacles"))
		owner.visible_message(span_warning("Что-то выпадает из [declent_ru(GENITIVE)] [owner]!"),
								span_warning("Что-то выпадает из вашего [declent_ru(GENITIVE)]!"))
		empty_contents()

/obj/item/organ/internal/headpocket/ui_action_click(mob/user, datum/action/action, leftclick)
	if(!loc)
		loc = owner
	pocket.MouseDrop(owner)

/obj/item/organ/internal/headpocket/on_owner_death()
	empty_contents()

/obj/item/organ/internal/headpocket/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	empty_contents()
	. = ..()

/obj/item/organ/internal/headpocket/proc/empty_contents()
	for(var/obj/item/I in pocket.contents)
		pocket.remove_from_storage(I, get_turf(owner))

/obj/item/organ/internal/headpocket/proc/get_contents()
	return pocket.contents

/obj/item/organ/internal/headpocket/emp_act(severity)
	pocket.emp_act(severity)
	..()

/obj/item/organ/internal/headpocket/hear_talk(mob/living/M as mob, list/message_pieces)
	pocket.hear_talk(M, message_pieces)
	..()

/obj/item/organ/internal/headpocket/hear_message(mob/living/M as mob, msg)
	pocket.hear_message(M, msg)
	..()

/obj/item/organ/internal/heart/skrell
	species_type = /datum/species/skrell
	name = "skrell heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало скреллу."
	ru_names = list(
		NOMINATIVE = "сердце скрелла",
		GENITIVE = "сердца скрелла",
		DATIVE = "сердцу скрелла",
		ACCUSATIVE = "сердце скрелла",
		INSTRUMENTAL = "сердцем скрелла",
		PREPOSITIONAL = "сердце скрелла"
	)
	icon = 'icons/obj/species_organs/skrell.dmi'
	item_state = "skrell_heart-on"
	item_base = "skrell_heart"

/obj/item/organ/internal/brain/skrell
	species_type = /datum/species/skrell
	icon = 'icons/obj/species_organs/skrell.dmi'
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал скреллу."
	ru_names = list(
		NOMINATIVE = "мозг скрелла",
		GENITIVE = "мозга скрелла",
		DATIVE = "мозгу скрелла",
		ACCUSATIVE = "мозг скрелла",
		INSTRUMENTAL = "мозгом скрелла",
		PREPOSITIONAL = "мозге скрелла"
	)
	icon_state = "brain2"
	item_state = "skrell_brain"
	mmi_icon = 'icons/obj/species_organs/skrell.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/skrell
	species_type = /datum/species/skrell
	name = "skrell lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали скреллу."
	ru_names = list(
		NOMINATIVE = "лёгкие скрелла",
		GENITIVE = "лёгких скрелла",
		DATIVE = "лёгким скрелла",
		ACCUSATIVE = "лёгкие скрелла",
		INSTRUMENTAL = "лёгкими скрелла",
		PREPOSITIONAL = "лёгких скрелла"
	)
	icon = 'icons/obj/species_organs/skrell.dmi'
	item_state = "skrell_lungs"

/obj/item/organ/internal/kidneys/skrell
	species_type = /datum/species/skrell
	name = "skrell kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали скреллу."
	ru_names = list(
		NOMINATIVE = "почки скрелла",
		GENITIVE = "почек скрелла",
		DATIVE = "почкам скрелла",
		ACCUSATIVE = "почки скрелла",
		INSTRUMENTAL = "почками скрелла",
		PREPOSITIONAL = "почках скрелла"
	)
	icon = 'icons/obj/species_organs/skrell.dmi'
	item_state = "skrell_kidneys"

/obj/item/organ/internal/eyes/skrell
	species_type = /datum/species/skrell
	name = "skrell eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали скреллу."
	ru_names = list(
		NOMINATIVE = "глаза скрелла",
		GENITIVE = "глаз скрелла",
		DATIVE = "глазам скрелла",
		ACCUSATIVE = "глаза скрелла",
		INSTRUMENTAL = "глазами скрелла",
		PREPOSITIONAL = "глазах скрелла"
	)
	icon = 'icons/obj/species_organs/skrell.dmi'
	item_state = "skrell_eyes"
	see_in_dark = 5
	can_see_food = TRUE

/obj/item/organ/internal/ears/skrell
	species_type = /datum/species/skrell
	name = "skrell ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали скреллу."
	ru_names = list(
		NOMINATIVE = "уши скрелла",
		GENITIVE = "ушей скрелла",
		DATIVE = "ушам скрелла",
		ACCUSATIVE = "уши скрелла",
		INSTRUMENTAL = "ушами скрелла",
		PREPOSITIONAL = "ушах скрелла"
	)
