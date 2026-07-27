/datum/antagonist/lunatic
	name = "Лунатик"
	special_role = SPECIAL_ROLE_LUNATIC
	antag_hud_name = "lunatic"
	antag_hud_type = ANTAG_HUD_LUNATIC
	clown_gain_text = "Древние знания о Луне позволили вам преодолеть свою шутовскую натуру и научиться владеть оружием, не причиняя себе вреда."
	clown_removal_text = "По мере того, как ваши знания о Луне рассеиваются, вы возвращаетесь к своему неуклюжему, клоунскому \"я\"."
	var/datum/mind/ascended_heretic
	var/mob/living/carbon/human/ascended_body
	var/datum/objective/lunatic/lunatic_obj
	var/ismaster = FALSE


/datum/antagonist/lunatic/on_gain()
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

	if(!QDELETED(owner?.current))
		add_team_hud(owner.current, /datum/atom_hud/alternate_appearance/basic/heretic_team/lunatic, heretic_master)

	lunatic_obj.master = heretic_master
	lunatic_obj.update_explanation_text()

	to_chat(owner, span_boldnotice("Разрушь ложь, спаси правду, служа [heretic_master], — лидеру Лунатиков!"))


/datum/antagonist/lunatic/add_antag_hud(mob/living/antag_mob)
	. = ..()
	var/datum/mind/team_master = ismaster ? owner : ascended_heretic
	if(team_master)
		add_team_hud(antag_mob, /datum/atom_hud/alternate_appearance/basic/heretic_team/lunatic, team_master)

/datum/antagonist/lunatic/remove_antag_hud(mob/living/antag_mob)
	. = ..()
	remove_team_hud()


/datum/atom_hud/alternate_appearance/basic/heretic_team/lunatic/mob_should_see(mob/viewer)
	var/datum/mind/viewer_mind = viewer.mind
	if(!viewer_mind || !master_mind)
		return FALSE
	if(viewer_mind == master_mind)
		return TRUE
	var/datum/antagonist/lunatic/lunatic = viewer_mind.has_antag_datum(/datum/antagonist/lunatic)
	return lunatic?.ascended_heretic == master_mind


/datum/antagonist/lunatic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction |= FACTION_HERETIC
	ADD_TRAIT(our_mob, TRAIT_MADNESS_IMMUNE, UID())

	if(ismaster)
		return

	var/obj/effect/proc_holder/spell/lunatic_track/moon_track = new /obj/effect/proc_holder/spell/lunatic_track()
	our_mob.mind.AddSpell(moon_track)
	var/obj/effect/proc_holder/spell/touch/mansus_grasp/mad_touch = new /obj/effect/proc_holder/spell/touch/mansus_grasp()
	our_mob.mind.AddSpell(mad_touch)


/datum/antagonist/lunatic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction -= FACTION_HERETIC


/datum/objective/lunatic
	explanation_text = "Помогите своему мастеру. Если вы видите это, прокрутите чат вверх, чтобы узнать, кто это, и напишите баг-репорт."
	var/datum/mind/master
	var/is_master = FALSE


/datum/objective/lunatic/update_explanation_text()
	. = ..()
	if(is_master)
		explanation_text = "Используйте лунатиков для достижения своих целей!"
		return

	explanation_text = "Помогите лидеру Лунатиков. Лидер — [master.current.real_name]. Не вредите другим лунатикам!"


/datum/antagonist/lunatic/master
	name = "Лидер Лунатиков"
	special_role = SPECIAL_ROLE_LUNATIC_LEADER
	antag_hud_name = "lunatic_master"
	ismaster = TRUE


/datum/antagonist/lunatic/master/on_gain()
	var/datum/objective/lunatic/loony = new()
	objectives += loony
	loony.is_master = TRUE
	loony.update_explanation_text()
	return ..()
