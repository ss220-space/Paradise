
/datum/heretic_knowledge/reroll_targets
	drafting_tier = 2
	name = "Неустанное Сердцебиение"
	desc = "Позволяет использовать колокольчик (цветок), книгу и комбинезон, на руне \
			чтобы изменить цели жертвоприношения."
	gain_text = "Отдайте своё сердце принципам. Только тогда они могут называться нерушимыми."
	required_atoms = list(
		/obj/item/reagent_containers/food/snacks/grown/harebell = 1,
		/obj/item/book = 1,
		/obj/item/clothing/under = 1,
	)
	cost = 1
	research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "gaze"


/datum/heretic_knowledge/reroll_targets/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		loc.balloon_alert(user, "нет живого сердца!")
		return FALSE

	return TRUE


/datum/heretic_knowledge/reroll_targets/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	for(var/mob/living/carbon/human/target as anything in heretic_datum.sac_targets)
		heretic_datum.remove_sacrifice_target(target)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user, heretic_datum = heretic_datum))
		loc.balloon_alert(user, "нет подходящих целей!")
		return FALSE

	return TRUE


/datum/heretic_knowledge/hypnosis_ritual
	drafting_tier = 2
	name = "Раскрытие Разума"
	desc = "Обнажает разум язычника перед ужасами Обители, гипнотизируя его."
	transmute_text = "Преобразуйте скальпель, осколок стекла, лист бумаги и живого язычника."
	notice = "Язычник будет загипнотизирован тем, что написано на предоставленной бумаге.\
		<br>Если у язычника стоит имплант защиты разума, тот будет уничтожен — но итоговый гипноз может оказаться не таким, как вы ожидали.\
		<br>На других еретиков этот ритуал не действует."
	gain_text = "Моё восхождение было одиноким, но я понял, что так быть не должно. \
		Я могу показать им истину. Их слабые смертные умы могут не выдержать откровения, но из пепла восстанет феникс — свободный и истинный."
	required_atoms = list(
		/obj/item/scalpel = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
		/mob/living/carbon/human = 1,
	)
	cost = 2
	research_tree_icon_path = 'icons/mob/screen_alert.dmi'
	research_tree_icon_state = "hypnosis"


/datum/heretic_knowledge/hypnosis_ritual/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/mob/living/carbon/human/victim in atoms)
		if(victim.stat == DEAD || isheretic(victim) || victim.has_trauma_type(/datum/brain_trauma/hypnosis))
			atoms -= victim

	var/has_paper = FALSE
	var/has_written_text = FALSE
	for(var/obj/item/paper/paper in atoms)
		has_paper = TRUE
		if(paper.info)
			has_written_text = TRUE

	if(!has_written_text && has_paper)
		loc.balloon_alert(user, "напишите гипноз на бумаге!")
		return FALSE

	return ..()


/datum/heretic_knowledge/hypnosis_ritual/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/hypnosis_text = ""
	for(var/obj/item/paper/paper in selected_atoms)
		hypnosis_text += "[STRIP_HTML_FULL(paper.info, MAX_MESSAGE_LEN)] "

	hypnosis_text = trim(hypnosis_text, MAX_MESSAGE_LEN)
	for(var/mob/living/carbon/human/victim in selected_atoms)
		var/specific_hypnosis_text = (ismindshielded(victim) || !hypnosis_text) ? pick_list(HERETIC_INFLUENCE_FILE, "hypnosis") : hypnosis_text
		for(var/obj/item/implant/mindshield/shield in victim)
			shield.removed(victim)
			qdel(shield)

		selected_atoms -= victim
		var/datum/brain_trauma/hypnosis/trauma = new(specific_hypnosis_text)
		victim.gain_trauma(trauma, TRAUMA_RESILIENCE_LOBOTOMY)

	return TRUE


/datum/heretic_knowledge/mad_mask
	drafting_tier = 3
	name = "Маска Безумия"
	desc = "Позволяет создать \"Маску Безумия\".<br>\
			Маска вселяет страх в язычников, которые её видят, вызывая снижение выносливости, галлюцинации и безумие.<br>\
			Её также можно надеть на язычника силой, чтобы он не смог её снять..."
	transmute_text = "Преобразуйте любую маску, четыре зажжённые свечи, стандубинку и печень."
	gain_text = "Дозор носил на службе странное облачение. Оно позволяло ходить по городу, оставаясь незамеченным для толпы."
	required_atoms = list(
		/obj/item/organ/internal/liver = 1,
		/obj/item/melee/baton/security = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/candle = 4,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/masks.dmi'
	research_tree_icon_state = "mad_mask"


/datum/heretic_knowledge/mad_mask/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/candle/candle in atoms)
		if(!candle.lit)
			atoms -= candle
