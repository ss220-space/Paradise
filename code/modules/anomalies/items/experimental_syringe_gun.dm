/obj/item/gun/syringe/rapidsyringe/experimental
	name = "experimental syringe gun"
	ru_names = list(
		NOMINATIVE = "экспериментальный шприцемёт", \
		GENITIVE = "экспериментального шприцемёта", \
		DATIVE = "экспериментальному шприцемёту", \
		ACCUSATIVE = "экспериментальный шприцемёт", \
		INSTRUMENTAL = "экспериментальным шприцемётом", \
		PREPOSITIONAL = "экспериментальном шприцемёте"
	)
	desc = "Экспериментальный шприцемёт с 6 слотами для шприцев, со встроенным, самовосполняющимся хранилищем \
			химикатов и новейшей системой автозаправки шприцев. Для смены синтезируемых химикатов залейте новую \
			смесь внутрь. Не может синтезировать некоторые, особенно сложные вещества."
	gender = MALE
	origin_tech = "combat=3;biotech=4;bluespace=5"
	icon = 'icons/obj/weapons/techrelic.dmi'
	item_state = "strynggun"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	icon_state = "strynggun"
	materials = list(MAT_METAL=2000, MAT_GLASS=2000, MAT_BLUESPACE=400)
	origin_tech = "bluespace=4;biotech=5"
	/// Tank with ready reagents.
	var/obj/item/reagent_containers/glass/beaker/large/ready_reagents = new
	/// A list synthesized reagents.
	var/list/synth_reagents = list()
	/// The amount of substance synthesized in a cycle.
	var/synth_speed = 5
	/// The size of the internal tank with ready-made reagents.
	var/bank_size = 100
	/// Inserted vortex anomaly core.
	var/obj/item/assembly/signaler/core/vortex/core = null

/obj/item/gun/syringe/rapidsyringe/experimental/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/gun/syringe/rapidsyringe/experimental/Destroy()
	STOP_PROCESSING(SSobj, src)
	core?.forceMove(get_turf(src))
	core = null
	QDEL_LAZYLIST(synth_reagents)
	qdel(ready_reagents)
	return ..()

/obj/item/gun/syringe/rapidsyringe/experimental/proc/update_core()
	if(!core)
		synth_speed = 0
		return

	synth_speed = core.get_strength() / 30

/obj/item/gun/syringe/rapidsyringe/experimental/attackby(obj/item/item, mob/user)
	if(iscorevortex(item))
		add_fingerprint(user)
		var/msg = "ядро вставлено"
		if(core)
			if(!user.put_in_hands(core))
				core.forceMove(get_turf(user))

			msg = "ядро заменено"

		if(!user.drop_transfer_item_to_loc(item, src))
			balloon_alert(user, "отпустить невозможно!")
			return ATTACK_CHAIN_PROCEED

		core = item
		user.balloon_alert(user, msg)
		update_core()
		return ATTACK_CHAIN_PROCEED

	if(issyringe(item))
		var/in_clip = length(syringes) + (chambered.BB ? 1 : 0)
		if(in_clip >= max_syringes)
			user.balloon_alert(user, "недостаточно места")
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(item, src))
			return ..()

		user.balloon_alert(user, "заряжено")
		syringes.Add(item)
		process_chamber() // Chamber the syringe if none is already
		return ATTACK_CHAIN_BLOCKED_ALL

	if(isglassreagentcontainer(item))
		if(!core)
			user.balloon_alert(user, "нет ядра")
			return ..()

		var/obj/item/reagent_containers/glass/RC = item
		if (!RC.reagents.reagent_list)
			return  ..()

		ready_reagents.reagents.clear_reagents()
		synth_reagents = list()
		RC.reagents.trans_to(ready_reagents, bank_size)
		var/synch_reagent_volume = 0
		for(var/datum/reagent/reagent in ready_reagents.reagents.reagent_list)
			if(!reagent.can_synth)
				continue

			synch_reagent_volume += reagent.volume

		for(var/datum/reagent/reagent in ready_reagents.reagents.reagent_list)
			if(!reagent.can_synth)
				continue

			synth_reagents[reagent.id] = reagent.volume / synch_reagent_volume

		user.balloon_alert(user, "смесь изменена")
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/gun/syringe/rapidsyringe/experimental/click_alt(mob/user)
	if(!user.contains(src))
		return

	if(!user.put_in_hands(core))
		core.forceMove(get_turf(user))

	core = null
	user.balloon_alert(user, "ядро извлечено")
	update_core()

/obj/item/gun/syringe/rapidsyringe/experimental/process()
	if(!core)
		return

	if(syringes.len < max_syringes && prob(core.get_strength() / 5))
		syringes.Add(new /obj/item/reagent_containers/syringe)
		process_chamber()

	var/synth_volume = min(synth_speed, ready_reagents.reagents.maximum_volume - ready_reagents.reagents.total_volume)
	for(var/id in synth_reagents)
		ready_reagents.reagents.add_reagent(id, synth_reagents[id] * synth_volume)

	if(chambered?.BB)
		ready_reagents.reagents.trans_to(chambered.BB, ready_reagents.reagents.total_volume)

	for (var/obj/item/reagent_containers/syringe/slime in syringes)
		ready_reagents.reagents.trans_to(slime, ready_reagents.reagents.total_volume)

/obj/item/gun/syringe/rapidsyringe/experimental/afterattack(atom/target, mob/living/user, flag, params)
	if(!isglassreagentcontainer(target))
		return ..()

	var/obj/item/reagent_containers/glass/G = target
	ready_reagents.reagents.trans_to(G, ready_reagents.reagents.total_volume)

/obj/item/gun/syringe/rapidsyringe/experimental/examine(mob/user)
	. = ..()
	if(!core)
		. += span_warning("В [declent_ru(PREPOSITIONAL)] нет ядра!")
	else
		. += span_notice("В [declent_ru(PREPOSITIONAL)] есть ядро.")

	. += span_notice("Синтезируемые реагенты:")
	for(var/id in synth_reagents)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[id]
		. += span_notice(" [reagent.name]: [synth_reagents[id] * synth_speed]")

	. += span_notice("Готовые реагенты:")
	for(var/datum/reagent/reagent in ready_reagents.reagents.reagent_list)
		. += span_notice(" [reagent.name]: [reagent.volume]")

/obj/item/gun/syringe/rapidsyringe/experimental/suicide_act(mob/living/carbon/human/user)
	if(!core || HAS_TRAIT(user, TRAIT_NO_BLOOD) || !istype(user))
		return ..()

	user.visible_message(span_suicide("[user] разреза[pluralize_ru(user.gender,"ет","ют")] свою руку и подключа[pluralize_ru(user.gender,"ет","ют")] систему автозаправки к \
									кровеносной системе! Выглядит будто он[genderize_ru(gender, "", "а", "о", "и")] \
									пыта[pluralize_ru(user.gender,"ет","ют")]ся убить себя!"))
	ready_reagents.reagents.trans_to(user, ready_reagents.reagents.total_volume)
	user.bleed(user.blood_volume)
	return OXYLOSS | BRUTELOSS

/obj/item/gun/syringe/rapidsyringe/experimental/attack_self(mob/living/user)
	return

/obj/item/gun/syringe/rapidsyringe/experimental/preloaded
	core = new /obj/item/assembly/signaler/core/vortex/tier2()


/datum/crafting_recipe/rapidsyringe_experimental
	name = "Experemintal syringe gun"
	result = /obj/item/gun/syringe/rapidsyringe/experimental
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(/obj/item/relict_production/perfect_mix = 1,
				/obj/item/gun/syringe/rapidsyringe = 1,
				/obj/item/stock_parts/matter_bin = 1)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
