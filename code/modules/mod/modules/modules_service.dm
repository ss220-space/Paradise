//Service modules for MODsuits

///Bike Horn - Plays a bike horn sound.
/obj/item/mod/module/bikehorn
	name = "MOD bike horn module"
	desc = "A shoulder-mounted piece of heavy sonic artillery, this module uses the finest femto-manipulator technology to \
		precisely deliver an almost lethal squeeze to... a bike horn, producing a significantly memorable sound."
	icon_state = "bikehorn"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/bikehorn)
	cooldown_time = 1 SECONDS

/obj/item/mod/module/bikehorn/get_ru_names()
	return list(
		NOMINATIVE = "модуль гудка для МЭК",
		GENITIVE = "модуля гудка для МЭК",
		DATIVE = "модулю гудка для МЭК",
		ACCUSATIVE = "модуль гудка для МЭК",
		INSTRUMENTAL = "модулем гудка для МЭК",
		PREPOSITIONAL = "модуле гудка для МЭК",
	)

/obj/item/mod/module/bikehorn/on_use()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/bikehorn.ogg', 100, FALSE)
	drain_power(use_energy_cost)

//Waddle - Makes you waddle and squeak.
/obj/item/mod/module/waddle
	name = "MOD waddle module"
	desc = "Some of the most primitive technology in use by Honk Co. This module works off an automatic intention system, \
		utilizing its' sensitivity to the pilot's often-limited brainwaves to directly read their next step, \
		affecting the boots they're installed in. Employing a twin-linked gravitonic drive to create \
		miniaturized etheric blasts of space-time beneath the user's feet, this enables them to... \
		to waddle around, bouncing to and fro with a pep in their step."
	icon_state = "waddle"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/waddle)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/waddle/get_ru_names()
	return list(
		NOMINATIVE = "модуль покачивания для МЭК",
		GENITIVE = "модуля покачивания для МЭК",
		DATIVE = "модулю покачивания для МЭК",
		ACCUSATIVE = "модуль покачивания для МЭК",
		INSTRUMENTAL = "модулем покачивания для МЭК",
		PREPOSITIONAL = "модуле покачивания для МЭК",
	)

/obj/item/mod/module/waddle/on_part_activation()
	var/obj/item/shoes = mod.get_part_from_slot(ITEM_SLOT_FEET)
	if(shoes)
		shoes.AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg' = 1, 'sound/effects/clownstep2.ogg' = 1), 50, falloff_exponent = 20) //die off quick please
	shoes.AddElement(/datum/element/waddling)

/obj/item/mod/module/waddle/on_part_deactivation(deleting = FALSE)
	var/obj/item/shoes = mod.get_part_from_slot(ITEM_SLOT_FEET)
	if(shoes && !deleting)
		qdel(shoes.GetComponent(/datum/component/squeak))
	shoes.RemoveElement(/datum/element/waddling)

//Boot heating - dries floors like galoshes/dry
/obj/item/mod/module/boot_heating
	name = "MOD boot heating module"
	desc = "A MOD suit boot heating module. Heats the bottom of the boots to assist in drying wet floors as you clean. Only for the most well trained of janitorial staff." /// Kinda small comparied to the other descriptions, but its ERT only, so..
	icon_state = "regulator"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/boot_heating)

/obj/item/mod/module/boot_heating/get_ru_names()
	return list(
		NOMINATIVE = "модуль согревающей обуви для МЭК",
		GENITIVE = "модуля согревающей обуви для МЭК",
		DATIVE = "модулю согревающей обуви для МЭК",
		ACCUSATIVE = "модуль согревающей обуви для МЭК",
		INSTRUMENTAL = "модулем согревающей обуви для МЭК",
		PREPOSITIONAL = "модуле согревающей обуви для МЭК",
	)

/obj/item/mod/module/boot_heating/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_step))

/obj/item/mod/module/boot_heating/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)

/obj/item/mod/module/boot_heating/proc/on_step()
	SIGNAL_HANDLER

	var/turf/simulated/t_loc = get_turf(src)
	if(istype(t_loc) && t_loc.wet)
		t_loc.MakeDry(TURF_WET_WATER)

// recharging cleaner spray module
/obj/item/mod/module/mister/cleaner
	name = "MOD janitorial mister module"
	desc = "A space cleaner mister, able to clean up messes quickly. Synthesizes its own supply over time (if active)."
	device = /obj/item/reagent_containers/spray/mister/janitor
	volume = 100
	active_power_cost = DEFAULT_CHARGE_DRAIN

/obj/item/mod/module/mister/cleaner/Initialize(mapload)
	. = ..()
	reagents.flags = AMOUNT_VISIBLE
	reagents.add_reagent(/datum/reagent/space_cleaner, volume)

/obj/item/mod/module/mister/cleaner/on_active_process(seconds_per_tick)
	var/refill_add = min(volume - reagents.total_volume, 2 * seconds_per_tick)
	if(refill_add > 0)
		reagents.add_reagent(/datum/reagent/space_cleaner, refill_add)
