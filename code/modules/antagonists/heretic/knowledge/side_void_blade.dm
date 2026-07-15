


/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	drafting_tier = 3
	name = "Разрушенный Ритуал"
	desc = "Позволяет трансмутировать труп с душой, пару латексных или нитриловых перчаток и любой костюм, \
			чтобы создать Разбитого Восставшего. \
			Разбитые Восставшие — сильные гули со 125 единицами здоровья, но неспособные держать предметы. \
			Вместо рук у них два грозных оружия. Вы можете создать только одного Разбитого Восставшего за раз."
	gain_text = "Я видел, как холодная, раздирающая сила вернула этот труп к жизни. \
				Когда он движется, раздаётся хруст, словно внутри него пересыпаются осколки стекла. \
				Его руки больше не похожи на человеческие. \
				Вместо каждого из кулаков — грозное месиво острых костяных осколков."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/color/latex = 1,
	)
	cost = 2

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"


/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue

		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] в слишком плохом состоянии, чтобы превратиться в гуля."))
			continue

		if(!body.mind)
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] не име[PLUR_ET_YUT(body)] разума, а значит не мо[PLUR_JET_GUT(body)] стать гулём."))
			continue

		if(!body.client && !body.mind.get_ghost())
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] не име[PLUR_ET_YUT(body)] души, а значит не мо[PLUR_JET_GUT(body)] стать гулём."))
			continue

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
	name = "shattered risen fist"
	desc = "То, что когда-то было обычным человеческим кулаком, \
			теперь является месивом из острых костяных осколков."
	color = "#001aff"
	hitsound = SFX_SHATTER
	force = 16
	sharp = TRUE


/obj/item/mutant_hand/shattered_risen/get_ru_names()
	return alist(
		NOMINATIVE = "месиво костяных осколков",
		GENITIVE = "месива костяных осколков",
		DATIVE = "месиву костяных осколков",
		ACCUSATIVE = "месиво костяных осколков",
		INSTRUMENTAL = "месивом костяных осколков",
		PREPOSITIONAL = "месиве костяных осколков",
	)


/datum/heretic_knowledge/rune_carver
	drafting_tier = 2
	name = "Рунный Резак"
	desc = "Позволяет преобразовать нож, осколок стекла и лист бумаги в рунный резак. \
			Рунный резак позволяет создавать руны-ловушки, срабатывающие при \
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
	drafting_tier = 3
	name = "Дева-из-Зеркала"
	desc = "Позволяет трансмутировать пять листов стекла, любой костюм и пару лёгких, \
			чтобы создать Деву-из-Зеркала. Девы-из-Зеркала — достойные бойцы, способные \
			становиться бестелесными, появляясь в зеркальном мире и выходя из него, служа мощными \
			разведчиками и засадниками. Их атаки также накладывают заряд холода пустоты."
	gain_text = "В каждом отражении — врата в невообразимый мир полный цветов, которых никогда никто не видел. \
				Пол — стекло, а стены — ножи. Каждый шаг ранит, если у вас нет проводника."

	required_atoms = list(
		/obj/item/stack/sheet/glass = 5,
		/obj/item/clothing/suit = 1,
		/obj/item/organ/internal/lungs = 1,
	)
	cost = 2

	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror
