/**
 * MARK: FLash
 */

/obj/item/flash
	name = "flash"
	desc = "Многоцелевое импульсное осветительное устройство. При активации испускает яркую вспышку, что может быть использовано как для дезориентации противника в бою, \
			так и для калибровки роботизированных оптических сенсоров. Матрица имеет тенденцию быстро выгорать при активном использовании."
	gender = MALE
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"
	belt_icon = "flash"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	flags = CONDUCT
	materials = list(MAT_METAL = 300, MAT_GLASS = 300)
	origin_tech = "magnets=2;combat=1"
	/// Number of times it's been used.
	var/times_used = 0
	/// Is the flash burnt out?
	var/broken = FALSE
	/// last world.time it was used.
	var/last_used = 0
	/// Whether the flash can be modified with a cell or not
	var/battery_panel = FALSE
	/// If overcharged the flash will set people on fire then immediately burn out (does so even if it doesn't blind them).
	var/overcharged = FALSE
	/// Set this to FALSE if you don't want your flash to be overcharge capable
	var/can_overcharge = TRUE
	var/use_sound = 'sound/weapons/flash.ogg'
	/// This is the duration of the cooldown
	var/cooldown_duration = 1 SECONDS
	COOLDOWN_DECLARE(flash_cooldown)
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE
	light_range = 2

/obj/item/flash/get_ru_names()
	return list(
		NOMINATIVE = "флешер",
		GENITIVE = "флешера",
		DATIVE = "флешеру",
		ACCUSATIVE = "флешер",
		INSTRUMENTAL = "флешером",
		PREPOSITIONAL = "флешере"
	)

/obj/item/flash/update_icon_state()
	icon_state = "[initial(icon_state)][broken ? "burnt" : ""]"

/obj/item/flash/update_overlays()
	. = ..()
	if(overcharged)
		. += "overcharge"

/obj/item/flash/proc/clown_check(mob/user)
	if(user && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		flash_carbon(user, user, 30 SECONDS, 0)
		return FALSE
	return TRUE

/obj/item/flash/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!can_overcharge)
		balloon_alert(user, "панель отсутствует!")
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	battery_panel = !battery_panel
	balloon_alert(user, "отсек для батареи [battery_panel ? "от" : "за"]крыт")

/obj/item/flash/attackby(obj/item/I, mob/user, params)
	if(!can_overcharge || !iscell(I))
		return ..()
	add_fingerprint(user)
	if(!battery_panel)
		balloon_alert(user, "панель закрыта!")
		return ATTACK_CHAIN_PROCEED
	if(overcharged)
		balloon_alert(user, "слот для батареи занят!")
		return ATTACK_CHAIN_PROCEED
	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()
	. = ATTACK_CHAIN_BLOCKED_ALL
	balloon_alert(user, "батарея установлена")
	overcharged = TRUE
	update_icon(UPDATE_OVERLAYS)
	qdel(I)

/obj/item/flash/random/Initialize(mapload)
	. = ..()
	if(prob(25))
		broken = TRUE
		update_icon(UPDATE_ICON_STATE)

/// Made so you can override it if you want to have an invincible flash from R&D or something.
/obj/item/flash/proc/burn_out()
	broken = TRUE
	update_icon(UPDATE_ICON_STATE)
	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] выгорает!"))

/obj/item/flash/proc/flash_recharge(mob/user)
	if(prob(times_used * 2)) // if you use it 5 times in a minute it has a 10% chance to break!
		burn_out()
		return FALSE

	var/deciseconds_passed = world.time - last_used
	times_used -= round(deciseconds_passed / 100) // get 1 charge every 10 seconds

	last_used = world.time
	times_used = max(0, times_used) // sanity

/obj/item/flash/proc/try_use_flash(mob/user)
	if(broken)
		return FALSE
	if(!COOLDOWN_FINISHED(src, flash_cooldown))
		if(user)
			balloon_alert(user, "ещё не готово!")
		return FALSE
	COOLDOWN_START(src, flash_cooldown, cooldown_duration)
	flash_recharge(user)

	playsound(loc, use_sound, 100, TRUE)
	flick("[initial(icon_state)]2", src)
	set_light_on(TRUE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light_on), FALSE), 2)
	times_used++

	if(user && !clown_check(user))
		return FALSE

	return TRUE

/obj/item/flash/proc/flash_carbon(mob/living/carbon/target, mob/user, power = 10 SECONDS, targeted = TRUE)
	if(user)
		add_attack_logs(user, target, "Flashed with [src]")
		if(targeted)
			if(target.weakeyes)
				/// quick weaken bypasses eye protection but has no eye flash
				target.Weaken(6 SECONDS)
			if(target.flash_eyes(1, TRUE))
				target.AdjustConfused(power)
				target.Stun(2 SECONDS)
				target.visible_message(
					span_disarm("[user.declent_ru(NOMINATIVE)] ослепля[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]!"),
					span_userdanger("[user.declent_ru(NOMINATIVE)] ослепля[PLUR_ET_YUT(user)] вас [declent_ru(INSTRUMENTAL)]!"),
					ignored_mobs = user,
				)
				target.balloon_alert(user, "цель ослеплена!")
				if(target.weakeyes)
					target.Stun(4 SECONDS)
					target.visible_message(
						span_disarm("[user.declent_ru(NOMINATIVE)] ослепля[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]!"),
						span_userdanger("[user.declent_ru(NOMINATIVE)] ослепля[PLUR_ET_YUT(user)] вас [declent_ru(INSTRUMENTAL)]!"),
					)
					target.visible_message(
						span_disarm("[target.declent_ru(NOMINATIVE)] пыта[PLUR_ET_YUT(target)]ся прикрыть свои глаза!"),
						span_userdanger("Вы пытаетесь прикрыть свои глаза!")
					)
			else
				target.visible_message(
					span_disarm("[user.declent_ru(NOMINATIVE)] безуспешно пыта[PLUR_ET_YUT(user)]ся ослепить [target.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]!"),
					span_userdanger("[user.declent_ru(NOMINATIVE)] безуспешно пыта[PLUR_ET_YUT(user)]ся ослепить вас [declent_ru(INSTRUMENTAL)]!"),
					ignored_mobs = user,
				)
				target.balloon_alert(user, "не удалось ослепить!")
			return

	if(target.flash_eyes())
		target.AdjustConfused(power)

/obj/item/flash/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!try_use_flash(user))
		return .
	if(iscarbon(target))
		flash_carbon(target, user, 10 SECONDS, TRUE)
		if(overcharged)
			target.adjust_fire_stacks(6)
			target.IgniteMob()
			burn_out()
		return .|ATTACK_CHAIN_SUCCESS
	if(issilicon(target))
		add_attack_logs(user, target, "Flashed with [src]")
		if(target.flash_eyes(affect_silicon = TRUE))
			target.Weaken(rand(10 SECONDS, 20 SECONDS))
			target.visible_message(
				span_disarm("[user.declent_ru(NOMINATIVE)] перегружа[PLUR_ET_YUT(user)] оптические сенсоры [target.declent_ru(GENITIVE)] [declent_ru(INSTRUMENTAL)]!"),
				span_userdanger("[user.declent_ru(NOMINATIVE)] перегружа[PLUR_ET_YUT(user)] ваши оптические сенсоры [declent_ru(INSTRUMENTAL)]!"),
				ignored_mobs = user,
			)
			target.balloon_alert(user, "цель ослеплена!")
		return .|ATTACK_CHAIN_SUCCESS
	target.visible_message(
		span_disarm("[user.declent_ru(NOMINATIVE)] безуспешно пыта[PLUR_ET_YUT(user)]ся ослепить [target.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]!"),
		span_userdanger("[user.declent_ru(NOMINATIVE)] безуспешно пыта[PLUR_ET_YUT(user)]ся ослепить вас [declent_ru(INSTRUMENTAL)]!"),
		ignored_mobs = user,
	)
	target.balloon_alert(user, "не удалось ослепить!")

/obj/item/flash/attack_self(mob/living/carbon/user, flag = 0, emp = FALSE)
	if(!try_use_flash(user))
		return FALSE
	user.visible_message(
		span_disarm("[DECLENT_RU_CAP(src, NOMINATIVE)] в руках [user.declent_ru(GENITIVE)] озаряется яркой вспышкой!"),
		ignored_mobs = user,
	)
	for(var/mob/living/carbon/target in oviewers(3, get_turf(src)))
		flash_carbon(target, user, 6 SECONDS, FALSE)

/obj/item/flash/emp_act(severity)
	if(!try_use_flash())
		return FALSE
	for(var/mob/living/carbon/target in viewers(3, get_turf(src)))
		flash_carbon(target, null, 20 SECONDS, FALSE)
	burn_out()
	..()

/**
 * MARK: Cyborg flash
 */

/obj/item/flash/cyborg
	origin_tech = null

/obj/item/flash/cyborg/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/flash/cyborg/attack_self(mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/**
 * MARK: Camera flash
 */

/obj/item/flash/cameraflash // TODO: translate when `/obj/item/camera` is translated
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack"
	belt_icon = null
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	can_overcharge = FALSE
	var/flash_max_charges = 5
	var/flash_cur_charges = 5
	var/charge_tick = 0
	use_sound = 'sound/items/polaroid1.ogg'

/obj/item/flash/cameraflash/get_ru_names()
	return list(
		NOMINATIVE = "фотоаппарат",
		GENITIVE = "фотоаппарата",
		DATIVE = "фотоаппарату",
		ACCUSATIVE = "фотоаппарат",
		INSTRUMENTAL = "фотоаппаратом",
		PREPOSITIONAL = "фотоаппарате"
	)

/obj/item/flash/cameraflash/burn_out() //stops from burning out
	return

/obj/item/flash/cameraflash/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/flash/cameraflash/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flash/cameraflash/process() //this and the two parts above are part of the charge system.
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	flash_cur_charges = min(flash_cur_charges+1, flash_max_charges)
	return TRUE

/obj/item/flash/cameraflash/try_use_flash(mob/user)
	if(!flash_cur_charges)
		if(user)
			balloon_alert(user, "ещё не готово!")
		return FALSE
	. = ..()
	if(.)
		flash_cur_charges--
		if(user)
			balloon_alert(user, "зарядов осталось — [flash_cur_charges]")

/**
 * MARK: Arm implant flash
 */

/obj/item/flash/armimplant
	name = "photon projector"
	desc = "Высокомощное устройство, предназначенное в первую очередь для освещения, хотя и может быть использовано в качестве средства самообороны. \
			Протоколы самовосстановления автоматически восстановят матрицу в случае выгорания."
	cooldown_duration = 2 SECONDS
	var/obj/item/organ/internal/cyberimp/arm/flash/I = null

/obj/item/flash/armimplant/get_ru_names()
	return list(
		NOMINATIVE = "фотонный излучатель",
		GENITIVE = "фотонного излучателя",
		DATIVE = "фотонному излучателю",
		ACCUSATIVE = "фотонный излучатель",
		INSTRUMENTAL = "фотонным излучателем",
		PREPOSITIONAL = "фотонном излучателе"
	)

/obj/item/flash/armimplant/Destroy()
	I = null
	return ..()

/obj/item/flash/armimplant/burn_out()
	if(I?.owner)
		balloon_alert(I.owner, "имплант перегружен!")
		I.Retract()

/**
 * MARK: Synthetic flash
 */

/obj/item/flash/synthetic //just a regular flash now
