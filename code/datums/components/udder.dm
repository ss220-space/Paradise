/datum/component/udder
	var/obj/item/udder/udder
	var/udder_flags = UDDER_PASSIVE_GENERATION
	var/list/consumed_typecache
	var/datum/callback/on_full_callback
	COOLDOWN_DECLARE(milk_boost)

/datum/component/udder/Initialize(udder_type = /obj/item/udder, udder_flags = UDDER_PASSIVE_GENERATION, datum/callback/on_full_callback = null, list/consumed_types = null)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.udder_flags = udder_flags
	src.on_full_callback = on_full_callback
	if(udder_flags & UDDER_GENERATE_ON_CONSUME)
		consumed_typecache = typecacheof(consumed_types)
	udder = new udder_type(null)

/datum/component/udder/Destroy(force)
	. = ..()
	QDEL_NULL(udder)
	on_full_callback = null
	consumed_typecache = null

/datum/component/udder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	if(udder_flags & UDDER_EXAMINE)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	if((udder_flags & (UDDER_PASSIVE_GENERATION | UDDER_BOOST_ON_FEED)) || on_full_callback)
		RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	if(udder_flags & UDDER_GENERATE_ON_CONSUME)
		RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_consumed))
	if(udder_flags & UDDER_BOOST_ON_FEED)
		RegisterSignal(parent, COMSIG_SIMPLE_ANIMAL_FED, PROC_REF(on_fed))
	if(udder_flags & UDDER_CLEAR_ON_BIRTH)
		RegisterSignal(parent, COMSIG_SIMPLE_ANIMAL_GAVE_BIRTH, PROC_REF(on_birth))
	update_fullness()

/datum/component/udder/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_ATOM_EXAMINE,
		COMSIG_LIVING_LIFE,
		COMSIG_HOSTILE_POST_ATTACKINGTARGET,
		COMSIG_SIMPLE_ANIMAL_FED,
		COMSIG_SIMPLE_ANIMAL_GAVE_BIRTH,
	))
	REMOVE_TRAIT(parent, TRAIT_UDDER_FULL, UNIQUE_TRAIT_SOURCE(src))

/datum/component/udder/proc/update_fullness()
	var/is_full = udder.reagents.total_volume >= udder.reagents.maximum_volume
	if(is_full)
		ADD_TRAIT(parent, TRAIT_UDDER_FULL, UNIQUE_TRAIT_SOURCE(src))
	else
		REMOVE_TRAIT(parent, TRAIT_UDDER_FULL, UNIQUE_TRAIT_SOURCE(src))
	return is_full

/datum/component/udder/proc/on_life(datum/source, seconds)
	SIGNAL_HANDLER

	if(udder.feeded && COOLDOWN_FINISHED(src, milk_boost))
		udder.feeded = FALSE

	var/mob/living/animal = parent
	if(animal.stat != CONSCIOUS)
		return

	if(udder_flags & UDDER_PASSIVE_GENERATION)
		udder.generateMilk()

	var/is_full = update_fullness()
	if(is_full && on_full_callback)
		on_full_callback.Invoke()

/datum/component/udder/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("В его [udder.declent_ru(PREPOSITIONAL)] содержится [udder.reagents.total_volume] единиц[DECL_A_Y_0(udder.reagents.total_volume)] молока.")

/datum/component/udder/proc/on_consumed(datum/source, atom/food, success)
	SIGNAL_HANDLER

	if(!success || !is_type_in_typecache(food, consumed_typecache))
		return

	udder.generateMilk()
	update_fullness()

/datum/component/udder/proc/on_fed(datum/source, obj/item/food, mob/feeder)
	SIGNAL_HANDLER

	boost_production(60 SECONDS)

/datum/component/udder/proc/on_birth(datum/source, mob/living/simple_animal/child)
	SIGNAL_HANDLER

	udder.reagents.clear_reagents()
	update_fullness()

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

	update_fullness()

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

