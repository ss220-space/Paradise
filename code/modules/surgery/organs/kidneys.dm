/obj/item/organ/internal/kidneys
	name = "kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали человеку."
	ru_names = list(
		NOMINATIVE = "почки человека",
		GENITIVE = "почек человека",
		DATIVE = "почкам человека",
		ACCUSATIVE = "почки человека",
		INSTRUMENTAL = "почками человека",
		PREPOSITIONAL = "почках человека"
	)
	icon_state = "kidneys"
	gender = PLURAL
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_KIDNEYS

/obj/item/organ/internal/kidneys/on_life()
	// Coffee is really bad for you with busted kidneys.
	// This should probably be expanded in some way, but fucked if I know
	// what else kidneys can process in our reagent list.
	if(!owner.reagents)
		return
	var/datum/reagent/coffee = locate(/datum/reagent/consumable/drink/coffee) in owner.reagents.reagent_list
	if(coffee)
		if(is_bruised())
			owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
		else if(is_traumatized())
			owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)

/obj/item/organ/internal/kidneys/cybernetic
	name = "cybernetic kidneys"
	desc = "Электронное устройство, имитирующее работу органических почек. Функционально не имеет никаких отличий от органического аналога, кроме производственных затрат."
	ru_names = list(
		NOMINATIVE = "кибернетические почки",
		GENITIVE = "кибернетических почек",
		DATIVE = "кибернетическим почкам",
		ACCUSATIVE = "кибернетические почки",
		INSTRUMENTAL = "кибернетическими почками",
		PREPOSITIONAL = "кибернетических почках"
	)
	icon_state = "kidneys-c"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'
