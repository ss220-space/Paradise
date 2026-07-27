/// Global list of all heretic knowledge that have is_starting_knowledge = TRUE. List of PATHS.
GLOBAL_LIST_INIT(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(initial(knowledge.is_starting_knowledge) != TRUE)
			continue

		. += knowledge


/// The base heretic knowledge. Grants the Хватка Обители spell.
/datum/heretic_knowledge/spell/basic
	name = "Рассвет"
	desc = "Начинает ваше путешествие по Обители. \
			Даёт вам \"Хватку Обители\", мощное и улучшаемое \
			заклинание, которое можно применить без фокуса."
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "static"
	spell_to_add = /obj/effect/proc_holder/spell/touch/mansus_grasp
	is_starting_knowledge = TRUE

/*
/datum/heretic_knowledge/spell/basic/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))


/datum/heretic_knowledge/spell/basic/proc/on_grasp_cast(mob/living/carbon/cast_on, obj/effect/proc_holder/spell/touch/touch_spell)
	SIGNAL_HANDLER

	if(!istype(touch_spell, spell_to_add))
		return NONE

	var/obj/item/twohanded/fishing_rod/held_rod = cast_on.get_active_hand()
	if(!istype(held_rod, /obj/item/twohanded/fishing_rod) || HAS_TRAIT(held_rod, TRAIT_ROD_MANSUS_INFUSED))
		return NONE

	INVOKE_ASYNC(cast_on, TYPE_PROC_REF(/atom/movable, say), message = "R'CH T'H F'SH!", forced = "fishing rod infusion invocation")
	playsound(cast_on, /obj/effect/proc_holder/spell/touch/mansus_grasp::sound, 15)
	cast_on.visible_message(span_notice("[cast_on] snaps [cast_on.p_their()] fingers next to [held_rod], covering it in a burst of purple flames!"))

	ADD_TRAIT(held_rod, TRAIT_ROD_MANSUS_INFUSED, held_rod.UID())
	held_rod.difficulty_modifier -= 20
	RegisterSignal(held_rod, COMSIG_FISHING_ROD_CAUGHT_FISH, PROC_REF(unfuse))
	held_rod.add_filter("mansus_infusion", 2, list("type" = "outline", "color" = COLOR_VOID_PURPLE, "size" = 1))
	return COMPONENT_CAST_HANDLESS


/datum/heretic_knowledge/spell/basic/proc/unfuse(obj/item/fishing_rod/item, reward, mob/user)
	if(reward != FISHING_INFLUENCE && !prob(35))
		return

	item.remove_filter("mansus_infusion")
	REMOVE_TRAIT(item, TRAIT_ROD_MANSUS_INFUSED, item.UID())
	item.difficulty_modifier += 20
*/
/// Gives the heretic a living heart, and a ritual to turn their heart into one if lost.
/datum/heretic_knowledge/living_heart
	name = "Живое Сердце"
	desc = "Даёт вам \"Живое Сердце\", позволяющее отслеживать цели жертвоприношения. \
			Если вы потеряете сердце, вы можете использовать мак и лужу крови, \
			чтобы переобразовать своё сердце в Живое Сердце. Если ваше сердце кибернетическое, \
			вы не сможете переобразовать его."
	required_atoms = list(
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Knowing how to remake your heart is important
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "living_heart"


/datum/heretic_knowledge/living_heart/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	var/obj/item/organ/where_to_put_our_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	if(!is_valid_heart(where_to_put_our_heart))
		where_to_put_our_heart = null

	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs,
			INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver,
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/look_for_backup = user.get_organ_slot(backup_slot)
			if(!is_valid_heart(look_for_backup))
				continue

			where_to_put_our_heart = look_for_backup
			our_heretic.living_heart_organ_slot = backup_slot
			to_chat(user, span_boldnotice("Поскольку у вашего вида нет сердца, ваше Живое Сердце находится в ваш[GEND_EM_EI_EM_IH(look_for_backup)] [look_for_backup.declent_ru(PREPOSITIONAL)]."))
			break

	if(!where_to_put_our_heart)
		for(var/fallback_slot in list(INTERNAL_ORGAN_HEART, INTERNAL_ORGAN_BRAIN))
			var/obj/item/organ/fallback_organ = user.get_organ_slot(fallback_slot)
			if(!fallback_organ)
				continue
			where_to_put_our_heart = fallback_organ
			our_heretic.living_heart_organ_slot = fallback_slot
			to_chat(user, span_boldnotice("Поскольку ваше тело синтетическое, ваше Живое Сердце пробуждается в ваш[GEND_EM_EI_EM_IH(fallback_organ)] [fallback_organ.declent_ru(PREPOSITIONAL)]."))
			break

	if(!where_to_put_our_heart)
		to_chat(user, span_boldnotice("У вас нет сердца, да и вообще каких-либо органов в грудной клетке. Из-за этого вы не получили Живое Сердце."))
		return

	where_to_put_our_heart.AddComponent(/datum/component/living_heart)
	desc = "Даёт вам Живое Сердце, привязанное к ваш[GEND_HIM_HER(where_to_put_our_heart)] [where_to_put_our_heart.declent_ru(DATIVE)], позволяющее отслеживать цели жертвоприношений. \
			Если вы потеряете своё [where_to_put_our_heart.declent_ru(ACCUSATIVE)], вы можете преобразовать мак и лужу крови, \
			чтобы пробудить силы Живого Сердца в ваш[GEND_EM_EI_EM_IH(where_to_put_our_heart)] [where_to_put_our_heart.declent_ru(DATIVE)]. \
			Кибернетическ[UNLINT(genderize_ru(where_to_put_our_heart.gender, "ий", "ая", "ое", "ие"))] [where_to_put_our_heart.declent_ru(NOMINATIVE)] не позвол[PLUR_IT_YAT(where_to_put_our_heart)] провести ритуал!"


/datum/heretic_knowledge/living_heart/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	if(!our_living_heart)
		return

	qdel(our_living_heart.GetComponent(/datum/component/living_heart))


/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	return invoker.has_living_heart() != HERETIC_HAS_LIVING_HEART


/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	if(QDELETED(our_living_heart))
		loc.balloon_alert(user, "провал, нет сердца!")
		return FALSE

	if(HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		loc.balloon_alert(user, "провал, способность занята!")
		return FALSE

	if(is_valid_heart(our_living_heart))
		return TRUE

	loc.balloon_alert(user, "орган не подходит!") // "heart can't be awakened!"
	return FALSE


/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	var/obj/item/organ/our_new_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	selected_atoms -= our_new_heart
	our_new_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, span_warning("Вы чувствуете как [our_new_heart.declent_ru(NOMINATIVE)] начинает яростно биться!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	return TRUE


/// Checks if the passed heart is a valid heart to become a living heart
/datum/heretic_knowledge/living_heart/proc/is_valid_heart(obj/item/organ/new_heart)
	if(QDELETED(new_heart))
		return FALSE

	if(new_heart.is_dead())
		return FALSE

	if(HASBIT(new_heart.status, ORGAN_ROBOT))
		return FALSE

	return TRUE


/// Allows the heretic to craft a spell focus, required to cast advanced spells.
/datum/heretic_knowledge/amber_focus
	name = "Янтарный Амулет"
	desc = "Позволяет преобразовать лист стекла и пару глаз в Янтарный Амулет. \
			Предоставляет носителю фокус, необходимый для использования более сложных заклинаний."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	priority = MAX_KNOWLEDGE_PRIORITY - 2 // Not as important as making a heart or sacrificing, but important enough.
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/obj/clothing/neck.dmi'
	research_tree_icon_state = "eldritch_necklace"


/datum/heretic_knowledge/spell/heretic_menu
	name = "Меню Еретика"
	desc = "Открывает меню, в котором можно изучать новые знания."
	research_tree_icon_path = 'icons/mob/actions/actions.dmi'
	research_tree_icon_state = "spell_default"
	spell_to_add = /obj/effect/proc_holder/spell/heretic_menu
	is_starting_knowledge = TRUE


/datum/heretic_knowledge/spell/cloak_of_shadows
	name = "Плащ Тьмы"
	desc = "Даёт вам заклинание \"Плащ Тьмы\". Это заклинание полностью скроет вашу личность в фиолетовом дыму \
			на три минуты, помогая вам сохранять скрытность."
	notice = "Можно применить, только пока у вас есть Живое Сердце."
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "curse"
	spell_to_add = /obj/effect/proc_holder/spell/shadow_cloak
	cost = 1
	drafting_tier = 1
	is_shop_only = TRUE

/datum/heretic_knowledge/feast_of_owls
	name = "Фестиваль Сов"
	desc = "Позволяет пройти ритуал, дающий 5 очков знаний, но блокирующий возможность вознесения. Это можно сделать только один раз."
	gain_text = "Под мягким сиянием безумия в ночи крадётся зверь. Я смирюсь со своей судьбой и позволю ему найти меня. Он насытится моими амбициями и оставит после себя знание."
	is_starting_knowledge = TRUE
	required_atoms = list()
	research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "god_transmit"
	/// amount of research points granted
	var/reward = 5


/datum/heretic_knowledge/feast_of_owls/can_be_invoked(datum/antagonist/heretic/invoker)
	return !invoker.feast_of_owls


/datum/heretic_knowledge/feast_of_owls/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/alert = tgui_alert(user, "Вы действительно хотите отказаться от своего вознесения? Это действие необратимо.", "Фестиваль Сов", list("Да", "Нет"), 30 SECONDS)
	if(alert != "Да" || QDELETED(user) || QDELETED(src) || get_dist(user, loc) > 2)
		return FALSE

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(QDELETED(heretic_datum) || heretic_datum.feast_of_owls)
		return FALSE

	. = TRUE

	heretic_datum.feast_of_owls = TRUE
	user.EyeBlind(reward * 1 SECONDS)
	user.AdjustParalysis(reward * 1 SECONDS)
	user.playsound_local(get_turf(user), 'sound/music/heretic/heretic_gain_intense.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	for(var/i in 1 to reward)
		user.emote("scream")
		playsound(loc, 'sound/items/eatfood.ogg', 100, TRUE)
		heretic_datum.adjust_knowledge_points(1)
		to_chat(user, span_danger("Вы чувствуете, как что-то невидимое разрывает самую вашу суть!"))
		user.do_jitter_animation()
		sleep(1 SECONDS)
		if(QDELETED(user) || QDELETED(heretic_datum))
			return FALSE

	to_chat(user, span_danger(span_big("Ваши амбиции разрушены, но что-то могущественное осталось после них...")))
	var/drain_message = pick_list(HERETIC_INFLUENCE_FILE, "drain_message")
	to_chat(user, span_purple(span_big("[drain_message]")))
	return .
