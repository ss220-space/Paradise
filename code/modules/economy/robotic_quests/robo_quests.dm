//robotics quests console datums

/datum/roboquest
	/// Name of our current mecha
	var/name
	/// Description of our current mech quest
	var/desc
	/// Reward for our current quest
	var/reward
	/// Difficulty type
	var/difficulty
	/// Is our quest was claimed
	var/claimed = FALSE
	//всякая хрень, отвечает за сам сгенерированный мех
	var/choosen_mech
	var/list/choosen_modules
	var/modules_amount

/datum/roboquest/New()
	..()
	generate_mecha()

/datum/roboquest/proc/generate_mecha()
	var/mech = pick(subtypesof(/datum/quest_mech))
	var/datum/quest_mech/selected = new mech
	name = selected.name
	desc = "Блаблабла"
	choosen_mech = selected.mech_type //тут мы выбираем меха из заготовок
	if(length(selected.wanted_modules))
		var/list/weapons = selected.wanted_modules
		for(var/i in 1 to rand(1, 4))
			choosen_modules += list(pick_n_take(weapons))
			modules_amount = i






