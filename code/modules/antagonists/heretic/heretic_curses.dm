/*!
 * Contains all the curses a heretic can cast using their upgraded codex
 */

/datum/heretic_knowledge/curse
	abstract_parent_type = /datum/heretic_knowledge/curse
	/// How far can we curse people?
	var/max_range = 64
	/// The duration of the curse
	var/duration = 1 MINUTES
	/// What color do we outline cursed folk with?
	var/curse_color = "#dadada"
	/// A list of all the fingerprints that were found on our atoms, in our last go at the ritual
	var/list/fingerprints
	/// A list of all the blood samples that were found on our atoms, in our last go at the ritual
	var/list/blood_samples


/datum/heretic_knowledge/curse/recipe_snowflake_check(mob/living/carbon/human/user, list/atoms, list/selected_atoms, turf/loc)
	fingerprints = list()
	blood_samples = list()
	var/atom/blood_owner = atoms[1]
	var/datum/reagent/blood = blood_owner.reagents.has_reagent("blood")
	if(!blood)
		return FALSE

	fingerprints += blood_owner.fingerprints
	blood_samples.Add(blood?.data["blood_DNA"])
	return blood?.data["blood_DNA"]


/datum/heretic_knowledge/curse/on_finished_recipe(mob/living/user, list/selected_atoms,  turf/loc)
	// Potential targets is an assoc list of [names] to [human mob ref].
	var/list/potential_targets = list()

	for(var/datum/mind/crewmember as anything in SSticker.minds)
		var/mob/living/carbon/human/human_to_check = crewmember.current
		if(!istype(human_to_check) || human_to_check.stat == DEAD || !human_to_check.dna)
			continue

		var/their_prints = md5(human_to_check.dna.uni_identity)
		var/their_blood = copytext(human_to_check.dna.unique_enzymes, 1, 0)
		if(!fingerprints[their_prints] && !blood_samples[their_blood])
			continue

		potential_targets["[human_to_check.real_name]"] = human_to_check

	if(potential_targets.len == 0)
		user.balloon_alert(user, "нет подходящих ДНК!")
		return FALSE

	var/chosen_mob = tgui_input_list(user, "Выберите жертву, которую хотите проклясть.", name, sort_list(potential_targets, GLOBAL_PROC_REF(cmp_text_asc)))
	if(isnull(chosen_mob))
		return FALSE

	var/mob/living/carbon/human/to_curse = potential_targets[chosen_mob]
	if(QDELETED(to_curse))
		loc.balloon_alert(user, "не подходящая цель!")
		return FALSE

	// Yes, you COULD curse yourself, not sure why but you could
	if(to_curse == user)
		var/are_you_sure = tgui_alert(user, "Вы уверены что хотите проклясть себя?", name, list("Да", "Нет"))
		if(are_you_sure == "Нет")
			return FALSE

	if(!ask_for_input(user))
		return FALSE

	var/turf/curse_turf = get_turf(to_curse)
	if(curse_turf.z != loc.z || get_dist(curse_turf, loc) > max_range * 1.5) // Give a bit of leeway on max range for people moving around
		loc.balloon_alert(user, "цель слишком далеко!")
		return FALSE

	if(isheretic(to_curse) && to_curse != user)
		to_chat(user, span_warning("Связь жертвы с Мансусом слишком крепка. Вы не можете проклясть [genderize_ru(to_curse.gender, "его", "ее", "его", "их")]."))
		return TRUE

	if(to_curse.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY, charge_cost = 0))
		to_chat(to_curse, span_warning("На мгновение вас охватывает жуткий холод."))
		return TRUE

	var/obj/item/codex_cicatrix/morbus/cursed_book = locate() in selected_atoms
	curse(to_curse, cursed_book)
	to_chat(user, span_hierophant("Вы применяете \"[name]\". Ваша цель - [to_curse.real_name]."))

	fingerprints = null
	blood_samples = null

	for(var/atom/to_drain in selected_atoms)
		if(!to_drain.reagents?.reagent_list)
			continue

		for(var/datum/reagent/to_match in to_drain.reagents.reagent_list)
			if(to_match.data["blood_DNA"] != to_curse.dna.unique_enzymes)
				continue

			to_drain.reagents.remove_reagent(to_match.type, 5)

	return TRUE

/**
 * Calls a curse onto [chosen_mob].
 */
/datum/heretic_knowledge/curse/proc/curse(mob/living/carbon/human/chosen_mob, obj/item/codex_cicatrix/morbus/cursing_book)
	SHOULD_CALL_PARENT(TRUE)

	if(duration > 0)
		addtimer(CALLBACK(src, PROC_REF(uncurse), chosen_mob), duration)

	if(!curse_color)
		return

	chosen_mob.add_filter(name, 2, list("type" = "outline", "color" = curse_color, "size" = 1))

/**
 * Removes a curse from [chosen_mob]. Used in timers / callbacks.
 */
/datum/heretic_knowledge/curse/proc/uncurse(mob/living/carbon/human/chosen_mob)
	SHOULD_CALL_PARENT(TRUE)

	if(QDELETED(chosen_mob))
		return

	if(!curse_color)
		return

	chosen_mob.remove_filter(name)

/**
 * Asks the user for input (Optional)
 * Return TRUE to finish the curse
 * Return FALSE to cancel the curse
 */
/datum/heretic_knowledge/curse/proc/ask_for_input(mob/living/user)
	return TRUE

//---- Curse of Paralysis

/datum/heretic_knowledge/curse/paralysis
	abstract_parent_type = /datum/heretic_knowledge/curse/paralysis
	name = "Проклятье Паралича"
	desc = "Позволяет через жертвоприношение топора, левой и правой ноги, наложить проклятие паралича на члена экипажа. \
			Пока жертва проклята, она не сможет ходить. Вы можете дополнительно использовать предмет, которого коснулась жертва \
			или который покрыт кровью жертвы, чтобы продлить проклятие."
	gain_text = "Плоть слаба. Покажи им насколько она ненадежна. Покажи им насколько она хрупка."

	duration = 5 MINUTES
	curse_color = "#f19a9a"

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "curse_paralysis"


/datum/heretic_knowledge/curse/paralysis/curse(mob/living/carbon/human/chosen_mob)
	if(chosen_mob.usable_legs <= 0) // What're you gonna do, curse someone who already can't walk?
		to_chat(chosen_mob, span_notice("На мгновение вы чувствуете легкое покалывание в ногах. Странно."))
		return

	to_chat(chosen_mob, span_danger("Вы внезапно понимаете что больше не чувствуете ног!"))
	ADD_TRAIT(chosen_mob, TRAIT_FLOORED, type)
	return ..()

/datum/heretic_knowledge/curse/paralysis/uncurse(mob/living/carbon/human/chosen_mob)
	if(QDELETED(chosen_mob))
		return

	REMOVE_TRAIT(chosen_mob, TRAIT_FLOORED, type)
	if(chosen_mob.usable_legs > 1)
		to_chat(chosen_mob, span_green("Вы внезапно снова начинаете чувствовать свои ноги!"))

	return ..()

//---- Curse of Corrosion

/datum/heretic_knowledge/curse/corrosion
	abstract_parent_type = /datum/heretic_knowledge/curse/corrosion
	name = "Проклятье Болезни"
	desc = "Позволяет через жертвоприношение кусачек, лужи рвоты и сердца, наложить проклятие болезни на члена экипажа. \
			Пока жертва проклята, её будет постоянно тошнить, а органы будут постоянно получать повреждения. \
			Вы можете дополнительно использовать предмет, которого коснулась жертва или который был покрыт ее кровью, \
			чтобы продлить проклятие."
	gain_text = "Плоть недолговечна. Ее старение не остановить, так-же как не остановить ржавение металлов. Покажи им насколько она хрупка."

	duration = 3 MINUTES
	curse_color = "#c1ffc9"

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "curse_corrosion"

/datum/heretic_knowledge/curse/corrosion/curse(mob/living/carbon/human/chosen_mob)
	to_chat(chosen_mob, span_danger("Вам резко стало очень плохо..."))
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)
	return ..()

/datum/heretic_knowledge/curse/corrosion/uncurse(mob/living/carbon/human/chosen_mob)
	if(QDELETED(chosen_mob))
		return

	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)
	to_chat(chosen_mob, span_green("Ваше самочувствие резко улучшилось."))
	return ..()

//---- Curse of Transmutation

/datum/heretic_knowledge/curse/transmutation
	abstract_parent_type = /datum/heretic_knowledge/curse/transmutation
	name = "Проклятье Трансмутации"
	duration = 0 // Infinite curse, it breaks when our codex is destroyed
	curse_color = NONE
	/// What species we are going to turn our victim in to
	var/chosen_species

/datum/heretic_knowledge/curse/transmutation/ask_for_input(mob/living/user)
	var/list/chooseable_races = list(
		"Человек" = /datum/species/human,
		"Унати" = /datum/species/unathi,
		"Таяран" = /datum/species/tajaran,
		"Вульпканин" = /datum/species/vulpkanin,
		"Скрелл" = /datum/species/skrell,
		"Вокс" = /datum/species/vox,
		"Кидан" = /datum/species/kidan,
		"Слаймочеловек" = /datum/species/slime,
		"Серый" = /datum/species/grey,
		"Диона" = /datum/species/diona,
		"Драск" = /datum/species/drask,
		"Врин" = /datum/species/wryn,
		"Ниан" = /datum/species/moth
	)

	var/species_name = tgui_input_list(user, "Выберите расу", "Выберите расу, в которую хотите превратить жертву.", chooseable_races)
	if(!species_name)
		return FALSE

	chosen_species = chooseable_races[species_name]
	return ..()

/datum/heretic_knowledge/curse/transmutation/curse(mob/living/carbon/human/chosen_mob, obj/item/codex_cicatrix/morbus/cursing_book)
	if(chosen_mob.dna.species == chosen_species)
		to_chat(chosen_mob, span_warning("Вы чувствуете что превращаетесь в... себя?"))
		return

	chosen_mob.apply_status_effect(/datum/status_effect/race_swap, chosen_species)
	cursing_book.transmuted_victims += chosen_mob
	to_chat(chosen_mob, span_danger("Вы чувствуете, что ваше тело принимает новую форму."))
	return ..()

/datum/heretic_knowledge/curse/transmutation/uncurse(mob/living/carbon/human/chosen_mob)
	if(QDELETED(chosen_mob))
		return

	chosen_mob.remove_status_effect(/datum/status_effect/race_swap)
	return ..()

/datum/status_effect/race_swap
	id = "race_swap"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	tick_interval = -1
	/// What species were we before this effect was ever applied on us
	var/datum/old_species

/datum/status_effect/race_swap/on_creation(mob/living/carbon/human/new_owner, datum/species/new_species)
	. = ..()
	var/mob/living/carbon/human/human = owner
	human.set_species(new_species)

/datum/status_effect/race_swap/on_apply()
	if(!iscarbon(owner))
		return FALSE

	var/mob/living/carbon/carbon_owner = owner
	if(!old_species)
		old_species = carbon_owner.dna.species

	return ..()

/datum/status_effect/race_swap/be_replaced()
	var/mob/living/carbon/human/human = owner
	human.set_species(old_species.type)
	return ..()

/datum/status_effect/race_swap/on_remove()
	. = ..()
	var/mob/living/carbon/human/human = owner
	human.set_species(old_species)

//---- Curse of Indulgence

/datum/heretic_knowledge/curse/indulgence
	abstract_parent_type = /datum/heretic_knowledge/curse/indulgence
	name = "Проклятье Восприимчивости"
	duration = 8 MINUTES
	curse_color = COLOR_MAROON

/datum/heretic_knowledge/curse/indulgence/curse(mob/living/carbon/human/chosen_mob)
	chosen_mob.gain_trauma(/datum/brain_trauma/severe/flesh_desire, TRAUMA_RESILIENCE_MAGIC)
	chosen_mob.nutrition = NUTRITION_LEVEL_STARVING
	return ..()

/datum/heretic_knowledge/curse/indulgence/uncurse(mob/living/carbon/human/chosen_mob)
	if(QDELETED(chosen_mob))
		return

	chosen_mob.cure_trauma_type(/datum/brain_trauma/severe/flesh_desire, TRAUMA_RESILIENCE_MAGIC)
	return ..()
