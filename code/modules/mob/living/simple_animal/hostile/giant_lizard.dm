/*
 * Giant lizard
 *
 * Ported from CMSS13 (code/modules/mob/living/simple_animal/hostile/giant_lizard.dm)
 */

#define LIZARD_ATTACK_SLASH 0
#define LIZARD_ATTACK_BITE 1

// Lizard movement speed
#define LIZARD_SPEED_NORMAL 2.8
#define LIZARD_SPEED_RETREAT 2.5
#define LIZARD_SPEED_NORMAL_CLIENT -0.5
#define LIZARD_SPEED_RETREAT_CLIENT -1.5

#define LIZARD_STANCE_IDLE 0
#define LIZARD_STANCE_ALERT 1
#define LIZARD_STANCE_ATTACKING 2

// Injury thresholds for displaying the corresponding overlay.
#define LIZARD_WOUNDS_NONE 4
#define LIZARD_WOUNDS_SMALL 3
#define LIZARD_WOUNDS_BIG 2

/*
 * An overlay for displaying wounds and a protruding tongue over a 64x64 lizard sprite.
 */
/obj/effect/abstract/giant_lizard_icon_holder
	icon = 'icons/mob/mob_64.dmi'
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_DIR|VIS_INHERIT_LAYER|VIS_INHERIT_PLANE
	appearance_flags = RESET_COLOR

/mob/living/simple_animal/hostile/giant_lizard
	name = "giant lizard"
	desc = "Крупное звероподобное пресмыкающееся. Его глаза пристально следят за вами."
	icon = 'icons/mob/mob_64.dmi'
	icon_state = "Giant Lizard Running"
	icon_living = "Giant Lizard Running"
	icon_dead = "Giant Lizard Dead"
	pixel_x = -16
	base_pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	maxHealth = 350
	health = 350
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	can_be_on_fire = TRUE
	move_to_delay = LIZARD_SPEED_NORMAL
	speed = LIZARD_SPEED_NORMAL_CLIENT
	footstep_type = FOOTSTEP_MOB_CLAW
	nightvision = 12

	speak_emote = list("шипит")
	emote_hear = list("шипит.", "рычит.")
	emote_see = list("мотает головой.", "виляет хвостом.", "зевает.", "облизывает глазное яблоко.")
	response_help = "гладит"

	melee_damage_lower = 15
	melee_damage_upper = 30
	obj_damage = 10
	vision_range = 16
	aggro_vision_range = 16
	ai_controller = /datum/ai_controller/giant_lizard

	var/obj/effect/abstract/giant_lizard_icon_holder/tongue_icon_holder
	var/obj/effect/abstract/giant_lizard_icon_holder/wound_icon_holder
	var/stance = LIZARD_STANCE_IDLE
	///Maximum distance at which the lizard continues to pursue the target.
	var/max_attack_distance = 16
	///Distance at which the lizard starts hissing/growling a warning at an intruder.
	var/max_growl_distance = 4
	///Distance at which the lizard immediately retaliates against an intruder.
	var/max_retaliate_distance = 2
	///Aggression value. At 0, the lizard calms down and enters standby mode.
	var/aggression_value = 0


	COOLDOWN_DECLARE(calm_cooldown)
	COOLDOWN_DECLARE(growl_message)

	var/is_ravaging = FALSE
	var/pounce_cooldown_length = 9 SECONDS
	COOLDOWN_DECLARE(pounce_cooldown)
	var/is_pouncing = FALSE

	var/bleed_ticks = 0
	var/chance_to_rest = 0
	var/is_retreating = FALSE
	var/retreat_attempts = 0
	COOLDOWN_DECLARE(retreat_cooldown)
	COOLDOWN_DECLARE(melee_cooldown)

	var/tameable = TRUE
	///Food this lizard accepts when hand-fed
	food_type = list(
		/obj/item/reagent_containers/food/snacks/meat,
	)
	///Chance that a single feeding wins the lizard over
	tame_chance = 25
	///Chance added for every failed taming attempt.
	bonus_tame_chance = 5
	var/obj/item/reagent_containers/food/snacks/food_target

	var/is_eating = FALSE
	COOLDOWN_DECLARE(food_cooldown)

/mob/living/simple_animal/hostile/giant_lizard/get_ru_names()
	return alist(
		NOMINATIVE = "гигантский ящер",
		GENITIVE = "гигантского ящера",
		DATIVE = "гигантскому ящеру",
		ACCUSATIVE = "гигантского ящера",
		INSTRUMENTAL = "гигантским ящером",
		PREPOSITIONAL = "гигантском ящере",
	)

/mob/living/simple_animal/hostile/giant_lizard/Initialize(mapload)
	. = ..()
	wound_icon_holder = new
	tongue_icon_holder = new
	tongue_icon_holder.pixel_x = 2
	vis_contents += wound_icon_holder
	vis_contents += tongue_icon_holder

	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(change_tongue_offset))

	GLOB.giant_lizards_alive += src
	var/name_suffix = " ([rand(1, 999)])"
	name += name_suffix
	real_name = name
	set_ru_names_suffix(name_suffix)
	toggle_ai(AI_OFF)

/mob/living/simple_animal/hostile/giant_lizard/proc/change_tongue_offset(datum/source, olddir, newdir)
	SIGNAL_HANDLER

	if(!newdir)
		newdir = dir

	switch(newdir)
		if(WEST)
			if(resting)
				tongue_icon_holder.pixel_x = 5
				tongue_icon_holder.pixel_y = -4
				return

			tongue_icon_holder.pixel_x = -8
			tongue_icon_holder.pixel_y = 0

		if(EAST)
			if(resting)
				tongue_icon_holder.pixel_x = -5
				tongue_icon_holder.pixel_y = -4
				return

			tongue_icon_holder.pixel_x = 8
			tongue_icon_holder.pixel_y = 0
		if(SOUTH)
			tongue_icon_holder.pixel_x = 0
			tongue_icon_holder.pixel_y = 0

/mob/living/simple_animal/hostile/giant_lizard/keybind_face_direction(direction)
	if(resting && (direction == NORTH || direction == SOUTH))
		return
	return ..()

/mob/living/simple_animal/hostile/giant_lizard/proc/growl(atom/target_mob, ignore_cooldown = FALSE)
	if(stat == DEAD)
		return
	if(!COOLDOWN_FINISHED(src, growl_message) && !ignore_cooldown)
		return
	if(target_mob)
		custom_emote(message = "рычит на [target_mob.declent_ru(ACCUSATIVE)].")
	else
		custom_emote(message = "рычит.")
	playsound(loc, 'sound/effects/giant_lizard_growl1.ogg', 60)
	COOLDOWN_START(src, growl_message, rand(10, 14) SECONDS)

///Stops the lizard's movement cycle without resetting its stance.
/mob/living/simple_animal/hostile/giant_lizard/proc/stop_moving()
	GLOB.move_manager.stop_looping(src)

/mob/living/simple_animal/hostile/giant_lizard/update_icons()
	if(stat == DEAD)
		icon_state = icon_dead
	else if(body_position == LYING_DOWN)
		icon_state = "Giant Lizard Sleeping"
	else
		icon_state = icon_living
	if(tongue_icon_holder)
		tongue_icon_holder.alpha = (body_position == LYING_DOWN || stat == DEAD) ? 0 : alpha
	update_wounds()
	change_tongue_offset()
	regenerate_icons()

///Updates the wound overlay based on current health and body position.
/mob/living/simple_animal/hostile/giant_lizard/proc/update_wounds()
	if(!wound_icon_holder)
		return

	var/health_threshold = max(ceil((health * 4) / maxHealth), 0)
	var/wound_state
	switch(health_threshold)
		if(LIZARD_WOUNDS_NONE)
			wound_state = "none"
		if(LIZARD_WOUNDS_SMALL)
			wound_state = "Wounds Small"
		if(0 to LIZARD_WOUNDS_BIG)
			wound_state = "Wounds Big"

	if(health <= 0)
		return
	if(wound_state == "none")
		wound_icon_holder.icon_state = "none"
	else if(body_position == LYING_DOWN)
		wound_icon_holder.icon_state = "Giant Lizard [wound_state] Rest"
	else
		wound_icon_holder.icon_state = "Giant Lizard [wound_state]"

/mob/living/simple_animal/hostile/giant_lizard/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		return .
	else if(faction_check_mob(user))
		. += span_notice("В его взгляде есть что-то тёплое.")
	return .

/mob/living/simple_animal/hostile/giant_lizard/set_resting(new_resting, silent = TRUE, instant = FALSE)
	. = ..()
	update_icons()

/mob/living/simple_animal/hostile/giant_lizard/rejuvenate()
	if(stat == DEAD)
		GLOB.giant_lizards_alive += src
	return ..()

/mob/living/simple_animal/hostile/giant_lizard/death(gibbed)
	playsound(loc, 'sound/effects/giant_lizard_death.ogg', 70)
	GLOB.giant_lizards_alive -= src
	stance = LIZARD_STANCE_IDLE
	enemies = list()
	lose_target()
	return ..()

/mob/living/simple_animal/hostile/giant_lizard/Destroy()
	GLOB.giant_lizards_alive -= src
	vis_contents -= wound_icon_holder
	vis_contents -= tongue_icon_holder
	QDEL_NULL(wound_icon_holder)
	QDEL_NULL(tongue_icon_holder)
	food_target = null
	return ..()

/mob/living/simple_animal/hostile/giant_lizard/apply_damage(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	blocked = 0,
	sharp = FALSE,
	used_weapon = null,
	spread_damage = FALSE,
	forced = FALSE,
	silent = FALSE,
	updating_health = TRUE,
	update_damage_icon = TRUE,
)
	aggression_value = clamp(aggression_value + 5, 0, 30)
	. = ..()
	if(damage <= 0)
		return .
	var/retreat_chance = abs((health / maxHealth * 100) - 100)
	if(prob(retreat_chance) && health <= maxHealth * 0.66 && COOLDOWN_FINISHED(src, retreat_cooldown))
		if(client && !is_retreating)
			is_retreating = TRUE
			to_chat(src, span_userdanger("Рефлекс \"бей или беги\" срабатывает — бегите!"))
			speed = LIZARD_SPEED_RETREAT_CLIENT
			addtimer(VARSET_CALLBACK(src, speed, LIZARD_SPEED_NORMAL_CLIENT), 8 SECONDS)
			addtimer(VARSET_CALLBACK(src, is_retreating, FALSE), 8 SECONDS)
		else if(!client)
			MoveTo(target, 12, TRUE, 4.5 SECONDS)
	if(damage >= 10 && damagetype == BRUTE)
		add_splatter_floor(loc, TRUE)
		bleed_ticks = clamp(bleed_ticks + ceil(damage / 10), 0, 30)
	update_wounds()
	return .

/mob/living/simple_animal/hostile/giant_lizard/proc/flee_from_fire()
	if(is_retreating || !on_fire || client || stat == DEAD || body_position == LYING_DOWN)
		return

	stance = LIZARD_STANCE_ALERT
	GiveTarget(null)
	food_target = null
	is_eating = FALSE
	MoveTo(null, 9, TRUE, 4 SECONDS, FALSE)
	playsound(src, 'sound/effects/giant_lizard_hiss2.ogg', 40)
	COOLDOWN_START(src, calm_cooldown, 8 SECONDS)

/mob/living/simple_animal/hostile/giant_lizard/IgniteMob()
	. = ..()
	if(on_fire)
		flee_from_fire()

/mob/living/simple_animal/hostile/giant_lizard/handle_fire()
	. = ..()
	if(on_fire)
		flee_from_fire()

/mob/living/simple_animal/hostile/giant_lizard/Life(seconds, times_fired)
	if(stat == DEAD)
		return ..()

	if(aggression_value > 0)
		aggression_value--

	// Rest healing: restore 2% brute per tick while sleeping
	if(resting && stat != DEAD && getBruteLoss() > 0)
		heal_damage_type(min(maxHealth * 0.02, getBruteLoss()), BRUTE)
		update_wounds()

	// Tongue flick cosmetics
	if(!HAS_TRAIT(src, TRAIT_INCAPACITATED) && !HAS_TRAIT(src, TRAIT_FLOORED) && prob(25))
		flick("Giant Lizard Tongue", tongue_icon_holder)

	// Blood pooling from bleeding
	if(bleed_ticks)
		var/is_small_pool = bleed_ticks < 10
		bleed_ticks--
		add_splatter_floor(loc, is_small_pool)

	. = ..()

	// Client-controlled: stop all AI-driven movement
	if(client)
		stop_moving()
		enemies = list()
		lose_target()
		ai_controller?.blackboard[BB_LIZARD_TARGET] = null
		ai_controller?.blackboard[BB_LIZARD_FOOD_TARGET] = null
		return .

	// Aggression dropped to zero — lose target so AI controller resumes idle
	if(aggression_value <= 0 && target)
		enemies = list()
		lose_target()

	// Wake up if resting and there is an active threat or target in blackboard
	if(resting && (target || on_fire || is_retreating || ai_controller?.blackboard[BB_LIZARD_TARGET]))
		set_resting(FALSE)

	// Destroy obstacles while retreating
	if(target && is_retreating && environment_smash)
		INVOKE_ASYNC(src, PROC_REF(DestroySurroundings))

	// Stop moving and reset retreat flag when there is no reason to continue fleeing
	if(is_retreating && !target && !on_fire)
		stop_moving()

	return .


///Can the lizard continue to consider this mob a target?
///Replaces CM's SA_attackable() and evaluate_target().
/mob/living/simple_animal/hostile/giant_lizard/proc/can_keep_target(mob/living/target_mob)
	if(!isliving(target_mob))
		return FALSE
	if(target_mob.stat == DEAD || target_mob.alpha <= 200 || !isturf(target_mob.loc))
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/giant_lizard/CanAttack(atom/the_target)
	if(ismonkey(the_target))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/giant_lizard/MoveToTarget(list/possible_targets)
	stop_automated_movement = TRUE
	var/mob/living/target_mob = isliving(target) ? target : null
	if(!target_mob || !can_keep_target(target_mob))
		stance = LIZARD_STANCE_IDLE
		return FALSE
	if(get_dist(src, target_mob) <= max_attack_distance)
		if(MoveTo(target_mob))
			stance = LIZARD_STANCE_ATTACKING
			return TRUE
	return FALSE

///Retaliation does not spread recursively: alert_others() skips pack members that already have a target.
/mob/living/simple_animal/hostile/giant_lizard/Retaliate()
	if(stat == DEAD || on_fire)
		return
	aggression_value = clamp(aggression_value + 5, 0, 15)

	. = ..()

	var/mob/living/found_target = FindTarget()
	if(!isliving(found_target))
		return
	GiveTarget(found_target)
	growl(found_target)
	MoveToTarget()

	alert_others()

/// Wakes the nearest pack members so they can join the fight as well.
/mob/living/simple_animal/hostile/giant_lizard/proc/alert_others()
	for(var/mob/living/simple_animal/hostile/giant_lizard/pack_member as anything in GLOB.giant_lizards_alive)
		if(pack_member == src || pack_member.client || isliving(pack_member.target) || get_dist(src, pack_member) > 7)
			continue
		pack_member.Retaliate()

//Procedure for moving to the target. GLOB.move_manager does not check for resting or status effects, so we check for them ourselves.
/mob/living/simple_animal/hostile/giant_lizard/proc/MoveTo(atom/move_target, distance = 1, retreat = FALSE, time = 6 SECONDS, return_to_combat = FALSE)
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_INCAPACITATED) || HAS_TRAIT(src, TRAIT_FLOORED))
		return FALSE
	if(client)
		stop_moving()
		return FALSE
	if(resting)
		set_resting(FALSE)
	var/atom/destination = move_target ? move_target : get_turf(src)
	if(!destination)
		return FALSE
	if(!retreat)
		GLOB.move_manager.move_to(src, destination, distance, move_to_delay)
		return TRUE
	if(is_retreating)
		return TRUE
	is_retreating = TRUE
	stop_automated_movement = TRUE
	stance = LIZARD_STANCE_ALERT
	GLOB.move_manager.move_away(src, destination, distance, LIZARD_SPEED_RETREAT)
	addtimer(CALLBACK(src, PROC_REF(stop_retreat), return_to_combat), time)
	return TRUE

/mob/living/simple_animal/hostile/giant_lizard/proc/stop_retreat(return_to_combat = FALSE, atom/return_target = null)
	is_retreating = FALSE
	if(on_fire)
		flee_from_fire()
		return
	// No combat recovery for skirmish retreat — lizard calms down regardless
	if(retreat_attempts >= 2)
		// Repeated failed retreats — abandon and try to find a new distant target
		var/mob/living/found_target = FindTarget()
		if(isliving(found_target))
			GiveTarget(found_target)
			ai_controller?.blackboard[BB_LIZARD_TARGET] = WEAKREF(found_target)
		retreat_attempts = 0
		COOLDOWN_START(src, retreat_cooldown, 20 SECONDS)
		return
	for(var/mob/living/carbon/hostile_mob in view(7, src))
		if(faction_check_mob(hostile_mob))
			continue
		// Retreat from nearest hostile mob found near current position
		MoveTo(hostile_mob, 10, TRUE, 2 SECONDS, FALSE)
		retreat_attempts++
		return
	retreat_attempts = 0
	lose_target()

///Target is optional: 1984 calls this without arguments, while DestroySurroundings() passes a specific object.
/mob/living/simple_animal/hostile/giant_lizard/AttackingTarget(atom/inherited_target = null)
	if(!inherited_target)
		inherited_target = target
	if(!inherited_target || !Adjacent(inherited_target) || is_ravaging || body_position == LYING_DOWN || is_eating)
		return
	if(!COOLDOWN_FINISHED(src, melee_cooldown))
		return

	if(isliving(inherited_target))
		var/mob/living/target_living = inherited_target
		if(target_living.body_position == LYING_DOWN)
			ravagingattack(target_living)
			return target_living

		var/attack_type = pick(LIZARD_ATTACK_SLASH, LIZARD_ATTACK_BITE)
		attacktext = attack_type ? "царапает" : "кусает"
		attack_sound = attack_type ? 'sound/weapons/slash.ogg' : 'sound/weapons/bite.ogg'
		target_living.attack_animal(src)
		COOLDOWN_START(src, melee_cooldown, CLICK_CD_MELEE)

		if(isalien(target_living))
			var/extra_damage = rand(melee_damage_lower, melee_damage_upper) * 0.33
			target_living.apply_damage(extra_damage, BRUTE)

		if(prob(33))
			if(client && !is_retreating)
				is_retreating = TRUE
				to_chat(src, span_userdanger("Рефлекс \"бей или беги\" срабатывает — бегите!"))
				speed = LIZARD_SPEED_RETREAT_CLIENT
				addtimer(VARSET_CALLBACK(src, speed, LIZARD_SPEED_NORMAL_CLIENT), 2 SECONDS)
				addtimer(VARSET_CALLBACK(src, is_retreating, FALSE), 2 SECONDS)
			else
				// After skirmish retreat, lizard does NOT return to combat — it calms down
				MoveTo(target_living, 8, TRUE, 2 SECONDS, FALSE)
		return target_living

	if(client && !is_eating && istype(inherited_target, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/food_snack = inherited_target
		handle_food_client(food_snack)
		return

	inherited_target.attack_animal(src)

/mob/living/simple_animal/hostile/giant_lizard/OnUnarmedAttack(atom/attacked_atom, proximity_flag, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		pounce(attacked_atom)
		return

	var/tile_attack = FALSE
	if(attacked_atom == src)
		attacked_atom = get_turf(src)
		tile_attack = TRUE

	if(tile_attack && isturf(attacked_atom))
		var/turf/our_turf = attacked_atom
		for(var/mob/living/possible_target in our_turf)
			if(possible_target == src)
				continue
			attacked_atom = possible_target
			break

	AttackingTarget(attacked_atom)

/mob/living/simple_animal/hostile/giant_lizard/DestroySurroundings()
	. = ..()
	for(var/obj/structure/obstacle in view(1, src))
		if(is_type_in_list(obstacle, string_list(list(
			/obj/structure/window,
			/obj/structure/closet,
			/obj/structure/table,
			/obj/structure/grille,
			/obj/structure/barricade,
		))))
			AttackingTarget(obstacle)
			return .
	return .

/mob/living/simple_animal/hostile/giant_lizard/resist_fire()
	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] отчаянно катается по земле, пытаясь потушить себя!"))
	adjust_fire_stacks(-10)
	Knockdown(2)
	Stun(2)

///Furious Attack — used against a prone or grappled target.
/mob/living/simple_animal/hostile/giant_lizard/proc/ravagingattack(mob/living/target_living)
	if(is_ravaging || !isliving(target_living))
		return
	is_ravaging = TRUE
	visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] яростно терзает [target_living.declent_ru(ACCUSATIVE)]!"))

	for(var/times_to_attack = 3, times_to_attack > 0, times_to_attack--)
		if(body_position == LYING_DOWN)
			is_ravaging = FALSE
			return

		if(Adjacent(target_living))
			var/damage = rand(melee_damage_lower, melee_damage_upper) * 0.4
			if(isalien(target_living))
				damage *= 1.33
			var/attack_type = pick(LIZARD_ATTACK_SLASH, LIZARD_ATTACK_BITE)
			if(attack_type)
				attacktext = "царапает"
				playsound(loc, 'sound/weapons/slash.ogg', 25, 1)
			else
				attacktext = "кусает"
				playsound(loc, 'sound/weapons/bite.ogg', 25, 1)

			if(target_living.body_position == LYING_DOWN)
				target_living.apply_damage(damage, BRUTE)
				target_living.apply_effect(1, DROWSY)
				shake_camera(target_living, 1, 2)

			do_attack_animation(target_living)
			face_atom(target_living)
			sleep(0.5 SECONDS)
	is_ravaging = FALSE

// MARK: Pounce
/mob/living/simple_animal/hostile/giant_lizard/proc/pounce(atom/pounce_target)
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_INCAPACITATED) || HAS_TRAIT(src, TRAIT_FLOORED))
		return
	if(!COOLDOWN_FINISHED(src, pounce_cooldown))
		return

	COOLDOWN_START(src, pounce_cooldown, pounce_cooldown_length)
	var/pounce_distance = clamp(get_dist(src, pounce_target), 1, 5)
	custom_emote(message = "прыгает на [pounce_target.declent_ru(ACCUSATIVE)]!")
	is_pouncing = TRUE
	INVOKE_ASYNC(src, PROC_REF(do_pounce), pounce_target, pounce_distance)

/mob/living/simple_animal/hostile/giant_lizard/proc/do_pounce(atom/pounce_target, pounce_distance)
	throw_at(pounce_target, pounce_distance, 2, src, FALSE)

/mob/living/simple_animal/hostile/giant_lizard/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!is_pouncing)
		return ..()
	is_pouncing = FALSE
	if(isliving(hit_atom))
		var/mob/living/pounced_target_living = hit_atom
		pounced_mob(pounced_target_living)
		return
	if(isturf(hit_atom))
		var/turf/pounced_target_turf = hit_atom
		pounced_turf(pounced_target_turf)
		return
	if(isobj(hit_atom))
		var/obj/pounced_target_obj = hit_atom
		pounced_obj(pounced_target_obj)
		return
	return ..()

/mob/living/simple_animal/hostile/giant_lizard/proc/reverse_nearby_direction(check_dir)
	var/opposite = turn(check_dir, 180)
	return list(opposite, turn(opposite, 45), turn(opposite, -45))

/mob/living/simple_animal/hostile/giant_lizard/proc/pounced_mob(mob/living/pounced_target)
	if(stat == DEAD || pounced_target.stat == DEAD || pounced_target.mob_size >= MOB_SIZE_LARGE || pounced_target == src)
		return

	if(ishuman(pounced_target) && (pounced_target.dir in reverse_nearby_direction(dir)))
		var/mob/living/carbon/human/human_mob = pounced_target
		if(human_mob.check_shields(src, 0, "прыжок", attack_type = THROWN_PROJECTILE_ATTACK))
			Knockdown(1)
			Stun(1)
			playsound(human_mob, 'sound/effects/meteorimpact.ogg', 75, FALSE)
			return

	playsound(loc, 'sound/effects/giant_lizard_hiss1.ogg', 25)
	pounced_target.Knockdown(0.5)
	step_towards(src, pounced_target)
	if(!client && !faction_check_mob(pounced_target))
		ravagingattack(pounced_target)

/mob/living/simple_animal/hostile/giant_lizard/proc/pounced_turf(turf/turf_target)
	if(turf_target.density)
		return
	for(var/mob/living/pounced_target in turf_target)
		pounced_mob(pounced_target)
		return

/mob/living/simple_animal/hostile/giant_lizard/proc/pounced_obj(obj/pounced_target)
	if(stat != CONSCIOUS)
		return

	if(!istable(pounced_target))
		pounced_target.hitby(src)

///Ranged right click is dispatched here, adjacent right click arrives through OnUnarmedAttack() with RIGHT_CLICK.
/mob/living/simple_animal/hostile/giant_lizard/ranged_secondary_attack(atom/target, list/modifiers)
	if(!client)
		return ..()
	pounce(target)
	return TRUE

// MARK: Food and taming
/mob/living/simple_animal/hostile/giant_lizard/proc/handle_food(obj/item/reagent_containers/food/snacks/food)
	visible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] начинает грызть [food.declent_ru(ACCUSATIVE)].")
	is_eating = TRUE
	for(var/times_to_eat = rand(4, 6), times_to_eat--)
		sleep(rand(1, 3) SECONDS)
		if(check_food_loc(food) || stance > LIZARD_STANCE_ALERT || stat == DEAD)
			return
		face_atom(food)
		playsound(loc, 'sound/items/eatfood.ogg', 25, 1)

///No last_dropped_by field in 1984, so the nearest non-hostile mob present is credited with the feeding.
	for(var/mob/living/carbon/nearest_mob in view(7, src))
		if(faction_check_mob(nearest_mob) || nearest_mob.stat != CONSCIOUS)
			continue
		face_atom(nearest_mob)
		visible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] смотрит на [nearest_mob.declent_ru(ACCUSATIVE)].")
		if(tame)
			break
		if(prob(tame_chance))
			tame = TRUE
			tamed(nearest_mob)
		else
			tame_chance += bonus_tame_chance
		break

	health += maxHealth * 0.15
	update_wounds()
	qdel(food)
	food_target = null
	is_eating = FALSE
	stance = LIZARD_STANCE_IDLE
	COOLDOWN_START(src, food_cooldown, 30 SECONDS)

/mob/living/simple_animal/hostile/giant_lizard/proc/handle_food_client(obj/item/reagent_containers/food/snacks/food)
	visible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] начинает грызть [food.declent_ru(ACCUSATIVE)].")
	playsound(loc, 'sound/items/eatfood.ogg', 25, 1)
	is_eating = TRUE
	if(!do_after(src, 4 SECONDS, src, DA_IGNORE_USER_LOC_CHANGE|DA_IGNORE_LYING|DA_IGNORE_HELD_ITEM, max_interact_count = 1))
		is_eating = FALSE
		return

	is_eating = FALSE
	if(!Adjacent(food))
		return

	playsound(loc, 'sound/items/eatfood.ogg', 25, 1)
	health += maxHealth * 0.10
	update_wounds()
	qdel(food)
	food_target = null
	stance = LIZARD_STANCE_IDLE
	COOLDOWN_START(src, food_cooldown, 15 SECONDS)

///Checks if anyone has taken our food.
/mob/living/simple_animal/hostile/giant_lizard/proc/check_food_loc(obj/food)
	if(!ismob(food.loc))
		return FALSE

	var/mob/living/food_holder = food.loc
	stop_moving()
	COOLDOWN_START(src, food_cooldown, 15 SECONDS)
	food_target = null
	is_eating = FALSE
	if(get_dist(src, food_holder) <= 2 && !faction_check_mob(food_holder))
		Retaliate()
		return TRUE

	growl(food.loc)
	stance = LIZARD_STANCE_IDLE
	return TRUE

/mob/living/simple_animal/hostile/giant_lizard/proc/lose_food()
	stance = LIZARD_STANCE_IDLE
	food_target = null
	is_eating = FALSE
	COOLDOWN_START(src, food_cooldown, 15 SECONDS)

// MARK: Emotes
/datum/emote/living/giant_lizard
	mob_type_allowed_typecache = list(/mob/living/simple_animal/hostile/giant_lizard)

/datum/emote/living/giant_lizard/growl
	name = "Рычать"
	key = "growl"
	message = "рыч%(ит,ат)%."
	sound = 'sound/effects/giant_lizard_growl1.ogg'
	emote_type = EMOTE_AUDIBLE|EMOTE_VISIBLE

/datum/emote/living/giant_lizard/hiss
	name = "Шипеть"
	key = "hiss"
	message = "шип%(ит,ят)%."
	sound = 'sound/effects/giant_lizard_hiss1.ogg'
	emote_type = EMOTE_AUDIBLE|EMOTE_VISIBLE

/datum/emote/living/giant_lizard/flicktongue
	name = "Язык"
	key = "flicktongue"
	message = null

/datum/emote/living/giant_lizard/flicktongue/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/giant_lizard/lizard_user = user
	if(!istype(lizard_user) || !lizard_user.tongue_icon_holder)
		return
	flick("Giant Lizard Tongue", lizard_user.tongue_icon_holder)

#undef LIZARD_ATTACK_SLASH
#undef LIZARD_ATTACK_BITE
#undef LIZARD_SPEED_NORMAL
#undef LIZARD_SPEED_RETREAT
#undef LIZARD_SPEED_NORMAL_CLIENT
#undef LIZARD_SPEED_RETREAT_CLIENT
#undef LIZARD_STANCE_IDLE
#undef LIZARD_STANCE_ALERT
#undef LIZARD_STANCE_ATTACKING
#undef LIZARD_WOUNDS_NONE
#undef LIZARD_WOUNDS_SMALL
#undef LIZARD_WOUNDS_BIG
