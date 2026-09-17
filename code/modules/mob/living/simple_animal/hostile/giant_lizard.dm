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
	nightvision = 12

	speak_emote = list("шипит")
	emote_hear = list("шипит.", "рычит.")
	emote_see = list("мотает головой.", "виляет хвостом.", "зевает.", "облизывает глазное яблоко.")

	melee_damage_lower = 15
	melee_damage_upper = 30
	obj_damage = 10
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attack_same = FALSE
	///Only fights back after being attacked: the parent hostile AI handles enemy tracking,
	///line of sight and sharing enemies with the pack.
	retaliate_only = TRUE
	//The parent ListTargets() works off vision_range, so it has to cover max_attack_distance.
	vision_range = 16
	aggro_vision_range = 16

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
	///Structures that the lizard can break.
	var/list/destruction_targets = list(
		/obj/structure/window,
		/obj/structure/closet,
		/obj/structure/table,
		/obj/structure/grille,
		/obj/structure/barricade,
	)

	var/list/pet_emotes = list("довольно рычит.", "виляет хвостом.")
	COOLDOWN_DECLARE(emote_cooldown)
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

/mob/living/simple_animal/hostile/giant_lizard/proc/change_tongue_offset(datum/source, olddir, newdir)
	SIGNAL_HANDLER

	if(!newdir)
		newdir = dir

	switch(newdir)
		if(WEST)
			if(resting)
				tongue_icon_holder.pixel_x = 25
				tongue_icon_holder.pixel_y = -4
				return

			tongue_icon_holder.pixel_x = -28
			tongue_icon_holder.pixel_y = 0

		if(EAST)
			if(resting)
				tongue_icon_holder.pixel_x = -25
				tongue_icon_holder.pixel_y = -4
				return

			tongue_icon_holder.pixel_x = 28
			tongue_icon_holder.pixel_y = 0
		if(SOUTH)
			tongue_icon_holder.pixel_x = 0
			tongue_icon_holder.pixel_y = 0

/mob/living/simple_animal/hostile/giant_lizard/keybind_face_direction(direction)
	if(resting && (direction == NORTH || direction == SOUTH))
		return
	return ..()

/mob/living/simple_animal/hostile/giant_lizard/proc/growl(atom/target_mob, ignore_cooldown = FALSE)
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
	//Simple animals only carry CANPUSH in status_flags, and check_incapacitating_immunity() blocks
	//anything without the matching flag, so Stun()/Knockdown()/Weaken() are no-ops for them. The
	//"Giant Lizard Knocked Down" sprite state was therefore unreachable and has been removed.
	//The tongue overlay has no lying-down sprite, so it is hidden while the lizard is on the ground.
	if(tongue_icon_holder)
		tongue_icon_holder.alpha = (body_position == LYING_DOWN || stat == DEAD) ? 0 : alpha
	update_wounds()
	change_tongue_offset()
	//The parent proc also refreshes the collar overlays and the fire overlay.
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
	return ..()

/mob/living/simple_animal/hostile/giant_lizard/Destroy()
	GLOB.giant_lizards_alive -= src
	vis_contents -= wound_icon_holder
	vis_contents -= tongue_icon_holder
	QDEL_NULL(wound_icon_holder)
	QDEL_NULL(tongue_icon_holder)
	food_target = null
	return ..()
///Reaction to being hurt. Retaliate() itself is triggered by the parent adjustHealth()
///because retaliate_only is set, so it is not called manually here.
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

///Заставляет ящера выйти из боя и попытаться потушить себя. Не вызывается, если ящер уже отступает.
/*
 * NOTE (difference from CMSS13): the lizard no longer tries to put itself out.
 * 1984's adjust_fire_stacks() calls ExtinguishMob() the moment fire_stacks reaches 0, so the old
 * adjust_fire_stacks(-10) wiped the entire burn stack in one go. Now it just flees while burning
 * and handle_fire() drains fire_stacks naturally. resist_fire() is kept as the manual
 * "stop, drop and roll" action (the resist verb / fire alert click).
 */
/mob/living/simple_animal/hostile/giant_lizard/proc/flee_from_fire()
	if(is_retreating || !on_fire || client || stat == DEAD || body_position == LYING_DOWN)
		return

	//Забываем ВСЁ. Нам нужно остановить пламя!
	stance = LIZARD_STANCE_ALERT
	GiveTarget(null)
	food_target = null
	is_eating = FALSE
	custom_emote(message = "шипит в агонии!")
	playsound(src, 'sound/effects/giant_lizard_hiss2.ogg', 40)
	MoveTo(null, 9, TRUE, 4 SECONDS, FALSE)
	COOLDOWN_START(src, calm_cooldown, 8 SECONDS)

/mob/living/simple_animal/hostile/giant_lizard/IgniteMob()
	. = ..()
	if(on_fire)
		flee_from_fire()

/mob/living/simple_animal/hostile/giant_lizard/handle_fire()
	. = ..()
	if(on_fire)
		flee_from_fire()

/*
 * Отличие от CMSS13: там Life(delta_time), здесь Life(seconds, times_fired).
 * Также убран хак SetKnockOut(0)/SetStun(0)/SetKnockDown(0) — в 1984 нет CM-овской
 * машины стансов, которая ломалась при оглушении посреди боя, а AI восстанавливается сам.
 */
/mob/living/simple_animal/hostile/giant_lizard/Life(seconds, times_fired)
	if(aggression_value > 0)
		aggression_value--

	//Ящер мог сохранить цель, оставшись в режиме ожидания, и никогда её не потерять.
	//Тогда он будет парализован и ничего не сделает до конца жизни, поэтому нужна эта проверка.
	var/mob/living/target_mob = isliving(target) ? target : null
	if(!client && stance == LIZARD_STANCE_ALERT && target_mob && !is_retreating && !on_fire)
		GiveTarget(FindTarget())
		MoveToTarget()

	if(resting && stat != DEAD)
		health += maxHealth * 0.05
		update_wounds()

	if(stat != DEAD && !HAS_TRAIT(src, TRAIT_INCAPACITATED) && !HAS_TRAIT(src, TRAIT_FLOORED) && prob(25))
		flick("Giant Lizard Tongue", tongue_icon_holder)

	if(bleed_ticks)
		var/is_small_pool = bleed_ticks < 10
		bleed_ticks--
		add_splatter_floor(loc, is_small_pool)

	//Делается до вызова родителя, иначе ящер начнёт двигаться раньше, чем ляжет отдыхать.
	if(stance == LIZARD_STANCE_IDLE && !client)
		stop_automated_movement = FALSE
		//Если рядом на том же тайле друг — не встаём (мило же!)
		var/mob/living/carbon/friend = locate(/mob/living/carbon) in get_turf(src)
		if(friend && faction_check_mob(friend) && resting)
			chance_to_rest = 0

		if(prob(chance_to_rest))
			set_resting(!resting)
			chance_to_rest = 0

		chance_to_rest += rand(1, 2)

	. = ..()

	if(client)
		return .

	//Если нас давно не били, успокаиваемся и возвращаемся в режим ожидания.
	if(aggression_value == 0 && stance == LIZARD_STANCE_ATTACKING)
		enemies = list()
		lose_target()
		stance = LIZARD_STANCE_IDLE
		if(COOLDOWN_FINISHED(src, emote_cooldown))
			custom_emote(message = "успокаивается.")
			COOLDOWN_START(src, calm_cooldown, 4 SECONDS)
			COOLDOWN_START(src, emote_cooldown, 3 SECONDS)

	//В бою еда нас больше не интересует.
	if(stance > LIZARD_STANCE_ALERT)
		is_eating = FALSE

	//Если мы отдыхали, а что-то привлекло наше внимание — встаём.
	if(stance != LIZARD_STANCE_IDLE && resting)
		set_resting(FALSE)

	if(target_mob && !is_retreating && target_mob.stat == CONSCIOUS && stance == LIZARD_STANCE_ATTACKING && COOLDOWN_FINISHED(src, pounce_cooldown) && (prob(75) || get_dist(src, target_mob) <= 5) && (target_mob in view(5, src)))
		pounce(target_mob)

	//Если мы пытаемся убежать и вокруг препятствия — ломаем их.
	if(target_mob && is_retreating && stance >= LIZARD_STANCE_ALERT && environment_smash)
		INVOKE_ASYNC(src, PROC_REF(DestroySurroundings))

	if(target_mob || on_fire)
		return .

	//Если мы отступаем, но цели нет и мы не горим — прекращаем отступать.
	if(is_retreating)
		stop_moving()
		stance = LIZARD_STANCE_IDLE

	//Если мы голодны и ещё не присмотрели себе снек — ищем еду.
	if(tameable && !food_target && COOLDOWN_FINISHED(src, food_cooldown))
		for(var/obj/item/reagent_containers/food/snacks/food in view(6, src))
			var/is_meat = locate(/datum/reagent/consumable/nutriment/protein) in food.reagents.reagent_list

			if(is_meat || is_type_in_list(food, food_type))
				food_target = food
				if(QDELETED(food_target)) // не удалился ли он за время поиска?
					food_target = null
					continue
				stance = LIZARD_STANCE_ALERT
				stop_automated_movement = TRUE
				MoveTo(food_target)
				break

	//Разбираемся с мобами, вторгшимися в наше личное пространство.
	if(stance <= LIZARD_STANCE_ALERT && !food_target && COOLDOWN_FINISHED(src, calm_cooldown))
		var/intruder_in_sight = FALSE
		for(var/mob/living/carbon/intruder in view(max_growl_distance + 2, src))
			if(faction_check_mob(intruder) || intruder.stat != CONSCIOUS || ismonkey(intruder) || intruder.alpha <= 200)
				continue

			intruder_in_sight = TRUE
			face_atom(intruder)
			stance = LIZARD_STANCE_ALERT
			stop_automated_movement = TRUE
			var/intruder_distance = get_dist(src, intruder)
			if(intruder_distance <= max_retaliate_distance)
				Retaliate()
				COOLDOWN_START(src, pounce_cooldown, 1 SECONDS)
				break
			if(intruder_distance <= max_growl_distance)
				growl(intruder)

		if(!intruder_in_sight && stance == LIZARD_STANCE_ALERT)
			stance = LIZARD_STANCE_IDLE

	//Если у нас есть снек, который мы хотим съесть, но пока не жуём — проверяем, близко ли он.
	var/obj/item/reagent_containers/food/snacks/wanted_food = food_target
	if(wanted_food && !is_eating)
		if(!(wanted_food in view(5, src)))
			stop_moving()
			lose_food()
		//Если еда рядом с нами И не в руках моба — начинаем есть.
		else if(!check_food_loc(wanted_food) && Adjacent(wanted_food))
			INVOKE_ASYNC(src, PROC_REF(handle_food), wanted_food)

	return .

/*
 * AI-ядро ящера.
 *
 * CM-овская машина стансов (HOSTILE_STANCE_*) переведена на локальный var/stance,
 * а захват цели идёт через штатные 1984-овские ListTargets()/CanAttack()/FindTarget().
 */

/mob/living/simple_animal/hostile/giant_lizard/handle_automated_action()
	if(AIStatus == AI_OFF || QDELETED(src))
		return FALSE
	//Мобом управляет игрок, либо он мёртв — поведение AI не нужно.
	if(client || stat == DEAD)
		return TRUE
	//Пока ящер отступает или ест, обычное преследование не работает.
	if(is_retreating || is_eating)
		return TRUE
	if(stance != LIZARD_STANCE_ATTACKING)
		return TRUE

	var/mob/living/target_mob = isliving(target) ? target : null
	if(!target_mob || !can_keep_target(target_mob))
		GiveTarget(null)
		stance = LIZARD_STANCE_IDLE
		return TRUE
	//Порог потери цели больше, чем у обычных мобов — ящеру нужна дистанция для манёвров.
	if(get_dist(src, target_mob) > max_attack_distance)
		GiveTarget(null)
		stance = LIZARD_STANCE_IDLE
		return TRUE
	if(in_range(src, target_mob))
		//Go through the parent's melee path (rapid_melee / GainPatience), exactly like regular hostiles.
		MeleeAction()
		return TRUE
	MoveToTarget()
	return TRUE

///Может ли ящер продолжать считать этого моба целью?
///Заменяет CM-овские SA_attackable() и evaluate_target().
/mob/living/simple_animal/hostile/giant_lizard/proc/can_keep_target(mob/living/target_mob)
	if(!isliving(target_mob))
		return FALSE
	//Мобы в критическом состоянии — законная добыча, а мёртвые/невидимые/не на тайле — нет.
	if(target_mob.stat == DEAD || target_mob.alpha <= 200 || !isturf(target_mob.loc))
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/giant_lizard/CanAttack(atom/the_target)
	//Обезьян не трогаем — иначе ящер вырежет всех мелких хозяев станции.
	if(ismonkey(the_target))
		return FALSE
	return ..()

//Заменяет walk_to() на GLOB.move_manager.
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

/*
 * Немедленная ответная агрессия после получения урона.
 *
 * Отличие от CMSS13: там был параметр pack_attack, чтобы члены стаи не будили друг друга
 * рекурсивно. Здесь вместо отдельного прока обходимся без параметра: alert_others() пропускает
 * тех, у кого уже есть цель, поэтому рекурсия сама себя обрывает. Вызов ..() ниже — это вызов
 * родительского /mob/living/simple_animal/hostile(), который наполняет enemies
 * и раздаёт их союзникам по фракции.
 */
/mob/living/simple_animal/hostile/giant_lizard/Retaliate()
	if(stat == DEAD || on_fire)
		return
	var/mob/living/current_target = isliving(target) ? target : null
	//Уже вплотную к цели — не тратим время на рычание и поиск.
	if(current_target && get_dist(src, current_target) < 6)
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

///Будит ближайших членов стаи, чтобы они тоже вступили в бой.
/mob/living/simple_animal/hostile/giant_lizard/proc/alert_others()
	for(var/mob/living/simple_animal/hostile/giant_lizard/pack_member as anything in GLOB.giant_lizards_alive)
		if(pack_member == src || pack_member.client || isliving(pack_member.target) || get_dist(src, pack_member) > 7)
			continue
		pack_member.Retaliate()

//Процедура для перемещения к цели. GLOB.move_manager не проверяет отдых и статусные эффекты, поэтому проверяем сами.
/mob/living/simple_animal/hostile/giant_lizard/proc/MoveTo(atom/move_target, distance = 1, retreat = FALSE, time = 6 SECONDS, return_to_combat = FALSE)
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_INCAPACITATED) || HAS_TRAIT(src, TRAIT_FLOORED))
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

//Процедура, вызываемая по завершении отступления.
/mob/living/simple_animal/hostile/giant_lizard/proc/stop_retreat(return_to_combat = FALSE)
	is_retreating = FALSE
	//Тушение — приоритет номер один.
	if(on_fire)
		flee_from_fire()
		return
	if(return_to_combat)
		GiveTarget(FindTarget())
		MoveToTarget()
		return
	//Не можем отступить? Возвращаемся в бой.
	if(retreat_attempts >= 2)
		GiveTarget(FindTarget())
		MoveToTarget()
		retreat_attempts = 0
		//Похоже, ситуация «жизнь или смерть». Прекращаем попытки убежать.
		COOLDOWN_START(src, retreat_cooldown, 20 SECONDS)
		return
	//Не прекращаем отступать, если в поле зрения есть недружественные углеродные формы жизни.
	for(var/mob/living/carbon/hostile_mob in view(7, src))
		if(faction_check_mob(hostile_mob))
			continue
		MoveTo(hostile_mob, 10, TRUE, 2 SECONDS, FALSE)
		retreat_attempts++
		return
	retreat_attempts = 0
	lose_target()

/*
 * Атаки ящера.
 *
 * Отличие от CMSS13: AttackingTarget() получает опциональную цель, так как 1984 вызывает
 * его без аргументов (используя var/target), а DestroySurroundings() — с конкретным объектом.
 */
/mob/living/simple_animal/hostile/giant_lizard/AttackingTarget(atom/inherited_target = null)
	if(!inherited_target)
		inherited_target = target
	if(!inherited_target || !Adjacent(inherited_target) || is_ravaging || body_position == LYING_DOWN)
		return

	if(isliving(inherited_target))
		var/mob/living/target_living = inherited_target
		//Pounced/lying targets get mauled instead of taking a normal hit.
		if(target_living.body_position == LYING_DOWN)
			ravagingattack(target_living)
			return target_living

		var/attack_type = pick(LIZARD_ATTACK_SLASH, LIZARD_ATTACK_BITE)
		attacktext = attack_type ? "царапает" : "кусает"
		attack_sound = attack_type ? 'sound/weapons/slash.ogg' : 'sound/weapons/bite.ogg'
		//attack_animal() already does face_atom(), do_attack_animation(), attack_sound, the visible_message
		//and the damage roll - we only drive the native vars instead of duplicating all of it.
		target_living.attack_animal(src)

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
				MoveTo(target_living, 8, TRUE, 2 SECONDS, TRUE)
		return target_living

	if(client && !is_eating && istype(inherited_target, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/food_snack = inherited_target
		handle_food_client(food_snack)
		return

	//Everything else goes through the native attack_animal() path: /obj/attack_animal() performs
	//do_attack_animation(), changeNext_move(CLICK_CD_MELEE) and take_damage() via attack_generic(),
	//while /atom/attack_animal() is a no-op - hence turfs cannot be attacked at all.
	inherited_target.attack_animal(src)

//Используется для атак, когда мобом управляет игрок. Иначе мы бы получили обычную атаку животного.
/*
 * NOTE (difference from CMSS13): this hooks OnUnarmedAttack() instead of UnarmedAttack().
 * /mob/proc/UnarmedAttack() is the proc that calls changeNext_move(CLICK_CD_MELEE); overriding it
 * (and never calling ..()) removed the melee cooldown entirely. Hooking OnUnarmedAttack() keeps
 * the cooldown and follows the same attack path as regular /mob/living/simple_animal/hostile mobs.
 */
/mob/living/simple_animal/hostile/giant_lizard/OnUnarmedAttack(atom/attacked_atom, proximity_flag, list/modifiers)
	//Right mouse button: pounce instead of a normal attack.
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		pounce(attacked_atom)
		return

	var/tile_attack = FALSE
	if(attacked_atom == src) //Клик по себе.
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

/*
 * Отличие от CMSS13: там был break_stuff_probability и свой список с шансом.
 * Здесь мы опираемся на environment_smash и штатный DestroySurroundings(), а затем
 * дополнительно бьём по структурам из destruction_targets, которые видим рядом.
 */
/mob/living/simple_animal/hostile/giant_lizard/DestroySurroundings()
	. = ..()
	for(var/obj/structure/obstacle in view(1, src))
		if(is_type_in_list(obstacle, destruction_targets))
			AttackingTarget(obstacle)
			return .
	return .

/mob/living/simple_animal/hostile/giant_lizard/resist_fire()
	visible_message(span_notice("[src] отчаянно катается по земле, пытаясь потушить себя!"))
	adjust_fire_stacks(-10)
	Knockdown(2)
	Stun(2)

///Яростная атака — применяется к поваленной или схваченной цели.
/mob/living/simple_animal/hostile/giant_lizard/proc/ravagingattack(mob/living/target_living)
	if(is_ravaging || !isliving(target_living))
		return
	is_ravaging = TRUE
	visible_message(span_danger("<B>[src]</B> яростно терзает [target_living.declent_ru(ACCUSATIVE)]!"))

	var/successful_attacks = 0
	for(var/times_to_attack = 3, times_to_attack > 0, times_to_attack--)
		//Нас оглушили — значит, больше не можем терзать.
		if(body_position == LYING_DOWN)
			is_ravaging = FALSE
			return

		if(Adjacent(target_living))
			var/damage = rand(melee_damage_lower, melee_damage_upper) * 0.4
			//Ксеносы получают повышенный урон.
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
				//Отличие от CMSS13: там применялся DAZE, которого в 1984 нет.
				target_living.apply_effect(1, DROWSY)
				shake_camera(target_living, 1, 2)

			do_attack_animation(target_living)
			face_atom(target_living)
			sleep(0.5 SECONDS)
			successful_attacks++

	if(successful_attacks == 3 && !COOLDOWN_FINISHED(src, pounce_cooldown))
		to_chat(src, span_boldwarning("Кровожадность придаёт вам сил! Вы будете готовы прыгнуть намного раньше."))
		COOLDOWN_START(src, pounce_cooldown, COOLDOWN_TIMELEFT(src, pounce_cooldown) * 0.5)
	is_ravaging = FALSE

//ПРОЦЕДУРЫ ПРЫЖКА
//////////////////

/mob/living/simple_animal/hostile/giant_lizard/proc/pounce(atom/pounce_target)
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_INCAPACITATED) || HAS_TRAIT(src, TRAIT_FLOORED))
		return
	if(!COOLDOWN_FINISHED(src, pounce_cooldown))
		to_chat(src, span_warning("Вы не можете прыгнуть так быстро! Нужно подождать [round(COOLDOWN_TIMELEFT(src, pounce_cooldown) / 10, 1)] сек."))
		return

	COOLDOWN_START(src, pounce_cooldown, pounce_cooldown_length)
	var/pounce_distance = clamp(get_dist(src, pounce_target), 1, 5)
	custom_emote(message = "прыгает на [pounce_target.declent_ru(ACCUSATIVE)]!")
	is_pouncing = TRUE
	//Отличие от CMSS13: там был throw_atom() с колбэками pounce_callbacks.
	//В 1984 колбэков нет, поэтому мы переопределяем throw_impact().
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

///Возвращает направления, «смотрящие» навстречу указанному (само плюс соседние по 45°).
///Заменяет CM-овский reverse_nearby_direction().
/mob/living/simple_animal/hostile/giant_lizard/proc/reverse_nearby_direction(check_dir)
	var/opposite = turn(check_dir, 180)
	return list(opposite, turn(opposite, 45), turn(opposite, -45))

/*
 * Отличие от CMSS13: убраны блоки с isyautja() (body slam) и TRAIT_POUNCE_RESISTANT —
 * ни яутжа, ни этого трейта в 1984 нет. Блок щита переведён на 1984-овский check_shields().
 */
/mob/living/simple_animal/hostile/giant_lizard/proc/pounced_mob(mob/living/pounced_target)
	if(stat == DEAD || pounced_target.stat == DEAD || pounced_target.mob_size >= MOB_SIZE_LARGE || pounced_target == src)
		return

	if(ishuman(pounced_target) && (pounced_target.dir in reverse_nearby_direction(dir)))
		var/mob/living/carbon/human/human_mob = pounced_target
		//Блок щитом или парированием.
		if(human_mob.check_shields(src, 0, "прыжок", attack_type = THROWN_PROJECTILE_ATTACK))
			visible_message(span_danger("[src] врезается в [human_mob.declent_ru(ACCUSATIVE)]!"))
			Knockdown(1)
			Stun(1)
			playsound(human_mob, 'sound/effects/meteorimpact.ogg', 75, FALSE)
			return

	playsound(loc, 'sound/effects/giant_lizard_hiss1.ogg', 25)
	pounced_target.Knockdown(0.5)
	step_towards(src, pounced_target)
	if(!client && !faction_check_mob(pounced_target))
		ravagingattack(pounced_target)

//Отличие от CMSS13: там для плотных тайлов вызывался turf_launch_collision(), которого в 1984 нет.
/mob/living/simple_animal/hostile/giant_lizard/proc/pounced_turf(turf/turf_target)
	if(turf_target.density)
		return
	for(var/mob/living/pounced_target in turf_target)
		pounced_mob(pounced_target)
		return

/mob/living/simple_animal/hostile/giant_lizard/proc/pounced_obj(obj/pounced_target)
	// Без сознания или мёртв, или не в процессе прыжка.
	if(stat != CONSCIOUS)
		return

	if(!istype(pounced_target, /obj/structure/table) && !istype(pounced_target, /obj/structure/rack))
		pounced_target.hitby(src) //Это сбрасывает состояние броска.

/*
 * Pounce is bound to the right mouse button.
 *
 * A ranged right click is dispatched here by /mob/proc/ClickOn ("Useful for mobs that have their
 * abilities mapped to right click"), while an adjacent right click arrives through
 * OnUnarmedAttack() with RIGHT_CLICK in the modifiers list. Shift+left click is deliberately NOT
 * used anymore - it is reserved for examining.
 */
/mob/living/simple_animal/hostile/giant_lizard/ranged_secondary_attack(atom/target, list/modifiers)
	if(!client)
		return ..()
	pounce(target)
	return TRUE

//ПРОЦЕДУРЫ ЕДЫ И ПРИРУЧЕНИЯ
////////////////////////////

///Процедура, вызываемая, когда ящер находит еду и начинает её ПОЖИРАТЬ.
/mob/living/simple_animal/hostile/giant_lizard/proc/handle_food(obj/item/reagent_containers/food/snacks/food)
	visible_message("[src] начинает грызть [food.declent_ru(ACCUSATIVE)].")
	is_eating = TRUE
	for(var/times_to_eat = rand(4, 6), times_to_eat--)
		sleep(rand(1.7, 2.5) SECONDS)
		if(check_food_loc(food) || stance > LIZARD_STANCE_ALERT || stat == DEAD)
			return
		face_atom(food)
		playsound(loc, 'sound/items/eatfood.ogg', 25, 1)

	/*
	 * Отличие от CMSS13: там приручение было привязано к food.last_dropped_by (тот, кто уронил еду).
	 * В 1984 такого поля у предметов нет, поэтому ящер признаёт другом ближайшего не-врага,
	 * который присутствовал при кормлении.
	 */
	for(var/mob/living/carbon/nearest_mob in view(7, src))
		if(faction_check_mob(nearest_mob) || nearest_mob.stat != CONSCIOUS)
			continue
		face_atom(nearest_mob)
		visible_message("[src] смотрит на [nearest_mob.declent_ru(ACCUSATIVE)].")
		//Taming is not guaranteed: repeated feedings raise the odds via bonus_tame_chance.
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
	visible_message("[src] начинает грызть [food.declent_ru(ACCUSATIVE)].")
	playsound(loc, 'sound/items/eatfood.ogg', 25, 1)
	is_eating = TRUE
	//Отличие от CMSS13: вместо CM-овских INTERRUPT_ALL|BEHAVIOR_IMMOBILE и BUSY_ICON_FRIENDLY — флаги DA_*.
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

///Проверяет, не забрал ли кто-нибудь нашу еду.
/mob/living/simple_animal/hostile/giant_lizard/proc/check_food_loc(obj/food)
	if(!ismob(food.loc))
		return FALSE

	var/mob/living/food_holder = food.loc
	stop_moving()
	COOLDOWN_START(src, food_cooldown, 15 SECONDS)
	food_target = null
	is_eating = FALSE
	//Стащить еду прямо у нас из-под носа — очень злит.
	if(get_dist(src, food_holder) <= 2 && !faction_check_mob(food_holder))
		Retaliate()
		return TRUE

	growl(food.loc)
	stance = LIZARD_STANCE_IDLE
	return TRUE

///Процедура для потери цели-еды.
/mob/living/simple_animal/hostile/giant_lizard/proc/lose_food()
	stance = LIZARD_STANCE_IDLE
	food_target = null
	is_eating = FALSE
	COOLDOWN_START(src, food_cooldown, 15 SECONDS)

//ЭМОЦИИ ИГРОКА
////////////////
/datum/emote/living/giant_lizard
	mob_type_allowed_typecache = list(/mob/living/simple_animal/hostile/giant_lizard)

/datum/emote/living/giant_lizard/growl
	key = "growl"
	message = "рыч%(ит,ат)%."
	sound = 'sound/effects/giant_lizard_growl1.ogg'
	emote_type = EMOTE_AUDIBLE|EMOTE_VISIBLE

/datum/emote/living/giant_lizard/hiss
	key = "hiss"
	message = "шип%(ит,ят)%."
	sound = 'sound/effects/giant_lizard_hiss1.ogg'
	emote_type = EMOTE_AUDIBLE|EMOTE_VISIBLE

/datum/emote/living/giant_lizard/flicktongue
	key = "flicktongue"
	message = null
	emote_type = EMOTE_VISIBLE

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
