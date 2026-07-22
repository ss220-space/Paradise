/mob/living/simple_animal/hostile/heretic_summon/star_gazer
	name = "star gazer"
	desc = "Существо, которому поручено следить за звёздами."
	gender = MALE
	icon = 'icons/mob/96x96eldritch_mobs.dmi'
	icon_state = "star_gazer"
	icon_living = "star_gazer"
	pixel_x = -32
	base_pixel_x = -32
	response_help = "проходит сквозь"
	speed = -0.2
	maxHealth = 6000
	health = 6000

	obj_damage = 400
	armour_penetration = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	sentience_type = SENTIENCE_BOSS
	attacktext = "бьет"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	Atkcool = 0.6 SECONDS
	speak_emote = list("рычит")
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)
	death_sound = 'sound/magic/cosmic_expansion.ogg'

	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	can_buckle_to = FALSE
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS

	ai_controller = /datum/ai_controller/basic_controller/star_gazer
	/// Reference to the mob which summoned us
	var/datum/weakref/summoner
	/// How far we can go before being pulled back
	var/leash_range = 20
	/// Timer for finding a ghost so it doesn't spam dead chat with requests
	var/begging_timer
	/// Abilities given to the star gazer mob
	var/list/abilities_to_grant = list(
		/obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion,
		/obj/effect/proc_holder/spell/pointed/projectile/star_blast,
		/obj/effect/proc_holder/spell/recall_stargazer,
		/obj/effect/proc_holder/spell/stargazer_laser,
	)


/mob/living/simple_animal/hostile/heretic_summon/star_gazer/get_ru_names()
	return alist(
		NOMINATIVE = "Звёздный Наблюдатель",
		GENITIVE = "Звёздного Наблюдателя",
		DATIVE = "Звёздному Наблюдателю",
		ACCUSATIVE = "Звёздного Наблюдателя",
		INSTRUMENTAL = "Звёздным Наблюдателем",
		PREPOSITIONAL = "Звёздном Наблюдателе",
	)


/mob/living/simple_animal/hostile/heretic_summon/star_gazer/Initialize(mapload, mob/living/master)
	. = ..()
	if(master)
		summoner = WEAKREF(master)
	for(var/spell_path in abilities_to_grant)
		var/obj/effect/proc_holder/spell/spell = new spell_path(src)
		AddSpell(spell)
		if(istype(spell, /obj/effect/proc_holder/spell/pointed/projectile/star_blast))
			var/obj/effect/proc_holder/spell/pointed/projectile/star_blast/blast = spell
			blast.summoner = summoner
		else if(istype(spell, /obj/effect/proc_holder/spell/stargazer_laser))
			var/obj/effect/proc_holder/spell/stargazer_laser/laser = spell
			laser.our_master = summoner
	AddComponent(/datum/component/seethrough_mob)
	var/static/list/death_loot = list(/obj/effect/temp_visual/cosmic_domain)
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/death_explosion, 3, 6, 12)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	AddElement(/datum/element/wall_smasher, ENVIRONMENT_SMASH_RWALLS)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/effect_trail/cosmic_field/antiprojectile, /obj/effect/forcefield/cosmic_field/fast)
	AddElement(/datum/element/ai_target_damagesource)
	AddComponent(/datum/component/regenerator, outline_colour = "#b97a5d")
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	set_light(4, l_color = "#dcaa5b")
	INVOKE_ASYNC(src, PROC_REF(beg_for_ghost))
	RegisterSignal(src, COMSIG_LIVING_GHOSTIZED, PROC_REF(beg_for_ghost))


/mob/living/simple_animal/hostile/heretic_summon/star_gazer/Destroy()
	deltimer(begging_timer)
	return ..()


/// Tries to find a ghost to take control of the mob. If no ghost accepts, ask again in a bit.
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/beg_for_ghost()
	SIGNAL_HANDLER
	if(timeleft(begging_timer) && !client)
		return
	begging_timer = addtimer(CALLBACK(src, PROC_REF(beg_for_ghost)), 2 MINUTES, TIMER_STOPPABLE | TIMER_UNIQUE) // Keep begging until someone accepts
	if(client) // Already player-controlled; keep the heartbeat armed for a future ghosting but don't poll over them.
		return
	INVOKE_ASYNC(src, PROC_REF(poll_for_gazer))

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/poll_for_gazer()
	var/mob/living/master = summoner?.resolve()
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите стать [declent_ru(INSTRUMENTAL)] вознёсшегося еретика[master ? " [master.real_name]" : ""]?", null, FALSE, poll_time = 20 SECONDS, ignore_respawnability = TRUE, source = src)
	if(!length(candidates) || client || QDELETED(src))
		return
	var/mob/dead/observer/chosen_ghost = pick(candidates)
	key = chosen_ghost.key
	deltimer(begging_timer)
	if(master?.mind && mind && !mind.has_antag_datum(/datum/antagonist/heretic_monster))
		var/datum/antagonist/heretic_monster/heretic_monster = mind.add_antag_datum(/datum/antagonist/heretic_monster)
		heretic_monster.set_owner(master.mind)


/// Connects these two mobs by a leash
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/leash_to(atom/movable/leashed, atom/movable/leashed_to)
	leashed.AddComponent(\
		/datum/component/leash,\
		owner = leashed_to,\
		distance = leash_range,\
		force_teleport_out_effect = /obj/effect/temp_visual/guardian/phase/out,\
		force_teleport_in_effect = /obj/effect/temp_visual/guardian/phase,\
	)


/mob/living/simple_animal/hostile/heretic_summon/star_gazer/AttackingTarget()
	if(target == summoner?.resolve())
		return FALSE
	. = ..()
	if(!. || !isliving(target))
		return

	var/mob/living/liv_target = target
	liv_target.apply_status_effect(/datum/status_effect/star_mark)
	liv_target.apply_damage(damage = 5, damagetype = BURN)
	for(var/mob/living/nearby_mob in range(1, src))
		if(target == nearby_mob || !CanAttack(src, nearby_mob))
			continue

		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)
		nearby_mob.apply_damage(10)
		to_chat(nearby_mob, span_userdanger("[declent_ru(NOMINATIVE)] [attacktext] вас!"))
		do_attack_animation(nearby_mob, ATTACK_EFFECT_SLASH)
		add_attack_logs(src, nearby_mob, "slashed (star gazer cleave)")


/obj/effect/proc_holder/spell/recall_stargazer
	name = "Найти хозяина"
	desc = "Телепортирует вас к вашему хозяину."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "stargazer_menu"
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 5 SECONDS
	spell_requirements = NONE


/obj/effect/proc_holder/spell/recall_stargazer/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/recall_stargazer/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/real_owner = action.owner
	if(!istype(real_owner))
		return FALSE
	var/mob/living/master = real_owner.summoner?.resolve()
	if(!master)
		to_chat(real_owner, span_warning("У вас нет хозяина!"))
		revert_cast(real_owner)
		return FALSE
	do_teleport(real_owner, get_turf(master))
	return TRUE


/obj/effect/proc_holder/spell/stargazer_laser
	name = "Звёздный взор"
	desc = "Создаёт колоссальный смертоносный луч, испепеляющий всё на своём пути. \
			Обладает собственной гравитацией, затягивающей новые жертвы."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "gazer_beam_charge"
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS
	invocation = "SH''P D' W''P"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	/// list of turfs we are hitting while shooting our beam
	var/list/turf/beam_targets
	/// Timer that handles the damage ticking
	var/damage_timer
	/// Reference to our summoner so that we don't disintegrate them by accident
	var/datum/weakref/our_master
	/// The overlay on the caster when they fire the beam
	var/obj/effect/abstract/gazer_orb/orb_visual
	/// The visual effect at the beginning of the laser
	var/obj/effect/abstract/gazer_beam/beam_visual
	/// List of visual effects for the beam, in between and in the end
	var/list/beam_fillings
	/// Sound loop for the active laser
	var/datum/looping_sound/gazer_beam/sound_loop
	/// The visual effect at the end of the laser
	var/obj/effect/abstract/gazer_beamend/end_visual
	/// Tracks how many times the beam has processed, after the maximum amount of cycles it will forcibly end the beam
	var/cycle_tracker = 0


/obj/effect/proc_holder/spell/stargazer_laser/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/stargazer_laser/Initialize(mapload)
	. = ..()
	sound_loop = new


/obj/effect/proc_holder/spell/stargazer_laser/Destroy()
	stop_beaming()
	QDEL_NULL(sound_loop)
	return ..()


/obj/effect/proc_holder/spell/stargazer_laser/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action.owner
	if(!caster)
		return FALSE

	if(damage_timer)
		stop_beaming()

	var/turf/check_turf = get_step(caster, caster.dir)
	var/list/turf/targets_left = list()
	targets_left += get_step(check_turf, turn(caster.dir, 90))
	var/list/turf/targets_right = list()
	targets_right += get_step(check_turf, turn(caster.dir, -90))
	LAZYINITLIST(beam_targets)
	while(check_turf && length(beam_targets) < 20)
		beam_targets += check_turf
		check_turf = get_step(check_turf, caster.dir)
		targets_left += get_step(check_turf, turn(caster.dir, 90))
		targets_right += get_step(check_turf, turn(caster.dir, -90))
	if(!LAZYLEN(beam_targets))
		return FALSE

	RegisterSignals(caster, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE), PROC_REF(stop_beaming))
	beam_fillings = list()
	cycle_tracker = 0
	orb_visual = new(get_step(caster, caster.dir))
	var/beam_timer = addtimer(CALLBACK(src, PROC_REF(open_laser), caster, beam_targets), 2.2 SECONDS, TIMER_STOPPABLE)
	playsound(caster, 'sound/creatures/stargazer/beam_open.ogg', 50, FALSE)
	if(!do_after(caster, 3 SECONDS, caster))
		cooldown_handler.start_recharge(1 SECONDS)
		deltimer(beam_timer)
		UnregisterSignal(caster, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
		QDEL_NULL(orb_visual)
		QDEL_NULL(beam_visual)
		QDEL_NULL(end_visual)
		for(var/atom/to_delete as anything in beam_fillings)
			qdel(to_delete)
		beam_fillings = null
		beam_targets = null
		return FALSE

	sound_loop.start(caster)
	QDEL_NULL(orb_visual)
	beam_visual.icon_state = "gazer_beam_active"
	beam_visual.update_appearance(UPDATE_ICON)
	end_visual.icon_state = "gazer_beam_end"
	end_visual.update_appearance(UPDATE_ICON)
	beam_targets += targets_left
	beam_targets += targets_right
	process_beam()
	return TRUE


/// Spawns the beginning of the laser, uses `beam_targets` to determine the rotation
/obj/effect/proc_holder/spell/stargazer_laser/proc/open_laser(mob/owner, list/turf/beam_targets)
	beam_visual = new(get_step(get_step(owner, owner.dir), owner.dir), beam_targets[length(beam_targets)])
	end_visual = new(beam_targets[length(beam_targets)], owner)
	var/start_index = min(4, length(beam_targets))
	var/end_index = max(1, length(beam_targets) - 2)
	for(var/turf/to_fill as anything in (get_line(beam_targets[start_index], beam_targets[end_index])))
		var/obj/effect/abstract/gazer_beam_filling/new_filling = new(to_fill, owner.dir)
		beam_fillings += new_filling


/// Recursive proc which affects whatever is caught within the beam
/obj/effect/proc_holder/spell/stargazer_laser/proc/process_beam()
	if(cycle_tracker > 33)
		stop_beaming()
	for(var/obj/effect/abstract/gazer_beam_filling/fillings as anything in beam_fillings)
		if(prob(98))
			continue
		fillings.pull_victims()
	var/mob/living/master = our_master?.resolve()
	for(var/turf/target as anything in beam_targets)
		if(!target)
			continue
		if(iswallturf(target))
			var/turf/simulated/wall/wall_target = target
			wall_target.dismantle_wall(devastated = TRUE)
			continue
		if(isfloorturf(target))
			var/turf/simulated/floor/to_burn = target
			to_burn.burn_tile()
		for(var/victim in target)
			if(isobj(victim))
				var/obj/to_obliterate = victim
				if(to_obliterate.resistance_flags & INDESTRUCTIBLE)
					continue
				to_obliterate.obj_destruction(FIRE)
			if(isliving(victim))
				if(victim == master)
					continue
				var/mob/living/living_victim = victim
				if(living_victim.stat > CONSCIOUS)
					playsound(living_victim, 'sound/effects/supermatter.ogg', 80, TRUE)
					living_victim.visible_message(
						span_danger("Вы видите, как [living_victim] поглощает испепеляющий гнев космоса. \
							На мгновение силуэт бьётся в агонии, прежде чем распасться на атомы."),
						span_bold(span_hypnophrase("СИЛА САМОГО КОСМОСА ОБРУШИВАЕТСЯ НА ВАШЕ ТЕЛО. \
							ВОЛНЫ ЖАРА ВЦЕПЛЯЮТСЯ В НЕГО, РАЗРЫВАЯ ПО ШВАМ. \
							ВАШЕ ПОЛНОЕ УНИЧТОЖЕНИЕ ЗАНИМАЕТ ЛИШЬ МГНОВЕНИЕ, ПРЕЖДЕ ЧЕМ ВЫ ВНОВЬ СТАНЕТЕ ТЕМ, ЧЕМ ВСЕГДА БЫЛИ. \
							ПЫЛИНКАМИ ПРАХА..."))
						)
					living_victim.dust()
					continue
				living_victim.emote("scream")
				living_victim.apply_status_effect(/datum/status_effect/star_mark)
				living_victim.apply_damage(damage = 30, damagetype = BURN)
	cycle_tracker++
	damage_timer = addtimer(CALLBACK(src, PROC_REF(process_beam)), 0.3 SECONDS, TIMER_STOPPABLE)


/// Stops the beam after we cancel it
/obj/effect/proc_holder/spell/stargazer_laser/proc/stop_beaming()
	SIGNAL_HANDLER
	sound_loop.stop()
	if(action?.owner)
		UnregisterSignal(action.owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	QDEL_NULL(beam_visual)
	QDEL_NULL(end_visual)
	QDEL_LIST(beam_fillings)
	deltimer(damage_timer)
	damage_timer = null
	beam_targets = null


/obj/effect/abstract/gazer_orb
	icon = 'icons/effects/160x160.dmi'
	icon_state = "gazer_beam_charge"
	invisibility = INVISIBILITY_NONE
	SET_BASE_VISUAL_PIXEL(-64, -64)


/obj/effect/abstract/gazer_beam
	icon = 'icons/effects/beam96x96.dmi'
	invisibility = INVISIBILITY_NONE
	SET_BASE_VISUAL_PIXEL(-32, -32)


/obj/effect/abstract/gazer_beam/Initialize(mapload, turf/target)
	. = ..()
	if(!target)
		return INITIALIZE_HINT_QDEL
	var/Angle = get_angle_raw(x, y, pixel_x, pixel_y, target.x, target.y, target.pixel_x, target.pixel_y)
	var/matrix/transform_matrix = matrix()
	Angle = round(Angle, 45)
	transform_matrix.Turn(Angle - 90)
	transform_matrix.Scale(2, 2)
	transform = transform_matrix
	flick("gazer_beam_start", src)


/obj/effect/abstract/gazer_beam_filling
	icon = 'icons/effects/beam.dmi'
	icon_state = "gazer_beam"
	invisibility = INVISIBILITY_NONE


/obj/effect/abstract/gazer_beam_filling/Initialize(mapload, direction)
	. = ..()
	if(!direction)
		return INITIALIZE_HINT_QDEL
	var/Angle = dir2angle(direction)
	var/matrix/transform_matrix = matrix()
	transform_matrix.Turn(Angle)
	transform_matrix.Scale(2, 2)
	transform = transform_matrix
	flick("gazer_beam_end_opening", src)


/obj/effect/abstract/gazer_beam_filling/proc/pull_victims()
	for(var/atom/movable/movable_atom in orange(5, src))
		if(movable_atom.anchored || movable_atom.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)
			continue
		if(ismob(movable_atom))
			var/mob/pulled_mob = movable_atom
			if(pulled_mob.mob_negates_gravity())
				continue
		step_towards(movable_atom, src)


/obj/effect/abstract/gazer_beamend
	icon = 'icons/effects/beam.dmi'
	invisibility = INVISIBILITY_NONE


/obj/effect/abstract/gazer_beamend/Initialize(mapload, atom/origin)
	. = ..()
	if(!origin)
		return INITIALIZE_HINT_QDEL
	var/Angle = get_angle_raw(origin.x, origin.y, origin.pixel_x, origin.pixel_y, x, y, pixel_x, pixel_y)
	var/matrix/transform_matrix = matrix()
	Angle = round(Angle, 45)
	transform_matrix.Turn(Angle)
	transform_matrix.Scale(2, 2)
	transform = transform_matrix
	flick("gazer_beam_end_opening", src)


/datum/looping_sound/gazer_beam
	mid_sounds = list('sound/creatures/stargazer/beam_loop_one.ogg')
	mid_length = 109
	volume = 80


/datum/ai_controller/basic_controller/star_gazer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targetting_datum/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_PET_TARGETING_STRATEGY = /datum/targetting_datum/basic/not_friends/attack_everything,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)


/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer


/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer


/datum/ai_behavior/attack_obstructions/star_gazer
	action_cooldown = 0.4 SECONDS
	can_attack_turfs = TRUE
	can_attack_dense_objects = TRUE


/datum/pet_command/attack/star_gazer
	speech_commands = list("атакуй", "фас", "убей", "в атаку", "бей")
	command_feedback = "наблюдает!"
	pointed_reaction = "пристально наблюдает!"
	refuse_reaction = "..."
