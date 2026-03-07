/datum/borer_focus
	var/name = "Focus"
	var/cost = 0
	var/datum/antagonist/borer/parent
	var/movable_granted = FALSE
	var/is_catathonic = FALSE // Ckey isn't a constant value. So, check only on this.

/datum/borer_focus/New(mob/living/simple_animal/borer/borer)
	parent = borer.antag_datum
	apply()

/datum/borer_focus/proc/tick()
	return

/datum/borer_focus/proc/apply()
	return

/datum/borer_focus/proc/grant_movable_effect()
	return

/datum/borer_focus/proc/remove_movable_effect()
	return

/datum/borer_focus/Destroy(force)
	parent = null

	return ..()

/datum/borer_focus/head
	name = "Фокус головы"
	cost = HEAD_FOCUS_COST

/datum/borer_focus/torso
	name = "Фокус тела"
	cost = TORSO_FOCUS_COST
	var/obj/item/organ/internal/heart/linked_organ

/datum/borer_focus/hands
	name = "Фокус рук"
	cost = HANDS_FOCUS_COST

/datum/borer_focus/legs
	name = "Фокус ног"
	cost = LEGS_FOCUS_COST

/datum/borer_focus/sting
	name = "Фокус жала"
	cost = STING_FOCUS_COST

/datum/borer_focus/reproductive
	name = "Фокус репродукции"
	cost = REPRODUCTION_FOCUS_COST

/datum/borer_focus/abdomen
	name = "Фокус брюшка"
	cost = ABDOMEN_FOCUS_COST

/datum/borer_focus/secretion
	name = "Фокус секреции"
	cost = SECRETION_FOCUS_COST

/datum/borer_focus/strength
	name = "Фокус мышц"
	cost = STRENGHT_FOCUS_COST
	var/datum/strength_level/backup_strength_level
	var/backup_strength_points = 0

/datum/borer_focus/head/grant_movable_effect()
	if(!is_catathonic)
		parent.user.host.physiology.brain_mod *= 0.85
		parent.user.host.physiology.hunger_mod *= 0.75
		parent.user.host.stam_regen_start_modifier *= 0.875
		return TRUE

	parent.user.host.physiology.brain_mod *= 0.7
	parent.user.host.physiology.hunger_mod *= 0.5
	parent.user.host.stam_regen_start_modifier *= 0.75
	return TRUE

/datum/borer_focus/head/remove_movable_effect()
	if(!is_catathonic)
		parent.user.host.physiology.brain_mod /= 0.85
		parent.user.host.physiology.hunger_mod /= 0.75
		parent.user.host.stam_regen_start_modifier /= 0.875
		return TRUE

	parent.user.host.physiology.brain_mod /= 0.7
	parent.user.host.physiology.hunger_mod /= 0.3
	parent.user.host.stam_regen_start_modifier /= 0.75
	return TRUE

/datum/borer_focus/head/tick()
	if(!parent.user.controlling && parent.user.host && parent.user.host.stat != DEAD)
		parent.user.host.adjustBrainLoss(-1)

/datum/borer_focus/torso/grant_movable_effect()
	if(!is_catathonic)
		parent.user.host.physiology.brute_mod *= 0.9
		return TRUE

	parent.user.host.physiology.brute_mod *= 0.8
	return TRUE

/datum/borer_focus/torso/remove_movable_effect()
	if(!is_catathonic)
		parent.user.host.physiology.brute_mod /= 0.9
		return TRUE

	parent.user.host.physiology.brute_mod /= 0.8
	return TRUE

/datum/borer_focus/torso/tick()
	if(!parent.user.host || parent.user.host.stat == DEAD)
		return

	linked_organ = parent.user.host.get_int_organ(/obj/item/organ/internal/heart)
	if(!linked_organ)
		return

	parent.user.host.set_heartattack(FALSE)

/datum/borer_focus/torso/Destroy(force)
	linked_organ = null
	return ..()

/datum/borer_focus/hands/grant_movable_effect()
	parent.user.host.add_actionspeed_modifier(/datum/actionspeed_modifier/borer_arm_focus)
	parent.user.host.physiology.punch_damage_low += 7
	parent.user.host.physiology.punch_damage_high += 5
	parent.user.host.next_move_modifier *= 0.75
	return TRUE

/datum/borer_focus/hands/remove_movable_effect()
	parent.user.host.remove_actionspeed_modifier(/datum/actionspeed_modifier/borer_arm_focus)
	parent.user.host.physiology.punch_damage_low -= 7
	parent.user.host.physiology.punch_damage_high -= 5
	parent.user.host.next_move_modifier /= 0.75
	return TRUE

/datum/borer_focus/legs/grant_movable_effect()
	if(!is_catathonic)
		parent.user.host.add_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus/lesser)
		return TRUE

	parent.user.host.add_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus)
	return TRUE

/datum/borer_focus/legs/remove_movable_effect()
	if(!is_catathonic)
		parent.user.host.remove_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus/lesser)
		return TRUE

	parent.user.host.remove_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus)
	return TRUE

/datum/borer_focus/sting/apply()
	parent.user.dominate_spell.weaken_time += pick(5, 6) SECONDS
	parent.user.torment_action.cost -= 15

/datum/borer_focus/reproductive/apply()
	RegisterSignal(parent.user, COMSIG_BORER_REPRODUCE, PROC_REF(on_reproduce))
	parent.user.make_larvae_action.cost = parent.user.make_larvae_action.cost * 0.3

/datum/borer_focus/reproductive/proc/on_reproduce(mob/living/simple_animal/borer/source, turf/turf)
	SIGNAL_HANDLER

	var/additional_borers = 0
	var/chance = rand(1, 100)

	switch(chance)
		if(1 to 10)
			additional_borers = 1

		if(11 to 15)
			additional_borers = 2

	for(var/count in 1 to additional_borers)
		turf.add_vomit_floor()
		new /mob/living/simple_animal/borer(turf, source.generation + 1)

/datum/borer_focus/reproductive/Destroy(force)
	UnregisterSignal(parent.user, COMSIG_BORER_REPRODUCE)
	return ..()

/datum/borer_focus/abdomen/apply()
	parent.user.transform = parent.user.transform.Scale(0.8)
	parent.user.pixel_y = 0

/datum/borer_focus/secretion/apply()
	parent.user.chem_gain += 0.5
	parent.user.infest_spell.cast_time = parent.user.infest_spell.cast_time * 0.5


/datum/borer_focus/strength/grant_movable_effect()
	var/mob/living/carbon/human/host = parent.user.host
	if(!istype(host))
		return FALSE

	// Получаем или создаём компонент мышц
	var/datum/component/muscles/muscles = host.GetComponent(/datum/component/muscles)
	if(!muscles)
		muscles = host.AddComponent(/datum/component/muscles)
		if(!muscles)
			return FALSE

	// Запоминаем текущие значения
	backup_strength_level = muscles.real_strength_level
	backup_strength_points = muscles.strength_points

	// Устанавливаем максимальную силу (5 уровень)
	ADD_TRAIT(host, TRAIT_STRONG_MUSCLES, BORER_TRAIT)
	muscles.real_strength_level = new STRENGTH_LEVEL_SUPERHUMAN()	// Предполагается, что это максимальный уровень
	muscles.strength_points = 0

	host.update_body(TRUE)
	return TRUE

/datum/borer_focus/strength/remove_movable_effect()
	var/mob/living/carbon/human/host = parent.user.host
	if(!istype(host))
		return FALSE

	REMOVE_TRAIT(host, TRAIT_STRONG_MUSCLES, BORER_TRAIT)

	var/datum/component/muscles/muscles = host.GetComponent(/datum/component/muscles)
	if(muscles)
		if(backup_strength_level)
			// Восстанавливаем сохранённый уровень
			muscles.real_strength_level = backup_strength_level
			muscles.strength_points = backup_strength_points
		else
			// Если по какой-то причине нет сохранённых данных — ставим стандартный уровень
			muscles.real_strength_level = new STRENGTH_LEVEL_DEFAULT()
			muscles.strength_points = 0

	host.update_body(TRUE)
	return TRUE
