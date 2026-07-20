
/**
 * Hands the target one Runtime Error, crashing them once they hold [BEYOND_MAX_RUNTIME_ERRORS].
 *
 * * target: who gets the error. Heretics and their servants are immune.
 * * source: the heretic responsible, used to decide whether the crash carries the Null Reference upgrade.
 */
/proc/give_runtime_error(mob/living/target, mob/living/source)
	if(!isliving(target) || target.stat == DEAD)
		return FALSE
	if(IS_HERETIC_OR_MONSTER(target))
		return FALSE

	var/datum/status_effect/runtime_error/errors = target.has_status_effect(/datum/status_effect/runtime_error)
	if(!errors)
		return target.apply_status_effect(/datum/status_effect/runtime_error, source)

	errors.add_error(source)
	return TRUE


/datum/status_effect/runtime_error
	id = "runtime_error"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/runtime_error
	show_duration = TRUE
	on_remove_on_mob_delete = TRUE
	var/errors = 1
	var/datum/weakref/culprit_ref
	var/datum/weakref/viewer_ref
	var/image/counter


/datum/status_effect/runtime_error/on_creation(mob/living/new_owner, mob/living/culprit)
	if(culprit)
		culprit_ref = WEAKREF(culprit)
	return ..()


/datum/status_effect/runtime_error/on_apply()
	. = ..()
	if(!.)
		return
	counter = image(null, owner)
	counter.layer = ABOVE_ALL_MOB_LAYER
	counter.appearance_flags |= RESET_ALPHA
	counter.maptext_width = 96
	counter.maptext_height = 16
	counter.maptext_x = -32
	counter.maptext_y = 26
	counter.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	SET_PLANE_EXPLICIT(counter, ABOVE_LIGHTING_PLANE, owner)
	RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_changed))
	announce_count()


/datum/status_effect/runtime_error/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED)
	hide_counter()
	counter = null
	return ..()


/datum/status_effect/runtime_error/Destroy()
	hide_counter()
	counter = null
	culprit_ref = null
	return ..()


/datum/status_effect/runtime_error/proc/hide_counter()
	var/mob/viewer = viewer_ref?.resolve()
	if(viewer)
		UnregisterSignal(viewer, COMSIG_MOB_LOGIN)
		viewer.client?.images -= counter
	viewer_ref = null


/datum/status_effect/runtime_error/proc/update_counter_viewer()
	var/mob/living/culprit = culprit_ref?.resolve()
	var/mob/current_viewer = viewer_ref?.resolve()
	if(current_viewer == culprit)
		culprit?.client?.images |= counter
		return

	if(current_viewer)
		UnregisterSignal(current_viewer, COMSIG_MOB_LOGIN)
		current_viewer.client?.images -= counter
	viewer_ref = null

	if(!culprit)
		return
	viewer_ref = WEAKREF(culprit)
	RegisterSignal(culprit, COMSIG_MOB_LOGIN, PROC_REF(on_viewer_login), override = TRUE)
	culprit.client?.images |= counter


/datum/status_effect/runtime_error/proc/on_viewer_login(mob/source)
	SIGNAL_HANDLER
	source.client?.images |= counter


/datum/status_effect/runtime_error/proc/on_z_changed(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(same_z_layer)
		return
	SET_PLANE_EXPLICIT(counter, ABOVE_LIGHTING_PLANE, new_turf)


/datum/status_effect/runtime_error/proc/add_error(mob/living/culprit)
	if(culprit)
		culprit_ref = WEAKREF(culprit)

	errors++
	duration = world.time + initial(duration)
	if(errors < BEYOND_MAX_RUNTIME_ERRORS)
		announce_count()
		update_shown_duration()
		return

	crash()


/datum/status_effect/runtime_error/proc/announce_count()
	linked_alert?.icon_state = "runtime_error[min(errors, BEYOND_MAX_RUNTIME_ERRORS)]"
	if(counter)
		counter.maptext = MAPTEXT_TINY_UNICODE("<div align='center'><font color='#4ce6e6'>ERROR [errors]/[BEYOND_MAX_RUNTIME_ERRORS]</font></div>")
	update_counter_viewer()
	var/mob/living/culprit = culprit_ref?.resolve()
	if(culprit)
		UNLINT(owner.balloon_alert(culprit, "ERROR [errors]/[BEYOND_MAX_RUNTIME_ERRORS]"))
	playsound(owner, pick(GLOB.beyond_error_sounds), 40, TRUE)


/datum/status_effect/runtime_error/proc/crash()
	var/mob/living/crashed = owner
	if(crashed.has_status_effect(/datum/status_effect/crash_immunity))
		errors = BEYOND_MAX_RUNTIME_ERRORS - 1
		announce_count()
		return

	var/mob/living/culprit = culprit_ref?.resolve()
	new /obj/effect/temp_visual/beyond_crash(get_turf(crashed))
	playsound(crashed, pick(GLOB.beyond_glitch_sounds), 70, TRUE)
	to_chat(crashed, span_userdanger("Мир перестаёт вас обрабатывать!"))
	crashed.visible_message(span_danger("[crashed.declent_ru(NOMINATIVE)] застывает, дёргается и рассыпается на кадры!"))

	crashed.Paralyse(2 SECONDS)
	crashed.AdjustSilence(4 SECONDS)
	crashed.adjustStaminaLoss(25)
	crashed.apply_status_effect(/datum/status_effect/crash_immunity)

	if(null_reference_crash(culprit))
		crashed.apply_damage(10, BRUTE)
		var/obj/item/dropped = crashed.get_active_hand()
		if(dropped && crashed.drop_item_ground(dropped))
			dropped.AddComponent(/datum/component/nulled_reference, 3 SECONDS, block_pickup = TRUE)
		to_chat(crashed, span_userdanger("Cannot read property \"mind\" of null"))

	qdel(src)


/datum/status_effect/runtime_error/proc/null_reference_crash(mob/living/culprit)
	var/datum/antagonist/heretic/heretic_datum = culprit?.mind?.has_antag_datum(/datum/antagonist/heretic)
	return !isnull(heretic_datum?.get_knowledge(/datum/heretic_knowledge/blade_upgrade/beyond))


/atom/movable/screen/alert/status_effect/runtime_error
	name = "Runtime Error"
	desc = "Движок больше не уверен, что вы существуете. Накопите три ошибки — и он сдастся."
	icon = 'icons/mob/screen_alert_heretic.dmi'
	icon_state = "runtime_error1"


/datum/status_effect/crash_immunity
	id = "crash_immunity"
	duration = 12 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = null


/datum/status_effect/lag_stutter
	id = "lag_stutter"
	duration = -1
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 2 SECONDS
	alert_type = null


/datum/status_effect/lag_stutter/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/lag_field)


/datum/status_effect/lag_stutter/on_remove()
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/lag_field)
	return ..()


/datum/status_effect/lag_stutter/tick()
	owner.Immobilize(0.5 SECONDS)
	owner.balloon_alert(owner, "зависание")


/datum/status_effect/eldritch/beyond
	effect_icon_state = "beyond_select"
	var/datum/weakref/inspector_ref
	var/image/debug_outline


/datum/status_effect/eldritch/beyond/on_creation(mob/living/new_owner, mob/living/inspector)
	if(inspector)
		inspector_ref = WEAKREF(inspector)
	return ..()


/datum/status_effect/eldritch/beyond/on_apply()
	. = ..()
	if(!.)
		return

	var/mob/living/inspector = inspector_ref?.resolve()
	if(!inspector)
		return

	debug_outline = image('icons/effects/eldritch.dmi', owner, "beyond_select", ABOVE_LIGHTING_PLANE)
	debug_outline.appearance_flags |= RESET_ALPHA
	SET_PLANE_EXPLICIT(debug_outline, ABOVE_LIGHTING_PLANE, owner)
	RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(replane_outline))
	RegisterSignal(inspector, COMSIG_MOB_LOGIN, PROC_REF(show_outline), override = TRUE)
	show_outline(inspector)
	to_chat(inspector, span_hierophant("[DECLENT_RU_CAP(owner, NOMINATIVE)] выделен[GEND_A_O_Y(owner)]: \
		<b>[round(owner.health)]/[round(owner.maxHealth)]</b> здоровья."))


/datum/status_effect/eldritch/beyond/proc/show_outline(mob/show_to)
	SIGNAL_HANDLER
	show_to.client?.images |= debug_outline


/datum/status_effect/eldritch/beyond/proc/replane_outline(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(same_z_layer)
		return
	SET_PLANE_EXPLICIT(debug_outline, ABOVE_LIGHTING_PLANE, new_turf)


/datum/status_effect/eldritch/beyond/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED)
	var/mob/living/inspector = inspector_ref?.resolve()
	if(inspector)
		UnregisterSignal(inspector, COMSIG_MOB_LOGIN)
		inspector.client?.images -= debug_outline
	return ..()


/datum/status_effect/eldritch/beyond/Destroy()
	debug_outline = null
	inspector_ref = null
	return ..()


/datum/status_effect/eldritch/beyond/on_effect()
	var/mob/living/inspector = inspector_ref?.resolve()
	owner.apply_status_effect(/datum/status_effect/rubberband, inspector)
	give_runtime_error(owner, inspector)
	return ..()


/datum/status_effect/rubberband
	id = "rubberband"
	duration = 4 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/rubberband
	show_duration = TRUE
	var/obj/effect/beyond_anchor/anchor
	var/datum/weakref/caster_ref


/datum/status_effect/rubberband/on_creation(mob/living/new_owner, mob/living/caster)
	if(caster)
		caster_ref = WEAKREF(caster)
	return ..()


/datum/status_effect/rubberband/on_apply()
	if(owner.has_status_effect(/datum/status_effect/rubberband_immunity))
		return FALSE

	anchor = new(get_turf(owner))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_MOVABLE_TELEPORTING, PROC_REF(on_teleport))
	to_chat(owner, span_userdanger("Ваши координаты больше вам не принадлежат!"))
	return TRUE


/datum/status_effect/rubberband/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_TELEPORTING))
	QDEL_NULL(anchor)
	owner.apply_status_effect(/datum/status_effect/rubberband_immunity)
	return ..()


/datum/status_effect/rubberband/Destroy()
	caster_ref = null
	return ..()


/datum/status_effect/rubberband/proc/on_move(mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(QDELETED(anchor) || get_dist(source, anchor) <= 1)
		return

	source.forceMove(get_turf(anchor))
	new /obj/effect/temp_visual/beyond_select(get_turf(anchor))
	playsound(source, pick('sound/magic/blink.ogg', 'sound/magic/heretic/beyond/beyond_glitch.ogg'), 30, TRUE)
	to_chat(source, span_warning("Вас возвращает на сохранённую позицию!"))


/datum/status_effect/rubberband/proc/on_teleport(mob/living/source, turf/origin, turf/destination)
	SIGNAL_HANDLER

	give_runtime_error(source, caster_ref?.resolve())
	to_chat(source, span_warning("Привязка рвётся, оставляя за собой ошибку."))
	qdel(src)


/atom/movable/screen/alert/status_effect/rubberband
	name = "Rubberband"
	desc = "Движок настойчиво возвращает вас туда, где вы, по его мнению, стоите."
	icon = 'icons/mob/screen_alert_heretic.dmi'
	icon_state = "rubberband"


/datum/status_effect/rubberband_immunity
	id = "rubberband_immunity"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = null


/datum/status_effect/packet_loss
	id = "packet_loss"
	duration = 8 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/packet_loss
	show_duration = TRUE
	var/datum/weakref/caster_ref


/datum/status_effect/packet_loss/on_creation(mob/living/new_owner, mob/living/caster)
	if(caster)
		caster_ref = WEAKREF(caster)
	return ..()


/datum/status_effect/packet_loss/on_apply()
	RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(on_clickon))
	to_chat(owner, span_userdanger("Связь с миром рвётся. Ваше следующее действие до него не дойдёт."))
	playsound(owner, pick('sound/machines/deniedbeep.ogg', 'sound/magic/heretic/beyond/beyond_error.ogg'), 50, TRUE)
	return TRUE


/datum/status_effect/packet_loss/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_CLICKON)
	return ..()


/datum/status_effect/packet_loss/Destroy()
	caster_ref = null
	return ..()


/datum/status_effect/packet_loss/proc/on_clickon(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER

	UNLINT(source.balloon_alert_to_viewers("Packet dropped"))
	playsound(source, pick(GLOB.beyond_error_sounds), 50, TRUE)
	to_chat(source, span_userdanger("Действие потеряно по дороге."))
	give_runtime_error(source, caster_ref?.resolve())
	qdel(src)
	return COMSIG_MOB_CANCEL_CLICKON


/atom/movable/screen/alert/status_effect/packet_loss
	name = "Packet Loss"
	desc = "Соединение повреждено. Следующее ваше осознанное действие не дойдёт до сервера."
	icon = 'icons/mob/screen_alert_heretic.dmi'
	icon_state = "packet_loss"


/datum/status_effect/beyond_variable
	id = "beyond_variable"
	duration = 6 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = -1
	alert_type = null
	var/datum/weakref/editor_ref


/datum/status_effect/beyond_variable/on_creation(mob/living/new_owner, mob/living/editor)
	if(editor)
		editor_ref = WEAKREF(editor)
	return ..()


/datum/status_effect/beyond_variable/Destroy()
	editor_ref = null
	return ..()


/datum/status_effect/beyond_variable/be_replaced()
	qdel(src)


/datum/status_effect/beyond_variable/anchored
	id = "beyond_anchored"


/datum/status_effect/beyond_variable/anchored/on_apply()
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert_to_viewers("anchored = TRUE")
	playsound(owner, 'sound/magic/heretic/beyond/beyond_error.ogg', 50, TRUE)
	to_chat(owner, span_userdanger("Ваши координаты приколочены к миру!"))
	give_runtime_error(owner, editor_ref?.resolve())
	return TRUE


/datum/status_effect/beyond_variable/anchored/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	return ..()


/datum/status_effect/beyond_variable/density
	id = "beyond_density"
	duration = 4 SECONDS


/datum/status_effect/beyond_variable/density/on_apply()
	owner.density = FALSE
	owner.pass_flags |= PASSEVERYTHING
	owner.incorporeal_move = INCORPOREAL_NORMAL
	owner.alpha = 90
	ADD_TRAIT(owner, TRAIT_GODMODE, TRAIT_STATUS_EFFECT(id))
	owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_PACIFISM), TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert_to_viewers("density = FALSE")
	playsound(owner, 'sound/magic/heretic/beyond/beyond_noclip.ogg', 60, TRUE)
	to_chat(owner, span_userdanger("Мир перестаёт вас касаться."))
	return TRUE


/datum/status_effect/beyond_variable/density/on_remove()
	owner.density = initial(owner.density)
	owner.pass_flags &= ~PASSEVERYTHING
	owner.incorporeal_move = INCORPOREAL_NONE
	owner.alpha = initial(owner.alpha)
	eject_from_walls()
	REMOVE_TRAIT(owner, TRAIT_GODMODE, TRAIT_STATUS_EFFECT(id))
	owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_PACIFISM), TRAIT_STATUS_EFFECT(id))
	give_runtime_error(owner, editor_ref?.resolve())
	return ..()


/datum/status_effect/beyond_variable/density/proc/eject_from_walls()
	var/turf/current = get_turf(owner)
	if(!current?.density)
		return

	for(var/turf/nearby in orange(1, current))
		if(nearby.density)
			continue
		owner.forceMove(nearby)
		to_chat(owner, span_warning("Вас выталкивает наружу — мир снова знает, где вы."))
		return


/datum/status_effect/beyond_variable/alpha
	id = "beyond_alpha"
	var/image/debug_outline


/datum/status_effect/beyond_variable/alpha/on_apply()
	owner.alpha = 0
	owner.EyeBlind(duration)
	owner.balloon_alert_to_viewers("alpha = 0")
	playsound(owner, 'sound/magic/heretic/beyond/beyond_glitch.ogg', 50, TRUE)
	to_chat(owner, span_userdanger("Вы перестаёте отрисовываться — и перестаёте видеть."))

	var/mob/living/editor = editor_ref?.resolve()
	if(editor)
		debug_outline = image('icons/effects/eldritch.dmi', owner, "beyond_select", ABOVE_LIGHTING_PLANE)
		debug_outline.appearance_flags |= RESET_ALPHA
		SET_PLANE_EXPLICIT(debug_outline, ABOVE_LIGHTING_PLANE, owner)
		RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(replane_outline))
		editor.client?.images |= debug_outline
	return TRUE


/datum/status_effect/beyond_variable/alpha/proc/replane_outline(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(same_z_layer)
		return
	SET_PLANE_EXPLICIT(debug_outline, ABOVE_LIGHTING_PLANE, new_turf)


/datum/status_effect/beyond_variable/alpha/on_remove()
	owner.alpha = initial(owner.alpha)
	UnregisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED)
	var/mob/living/editor = editor_ref?.resolve()
	editor?.client?.images -= debug_outline
	debug_outline = null
	give_runtime_error(owner, editor)
	return ..()


/datum/status_effect/host_identity
	id = "host_identity"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 4 SECONDS
	alert_type = null
	var/static/list/host_names = list("Azizonkg", "HOST", "rv666")


/datum/status_effect/host_identity/on_apply()
	return ishuman(owner)


/datum/status_effect/host_identity/on_remove()
	set_displayed_name(null)
	return ..()


/datum/status_effect/host_identity/tick()
	set_displayed_name(prob(35) ? pick(host_names) : null)


/datum/status_effect/host_identity/proc/set_displayed_name(new_name)
	var/mob/living/carbon/human/host = owner
	if(host.name_override == new_name)
		return
	host.name_override = new_name
	host.sec_hud_set_ID()


/datum/status_effect/beyond_paused
	id = "beyond_paused"
	duration = 4 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = null


/datum/status_effect/beyond_paused/on_apply()
	owner.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_MUTE), TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_GODMODE, TRAIT_STATUS_EFFECT(id))
	owner.add_atom_colour(COLOR_CYAN, TEMPORARY_COLOUR_PRIORITY)
	UNLINT(owner.balloon_alert_to_viewers("Pause()"))
	playsound(owner, 'sound/magic/heretic/beyond/beyond_glitch.ogg', 40, TRUE)
	return TRUE


/datum/status_effect/beyond_paused/on_remove()
	owner.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_MUTE), TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_GODMODE, TRAIT_STATUS_EFFECT(id))
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_CYAN)
	return ..()
