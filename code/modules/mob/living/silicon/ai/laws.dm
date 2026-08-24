GAME_VERB_PROC_DESC(/mob/living/silicon/ai, show_laws_verb, "Список законов", "Check what your laws are privately. Also ensures all synced cyborgs are up to date with your laws, reminds them of your laws.", VERB_CATEGORY_AICOMMANDS)
	src.show_laws()

/mob/living/silicon/ai/show_laws(everyone = 0)
	var/who

	if(everyone)
		who = world
	else
		who = src
		to_chat(who, "<b>Подчиняйтесь данным законам:</b>")

	src.laws_sanity_check()
	src.laws.show_laws(who)

/mob/living/silicon/ai/add_ion_law(law)
	..()
	for(var/mob/living/silicon/robot/R in GLOB.mob_list)
		if(R.lawupdate && (R.connected_ai == src))
			R.show_laws()

/mob/living/silicon/ai/add_devil_law(law)
	..()
	for(var/mob/living/silicon/robot/R in GLOB.mob_list)
		if(R.lawupdate && (R.connected_ai == src))
			R.show_laws()
