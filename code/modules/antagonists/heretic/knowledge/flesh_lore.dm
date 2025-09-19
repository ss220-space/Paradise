/// The max amount of health a ghoul has.
#define GHOUL_MAX_HEALTH 25
/// The max amount of health a voiceless dead has.
#define MUTE_MAX_HEALTH 50

/datum/heretic_knowledge_tree_column/main/flesh
	neighbour_type_left = /datum/heretic_knowledge_tree_column/lock_to_flesh
	neighbour_type_right = /datum/heretic_knowledge_tree_column/flesh_to_void

	route = PATH_FLESH
	ui_bgr = "node_flesh"

	start = /datum/heretic_knowledge/limited_amount/starting/base_flesh
	grasp = /datum/heretic_knowledge/limited_amount/flesh_grasp
	tier1 = /datum/heretic_knowledge/limited_amount/flesh_ghoul
	mark = 	/datum/heretic_knowledge/mark/flesh_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/flesh
	unique_ability = /datum/heretic_knowledge/spell/flesh_surgery
	tier2 = /datum/heretic_knowledge/limited_amount/summon/raw_prophet
	blade = /datum/heretic_knowledge/blade_upgrade/flesh
	tier3 = /datum/heretic_knowledge/limited_amount/summon/stalker
	ascension = /datum/heretic_knowledge/ultimate/flesh_final


/datum/heretic_knowledge/limited_amount/starting/base_flesh
	name = "Голодная игра" // The Hunger Games
	desc = "Открывает вам Путь Плоти. \
			Позволяет превратить нож и лужу крови в Кровавый Клинок. \
			Вы можете создать только три клинка одновременно."
	gain_text = "Сотни из нас голодали, но не я... Я нашёл силу в своей жадности."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/effect/decal/cleanable/blood = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	limit = 3 // Bumped up so they can arm up their ghouls too.
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "flesh_blade"


/datum/heretic_knowledge/limited_amount/starting/base_flesh/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	var/datum/objective/heretic_summon/summon_objective = new()
	summon_objective.owner = our_heretic.owner
	our_heretic.objectives += summon_objective

	to_chat(user, span_hierophant("Ступив на Путь Плоти, вы получаете еще одну цель."))
	our_heretic.announce_objectives()


/datum/heretic_knowledge/limited_amount/flesh_grasp
	name = "Прикосновение Плоти"
	desc = "Ваше Прикосновение Мансуса получает способность создавать гулей из трупов с душой. \
			У гулей всего 25 единиц здоровья, но они могут эффективно использовать Кровавые Клинки. \
			Этим методом можно создавать только одного гуля за раз."
	gain_text = "Мои новые желания вели меня ко все большим и большим высотам."
	limit = 1
	cost = 1

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_flesh"


/datum/heretic_knowledge/limited_amount/flesh_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))


/datum/heretic_knowledge/limited_amount/flesh_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)


/datum/heretic_knowledge/limited_amount/flesh_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(target.stat != DEAD)
		return

	if(LAZYLEN(created_items) >= limit)
		target.balloon_alert(source, "лимит гулей!")
		return COMPONENT_BLOCK_HAND_USE

	if(!IS_VALID_GHOUL_MOB(target))
		target.balloon_alert(source, "не подходящее тело!")
		return COMPONENT_BLOCK_HAND_USE

	target.grab_ghost()

	// The grab failed, so they're mindless or playerless. We can't continue
	if(!target.mind || !target.client)
		target.balloon_alert(source, "нет души!")
		return COMPONENT_BLOCK_HAND_USE

	make_ghoul(source, target)


/// Makes [victim] into a ghoul.
/datum/heretic_knowledge/limited_amount/flesh_grasp/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	//user.log_message("created a ghoul, controlled by [key_name(victim)].", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a ghoul, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		GHOUL_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_ghoul)),
		CALLBACK(src, PROC_REF(remove_from_ghoul)),
	)


/// Callback for the ghoul status effect - Tracking all of our ghouls
/datum/heretic_knowledge/limited_amount/flesh_grasp/proc/apply_to_ghoul(mob/living/ghoul)
	LAZYADD(created_items, WEAKREF(ghoul))


/// Callback for the ghoul status effect - Tracking all of our ghouls
/datum/heretic_knowledge/limited_amount/flesh_grasp/proc/remove_from_ghoul(mob/living/ghoul)
	LAZYREMOVE(created_items, WEAKREF(ghoul))


/datum/heretic_knowledge/limited_amount/flesh_ghoul
	name = "Незавершенный ритуал"
	desc = "Позволяет преобразовать труп и мак, чтобы создать Безмолвного Мертвеца. \
			Трупу не обязательно иметь душу. \
			Безмолвные Мертвецы — немые гули с запасом здоровья всего 50 единиц, но могут \
			эффективно использовать Кровавые Клинки. \
			Вы можете создать только двух одновременно."
	gain_text = "Я нашел записи темного ритуала, незаконченного... но меня это не остановило..."
	required_atoms = list(
		/mob/living/carbon/human = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	limit = 2
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_voiceless"


/datum/heretic_knowledge/limited_amount/flesh_ghoul/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue

		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] не может стать Гулем."))
			continue

		// We'll select any valid bodies here. If they're clientless, we'll give them a new one.
		selected_atoms += body
		return TRUE

	loc.balloon_alert(user, "нет подходящего тела!")
	return FALSE


/datum/heretic_knowledge/limited_amount/flesh_ghoul/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "нет подходящего тела!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()

	if(soon_to_be_ghoul.mind && soon_to_be_ghoul.client)
		selected_atoms -= soon_to_be_ghoul
		make_ghoul(user, soon_to_be_ghoul)
		return TRUE

	message_admins("[ADMIN_LOOKUPFLW(user)] is creating a voiceless dead of a body with no player.")
	var/list/ghosts = SSghost_spawns.poll_candidates("Вы бы хотели сыграть за насильно убит[genderize_ru(soon_to_be_ghoul.gender, "ого", "ую", "ое", "ых")] [soon_to_be_ghoul.declent_ru(ACCUSATIVE)]?", \
				null, FALSE, 5 SECONDS, TRUE, source = soon_to_be_ghoul)

	if(!ghosts.len)
		loc.balloon_alert(user, "нет согласных призраков!")
		return FALSE

	var/mob/chosen_one = pick(ghosts)
	message_admins("[key_name_admin(chosen_one)] has taken control of ([key_name_admin(soon_to_be_ghoul)]) to replace an AFK player.")
	soon_to_be_ghoul.ghostize(FALSE)
	soon_to_be_ghoul.key = chosen_one.key
	selected_atoms -= soon_to_be_ghoul
	make_ghoul(user, soon_to_be_ghoul)
	return TRUE


/// Makes [victim] into a ghoul.
/datum/heretic_knowledge/limited_amount/flesh_ghoul/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	//user.log_message("created a voiceless dead, controlled by [key_name(victim)].", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a voiceless dead, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		MUTE_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_ghoul)),
		CALLBACK(src, PROC_REF(remove_from_ghoul)),
	)


/// Callback for the ghoul status effect - Tracks all of our ghouls and applies effects
/datum/heretic_knowledge/limited_amount/flesh_ghoul/proc/apply_to_ghoul(mob/living/ghoul)
	LAZYADD(created_items, WEAKREF(ghoul))
	ADD_TRAIT(ghoul, TRAIT_MUTE, MAGIC_TRAIT)


/// Callback for the ghoul status effect - Tracks all of our ghouls and applies effects
/datum/heretic_knowledge/limited_amount/flesh_ghoul/proc/remove_from_ghoul(mob/living/ghoul)
	LAZYREMOVE(created_items, WEAKREF(ghoul))
	REMOVE_TRAIT(ghoul, TRAIT_MUTE, MAGIC_TRAIT)


/datum/heretic_knowledge/mark/flesh_mark
	name = "Метка Плоти"
	desc = "Ваше Прикосновение Мансуса теперь применяет Метку Плоти. \
			Метка активируется в результате атаки вашим Кровавым клинком. \
			При активации у жертвы начинается внутреннее кровотечение."
	gain_text = "Вот тогда я их и увидел, несущих метку. Они были вне досягаемости. Они кричали и кричали."
	mark_type = /datum/status_effect/eldritch/flesh


/datum/heretic_knowledge/knowledge_ritual/flesh


/datum/heretic_knowledge/spell/flesh_surgery
	name = "Управление Плотью"
	desc = "Даёт вам заклинание «Управление Плотью». Это заклинание позволяет извлекать органы из жертв, \
			не прибегая к длительной хирургической операции. Этот процесс занимает гораздо больше времени, \
			если цель жива. Это заклинание позволяет вам исцелять ваших миньонов и призванных существ, \
			а также восстанавливать поврежденные органы до приемлемого состояния."
	gain_text = "Но они не смогли спастись от меня. \
				С каждым шагом крики становились всё громче, пока наконец \
				я не заставил их замолчать."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "mad_touch"
	spell_to_add = /obj/effect/proc_holder/spell/touch/flesh_surgery
	cost = 1


/datum/heretic_knowledge/limited_amount/summon/raw_prophet
	name = "Ритуал Сырости"
	desc = "Позволяет трансмутировать пару глаз, левую руку и лужу крови, чтобы создать Пророка Сырости. \
			Пророки Сырости обладают большой дальностью обзора, могут видеть сквозь стены, \
			временно становиться нематериальными и общаться с вами на расстоянии."
	gain_text = "Я не мог продолжать в одиночку. Я смог призвать Существо, \
				чтобы оно помогло мне увидеть больше. Крики... когда-то мучившие меня и днем и ночью, \
				теперь звучали тише. Я мог достичь своей цели."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/organ/external/arm = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/raw_prophet
	cost = 1


/datum/heretic_knowledge/blade_upgrade/flesh
	name = "Кровоточащая Cталь"
	desc = "Теперь «Кровавый клинок» поглощает кровь ваших врагов при атаке."
	gain_text = "Подобных существ было множество. Они привели меня к Маршалу. \
				Я наконец начал понимать. Небеса окрасились в алый."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_flesh"
	///What type of wound do we apply on hit
	//var/wound_type = /datum/wound/slash/flesh/severe


/datum/heretic_knowledge/blade_upgrade/flesh/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!ishuman(target) || source == target)
		return

	var/mob/living/carbon/human/human_target = target
	human_target.AdjustBlood(-25)


/datum/heretic_knowledge/limited_amount/summon/stalker
	name = "Ритуал Одиночества"
	desc = "Позволяет трансмутировать любой хвост, печень, лёгкие, ручку и лист бумаги, чтобы создать Ловца Плоти. \
			Ловцы Плоти умеют становиться нематериальными, выпускать ЭМИ, превращаться в животных или роботов, \
			а также сильны в бою."
	gain_text = "Мне удалось объединить жадность и желания в жуткого зверя. \
				Эта вечно меняющая форму масса плоти прекрасно знала мои цели."

	required_atoms = list(
		/obj/item/organ/external/tail = 1,
		///obj/item/organ/internal/stomach = 1,
		/obj/item/organ/internal/liver = 1,
		/obj/item/organ/internal/lungs = 1,
		/obj/item/pen = 1,
		/obj/item/paper = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/stalker
	cost = 1


/datum/heretic_knowledge/ultimate/flesh_final
	name = "Последний гимн священника"
	desc = "Ритуал вознесения Пути Плоти. \
			Положите 4 трупа на руну трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы сможете сбросить человеческий облик \
			и стать Повелителем Ночи, невероятно могущественным существом. \
			Один лишь акт трансформации вселяет в варваров, находящихся поблизости, сильный страх. \
			В облике Повелителя Ночи вы можете поглощать руки для исцеления и восстановления сегментов. \
			Кроме того, вы можете призвать в три раза больше Упырей и Безмолвных Мертвецов, \
			и создать бесчисленное множество клинков, чтобы вооружить их всех."
	gain_text = "При поддержке Маршала моя власть достигла пика. Трон был пуст. \
				Люди этого мира, услышьте меня, ибо время пришло! Маршал ведёт мою армию! \
				Реальность покорится ВЛАДЫКЕ НОЧИ или будет разрушена! СТАНЬТЕ СВИДЕТЕЛЯМИ МОЕГО ВОЗНЕСЕНИЯ!"
	required_atoms = list(/mob/living/carbon/human = 4)
	//ascension_achievement = /datum/award/achievement/misc/flesh_ascension
	announcement_text = "%SPOOKY% Реальность развернулась. ВОЗДЕНЬТЕ РУКИ К НЕБУ И ПОПРИВЕТСТВУЙТЕ, ВЛАДЫКУ НОЧИ! %NAME% вознесся! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_flesh.ogg'


/datum/heretic_knowledge/ultimate/flesh_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shapeshift/shed_human_form)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/limited_amount/flesh_grasp/grasp_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/flesh_grasp)
	grasp_ghoul.limit *= 3
	var/datum/heretic_knowledge/limited_amount/flesh_ghoul/ritual_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/flesh_ghoul)
	ritual_ghoul.limit *= 3
	var/datum/heretic_knowledge/limited_amount/starting/base_flesh/blade_ritual = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_flesh)
	blade_ritual.limit = 999

#undef GHOUL_MAX_HEALTH
#undef MUTE_MAX_HEALTH
