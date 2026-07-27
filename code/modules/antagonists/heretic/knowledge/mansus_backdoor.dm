/datum/heretic_knowledge/mansus_gate
	drafting_tier = 3
	is_shop_only = TRUE
	name = "Ключи от Чёрного Хода"
	desc = "Открывает чёрный ход в Обитель.<br>\
			Войдя в шкаф, вы перенесётесь в Обитель — безопасное убежище, \
			где можно проводить трансмутации и хранить снаряжение."
	transmute_text = "Преобразуйте шкаф и Кодекс Истязания или Кодекс Морбус."
	notice = "Сквозь чёрный ход могут пройти только добровольцы или мертвецы.\
		<br>Попытка провести жертвоприношение так близко к богам может разгневать их.\
		<br>Чёрный ход можно создать только один раз."
	gain_text = "У любых владений защита сильна ровно настолько, насколько сильна их слабейшая точка. \
				Кодекс говорит о чёрных ходах в Обитель — вратах с ветхими цепями, дверях с хрупкими замками, \
				люках с проржавевшими петлями. С правильным ключом я легко воспользуюсь ими."
	required_atoms = list(
		/obj/structure/closet = 1,
		list(/obj/item/codex_cicatrix, /obj/item/codex_cicatrix/morbus) = 1,
	)
	cost = 2
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "anom"
	var/used = FALSE
	var/relaying = FALSE
	var/obj/structure/closet/station_closet
	var/obj/structure/closet/mansus_closet


/datum/heretic_knowledge/mansus_gate/can_be_invoked(datum/antagonist/heretic/invoker)
	return !used


/datum/heretic_knowledge/mansus_gate/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/obj/structure/closet/locker = locate() in selected_atoms
	if(isnull(locker))
		stack_trace("Locker not found in selected atoms for mansus gate recipe!")
		return FALSE

	used = TRUE
	INVOKE_ASYNC(src, PROC_REF(setup_link), locker)
	return TRUE


/datum/heretic_knowledge/mansus_gate/cleanup_atoms(list/selected_atoms)
	for(var/obj/structure/closet/locker in selected_atoms)
		selected_atoms -= locker

	return ..()


/datum/heretic_knowledge/mansus_gate/proc/setup_link(obj/structure/closet/locker)
	var/datum/turf_reservation/reservation = SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_MANSUS_BACKDOOR, force = TRUE)
	if(isnull(reservation))
		stack_trace("Failed to load the mansus backdoor template!")
		return

	var/obj/structure/closet/exit_closet
	for(var/turf/tile as anything in block(reservation.bottom_left_turfs[1], reservation.top_right_turfs[1]))
		exit_closet = locate(/obj/structure/closet) in tile
		if(exit_closet)
			break

	if(isnull(exit_closet))
		stack_trace("No closet found in the loaded mansus backdoor template!")
		return

	station_closet = locker
	mansus_closet = exit_closet
	mansus_closet.set_anchored(TRUE)
	mansus_closet.anchorable = FALSE
	mansus_closet.can_weld_shut = FALSE
	for(var/obj/structure/closet/gate as anything in list(station_closet, mansus_closet))
		gate.resistance_flags |= INDESTRUCTIBLE
		gate.welded = FALSE
		gate.store_large_structures = TRUE
		gate.update_icon()
		RegisterSignal(gate, COMSIG_ATOM_ENTERED, PROC_REF(on_gate_entered))
		RegisterSignal(gate, COMSIG_QDELETING, PROC_REF(on_gate_deleted))


/datum/heretic_knowledge/mansus_gate/proc/on_gate_entered(obj/structure/closet/gate, atom/movable/arrived)
	SIGNAL_HANDLER

	if(relaying)
		return

	var/obj/structure/closet/destination = (gate == station_closet) ? mansus_closet : station_closet
	if(QDELETED(destination))
		return

	if(destination.welded)
		if(isliving(arrived))
			gate.balloon_alert(arrived, "проход закрыт!")
		return

	if(gate == station_closet)
		if(isliving(arrived) && !consents_to_entry(arrived))
			gate.balloon_alert(arrived, "дверь отвергает вас!")
			return

		for(var/mob/living/entering in arrived.get_all_contents() - arrived)
			if(consents_to_entry(entering))
				continue
			if(isliving(arrived))
				gate.balloon_alert(arrived, "дверь отвергает вас!")
			return

	relaying = TRUE
	arrived.forceMove(destination)
	relaying = FALSE


/datum/heretic_knowledge/mansus_gate/proc/consents_to_entry(mob/living/entering)
	if(IS_HERETIC_OR_MONSTER(entering))
		return TRUE
	if(entering.stat == DEAD)
		return TRUE
	return !entering.incapacitated(IGNORE_GRAB)


/datum/heretic_knowledge/mansus_gate/proc/on_gate_deleted(obj/structure/closet/gate)
	SIGNAL_HANDLER

	if(gate == station_closet)
		station_closet = null
	else if(gate == mansus_closet)
		mansus_closet = null


/datum/heretic_knowledge/mansus_gate/Destroy(force)
	station_closet = null
	mansus_closet = null
	return ..()


/datum/lazy_template/mansus_backdoor
	key = LAZY_TEMPLATE_KEY_MANSUS_BACKDOOR
	map_name = "mansus_backdoor"


/area/centcom/heretic_backdoor
	name = "Mansus"
	icon = 'icons/area/eldritch_areas.dmi'
	icon_state = "heretic"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	area_flags = UNIQUE_AREA
	no_teleportlocs = TRUE
	base_lighting_alpha = 200
	base_lighting_color = "#FFF4AA"


/area/centcom/heretic_backdoor/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/arrived_mob = arrived
	arrived_mob.add_movespeed_modifier(/datum/movespeed_modifier/heretic_backdoor_slowdown)
	arrived_mob.AdjustEyeBlind(1 SECONDS)
	arrived_mob.AdjustEyeBlurry(2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(greet_message), arrived_mob), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	if(!IS_HERETIC_OR_MONSTER(arrived_mob))
		arrived_mob.apply_necropolis_curse(CURSE_BLINDING)


/area/centcom/heretic_backdoor/Exited(atom/movable/gone, direction)
	. = ..()
	if(!isliving(gone))
		return
	var/mob/living/gone_mob = gone
	gone_mob.remove_movespeed_modifier(/datum/movespeed_modifier/heretic_backdoor_slowdown)
	gone_mob.remove_status_effect(/datum/status_effect/necropolis_curse)
	gone_mob.AdjustEyeBlind(1 SECONDS)
	gone_mob.AdjustEyeBlurry(2 SECONDS)


/area/centcom/heretic_backdoor/proc/greet_message(mob/living/arrived_mob)
	if(QDELETED(arrived_mob) || get_area(arrived_mob) != src)
		return
	to_chat(arrived_mob, span_mansus("Сверху светит полое солнце."))


/datum/movespeed_modifier/heretic_backdoor_slowdown
	multiplicative_slowdown = 0.5


/turf/simulated/floor/indestructible/mansus_grass
	name = "grass patch"
	desc = "Пристально вглядываясь в отдельные травинки, вы почти видите, как они шевелятся."
	icon_state = "grass1"
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/floor/indestructible/mansus_wood
	icon_state = "wood"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/wall/indestructible/mansus_wood
	name = "wooden wall"
	desc = "Стена, обшитая деревом. Выглядит непоколебимой."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS
