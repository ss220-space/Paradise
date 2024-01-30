//robotics quests console datums

/datum/robo_quest
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
	//всякая хрень, отвечает за радномизацию.
	var/mech_type
	var/list/wanted_modules
	//всякая хрень, отвечает за сам сгенерированный мех
	var/choosen_mech
	var/list/choosen_modules

/datum/robo_quest/New()
	..()
	generate_mecha()

/datum/robo_quest/proc/generate_mecha()
	var/mech = pick(subtypesof(/datum/robo_quest))
	var/datum/robo_quest/selected = new mech
	choosen_mech = selected.mech_type //тут мы выбираем меха из заготовок
	if(length(selected.wanted_modules))
		for(var/i in 1 to rand(1, 4))
			var/obj/item/mecha_weapon = pick(wanted_modules)
			choosen_modules += mecha_weapon






