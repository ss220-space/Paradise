
GLOBAL_LIST_INIT(beyond_error_sounds, list(
	'sound/machines/terminal_error.ogg',
	'sound/magic/heretic/beyond/beyond_error.ogg',
	'sound/magic/heretic/beyond/beyond_glitch.ogg',
))

GLOBAL_LIST_INIT(beyond_glitch_sounds, list(
	'sound/machines/terminal_alert.ogg',
	'sound/magic/heretic/beyond/beyond_glitch.ogg',
	'sound/magic/heretic/beyond/beyond_error.ogg',
))


/obj/effect/temp_visual/beyond_crash
	name = "runtime crash"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "beyond_crash"
	duration = 0.6 SECONDS


/obj/effect/temp_visual/beyond_select
	name = "selection bracket"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "beyond_select"
	duration = 0.8 SECONDS


/obj/effect/temp_visual/beyond_select/selection
	duration = 5 SECONDS


/obj/effect/temp_visual/beyond_qdel
	name = "missing texture"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "beyond_qdel"
	duration = 3 SECONDS


/obj/effect/temp_visual/beyond_afterimage
	name = "lagging frame"
	duration = 1.5 SECONDS
	randomdir = FALSE
	alpha = 110


/obj/effect/beyond_anchor
	name = "reference anchor"
	desc = "Позиция, в которой этот объект всё ещё обязан находиться."
	gender = FEMALE
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "beyond_rubberband"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = BELOW_MOB_LAYER


/obj/effect/beyond_anchor/get_ru_names()
	return alist(
		NOMINATIVE = "привязка ссылки",
		GENITIVE = "привязки ссылки",
		DATIVE = "привязке ссылки",
		ACCUSATIVE = "привязку ссылки",
		INSTRUMENTAL = "привязкой ссылки",
		PREPOSITIONAL = "привязке ссылки",
	)


/obj/effect/forcefield/lag_field
	name = "область задержки"
	desc = "Участок пространства, который перестал вовремя получать подтверждения."
	gender = FEMALE
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "beyond_lagfield"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_CLEANABLES_LAYER
	lifetime = 8 SECONDS
	var/datum/weakref/caster_ref


/obj/effect/forcefield/lag_field/get_ru_names()
	return alist(
		NOMINATIVE = "область задержки",
		GENITIVE = "области задержки",
		DATIVE = "области задержки",
		ACCUSATIVE = "область задержки",
		INSTRUMENTAL = "областью задержки",
		PREPOSITIONAL = "области задержки",
	)


/obj/effect/forcefield/lag_field/Initialize(mapload, mob/living/caster)
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


/obj/effect/forcefield/lag_field/Destroy()
	for(var/atom/movable/thing in get_turf(src))
		on_loc_exited(src, thing)
	caster_ref = null
	return ..()


/obj/effect/forcefield/lag_field/proc/is_affected(atom/movable/thing)
	if(isprojectile(thing))
		return TRUE
	if(!isliving(thing))
		return FALSE
	var/mob/living/living_thing = thing
	if(IS_HERETIC_OR_MONSTER(living_thing) || (FACTION_HERETIC in living_thing.faction))
		return FALSE
	return TRUE


/obj/effect/forcefield/lag_field/proc/on_entered(datum/source, atom/movable/thing)
	SIGNAL_HANDLER

	if(!is_affected(thing))
		return

	if(isprojectile(thing))
		var/obj/projectile/bullet = thing
		bullet.speed *= 3
		return

	var/mob/living/victim = thing
	victim.add_movespeed_modifier(/datum/movespeed_modifier/lag_field)
	victim.apply_status_effect(/datum/status_effect/lag_stutter)
	if(!TIMER_COOLDOWN_FINISHED(victim, COOLDOWN_BEYOND_LAG_SPIKE))
		return
	TIMER_COOLDOWN_START(victim, COOLDOWN_BEYOND_LAG_SPIKE, lifetime)
	give_runtime_error(victim, caster_ref?.resolve())


/obj/effect/forcefield/lag_field/proc/on_loc_exited(datum/source, atom/movable/thing)
	SIGNAL_HANDLER

	if(!is_affected(thing))
		return

	if(isprojectile(thing))
		var/obj/projectile/bullet = thing
		bullet.speed /= 3
		return

	var/mob/living/victim = thing
	victim.remove_movespeed_modifier(/datum/movespeed_modifier/lag_field)
	var/obj/effect/forcefield/lag_field/remaining = locate() in get_turf(victim)
	if(remaining && remaining != src)
		return
	victim.remove_status_effect(/datum/status_effect/lag_stutter)


/obj/effect/beyond_clone
	name = "frame"
	desc = "Кадр, который так и не был отброшен."
	gender = MALE
	anchored = TRUE
	density = FALSE
	var/mob/living/original
	var/frame_delay = 0.2 SECONDS
	var/popped = FALSE


/obj/effect/beyond_clone/get_ru_names()
	return alist(
		NOMINATIVE = "запоздавший кадр",
		GENITIVE = "запоздавшего кадра",
		DATIVE = "запоздавшему кадру",
		ACCUSATIVE = "запоздавший кадр",
		INSTRUMENTAL = "запоздавшим кадром",
		PREPOSITIONAL = "запоздавшем кадре",
	)


/obj/effect/beyond_clone/Initialize(mapload, mob/living/original, frame_delay, lifetime = 12 SECONDS)
	. = ..()
	if(!isliving(original))
		return INITIALIZE_HINT_QDEL

	src.original = original
	src.frame_delay = frame_delay
	appearance = original.appearance
	name = original.name
	RegisterSignal(original, COMSIG_MOVABLE_MOVED, PROC_REF(on_original_moved))
	RegisterSignal(original, COMSIG_QDELETING, PROC_REF(on_original_deleted))
	QDEL_IN(src, lifetime)


/obj/effect/beyond_clone/Destroy()
	if(original)
		UnregisterSignal(original, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
		original = null
	return ..()


/obj/effect/beyond_clone/proc/on_original_deleted(datum/source)
	SIGNAL_HANDLER
	original = null
	qdel(src)


/obj/effect/beyond_clone/proc/on_original_moved(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(!isturf(old_loc))
		return
	setDir(source.dir)
	addtimer(CALLBACK(src, PROC_REF(catch_up), old_loc), frame_delay)


/obj/effect/beyond_clone/proc/catch_up(turf/destination)
	if(QDELETED(src) || !destination)
		return
	forceMove(destination)


/obj/effect/beyond_clone/attack_hand(mob/user)
	dispel(user)
	return TRUE


/obj/effect/beyond_clone/attackby(obj/item/weapon, mob/user, params)
	dispel(user)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/effect/beyond_clone/bullet_act(obj/projectile/hitting, def_zone)
	. = ..()
	dispel(hitting.firer)


/obj/effect/beyond_clone/proc/dispel(mob/attacker)
	if(popped)
		return
	popped = TRUE

	new /obj/effect/temp_visual/beyond_crash(get_turf(src))
	playsound(src, pick(GLOB.beyond_error_sounds), 40, TRUE)

	if(isliving(attacker) && !IS_HERETIC_OR_MONSTER(attacker))
		var/mob/living/living_attacker = attacker
		living_attacker.adjustStaminaLoss(15)
		living_attacker.balloon_alert(living_attacker, "это был не он!")
		give_runtime_error(living_attacker, original)

	for(var/obj/effect/beyond_clone/sibling in range(7, src))
		if(sibling == src || sibling.original != original)
			continue
		sibling.distort()

	qdel(src)


/obj/effect/beyond_clone/proc/distort()
	animate(src, alpha = 120, pixel_x = rand(-4, 4), time = 1)
	animate(alpha = initial(alpha), pixel_x = 0, time = 3 SECONDS)


/datum/movespeed_modifier/lag_field
	multiplicative_slowdown = 0.25


/datum/actionspeed_modifier/lag_field
	multiplicative_slowdown = 0.5


/datum/component/nulled_reference
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/block_pickup = FALSE
	var/deletion_timer
	var/mob/living/holder


/datum/component/nulled_reference/Initialize(duration = 4 SECONDS, block_pickup = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.block_pickup = block_pickup
	var/obj/item/nulled = parent
	nulled.alpha = 90
	nulled.add_atom_colour(COLOR_CYAN, TEMPORARY_COLOUR_PRIORITY)
	playsound(nulled, pick('sound/magic/disable_tech.ogg', 'sound/magic/heretic/beyond/beyond_error.ogg'), 40, TRUE)
	deletion_timer = QDEL_IN_STOPPABLE(src, duration)


/datum/component/nulled_reference/InheritComponent(datum/component/nulled_reference/new_comp, i_am_original, duration = 4 SECONDS, block_pickup = FALSE)
	src.block_pickup ||= block_pickup
	deltimer(deletion_timer)
	deletion_timer = QDEL_IN_STOPPABLE(src, duration)


/datum/component/nulled_reference/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	var/obj/item/nulled = parent
	if(isliving(nulled.loc))
		hook_holder(nulled.loc)


/datum/component/nulled_reference/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PICKUP,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_ATTACK_HAND,
	))
	unhook_holder()


/datum/component/nulled_reference/Destroy(force)
	deltimer(deletion_timer)
	var/obj/item/nulled = parent
	nulled.alpha = initial(nulled.alpha)
	nulled.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_CYAN)
	return ..()


/datum/component/nulled_reference/proc/hook_holder(mob/living/new_holder)
	unhook_holder()
	holder = new_holder
	RegisterSignal(holder, COMSIG_MOB_CLICKON, PROC_REF(on_holder_click))
	RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(on_holder_deleted))


/datum/component/nulled_reference/proc/unhook_holder()
	if(!holder)
		return
	UnregisterSignal(holder, list(COMSIG_MOB_CLICKON, COMSIG_QDELETING))
	holder = null


/datum/component/nulled_reference/proc/on_pickup(datum/source, mob/taker)
	SIGNAL_HANDLER
	if(isliving(taker))
		hook_holder(taker)


/datum/component/nulled_reference/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	unhook_holder()


/datum/component/nulled_reference/proc/on_holder_deleted(datum/source)
	SIGNAL_HANDLER
	holder = null


/datum/component/nulled_reference/proc/on_holder_click(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(source.get_active_hand() != parent)
		return
	source.balloon_alert(source, "не отвечает!")
	return COMSIG_MOB_CANCEL_CLICKON


/datum/component/nulled_reference/proc/on_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!block_pickup)
		return
	user.balloon_alert(user, "ссылка утеряна!")
	return COMPONENT_CANCEL_ATTACK_CHAIN


/proc/create_lag_field(turf/epicentre, mob/living/caster)
	for(var/turf/covered in range(2, epicentre))
		if(covered.density)
			continue
		if(locate(/obj/effect/forcefield/lag_field) in covered)
			continue
		new /obj/effect/forcefield/lag_field(covered, caster)
