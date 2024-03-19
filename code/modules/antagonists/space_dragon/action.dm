//Small sprites
/datum/action/innate/small_sprite_dragon
	name = "Toggle Giant Sprite"
	desc = "Остальные продолжат видеть вас огромным."
	button_icon_state = "carp"
	background_icon_state = "bg_alien"
	var/small = FALSE
	var/small_icon = 'icons/mob/carp.dmi'
	var/small_icon_state = "carp"
	check_flags = AB_CHECK_CONSCIOUS


/datum/action/innate/small_sprite_dragon/Trigger(left_click = TRUE)
	..()
	if(owner.stat == DEAD)
		return
	if(!small)
		var/image/I = image(icon = small_icon, icon_state = small_icon_state, loc = owner)
		I.override = TRUE
		I.pixel_x -= owner.pixel_x
		I.pixel_y -= owner.pixel_y
		owner.add_alt_appearance("smallsprite", I, list(owner))
		small = TRUE
	else
		owner.remove_alt_appearance("smallsprite")
		small = FALSE


/datum/action/innate/space_dragon_gust
	name = "Gust"
	desc = "Эта способность отталкивает всех, кто находится рядом с вами."
	button_icon_state = "repulse"
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	var/mob/living/simple_animal/hostile/space_dragon/space_dragon


/datum/action/innate/space_dragon_gust/Grant(mob/M)
	. = ..()
	if(!M)
		return
	if(istype(owner, /mob/living/simple_animal/hostile/space_dragon))
		space_dragon = owner


/datum/action/innate/space_dragon_gust/Remove(mob/M)
	. = ..()
	if(!M)
		return
	space_dragon = null


/datum/action/innate/space_dragon_gust/Trigger(left_click = TRUE)
	. = ..()
	if(space_dragon?.stat == DEAD)
		return
	space_dragon?.try_gust()


/datum/action/innate/summon_rift
	name = "Summon Rift"
	desc = "Открывает разлом призыва орды космических карпов."
	button_icon_state = "carp_rift"
	background_icon_state = "bg_alien"


/datum/action/innate/summon_rift/Activate()
	var/datum/antagonist/space_dragon/dragon = owner.mind?.has_antag_datum(/datum/antagonist/space_dragon)
	if(!dragon)
		return
	var/area/rift_location = get_area(owner)
	if(!rift_location.valid_territory)
		to_chat(owner, span_warning("Вы не можете открыть разлом здесь! Попробуйте ещё раз где-то в безопасном месте на станции!"))
		return
	for(var/obj/structure/carp_rift/rift as anything in dragon.rift_list)
		var/area/used_location = get_area(rift)
		if(used_location == rift_location)
			to_chat(owner, span_warning("Вы уже открыли разлом на этой территории! Разлом должен находиться где-то ещё!"))
			return
	var/turf/rift_spawn_turf = get_turf(dragon)
	if(isspaceturf(rift_spawn_turf))
		to_chat(owner, span_warning("Вы не можете открыть разлом здесь! Для него нужна поверхность!"))
		return
	to_chat(owner, span_notice("Вы начинаете открывать разлом..."))
	if(!do_after(owner, 10 SECONDS, target = owner))
		return
	if(locate(/obj/structure/carp_rift) in owner.loc)
		return
	var/obj/structure/carp_rift/new_rift = new(get_turf(owner))
	playsound(owner.loc, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	dragon.riftTimer = -1
	new_rift.dragon = dragon
	dragon.rift_list += new_rift
	to_chat(owner, span_boldwarning("Разлом был открыт. Любой ценой не допустите его уничтожения!"))
	notify_ghosts("Космический дракон открыл разлом!", source = new_rift, action = NOTIFY_FOLLOW, flashwindow = FALSE, title = "Открытие разлома Карпов")
	ASSERT(dragon.rift_ability == src) // Badmin protection.
	QDEL_NULL(dragon.rift_ability) // Deletes this action when used successfully, we re-gain a new one on success later.


/datum/action/innate/lesser_carp_rift
	name = "Lesser Carp Rift"
	desc = "Открывает малый разлом карпов, который позволяет перемещаться на малое расстояние."
	button_icon_state = "rift"
	background_icon_state = "bg_alien"
	var/cooldown_time = 15 SECONDS
	var/melee_cooldown_time = 0 SECONDS // Handled by rift
	/// How far away can you place a rift?
	var/range = 3
	COOLDOWN_DECLARE(rift_cooldown)


/datum/action/innate/lesser_carp_rift/Activate()
	if(!COOLDOWN_FINISHED(src, rift_cooldown))
		to_chat(owner, span_warning("Способность на перезарядке! Осталось секунд: [round(COOLDOWN_TIMELEFT(src, rift_cooldown)) / 10]!"))
		return FALSE
	var/turf/current_location = get_turf(owner)
	var/turf/destination = get_teleport_loc(current_location, owner, range)
	if (!make_rift(destination))
		return FALSE
	COOLDOWN_START(src, rift_cooldown, cooldown_time)
	return TRUE


/datum/action/innate/lesser_carp_rift/proc/make_rift(atom/target_atom)
	var/turf/owner_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target_atom)
	if (!target_turf)
		return FALSE

	var/list/open_exit_turfs = list()
	for (var/turf/potential_exit as anything in (RANGE_TURFS(1, target_turf) - target_turf))
		if(potential_exit.is_blocked_turf(exclude_mobs = TRUE))
			continue
		open_exit_turfs += potential_exit

	if(!length(open_exit_turfs))
		to_chat(owner, span_warning("Нет выхода!"))
		return FALSE
	if(!target_turf.is_blocked_turf(exclude_mobs = TRUE))
		open_exit_turfs += target_turf

	new /obj/effect/temp_visual/lesser_carp_rift/exit(target_turf)
	var/obj/effect/temp_visual/lesser_carp_rift/entrance/enter = new(owner_turf)
	enter.exit_locs = open_exit_turfs
	enter.on_entered(enter, owner)
	return TRUE


/// If you touch the entrance you are teleported to the exit, exit doesn't do anything
/obj/effect/temp_visual/lesser_carp_rift
	name = "lesser carp rift"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "carp_rift"
	duration = 5 SECONDS
	/// Holds a reference to a timer until this gets deleted
	var/destroy_timer


/obj/effect/temp_visual/lesser_carp_rift/Initialize(mapload)
	destroy_timer = addtimer(CALLBACK(src, PROC_REF(animate_out)), duration - 1, TIMER_STOPPABLE)
	return ..()


/obj/effect/temp_visual/lesser_carp_rift/proc/animate_out()
	var/obj/effect/temp_visual/lesser_carp_rift_dissipating/animate_out = new(loc)
	animate_out.setup_animation(alpha)


/obj/effect/temp_visual/lesser_carp_rift/Destroy()
	. = ..()
	deltimer(destroy_timer)


/// If you touch this you are taken to the exit
/obj/effect/temp_visual/lesser_carp_rift/entrance
	/// Where you get teleported to
	var/list/exit_locs
	/// Click CD to apply after teleporting
	var/disorient_time = CLICK_CD_MELEE


/obj/effect/temp_visual/lesser_carp_rift/entrance/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/temp_visual/lesser_carp_rift/entrance/proc/on_entered(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER

	if (!length(exit_locs))
		return
	if (!ismob(entered_atom) && !isobj(entered_atom))
		return
	if (entered_atom.anchored)
		return
	if(!entered_atom.loc)
		return
	if (isobserver(entered_atom))
		return

	if (isliving(entered_atom))
		var/mob/living/teleported_mob = entered_atom
		teleported_mob.changeNext_move(disorient_time)

	var/turf/destination = pick(exit_locs)
	do_teleport(entered_atom, destination)
	playsound(src, 'sound/magic/wand_teleport.ogg', 50)
	playsound(destination, 'sound/magic/wand_teleport.ogg', 50)


/// Doesn't actually do anything, just a visual marker
/obj/effect/temp_visual/lesser_carp_rift/exit
	alpha = 125


/// Just an animation
/obj/effect/temp_visual/lesser_carp_rift_dissipating
	name = "lesser carp rift"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	duration = 1 SECONDS


/obj/effect/temp_visual/lesser_carp_rift_dissipating/proc/setup_animation(new_alpha)
	alpha = new_alpha
	animate(src, alpha = 0, time = duration - 1)

