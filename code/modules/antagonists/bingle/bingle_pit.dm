/obj/structure/bingle_hole
	name = "bingle pit"
	desc = "Всепоглощающая бездна бесконечных ужасов... и Бинглов."
	gender = FEMALE
	armor = list(MELEE = 20, BULLET = 20, LASER = 75, ENERGY = 75, BOMB = 75, BIO = 100, RAD = 100, FIRE = 50, ACID = 80)
	max_integrity = 500
	resistance_flags = FIRE_PROOF | UNACIDABLE
	icon = 'icons/mob/bingle/binglepit.dmi'
	icon_state = "bingle_pit-0"
	base_icon_state = "bingle_pit"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_BINGLE_PIT
	smoothing_groups = SMOOTH_GROUP_BINGLE_PIT
	light_color = LIGHT_COLOR_BABY_BLUE
	light_range = 5
	anchored = TRUE
	layer = PROJECTILE_HIT_THRESHOLD_LAYER
	/// The bingle pit turf reservation. Used for getting things in and out
	var/datum/turf_reservation/pit_reservation
	/// List of all bingle turfs used in pit reservation
	var/list/inside_pit_turfs = list()
	/// Values of all consumed items combined
	var/item_value_consumed = 0
	/// Last item_value_consumed value of pit grow
	var/last_grow_item_value = 0
	/// How many items are required right now to grow the pit by a size of 1
	var/grow_pit_value = BINGLE_PIT_GROW_VALUE
	/// Current pit size (1x1, 2x2, etc.)
	var/current_pit_size = 1
	/// List of all used pit overlays
	var/list/pit_overlays = list()
	/// Used to compare current and last item values for bingle spawning in processing
	var/last_bingle_spawn_value = 0
	/// We store the component in order to increase it's range later
	var/datum/component/aura_healing/aura_healing
	/// Antag team datum used for sending signals to
	var/datum/team/bingles/bingle_team
	/// Connect loc element
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_entered),
	)
	/// Cooldown for taking bomb damage - basically a cheat solution to handle it taking damage for each tile from one bomb.
	COOLDOWN_DECLARE(bomb_cooldown)
	/// Have we evolved our current bingles or not
	var/bingles_evolved

/obj/structure/bingle_hole/get_ru_names()
	return list(
		NOMINATIVE = "яма Бинглов",
		GENITIVE = "ямы Бинглов",
		DATIVE = "яме Бинглов",
		ACCUSATIVE = "яму Бинглов",
		INSTRUMENTAL = "ямой Бинглов",
		PREPOSITIONAL = "яме Бинглов"
	)

/obj/structure/bingle_hole/Initialize(mapload)
	..()
	bingle_team = GLOB.antagonist_teams[/datum/team/bingles]
	if(!bingle_team)
		bingle_team = new
	SEND_SIGNAL(bingle_team, COMSIG_BINGLE_HOLE_INITIALIZED, src)
	START_PROCESSING(SSbingle_pit, src)
	AddElement(/datum/element/connect_loc, loc_connections)
	return INITIALIZE_HINT_LATELOAD

/obj/structure/bingle_hole/ComponentInitialize()
	. = ..()
	aura_healing = AddComponent( \
		/datum/component/aura_healing, \
		range = 3, \
		simple_heal = 5, \
		limit_to_trait = TRAIT_HEALS_FROM_BINGLE_HOLES, \
		healing_color = COLOR_BLUE_LIGHT, \
		requires_visibility = FALSE, \
	)

/obj/structure/bingle_hole/LateInitialize()
	pit_reservation = SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_BINGLE_PIT, TRUE) // Separate insides for different holes
	log_game("Bingle Pit Template loaded.")

/obj/structure/bingle_hole/Destroy()
	QDEL_NULL(aura_healing)
	QDEL_LIST(pit_overlays)
	STOP_PROCESSING(SSbingle_pit, src)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(eject_bingle_pit_contents), get_turf(src), round(current_pit_size / 2), pit_reservation)
	bingle_team = null
	pit_reservation = null
	inside_pit_turfs = null
	return ..()

/obj/structure/bingle_hole/examine(mob/user)
	. = ..()
	if(!isbingle(user))
		return

	. += span_alert("Внутри находится <b>[item_value_consumed]</b> предмет[DECL_CREDIT(item_value_consumed)]!")
	. += span_notice("Существа смогут упасть туда, если в яме будет минимум <b>[BINGLE_PIT_GROW_VALUE]</b> предмет[declension_ru(BINGLE_PIT_GROW_VALUE, "", "а", "ов")]!")

/obj/structure/bingle_hole/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!pass_info.is_living)
		return TRUE
	if(isbingle(pass_info.requester_ref?.resolve()))
		return TRUE
	if(pass_info.thrown || pass_info.incorporeal_move)
		return TRUE
	if(!pass_info.incapacitated)
		if(!pass_info.gravity)
			return TRUE
		if(pass_info.movement_type & (FLYING | FLOATING))
			return TRUE
	return FALSE

/obj/structure/bingle_hole/attack_animal(mob/living/simple_animal/user)
	if(isbingle(user))
		to_chat(user, span_warning("Вы отказываетесь ломать ваше святилище!"))
		user.balloon_alert(user, "атака невозможна!")
		return TRUE
	return ..()

/obj/structure/bingle_hole/ex_act(severity)
	severity = min(severity, EXPLODE_HEAVY)
	if(!COOLDOWN_FINISHED(src, bomb_cooldown))
		return FALSE
	COOLDOWN_START(src, bomb_cooldown, 2 SECONDS)
	return ..()

/obj/structure/bingle_hole/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	swallow(arrived) // swallow does all the needed checks

/obj/structure/bingle_hole/process(seconds_per_tick)
	// Only spawn a new bingle for each BINGLE_SPAWN_VALUE item value milestone, and only once per milestone
	// Calculate how many bingles should exist based on current item value
	var/target_bingle_count = round(item_value_consumed / BINGLE_SPAWN_VALUE)
	var/current_bingle_count = round(last_bingle_spawn_value / BINGLE_SPAWN_VALUE)

	// If we need more bingles, spawn one
	if(target_bingle_count > current_bingle_count)
		last_bingle_spawn_value = target_bingle_count * BINGLE_SPAWN_VALUE
		INVOKE_ASYNC(src, PROC_REF(spawn_bingle_from_ghost))

	// No point in going further
	if(current_pit_size >= BINGLE_PIT_MAX_SIZE)
		return

	// If we dont have enough for at least one size grow, return
	var/non_used_item_value = item_value_consumed - last_grow_item_value
	if(non_used_item_value < grow_pit_value)
		return

	var/increase_size_counter = 0
	while((non_used_item_value - grow_pit_value) >= 0)
		increase_size_counter += 1
		last_grow_item_value += grow_pit_value
		non_used_item_value -= grow_pit_value
		grow_pit_value += BINGLE_PIT_ON_GROW_INCREASE_VALUE

	var/desired_pit_size = min(current_pit_size + increase_size_counter, BINGLE_PIT_MAX_SIZE)
	grow_pit(desired_pit_size)

	if(bingles_evolved)
		return

	if(item_value_consumed < BINGLE_EVOLVE_VALUE)
		return

	bingles_evolved = TRUE
	SEND_SIGNAL(bingle_team, COMSIG_MASS_BINGLE_EVOLVE, src)

/// Mob and objects falling into the hole procs are separated. This one is for mobs.
/obj/structure/bingle_hole/proc/swallow_mob(mob/living/victim)
	if(!isliving(victim))
		return FALSE
	if(victim.buckled) // you'll fall in once your buddy falls in
		return FALSE
	if(victim.incorporeal_move)
		return FALSE
	if(victim.body_position == STANDING_UP)
		if(!victim.get_gravity(get_turf(victim)))
			return FALSE
		if(victim.movement_type & (FLYING | FLOATING))
			return FALSE

	if(item_value_consumed < BINGLE_PIT_GROW_VALUE)
		var/turf/target = get_edge_target_turf(src, pick(GLOB.alldirs))
		victim.throw_at(target, rand(1, 5), rand(1, 5))
		to_chat(victim, span_warning("Вы не пролезаете в яму!"))
		return FALSE

	victim.add_traits(list(TRAIT_FALLING_INTO_BINGLE_HOLE, TRAIT_NO_TRANSFORM), UNIQUE_TRAIT_SOURCE(src))
	item_value_consumed += get_item_value(victim)
	if(iscarbon(victim) && victim.mind)
		repair_damage(BINGLE_PIT_PLAYER_HEAL)
	else
		repair_damage(BINGLE_PIT_LIVING_HEAL)
	// Only animate if we're actually swallowing
	animate_falling_into_pit(victim)
	// Delay the actual movement to let animation play
	addtimer(CALLBACK(src, PROC_REF(finish_swallow_mob), victim), 1 SECONDS)
	return TRUE

/obj/structure/bingle_hole/proc/get_item_value(atom/thing)
	if(isliving(thing))
		return BINGLE_PIT_LIVING_VALUE
	if(issingularity(thing))
		return BINGLE_PIT_SINGULARITY_VALUE
	if(!isstack(thing))
		return BINGLE_PIT_DEFAULT_OBJECT_GAIN_VALUE

	var/obj/item/stack/stack = thing
	var/stack_value = stack.amount * BINGLE_PIT_DEFAULT_OBJECT_GAIN_VALUE
	// If we have a set limit on this specific stack type, we limit to that. Otherwise, limit to common limiter
	if(LAZYACCESS(GLOB.bingle_hole_stack_limit, stack.type))
		return min(stack_value, GLOB.bingle_hole_stack_limit[stack.type])
	return min(stack_value, BINGLE_PIT_STACK_GAIN_LIMIT)

/// Mob and objects falling into the hole procs are separated. This one is for objects.
/obj/structure/bingle_hole/proc/swallow_obj(obj/thing)
	if(!isobj(thing))
		return FALSE

	ADD_TRAIT(thing, TRAIT_FALLING_INTO_BINGLE_HOLE, UNIQUE_TRAIT_SOURCE(src))
	repair_damage(BINGLE_PIT_OBJECT_CONSUME_HEAL)

	var/object_value = get_item_value(thing)
	var/list/hole_blacklist = GLOB.bingle_hole_blacklist
	for(var/atom/movable/content as anything in thing.get_all_contents() - thing)
		if(QDELETED(content) || HAS_TRAIT(content, TRAIT_FALLING_INTO_BINGLE_HOLE) || isbrain(content))
			continue
		if(isliving(content))
			content.forceMove(content.drop_location())
			continue
		if(is_type_in_typecache(content, hole_blacklist))
			qdel(content)
			continue
		if(!isobj(content))
			continue
		object_value = min(object_value + get_item_value(content), BINGLE_PIT_OBJECT_CONTENTS_VALUE_LIMIT)
		repair_damage(BINGLE_PIT_OBJECT_CONSUME_HEAL)

	item_value_consumed += object_value
	// Only animate if we're actually swallowing
	animate_falling_into_pit(thing)
	// Delay the actual movement to let animation play
	addtimer(CALLBACK(src, PROC_REF(finish_swallow_obj), thing), 1 SECONDS)
	return TRUE

/**
 * Proc called when someone falls into the hole.
 *
 * Currently checks for abstract objects, blacklist objects,
 * and thrown objects.
 *
 * Handling is separated into two procs, swallow_mob and swallow_obj.
 */
/obj/structure/bingle_hole/proc/swallow(atom/movable/item)
	if(QDELETED(src) || QDELETED(item))
		return
	if(item.invisibility == INVISIBILITY_ABSTRACT)
		return
	if(is_type_in_typecache(item, GLOB.bingle_hole_blacklist))
		return
	if(HAS_TRAIT(item, TRAIT_FALLING_INTO_BINGLE_HOLE) || HAS_TRAIT(item, TRAIT_NO_TRANSFORM))
		return
	if(item.throwing && item.throwing.target_turf != loc) // you can throw things over the pit
		return
	if(!swallow_mob(item) && !swallow_obj(item))
		return

	item.pulledby?.stop_pulling()
	item.stop_pulling()
	item.unbuckle_all_mobs()

/obj/structure/bingle_hole/proc/animate_falling_into_pit(atom/movable/item)
	var/turf/item_turf = get_turf(item)
	var/turf/pit_turf = get_turf(src)

	if(isnull(item_turf) || isnull(pit_turf))
		return

	// Create visual effects
	playsound(item_turf, 'sound/effects/gravhit.ogg', 50, TRUE)

	var/original_px = item.pixel_x
	var/original_py = item.pixel_y
	var/original_alpha = item.alpha

	// Make the item spin and shrink as it falls toward the center
	var/original_transform = item.transform

	// Calculate movement toward pit center
	var/dx = pit_turf.x - item_turf.x
	var/dy = pit_turf.y - item_turf.y

	// Animate the item moving toward pit center while spinning and shrinking
	animate(item, pixel_x = dx * world.icon_size, pixel_y = dy * world.icon_size, transform = turn(original_transform, 360), alpha = 100, time = 0.8 SECONDS, easing = EASE_IN)

	// Final disappear animation
	animate(transform = turn(original_transform, 720) * 0.1, alpha = 0, time = 0.2 SECONDS, easing = EASE_IN)

	// and ensure they animate back to normal afterwards
	animate(pixel_x = original_px, pixel_y = original_py, alpha = original_alpha, transform = original_transform, time = 0.5 SECONDS, easing = EASE_IN)

/// Transfers the swallowed mob into the hole, if the reservation is loaded.
/obj/structure/bingle_hole/proc/finish_swallow_mob(mob/living/swallowed_mob)
	if(QDELETED(swallowed_mob))
		return

	var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
	if(bingle_pit_turf)
		swallowed_mob.forceMove(bingle_pit_turf)
		swallowed_mob.remove_traits(list(TRAIT_FALLING_INTO_BINGLE_HOLE, TRAIT_NO_TRANSFORM), UNIQUE_TRAIT_SOURCE(src))
		return

	if(swallowed_mob.client || swallowed_mob.mind)
		swallowed_mob.gib() // This would never really happen but just incase
		return

	qdel(swallowed_mob)

/// Transfers the swallowed object into the hole, if the reservation exists.
/obj/structure/bingle_hole/proc/finish_swallow_obj(obj/swallowed_obj)
	if(QDELETED(swallowed_obj))
		return

	REMOVE_TRAIT(swallowed_obj, TRAIT_FALLING_INTO_BINGLE_HOLE, UNIQUE_TRAIT_SOURCE(src))
	// We cant really contain teslas (since they just teleport around), but singularities on the other hand
	if(istype(swallowed_obj, /obj/singularity/energy_ball))
		qdel(swallowed_obj)
		return

	var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
	if(!bingle_pit_turf)
		qdel(swallowed_obj)
		return

	swallowed_obj.forceMove(bingle_pit_turf)

/// Grows a pit to a certain size. Can't grow to a smaller size.
/obj/structure/bingle_hole/proc/grow_pit(new_size)
	if(current_pit_size >= new_size)
		return
	var/turf/origin = get_turf(src)
	if(!origin)
		return

	// Calculate corner coordinate offset based on new size
	var/corner_offset
	if(new_size % 2 == 1) // Odd sizes (1, 3, 5, etc.)
		var/half = (new_size - 1) / 2
		corner_offset = -half
	else // Even sizes (2, 4, 6, etc.)
		var/half = new_size / 2
		corner_offset = -(half - 1)

	// Calculates how much the pit should grow to the left or right
	var/size_difference = new_size - current_pit_size
	var/size_increase = ceil(size_difference / 2)

	// Here we get the grow outline turfs of the pit
	// Starting with bottom left -> right, then bottom left -> up,
	// Then upper left -> right, and finally bottom right -> up
	var/right_side_offset = corner_offset + new_size - size_increase
	var/list/expansion_turfs
	expansion_turfs += CORNER_BLOCK_OFFSET(origin, new_size, size_increase, corner_offset, corner_offset) // bottom
	expansion_turfs += CORNER_BLOCK_OFFSET(origin, size_increase, new_size, corner_offset, corner_offset) // left
	expansion_turfs += CORNER_BLOCK_OFFSET(origin, new_size, size_increase, corner_offset, right_side_offset) // up
	expansion_turfs += CORNER_BLOCK_OFFSET(origin, size_increase, new_size, right_side_offset, corner_offset) // right

	// faster to access
	var/list/our_overlays = pit_overlays
	for(var/turf/turf as anything in expansion_turfs)
		if(QDELETED(src))
			return

		if(!turf)
			continue

		if(is_space_or_openspace(turf) && !check_spaceturf_size(turf))
			continue

		var/obj/structure/bingle_hole/hole = locate() in turf
		var/obj/structure/bingle_pit_overlay/overlay = locate() in turf

		if(!overlay)
			overlay = new(turf, src)
			our_overlays += overlay

		if(overlay.parent_pit != src)
			merge_bingle_holes(src, overlay.parent_pit)
			return
		if(hole && (hole != src))
			merge_bingle_holes(src, hole)
			return

		if(new_size <= 3)
			continue

		// If pit is larger than 3x3, consume contents of the turf
		for(var/atom/movable/thing as anything in turf)
			swallow(thing)

		// Remove wall turf itself, if present
		if(iswallturf(turf))
			turf.dismantle_wall(TRUE)

	SEND_SIGNAL(src, COMSIG_BINGLE_HOLE_GROW, current_pit_size, new_size)
	current_pit_size = new_size
	aura_healing.range = round(new_size / 2) + 2
	modify_max_integrity(max_integrity + size_difference * BINGLE_PIT_GROW_INTEGRITY_INCREASE, FALSE)

/// Proc to force grow a hole by a set amount.
/obj/structure/bingle_hole/proc/grow_pit_by_set_amount(grow_amount)
	grow_pit(current_pit_size + grow_amount)

/**
 * Proc to check for big spaceturf spaces around a spaceturf
 *
 * Looks for any spaceturf neighbours, and if there are
 * more than 4, returns FALSE.
 *
 * Why 4? Counting for all cardinal directions. Works pretty much fine
 */
/obj/structure/bingle_hole/proc/check_spaceturf_size(turf/spaceturf)
	var/spaceturf_amount = 0
	for(var/turf/turf as anything in TURF_NEIGHBORS(spaceturf))
		if(!is_space_or_openspace(turf))
			continue
		spaceturf_amount++
		if(spaceturf_amount >= 4)
			return FALSE
	return TRUE


/obj/structure/bingle_pit_overlay
	name = "bingle pit"
	desc = "Что-то словно манит вас прыгнуть туда..."
	icon = 'icons/mob/bingle/binglepit.dmi'
	icon_state = "floor"
	base_icon_state = "bingle_pit"
	resistance_flags = FIRE_PROOF | UNACIDABLE
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_BINGLE_PIT
	smoothing_groups = SMOOTH_GROUP_BINGLE_PIT
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/obj/structure/bingle_hole/parent_pit

/obj/structure/bingle_pit_overlay/get_ru_names()
	return list(
		NOMINATIVE = "яма Бинглов",
		GENITIVE = "ямы Бинглов",
		DATIVE = "яме Бинглов",
		ACCUSATIVE = "яму Бинглов",
		INSTRUMENTAL = "ямой Бинглов",
		PREPOSITIONAL = "яме Бинглов"
	)

/obj/structure/bingle_pit_overlay/Initialize(mapload, obj/structure/bingle_hole/parent_pit)
	. = ..()
	if(!parent_pit)
		stack_trace("Bingle pit overlay created without parent pit.")
		qdel(src)
		return
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	src.parent_pit = parent_pit

/obj/structure/bingle_pit_overlay/Destroy()
	parent_pit?.pit_overlays -= src
	parent_pit = null
	return ..()

/obj/structure/bingle_pit_overlay/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return parent_pit.CanAStarPass(to_dir, pass_info)

/obj/structure/bingle_pit_overlay/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		parent_pit.on_entered(source, arrived)

/obj/structure/bingle_pit_overlay/ex_act(severity)
	return parent_pit.ex_act(severity)

/obj/structure/bingle_pit_overlay/attackby(obj/item/W, mob/user, params)
	if(parent_pit)
		user.do_attack_animation(src) // hacky but well
		return parent_pit.attackby(W, user, params)

	return ..()

/obj/structure/bingle_pit_overlay/attack_hand(mob/user)
	if(parent_pit)
		return parent_pit.attack_hand(user)

	return ..()

/obj/structure/bingle_pit_overlay/attack_animal(mob/living/simple_animal/user)
	if(isbingle(user))
		to_chat(user, span_warning("Вы отказываетесь ломать ваше святилище!"))
		user.balloon_alert(user, "атака невозможна!")
		return TRUE
	if(parent_pit)
		return parent_pit.attack_animal(user)

	return ..()

/obj/structure/bingle_pit_overlay/take_damage(amount, type, source, flags)
	if(isbingle(source))
		return FALSE // No damage from bingles
	if(parent_pit)
		return parent_pit.take_damage(amount, type, source, flags)

	return ..()

/obj/structure/bingle_pit_overlay/bullet_act(obj/projectile/projectile)
	if(parent_pit)
		return parent_pit.bullet_act(projectile)

	return ..()

/obj/structure/bingle_pit_overlay/examine(mob/user)
	. = ..()
	if(parent_pit && isbingle(user))
		. += span_alert("Внутри находится <b>[parent_pit.item_value_consumed]</b> предмет[DECL_CREDIT(parent_pit.item_value_consumed)]!")
		. += span_notice("Существа смогут упасть туда, если в яме будет минимум <b>[BINGLE_PIT_GROW_VALUE]</b> предмет[declension_ru(BINGLE_PIT_GROW_VALUE, "", "а", "ов")]!")

/obj/structure/bingle_hole/proc/spawn_bingle_from_ghost()
	var/image/poll_source = image('icons/mob/bingle/bingles.dmi', "bingle")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Хотите сыграть за Бингла?", ROLE_BINGLE, TRUE, poll_time = 10 SECONDS, source = poll_source)

	if(!length(candidates))
		return

	var/mob/dead/observer/candidate = pick_n_take(candidates)
	var/turf/spawn_loc = get_turf(src) // Use the pit's location
	if(isnull(spawn_loc))
		return

	var/mob/living/simple_animal/hostile/bingle/bingle = new(spawn_loc, src)
	bingle.possess_by_player(candidate.key)
	bingle.add_datum_if_not_exist()
	if(item_value_consumed >= BINGLE_EVOLVE_VALUE)
		SEND_SIGNAL(bingle, COMSIG_BINGLE_EVOLVE)

	message_admins("[ADMIN_LOOKUPFLW(bingle)] has been made into Bingle (pit spawn).")
	log_game("[key_name(bingle)] was spawned as Bingle by the pit.")

/obj/structure/bingle_hole/proc/get_random_bingle_pit_turf()
	// faster to access
	var/list/inside_pit_turfs_cached = inside_pit_turfs
	if(!length(inside_pit_turfs_cached))
		for(var/turf/simulated/floor/indestructible/bingle/floor in pit_reservation?.reserved_turfs)
			if(!floor.is_blocked_turf())
				inside_pit_turfs_cached += floor

	if(length(inside_pit_turfs_cached)) // Incase we haven't loaded the pit yet
		return pick(inside_pit_turfs_cached)

// We would rather eat the singularity, and we can contain it inside
/obj/structure/bingle_hole/singularity_act()
	return

/obj/structure/bingle_hole/singularity_pull(obj/singularity/S, current_size)
	return

/obj/structure/bingle_pit_overlay/singularity_act()
	return

/obj/structure/bingle_hole/singularity_pull(obj/singularity/S, current_size)
	return

/area/misc/bingle_pit
	name = "Яма Бинглов"
	area_flags = UNIQUE_AREA
	has_gravity = TRUE
	requires_power = FALSE

/**
 * Proc used to eject everything from inside from bingle hole
 *
 * Range can be specified to spread out objects (to lessen client render lag)
 */
/proc/eject_bingle_pit_contents(turf/target_turf, range = 1, datum/turf_reservation/pit_reservation)
	if(!target_turf)
		return
	var/list/turfs_in_range = RANGE_TURFS(range, target_turf)
	// We dont use area since there are separate locations for separate holes. Instead, we check reservation turfs saved from template loading
	for(var/turf/turf as anything in pit_reservation?.reserved_turfs)
		for(var/atom/movable/thing in turf)
			if(QDELETED(thing))
				continue
			var/turf/eject_to = pick(turfs_in_range)
			thing.forceMove(eject_to)
			thing.SpinAnimation(5, 1) // So that people emerging from the hole still have a chance at living
			CHECK_TICK

	qdel(pit_reservation)

/**
 * Proc used to merge bingle holes
 *
 * Reassigns all bingle mobs to the kept hole,
 * Moves all items from the turf reservation to the kept one,
 * Reassigns pit overlays to the kept one,
 * Moves the to be kept hole to the cross turf,
 * and finally deletes the to be removed hole.
 */
/proc/merge_bingle_holes(obj/structure/bingle_hole/grown_pit, obj/structure/bingle_hole/grown_into)
	// Stop both holes from processing while merging
	STOP_PROCESSING(SSbingle_pit, grown_pit)
	STOP_PROCESSING(SSbingle_pit, grown_into)
	// Decide which hole to merge into
	var/obj/structure/bingle_hole/hole_to_keep
	var/obj/structure/bingle_hole/hole_to_destroy
	if(grown_pit.current_pit_size >= grown_into.current_pit_size)
		hole_to_keep = grown_pit
		hole_to_destroy = grown_into
	else
		hole_to_keep = grown_into
		hole_to_destroy = grown_pit

	// Overlays "merging"
	var/list/overlays_to_keep = hole_to_keep.pit_overlays
	var/list/overlays_to_transfer = hole_to_destroy.pit_overlays
	for(var/obj/structure/bingle_pit_overlay/pit_overlay as anything in overlays_to_transfer)
		pit_overlay.parent_pit = hole_to_keep
	overlays_to_keep += overlays_to_transfer
	overlays_to_transfer = list()

	// Reassign bingles of to remove hole to the kept one
	var/list/bingles_by_hole = GLOB.bingles_by_hole
	var/hole_to_keep_uid = hole_to_keep.UID()
	var/hole_to_destroy_uid = hole_to_destroy.UID()
	if(LAZYACCESS(bingles_by_hole, hole_to_destroy_uid))
		for(var/mob/living/simple_animal/hostile/bingle/bingle as anything in bingles_by_hole[hole_to_destroy_uid])
			LAZYADDASSOCLIST(bingles_by_hole, hole_to_keep_uid, bingle)
			bingle.spawn_hole = hole_to_keep
		bingles_by_hole -= hole_to_destroy_uid

	// Move everything from the destroyed hole to the new one
	for(var/turf/turf as anything in hole_to_destroy.pit_reservation?.reserved_turfs)
		for(var/atom/movable/thing in turf)
			if(QDELETED(thing))
				continue
			var/turf/eject_to = hole_to_keep.get_random_bingle_pit_turf()
			if(!eject_to)
				qdel(thing)
				return
			thing.forceMove(eject_to)

	// Some var stuff
	// Shitty var check to see whose armor is best (Works anyways)
	var/datum/armor/kept_armor = hole_to_keep.armor
	var/datum/armor/removed_armor = hole_to_destroy.armor
	if(kept_armor.getRating(MELEE) < removed_armor.getRating(MELEE))
		kept_armor = removed_armor
	kept_armor = kept_armor.setRating(
		melee_value = min(kept_armor.getRating(MELEE) + BINGLE_PIT_MERGE_ARMOR_INCREASE, BINGLE_PIT_MERGE_ARMOR_CAP),
		bullet_value = min(kept_armor.getRating(BULLET) + BINGLE_PIT_MERGE_ARMOR_INCREASE, BINGLE_PIT_MERGE_ARMOR_CAP),
		laser_value = min(kept_armor.getRating(LASER) + BINGLE_PIT_MERGE_ARMOR_INCREASE, BINGLE_PIT_MERGE_ARMOR_CAP),
		energy_value = min(kept_armor.getRating(ENERGY) + BINGLE_PIT_MERGE_ARMOR_INCREASE, BINGLE_PIT_MERGE_ARMOR_CAP),
	)

	hole_to_keep.modify_max_integrity(hole_to_keep.max_integrity + hole_to_destroy.max_integrity, FALSE)
	hole_to_keep.repair_damage(hole_to_destroy.obj_integrity)

	// Now start processing the previously process stopped hole
	START_PROCESSING(SSbingle_pit, hole_to_keep)
	// And finally remove the to destroy hole
	qdel(hole_to_destroy)
