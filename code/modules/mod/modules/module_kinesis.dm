///Kinesis - Gives you the ability to move and launch objects.
/obj/item/mod/module/anomaly_locked/kinesis
	name = "MOD kinesis module"
	desc = "Модуль для МЭК, подключаемый к предплечью костюма. Генерирует локальное поле анти-гравитации, \
			что позволяет пользователю с лёгкостью перемещать объекты в пространстве, будь то небольшой титановый стержень \
			или тяжёлая промышленная техника."
	icon_state = "kinesis"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked/kinesis)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_kinesis"
	overlay_state_active = "module_kinesis_on"
	accepted_anomalies = list(/obj/item/assembly/signaler/core/gravitational)
	required_slots = list(ITEM_SLOT_GLOVES)
	/// The maximum amount of range, that we can get from core
	var/maximum_grab_range = 8
	/// Range of the kinesis grab.
	var/grab_range = 5
	/// Time between us hitting objects with kinesis.
	var/hit_cooldown_time = 1 SECONDS
	/// Stat required for us to grab a mob.
	var/stat_required = DEAD
	/// Is incapitated required for us to grab a mob?
	var/incapacitated_required = TRUE
	/// How long we stun a mob for.
	var/mob_stun_time = 0
	/// Atom we grabbed with kinesis.
	var/atom/movable/grabbed_atom
	/// Overlay we add to each grabbed atom.
	var/image/kinesis_icon
	/// Our mouse movement catcher.
	var/atom/movable/screen/fullscreen/cursor_catcher/kinesis/kinesis_catcher
	/// The sounds playing while we grabbed an object.
	var/datum/looping_sound/kinesis/soundloop
	///The pixel_X of whatever we were grabbing before hand.
	var/pre_pixel_x
	///The pixel_y of whatever we were grabbing before hand.
	var/pre_pixel_y
	/// Ref of the beam following the grabbed atom.
	var/datum/beam/kinesis_beam
	/// The cooldown between us hitting objects with kinesis.
	COOLDOWN_DECLARE(hit_cooldown)

/obj/item/mod/module/anomaly_locked/kinesis/get_ru_names()
	return list(
		NOMINATIVE = "модуль \"Кинезис\"",
		GENITIVE = "модуля \"Кинезис\"",
		DATIVE = "модулю \"Кинезис\"",
		ACCUSATIVE = "модуль \"Кинезис\"",
		INSTRUMENTAL = "модулем \"Кинезис\"",
		PREPOSITIONAL = "модуле \"Кинезис\"",
	)

/obj/item/mod/module/anomaly_locked/kinesis/Initialize(mapload)
	. = ..()
	soundloop = new(src)
	kinesis_icon = image(icon = 'icons/effects/effects.dmi', icon_state = "kinesis", layer = EFFECTS_LAYER)

/obj/item/mod/module/anomaly_locked/kinesis/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(kinesis_beam)
	QDEL_NULL(kinesis_catcher)
	QDEL_NULL(kinesis_icon)
	grabbed_atom = null
	return ..()

/*
range 2-3
*/

/obj/item/mod/module/anomaly_locked/kinesis/update_core_powers()
	if(!core)
		grab_range = 0
		stat_required = DEAD
		incapacitated_required = TRUE
		return

	var/calculated_range = round((core.get_strength() / 20))
	grab_range = min(calculated_range, maximum_grab_range)

/obj/item/mod/module/anomaly_locked/kinesis/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.client)
		return
	if(grabbed_atom)
		launch()
		clear_grab(playsound = FALSE)
		return
	if(!range_check(target))
		balloon_alert(mod.wearer, "цель слишком далеко!")
		return
	if(!can_grab(target))
		balloon_alert(mod.wearer, "нельзя схватить!")
		return
	drain_power(use_energy_cost)
	grabbed_atom = target
	if(isliving(grabbed_atom))
		var/mob/living/grabbed_mob = grabbed_atom
		grabbed_mob.Stun(mob_stun_time)
	drain_power(use_energy_cost)
	grab_atom(target)

/obj/item/mod/module/anomaly_locked/kinesis/on_deactivation(display_message = TRUE, deleting = FALSE)
	clear_grab(playsound = !deleting)

/obj/item/mod/module/anomaly_locked/kinesis/process()
	if(!mod.wearer.client || mod.wearer.incapacitated(IGNORE_GRAB))
		clear_grab()
		return
	if(!range_check(grabbed_atom))
		balloon_alert(mod.wearer, "цель слишком далеко!")
		clear_grab()
		return
	drain_power(use_energy_cost)
	if(kinesis_catcher.mouse_params)
		kinesis_catcher.calculate_params()
	if(!kinesis_catcher.given_turf)
		return
	mod.wearer.setDir(get_dir(mod.wearer, grabbed_atom))
	if(grabbed_atom.loc == kinesis_catcher.given_turf)
		if(grabbed_atom.pixel_x == kinesis_catcher.given_x - ICON_SIZE_X/2 && grabbed_atom.pixel_y == kinesis_catcher.given_y - ICON_SIZE_Y/2)
			return //spare us redrawing if we are standing still
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + kinesis_catcher.given_x - ICON_SIZE_X/2, pixel_y = grabbed_atom.base_pixel_y + kinesis_catcher.given_y - ICON_SIZE_Y/2)
		kinesis_beam.redrawing()
		return
	animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + kinesis_catcher.given_x - ICON_SIZE_X/2, pixel_y = grabbed_atom.base_pixel_y + kinesis_catcher.given_y - ICON_SIZE_Y/2)
	kinesis_beam.redrawing()
	var/turf/next_turf = get_step_towards(grabbed_atom, kinesis_catcher.given_turf)
	if(grabbed_atom.Move(next_turf, get_dir(grabbed_atom, next_turf), 8))
		if(isitem(grabbed_atom) && (mod.wearer in next_turf))
			var/obj/item/grabbed_item = grabbed_atom
			clear_grab()
			grabbed_item.pickup(mod.wearer)
			mod.wearer.put_in_hands(grabbed_item)
		return
	var/pixel_x_change = 0
	var/pixel_y_change = 0
	var/direction = get_dir(grabbed_atom, next_turf)
	if(direction & NORTH)
		pixel_y_change = ICON_SIZE_Y/2
	else if(direction & SOUTH)
		pixel_y_change = -ICON_SIZE_Y/2
	if(direction & EAST)
		pixel_x_change = ICON_SIZE_X/2
	else if(direction & WEST)
		pixel_x_change = -ICON_SIZE_X/2
	animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + pixel_x_change, pixel_y = grabbed_atom.base_pixel_y + pixel_y_change)
	kinesis_beam.redrawing()
	if(!isitem(grabbed_atom) || !COOLDOWN_FINISHED(src, hit_cooldown))
		return
	var/atom/hitting_atom
	if(next_turf.density)
		hitting_atom = next_turf
	for(var/atom/movable/movable_content as anything in next_turf.contents)
		if(ismob(movable_content))
			continue
		if(movable_content.density)
			hitting_atom = movable_content
			break
	var/obj/item/grabbed_item = grabbed_atom
	grabbed_item.melee_attack_chain(mod.wearer, hitting_atom)
	COOLDOWN_START(src, hit_cooldown, hit_cooldown_time)

/obj/item/mod/module/anomaly_locked/kinesis/proc/can_grab(atom/target)
	if(mod.wearer == target)
		return FALSE
	if(!ismovable(target))
		return FALSE
	if(iseffect(target))
		return FALSE
	if(locate(mod.wearer) in target)
		return FALSE
	var/atom/movable/movable_target = target
	if(movable_target.anchored)
		return FALSE
	if(movable_target.throwing)
		return FALSE
	if(movable_target.move_resist >= MOVE_FORCE_OVERPOWERING)
		return FALSE
	if(locate(mod.wearer) in movable_target.buckled_mobs)
		return FALSE
	if(ismob(movable_target))
		if(!isliving(movable_target))
			return FALSE
		var/mob/living/living_target = movable_target
		if(living_target.stat < stat_required)
			return FALSE
		if(!living_target.incapacitated() && incapacitated_required)
			return FALSE
	else if(isitem(movable_target))
		var/obj/item/item_target = movable_target
		if(item_target.w_class >= WEIGHT_CLASS_GIGANTIC)
			return FALSE
		if(item_target.flags & ABSTRACT)
			return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/kinesis/proc/grab_atom(atom/movable/target)
	grabbed_atom = target
	if(isliving(grabbed_atom))
		grabbed_atom.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), ref(src))
		RegisterSignal(grabbed_atom, COMSIG_MOB_STATCHANGE, PROC_REF(on_statchange))
	ADD_TRAIT(grabbed_atom, TRAIT_NO_FLOATING_ANIM, ref(src))
	RegisterSignal(grabbed_atom, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_setanchored))
	playsound(grabbed_atom, 'sound/weapons/contractorbatonhit.ogg', 75, TRUE)
	kinesis_icon = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "kinesis", layer = grabbed_atom.layer - 0.1, appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM|KEEP_APART)
	grabbed_atom.add_overlay(kinesis_icon)
	kinesis_beam = mod.wearer.Beam(grabbed_atom, "kinesis")
	kinesis_catcher = mod.wearer.overlay_fullscreen("kinesis", /atom/movable/screen/fullscreen/cursor_catcher/kinesis, 0)
	kinesis_catcher.assign_to_mob(mod.wearer)
	soundloop.start()
	START_PROCESSING(SSfastprocess, src)


/obj/item/mod/module/anomaly_locked/kinesis/proc/clear_grab(playsound = TRUE)
	if(!grabbed_atom)
		return
	if(playsound)
		playsound(grabbed_atom, 'sound/effects/empulse.ogg', 75, TRUE)
	STOP_PROCESSING(SSfastprocess, src)
	UnregisterSignal(grabbed_atom, list(COMSIG_MOB_STATCHANGE, COMSIG_MOVABLE_SET_ANCHORED))
	kinesis_catcher = null
	mod.wearer.clear_fullscreen("kinesis")
	grabbed_atom.cut_overlay(kinesis_icon)
	QDEL_NULL(kinesis_beam)
	if(isliving(grabbed_atom))
		grabbed_atom.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), ref(src))
	if(!isitem(grabbed_atom))
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = pre_pixel_x, pixel_y = pre_pixel_y)
	grabbed_atom = null
	soundloop.stop()

/obj/item/mod/module/anomaly_locked/kinesis/proc/range_check(atom/target)
	if(!isturf(mod.wearer.loc))
		return FALSE
	if(ismovable(target) && !isturf(target.loc))
		return FALSE
	if(!can_see(target, grab_range))
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/kinesis/proc/on_statchange(mob/grabbed_mob, new_stat)
	SIGNAL_HANDLER

	if(new_stat < stat_required)
		clear_grab()

/obj/item/mod/module/anomaly_locked/kinesis/proc/on_setanchored(atom/movable/grabbed_atom, anchorvalue)
	SIGNAL_HANDLER

	if(grabbed_atom.anchored)
		clear_grab()

/obj/item/mod/module/anomaly_locked/kinesis/proc/launch()
	playsound(grabbed_atom, 'sound/magic/repulse.ogg', 100, TRUE)
	RegisterSignal(grabbed_atom, COMSIG_MOVABLE_IMPACT, PROC_REF(launch_impact))
	var/turf/target_turf = get_turf_in_angle(get_angle(mod.wearer, grabbed_atom), get_turf(src), 10)
	grabbed_atom.throw_at(target_turf, range = grab_range, speed = grabbed_atom.density ? 3 : 4, thrower = mod.wearer, spin = isitem(grabbed_atom))

/obj/item/mod/module/anomaly_locked/kinesis/proc/launch_impact(atom/movable/source, atom/hit_atom, datum/thrownthing/thrownthing)
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!isobj(source))
		return
	var/obj/our_source = source
	var/damage_self = TRUE
	var/damage = 8
	if(our_source.density)
		damage_self = FALSE
		damage = 15
	if(isliving(hit_atom))
		var/mob/living/living_atom = hit_atom
		living_atom.apply_damage(damage, BRUTE)
	else if(isobj(hit_atom))
		var/obj/O = hit_atom
		O.take_damage(damage, BRUTE, MELEE)
	if(damage_self)
		our_source.take_damage(our_source.max_integrity / 5, BRUTE, MELEE)

/obj/effect/abstract/kinesis
	var/datum/beam/chain

/obj/effect/abstract/kinesis/Destroy()
	qdel(chain)
	return ..()

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype
	name = "MOD prototype kinesis module"
	complexity = 0

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype/get_ru_names()
	return list(
		NOMINATIVE = "прототип модуля \"Кинезис\"",
		GENITIVE = "прототипа модуля \"Кинезис\"",
		DATIVE = "прототипу модуля \"Кинезис\"",
		ACCUSATIVE = "прототип модуля \"Кинезис\"",
		INSTRUMENTAL = "прототипом модуля \"Кинезис\"",
		PREPOSITIONAL = "прототипе модуля \"Кинезис\"",
	)

/atom/movable/screen/fullscreen/cursor_catcher/kinesis
	icon = 'icons/mob/screen_kinesis.dmi'
	icon_state = "kinesis"

//admin-only
/obj/item/mod/module/anomaly_locked/kinesis/plus
	name = "MOD kinesis+ module"
	desc = "Модуль для МЭК, подключаемый к предплечью костюма. Генерирует локальное поле анти-гравитации, \
			что позволяет пользователю с лёгкостью перемещать объекты в пространстве, будь то небольшой титановый стержень \
			или тяжёлая промышленная техника. Помимо этого, отличается от стандартной модели возможностью \
			воздействовать на живых существ благодаря модификации гравитационного механизма."
	complexity = 0
	prebuilt = TRUE
	removable = FALSE
	stat_required = CONSCIOUS //Still conscious here so we don't forget about it if the above is changed
	incapacitated_required = FALSE
	mob_stun_time = 10 SECONDS

/obj/item/mod/module/anomaly_locked/kinesis/plus/get_ru_names()
	return list(
		NOMINATIVE = "модуль \"Кинезис+\"",
		GENITIVE = "модуля \"Кинезис+\"",
		DATIVE = "модулю \"Кинезис+\"",
		ACCUSATIVE = "модуль \"Кинезис+\"",
		INSTRUMENTAL = "модулем \"Кинезис+\"",
		PREPOSITIONAL = "модуле \"Кинезис+\"",
	)
