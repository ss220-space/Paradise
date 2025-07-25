// A type of antagonist created by the moon ascension
/datum/antagonist/lunatic
	name = "Лунатик"
	antag_hud_name = "lunatic"
	clown_gain_text = "Древние знания о Луне позволили вам преодолеть свою шутовскую натуру и научиться владеть оружием, не причиняя себе вреда."
	clown_removal_text = "По мере того, как ваши знания о Луне рассеиваются, вы возвращаетесь к своему неуклюжему, клоунскому «я»."
	// The mind of the ascended heretic who created us
	var/datum/mind/ascended_heretic
	// The body of the ascended heretic who created us
	var/mob/living/carbon/human/ascended_body
	// Our objective
	var/datum/objective/lunatic/lunatic_obj


/datum/antagonist/lunatic/on_gain()
	// Masters gain an objective before so we dont want duplicates
	for(var/objective in objectives)
		if(!istype(objective, /datum/objective/lunatic))
			continue

		return ..()

	var/datum/objective/lunatic/loony = new()
	objectives += loony
	lunatic_obj = loony
	return ..()


/// Runs when the moon heretic creates us, used to give the lunatic a master
/datum/antagonist/lunatic/proc/set_master(datum/mind/heretic_master, mob/living/carbon/human/heretic_body)
	src.ascended_heretic = heretic_master
	src.ascended_body = heretic_body

	lunatic_obj.master = heretic_master
	lunatic_obj.update_explanation_text()

	to_chat(owner, span_boldnotice("Разрушь ложь, спаси правду служа [heretic_master] - лидеру Лунатиков!"))


/datum/antagonist/lunatic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction |= FACTION_HERETIC
	add_team_hud(our_mob, /datum/antagonist/lunatic)
	ADD_TRAIT(our_mob, TRAIT_MADNESS_IMMUNE, UID())

	var/obj/effect/proc_holder/spell/lunatic_track/moon_track = new /obj/effect/proc_holder/spell/lunatic_track()
	var/obj/effect/proc_holder/spell/touch/mansus_grasp/mad_touch = new /obj/effect/proc_holder/spell/touch/mansus_grasp()
	our_mob.mind.AddSpell(mad_touch)
	our_mob.mind.AddSpell(moon_track)


/datum/antagonist/lunatic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction -= FACTION_HERETIC


/datum/objective/lunatic
	explanation_text = "Помогите своему мастеру. Если вы видите это, прокрутите чат вверх, чтобы узнать, кто это, и напишите баг-репорт."
	var/datum/mind/master
	// If the person with this objective is a lunatic master
	var/is_master = FALSE


/datum/objective/lunatic/update_explanation_text()
	. = ..()
	if(is_master)
		explanation_text = "Используйте лунатиков для достижеиния своих целей!"
		return

	explanation_text = "Помогите лидеру Лунатиков. Лидер - [master.current.real_name]. Не вредите другим лунатикам!"


// Lunatic master
/datum/antagonist/lunatic/master
	name = "Лидер Лунатиков"
	antag_hud_name = "lunatic_master"


/datum/antagonist/lunatic/master/on_gain()
	var/datum/objective/lunatic/loony = new()
	objectives += loony
	loony.is_master = TRUE
	loony.update_explanation_text()
	return ..()


/datum/antagonist/lunatic/master/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	add_team_hud(our_mob, /datum/antagonist/lunatic)
