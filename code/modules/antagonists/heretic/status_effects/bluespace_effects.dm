
/**
 * Hands the target one Rift, collapsing them once they hold [BLUESPACE_MAX_INSTABILITY].
 *
 * * target: who gets the rift. Heretics and their servants are immune.
 * * source: the heretic responsible, used to decide whether the collapse carries the blade upgrade.
 */
/proc/give_spatial_instability(mob/living/target, mob/living/source)
	if(!isliving(target) || target.stat == DEAD)
		return FALSE
	if(IS_HERETIC_OR_MONSTER(target))
		return FALSE

	var/datum/status_effect/spatial_instability/rifts = target.has_status_effect(/datum/status_effect/spatial_instability)
	if(!rifts)
		return target.apply_status_effect(/datum/status_effect/spatial_instability, source)

	rifts.add_rift(source)
	return TRUE


/datum/status_effect/spatial_instability
	id = "spatial_instability"
	duration = 20 SECONDS
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/spatial_instability
	show_duration = TRUE
	on_remove_on_mob_delete = TRUE
	var/rifts = 1
	var/datum/weakref/culprit_ref
	var/datum/weakref/viewer_ref
	var/image/counter


/datum/status_effect/spatial_instability/on_creation(mob/living/new_owner, mob/living/culprit)
	if(culprit)
		culprit_ref = WEAKREF(culprit)
	return ..()


/datum/status_effect/spatial_instability/on_apply()
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


/datum/status_effect/spatial_instability/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED)
	hide_counter()
	counter = null
	return ..()


/datum/status_effect/spatial_instability/Destroy()
	hide_counter()
	counter = null
	culprit_ref = null
	return ..()


/datum/status_effect/spatial_instability/proc/hide_counter()
	var/mob/viewer = viewer_ref?.resolve()
	if(viewer)
		UnregisterSignal(viewer, COMSIG_MOB_LOGIN)
		viewer.client?.images -= counter
	viewer_ref = null


/datum/status_effect/spatial_instability/proc/update_counter_viewer()
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


/datum/status_effect/spatial_instability/proc/on_viewer_login(mob/source)
	SIGNAL_HANDLER
	source.client?.images |= counter


/datum/status_effect/spatial_instability/proc/on_z_changed(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(same_z_layer)
		return
	SET_PLANE_EXPLICIT(counter, ABOVE_LIGHTING_PLANE, new_turf)


/datum/status_effect/spatial_instability/proc/add_rift(mob/living/culprit)
	if(culprit)
		culprit_ref = WEAKREF(culprit)

	rifts++
	duration = world.time + initial(duration)
	if(rifts < BLUESPACE_MAX_INSTABILITY)
		announce_count()
		update_shown_duration()
		return

	collapse()


/datum/status_effect/spatial_instability/proc/announce_count()
	linked_alert?.icon_state = "instability[min(rifts, BLUESPACE_MAX_INSTABILITY)]"
	if(counter)
		counter.maptext = MAPTEXT_TINY_UNICODE("<div align='center'><font color='#4ce6e6'>РАЗЛОМ [rifts]/[BLUESPACE_MAX_INSTABILITY]</font></div>")
	update_counter_viewer()
	var/mob/living/culprit = culprit_ref?.resolve()
	if(culprit)
		UNLINT(owner.balloon_alert(culprit, "разлом [rifts]/[BLUESPACE_MAX_INSTABILITY]"))
	playsound(owner, pick(GLOB.bluespace_rift_sounds), 40, TRUE)


/datum/status_effect/spatial_instability/proc/collapse()
	var/mob/living/collapsed = owner
	if(collapsed.has_status_effect(/datum/status_effect/collapse_immunity))
		rifts = BLUESPACE_MAX_INSTABILITY - 1
		announce_count()
		return

	var/mob/living/culprit = culprit_ref?.resolve()
	new /obj/effect/temp_visual/bluespace_collapse(get_turf(collapsed))
	playsound(collapsed, pick(GLOB.bluespace_collapse_sounds), 70, TRUE)
	to_chat(collapsed, span_userdanger("Пространство перестаёт вас удерживать!"))
	collapsed.visible_message(span_danger("[collapsed.declent_ru(NOMINATIVE)] застывает, растягивается и схлопывается обратно!"))

	collapsed.Paralyse(2 SECONDS)
	collapsed.AdjustSilence(4 SECONDS)
	collapsed.adjustStaminaLoss(25)
	collapsed.apply_status_effect(/datum/status_effect/collapse_immunity)

	if(displacing_blade_collapse(culprit))
		collapsed.apply_damage(10, BRUTE)
		var/obj/item/dropped = collapsed.get_active_hand()
		if(dropped && collapsed.drop_item_ground(dropped))
			dropped.AddComponent(/datum/component/displaced_item, 3 SECONDS, block_pickup = TRUE)
		to_chat(collapsed, span_userdanger("Всё, что вы держали, осталось где-то по ту сторону."))

	qdel(src)


/datum/status_effect/spatial_instability/proc/displacing_blade_collapse(mob/living/culprit)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(culprit)
	return !isnull(heretic_datum?.get_knowledge(/datum/heretic_knowledge/blade_upgrade/bluespace))


/atom/movable/screen/alert/status_effect/spatial_instability
	name = "Разлом"
	desc = "Пространство больше не уверено, где именно вы находитесь. Накопите два разлома — и оно сдастся."
	icon = 'icons/mob/screen_alert_heretic.dmi'
	icon_state = "instability1"


/datum/status_effect/collapse_immunity
	id = "collapse_immunity"
	duration = 8 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = null


/datum/status_effect/spatial_drag
	id = "spatial_drag"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 2 SECONDS
	alert_type = null


/datum/status_effect/spatial_drag/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/distortion_field)


/datum/status_effect/spatial_drag/on_remove()
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/distortion_field)
	return ..()


/datum/status_effect/spatial_drag/tick()
	owner.Immobilize(0.5 SECONDS)
	owner.balloon_alert(owner, "пространство тянется")


/datum/status_effect/eldritch/bluespace
	effect_icon_state = "bluespace_mark"
	var/datum/weakref/inspector_ref
	var/image/marked_outline


/datum/status_effect/eldritch/bluespace/on_creation(mob/living/new_owner, mob/living/inspector)
	if(inspector)
		inspector_ref = WEAKREF(inspector)
	return ..()


/datum/status_effect/eldritch/bluespace/on_apply()
	. = ..()
	if(!.)
		return

	var/mob/living/inspector = inspector_ref?.resolve()
	if(!inspector)
		return

	marked_outline = image('icons/effects/eldritch.dmi', owner, "bluespace_mark", ABOVE_LIGHTING_PLANE)
	marked_outline.appearance_flags |= RESET_ALPHA
	SET_PLANE_EXPLICIT(marked_outline, ABOVE_LIGHTING_PLANE, owner)
	RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(replane_outline))
	RegisterSignal(inspector, COMSIG_MOB_LOGIN, PROC_REF(show_outline), override = TRUE)
	show_outline(inspector)
	to_chat(inspector, span_hierophant("[DECLENT_RU_CAP(owner, NOMINATIVE)] выделен[GEND_A_O_Y(owner)]: \
		<b>[round(owner.health)]/[round(owner.maxHealth)]</b> здоровья."))


/datum/status_effect/eldritch/bluespace/proc/show_outline(mob/show_to)
	SIGNAL_HANDLER
	show_to.client?.images |= marked_outline


/datum/status_effect/eldritch/bluespace/proc/replane_outline(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(same_z_layer)
		return
	SET_PLANE_EXPLICIT(marked_outline, ABOVE_LIGHTING_PLANE, new_turf)


/datum/status_effect/eldritch/bluespace/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED)
	var/mob/living/inspector = inspector_ref?.resolve()
	if(inspector)
		UnregisterSignal(inspector, COMSIG_MOB_LOGIN)
		inspector.client?.images -= marked_outline
	return ..()


/datum/status_effect/eldritch/bluespace/Destroy()
	marked_outline = null
	inspector_ref = null
	return ..()


/datum/status_effect/eldritch/bluespace/on_effect()
	var/mob/living/inspector = inspector_ref?.resolve()
	owner.apply_status_effect(/datum/status_effect/tether, inspector)
	give_spatial_instability(owner, inspector)
	return ..()


/datum/status_effect/tether
	id = "tether"
	duration = 4 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/tether
	show_duration = TRUE
	var/obj/effect/bluespace_anchor/anchor
	var/datum/weakref/caster_ref


/datum/status_effect/tether/on_creation(mob/living/new_owner, mob/living/caster)
	if(caster)
		caster_ref = WEAKREF(caster)
	return ..()


/datum/status_effect/tether/on_apply()
	if(owner.has_status_effect(/datum/status_effect/tether_immunity))
		return FALSE

	anchor = new(get_turf(owner))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_MOVABLE_TELEPORTING, PROC_REF(on_teleport))
	to_chat(owner, span_userdanger("Ваше место в пространстве больше вам не принадлежит!"))
	return TRUE


/datum/status_effect/tether/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_TELEPORTING))
	QDEL_NULL(anchor)
	owner.apply_status_effect(/datum/status_effect/tether_immunity)
	return ..()


/datum/status_effect/tether/Destroy()
	caster_ref = null
	return ..()


/datum/status_effect/tether/proc/on_move(mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(QDELETED(anchor) || get_dist(source, anchor) <= 1)
		return

	source.forceMove(get_turf(anchor))
	new /obj/effect/temp_visual/bluespace_marker(get_turf(anchor))
	playsound(source, 'sound/magic/blink.ogg', 30, TRUE)
	to_chat(source, span_warning("Вас утягивает обратно к якорю!"))


/datum/status_effect/tether/proc/on_teleport(mob/living/source, turf/origin, turf/destination)
	SIGNAL_HANDLER

	give_spatial_instability(source, caster_ref?.resolve())
	to_chat(source, span_warning("Привязка рвётся, оставляя за собой разлом."))
	qdel(src)


/atom/movable/screen/alert/status_effect/tether
	name = "Привязка"
	desc = "Пространство упрямо возвращает вас туда, где вы, по его мнению, стоите."
	icon = 'icons/mob/screen_alert_heretic.dmi'
	icon_state = "tether"


/datum/status_effect/tether_immunity
	id = "tether_immunity"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = null


/datum/status_effect/displacement
	id = "displacement"
	duration = 8 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/displacement
	show_duration = TRUE
	var/datum/weakref/caster_ref


/datum/status_effect/displacement/on_creation(mob/living/new_owner, mob/living/caster)
	if(caster)
		caster_ref = WEAKREF(caster)
	return ..()


/datum/status_effect/displacement/on_apply()
	RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(on_clickon))
	to_chat(owner, span_userdanger("Вас вырывает из пространства. Ваше следующее действие до него не дойдёт."))
	playsound(owner, 'sound/effects/phasein.ogg', 50, TRUE)
	return TRUE


/datum/status_effect/displacement/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_CLICKON)
	return ..()


/datum/status_effect/displacement/Destroy()
	caster_ref = null
	return ..()


/datum/status_effect/displacement/proc/on_clickon(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER

	UNLINT(source.balloon_alert_to_viewers("действие ушло в изнанку"))
	playsound(source, pick(GLOB.bluespace_rift_sounds), 50, TRUE)
	to_chat(source, span_userdanger("Ваше движение случилось где-то не здесь."))
	give_spatial_instability(source, caster_ref?.resolve())
	qdel(src)
	return COMSIG_MOB_CANCEL_CLICKON


/atom/movable/screen/alert/status_effect/displacement
	name = "Смещение"
	desc = "Вы вырваны из пространства. Следующее ваше осознанное действие до мира не дойдёт."
	icon = 'icons/mob/screen_alert_heretic.dmi'
	icon_state = "displacement"


/datum/status_effect/unravelled
	id = "unravelled"
	duration = 6 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = -1
	alert_type = null
	var/datum/weakref/unraveller_ref


/datum/status_effect/unravelled/on_creation(mob/living/new_owner, mob/living/unraveller)
	if(unraveller)
		unraveller_ref = WEAKREF(unraveller)
	return ..()


/datum/status_effect/unravelled/Destroy()
	unraveller_ref = null
	return ..()


/datum/status_effect/unravelled/be_replaced()
	qdel(src)


/datum/status_effect/unravelled/anchor
	id = "unravelled_anchor"


/datum/status_effect/unravelled/anchor/on_apply()
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert_to_viewers("прикован к месту")
	playsound(owner, 'sound/magic/wand_teleport.ogg', 50, TRUE)
	to_chat(owner, span_userdanger("Пространство прибивает вас к одной точке!"))
	give_spatial_instability(owner, unraveller_ref?.resolve())
	return TRUE


/datum/status_effect/unravelled/anchor/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	return ..()


/datum/status_effect/unravelled/phase
	id = "unravelled_phase"
	duration = 4 SECONDS


/datum/status_effect/unravelled/phase/on_apply()
	owner.density = FALSE
	owner.pass_flags |= PASSEVERYTHING
	owner.incorporeal_move = INCORPOREAL_NORMAL
	owner.alpha = 90
	ADD_TRAIT(owner, TRAIT_GODMODE, TRAIT_STATUS_EFFECT(id))
	owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_PACIFISM), TRAIT_STATUS_EFFECT(id))
	owner.balloon_alert_to_viewers("выведен из фазы")
	playsound(owner, 'sound/magic/ethereal_enter.ogg', 60, TRUE)
	to_chat(owner, span_userdanger("Мир перестаёт вас касаться."))
	return TRUE


/datum/status_effect/unravelled/phase/on_remove()
	owner.density = initial(owner.density)
	owner.pass_flags &= ~PASSEVERYTHING
	owner.incorporeal_move = INCORPOREAL_NONE
	owner.alpha = initial(owner.alpha)
	eject_from_walls()
	REMOVE_TRAIT(owner, TRAIT_GODMODE, TRAIT_STATUS_EFFECT(id))
	owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_PACIFISM), TRAIT_STATUS_EFFECT(id))
	give_spatial_instability(owner, unraveller_ref?.resolve())
	return ..()


/datum/status_effect/unravelled/phase/proc/eject_from_walls()
	var/turf/current = get_turf(owner)
	if(!current?.density)
		return

	for(var/turf/nearby in orange(1, current))
		if(nearby.density)
			continue
		owner.forceMove(nearby)
		to_chat(owner, span_warning("Вас выталкивает наружу — мир снова знает, где вы."))
		return


/datum/status_effect/unravelled/refract
	id = "unravelled_refract"
	var/image/marked_outline


/datum/status_effect/unravelled/refract/on_apply()
	owner.alpha = 0
	owner.EyeBlind(duration)
	owner.balloon_alert_to_viewers("свет обходит стороной")
	playsound(owner, 'sound/magic/blink.ogg', 50, TRUE)
	to_chat(owner, span_userdanger("Свет огибает вас — и вы перестаёте видеть."))

	var/mob/living/unraveller = unraveller_ref?.resolve()
	if(unraveller)
		marked_outline = image('icons/effects/eldritch.dmi', owner, "bluespace_mark", ABOVE_LIGHTING_PLANE)
		marked_outline.appearance_flags |= RESET_ALPHA
		SET_PLANE_EXPLICIT(marked_outline, ABOVE_LIGHTING_PLANE, owner)
		RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(replane_outline))
		unraveller.client?.images |= marked_outline
	return TRUE


/datum/status_effect/unravelled/refract/proc/replane_outline(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(same_z_layer)
		return
	SET_PLANE_EXPLICIT(marked_outline, ABOVE_LIGHTING_PLANE, new_turf)


/datum/status_effect/unravelled/refract/on_remove()
	owner.alpha = initial(owner.alpha)
	UnregisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED)
	var/mob/living/unraveller = unraveller_ref?.resolve()
	unraveller?.client?.images -= marked_outline
	marked_outline = null
	give_spatial_instability(owner, unraveller)
	return ..()


/datum/status_effect/unmoored_name
	id = "unmoored_name"
	tick_interval = 4 SECONDS
	alert_type = null


/datum/status_effect/unmoored_name/on_apply()
	return ishuman(owner)


/datum/status_effect/unmoored_name/on_remove()
	set_displayed_name(null)
	return ..()


/datum/status_effect/unmoored_name/tick()
	set_displayed_name(prob(35) ? generate_heretic_text(6) : null)


/datum/status_effect/unmoored_name/proc/set_displayed_name(new_name)
	var/mob/living/carbon/human/unmoored = owner
	if(unmoored.name_override == new_name)
		return
	unmoored.name_override = new_name
	unmoored.sec_hud_set_ID()


/datum/status_effect/bluespace_stasis
	id = "bluespace_stasis"
	duration = 4 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = null


/datum/status_effect/bluespace_stasis/on_apply()
	owner.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_MUTE), TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_GODMODE, TRAIT_STATUS_EFFECT(id))
	owner.add_atom_colour(COLOR_CYAN, TEMPORARY_COLOUR_PRIORITY)
	UNLINT(owner.balloon_alert_to_viewers("застыл вне времени"))
	playsound(owner, 'sound/magic/timeparadox2.ogg', 40, TRUE)
	return TRUE


/datum/status_effect/bluespace_stasis/on_remove()
	owner.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_MUTE), TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_GODMODE, TRAIT_STATUS_EFFECT(id))
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_CYAN)
	return ..()
