/datum/component/udder
	var/obj/item/udder/udder
	var/auto_generate = TRUE
	var/datum/callback/on_milk_callback
	COOLDOWN_DECLARE(milk_boost)

/datum/component/udder/Initialize(udder_type = /obj/item/udder, auto_generate = TRUE, datum/callback/on_milk_callback = null)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.auto_generate = auto_generate
	src.on_milk_callback = on_milk_callback
	udder = new udder_type(null)

/datum/component/udder/Destroy(force)
	QDEL_NULL(udder)
	on_milk_callback = null
	return ..()

/datum/component/udder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	if(auto_generate)
		RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/udder/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ITEM_INTERACTION, COMSIG_LIVING_LIFE))

/datum/component/udder/proc/on_life(datum/source, seconds)
	SIGNAL_HANDLER

	if(udder.feeded && COOLDOWN_FINISHED(src, milk_boost))
		udder.feeded = FALSE

	var/mob/living/animal = parent
	if(animal.stat == CONSCIOUS)
		udder.generateMilk()

/datum/component/udder/proc/on_item_interaction(datum/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER

	if(user.a_intent == INTENT_HARM || !iscup(tool))
		return NONE

	var/mob/living/animal = parent
	animal.add_fingerprint(user)

	if(animal.stat != CONSCIOUS)
		to_chat(user, span_warning("[animal] has problems with health."))
		return ITEM_INTERACT_BLOCKING

	if(!tool.is_open_container())
		user.balloon_alert(user, "ёмкость закрыта!")
		return ITEM_INTERACT_BLOCKING

	if(!udder.milkAnimal(tool, user, animal))
		return ITEM_INTERACT_BLOCKING

	if(on_milk_callback)
		on_milk_callback.Invoke()

	return ITEM_INTERACT_SUCCESS

/datum/component/udder/proc/boost_production(duration)
	COOLDOWN_START(src, milk_boost, duration)
	udder.feeded = TRUE

/obj/item/udder
	name = "udder"
	var/feeded = FALSE

/obj/item/udder/Initialize(mapload)
	. = ..()
	create_reagents(80)
	reagents.add_reagent(/datum/reagent/consumable/drink/milk, 20)

/obj/item/udder/Destroy(force)
	reagents.my_atom = null
	QDEL_NULL(reagents)
	return ..()

/obj/item/udder/proc/generateMilk()
	var/probability = 5
	if(feeded)
		probability = 30

	if(prob(probability))
		reagents.add_reagent(/datum/reagent/consumable/drink/milk, rand(5, 10))

/obj/item/udder/proc/milkAnimal(obj/item/reagent_containers/cup/container, mob/user, mob/living/animal = null)
	if(!container.reagents)
		user.balloon_alert(user, "неподходящая ёмкость!")
		return FALSE
	if(container.reagents.total_volume >= container.volume)
		user.balloon_alert(user, "ёмкость заполнена!")
		return FALSE
	var/transfered = reagents.trans_to(container, rand(5,10))
	if(!transfered)
		user.balloon_alert(user, "вымя сухое!")
		return FALSE
	var/atom/milked = animal ? animal : src
	user.visible_message(
		span_notice("[user] до[PLUR_IT_YAT(user)] [milked.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы доите [milked.declent_ru(ACCUSATIVE)]."),
	)
	return TRUE

