
/datum/heretic_knowledge_tree_column/main/moon
	neighbour_type_left = /datum/heretic_knowledge_tree_column/ash_to_moon
	neighbour_type_right = /datum/heretic_knowledge_tree_column/moon_to_lock

	route = PATH_MOON
	ui_bgr = "node_moon"
	complexity = "Сложный"
	complexity_color = "#c93b3b"
	path_description = list(
		"Путь Луны строится вокруг рассудка, сеяния хаоса и раздора, и обхода привычных правил боя.",
		"Берите этот путь, если уже освоились с Еретиком и хотите попробовать нечто крайне необычное, \
		или если желаете сыграть пацифистом (да-да, всерьёз!).",
	)
	path_pros = list(
		"Огромный набор инструментов, чтобы сбивать врагов с толку.",
		"Сеет хаос по всей станции через лунатиков.",
		"Практически невосприимчив к выводящим из строя эффектам в Сияющем Облачении.",
	)
	path_cons = list(
		"Никакой мобильности.",
		"Почти нет средств напрямую наносить урон противникам.",
		"Полностью завязан на обмане и дезориентации.",
		"Лунатики могут стать обузой и обернуться против вас.",
		"Довольно хрупок, несмотря на уникальную защиту.",
		"Смерть в Сияющем Облачении оборачивается кровавым концом.",
	)
	path_tips = list(
		"Ваше «Прикосновение Мансуса» вызывает у жертвы кратковременные галлюцинации и накладывает метку: \
		сработав от удара лунного клинка, она оглушает жертву и временно лишает её способности ходить ровно.",
		"Ваш лунный клинок особенный: им можно бить, даже будучи пацифицированным.",
		"Ваша пассивка делает вас полностью невосприимчивым к травмам мозга и медленно восстанавливает его здоровье. \
		Развивайте её, чтобы усилить регенерацию.",
		"Сияющее Облачение полностью меняет правила боя: вы становитесь невосприимчивы к выводящим из строя эффектам, \
		но сама мантия не даёт брони, пацифицирует вас и не позволяет пользоваться огнестрелом (клинком - можно).",
		"Амулет лунного света - важнейшая часть набора: пока он надет, ваша пассивка восстанавливает мозг вдвое быстрее.",
		"«Восстание Главарей» бьёт по области уроном мозга и галлюцинациями; используйте его, когда враги сбились в кучу.",
		"Вознесение дарует вам ауру, обращающую часть экипажа в верных лунатиков. \
		Те, у кого вживлён щит разума, вместо этого обречены - их рассудок не выдержит.",
	)
	// "Лунное Прозрение" passive (see /datum/status_effect/heretic_passive/moon): tiers light up as you grow.
	passive_name = "Лунное Прозрение"
	passive_descriptions = list(
		"Вы невосприимчивы к травмам мозга, а его здоровье медленно восстанавливается.",
		"Вы получаете иммунитет ко сну; восстановление мозга усилено.",
		"Восстановление мозга достигло предела.",
	)
	// Main line: base_moon -> Mind Gate -> Moonlight Amulet -> Resplendent Regalia(robes) ->
	// Lunar Parade -> Moonlight Blade -> Ringleader's Rise -> ascension.
	// The grasp (hallucination + identity hide), the moon mark and the brain passive are all folded into
	// base_moon, no separate grasp/mark/regen nodes. master220 has no sanity/mood system, so
	// the path's sanity mechanics are adapted to brain damage / hallucinations / confusion throughout.
	start = /datum/heretic_knowledge/limited_amount/starting/base_moon
	knowledge_tier1 = /datum/heretic_knowledge/spell/mind_gate
	knowledge_tier2 = /datum/heretic_knowledge/moon_amulet
	robes = /datum/heretic_knowledge/armor/moon
	knowledge_tier3 = /datum/heretic_knowledge/spell/moon_parade
	blade = /datum/heretic_knowledge/blade_upgrade/moon
	knowledge_tier4 = /datum/heretic_knowledge/spell/moon_ringleader
	ascension = /datum/heretic_knowledge/ultimate/moon_final
	// Side knowledges guaranteed to be offered in this path's drafts (TG).
	guaranteed_side_tier1 = /datum/heretic_knowledge/phylactery
	guaranteed_side_tier2 = /datum/heretic_knowledge/codex_morbus
	guaranteed_side_tier3 = /datum/heretic_knowledge/unfathomable_curio


/datum/heretic_knowledge/limited_amount/starting/base_moon
	name = "Лунная Труппа" // Sailor Moon / Moonlight Troupe
	desc = "Открывает вам Путь Луны. \
			Позволяет превратить 2 листа стекла и нож в Лунный Клинок. \
			Вы можете создать только два клинка одновременно."
	gain_text = "Под лунным светом раздаётся смех."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/stack/sheet/glass = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/moon)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "moon_blade"
	mark_type = /datum/status_effect/eldritch/moon
	// "Лунное Прозрение" passive: brain-trauma immunity + brain regen, scaling with power.
	passive_type = /datum/status_effect/heretic_passive/moon


/datum/heretic_knowledge/limited_amount/starting/base_moon/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	// The moon heretic empathises with the crew, the better to find and break the weak-willed.
	ADD_TRAIT(user, TRAIT_EMPATHY, type)


/datum/heretic_knowledge/limited_amount/starting/base_moon/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_EMPATHY, type)


/// Mansus Grasp also makes the victim hallucinate everyone as moon-masked, and briefly hides our identity
/// (was the "Касание Луны" node). The mark itself is applied by the parent.
/datum/heretic_knowledge/limited_amount/starting/base_moon/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()
	if(target.can_block_magic(MAGIC_RESISTANCE_MIND))
		to_chat(target, span_danger("Сверху доносится эхо смеха, но он глух и далёк."))
		return

	source.apply_status_effect(/datum/status_effect/moon_grasp_hide)
	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	to_chat(carbon_target, span_danger("Вы слышите эхо смеха откуда-то сверху!"))
	carbon_target.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by mansus grasp")


// Mind Gate (knowledge_tier1): the Moon path's first researchable spell. It lives on the Moon main line
// (not a side knowledge), so it appears in the research tree rather than the Knowledge Shop.
/datum/heretic_knowledge/spell/mind_gate
	name = "Врата Разума"
	desc = "Даёт вам «Врату Разума», заклинание, вызывающее у цели галлюцинации, \
			спутанность сознания, удушие и повреждения мозга в течение 10 секунд.\
			Заклинатель получает 20 единиц урона мозгу за каждое применение."
	gain_text = "Мой разум распахивается, как врата, и это, ценой немалых жертв, позволяет мне постичь истину."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "mind_gate"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/mind_gate
	cost = 2


/datum/heretic_knowledge/moon_amulet
	name = "Амулет Лунного Света"
	desc = "Позволяет преобразовать 2 листа стекла, сердце и галстук в Амулет Лунного Света. \
			Если применить его на ком-то в критическом состоянии, жертва впадает в ярость и начинает \
			атаковать всех вокруг. Пока амулет надет на вас, ваша пассивка восстанавливает мозг вдвое быстрее \
			и вы можете применять клинок даже в Сияющем Облачении."
	gain_text = "Он стоял во главе парада, луна слилась в единую массу - отражение души."

	required_atoms = list(
		/obj/item/organ/internal/heart = 1,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/clothing/accessory = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus/moon_amulet)
	cost = 2

	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "moon_amulette"
	research_tree_icon_frame = 9


/datum/heretic_knowledge/armor/moon
	name = "Сияющее Облачение" // Resplendent Regalia
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску и 2 листа стекла в Сияющее Облачение. \
			Мантия делает вас полностью невосприимчивым к выводящим из строя эффектам, но не даёт брони, \
			пацифицирует вас и лишает возможности пользоваться огнестрелом. \
			Чтобы бить клинком в облачении, вам понадобится Амулет Лунного Света."
	gain_text = "Сияние и веселье струились с каждого края этого великолепного одеяния. \
				Труппа кружилась в переливающихся каскадах, ослепляя зрителей истиной, которую те искали. \
				Я смотрел, купаясь в свете, чтобы обрести себя."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon)
	// The pink Resplendent Regalia sprite was inserted into the already-mapped armor.dmi.
	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "moon_armor"
	// The /armor parent points at eldritch_armor (a 14-frame anim) and asks for frame 12. moon_armor is a
	// single-frame sprite, so we must override back to frame 1, or requesting frame 12 of a 1-frame state
	// returns a blank PNG (this was why the node rendered empty).
	research_tree_icon_frame = 1
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/stack/sheet/glass = 2,
	)


/datum/heretic_knowledge/spell/moon_parade
	name = "Лунный Парад"
	desc = "Дарует вам «Лунный Парад», заклинание, которое после короткой подготовки посылает вперёд снаряд. \
			При попадании жертва вынуждена следовать за вами и страдать от галлюцинаций. \
			Чтобы освободиться, должны умереть либо она, либо вы."
	gain_text = "Музыка, словно из глубин их души, влекла - как мотыльков к пламени."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "moon_parade"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/projectile/moon_parade
	cost = 2
	drafting_tier = 5


/datum/heretic_knowledge/blade_upgrade/moon
	name = "Клинок Лунного Света"
	desc = "Теперь ваш клинок наносит урон мозгу и вызывает галлюцинации. \
			Урон по мозгу выше, если жертва без сознания."
	gain_text = "Его слова были остры как лезвие - он рассекал ложь, принося нам радость."

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_moon"


/datum/heretic_knowledge/blade_upgrade/moon/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	if(target.can_block_magic(MAGIC_RESISTANCE_MIND))
		return

	target.Hallucinate(60 SECONDS)
	target.emote(pick("giggle", "laugh"))
	// master220 has no mood system, so a per-hit sanity drain becomes an occasional moon chat (gated so
	// repeated blade swings don't spam the victim's chat).
	if(prob(50))
		to_chat(target, span_warning("ЛУНА СУДИТ ВАС И НАХОДИТ НЕДОСТОЙНЫМ!!!"))
	// master220 has no sanity, so "more brain damage if insane" is reduced to a
	// conscious / unconscious split: a downed victim's mind is far easier to shatter.
	if(target.stat == CONSCIOUS)
		target.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 10, 100)
		return
	target.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 25, 150)


/datum/heretic_knowledge/spell/moon_ringleader
	name = "Восстание Главарей"
	desc = "Даёт вам «Восстание Главарей», заклинание по области, наносящее \
			урон мозгу, вызывающее галлюцинации и спутанность у окружающих вас врагов."
	gain_text = "Я схватил его за руку, и мы поднялись. Те, кто видел истину, поднялись вместе с нами. \
				Главарь указал вверх, и тусклый свет истины озарил нас ярче."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "moon_ringleader"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/moon_ringleader
	cost = 2
	research_tree_icon_frame = 5
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/moon_final
	name = "Последний Акт"
	desc = "Ритуал вознесения Пути Луны. \
			Принесите 3 трупа с повреждениями мозга более 50 к руне трансмутации, чтобы завершить ритуал. \
			После завершения ваша аура начнёт вызывать разнообразные формы безумия у окружающих. \
			Часть экипажа превратится в аколитов и будет следовать вашим приказам, получив амулеты лунного света."
	gain_text = "Мы нырнули вниз, к толпе, его душа отделилась в поисках большего приключения, \
				ибо там, где Главарь начал парад, я продолжу его до заката солнца. \
				СТАНЬТЕ СВИДЕТЕЛЯМИ МОЕГО ВОЗНЕСЕНИЯ, ЛУНА СНОВА УЛЫБНУЛАСЬ И БУДЕТ УЛЫБАТЬСЯ ВСЕГДА!"

	//ascension_achievement = /datum/award/achievement/misc/moon_ascension
	announcement_text = "%SPOOKY% Смейтесь, ибо главарь %NAME% вознёсся! \
							Правда наконец поглотит ложь! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_moon.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "moonascend"


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
	// We use either the client count or the amount of candidates, whichever is larger.
	var/max_lunatics = ceil(max(length(GLOB.clients), length(lunatic_candidates)) * 0.2)

	for(var/mob/living/carbon/human/crewmate as anything in lunatic_candidates)
		// Heretics, lunatics and monsters shouldn't become lunatics because they either have a master or have a mansus grasp
		if(IS_HERETIC_OR_MONSTER(crewmate))
			to_chat(crewmate, span_boldwarning("Возвышение [user.declent_ru(ACCUSATIVE)] влияет на тех, чья воля слаба. Их разум будет разорван."))
			continue

		if(amount_of_lunatics > max_lunatics)
			to_chat(crewmate, span_boldwarning("Вы чувствуете на себе чей-то пристальный взгляд."))
			continue

		if(attempt_conversion(crewmate, user))
			amount_of_lunatics++


/// Turns one crewmate into a lunatic thrall of [user]: binds them to the master, hands them a moonlight
/// amulet and makes them laugh. Returns TRUE on success. Shared by the ascension burst and the aura.
/datum/heretic_knowledge/ultimate/moon_final/proc/attempt_conversion(mob/living/carbon/convertee, mob/user)
	if(QDELETED(convertee) || isnull(convertee.mind) || IS_HERETIC_OR_MONSTER(convertee))
		return FALSE
	if(convertee.mind.has_antag_datum(/datum/antagonist/lunatic))
		return FALSE

	var/datum/antagonist/lunatic/lunatic = convertee.mind.add_antag_datum(/datum/antagonist/lunatic)
	lunatic.set_master(user.mind, user)
	var/obj/item/clothing/neck/heretic_focus/moon_amulet/amulet = new(convertee.drop_location())
	var/static/list/slots = list(
		ITEM_SLOT_NECK,
		ITEM_SLOT_HAND_LEFT,
		ITEM_SLOT_HAND_RIGHT,
		ITEM_SLOT_POCKET_LEFT,
		ITEM_SLOT_POCKET_RIGHT,
		ITEM_SLOT_BACK,
	)
	convertee.equip_in_one_of_slots(amulet, slots, qdel_on_fail = FALSE)
	convertee.emote("laugh")
	return TRUE


/// A mind protected by a mindshield (or a cultist's already-claimed mind) can't be converted - the aura
/// shatters it instead of bending it.
/datum/heretic_knowledge/ultimate/moon_final/proc/should_mind_explode(mob/living/carbon/target)
	return ismindshielded(target) || iscultist(target)


/// The aura's "kill switch" for minds it can't claim: the head is taken off (or the body gibbed).
/datum/heretic_knowledge/ultimate/moon_final/proc/mind_explode(mob/living/carbon/target)
	if(QDELETED(target) || target.stat == DEAD)
		return
	to_chat(target, span_userdanger("ВАШ РАЗУМ ОХВАЧЕН ПОТУСТОРОННЕЙ СИЛОЙ, ПЫТАЮЩЕЙСЯ ПЕРЕПИСАТЬ САМУ ВАШУ СУТЬ. \
		ВЫ ДАЖЕ НЕ УСПЕВАЕТЕ ЗАКРИЧАТЬ, ПРЕЖДЕ ЧЕМ ИМПЛАНТ СРАБАТЫВАЕТ, ЗАБИРАЯ ВАШУ ГОЛОВУ!"))
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/organ/external/head = human_target.get_organ(BODY_ZONE_HEAD)
		if(head)
			head.dismember()
			return
	target.gib()


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

		// Already one of ours - the aura leaves its own lunatics alone (don't grind them into a coma).
		if(carbon_view.mind?.has_antag_datum(/datum/antagonist/lunatic))
			continue

		if(carbon_view.can_block_magic(MAGIC_RESISTANCE_MIND)) //Somehow a shitty piece of tinfoil is STILL able to hold out against the power of an ascended heretic.
			continue

		new moon_effect(get_turf(carbon_view))
		carbon_view.Confused(2 SECONDS)
		carbon_view.Hallucinate(60 SECONDS)
		// The ambient status alone fires unreliably; paced direct hallucinations make the ascension aura
		// actually manifest galuns. Async (this is a COMSIG_LIVING_LIFE handler) and minor+medium only, so
		// the moon stays atmospheric/visual rather than throwing the mask's scary majors.
		if(prob(20))
			INVOKE_ASYNC(carbon_view, TYPE_PROC_REF(/mob/living, hallucinate_living), pickweight(GLOB.minor_medium_hallutinations))

		// master220 has no sanity, so brain damage is the aura's madness meter: it grinds nearby minds down,
		// and once a mind is shattered (>= 60) the weak-willed join the heretic as lunatics over time, while
		// a mindshielded/cultist mind detonates instead. ~4 brain/tick (SSmobs ~2s) => ~30s to
		// break. Conversion/detonation is async since this runs inside a COMSIG_LIVING_LIFE handler.
		carbon_view.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 4, 100)
		if(carbon_view.get_organ_loss(INTERNAL_ORGAN_BRAIN) < 60)
			continue
		if(should_mind_explode(carbon_view))
			INVOKE_ASYNC(src, PROC_REF(mind_explode), carbon_view)
		else
			INVOKE_ASYNC(src, PROC_REF(attempt_conversion), carbon_view, source)
