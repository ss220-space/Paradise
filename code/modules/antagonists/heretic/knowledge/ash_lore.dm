
/datum/heretic_knowledge_tree_column/main/ash
	neighbour_type_left = /datum/heretic_knowledge_tree_column/cosmic_to_ash
	neighbour_type_right = /datum/heretic_knowledge_tree_column/ash_to_moon

	route = PATH_ASH
	ui_bgr = "node_ash"
	complexity = "Лёгкий"
	complexity_color = "#20b142"
	path_description = list(
		"Путь Пепла строится вокруг огня, мобильности и жёсткого контроля одиночных противников.",
		"Берите этот путь, если вы новичок в Еретике или любите тактику «ударил и убежал».",
	)
	path_pros = list(
		"Очень силён уже с самого начала пути.",
		"Лёгкий доступ к мобильности и расширенному зрению.",
		"Очень мощный эффект метки.",
	)
	path_cons = list(
		"Слабее большинства еретиков за пределами стартовых способностей.",
		"Не хватает живучести в затяжных конфликтах.",
		"Зависит от того, сумеете ли вы ударить быстро и сильно до того, как враг подготовит контрмеры.",
	)
	path_tips = list(
		"Ваше Прикосновение Мансуса накладывает короткую слепоту и метку, которая при срабатывании от клинка вгоняет жертву в стамина-крит. Метка может перекидываться на ближайших врагов.",
		"Выбор этого пути даёт иммунитет к урону от высокой температуры. Но помните: ваша одежда всё ещё может гореть!",
		"Извержение Вулкана быстро расправится с врагами, если те имели глупость сбиться в кучу.",
		"Не пренебрегайте Маской Безумия — она медленно выкачивает выносливость врагов и вызывает галлюцинации.",
		"Поджигайте как можно больше врагов! Возрождение Ночного Дозорного лечит вас и снижает откат за каждого поражённого.",
		"Вознесение даёт полный иммунитет к опасностям окружения, включая бомбы! Но обычное оружие всё ещё опасно — не теряйте бдительности.",
	)
	// "Vow of Destruction" passive (see /datum/status_effect/heretic_passive/ash): tiers light up as you grow.
	passive_name = "Клятва Разрушения"
	passive_descriptions = list(
		"Иммунитет к жару и пепельным бурям.",
		"Иммунитет к лаве.",
		"Сопротивление экстремальному холоду.",
	)
	// TG-format column (1:1 with tgstation Ash). Main line:
	// base_ash -> ash_passage -> fire_blast -> Scorched Mantle(robes) -> mad_mask -> Fiery Blade -> flame_birth -> ascension.
	// Grasp blind + ash mark are folded into base_ash (matching TG, no separate nodes).
	start = /datum/heretic_knowledge/limited_amount/starting/base_ash
	knowledge_tier1 = /datum/heretic_knowledge/spell/ash_passage
	knowledge_tier2 = /datum/heretic_knowledge/spell/fire_blast
	robes = /datum/heretic_knowledge/armor/ash
	knowledge_tier3 = /datum/heretic_knowledge/mad_mask
	blade = /datum/heretic_knowledge/blade_upgrade/ash
	knowledge_tier4 = /datum/heretic_knowledge/spell/flame_birth
	ascension = /datum/heretic_knowledge/ultimate/ash_final
	// Side knowledges guaranteed to be offered in this path's drafts (TG).
	guaranteed_side_tier1 = /datum/heretic_knowledge/medallion
	guaranteed_side_tier2 = /datum/heretic_knowledge/rifle
	guaranteed_side_tier3 = /datum/heretic_knowledge/limited_amount/summon/ashy


/datum/heretic_knowledge/limited_amount/starting/base_ash
	name = "И восстал Еретик из пепла потухшего огня" // Terminator
	desc = "Открывает вам Путь Пепла. \
			Позволяет превратить спичку и нож в Пепельный Клинок. \
			Вы можете создать только два клинка одновременно."
	gain_text = "Городская стража стоит на своем посту. Если вы подойдете к ним ночью, возможно, узнаете историю о потухшем фонаре."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/match = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "ash_blade"
	// The Ash mark and the grasp blind both live here now (matching TG), instead of separate nodes.
	mark_type = /datum/status_effect/eldritch/ash
	// "Vow of Destruction" passive: heat/ashstorm immunity now, lava on blade upgrade, cold on ascension.
	passive_type = /datum/status_effect/heretic_passive/ash


/// Mansus Grasp also burns the victim's eyes, blurring their vision (was the "Хватка Пепла" node).
/datum/heretic_knowledge/limited_amount/starting/base_ash/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()
	if(target.is_blind())
		return

	if(!target.get_organ_slot(INTERNAL_ORGAN_EYES))
		return

	to_chat(target, span_danger("Яркий зеленый свет ужасно жжет ваши глаза!"))
	target.adjustOrganLoss(INTERNAL_ORGAN_EYES, 5)
	target.EyeBlurry(20 SECONDS)
	for(var/obj/effect/proc_holder/spell/touch/mansus_grasp/spell in source.mind.spell_list)
		if(!spell.cooldown_handler.is_on_cooldown())
			continue

		spell.cooldown_handler.recharge_time += spell.base_cooldown / 2


/// Triggering the Ash mark also refunds 75% of the Mansus Grasp cooldown (was the "Метка Пепла" node).
/datum/heretic_knowledge/limited_amount/starting/base_ash/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	var/obj/effect/proc_holder/spell/touch/mansus_grasp/grasp = locate() in source.mind.spell_list
	if(!grasp)
		return

	grasp.cooldown_handler.recharge_time -= round(grasp.base_cooldown * 0.75)
	grasp.action?.UpdateButtonIcon()


/datum/heretic_knowledge/spell/ash_passage
	name = "Врата Пепла"
	desc = "Дает вам «Врата Пепла» — заклинание, позволяющее вам выходить из реальности и перемещаться на небольшие расстояния, проходя сквозь любые стены."
	gain_text = "Он умел ходить между мирами."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "ash_shift"
	spell_to_add = /obj/effect/proc_holder/spell/ethereal_jaunt/ash
	cost = 1


/datum/heretic_knowledge/knowledge_ritual/ash


/datum/heretic_knowledge/spell/fire_blast
	name = "Извержение Вулкана"
	desc = "Дарует вам «Извержение Вулкана» — заклинание, после короткой подготовки выпускающее луч энергии \
			в ближайшего врага, поджигая его. Если противник не погаснет сам, \
			луч продолжит движение к другой цели."
	gain_text = "Никакой огонь не был достаточно жарким, чтобы разжечь фонарь вновь. Никакой огонь не был достаточно ярким, чтобы спасти их. Никакой огонь не вечен."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "flames"
	spell_to_add = /obj/effect/proc_holder/spell/charged/beam/fire_blast
	cost = 1
	research_tree_icon_frame = 7


/datum/heretic_knowledge/armor/ash
	name = "Опалённая Мантия"
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску и спичку в Опалённую Мантию. \
			Она обеспечивает полную защиту от огня и способна пассивно создавать пламя. \
			Когда у вас накопится достаточно огня, вы сможете применять усиленные версии пепельных заклинаний. \
			Действует как амулет, пока капюшон надет."
	gain_text = "Дозор остаётся там, где пал, рассыпаясь в прах. И всё же ветра, веющие сквозь город, \
				зовут их обратно на службу, поднимая пыль в воздух — дрейфующий силуэт павших."
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/match = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash)
	research_tree_icon_path = 'icons/obj/clothing/armor.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 12


/datum/heretic_knowledge/mad_mask
	name = "Маска Безумия"
	desc = "Позволяет преобразовать любую маску, четыре свечи, стандубинку и печень в Маску Безумия. \
			Маска вселяет страх в язычников, которые её видят, вызывая снижение выносливости, галлюцинации и безумие. \
			Её также можно надеть на язычника силой, чтобы он не смог её снять..."
	gain_text = "Ночной Дозорный был мертв. Так считал Дозор. И всё же он бродил по миру, не привлекая внимания людей."
	required_atoms = list(
		/obj/item/organ/internal/liver = 1,
		/obj/item/melee/baton/security = 1,  // Technically means a cattleprod is valid
		/obj/item/clothing/mask = 1,
		/obj/item/candle = 4,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 1
	research_tree_icon_path = 'icons/obj/clothing/masks.dmi'
	research_tree_icon_state = "mad_mask"


/datum/heretic_knowledge/blade_upgrade/ash
	name = "Огненный Клинок"
	desc = "Теперь ваш клинок поджигает врагов при атаке."
	gain_text = "Он вернулся с клинком в руке, он размахивал им, пока пепел падал с небес. \
				Его город, люди, за которыми он поклялся следить... и он следил, пока они все не сгорели дотла."

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_ash"


/datum/heretic_knowledge/blade_upgrade/ash/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.adjust_fire_stacks(1)
	target.IgniteMob()


/datum/heretic_knowledge/spell/flame_birth
	name = "Возрождение Ночного Дозорного"
	desc = "Дарует вам «Возрождение Ночного Дозорного — заклинание, которое тушит вас и \
			ранит всех находящихся поблизости горящих язычников, исцеляя вас за каждую пораженную жертву. \
			Если жертвы находятся в критическом состоянии, они также мгновенно умирают."
	gain_text = "Огонь был неизбежен, и всё же жизнь теплилась в его обугленном теле. \
				Ночной Страж был особенным человеком, всегда наблюдавшим."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "smoke"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/fiery_rebirth
	cost = 1
	research_tree_icon_frame = 5


/datum/heretic_knowledge/ultimate/ash_final
	name = "Обряд Повелителя Пепла"
	desc = "Ритуал вознесения Пути Пепла. \
			Положите 3 горящих трупа на руну трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы становитесь предвестником пламени и получаете две способности. \
			Каскад, создающий вокруг вас огромное растущее огненное кольцо, \
			и Клятва Пламени, позволяющая вам пассивно создавать огненное кольцо при ходьбе. \
			Также будут усилены некоторые заклинания пепла, которые вы уже знали. \
			Вы также приобретете иммунитет к огню и давлению."
	gain_text = "Дозор уничтожен, Ночной Дозорный сгорел вместе с ним. Но его огонь горит вечно, \
				ибо Ночной Дозорный принёс себя в жертву человечеству! Его взгляд продолжает смотреть, \
				ибо теперь он един с пламенем, СТАНЬТЕ СВИДЕТЕЛЕМ МОЕГО ВОЗНЕСЕНИЯ, ПЕПЕЛЬНЫЙ ФОНАРЬ СНОВА ЗАГОРИТСЯ!"

	//ascension_achievement = /datum/award/achievement/misc/ash_ascension
	announcement_text = "%SPOOKY% Бойтесь пламени, ибо Повелитель Пепла, %NAME% вознесся! Пламя поглотит все! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_ash.ogg'
	/// A static list of all traits we apply on ascension.
	var/static/list/traits_to_apply = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_NO_BREATH,
		//TRAIT_NOFIRE,
		TRAIT_RESIST_COLD,
		TRAIT_RESIST_HEAT,
		TRAIT_RESIST_HEAT,
		TRAIT_RESIST_COLD,
	)


/datum/heretic_knowledge/ultimate/ash_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return

	if(sacrifice.on_fire)
		return TRUE

	if(HAS_TRAIT_FROM(sacrifice, TRAIT_HUSK, BURN))
		return TRUE

	return FALSE


/datum/heretic_knowledge/ultimate/ash_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/fire_sworn())
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/fire_cascade/big())
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/fireball/hellish())
	var/obj/effect/proc_holder/spell/charged/beam/fire_blast/existing_beam_spell = locate() in user.mind.spell_list
	if(existing_beam_spell)
		existing_beam_spell.max_beam_bounces *= 2 // Double beams
		existing_beam_spell.beam_duration *= 0.66 // Faster beams
		existing_beam_spell.base_cooldown *= 0.66 // Lower cooldown

	var/obj/effect/proc_holder/spell/aoe/fiery_rebirth/fiery_rebirth = locate() in user.mind.spell_list
	fiery_rebirth?.base_cooldown *= 0.16

	user.add_traits(traits_to_apply, type)
