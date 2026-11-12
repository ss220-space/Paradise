/obj/item/chemical_flamethrower
	name = "chemical flamethrower"
	desc = "Люблю запах напалма по утрам."
	icon = 'icons/obj/chemical_flamethrower.dmi'
	icon_state = "chem_flame"
	lefthand_file = 'icons/mob/inhands/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/flamethrower_righthand.dmi'
	flags = CONDUCT
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	slot_flags = ITEM_SLOT_BACK
	materials = list(MAT_METAL = 5000)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=1;plasmatech=2;engineering=2"
	attack_speed = 1.6 SECONDS

	/// All our loaded canisters in a list
	var/obj/item/chemical_canister/canister
	/// Is this a type of flamethrower that starts loaded?
	var/start_canister_type = /obj/item/chemical_canister

	/// How much ammo do we use per tile?
	var/ammo_usage = 60

	var/max_range = 4

/obj/item/chemical_flamethrower/get_ru_names()
	return alist(
		NOMINATIVE = "химический огнемёт",
		GENITIVE = "химического огнемёта",
		DATIVE = "химическому огнемёту",
		ACCUSATIVE = "химический огнемёт",
		INSTRUMENTAL = "химическим огнемётом",
		PREPOSITIONAL = "химическом огнемёте",
	)

/obj/item/chemical_flamethrower/Initialize(mapload)
	. = ..()
	if(start_canister_type && !canister)
		canister = new start_canister_type
		canister.on_reagent_change()
	update_appearance()

/obj/item/chemical_flamethrower/Destroy()
	QDEL_NULL(canister)
	return ..()

/obj/item/chemical_flamethrower/update_overlays()
	. = ..()
	if(canister)
		. += mutable_appearance('icons/obj/chemical_flamethrower.dmi', "[canister.icon_state]_1")

/obj/item/chemical_flamethrower/attack_self(mob/user)
	. = ..()
	if(canister)
		unequip_canister(user)

/obj/item/chemical_flamethrower/proc/unequip_canister(mob/user)
	if(!canister)
		return

	var/obj/item/chemical_canister/canister_to_remove = canister
	canister_to_remove.forceMove(get_turf(src))
	user.put_in_hands(canister_to_remove)
	canister = null
	update_appearance(UPDATE_OVERLAYS)

/obj/item/chemical_flamethrower/attackby(obj/item/item, mob/living/user, list/modifiers)
	. = ..()
	if(!istype(item, /obj/item/chemical_canister))
		to_chat(user, span_notice("Вы не можете посместить [item.declent_ru(ACCUSATIVE)] сюда!"))
		return
	if(canister)
		to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] уже полон!"))
		return

	if(user.transfer_item_to_loc(item, src))
		canister = item
		canister.on_reagent_change()
		to_chat(user, span_notice("Вы помещаете [item.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
		update_appearance(UPDATE_OVERLAYS)

/obj/item/chemical_flamethrower/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(proximity_flag || !user)
		return

	if(user.mind?.martial_art?.no_guns)
		to_chat(user, span_warning("[user.mind.martial_art.no_guns_message]"))
		return

	if(HAS_TRAIT(user, TRAIT_CHUNKYFINGERS))
		to_chat(user, span_warning("Ваш палец слишком велик для спускового крючка!"))
		return

	if(user.get_active_hand() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turf_list = get_line(user, target_turf)
			INVOKE_ASYNC(src, PROC_REF(flame_turf), turf_list, user, target)

/obj/item/chemical_flamethrower/proc/flame_turf(list/turflist = list(), mob/user, turf/target)
	if(!length(turflist))
		return

	var/turf/previousturf = get_turf(src)
	var/obj/item/chemical_canister/canister = src.canister
	if(!canister)
		return
	var/datum/reagents/canister_reagents = canister.reagents
	var/datum/reagents/reagent_holder = new()
	canister_reagents.trans_to(reagent_holder, ammo_usage)
	var/list/combust_data = reagent_holder.calc_combust_data()
	if(!combust_data)
		return
	add_attack_logs(user, target, "Chemical Flamethrowered at [target.x], [target.y], [target.z]")
	playsound(get_turf(user), SFX_FLAMETHROWER, 50, TRUE)
	var/obj/flamer_fire/temp = new()
	var/datum/reagent/combust_reagent = new()
	combust_reagent.durationfire = combust_data[COMBUST_DATA_DURATION]
	combust_reagent.intensityfire = combust_data[COMBUST_DATA_INTENSITY]
	combust_reagent.rangefire = combust_data[COMBUST_DATA_RADIUS]

	combust_reagent.burncolor = combust_data[COMBUST_DATA_FIRECOLOR]
	combust_reagent.color = combust_data[COMBUST_DATA_FIRECOLOR]

	combust_reagent.fire_penetrating = combust_data[COMBUST_DATA_PENETRATING]
	var/distance = 0
	var/max_range = src.max_range
	for(var/turf/simulated/turf in turflist)
		var/atom/found_obstruction = LinkBlocked(temp, previousturf, turf)
		if(found_obstruction)
			break
		if(!distance)
			distance++
			continue
		if(turf == target || distance >= max_range)
			reagent_holder.my_atom = turf
			reagent_holder.del_reagent(/datum/reagent/stabilizing_agent)
			reagent_holder.trigger_volatiles = canister.has_fuel
			reagent_holder.handle_reactions()
			QDEL_IN(reagent_holder, 1 SECONDS)
			break

		new /obj/flamer_fire(turf, combust_reagent, distance > 1? 1 : 0)
		distance++
		sleep(0.1 SECONDS)
		previousturf = turf

	qdel(temp)

/obj/item/chemical_flamethrower/extended
	name = "extended capacity chemical flamethrower"
	desc = "Огнемёт для создания продолжительных пожаров."
	icon_state = "chem_flame_2"

/obj/item/chemical_flamethrower/extended/get_ru_names()
	return alist(
		NOMINATIVE = "химический огнемёт повышенной ёмкости",
		GENITIVE = "химического огнемёта повышенной ёмкости",
		DATIVE = "химическому огнемёту повышенной ёмкости",
		ACCUSATIVE = "химический огнемёт повышенной ёмкости",
		INSTRUMENTAL = "химическим огнемётом повышенной ёмкости",
		PREPOSITIONAL = "химическом огнемёте повышенной ёмкости",
	)

/obj/item/chemical_flamethrower/extended/nuclear
	name = "Syndicate extended capacity chemical flamethrower"
	desc = "Огнемёт для создания продолжительных пожаров. Чёрный, как пепел ваших врагов."
	icon_state = "chem_flame_2_s"
	start_canister_type = /obj/item/chemical_canister/extended/nuclear
	ammo_usage = 40
	max_range = 7

/obj/item/chemical_flamethrower/extended/nuclear/get_ru_names()
	return alist(
		NOMINATIVE = "химический огнемёт повышенной ёмкости Синдиката",
		GENITIVE = "химического огнемёта повышенной ёмкости Синдиката",
		DATIVE = "химическому огнемёту повышенной ёмкости Синдиката",
		ACCUSATIVE = "химический огнемёт повышенной ёмкости Синдиката",
		INSTRUMENTAL = "химическим огнемётом повышенной ёмкости Синдиката",
		PREPOSITIONAL = "химическом огнемёте повышенной ёмкости Синдиката",
	)

/obj/item/chemical_canister
	name = "chemical canister"
	desc = "Простой баллон с топливом."
	icon = 'icons/obj/chemical_flamethrower.dmi'
	icon_state = "normal"
	container_type = REFILLABLE | AMOUNT_VISIBLE
	materials = list(MAT_METAL = 5000)
	/// How much ammo do we have? Empty at 0.
	var/ammo = 300
	var/is_clearing = FALSE
	var/has_fuel = FALSE
	var/static/list/reagents_whitelist = list(
		/datum/reagent/aluminum,
		/datum/reagent/acid,
	)

/obj/item/chemical_canister/get_ru_names()
	return alist(
		NOMINATIVE = "химический баллон",
		GENITIVE = "химического баллона",
		DATIVE = "химическому баллону",
		ACCUSATIVE = "химический баллон",
		INSTRUMENTAL = "химическим баллоном",
		PREPOSITIONAL = "химическом баллоне",
	)

/obj/item/chemical_canister/Initialize(mapload)
	. = ..()
	create_reagents(ammo)
	reagents.set_reacting(FALSE)

/obj/item/chemical_canister/on_reagent_change()
	var/datum/reagents/chem_content = reagents
	var/list/reagents_whitelist = src.reagents_whitelist
	if(is_clearing)
		return
	is_clearing = TRUE
	var/fuel_count = 0
	for(var/datum/reagent/reagent in chem_content.reagent_list)
		if(!reagent.chemfiresupp && !(reagent.type in reagents_whitelist))
			chem_content.del_reagent(reagent.type)
		if(istype(reagent, /datum/reagent/napalm))
			fuel_count += reagent.volume
	has_fuel = fuel_count > (ammo * 0.2)

/obj/item/chemical_canister/extended
	name = "extended capacity chemical canister"
	desc = "Увеличенная версия оригинальной конструкции."
	icon_state = "extended"
	ammo = 600
	materials = list(MAT_METAL = 10000)

/obj/item/chemical_canister/extended/get_ru_names()
	return alist(
		NOMINATIVE = "химический баллон повышенной ёмкости",
		GENITIVE = "химического баллона повышенной ёмкости",
		DATIVE = "химическому баллону повышенной ёмкости",
		ACCUSATIVE = "химический баллон повышенной ёмкости",
		INSTRUMENTAL = "химическим баллоном повышенной ёмкости",
		PREPOSITIONAL = "химическом баллоне повышенной ёмкости",
	)

/obj/item/chemical_canister/extended/nuclear
	name = "Syndicate chemical canister"
	desc = "Баллон, заранее заполненный напалмом, чтобы нести огненную смерть капитализму."
	icon_state = "pyro"

/obj/item/chemical_canister/extended/nuclear/get_ru_names()
	return alist(
		NOMINATIVE = "химический баллон Синдиката",
		GENITIVE = "химического баллона Синдиката",
		DATIVE = "химическому баллону Синдиката",
		ACCUSATIVE = "химический баллон Синдиката",
		INSTRUMENTAL = "химическим баллоном Синдиката",
		PREPOSITIONAL = "химическом баллоне Синдиката",
	)

/obj/item/chemical_canister/extended/nuclear/Initialize(mapload)
	..()
	reagents.add_reagent(/datum/reagent/napalm/penetrating, ammo) // Overload it with napalm!
