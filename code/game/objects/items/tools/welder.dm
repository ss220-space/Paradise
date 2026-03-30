#define GET_FUEL reagents.get_reagent_amount("fuel")

/obj/item/weldingtool
	name = "welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Оборудован небольшим баком для топлива."
	gender = MALE
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	item_state = "welder"
	belt_icon = "welding_tool"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	hitsound = SFX_SWING_HIT
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	materials = list(MAT_METAL=70, MAT_GLASS=30)
	origin_tech = "engineering=1;plasmatech=1"
	tool_behaviour = TOOL_WELDER
	tool_enabled = FALSE
	toolbox_radial_menu_compatibility = TRUE
	usesound = 'sound/items/welder.ogg'
	drop_sound = 'sound/items/handling/drop/weldingtool_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/weldingtool_pickup.ogg'
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_FIRE
	light_on = FALSE
	heat = T2500K
	var/force_enabled = 15
	var/maximum_fuel = 20
	/// Set to FALSE if it doesn't need fuel, but serves equally well as a cost modifier
	var/requires_fuel = TRUE
	/// Do we regenerate fuel?
	var/refills_over_time = FALSE
	var/activation_sound = 'sound/items/welderactivate.ogg'
	var/deactivation_sound = 'sound/items/welderdeactivate.ogg'
	var/light_intensity = 2
	/// More than one icon_state due to low fuel?
	var/low_fuel_changes_icon = TRUE
	/// Length of time between each "eye flash"
	var/progress_flash_divisor = 10

/obj/item/weldingtool/get_ru_names()
	return list(
		NOMINATIVE = "сварочный аппарат",
		GENITIVE = "сварочного аппарата",
		DATIVE = "сварочному аппарату",
		ACCUSATIVE = "сварочный аппарат",
		INSTRUMENTAL = "сварочным аппаратом",
		PREPOSITIONAL = "сварочном аппарате"
	)

/obj/item/weldingtool/Initialize(mapload)
	. = ..()
	create_reagents(maximum_fuel)
	reagents.add_reagent("fuel", maximum_fuel)
	update_icon()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)
	RegisterSignal(src, COMSIG_TOOLBOX_RADIAL_MENU_TOOL_USAGE, PROC_REF(handle_toolbox_signal))

/obj/item/weldingtool/Destroy()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, COMSIG_TOOLBOX_RADIAL_MENU_TOOL_USAGE)
	return ..()

/obj/item/weldingtool/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 0)
		. += span_notice("Индикатор топливного бака: <b>[GET_FUEL]/[maximum_fuel]</b>.")

/obj/item/weldingtool/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] заварива[PLUR_ET_YUT(user)] себе все лицевые отверстия! Это похоже на попытку самоубийства!"))
	return FIRELOSS

/obj/item/weldingtool/can_enter_storage(obj/item/storage/S, mob/user)
	if(tool_enabled)
		balloon_alert(user, "сначала выключите!")
		return FALSE
	else
		return TRUE

/obj/item/weldingtool/process()
	if(tool_enabled)
		var/turf/T = get_turf(src)
		if(T) // Implants for instance won't find a turf
			T.hotspot_expose(2500, 1)
		if(prob(5))
			remove_fuel(1)
	if(refills_over_time)
		if(GET_FUEL < maximum_fuel)
			reagents.add_reagent("fuel", 1)
	..()

/obj/item/weldingtool/extinguish_light(force = FALSE)
	if(!force)
		return
	if(!tool_enabled)
		return
	remove_fuel(maximum_fuel)

/obj/item/weldingtool/attack_self(mob/user)
	if(try_toggle_welder(user))
		return ..()

/obj/item/weldingtool/proc/handle_toolbox_signal(datum/source, mob/user)
	SIGNAL_HANDLER
	try_toggle_welder(user)

/obj/item/weldingtool/proc/try_toggle_welder(mob/user, manual_toggle = TRUE)
	if(tool_enabled) // Turn off the welder if it's on
		balloon_alert(user, "выключено")
		if(manual_toggle)
			toggle_welder()
		return TRUE
	else if(GET_FUEL) // The welder is off, but we need to check if there is fuel in the tank
		balloon_alert(user, "включено")
		if(manual_toggle)
			toggle_welder()
		return TRUE
	else // The welder is off and unfuelled
		balloon_alert(user, "нет топлива!")
		return FALSE

/// Turn it on or off, forces it to deactivate
/obj/item/weldingtool/proc/toggle_welder(turn_off = FALSE)
	tool_enabled = turn_off ? FALSE : !tool_enabled
	if(tool_enabled)
		START_PROCESSING(SSobj, src)
		damtype = BURN
		force = force_enabled
		hitsound = 'sound/items/welder.ogg'
		playsound(loc, activation_sound, 50, TRUE)
		set_light_on(TRUE)
	else
		if(!refills_over_time)
			STOP_PROCESSING(SSobj, src)
		damtype = BRUTE
		force = initial(force)
		hitsound = SFX_SWING_HIT
		playsound(loc, deactivation_sound, 50, TRUE)
		set_light_on(FALSE)
	update_icon()
	if(ismob(loc))
		var/mob/M = loc
		M.update_held_items()

// If welding tool ran out of fuel during a construction task, construction fails.
/obj/item/weldingtool/tool_use_check(mob/living/user, amount, silent = FALSE)
	if(!tool_enabled)
		if(!silent)
			balloon_alert(user, "выключено посреди процесса!")
		return FALSE
	if(GET_FUEL >= amount * requires_fuel)
		return TRUE
	else
		if(!silent)
			balloon_alert(user, "недостаточно топлива!")
		return FALSE

// When welding is about to start, run a normal tool_use_check, then flash a mob if it succeeds.
/obj/item/weldingtool/tool_start_check(atom/target, mob/living/user, amount=0)
	. = tool_use_check(user, amount)
	if(. && user && !ismob(target)) // Don't flash the user if they're repairing robo limbs or repairing a borg etc. Only flash them if the target is an object
		user.flash_eyes(light_intensity)

/obj/item/weldingtool/use(amount)
	if(GET_FUEL < amount * requires_fuel)
		return
	remove_fuel(amount)
	return TRUE

/obj/item/weldingtool/use_tool(atom/target, user, delay, amount, volume, datum/callback/extra_checks)
	var/mutable_appearance/sparks = mutable_appearance('icons/effects/welding_effect.dmi', "welding_sparks", GASFIRE_LAYER, src, ABOVE_LIGHTING_PLANE)
	target.add_overlay(sparks)
	LAZYADD(target.update_overlays_on_z, sparks)

	var/did_thing = ..()
	if(did_thing)
		remove_fuel(1) // Consume some fuel after we do a welding action
	if(delay)
		progress_flash_divisor = initial(progress_flash_divisor)

	LAZYREMOVE(target.update_overlays_on_z, sparks)
	target.cut_overlay(sparks)

	return did_thing

/obj/item/weldingtool/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	. = ..()
	if(. && user)
		if(progress_flash_divisor == 0)
			user.flash_eyes(min(light_intensity, TRUE))
			progress_flash_divisor = initial(progress_flash_divisor)
		else
			progress_flash_divisor--

/// Doesn't check if we have enough fuel, it just removes however much is left if there's not enough
/obj/item/weldingtool/proc/remove_fuel(amount)
	reagents.remove_reagent("fuel", amount * requires_fuel)
	if(!GET_FUEL)
		toggle_welder(TRUE)

/obj/item/weldingtool/refill(mob/user, atom/A, amount)
	if(!A.reagents)
		return
	if(GET_FUEL >= maximum_fuel)
		balloon_alert(user, "бак полон!")
		return
	var/amount_transferred = A.reagents.trans_id_to(src, "fuel", amount)
	if(amount_transferred)
		balloon_alert(user, "пополнено на <b>[amount_transferred]</b> единиц[DECL_CREDIT(amount_transferred)] топлива")
		playsound(src, 'sound/effects/refill.ogg', 50, TRUE)
		update_icon()
		return amount_transferred
	else
		A.balloon_alert(user, "нечем заправлять!")

/obj/item/weldingtool/update_icon_state()
	if(low_fuel_changes_icon)
		var/ratio = GET_FUEL / maximum_fuel
		ratio = CEILING(ratio*4, 1) * 25
		if(ratio == 100)
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)][ratio]"
	if(tool_enabled)
		item_state = "[initial(item_state)]1"
	else
		item_state = "[initial(item_state)]"

/obj/item/weldingtool/update_overlays()
	. = ..()
	if(tool_enabled)
		. += "[initial(icon_state)]-on"

/obj/item/weldingtool/get_temperature()
	return tool_enabled * heat

/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Оборудован баком для топлива увеличенного объёма."
	icon_state = "indwelder"
	belt_icon = "industrial_welding_tool"
	maximum_fuel = 40
	materials = list(MAT_METAL=70, MAT_GLASS=60)
	origin_tech = "engineering=2;plasmatech=2"

/obj/item/weldingtool/largetank/get_ru_names()
	return list(
		NOMINATIVE = "промышленный сварочный аппарат",
		GENITIVE = "промышленного сварочного аппарата",
		DATIVE = "промышленному сварочному аппарату",
		ACCUSATIVE = "промышленный сварочный аппарат",
		INSTRUMENTAL = "промышленным сварочным аппаратом",
		PREPOSITIONAL = "промышленном сварочном аппарате"
	)

/obj/item/weldingtool/largetank/cyborg
	name = "integrated welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Оборудован небольшим баком для топлива. \
			Специализированная версия для установки в роботизированные системы."
	toolspeed = 0.5

/obj/item/weldingtool/largetank/cyborg/get_ru_names()
	return list(
		NOMINATIVE = "встроенный сварочный аппарат",
		GENITIVE = "встроенного сварочного аппарата",
		DATIVE = "встроенному сварочному аппарату",
		ACCUSATIVE = "встроенный сварочный аппарат",
		INSTRUMENTAL = "встроенным сварочным аппаратом",
		PREPOSITIONAL = "встроенном сварочном аппарате"
	)

/obj/item/weldingtool/mini
	name = "emergency welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Уменьшенная версия, предназначенная для чрезвычайных ситуаций."
	icon_state = "miniwelder"
	maximum_fuel = 10
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	low_fuel_changes_icon = FALSE

/obj/item/weldingtool/mini/get_ru_names()
	return list(
		NOMINATIVE = "аварийный сварочный аппарат",
		GENITIVE = "аварийного сварочного аппарата",
		DATIVE = "аварийному сварочному аппарату",
		ACCUSATIVE = "аварийный сварочный аппарат",
		INSTRUMENTAL = "аварийным сварочным аппаратом",
		PREPOSITIONAL = "аварийном сварочном аппарате"
	)

/obj/item/weldingtool/abductor
	name = "alien welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Кажется, будто бы запас топлива в баке неиссякаем."
	icon = 'icons/obj/abductor.dmi'
	item_state = "alienwelder"
	belt_icon = "alien_welding_tool"
	toolspeed = 0.1
	light_intensity = 0
	origin_tech = "plasmatech=5;engineering=5;abductor=3"
	requires_fuel = FALSE
	refills_over_time = TRUE
	low_fuel_changes_icon = FALSE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/weldingtool/abductor/get_ru_names()
	return list(
		NOMINATIVE = "чужеродный сварочный аппарат",
		GENITIVE = "чужеродного сварочного аппарата",
		DATIVE = "чужеродному сварочному аппарату",
		ACCUSATIVE = "чужеродный сварочный аппарат",
		INSTRUMENTAL = "чужеродным сварочным аппаратом",
		PREPOSITIONAL = "чужеродном сварочном аппарате"
	)

/obj/item/weldingtool/hugetank
	name = "upgraded welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Оборудован баком для топлива большого объёма."
	icon_state = "upindwelder"
	item_state = "upindwelder"
	belt_icon = "upgraded_welding_tool"
	maximum_fuel = 80
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "engineering=3;plasmatech=2"

/obj/item/weldingtool/hugetank/get_ru_names()
	return list(
		NOMINATIVE = "улучшенный сварочный аппарат",
		GENITIVE = "улучшенного сварочного аппарата",
		DATIVE = "улучшенному сварочному аппарату",
		ACCUSATIVE = "улучшенный сварочный аппарат",
		INSTRUMENTAL = "улучшенным сварочным аппаратом",
		PREPOSITIONAL = "улучшенном сварочном аппарате"
	)

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Оборудован баком для топлива увеличенного объёма. \
			Экспериментальная модель, способная синтезировать топливо и \
			обладающая уменьшенной нагрузкой на органы зрения пользователя."
	icon_state = "exwelder"
	item_state = "exwelder"
	belt_icon = "experimental_welding_tool"
	maximum_fuel = 40
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "materials=4;engineering=4;bluespace=3;plasmatech=4"
	light_intensity = 1
	toolspeed = 0.5
	refills_over_time = TRUE
	low_fuel_changes_icon = FALSE

/obj/item/weldingtool/experimental/get_ru_names()
	return list(
		NOMINATIVE = "экспериментальный сварочный аппарат",
		GENITIVE = "экспериментального сварочного аппарата",
		DATIVE = "экспериментальному сварочному аппарату",
		ACCUSATIVE = "экспериментальный сварочный аппарат",
		INSTRUMENTAL = "экспериментальным сварочным аппаратом",
		PREPOSITIONAL = "экспериментальном сварочном аппарате"
	)

/obj/item/weldingtool/experimental/mecha
	name = "integrated welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Оборудован баком для топлива увеличенного объёма. \
			Экспериментальная модель, способная синтезировать топливо и \
			обладающая уменьшенной нагрузкой на органы зрения пользователя. \
			Специализированная версия для установки в роботизированные системы."
	requires_fuel = FALSE
	light_intensity = 0

/obj/item/weldingtool/experimental/mecha/get_ru_names()
	return list(
		NOMINATIVE = "встроенный сварочный аппарат",
		GENITIVE = "встроенного сварочного аппарата",
		DATIVE = "встроенному сварочному аппарату",
		ACCUSATIVE = "встроенный сварочный аппарат",
		INSTRUMENTAL = "встроенным сварочным аппаратом",
		PREPOSITIONAL = "встроенном сварочном аппарате"
	)

/obj/item/weldingtool/experimental/brass
	name = "brass welding tool"
	desc = "Инструмент, используемый для выполнения сварочных работ. \
			Оборудован баком для топлива увеличенного объёма. \
			Способен синтезировать топливо и \
			обладает уменьшенной нагрузкой на органы зрения пользователя. \
			На ощупь слегка тёплый."
	icon_state = "brasswelder"
	item_state = "brasswelder"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_enabled = 10

/obj/item/weldingtool/experimental/brass/get_ru_names()
	return list(
		NOMINATIVE = "латунный сварочный аппарат",
		GENITIVE = "латунного сварочного аппарата",
		DATIVE = "латунному сварочному аппарату",
		ACCUSATIVE = "латунный сварочный аппарат",
		INSTRUMENTAL = "латунным сварочным аппаратом",
		PREPOSITIONAL = "латунном сварочном аппарате"
	)

#undef GET_FUEL
