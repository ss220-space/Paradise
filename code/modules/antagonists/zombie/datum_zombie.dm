/datum/antagonist/zombie
	name = "Zombie"
	antag_hud_name = "hudzombie"
	antag_hud_type = ANTAG_HUD_ZOMBIE
	special_role = SPECIAL_ROLE_ZOMBIE
	clown_gain_text = "М-мозгии... Хонк..."
	clown_removal_text = "Вы снова чувствуете себя забавным."
	wiki_page_name = "Zombie"
	russian_wiki_name = "Зомби"
	has_skill_bonus = FALSE
	var/list/old_languages = list() // someone make this better to prevent langs changing if species changes while zombie somehow
	var/static/list/zombie_traits = list(TRAIT_LANGUAGE_LOCKED, TRAIT_ABSTRACT_HANDS, TRAIT_NO_BREATH)
	var/datum/unarmed_attack/claws/claw_attack
	var/chosen_disease
	var/datum/zombie_class/class

// possibly upgrades for the zombies after eating brains? Better vision (/datum/action/changeling/augmented_eyesight), better weapons (armblade), better infection, more inhereint armor (physiology)
// ability to find nearby brains to eat (like cling/vamp ability to track people around them)
/datum/antagonist/zombie/New(chosen_plague)
	chosen_disease = chosen_plague
	..()

/datum/antagonist/zombie/on_gain()
	. = ..()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE))
		var/datum/action/cooldown/spell/zombie_claws/plague_claws/plague_claws = new()
		plague_claws.disease = chosen_disease
		owner.AddSpell(plague_claws)
		owner.AddSpell(new /datum/action/cooldown/spell/pointed/zombie_leap)
	else
		owner.AddSpell(new /datum/action/cooldown/spell/select_zombie_class)
	claw_attack = new /datum/unarmed_attack/claws()
	owner.current.drop_item_ground()

/datum/antagonist/zombie/Destroy(force, ...)
	QDEL_NULL(claw_attack)
	return ..()

/datum/antagonist/zombie/detach_from_owner()
	if(HAS_TRAIT(owner, TRAIT_PLAGUE_ZOMBIE))
		owner.RemoveSpell(/datum/action/cooldown/spell/zombie_claws/plague_claws)
		owner.RemoveSpell(/datum/action/cooldown/spell/pointed/zombie_leap)
	else
		owner.RemoveSpell(/datum/action/cooldown/spell/select_zombie_class)
	class?.remove(owner.current)
	return ..()

/datum/antagonist/zombie/greet()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE)) // we shouldnt get a second welcome message for wiz zombies
		return
	var/list/messages = list()
	. = messages
	if(owner && owner.current)
		messages.Add(span_userdanger(span_zombie("Вы [special_role]!")))
		messages.Add(span_zombie("Вы чувствуете, как ваше сердце останавливается, но что-то не так... жизнь не покинула ваше изломанное тело. Вы ощущаете лишь глубокий и неизменный голод, который не способна остановить даже смерть."))

/datum/antagonist/zombie/finalize_antag()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE)) // we shouldnt get a second welcome message for wiz zombies
		return
	var/list/messages = list()
	. = messages
	if(owner && owner.current)
		messages.Add("<br>[span_notice("Вы можете использовать свои когти, чтобы взламывать двери и раскалывать повреждённые черепа. Как только их голова вскрыта, используйте пустую руку, чтобы съесть их мозги. Либо схватите кого-нибудь агрессивно и нанесите им урон, чтобы укусить и заразить их. Вы восстанавливаетесь медленно, но быстрее — в темноте; после смерти вы будете медленно оживать и пробуждаться.")]")
		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/zomboidalert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/zombie/apply_innate_effects(mob/living/mob_override)
	var/mob/living/L = ..()

	old_languages = L.languages.Copy()
	for(var/datum/language/lang as anything in L.languages)
		L.remove_language(lang.name)
	L.add_language(LANGUAGE_ZOMBIE)
	L.default_language = GLOB.all_languages[LANGUAGE_ZOMBIE]
	L.add_movespeed_modifier(class?.movespeed_modifier || /datum/movespeed_modifier/zombie)
	if(!HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE))
		L.extinguish_light() // zombies prefer darkness
	for(var/trait in zombie_traits)
		ADD_TRAIT(L, trait, ZOMBIE_TRAIT)
	if(!L.HasDisease(/datum/disease/virus/zombie))
		var/datum/disease/virus/zombie/zomb = new ()
		zomb.Contract(L)
		zomb = locate(/datum/disease/virus/zombie) in L.diseases
		zomb.stage = 7

/datum/antagonist/zombie/remove_innate_effects(mob/living/mob_override)
	var/mob/living/L = ..()
	if(!ishuman(L))
		STOP_PROCESSING(SSobj, src) // This is to handle when they transfer into a headslug (simple animal). We shouldn't process in that case.
	for(var/trait in zombie_traits)
		REMOVE_TRAIT(L, trait, ZOMBIE_TRAIT)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/zombie)
	L.remove_language(LANGUAGE_ZOMBIE)
	for(var/datum/language/lang as anything in old_languages)
		L.add_language(lang.name)
	L.default_language = null

/datum/antagonist/zombie/add_owner_to_gamemode()
	SSticker.mode.zombies |= owner

/datum/antagonist/zombie/remove_owner_from_gamemode()
	SSticker.mode.zombies -= owner

/datum/antagonist/zombie/on_body_transfer(mob/living/old_body, mob/living/new_body)
	if(!new_body.HasDisease(/datum/disease/virus/zombie))
		owner.remove_antag_datum(/datum/antagonist/zombie)
		return
	return ..()

/datum/antagonist/zombie/give_objectives()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE))
		return
	add_objective(/datum/objective/zombie)

/datum/objective/zombie
	explanation_text = "«Голод растёт внутри нас — нам нужно пировать мозгами незаражённых. Царапайте, кусайте и распространяйте чуму."
	needs_target = FALSE
	completed = TRUE
