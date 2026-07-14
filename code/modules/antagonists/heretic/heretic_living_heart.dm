/**
 * # Living Heart Component
 *
 * Applied to a heart to turn it into a heretic's 'living heart'.
 * The living heart is what they use to track people they need to sacrifice.
 *
 * This component handles the spell associated with it -
 * if the organ is removed, the spell should be deleted
 */
/datum/component/living_heart
	/// The spell we create and give to our heart.
	var/obj/effect/proc_holder/spell/track_target/spell

/datum/component/living_heart/Initialize()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/organ_parent = parent
	spell = new(src)
	organ_parent.owner.mind.AddSpell(spell)

/datum/component/living_heart/Destroy(force)
	QDEL_NULL(spell)
	return ..()

/datum/component/living_heart/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_LIVING_HEART, UID())
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))
	RegisterSignal(parent, COMSIG_ORGAN_BEING_REPLACED, PROC_REF(on_organ_replaced))

/datum/component/living_heart/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_LIVING_HEART, UID())
	UnregisterSignal(parent, list(COMSIG_ORGAN_REMOVED, COMSIG_ORGAN_BEING_REPLACED))

/datum/component/living_heart/PostTransfer(datum/new_parent)
	if(!isorgan(new_parent))
		return COMPONENT_INCOMPATIBLE

/**
 * Signal proc for [COMSIG_ORGAN_REMOVED].
 *
 * If the organ is removed, the component will remove itself.
 */
/datum/component/living_heart/proc/on_organ_removed(obj/item/organ/source, mob/living/carbon/old_owner)
	SIGNAL_HANDLER

	to_chat(old_owner, span_userdanger("[DECLENT_RU_CAP(source, NOMINATIVE)] покидает ваше тело, и вы чувствуете, как ваша связь с Обителью слабеет!"))
	qdel(src)

/**
 * Signal proc for [COMSIG_ORGAN_BEING_REPLACED].
 *
 * If the organ is replaced, before it's done transfer the component over
 */
/datum/component/living_heart/proc/on_organ_replaced(obj/item/organ/source, obj/item/organ/replacement)
	SIGNAL_HANDLER

	if(isroboticorgan(replacement))
		qdel(src)
		return

	replacement.TakeComponent(src)

/**
 * The spell associated with the living heart.
 * Allows a heretic to track sacrifice targets.
 */
/obj/effect/proc_holder/spell/track_target
	name = "Биение Живого Сердца"
	desc = "ЛКМ: Выберите одну из целей жертвоприношения для отслеживания.\nАльт-клик: Переключает автовыбор последней выбранной цели."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon = 'icons/obj/eldritch.dmi'
	action_icon_state = "living_heart"
	base_cooldown = 4 SECONDS
	clothes_req = FALSE

	/// Tracks whether we were right clicked or left clicked in our last trigger
	var/alt_clicked = FALSE
	/// The real name of the last thing we tracked
	var/last_tracked_name
	/// Whether the target radial is currently opened.
	var/radial_open = FALSE
	/// Navigator to our target that we have.
	var/datum/status_effect/agent_pinpointer/scan/heretic/heretic_pinpointer


/obj/effect/proc_holder/spell/track_target/can_add(mob/granted)
	return isheretic(granted)


/obj/effect/proc_holder/spell/track_target/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	. = ..()
	if(!.)
		return

	if(!isheretic(action.owner))
		return FALSE

	if(radial_open)
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/track_target/click_alt(mob/user)
	. = ..()
	alt_clicked = !alt_clicked


/obj/effect/proc_holder/spell/track_target/cast(list/targets, mob/user = usr)
	var/datum/antagonist/heretic/heretic_datum = action.owner.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/sac_knowledge = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)

	if(!LAZYLEN(heretic_datum.sac_targets))
		action.owner.balloon_alert(action.owner, "нет целей!")
		return

	var/list/choosable_targets = list()
	var/list/possible_tracked_atoms = list()

	var/datum/heretic_knowledge/limited_amount/starting/blade_knowledge
	for(var/datum/potential_knowledge as anything in subtypesof(/datum/heretic_knowledge/limited_amount/starting))
		blade_knowledge = heretic_datum.get_knowledge(potential_knowledge)
		if(blade_knowledge)
			break

	for(var/datum/weakref/blade_ref as anything in blade_knowledge?.created_items)
		var/obj/item/melee/sickly_blade/blade = blade_ref.resolve()
		if(QDELETED(blade))
			blade_knowledge.created_items -= blade_ref
			continue

		if(!istype(blade, /obj/item/melee/sickly_blade))
			continue // Just in case someone makes a /datum/heretic_knowledge/limited_amount/starting that doesn't create blades

		if(get(blade, /mob/living) == action.owner)
			continue

		choosable_targets[blade.name] = image(icon = blade.icon, icon_state = blade.icon_state)
		possible_tracked_atoms[blade.name] = blade

	for(var/mob/living/carbon/human/sac_target as anything in heretic_datum.sac_targets)
		choosable_targets[sac_target.real_name] = heretic_datum.sac_targets[sac_target]
		possible_tracked_atoms[sac_target.real_name] = sac_target

	if(isnull(last_tracked_name) || !alt_clicked)
		radial_open = TRUE
		last_tracked_name = show_radial_menu(
			action.owner,
			action.owner,
			choosable_targets,
			custom_check = CALLBACK(src, PROC_REF(check_menu)),
			radius = 40,
			require_near = TRUE,
		)
		radial_open = FALSE

	if(isnull(last_tracked_name))
		return

	var/atom/tracked_thing = possible_tracked_atoms[last_tracked_name]
	if(QDELETED(tracked_thing))
		last_tracked_name = null
		return

	playsound(action.owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	action.owner.balloon_alert(action.owner, get_balloon_message(tracked_thing))

	if(!ismob(tracked_thing))
		return

	var/mob/tracked_mob = tracked_thing
	if(tracked_mob.stat != DEAD)
		return

	to_chat(action.owner, span_hierophant("[DECLENT_RU_CAP(tracked_mob, NOMINATIVE)] мертв[GEND_A_O_Y(tracked_mob)]. \
										Принесите [GEND_HIS_HER(tracked_mob)] на руну трансформации и используйте \
										\"[sac_knowledge.name]\", чтобы принести [GEND_HIS_HER(tracked_mob)] в жертву!"))


/// Callback for the radial to ensure it's closed when not allowed.
/obj/effect/proc_holder/spell/track_target/proc/check_menu()
	if(QDELETED(src))
		return FALSE

	if(!isheretic(action.owner))
		return FALSE

	return TRUE


/// Gets the balloon message for who we're tracking.
/obj/effect/proc_holder/spell/track_target/proc/get_balloon_message(atom/tracked_thing)
	var/balloon_message = "ошибка!"
	var/turf/their_turf = get_turf(tracked_thing)
	var/turf/our_turf = get_turf(action.owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

	if(!our_z || !their_z)
		balloon_message = "на другом уровне!"

	else if(our_z != their_z)
		if(is_station_level(their_z))
			if(is_station_level(our_z))
				if(our_z > their_z)
					balloon_message = "под вами!"
				else
					balloon_message = "над вами!"
			else
				balloon_message = "на станции!"

		else if(is_mining_level(their_z))
			balloon_message = "на лавовой земле!"

		else if(is_away_level(their_z))
			balloon_message = "за вратами!"

		else
			balloon_message = "на другом слое реальности!"

	else
		var/dist = get_dist(our_turf, their_turf)
		var/dir = get_dir(our_turf, their_turf)

		var/arrow_color

		switch(dist)
			if(0 to 15)
				balloon_message = "очень близко, [dir2rustext_where(dir)]!"
				arrow_color = COLOR_GREEN
			if(16 to 31)
				balloon_message = "близко, [dir2rustext_where(dir)]!"
				arrow_color = COLOR_YELLOW
			if(32 to 127)
				balloon_message = "далеко, [dir2rustext_where(dir)]!"
				arrow_color = COLOR_ORANGE
			else
				balloon_message = "слишком далеко!"
				arrow_color = COLOR_RED

		if(action.owner.hud_used)
			new /atom/movable/screen/navigate_arrow(null, action.owner.hud_used, their_turf, arrow_color)

	if(!ismob(tracked_thing))
		return balloon_message

	var/mob/tracked_mob = tracked_thing
	if(tracked_mob.stat != DEAD)
		return balloon_message

	return "[GEND_MERTV(tracked_mob)], " + balloon_message


/atom/movable/screen/navigate_arrow
	icon = 'icons/effects/96x96.dmi'
	name = "указатель"
	icon_state = "navigate_arrow_appear"
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/atom/movable/screen/navigate_arrow/Initialize(mapload, datum/hud/hud_owner, turf/tracked_turf, arrow_color)
	. = ..()
	var/mob/owner = hud?.mymob
	if(owner)
		animate(src, transform = matrix(get_angle(owner, tracked_turf), MATRIX_ROTATE), 0.2 SECONDS)

	screen_loc = "CENTER-1,CENTER-1"
	color = arrow_color
	if(!hud)
		addtimer(CALLBACK(src, PROC_REF(end_effect)), 1.6 SECONDS)
		return

	hud.infodisplay += src
	hud.show_hud(hud.hud_version)
	addtimer(CALLBACK(src, PROC_REF(end_effect)), 1.6 SECONDS)


/atom/movable/screen/navigate_arrow/proc/end_effect()
	icon_state = "navigate_arrow_disappear"
	addtimer(CALLBACK(src, PROC_REF(null_arrow)), 0.4 SECONDS)


/atom/movable/screen/navigate_arrow/proc/null_arrow()
	if(!hud)
		qdel(src)
		return

	hud.infodisplay -= src
	hud.show_hud(hud.hud_version)
	qdel(src)
