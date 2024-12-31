/datum/borer_rank
	var/rankname = "Error"
	/// how many reproductions we need to gain new rank
	var/required_reproductions
	var/datum/antagonist/borer/parent
	var/mob/living/simple_animal/borer/owner
	var/next_rank_type
	var/rank_ability_amplifier

/datum/borer_rank/Destroy(force)
	parent = null
	owner = null
	return ..()

/datum/borer_rank/New(mob/living/simple_animal/borer/borer)
	owner = borer
	parent = borer.antag_datum
	on_apply()

/datum/borer_rank/proc/on_apply()
	return

/datum/borer_rank/proc/tick(seconds_between_ticks)
	return

/datum/borer_rank/young
	rankname = "Young"
	required_reproductions = REPRODUCTIONS_TO_MATURE
	next_rank_type = BORER_RANK_MATURE
	rank_ability_amplifier = 0

/datum/borer_rank/mature
	rankname = "Mature"
	required_reproductions = REPRODUCTIONS_TO_ADULT
	next_rank_type = BORER_RANK_ADULT
	rank_ability_amplifier = 1

/datum/borer_rank/adult
	rankname = "Adult"
	required_reproductions = REPRODUCTIONS_TO_ELDER
	next_rank_type = BORER_RANK_ELDER
	rank_ability_amplifier = 2

/datum/borer_rank/elder
	rankname = "Elder"
	rank_ability_amplifier = 3

/datum/borer_rank/young/on_apply()
	owner.update_transform(0.5) // other ranks should be gained and processed only with antag datum
	return TRUE

/datum/borer_rank/mature/on_apply()
	parent.user.update_transform(2)
	parent.user.maxHealth += 5
	return TRUE

/datum/borer_rank/adult/on_apply()
	parent.user.maxHealth += 5
	return TRUE

/datum/borer_rank/elder/on_apply()
	parent.user.maxHealth += 10
	return TRUE

/datum/borer_rank/young/tick(seconds_between_ticks)
	parent.user.adjustHealth(-0.1)

/datum/borer_rank/mature/tick(seconds_between_ticks)
	parent.user.adjustHealth(-0.15)

/datum/borer_rank/adult/tick(seconds_between_ticks)
	parent.user.adjustHealth(-0.2)

	if(parent.host?.stat != DEAD && !parent.user.sneaking)
		parent.user.chemicals += 0.2

/datum/borer_rank/elder/tick(seconds_between_ticks)
	parent.user.adjustHealth(-0.3)

	if(parent.host?.stat != DEAD)
		parent.host?.heal_overall_damage(0.4, 0.4)
		parent.user.chemicals += 0.3
