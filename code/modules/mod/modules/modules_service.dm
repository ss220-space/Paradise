//Service modules for MODsuits

// MARK: Bike horn
/// Bike Horn - Plays a bike horn sound.
/obj/item/mod/module/bikehorn
	name = "MOD bike horn module"
	desc = "Модуль для МЭК, располагающийся в плече костюма. Представляет собой систему фемто-манипуляторов, \
			предназначенных для точных и быстрых сжатий... клаксона, издающего навсегда въедающийся в память звук. \
			Технология запатентована \"Биб-Ко\"."
	icon_state = "bikehorn"
	module_type = MODULE_USABLE
	complexity = 1
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/bikehorn)
	cooldown_time = 1 SECONDS

/obj/item/mod/module/bikehorn/get_ru_names()
	return list(
		NOMINATIVE = "модуль гудка",
		GENITIVE = "модуля гудка",
		DATIVE = "модулю гудка",
		ACCUSATIVE = "модуль гудка",
		INSTRUMENTAL = "модулем гудка",
		PREPOSITIONAL = "модуле гудка",
	)

/obj/item/mod/module/bikehorn/on_use()
	playsound(src, 'sound/items/bikehorn.ogg', 100, FALSE)
	drain_power(use_energy_cost)

// MARK: Waddle
//Waddle - Makes you waddle and squeak.
/obj/item/mod/module/waddle
	name = "MOD waddle module"
	desc = "Модуль для МЭК, одна из наиболее примитивных технологий на вооружении \"Биб-Ко\". Работает за счёт автоматической системы, \
			чувствительной к намерениям зачастую обделённого мозговой активностью пользователя для предсказания его следующего шага, \
			влияя на работу обуви, к которой она подключена. Это позволяет ей использовать спаренный гравитонный привод для создания \
			миниатюрных эфирных колебаний пространства-времени под ногами пользователя, открывая ему возможность... \
			беззаботно скакать вприпрыжку, покачиваясь взад и вперёд."
	icon_state = "waddle"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/waddle)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/waddle/get_ru_names()
	return list(
		NOMINATIVE = "модуль покачивания",
		GENITIVE = "модуля покачивания",
		DATIVE = "модулю покачивания",
		ACCUSATIVE = "модуль покачивания",
		INSTRUMENTAL = "модулем покачивания",
		PREPOSITIONAL = "модуле покачивания",
	)

/obj/item/mod/module/waddle/on_part_activation()
	var/obj/item/shoes = mod.get_part_from_slot(ITEM_SLOT_FEET)
	if(shoes)
		shoes.AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg' = 1, 'sound/effects/clownstep2.ogg' = 1), 50, falloff_exponent = 20) //die off quick please
	mod.wearer.AddElement(/datum/element/waddling)

/obj/item/mod/module/waddle/on_part_deactivation(deleting = FALSE)
	var/obj/item/shoes = mod.get_part_from_slot(ITEM_SLOT_FEET)
	if(shoes && !deleting)
		qdel(shoes.GetComponent(/datum/component/squeak))
	mod.wearer.RemoveElement(/datum/element/waddling)

// MARK: Boot heating
/// Boot heating - dries floors like galoshes/dry
/obj/item/mod/module/boot_heating
	name = "MOD boot heating module"
	desc = "Модуль для МЭК, устанавливаемый в ботинки костюма. Нагревает подошвы, позволяя осушать мокрый пол под \
			ногами пользователя."
	icon_state = "regulator"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	required_slots = list(ITEM_SLOT_FEET)
	incompatible_modules = list(/obj/item/mod/module/boot_heating)

/obj/item/mod/module/boot_heating/get_ru_names()
	return list(
		NOMINATIVE = "модуль осушающей обуви",
		GENITIVE = "модуля осушающей обуви",
		DATIVE = "модулю осушающей обуви",
		ACCUSATIVE = "модуль осушающей обуви",
		INSTRUMENTAL = "модулем осушающей обуви",
		PREPOSITIONAL = "модуле осушающей обуви",
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
