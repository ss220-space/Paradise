
/datum/heretic_knowledge_tree_column/main/blade

	route = PATH_BLADE
	ui_bgr = "node_blade"
	complexity = "Сложный"
	complexity_color = "#c93b3b"
	path_description = list(
		"Путь Клинка — именно то, что следует из названия.",
		"Вы мастерски кромсаете противников в лоскуты.",
		"Берите этот путь, если хотите драться и хотите быть лучшим в драке.",
	)
	path_pros = list(
		"Способен блокировать входящие атаки и отвечать контрударом.",
		"Стремительно наносит урон парными клинками и направленными ударами.",
		"Высокая защита от оглушений и сбиваний с ног.",
		"Смертельно опасен в прямом бою один на один.",
	)
	path_cons = list(
		"Требует высокого мастерства и точного контроля.",
		"Без клинков путь теряет почти всю боевую мощь.",
		"Нет средств мобильности.",
		"Нет защиты от опасностей окружающей среды.",
	)
	path_tips = list(
		"Ваша \"Хватка Обители\" оглушает противника, если ударить его со спины или пока он лежит. \
		Метка запирает жертву в комнате; срабатывание метки дарует вращающийся нож, блокирующий одну атаку.",
		"У вас самый высокий лимит клинков среди всех путей (до 4). Но они требуют серебра или титана, \
		так что без работы шахтёров вы рискуете остаться без материалов. И серебро, и титан можно выплавить \
		из руды в плавильной печи карго.",
		"Вы крайне зависимы от ближнего боя. Поскальзывания, бола и медвежьи капканы — ваши злейшие враги.",
		"\"Перестройка\" вытащит вас из оглушений и сбиваний с ног, но на время умиротворяет.",
		"С \"Усиленными Клинками\" вы бьёте сразу обеими руками и можете вкладывать в клинки силу Обители, \
		активировав \"Хватку\". Клинки также сильнее крушат объекты, силиконов и мехов.",
		"Хорошая атака рождает хорошую защиту: с вращающимися клинками вы блокируете больше входящих атак.",
		"\"Яростная Сталь\" создаёт несколько ножей для защиты, которые можно метать по щелчку пустой рукой.",
		"Используйте \"Волк среди Овец\" с осторожностью: помимо большого отката, он вооружает клинками и тех, \
		кто заперт вместе с вами. Это последний рубеж обороны или добивающий удар при явном преимуществе.",
	)
	passive_name = "Танец Клинка"
	passive_descriptions = list(
		"Атакованный в ближнем бою с клинком Еретика в любой руке, вы наносите мгновенный ответный удар атакующему. Срабатывает не чаще, чем раз в 20 секунд.",
		"Иммунитет к урону от падения.",
		"Перезарядка контратаки сокращена до 10 секунд.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_blade
	knowledge_tier1 = /datum/heretic_knowledge/spell/realignment
	knowledge_tier2 = /datum/heretic_knowledge/duel_stance
	robes = /datum/heretic_knowledge/armor/blade
	knowledge_tier3 = /datum/heretic_knowledge/spell/furious_steel
	blade = /datum/heretic_knowledge/blade_upgrade/blade
	knowledge_tier4 = /datum/heretic_knowledge/spell/wolves_among_sheep
	ascension = /datum/heretic_knowledge/ultimate/blade_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/greaves_of_the_prophet
	guaranteed_side_tier2 = /datum/heretic_knowledge/essence
	guaranteed_side_tier3 = /datum/heretic_knowledge/rune_carver


/datum/heretic_knowledge/limited_amount/starting/base_blade
	name = "Бегущий по Лезвию Клинка" // Blade Runner
	desc = "Открывает вам Путь Клинков. \
			Позволяет преобразовать нож в один слиток серебра или титана в Расколотый Клинок. \
			Вы можете создать до четырёх клинков одновременно."
	gain_text = "Наши великие предки ковали мечи и тренировались в спаррингах накануне великих сражений."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/dark)
	limit = 4 // It's the blade path, it's a given
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"
	mark_type = /datum/status_effect/eldritch/blade
	passive_type = /datum/status_effect/heretic_passive/blade


/// Mansus Grasp backstab-stuns a target hit from behind or while prone.
/datum/heretic_knowledge/limited_amount/starting/base_blade/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()
	if(!check_behind(source, target))
		return

	target.AdjustParalysis(1.5 SECONDS)
	target.apply_damage(10, BRUTE/*, wound_bonus = CANT_WOUND*/)
	target.balloon_alert(source, "удар в спину!")
	playsound(target, 'sound/weapons/guillotine.ogg', 100, TRUE)


/datum/heretic_knowledge/limited_amount/starting/base_blade/create_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/blade/blade_mark = ..()
	if(!istype(blade_mark))
		return blade_mark

	var/area/to_lock_to = get_area(target)
	blade_mark.locked_to = to_lock_to
	to_chat(target, span_purple("Потусторонняя сила заставляет вас оставаться в [get_area_name(to_lock_to)]!"))
	return blade_mark


/datum/heretic_knowledge/limited_amount/starting/base_blade/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	source.apply_status_effect(/datum/status_effect/protective_blades, 60 SECONDS, 1, 20, 0 SECONDS)


/*
 * Stance of the Torn Champion. The Blade path's knowledge_tier2, also offered to other
 * paths as a Tier-5 shop/draft side. master220 has no wound system, so the wound-resilience parts are
 * dropped; kept the iconic immunity-to-dismemberment, plus the low-health (<50%) "duelist stance".
 *
 * The duelist stance does NOT make you flat-out faster. It grants immunity to the damage-induced
 * slowdown via TRAIT_IGNOREDAMAGESLOWDOWN, which makes update_movespeed_damage_modifiers() drop
 * /datum/movespeed_modifier/damage_slowdown[_flying]. So while wounded below 50% you move at your
 * normal baseline pace instead of being slowed by your injuries - you never exceed baseline.
 * Driven off the Life tick (master220 has no COMSIG_LIVING_HEALTH_UPDATE).
 */
/datum/heretic_knowledge/duel_stance
	name = "Стойка Истерзанного Чемпиона"
	desc = "Дарует невосприимчивость к отсеканию конечностей. Кроме того, когда ваше здоровье \
			опускается ниже 50% от максимума, вы входите в стойку дуэлянта и перестаёте замедляться."
	gain_text = "Со временем именно он остался стоять один среди тел своих павших товарищей, омытый кровью, \
				но ни капли её не было его собственной. Он остался без соперника, без равного, без цели."
	cost = 2
	drafting_tier = 5
	research_tree_icon_path = 'icons/effects/blood.dmi'
	research_tree_icon_state = "suitblood"
	/// Whether we're currently in the low-health duelist stance.
	var/in_duelist_stance = FALSE

/datum/heretic_knowledge/duel_stance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	ADD_TRAIT(user, TRAIT_NODISMEMBER, type)
	RegisterSignal(user, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life_check))
	if(isliving(user))
		check_stance(user) // apply immediately if learned while already hurt

/datum/heretic_knowledge/duel_stance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	REMOVE_TRAIT(user, TRAIT_NODISMEMBER, type)
	if(in_duelist_stance)
		REMOVE_TRAIT(user, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	in_duelist_stance = FALSE
	UnregisterSignal(user, list(COMSIG_ATOM_EXAMINE, COMSIG_LIVING_LIFE))

/datum/heretic_knowledge/duel_stance/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(in_duelist_stance)
		examine_list += span_warning("[source] выглядит неестественно собранно, готовясь нанести удар.")

/datum/heretic_knowledge/duel_stance/proc/on_life_check(mob/living/source)
	SIGNAL_HANDLER
	check_stance(source)

/datum/heretic_knowledge/duel_stance/proc/check_stance(mob/living/source)
	if(in_duelist_stance && source.health > source.maxHealth * 0.5)
		in_duelist_stance = FALSE
		source.balloon_alert(source, "обычная стойка")
		REMOVE_TRAIT(source, TRAIT_IGNOREDAMAGESLOWDOWN, type)
		return
	if(!in_duelist_stance && source.health <= source.maxHealth * 0.5)
		in_duelist_stance = TRUE
		source.balloon_alert(source, "стойка дуэлянта")
		ADD_TRAIT(source, TRAIT_IGNOREDAMAGESLOWDOWN, type)


/datum/heretic_knowledge/armor/blade
	name = "Расколотая Паноплия" // Shattered Panoply
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску и слиток серебра или титана \
			в Расколотую Паноплию. Полностью защищает от шока и сопротивляется оглушению дубинками, \
			пока надета. Действует в качестве источника фокуса, пока надет капюшон."
	gain_text = "Эхо бесцельной какофонии насилия отдаётся вокруг меня. Даже когда стальную паноплию Чемпиона \
				сорвали с его тела, каждая её часть всё ещё жаждет цели, стремясь перехватить незримые удары."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade)
	research_tree_icon_state = "blade_armor"
	research_tree_icon_frame = 1
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)


/datum/heretic_knowledge/spell/realignment
	name = "Перестройка"
	desc = "Даёт вам \"Перестройку\", заклинание, которое быстро перестраивает ваше тело на короткий промежуток времени. \
			Во время этого процесса вы будете быстро восстанавливать выносливость и быстро восстанавливаться от оглушения, \
			однако не сможете атаковать."
	gain_text = "В круговерти смерти он обрёл внутренний покой. Несмотря на непреодолимые препятствия, он продолжал идти вперёд."
	research_tree_icon_path = 'icons/hud/implants.dmi'
	research_tree_icon_state = "adrenal"
	spell_to_add = /obj/effect/proc_holder/spell/realignment
	cost = 2


/datum/heretic_knowledge/spell/wolves_among_sheep
	name = "Волк среди Овец"
	desc = "Изменяет ткань реальности, создавая магическую арену, закрытую для посторонних. \
			Все участники оказываются в ловушке и становятся невосприимчивыми к \
			опасностям окружающей среды. Пойманным участникам даруется Клинок, и они не могут \
			покинуть ловушку, пока не нанесут противнику критический удар. \
			Критические удары частично восстанавливают здоровье Еретика."
	gain_text = "Кто-то идет по комнате, отбрасывая неясные тени. Кто-то замахивается клинком над спящим. \
				Я нажил себе врагов. Я больше никогда не познаю мир. Я разрушил все связи и \
				разорвал все союзы. В этой истине я теперь знаю хрупкость товарищества. Мои враги падут."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "among_sheep"
	cost = 2
	spell_to_add = /obj/effect/proc_holder/spell/wolves_among_sheep
	is_final_knowledge = TRUE


/datum/heretic_knowledge/blade_upgrade/blade
	name = "Усиленные Клинки"
	desc = "Атака с Клинками в обеих руках теперь будет наносить удар обоими руками \
			одновременно. Второй удар будет немного слабее. Вы можете вкладывать силу \
			Обители непосредственно в свои клинки, а сами клинки наносят гораздо больше \
			урона строениям, силиконам и мехам."
	gain_text = "Я нашел его расколотым надвое, половинки сцепились в бесконечном поединке; \
				Вокруг был шквал клинков, но ни один не достиг цели, ибо Чемпион был неукротим."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_blade"
	/// How much force do we apply to the offhand?
	var/offand_force_decrement = 0
	/// How much force was the last weapon we offhanded with? If it's different, we need to re-calculate the decrement
	var/last_weapon_force = -1


/datum/heretic_knowledge/blade_upgrade/blade/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(do_melee_effects), override = TRUE)


/datum/heretic_knowledge/blade_upgrade/blade/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, list(COMSIG_TOUCH_HANDLESS_CAST, COMSIG_HERETIC_BLADE_ATTACK))


///Tries to infuse our held blade with our mansus grasp
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_grasp_cast(mob/living/carbon/cast_on)
	SIGNAL_HANDLER

	var/held_item = cast_on.get_active_hand()
	if(!istype(held_item, /obj/item/melee/sickly_blade/dark))
		return NONE

	var/obj/item/melee/sickly_blade/dark/held_blade = held_item
	if(held_blade.infused)
		return NONE

	held_blade.infused = TRUE
	held_blade.update_appearance(UPDATE_ICON)

	var/obj/item/melee/sickly_blade/dark/off_hand_blade = cast_on.get_inactive_hand()
	if(istype(off_hand_blade, /obj/item/melee/sickly_blade/dark))
		off_hand_blade.infused = TRUE
		off_hand_blade.update_appearance(UPDATE_ICON)

	cast_on.update_held_items()

	return COMPONENT_CAST_HANDLESS


/datum/heretic_knowledge/blade_upgrade/blade/do_melee_effects(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(target == source)
		return

	var/obj/item/off_hand = source.get_inactive_hand()
	if(QDELETED(off_hand) || !istype(off_hand, /obj/item/melee/sickly_blade))
		return

	if(off_hand == blade)
		return

	addtimer(CALLBACK(src, PROC_REF(follow_up_attack), source, target, off_hand), 0.25 SECONDS)


/datum/heretic_knowledge/blade_upgrade/blade/proc/follow_up_attack(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(QDELETED(source) || QDELETED(target) || QDELETED(blade))
		return

	if(blade != source.get_inactive_hand())
		return

	if(!source.Adjacent(target))
		return

	if(last_weapon_force == blade.force)
		blade.melee_attack_chain(source, target, null, list(FORCE_MODIFIER = -offand_force_decrement))
		return

	offand_force_decrement = 0
	var/hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2))
	while(hits_to_crit_on_average <= 3) // 3 hits and beyond is a bit too absurd
		if(offand_force_decrement + 2 > blade.force * 0.5) // Cutting the force beyond half is absurd too
			break

		offand_force_decrement += 2
		hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2 - offand_force_decrement))

	blade.melee_attack_chain(source, target, null, list(FORCE_MODIFIER = -offand_force_decrement))

/datum/heretic_knowledge/spell/furious_steel
	name = "Яростная сталь"
	desc = "Даёт вам \"Яростную сталь\", направляемое заклинание. При его использовании вокруг \
			вас появятся три вращающихся клинка. Эти клинки защитят вас от атак, \
			но расходуются при использовании. Кроме того, вы можете, выстрелить клинками \
			в цель, нанося урон и вызывая кровотечение."
	gain_text = "Не раздумывая, я схватил нож павшего солдата и метнул его со всей силы. \
				Мои тренировки меня не подвели! Истерзанный Чемпион улыбнулся, \
				впервые почувствовав боль. Его клинки стали моими."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "furious_steel"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/projectile/furious_steel
	cost = 2


/datum/heretic_knowledge/ultimate/blade_final
	name = "Серебрянный водоворот"
	desc = "Ритуал вознесения Пути Клинка. \
			Принесите 3 безголовых трупа к руне трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы будете окружены множеством клинков. \
			Эти клинки защитят вас от всех атак, но расходуются при использовании. \
			Ваше заклинание \"Неистовая сталь\" также будет перезаряжаться быстрее. \
			Кроме того, вы становитесь мастером боя, получая полную невосприимчивость \
			к переломам и любым кровотечениям — внутренним, артериальным и обычным - \
			а также способность игнорировать кратковременные оглушения. \
			Ваши клинки наносят дополнительный урон и исцеляют вас при \
			атаке на часть нанесенного урона."
	gain_text = "Я достиг вершины боевого мастерства! МНЕ НЕТ РАВНЫХ! ДА НАСТИГНЕТ МОИХ ВРАГОВ БУРЯ ИЗ СТАЛИ И СЕРЕБРА! СТАНЬТЕ СВИДЕТЕЛЯМИ МОЕГО ВОЗНЕСЕНИЯ!"

	announcement_text = "%SPOOKY% Воздух пронзает свист тысячи лезвий! Мастер Клинка %NAME% вознёсся! Сталь клинков рассечет реальность в серебрянном водовороте! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_blade.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "bladeascend"


/datum/heretic_knowledge/ultimate/blade_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return !sacrifice.get_bodypart(BODY_ZONE_HEAD)// || HAS_TRAIT(sacrifice, TRAIT_HAS_CRANIAL_FISSURE)


/datum/heretic_knowledge/ultimate/blade_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.add_fracture_ignore_trait(type)
		human_user.physiology.knockdown_mod = 0.75 // Otherwise knockdowns would probably overpower the stun absorption effect.
		for(var/obj/item/organ/external/bodypart as anything in human_user.bodyparts)
			bodypart.cannot_break = TRUE
			bodypart.cannot_internal_bleed = TRUE
			bodypart.cannot_arterial_bleed = TRUE
			bodypart.stop_internal_bleeding()
			bodypart.stop_bleeding()
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(suppress_external_bleeding))
	user.apply_status_effect(/datum/status_effect/protective_blades/recharging, STATUS_EFFECT_PERMANENT, 8, 30, 0.25 SECONDS, /obj/effect/floating_blade, 60 SECONDS)
	user.add_status_effect_absorption(
		source = type,
		effect_type = list(STUN, WEAKEN, KNOCKDOWN, PARALYZE, IMMOBILIZE),
		message = span_warning("%EFFECT_OWNER выдерживает оглушение!"),
		self_message = span_warning("Вы выдерживаете оглушение!"),
		examine_message = span_purple("%EFFECT_OWNER_THEYRE слегка покачивается."),
		max_seconds_of_effect_blocked = 45 SECONDS,
		delete_after_passing_max = FALSE,
		recharge_time = 2 MINUTES,
	)
	var/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/steel_spell = locate() in user.mob_spell_list
	if(steel_spell)
		steel_spell.base_cooldown /= 2
		if(steel_spell.cooldown_handler)
			steel_spell.cooldown_handler.recharge_duration /= 2


/// Wipes plain external bleeding (the only kind master220 has no per-limb prevention flag for). Early-outs
/// when the heretic isn't bleeding, so it's essentially free on idle ticks and only acts right after a hit.
/datum/heretic_knowledge/ultimate/blade_final/proc/suppress_external_bleeding(mob/living/source)
	SIGNAL_HANDLER

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/human_source = source
	if(!human_source.bleed_rate) // Cheap O(1) check - nothing to do unless we're actually bleeding.
		return

	for(var/obj/item/organ/external/bodypart as anything in human_source.bleeding_bodyparts)
		bodypart.stop_bleeding() // bleeding_amount = 0; SSblood prunes the part from bleeding_bodyparts next pass


/datum/heretic_knowledge/ultimate/blade_final/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	if(!istype(target))
		return

	if(target == source)
		return

	var/bonus_damage = clamp(30 - blade.force, 0, 12)

	target.apply_damage(
		damage = bonus_damage,
		damagetype = BRUTE,
		spread_damage = TRUE,
		sharp = TRUE,
	)

	if(target.stat != DEAD)
		source.heal_overall_damage(bonus_damage / 2, bonus_damage / 2)


///Checks to see if `atom/source` is behind `atom/target`
/proc/check_behind(atom/source, atom/target)


	if(target.loc == source.loc)
		return TRUE

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.body_position == LYING_DOWN)
			return TRUE

	var/dir_target_to_source = get_dir(target, source)
	if(target.dir & REVERSE_DIR(dir_target_to_source))
		return TRUE

	return FALSE
