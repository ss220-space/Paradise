
/datum/heretic_knowledge_tree_column/main/moon
	neighbour_type_left = /datum/heretic_knowledge_tree_column/ash_to_moon
	neighbour_type_right = /datum/heretic_knowledge_tree_column/moon_to_lock

	route = PATH_MOON
	ui_bgr = "node_moon"

	start = /datum/heretic_knowledge/limited_amount/starting/base_moon
	grasp = /datum/heretic_knowledge/moon_grasp
	tier1 = /datum/heretic_knowledge/spell/moon_smile
	mark = /datum/heretic_knowledge/mark/moon_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/moon
	unique_ability = /datum/heretic_knowledge/spell/moon_parade
	tier2 = /datum/heretic_knowledge/moon_amulet
	blade = /datum/heretic_knowledge/blade_upgrade/moon
	tier3 =	/datum/heretic_knowledge/spell/moon_ringleader
	ascension = /datum/heretic_knowledge/ultimate/moon_final


/datum/heretic_knowledge/limited_amount/starting/base_moon
	name = "Лунная Призма" // Sailor Moon
	desc = "Открывает вам Путь Луны. \
			Позволяет превратить 2 листа железа и нож в Лунный Клинок. \
			Вы можете создать только два клинка одновременно."
	gain_text = "Под лунным светом раздается смех."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/stack/sheet/metal = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/moon)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "moon_blade"


/datum/heretic_knowledge/limited_amount/starting/base_moon/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	ADD_TRAIT(user, TRAIT_EMPATHY, UID())


/datum/heretic_knowledge/moon_grasp
	name = "Касание Луны"
	desc = "Ваше Прикосновение Мансуса заставит ваших жертв видеть всех в виде лунной массы, \
			и на короткое время скроет вашу личность."
	gain_text = "Труппа на обратной стороне Луны показала мне правду, и я её принял."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_moon"


/datum/heretic_knowledge/moon_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))


/datum/heretic_knowledge/moon_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)


/datum/heretic_knowledge/moon_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	if(target.can_block_magic(MAGIC_RESISTANCE_MIND))
		to_chat(target, span_danger("Сверху доносится эхо смеха, но он глух и далек."))
		return

	source.apply_status_effect(/datum/status_effect/moon_grasp_hide)
	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	to_chat(carbon_target, span_danger("Вы слышите эхо смеха откуда-то сверху!"))
	carbon_target.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by mansus grasp")


/datum/heretic_knowledge/spell/moon_smile
	name = "Лунная Улыбка"
	desc = "Даёт вам Лунную Улыбку — заклинание дальнего боя, оглушающее, ослепляющее и \
			не дающее говорить некоторое время. После активации заклинания необходимо кликнуть по выбранной цели."
	gain_text = "Луна улыбается нам всем, но лишь те, кто видит истинну, могут улыбнуться ей в ответ."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "moon_smile"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/moon_smile
	cost = 1


/datum/heretic_knowledge/mark/moon_mark
	name = "Лунная Метка"
	desc = "Ваше «Прикосновение Мансуса» теперь накладывает Метку Луны, умиротворяя жертву до тех пор, пока её не атакуют. \
			Метка также может быть активирована атакой вашим Лунным Клинком, временно забрав у жертвы возможность ходить прямо."
	gain_text = "Труппа на Луне танцевала бы весь день, и в этом танце Луна улыбалась \
				бы, но когда наступала ночь, её улыбка гасла, и мы вынуждены были смотреть на Землю."
	mark_type = /datum/status_effect/eldritch/moon


/datum/heretic_knowledge/knowledge_ritual/moon


/datum/heretic_knowledge/spell/moon_parade
	name = "Лунный парад"
	desc = "Дарует вам Лунный парад, заклинание, которое после короткой подготовки посылает вперёд снаряд. \
			При попадании, жертва будет вынуждена следовать за вами и страдать от галлюцинаций. \
			Чтобы жертва освободилась, должна умереть либо она, либо вы."
	gain_text = "Музыка, словно из глубин их души, влекла, словно мотыльков к пламени."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "moon_parade"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/projectile/moon_parade
	cost = 1


/datum/heretic_knowledge/moon_amulet
	name = "Амулет Лунного Света"
	desc = "Позволяет преобразовать 2 листа стекла, сердце и галстук в Амулет Лунного Света. \
			Если предмет используется на ком-то в критическом состоянии, жертва приходит в ярость и начинает \
			атаковать всех вокруг."
	gain_text = "Он стоял во главе парада, луна слилась в единую массу, отражение души."

	required_atoms = list(
		/obj/item/organ/internal/heart = 1,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/clothing/accessory = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus/moon_amulet)
	cost = 1

	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "moon_amulette"
	research_tree_icon_frame = 9


/datum/heretic_knowledge/blade_upgrade/moon
	name = "Клинок Лунного Света"
	desc = "Теперь ваш клинок наносит урон мозгу, и вызывает галлюцинации."
	gain_text = "Его слова были остры как лезвие, он разрубал ложь, принося нам радость."

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_moon"


/datum/heretic_knowledge/blade_upgrade/moon/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	if(target.can_block_magic(MAGIC_RESISTANCE_MIND))
		return

	target.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 10, 100)
	target.Hallucinate(60 SECONDS)
	/*target.cause_hallucination( \
			get_random_valid_hallucination_subtype(/datum/hallucination/body), \
			"upgraded path of moon blades", \
		)*/
	target.emote(pick("giggle", "laugh"))


/datum/heretic_knowledge/spell/moon_ringleader
	name = "Восстание Главарей"
	desc = "Даёт вам «Восстание Главарей» — заклинание по области, наносящее \
			урон мозгу, вызывающее галлюцинации и спутанность у окружающих вас врагов."
	gain_text = "Я схватил его за руку, и мы поднялись. Те, кто видел истину, поднялись вместе с нами. \
				Главарь указал вверх, и тусклый свет истины озарил нас ярче."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "moon_ringleader"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/moon_ringleader
	cost = 1

	research_tree_icon_frame = 5


/datum/heretic_knowledge/ultimate/moon_final
	name = "Последний Акт"
	desc = "Ритуал вознесения Пути Луны. \
			Принесите 3 трупа с повреждениями мозга более 50 к руне трансмутации, чтобы завершить ритуал. \
			После завершения ритуала ваша аура начнет вызывать разнообразные формы безумия у окружающих. \
			Одна пятая часть экипажа превратится в аколитов и будет следовать вашим приказам. \
			Все они получат амулеты лунного света."
	gain_text = "Мы нырнули вниз, к толпе, его душа отделилась в поисках большего приключения \
				ибо там, где Главарь начал парад, я продолжу его до заката солнца \
				СТАНЬТЕ СВИДЕТЕЛЯМИ МОЕГО ВОЗНЕСЕНИЯ, ЛУНА СНОВА УЛЫБНУЛАСЬ И БУДЕТ УЛЫБАТЬСЯ ВСЕГДА!"

	//ascension_achievement = /datum/award/achievement/misc/moon_ascension
	announcement_text = "%SPOOKY% Смейтесь, ибо главарь %NAME% вознёсся! \
							Правда наконец поглотит ложь! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_moon.ogg'


/datum/heretic_knowledge/ultimate/moon_final/is_valid_sacrifice(mob/living/sacrifice)


	var/brain_damage = sacrifice.get_organ_loss(INTERNAL_ORGAN_BRAIN)
	// Checks if our target has enough brain damage
	if(brain_damage < 50)
		return FALSE

	return ..()


/datum/heretic_knowledge/ultimate/moon_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	ADD_TRAIT(user, TRAIT_MADNESS_IMMUNE, type)
	user.mind.add_antag_datum(/datum/antagonist/lunatic/master)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	var/amount_of_lunatics = 0
	var/list/lunatic_candidates = list()
	for(var/mob/living/carbon/human/crewmate as anything in shuffle(GLOB.human_list))
		if(QDELETED(crewmate) || isnull(crewmate.client) || isnull(crewmate.mind) || crewmate.stat != CONSCIOUS || crewmate.can_block_magic(MAGIC_RESISTANCE_MIND))
			continue

		var/turf/crewmate_turf = get_turf(crewmate)
		var/crewmate_z = crewmate_turf?.z
		if(!is_station_level(crewmate_z))
			continue

		lunatic_candidates += crewmate

	// Roughly 1/5th of the station will rise up as lunatics to the heretic.
	// We use either the (locked) manifest for the maximum, or the amount of candidates, whichever is larger.
	// If there's more eligible humans than crew, more power to them I guess.
	var/max_lunatics = ceil(max(length(GLOB.clients), length(lunatic_candidates)) * 0.2)

	for(var/mob/living/carbon/human/crewmate as anything in lunatic_candidates)
		// Heretics, lunatics and monsters shouldn't become lunatics because they either have a master or have a mansus grasp
		if(IS_HERETIC_OR_MONSTER(crewmate))
			to_chat(crewmate, span_boldwarning("Возвышение [user.declent_ru(ACCUSATIVE)] влияет на тех, чья воля слаба. Их разум будет разорван."))
			continue

		// Mindshielded and anti-magic folks are immune against this effect because this is a magical mind effect
		//if(HAS_MIND_TRAIT(crewmate, TRAIT_UNCONVERTABLE) || crewmate.can_block_magic(MAGIC_RESISTANCE))
		//	to_chat(crewmate, span_boldwarning("You feel shielded from something." ))
		//	continue

		if(amount_of_lunatics > max_lunatics)
			to_chat(crewmate, span_boldwarning("Вы чувствуете на себе чей-то пристальный взгляд."))
			continue

		var/datum/antagonist/lunatic/lunatic = crewmate.mind.add_antag_datum(/datum/antagonist/lunatic)
		lunatic.set_master(user.mind, user)
		var/obj/item/clothing/neck/heretic_focus/moon_amulet/amulet = new(crewmate.drop_location())
		var/static/list/slots = list(
			ITEM_SLOT_NECK,
			ITEM_SLOT_HAND_LEFT,
			ITEM_SLOT_HAND_RIGHT,
			ITEM_SLOT_POCKET_LEFT,
			ITEM_SLOT_POCKET_RIGHT,
			ITEM_SLOT_BACK,
		)
		crewmate.equip_in_one_of_slots(amulet, slots, qdel_on_fail = FALSE)
		crewmate.emote("laugh")
		amount_of_lunatics++


/datum/heretic_knowledge/ultimate/moon_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader
	visible_hallucination_pulse(
		center = get_turf(source),
		radius = 7,
		hallucination_duration = 60 SECONDS
	)

	for(var/mob/living/carbon/carbon_view in view(5, source))
		if(carbon_view.stat != CONSCIOUS)
			continue

		if(IS_HERETIC_OR_MONSTER(carbon_view))
			continue

		if(carbon_view.can_block_magic(MAGIC_RESISTANCE_MIND)) //Somehow a shitty piece of tinfoil is STILL able to hold out against the power of an ascended heretic.
			continue

		new moon_effect(get_turf(carbon_view))
		carbon_view.Confused(2 SECONDS)
		carbon_view.Hallucinate(10 SECONDS)
