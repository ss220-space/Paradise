//robotics quests console datums

/datum/roboquest
	/// Name of our current mecha
	var/name
	/// Description of our current mech quest
	var/desc
	/// Text info for tgui
	var/list/questinfo = list()
	/// Reward for our current quest
	var/reward
	/// Difficulty type
	var/difficulty
	/// Is our quest was claimed
	var/claimed = FALSE
	//всякая хрень, отвечает за сам сгенерированный мех
	var/choosen_mech
	var/list/choosen_modules
	var/modules_amount = 0
	var/obj/check

/datum/roboquest/New()
	..()
	generate_mecha()

/datum/roboquest/proc/generate_mecha()
	var/mech = pick(subtypesof(/datum/quest_mech))
	var/datum/quest_mech/selected = new mech
	name = selected.name
	questinfo["name"] = name
	desc = "Блаблабла"
	questinfo["desc"] = desc
	questinfo["icon"] = icon2base64(selected.mech_icon)
	choosen_mech = selected.mech_type //тут мы выбираем меха из заготовок
	if(length(selected.wanted_modules))
		var/list/weapons = selected.wanted_modules
		for(var/i in 1 to rand(1, 4))
			var/the_choosen_one = list(pick_n_take(weapons))
			choosen_modules += the_choosen_one
		for(var/i in choosen_modules)
			modules_amount++
			var/obj/module = new i
			questinfo["module[modules_amount]-icon"]=icon2base64(icon(module.icon, module.icon_state))
			questinfo["module[modules_amount]"] = module.name
			qdel(module)






