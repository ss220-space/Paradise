// Sidepaths for knowledge between Void and Blade.

/datum/heretic_knowledge_tree_column/void_to_blade
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/void
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/blade

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/limited_amount/risen_corpse
	tier2 = /datum/heretic_knowledge/rune_carver
	tier3 = /datum/heretic_knowledge/limited_amount/summon/maid_in_mirror


/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Разрушенный ритуал"
	desc = "Позволяет трансмутировать труп с душой, пару латексных или нитриловых перчаток и любой костюм, \
			чтобы создать Разбитого Восставшего. \
			Разбитые Восставшие — сильные гули со 125 единицами здоровья, но неспособные держать предметы. \
			Вместо рук у них два грозных оружия. Вы можете создать только одно Разбитого Восставшего раз."
	gain_text = "Я видел, как холодная, раздирающая сила вернула этот труп к жизни. \
				Когда он движется, раздаётся хруст, словно внутри него пересыпаются осколки стекла. \
				Его руки больше не похожи на человеческие. \
				Вместо каждого из кулаков - грозное месиво острых костяных осколков."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/color/latex = 1,
	)
	cost = 1

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"


/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue

		if(!IS_VALID_GHOUL_MOB(body))
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] в слишком плохом состоянии, чтобы превратиться в гуля."))
			continue

		if(!body.mind)
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] не име[pluralize_ru(body.gender, "е", "ю")]т разума, а значит не мо[pluralize_ru(body.gender, "же", "гу")]т стать гулём."))
			continue

		if(!body.client && !body.mind.get_ghost())
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] не име[pluralize_ru(body.gender, "е", "ю")]т души, а значит не мо[pluralize_ru(body.gender, "же", "гу")]т стать гулём."))
			continue

		// We will only accept valid bodies with a mind, or with a ghost connected that used to control the body
		selected_atoms += body
		return TRUE

	loc.balloon_alert(user, "нет подходящего тела!")
	return FALSE


/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "нет подходящего трупа!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "нет подходящего трупа!")
		return FALSE

	selected_atoms -= soon_to_be_ghoul
	make_risen(user, soon_to_be_ghoul)
	return TRUE


/// Make [victim] into a shattered risen ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/make_risen(mob/living/user, mob/living/carbon/human/victim)
	//user.log_message("created a shattered risen out of [key_name(victim)].", LOG_GAME)
	//victim.log_message("became a shattered risen of [key_name(user)]'s.", LOG_VICTIM, log_globally = FALSE)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a shattered risen, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		RISEN_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_risen)),
		CALLBACK(src, PROC_REF(remove_from_risen)),
	)


/// Callback for the ghoul status effect - what effects are applied to the ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
	LAZYADD(created_items, WEAKREF(risen))
	risen.AddComponent(/datum/component/mutant_hands, mutant_hand_path = /obj/item/mutant_hand/shattered_risen)


/// Callback for the ghoul status effect - cleaning up effects after the ghoul status is removed.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
	LAZYREMOVE(created_items, WEAKREF(risen))
	qdel(risen.GetComponent(/datum/component/mutant_hands))


#undef RISEN_MAX_HEALTH


/// The "hand" "weapon" used by shattered risen
/obj/item/mutant_hand/shattered_risen
	name = "месиво костяных осколков"
	desc = "То, что когда-то было обычным человеческим кулаком, \
			теперь является месивом из острых костяных осколков."
	color = "#001aff"
	hitsound = 'sound/effects/glassbr1.ogg'
	force = 25
	//wound_bonus = -30
	//bare_wound_bonus = 15
	//demolition_mod = 1.5
	sharp = TRUE


/obj/item/mutant_hand/shattered_risen/get_ru_names()
	return list(
		NOMINATIVE = "месиво костяных осколков",
		GENITIVE = "месива костяных осколков",
		DATIVE = "месиву костяных осколков",
		ACCUSATIVE = "месиво костяных осколков",
		INSTRUMENTAL = "месивом костяных осколков",
		PREPOSITIONAL = "месиве костяных осколков",
	)


/datum/heretic_knowledge/rune_carver
	name = "Разделочный Нож"
	desc = "Позволяет преобразовать нож, осколок стекла и лист бумаги в разделочный нож. \
			Разделочный нож позволяет создавать руны - ловушки, срабатывающие при \
			наступании на них. \
			Также служит неплохим метательным оружием."
	gain_text = "Высеченный, вырезанный... ныне вечный. Во всём скрыта сила. Я могу раскрыть её! \
				Я могу высечь монолит, чтобы сбросить цепи!"

	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 1


	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "rune_carver"


/datum/heretic_knowledge/limited_amount/summon/maid_in_mirror
	name = "Горничная в Зеркале"
	desc = "Позволяет трансмутировать лист бумаги, мыло и пару лёгких, \
			чтобы создать Горничную в Зеркеле. Горничные в Зеркеле — достойные бойцы, способные \
			становиться бестелесными, появляясь в зеркальном мире и выходя из него, служа мощными \
			разведчиками и засадниками. Однако они уязвимы для взгляда смертных и получают урон при осмотре."
	gain_text = "В каждом отражении — врата в невообразимый мир полный цветов, которых никогда никто не видел. \
				Пол — стекло, а стены — ножи. Каждый шаг ранит, если у вас нет проводника."

	required_atoms = list(
		/obj/item/paper = 1,
		/obj/item/soap = 1,
		/obj/item/organ/internal/lungs = 1,
	)
	cost = 1

	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror
