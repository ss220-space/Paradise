
GLOBAL_LIST_INIT(bluespace_rift_sounds, list(
	'sound/magic/blink.ogg',
	'sound/effects/phasein.ogg',
	'sound/magic/wand_teleport.ogg',
))

GLOBAL_LIST_INIT(bluespace_collapse_sounds, list(
	'sound/magic/voidblink.ogg',
	'sound/effects/bamf.ogg',
	'sound/magic/teleport_diss.ogg',
))


/obj/effect/temp_visual/bluespace_collapse
	name = "spatial collapse"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "bluespace_collapse"
	duration = 0.6 SECONDS


/obj/effect/temp_visual/bluespace_marker
	name = "spatial marker"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "bluespace_mark"
	duration = 0.8 SECONDS


/obj/effect/temp_visual/bluespace_marker/selection
	duration = 5 SECONDS


/obj/effect/temp_visual/bluespace_banish
	name = "collapsing rift"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "bluespace_banish"
	duration = 3 SECONDS


/obj/effect/temp_visual/bluespace_echo
	name = "bluespace echo"
	duration = 1.5 SECONDS
	randomdir = FALSE
	alpha = 110


/obj/effect/bluespace_anchor
	name = "spatial anchor"
	desc = "Точка, в которой этот объект всё ещё обязан находиться."
	gender = MALE
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "bluespace_anchor"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = BELOW_MOB_LAYER


/obj/effect/bluespace_anchor/get_ru_names()
	return alist(
		NOMINATIVE = "пространственный якорь",
		GENITIVE = "пространственного якоря",
		DATIVE = "пространственному якорю",
		ACCUSATIVE = "пространственный якорь",
		INSTRUMENTAL = "пространственным якорем",
		PREPOSITIONAL = "пространственном якоре",
	)


/obj/effect/forcefield/distortion_field
	name = "поле искажения"
	desc = "Участок пространства, растянувшийся куда сильнее, чем выглядит."
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "bluespace_distortion"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_CLEANABLES_LAYER
	lifetime = 8 SECONDS
	var/datum/weakref/caster_ref


/obj/effect/forcefield/distortion_field/get_ru_names()
	return alist(
		NOMINATIVE = "поле искажения",
		GENITIVE = "поля искажения",
		DATIVE = "полю искажения",
		ACCUSATIVE = "поле искажения",
		INSTRUMENTAL = "полем искажения",
		PREPOSITIONAL = "поле искажения",
	)


/obj/effect/forcefield/distortion_field/Initialize(mapload, mob/living/caster)
	. = ..()
	if(caster)
		caster_ref = WEAKREF(caster)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_loc_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	for(var/atom/movable/thing in get_turf(src))
		on_entered(src, thing)


/obj/effect/forcefield/distortion_field/Destroy()
	for(var/atom/movable/thing in get_turf(src))
		on_loc_exited(src, thing)
	caster_ref = null
	return ..()


/obj/effect/forcefield/distortion_field/proc/is_affected(atom/movable/thing)
	if(isprojectile(thing))
		return TRUE
	if(!isliving(thing))
		return FALSE
	var/mob/living/living_thing = thing
	if(IS_HERETIC_OR_MONSTER(living_thing) || (FACTION_HERETIC in living_thing.faction))
		return FALSE
	return TRUE


/obj/effect/forcefield/distortion_field/proc/on_entered(datum/source, atom/movable/thing)
	SIGNAL_HANDLER

	if(!is_affected(thing))
		return

	if(isprojectile(thing))
		var/obj/projectile/bullet = thing
		bullet.speed *= 3
		return

	var/mob/living/victim = thing
	victim.add_movespeed_modifier(/datum/movespeed_modifier/distortion_field)
	victim.apply_status_effect(/datum/status_effect/spatial_drag)
	if(!TIMER_COOLDOWN_FINISHED(victim, COOLDOWN_BLUESPACE_DISTORTION))
		return
	TIMER_COOLDOWN_START(victim, COOLDOWN_BLUESPACE_DISTORTION, lifetime)
	give_spatial_instability(victim, caster_ref?.resolve())


/obj/effect/forcefield/distortion_field/proc/on_loc_exited(datum/source, atom/movable/thing)
	SIGNAL_HANDLER

	if(!is_affected(thing))
		return

	if(isprojectile(thing))
		var/obj/projectile/bullet = thing
		bullet.speed /= 3
		return

	var/mob/living/victim = thing
	victim.remove_movespeed_modifier(/datum/movespeed_modifier/distortion_field)
	var/obj/effect/forcefield/distortion_field/remaining = locate() in get_turf(victim)
	if(remaining && remaining != src)
		return
	victim.remove_status_effect(/datum/status_effect/spatial_drag)


/obj/effect/bluespace_double
	name = "echo"
	desc = "Отражение, которое изнанка так и не отпустила."
	gender = MALE
	var/mob/living/original
	var/echo_delay = 0.2 SECONDS
	var/popped = FALSE


/obj/effect/bluespace_double/get_ru_names()
	return alist(
		NOMINATIVE = "блюспейс-двойник",
		GENITIVE = "блюспейс-двойника",
		DATIVE = "блюспейс-двойнику",
		ACCUSATIVE = "блюспейс-двойника",
		INSTRUMENTAL = "блюспейс-двойником",
		PREPOSITIONAL = "блюспейс-двойнике",
	)


/obj/effect/bluespace_double/Initialize(mapload, mob/living/original, echo_delay, lifetime = 12 SECONDS)
	. = ..()
	if(!isliving(original))
		return INITIALIZE_HINT_QDEL

	src.original = original
	src.echo_delay = echo_delay
	appearance = original.appearance
	name = original.name
	RegisterSignal(original, COMSIG_MOVABLE_MOVED, PROC_REF(on_original_moved))
	RegisterSignal(original, COMSIG_QDELETING, PROC_REF(on_original_deleted))
	QDEL_IN(src, lifetime)


/obj/effect/bluespace_double/Destroy()
	if(original)
		UnregisterSignal(original, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
		original = null
	return ..()


/obj/effect/bluespace_double/proc/on_original_deleted(datum/source)
	SIGNAL_HANDLER
	original = null
	qdel(src)


/obj/effect/bluespace_double/proc/on_original_moved(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(!isturf(old_loc))
		return
	setDir(source.dir)
	addtimer(CALLBACK(src, PROC_REF(catch_up), old_loc), echo_delay)


/obj/effect/bluespace_double/proc/catch_up(turf/destination)
	if(QDELETED(src) || !destination)
		return
	forceMove(destination)


/obj/effect/bluespace_double/attack_hand(mob/user)
	dispel(user)
	return TRUE


/obj/effect/bluespace_double/attackby(obj/item/weapon, mob/user, params)
	dispel(user)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/effect/bluespace_double/bullet_act(obj/projectile/hitting, def_zone)
	. = ..()
	dispel(hitting.firer)


/obj/effect/bluespace_double/proc/dispel(mob/attacker)
	if(popped)
		return
	popped = TRUE

	new /obj/effect/temp_visual/bluespace_collapse(get_turf(src))
	playsound(src, pick(GLOB.bluespace_rift_sounds), 40, TRUE)

	if(isliving(attacker) && !IS_HERETIC_OR_MONSTER(attacker))
		var/mob/living/living_attacker = attacker
		living_attacker.adjustStaminaLoss(15)
		living_attacker.balloon_alert(living_attacker, "это был не он!")
		give_spatial_instability(living_attacker, original)

	for(var/obj/effect/bluespace_double/sibling in range(7, src))
		if(sibling == src || sibling.original != original)
			continue
		sibling.distort()

	qdel(src)


/obj/effect/bluespace_double/proc/distort()
	animate(src, alpha = 120, pixel_x = rand(-4, 4), time = 1)
	animate(alpha = initial(alpha), pixel_x = 0, time = 3 SECONDS)


/datum/movespeed_modifier/distortion_field
	multiplicative_slowdown = 0.25


/datum/actionspeed_modifier/distortion_field
	multiplicative_slowdown = 0.5


/datum/component/displaced_item
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/block_pickup = FALSE
	var/deletion_timer
	var/mob/living/holder


/datum/component/displaced_item/Initialize(duration = 4 SECONDS, block_pickup = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.block_pickup = block_pickup
	var/obj/item/displaced = parent
	displaced.alpha = 90
	displaced.add_atom_colour(COLOR_CYAN, TEMPORARY_COLOUR_PRIORITY)
	playsound(displaced, 'sound/magic/wand_teleport.ogg', 40, TRUE)
	deletion_timer = QDEL_IN_STOPPABLE(src, duration)


/datum/component/displaced_item/InheritComponent(datum/component/displaced_item/new_comp, i_am_original, duration = 4 SECONDS, block_pickup = FALSE)
	src.block_pickup ||= block_pickup
	deltimer(deletion_timer)
	deletion_timer = QDEL_IN_STOPPABLE(src, duration)


/datum/component/displaced_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	var/obj/item/displaced = parent
	if(isliving(displaced.loc))
		hook_holder(displaced.loc)


/datum/component/displaced_item/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PICKUP,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_ATTACK_HAND,
	))
	unhook_holder()


/datum/component/displaced_item/Destroy(force)
	deltimer(deletion_timer)
	var/obj/item/displaced = parent
	displaced.alpha = initial(displaced.alpha)
	displaced.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_CYAN)
	return ..()


/datum/component/displaced_item/proc/hook_holder(mob/living/new_holder)
	unhook_holder()
	holder = new_holder
	RegisterSignal(holder, COMSIG_MOB_CLICKON, PROC_REF(on_holder_click))
	RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(on_holder_deleted))


/datum/component/displaced_item/proc/unhook_holder()
	if(!holder)
		return
	UnregisterSignal(holder, list(COMSIG_MOB_CLICKON, COMSIG_QDELETING))
	holder = null


/datum/component/displaced_item/proc/on_pickup(datum/source, mob/taker)
	SIGNAL_HANDLER
	if(isliving(taker))
		hook_holder(taker)


/datum/component/displaced_item/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	unhook_holder()


/datum/component/displaced_item/proc/on_holder_deleted(datum/source)
	SIGNAL_HANDLER
	holder = null


/datum/component/displaced_item/proc/on_holder_click(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(source.get_active_hand() != parent)
		return
	source.balloon_alert(source, "проходит насквозь!")
	return COMSIG_MOB_CANCEL_CLICKON


/datum/component/displaced_item/proc/on_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!block_pickup)
		return
	user.balloon_alert(user, "вне фазы!")
	return COMPONENT_CANCEL_ATTACK_CHAIN


/proc/create_distortion_field(turf/epicentre, mob/living/caster)
	for(var/turf/covered in range(2, epicentre))
		if(covered.density)
			continue
		if(locate(/obj/effect/forcefield/distortion_field) in covered)
			continue
		new /obj/effect/forcefield/distortion_field(covered, caster)
