/datum/component/muscles
	/// Max level of strength for this muscles owner.
	var/datum/strength_level/max_species_strength = STRENGTH_LEVEL_IDEAL
	/// If FALSE, strength of body can't be changed.
	var/can_become_stronger = TRUE
	/// Strength level before modifiers.
	var/datum/strength_level/real_strength_level
	/// Strength level after modifiers.
	var/datum/strength_level/usable_strength_level
	/// Points of strength that this body already has. They are used to change the strength level.
	var/strength_points = 0


/datum/component/muscles/Initialize(max_species_strength = STRENGTH_LEVEL_MAXDEFAULT, default_strength = STRENGTH_LEVEL_DEFAULT, can_become_stronger = TRUE)
	..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	src.max_species_strength = max_species_strength
	src.can_become_stronger = can_become_stronger
	real_strength_level = default_strength
	usable_strength_level = default_strength


/datum/component/muscles/RegisterWithParent()
	RegisterSignal(parent, COMSIG_GET_GRAB_SPEED_MODIFIERS, PROC_REF(get_strength_grab_speed_modifier))
	RegisterSignal(parent, COMSIG_GET_PULL_SLOWDOWN_MODIFIERS, PROC_REF(get_strength_pull_slowdown_modifier))
	RegisterSignal(parent, COMSIG_GET_MELEE_DAMAGE_DELTAS, PROC_REF(get_strength_melee_damage_delta))
	RegisterSignal(parent, COMSIG_MOB_EXERCISED, PROC_REF(try_add_strength_points))
	RegisterSignal(parent, COMSIG_GET_ICON_RENDER_KEY_INFO, PROC_REF(get_icon_render_key_info))
	RegisterSignal(parent, COMSIG_GET_ORGAN_ICON_STATE, PROC_REF(get_organ_icon_state))
	RegisterSignal(parent, COMSIG_STRENGTH_BORDER_UPDATE, PROC_REF(on_strength_border_update))
	RegisterSignal(parent, COMSIG_CAN_CHANGE_STRENGTH, PROC_REF(can_activate_strength_gene))
	RegisterSignal(parent, COMSIG_GET_STRENGTH, PROC_REF(get_strength_list))
	RegisterSignal(parent, COMSIG_UPDATE_STRENGTH, PROC_REF(update_strength))
	RegisterSignal(parent, COMSIG_GET_BREAKOUTTIME_MODIFIERS, PROC_REF(get_breakouttime_modifiers))
	RegisterSignal(parent, COMSIG_GET_THROW_SPEED_MODIFIERS, PROC_REF(get_throw_speed_modifier))
	RegisterSignal(parent, COMSIG_GET_THROW_RANGE_DELTAS, PROC_REF(get_throw_range_deltas))
	RegisterSignal(parent, COMSIG_GET_BOLA_MODIFIERS, PROC_REF(get_bolas_time_modifier))
	RegisterSignal(parent, COMSIG_GET_HUNGER_MODS, PROC_REF(get_hunger_mod))


/datum/component/muscles/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_GET_GRAB_SPEED_MODIFIERS,
		COMSIG_GET_PULL_SLOWDOWN_MODIFIERS,
		COMSIG_GET_MELEE_DAMAGE_DELTAS,
		COMSIG_MOB_EXERCISED,
		COMSIG_GET_ICON_RENDER_KEY_INFO,
		COMSIG_GET_ORGAN_ICON_STATE,
		COMSIG_STRENGTH_BORDER_UPDATE,
		COMSIG_CAN_CHANGE_STRENGTH,
		COMSIG_GET_STRENGTH,
		COMSIG_UPDATE_STRENGTH,
		COMSIG_GET_BREAKOUTTIME_MODIFIERS,
		COMSIG_GET_THROW_SPEED_MODIFIERS,
		COMSIG_GET_THROW_RANGE_DELTAS,
		COMSIG_GET_BOLA_MODIFIERS,
		COMSIG_GET_HUNGER_MODS
	))

/datum/component/muscles/proc/update_strength()
	SIGNAL_HANDLER

	if(HAS_TRAIT(parent, TRAIT_STRONG_MUSCLES))
		usable_strength_level = real_strength_level.level_num >= /datum/strength_level/ideal::level_num ? real_strength_level : /datum/strength_level/ideal
		return

	if(HAS_TRAIT(parent, TRAIT_WEAK_MUSCULS))
		usable_strength_level = /datum/strength_level/weak
		return

	var/mob/living/user = parent
	var/datum/status_effect/sport_grouped/strength_level_delta = user.has_status_effect(/datum/status_effect/sport_grouped/strength_level_delta)
	var/delta = strength_level_delta ? strength_level_delta.get_sum() : 0
	usable_strength_level = real_strength_level
	while(delta > 0)
		delta--
		if(!usable_strength_level.next_level)
			break

		usable_strength_level = usable_strength_level.next_level

	while(delta < 0)
		delta++
		if(!usable_strength_level.prev_level)
			break

		usable_strength_level = usable_strength_level.prev_level


/datum/component/muscles/proc/get_strength_list(user, list/strength_list)
	SIGNAL_HANDLER
	strength_list.Add(usable_strength_level)


/datum/component/muscles/proc/can_activate_strength_gene(user)
	SIGNAL_HANDLER
	return COMPONENT_CAN_CHANGE_STRENGTH


/datum/component/muscles/proc/on_strength_border_update(user)
	SIGNAL_HANDLER
	while(real_strength_level.level_num > get_max_strength_level())
		real_strength_level = real_strength_level.prev_level


#define REQ_STAMINA_FOR_STRENGTH_POINT		25
#define REQ_NUTRITION_FOR_STRENGTH_POINT	25
#define MIN_NUTRITION_FOR_STRENGTH_CHANGE	NUTRITION_LEVEL_STARVING

/datum/component/muscles/proc/try_add_strength_points(mob/living/user, delta)
	SIGNAL_HANDLER
	if(user.nutrition < MIN_NUTRITION_FOR_STRENGTH_CHANGE)
		to_chat(user, span_warning("Вы слишком голодны!"))
		return FALSE

	var/datum/status_effect/sport_grouped/swing_stamina_mod = user.has_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod)
	var/stamina_mod = swing_stamina_mod ? swing_stamina_mod.get_mult() : 1

	if(user.getStaminaLoss() + delta * REQ_STAMINA_FOR_STRENGTH_POINT * stamina_mod > MAX_STAMINA_LOSS)
		to_chat(user, span_warning("Вы слишком устали!"))
		return FALSE

	if(!can_become_stronger)
		return TRUE

	user.adjustStaminaLoss(delta * REQ_STAMINA_FOR_STRENGTH_POINT * stamina_mod)
	user.adjust_nutrition(-delta * REQ_NUTRITION_FOR_STRENGTH_POINT)

	var/datum/status_effect/sport_grouped/swing_effect_mod = user.has_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod)
	delta *= swing_effect_mod ? swing_effect_mod.get_mult() : 1

	strength_points += delta
	try_upgrade_strength(user)
	if(real_strength_level.level_num >= get_max_strength_level())
		strength_points = 0

	return TRUE


/datum/component/muscles/proc/try_upgrade_strength(mob/living/carbon/human/user)
	if(real_strength_level.level_num >= get_max_strength_level())
		return

	if(strength_points < real_strength_level.strength_req_to_upgrade)
		return

	strength_points -= real_strength_level.strength_req_to_upgrade
	real_strength_level = new real_strength_level.next_level()
	user.update_body(TRUE)


/datum/component/muscles/proc/get_max_strength_level()
	if(HAS_TRAIT(parent, TRAIT_WEAK_MUSCULS))
		var/datum/strength_level/weak = STRENGTH_LEVEL_WEAK
		return weak.level_num

	if(HAS_TRAIT(parent, TRAIT_STRONG_MUSCLES))
		var/datum/strength_level/super = STRENGTH_LEVEL_SUPERHUMAN
		return super.level_num

	return max_species_strength.level_num


/datum/component/muscles/proc/get_icon_render_key_info(mob/living/user, list/info)
	SIGNAL_HANDLER
	info.Add(get_strength(user))


/datum/component/muscles/proc/get_organ_icon_state(mob/living/carbon/human/user, obj/item/organ/external/organ, list/icon_state_additions)
	SIGNAL_HANDLER
	if(!istype(user.dna.species, /datum/species/human) || !ischest(organ) && !isgroin(organ))
		return

	icon_state_additions.Add("_[min(4, get_strength(user))]")


/datum/component/muscles/proc/get_strength()
	update_strength()
	var/mob/living/living = parent
	var/datum/status_effect/sport_grouped/strength_level_delta = living.has_status_effect(/datum/status_effect/sport_grouped/strength_level_delta)
	var/delta = strength_level_delta ? strength_level_delta.get_sum() : 0
	return clamp(real_strength_level.level_num + delta, 1, 5)


/datum/component/muscles/proc/get_strength_level_part(mob/living/user)
	var/level = get_strength(user)
	if(level == STRENGTH_LEVEL_SUPERHUMAN)
		return 0

	return strength_points / real_strength_level.strength_req_to_upgrade


/datum/component/muscles/proc/get_strength_grab_speed_modifier(mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	var/strength_level_part = get_strength_level_part(user)
	if(strength_level_part == 0)
		modifiers.Add(usable_strength_level.grab_speed_modifier)
		return

	var/datum/strength_level/next_strength_level = usable_strength_level.next_level
	modifiers.Add(usable_strength_level.grab_speed_modifier + \
		(next_strength_level.grab_speed_modifier - usable_strength_level.grab_speed_modifier) * strength_level_part)


/datum/component/muscles/proc/get_strength_pull_slowdown_modifier(mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	var/strength_level_part = get_strength_level_part(user)
	if(strength_level_part == 0)
		modifiers.Add(usable_strength_level.pull_slowdown_modifier)
		return

	var/datum/strength_level/next_strength_level = usable_strength_level.next_level
	modifiers.Add(usable_strength_level.pull_slowdown_modifier + \
		(next_strength_level.pull_slowdown_modifier - usable_strength_level.pull_slowdown_modifier) * strength_level_part)


/datum/component/muscles/proc/get_strength_melee_damage_delta(mob/living/user, list/deltas, obj/item/weapon)
	SIGNAL_HANDLER

	if(weapon && weapon.damtype != BRUTE)
		return

	var/strength_level_part = get_strength_level_part(user)
	if(strength_level_part == 0)
		deltas.Add(usable_strength_level.melee_damage_delta)
		return

	var/datum/strength_level/next_strength_level = usable_strength_level.next_level
	deltas.Add(usable_strength_level.melee_damage_delta + \
		(next_strength_level.melee_damage_delta - usable_strength_level.melee_damage_delta) * strength_level_part)



/datum/component/muscles/proc/get_hunger_mod(user, list/modifiers)
	SIGNAL_HANDLER
	if(isvampire(user))
		return

	var/strength_level_part = get_strength_level_part(user)
	if(strength_level_part == 0)
		modifiers.Add(usable_strength_level.hunger_modifier)
		return

	var/datum/strength_level/next_strength_level = usable_strength_level.next_level
	modifiers.Add(usable_strength_level.hunger_modifier + \
		(next_strength_level.hunger_modifier - usable_strength_level.hunger_modifier) * strength_level_part)


/datum/component/muscles/proc/get_bolas_time_modifier(user, list/modifiers)
	SIGNAL_HANDLER
	var/strength_level_part = get_strength_level_part(user)
	if(strength_level_part == 0)
		modifiers.Add(usable_strength_level.bolas_time_modifier)
		return

	var/datum/strength_level/next_strength_level = usable_strength_level.next_level
	modifiers.Add(usable_strength_level.bolas_time_modifier + \
		(next_strength_level.bolas_time_modifier - usable_strength_level.bolas_time_modifier) * strength_level_part)


/datum/component/muscles/proc/get_throw_range_deltas(user, list/deltas)
	SIGNAL_HANDLER
	var/strength_level_part = get_strength_level_part(user)
	if(strength_level_part == 0)
		deltas.Add(usable_strength_level.throw_range_delta)
		return

	var/datum/strength_level/next_strength_level = usable_strength_level.next_level
	deltas.Add(usable_strength_level.throw_range_delta + \
		(next_strength_level.throw_range_delta - usable_strength_level.throw_range_delta) * strength_level_part)


/datum/component/muscles/proc/get_throw_speed_modifier(user, list/modifiers)
	SIGNAL_HANDLER
	var/strength_level_part = get_strength_level_part(user)
	if(strength_level_part == 0)
		modifiers.Add(usable_strength_level.throw_speed_modifier)
		return

	var/datum/strength_level/next_strength_level = usable_strength_level.next_level
	modifiers.Add(usable_strength_level.throw_speed_modifier + \
		(next_strength_level.throw_speed_modifier - usable_strength_level.throw_speed_modifier) * strength_level_part)


/datum/component/muscles/proc/get_breakouttime_modifiers(user, list/modifiers)
	SIGNAL_HANDLER

	var/strength_level_part = get_strength_level_part(user)
	if(strength_level_part == 0)
		modifiers.Add(1 / usable_strength_level.break_ties_speed_modifier)
		return

	var/datum/strength_level/next_strength_level = usable_strength_level.next_level
	modifiers.Add(1 / (usable_strength_level.break_ties_speed_modifier + \
		(next_strength_level.break_ties_speed_modifier - usable_strength_level.break_ties_speed_modifier) * strength_level_part))


#undef REQ_STAMINA_FOR_STRENGTH_POINT
#undef REQ_NUTRITION_FOR_STRENGTH_POINT
#undef MIN_NUTRITION_FOR_STRENGTH_CHANGE


/datum/strength_level
	var/datum/strength_level/next_level
	var/datum/strength_level/prev_level
	var/level_num
	var/grab_speed_modifier
	var/pull_slowdown_modifier
	var/melee_damage_delta
	var/break_ties_speed_modifier
	var/throw_speed_modifier
	var/throw_range_delta
	var/bolas_time_modifier
	var/hunger_modifier
	var/strength_req_to_upgrade
	var/strength_examine


/datum/strength_level/weak
	next_level = /datum/strength_level/normal
	level_num = 1
	grab_speed_modifier = 0.8
	pull_slowdown_modifier = 1.2
	melee_damage_delta = -2
	break_ties_speed_modifier = 0.8
	throw_speed_modifier = 0.5
	throw_range_delta = -2
	bolas_time_modifier = 1.2
	hunger_modifier = 0.9
	strength_req_to_upgrade = 10
	strength_examine = "слаб"


/datum/strength_level/normal
	next_level = /datum/strength_level/strong
	prev_level = /datum/strength_level/weak
	level_num = 2
	grab_speed_modifier = 1
	pull_slowdown_modifier = 1
	melee_damage_delta = 0
	break_ties_speed_modifier = 1
	throw_speed_modifier = 0.6
	throw_range_delta = -1
	bolas_time_modifier = 1
	hunger_modifier = 1
	strength_req_to_upgrade = 20
	strength_examine = "нормальн"


/datum/strength_level/strong
	next_level = /datum/strength_level/ideal
	prev_level = /datum/strength_level/normal
	level_num = 3
	grab_speed_modifier = 1.15
	pull_slowdown_modifier = 0.75
	melee_damage_delta = 2
	break_ties_speed_modifier = 1.3
	throw_speed_modifier = 0.7
	throw_range_delta = 0
	bolas_time_modifier = 0.8
	hunger_modifier = 1.1
	strength_req_to_upgrade = 30
	strength_examine = "сильн"


/datum/strength_level/ideal
	next_level = /datum/strength_level/superhuman
	prev_level = /datum/strength_level/strong
	level_num = 4
	grab_speed_modifier = 1.3
	pull_slowdown_modifier = 0.5
	melee_damage_delta = 4
	break_ties_speed_modifier = 1.5
	throw_speed_modifier = 0.8
	throw_range_delta = 1
	bolas_time_modifier = 0.5
	hunger_modifier = 1.2
	strength_req_to_upgrade = 35
	strength_examine = "очень сильн"


/datum/strength_level/superhuman
	prev_level = /datum/strength_level/ideal
	level_num = 5
	grab_speed_modifier = 1.5
	pull_slowdown_modifier = 0
	melee_damage_delta = 6
	break_ties_speed_modifier = 2
	throw_speed_modifier = 1
	throw_range_delta = 2
	bolas_time_modifier = 0.3
	hunger_modifier = 1.3
	strength_req_to_upgrade = -1
	strength_examine = "необыкновенно сильн"
