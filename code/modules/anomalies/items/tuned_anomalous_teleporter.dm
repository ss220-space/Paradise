/obj/item/assembly/tuned_anomalous_teleporter
	name = "tuned anomalous teleporter"
	ru_names = list(
		NOMINATIVE = "настраеваемый аномальный телепортер", \
		GENITIVE = "настраеваемого аномального телепортера", \
		DATIVE = "настраеваемому аномальному телепортеру", \
		ACCUSATIVE = "настраеваемый аномальный телепортер", \
		INSTRUMENTAL = "настраеваемым аномальным телепортером", \
		PREPOSITIONAL = "настраеваемом аномальном телепортере"
	)
	desc = "Портативный настраиваемый телепортер использующий ядро блюспейс аномалии для телепортации пользователя в \
			выбранном направлении."
	icon = 'icons/obj/weapons/techrelic.dmi'
	icon_state = "teleport"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	item_state = "teleport"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000)
	origin_tech = "magnets=3;bluespace=4"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	origin_tech = "bluespace=5"
	gender = MALE

	/// Inserted bluespace anomaly core.
	var/obj/item/assembly/signaler/core/bluespace/core = null
	/// Variable contains next time hand tele can be used to make it not EMP proof
	var/emp_timer = 0
	/// Cooldown for teleportations.
	var/base_cooldown = 20 SECONDS
	/// Minimum waiting time after EMP.
	var/emp_cooldown_min = 10 SECONDS // min cooldown for emp
	/// Maximum waiting time after EMP.
	var/emp_cooldown_max = 15 SECONDS // max cooldown for emp
	/// Selected range of teleportations.
	var/tp_range = 0
	/// Max allowed range of teleportations.
	var/max_tp_range = 0

	COOLDOWN_DECLARE(tuned_anomalous_teleporter_cooldown) // declare cooldown for teleportations
	COOLDOWN_DECLARE(emp_cooldown) // declare cooldown for EMP

/obj/item/assembly/tuned_anomalous_teleporter/Initialize(mapload)
	. = ..()
	update_core()

/obj/item/assembly/tuned_anomalous_teleporter/Destroy()
	core?.forceMove(get_turf(src))
	core = null
	. = ..()

/obj/item/assembly/tuned_anomalous_teleporter/proc/can_teleport(mob/user)
	if(max_tp_range < 5)
		if(user)
			to_chat(user, span_warning("[declent_ru(NOMINATIVE)] не может вас телепортировать, \
											из-за отсутствия достаточно сильного ядра."))
		return FALSE

	if(!COOLDOWN_FINISHED(src, emp_cooldown))
		do_sparks(5, FALSE, loc)
		if(user)
			to_chat(user, span_warning("[declent_ru(NOMINATIVE)] не может вас телепортировать, \
										из-за того, что он временно выведен из строя."))

		return FALSE

	if(!COOLDOWN_FINISHED(src, tuned_anomalous_teleporter_cooldown))
		if(user)
			to_chat(user, span_warning("[declent_ru(NOMINATIVE)] все ещё перезаряжается."))

		return FALSE

	return TRUE

/obj/item/assembly/tuned_anomalous_teleporter/activate(mob/user)
	if(!can_teleport(user))
		return

	var/atom/tp_target = src
	if(user)
		tp_target = user
	else
		while(!isturf(tp_target.loc))
			tp_target = tp_target.loc

	COOLDOWN_START(src, tuned_anomalous_teleporter_cooldown, base_cooldown)

	var/datum/teleport/TP = new /datum/teleport()
	var/crossdir = angle2dir((dir2angle(tp_target.dir)) % 360)
	var/turf/T1 = get_turf(tp_target)
	for(var/i in 1 to tp_range)
		T1 = get_step(T1, crossdir)

	var/datum/effect_system/fluid_spread/smoke/s1 = new
	var/datum/effect_system/fluid_spread/smoke/s2 = new
	s1.set_up(5, FALSE, tp_target)
	s2.set_up(5, FALSE, tp_target)
	TP.start(tp_target, T1, FALSE, TRUE, s1, s2, 'sound/effects/phasein.ogg', )
	TP.doTeleport()

/obj/item/assembly/tuned_anomalous_teleporter/attack_self(mob/user)
	activate(user)

/obj/item/assembly/tuned_anomalous_teleporter/emp_act(severity)
	make_inactive(severity)
	return ..()

/obj/item/assembly/tuned_anomalous_teleporter/proc/make_inactive(severity)
	var/time = rand(emp_cooldown_min, emp_cooldown_max) * (severity == EMP_HEAVY ? 2 : 1)
	COOLDOWN_START(src, emp_cooldown, time)

/obj/item/assembly/tuned_anomalous_teleporter/examine(mob/user)
	. = ..()
	if(!core)
		. += span_warning("В [declent_ru(PREPOSITIONAL)] нет ядра!")
	else
		. += span_info("В [declent_ru(PREPOSITIONAL)] есть ядро.")

	if(emp_timer > world.time)
		. += span_warning("[declent_ru(NOMINATIVE)] выглядит неработающим.")

/obj/item/assembly/tuned_anomalous_teleporter/click_alt(mob/user)
	if(!user.contains(src))
		return

	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	user.put_in_active_hand(core)
	core = null
	user.balloon_alert(user, "ядро извлечено")
	update_core()

/obj/item/assembly/tuned_anomalous_teleporter/attackby(obj/item/item, mob/user, params)
	if(!iscorebluespace(item))
		return ..()

	add_fingerprint(user)
	var/msg = "ядро вставлено"
	if(core)
		user.put_in_hands(core)
		msg = "ядро заменено"

	if(!user.drop_transfer_item_to_loc(item, src))
		balloon_alert(user, "отпустить невозможно!")
		return ATTACK_CHAIN_PROCEED

	core = item
	balloon_alert(user, msg)
	update_core()
	return ATTACK_CHAIN_PROCEED

/obj/item/assembly/tuned_anomalous_teleporter/attack_hand(mob/user, pickupfireoverride)
	if(!core || !user.is_in_hands(src))
		return ..()

	add_fingerprint(user)
	if(max_tp_range < 5)
		to_chat(user, span_warning("В [declent_ru(PREPOSITIONAL)] нет ядра, достаточно сильного, для телепортации."))
		return

	var/new_range = tgui_input_number(user, "Выберите дистанцию телепортации", "Настройка телепортера", tp_range, max_tp_range, 1)
	if(!new_range)
		return

	if(get_dist(user, src) > 1)
		user.balloon_alert(user, "слишком далеко")
		return

	tp_range = clamp(new_range, 1, max_tp_range)
	user.balloon_alert(user, "выбрана дистанция [tp_range]")

/*
Ranges with core charge 50-100:
	tier1 - 1-3 (to weak for any)
	tier2 - 3-7
	tier3 - 7-10
*/
/obj/item/assembly/tuned_anomalous_teleporter/proc/update_core()
	if(!core)
		max_tp_range = 0
		tp_range = 0
		return

	var/old_max_tp_range = max_tp_range
	max_tp_range = max(1, round((core.get_strenght() + 10) / 30))
	if(tp_range != old_max_tp_range) // If was max, set max, else leave old.
		tp_range = max_tp_range

/obj/item/assembly/tuned_anomalous_teleporter/suicide_act(mob/user)
	if(!can_teleport()) // Without massages.
		return ..()

	user.visible_message(span_suicide("[user] перенастраива[pluralize_ru(user.gender,"ет","ют")] [declent_ru(NOMINATIVE)] случайным образом и пыта[pluralize_ru(user.gender,"ет","ют")]ся телепортироваться! Выглядит, будто он[genderize_ru(gender, "", "а", "о", "и")] хо[genderize_ru(gender, "чет", "чет", "чет", "тят")] убить себя!"))
	if(!do_after(user, 1 SECONDS, user))
		return ..()

	tp_range = rand(1, max_tp_range)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(10, FALSE, user)
	smoke.start()
	user.gib()
	return OBLITERATION

/obj/item/assembly/tuned_anomalous_teleporter/bullet_act(obj/projectile/projectile)
	. = ..(projectile)
	activate()

/obj/item/assembly/tuned_anomalous_teleporter/preloaded
	core = new /obj/item/assembly/signaler/core/bluespace/tier2()

/datum/crafting_recipe/tuned_anomalous_teleporter
	name = "Tuned anomalous teleporter"
	result = /obj/item/assembly/tuned_anomalous_teleporter
	tools = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	reqs = list(/obj/item/relict_production/strange_teleporter = 1,
				/obj/item/gps = 1,
				/obj/item/stack/ore/bluespace_crystal,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/stack/cable_coil = 5)
	time = 300
	category = CAT_MISC
