/// The max amount of health a ghoul has.
#define GHOUL_MAX_HEALTH 25
/// The max amount of health a voiceless dead has.
#define MUTE_MAX_HEALTH 50

/datum/heretic_knowledge_tree_column/main/flesh

	route = PATH_FLESH
	ui_bgr = "node_flesh"
	complexity = "Варьируется"
	complexity_color = COLOR_ORANGE
	path_description = list(
		"Путь Плоти строится вокруг призыва гулей и чудовищ, выполняющих ваши приказы.",
		"Выбирайте этот путь, если вам по душе роль некроманта, ведущего в бой легионы союзников.",
	)
	path_pros = list(
		"Может превращать мёртвых гуманоидов в хрупких, но верных гулей.",
		"Доступ к разнообразному списку призываемых миньонов.",
		"Ваши миньоны очень универсальны и при слаженной атаке быстро задавят экипаж числом.",
		"Поедание органов или полнота даруют различные бонусы (в зависимости от уровня вашей пассивки).",
	)
	path_cons = list(
		"Значительная часть вашего развития — это получение новых призываемых чудовищ.",
		"За пределами своих миньонов вы почти ничего не умеете.",
		"Вы не получаете врождённого доступа к защитным, атакующим или мобильным заклинаниям.",
		"Вы в основном сосредоточены на поддержке своих миньонов.",
	)
	path_tips = list(
		"Ваша \"Хватка Обители\" превращает мёртвых гуманоидов в гулей (даже защищённых разумом — офицеров СБ и капитана). Оно также оставляет метку, вызывающую сильное кровотечение при срабатывании от вашего Кровавого Клинка.",
		"Для Еретика Плоти органы и трупы — лучшие друзья! Их можно использовать в ритуалах, для лечения или получения бонусов.",
		"Заклинание \"Управление Плотью\" лечит ваших призванных существ. Ваши робы создают ауру, что также исцеляет миньонов поблизости (но не вас самих).",
		"\"Управление Плотью\" также позволяет красть органы у гуманоидов. Полезно, если нужна запасная печень.",
		"Бескожие Пророки могут связать вас и других миньонов в телепатическую сеть для координации на расстоянии.",
		"Ловцы Плоти — неплохие бойцы, способные маскироваться под мелких существ вроде ботов-уборщиков и корги. Они также владеют ЭМИ, но это может навредить им самим, если они обернулись роботом!",
		"Ваш успех на этом пути зависит от того, насколько умелы и живучи ваши миньоны. Но в количестве всегда есть сила: чем больше миньонов, тем выше шансы на успех.",
		"Ваши миньоны куда расходнее вас. Не бойтесь посылать их на смерть. Вы всегда сможете вернуть их позже... наверное.",
	)
	passive_name = "Ненасытный Голод"
	passive_descriptions = list(
		"Иммунитет к болезням и отвращению — никакая еда не вызывает у вас тошноты.",
		"Поедание мяса или органов исцеляет вас, а полнота больше вас не замедляет.",
		"Будучи толстым, вы получаете 25% сопротивления урону и устойчивость к электродубинкам.",
	)
	start = /datum/heretic_knowledge/limited_amount/starting/base_flesh
	knowledge_tier1 = /datum/heretic_knowledge/limited_amount/flesh_ghoul
	knowledge_tier2 = /datum/heretic_knowledge/spell/flesh_surgery
	robes = /datum/heretic_knowledge/armor/flesh
	knowledge_tier3 = /datum/heretic_knowledge/limited_amount/summon/raw_prophet
	blade = /datum/heretic_knowledge/blade_upgrade/flesh
	knowledge_tier4 = /datum/heretic_knowledge/limited_amount/summon/stalker
	ascension = /datum/heretic_knowledge/ultimate/flesh_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/limited_amount/risen_corpse
	guaranteed_side_tier2 = /datum/heretic_knowledge/crucible
	guaranteed_side_tier3 = /datum/heretic_knowledge/spell/cleave


/datum/heretic_knowledge/limited_amount/starting/base_flesh
	name = "Голодная Игра" // The Hunger Games
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
	mark_type = /datum/status_effect/eldritch/flesh
	passive_type = /datum/status_effect/heretic_passive/flesh


/datum/heretic_knowledge/limited_amount/starting/base_flesh/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	var/datum/objective/heretic_summon/summon_objective = new()
	summon_objective.owner = our_heretic.owner
	our_heretic.objectives += summon_objective

	to_chat(user, span_hierophant("Ступив на Путь Плоти, вы получаете еще одну цель."))
	our_heretic.announce_objectives()


/// Mansus Grasp turns dead, valid humanoids into loyal ghouls (was the separate "Прикосновение Плоти" node).
/// Living targets instead receive the flesh mark via the parent call.
/datum/heretic_knowledge/limited_amount/starting/base_flesh/on_mansus_grasp(mob/living/source, mob/living/target)
	..() // applies the flesh mark to a living target (no-op on the dead)

	if(target.stat != DEAD)
		return

	if(LAZYLEN(created_items) >= limit)
		target.balloon_alert(source, "лимит гулей!")
		return COMPONENT_BLOCK_HAND_USE

	if(!IS_VALID_GHOUL_MOB(target))
		target.balloon_alert(source, "не подходящее тело!")
		return COMPONENT_BLOCK_HAND_USE

	target.grab_ghost()

	if(!target.mind || !target.client)
		target.balloon_alert(source, "нет души!")
		return COMPONENT_BLOCK_HAND_USE

	make_ghoul(source, target)


/// Makes [victim] into a ghoul.
/datum/heretic_knowledge/limited_amount/starting/base_flesh/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a ghoul, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		GHOUL_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_ghoul)),
		CALLBACK(src, PROC_REF(remove_from_ghoul)),
	)


/// Callback for the ghoul status effect - Tracking all of our ghouls
/datum/heretic_knowledge/limited_amount/starting/base_flesh/proc/apply_to_ghoul(mob/living/ghoul)
	LAZYADD(created_items, WEAKREF(ghoul))


/// Callback for the ghoul status effect - Tracking all of our ghouls
/datum/heretic_knowledge/limited_amount/starting/base_flesh/proc/remove_from_ghoul(mob/living/ghoul)
	LAZYREMOVE(created_items, WEAKREF(ghoul))


/datum/heretic_knowledge/limited_amount/flesh_ghoul
	name = "Незавершенный Ритуал"
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
	cost = 2
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
	var/list/ghosts = SSghost_spawns.poll_candidates("Вы бы хотели сыграть за насильно убит[UNLINT(genderize_ru(soon_to_be_ghoul.gender, "ого", "ую", "ое", "ых"))] [soon_to_be_ghoul.declent_ru(ACCUSATIVE)]?", \
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


/datum/heretic_knowledge/spell/flesh_surgery
	drafting_tier = 5
	name = "Управление Плотью"
	desc = "Даёт вам заклинание \"Управление Плотью\". Это заклинание позволяет извлекать органы из жертв, \
			не прибегая к длительной хирургической операции. Этот процесс занимает гораздо больше времени, \
			если цель жива. Это заклинание позволяет вам исцелять ваших миньонов и призванных существ, \
			а также восстанавливать поврежденные органы до приемлемого состояния."
	gain_text = "Но они не смогли спастись от меня. \
				С каждым шагом крики становились всё громче, пока наконец \
				я не заставил их замолчать."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "mad_touch"
	spell_to_add = /obj/effect/proc_holder/spell/touch/flesh_surgery
	cost = 2


/datum/heretic_knowledge/armor/flesh
	name = "Извивающиеся Объятия"
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску и лужу крови в Извивающиеся Объятия. \
			Они дают вам способность определять состояние здоровья живых (и не очень) существ, а также \
			создают ауру, медленно исцеляющую ваших призванных существ. \
			Действует в качестве источника фокуса, пока надет капюшон."
	gain_text = "Я обернул вокруг себя этих жалких, копошащихся тварей, словно тёплое одеяло. \
				Глазами-не-моими они будут смотреть. Зубами-не-моими они будут стискивать. Руками-не-моими они будут ломать."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh)
	research_tree_icon_state = "flesh_armor"
	research_tree_icon_frame = 1
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/effect/decal/cleanable/blood = 1,
	)


/datum/heretic_knowledge/limited_amount/summon/raw_prophet
	name = "Ритуал Сырости"
	desc = "Позволяет трансмутировать пару глаз, левую руку и лужу крови, чтобы создать Бескожего Пророка. \
			Бескожие Пророки обладают большой дальностью обзора, могут видеть сквозь стены, \
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
	cost = 2


/datum/heretic_knowledge/blade_upgrade/flesh
	name = "Кровоточащая Cталь"
	desc = "Теперь ваш Кровавый Клинок при атаке вызывает у врагов обильное кровотечение."
	gain_text = "Подобных существ было множество. Они привели меня к Маршалу. \
				Я наконец начал понимать. Небеса окрасились в алый."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_flesh"


/datum/heretic_knowledge/blade_upgrade/flesh/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!ishuman(target) || source == target)
		return

	var/mob/living/carbon/human/human_target = target
	if(HAS_TRAIT(human_target, TRAIT_NO_BLOOD))
		return

	var/list/valid_limbs = list()
	for(var/obj/item/organ/external/bodypart as anything in human_target.bodyparts)
		if(!bodypart.is_robotic())
			valid_limbs += bodypart
	if(!length(valid_limbs))
		return

	var/obj/item/organ/external/limb = pick(valid_limbs)
	limb.bleeding_amount = min(limb.bleeding_amount + limb.max_bleeding_amount, limb.max_bleeding_amount)
	human_target.add_bleeding_bodypart(limb)


/datum/heretic_knowledge/limited_amount/summon/stalker
	name = "Ритуал Одиночества"
	desc = "Позволяет трансмутировать любой хвост, печень, лёгкие, ручку и лист бумаги, чтобы создать Ловца Плоти. \
			Ловцы Плоти умеют становиться нематериальными, выпускать ЭМИ, превращаться в животных или роботов, \
			а также сильны в бою."
	gain_text = "Мне удалось объединить жадность и желания в жуткого зверя. \
				Эта вечно меняющая форму масса плоти прекрасно знала мои цели."

	required_atoms = list(
		/obj/item/organ/external/tail = 1,
		/obj/item/organ/internal/liver = 1,
		/obj/item/organ/internal/lungs = 1,
		/obj/item/pen = 1,
		/obj/item/paper = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/stalker
	cost = 2
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/flesh_final
	name = "Последний Гимн Священника"
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
	announcement_text = "%SPOOKY% Реальность разверзлась с хрустом рвущейся плоти. ВОЗДЕНЬТЕ РУКИ К НЕБУ И ПОПРИВЕТСТВУЙТЕ ВЛАДЫКУ НОЧИ! %NAME% вознёсся! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_flesh.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "fleshascend"


/datum/heretic_knowledge/ultimate/flesh_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shapeshift/shed_human_form)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/limited_amount/starting/base_flesh/blade_ritual = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_flesh)
	blade_ritual.limit = 999
	var/datum/heretic_knowledge/limited_amount/flesh_ghoul/ritual_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/flesh_ghoul)
	ritual_ghoul.limit *= 3

#undef GHOUL_MAX_HEALTH
#undef MUTE_MAX_HEALTH
