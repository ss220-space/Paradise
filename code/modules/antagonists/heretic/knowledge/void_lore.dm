
/datum/heretic_knowledge_tree_column/main/void

	route = PATH_VOID
	ui_bgr = "node_void"
	complexity = "Лёгкий"
	complexity_color = "#20b142"
	path_description = list(
		"Путь Пустоты строится вокруг скрытности, леденящего холода, мобильности и разгерметизации.",
		"Берите этот путь, если вам по душе роль неуловимого ассасина, за которым врагам не угнаться.",
	)
	path_pros = list(
		"Защита от опасностей космоса.",
		"Ваши заклинания накладывают стакающийся дебафф, охлаждающий и замедляющий цели.",
		"Множество заклинаний мобильности.",
		"Высокая скрытность.",
	)
	path_cons = list(
		"В космосе вы защищены, но передвигаетесь там куда хуже, чем пешком.",
		"Трудно сражаться с противниками, невосприимчивыми к холоду.",
		"Трудно сражаться с силиконовыми формами жизни.",
	)
	path_tips = list(
		"\"Хватка Обители\" заглушает жертву — идеально для бесшумных убийств (учтите: датчики костюма оно не отключает, не забудьте выключить их после убийства). Хватка также накладывает метку: сработав от удара Клинком Пустоты, она накладывает максимум зарядов пустотного озноба, замедляя жертву до предела.",
		"Плащ Пустоты с опущенным капюшоном прячет один из ваших клинков и Кодекс Истязания, а с надетым — служит источником фокуса.",
		"\"Пустотный озноб\" — дебафф, накладываемый вашими заклинаниями, хваткой, меткой и (после улучшения) клинком. Каждый заряд замедляет цель на 10% и постепенно охлаждает её; максимум 5 зарядов.",
		"На 5 зарядах пустотный озноб не даёт жертве согреться.",
		"С самого начала смены вы невосприимчивы к низкому давлению и холоду. Улучшите пассивную способность до 2 уровня, чтобы перестать нуждаться в дыхании. Используйте это с умом.",
		"\"Пустотная Тюрьма\" запирает цель в шаре на десяток секунд. Идеально, чтобы изолировать одного противника, сражаясь с несколькими.",
		"\"Врата в Пустоту\" - ваша визитная карточка. Вонзите Клинок Пустоты в космос, снег или вакуум, чтобы открыть врата: они постепенно уничтожают окна и шлюзы вокруг зоны действия. Используйте их для разгерметизации станции и расширения своих владений. Клинок при этом расходуется.",
	)
	passive_name = "Путь Аристократа"
	passive_descriptions = list(
		"Иммунитет к холоду и низкому давлению.",
		"Вам больше не нужно дышать.",
		"Вода, лёд и скользкие поверхности вам не страшны.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_void
	knowledge_tier1 = /datum/heretic_knowledge/spell/void_phase
	knowledge_tier2 = /datum/heretic_knowledge/void_prison
	robes = /datum/heretic_knowledge/armor/void
	knowledge_tier3 = /datum/heretic_knowledge/spell/void_pull
	blade = /datum/heretic_knowledge/blade_upgrade/void
	knowledge_tier4 = /datum/heretic_knowledge/void_conduit
	ascension = /datum/heretic_knowledge/ultimate/void_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/void_cloak
	guaranteed_side_tier2 = /datum/heretic_knowledge/ether
	guaranteed_side_tier3 = /datum/heretic_knowledge/limited_amount/summon/maid_in_mirror


/datum/heretic_knowledge/limited_amount/starting/base_void
	name = "Зима Близко" // Game of thrones
	desc = "Открывает вам Путь Пустоты. \
			Позволяет при низких температурах превратить нож в Клинок Пустоты. \
			Вы можете создать только два клинка одновременно."
	gain_text = "Я вижу блеск в воздухе, воздух вокруг становится холоднее. \
				Я начинаю осознавать пустоту бытия. Что-то наблюдает за мной."
	required_atoms = list(/obj/item/kitchen/knife = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "void_blade"
	mark_type = /datum/status_effect/eldritch/void
	passive_type = /datum/status_effect/heretic_passive/void


/datum/heretic_knowledge/limited_amount/starting/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/simulated/loc)
	if(loc.get_readonly_air()?.temperature() < T0C)
		return ..()

	loc.balloon_alert(user, "слишком тепло!")
	return FALSE


/// Mansus Grasp: the parent applies our mark, then we silence and chill carbon victims.
/datum/heretic_knowledge/limited_amount/starting/base_void/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.AdjustSilence(10 SECONDS)
	carbon_target.apply_status_effect(/datum/status_effect/void_chill, 2)


/datum/heretic_knowledge/spell/void_phase
	name = "Пустотный Сдвиг"
	desc = "Дарует вам \"Пустотный Сдвиг\", заклинание телепортации на большие расстояния. \
			Кроме того, наносит урон врагам вокруг вашей исходной и целевой точки назначения."
	gain_text = "Я был в пустоте. Я видел сущность называющую себя Аристократом. \
				Она летела оставляя после себя резкий, холодный ветер. Я следовал за ней, но \
				она исчезла, оставив меня посреди метели."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "voidblink"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_phase
	cost = 2
	research_tree_icon_frame = 7


/datum/heretic_knowledge/void_prison
	drafting_tier = 5 // each path's signature spell is a cross-path tier-5 draftable
	name = "Пустотная Тюрьма"
	desc = "Позволяет преобразовать наручники, стандубинку и шкаф в \"Пустотную Тюрьму\".<br>\
			Пустотная Тюрьма — сфера, при использовании заключающая всех ближайших язычников \
			без метки в стазис-шар на 10 секунд. Внутри шара они не могут говорить, действовать \
			или получать урон. Сфера расходуется после одного использования."
	transmute_text = "Преобразуйте наручники, стандубинку и шкаф."
	gain_text = "Я вижу себя, вальсирующего по заснеженной улице. \
				Я пытаюсь кричать, пытаюсь схватить этого дурака, пытаюсь сказать ему, чтобы он бежал. \
				Моё улыбающееся лицо поворачивается ко мне, отражая в остекленевших глазах пустоту — путь по которому я шёл."
	required_atoms = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/structure/closet = 1,
		/obj/item/melee/baton/security = 1,
	)
	result_atoms = list(/obj/item/void_prison)
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "voidball"
	cost = 2
	var/list/closet_blacklist = list(
		/obj/structure/closet/crate,
		/obj/structure/closet/body_bag,
		/obj/structure/closet/cardboard,
	)


/datum/heretic_knowledge/void_prison/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/structure/closet/closet in atoms)
		if(is_type_in_list(closet, closet_blacklist))
			atoms -= closet


/datum/heretic_knowledge/void_prison/cleanup_atoms(list/selected_atoms)
	for(var/obj/structure/closet/closet in selected_atoms)
		closet.dump_contents()

	return ..()


/datum/heretic_knowledge/armor/void
	name = "Полое Плетение" // Hollow Weave
	desc = "Позволяет преобразовать стол (или верхнюю одежду) и маску при температуре ниже нуля в Полое Плетение. \
			Эта броня периодически полностью поглощает атаки, даруя вам краткую маскировку, чтобы сменить позицию. \
			Действует в качестве источника фокуса, пока надет капюшон."
	gain_text = "Ступая сквозь холодный воздух, я ощутил нечто новое. \
				Тысячи почти неразличимых нитей льнут к моему телу. \
				С каждым шагом я словно плыву по течению. \
				Я слышу хруст снега под ногой — но не чувствую ничего."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/void)
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
	)
	research_tree_icon_state = "void_armor"
	research_tree_icon_frame = 1


/datum/heretic_knowledge/armor/void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/simulated/loc)
	if(loc.get_readonly_air()?.temperature() < T0C)
		return ..()

	loc.balloon_alert(user, "слишком тепло!")
	return FALSE


/datum/heretic_knowledge/spell/void_pull
	name = "Притяжение Пустоты"
	desc = "Дает вам Притяжение Пустоты, заклинание, притягивающее к вам всех находящихся поблизости язычников, ненадолго оглушая их."
	gain_text = "Всё мимолётно, но что же ещё остаётся? Я близок к завершению начатого. \
				Аристократы снова открываются мне. Они говорят, что я опоздал. \
				Их притяжение огромно, я не могу повернуть назад."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "voidpull"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/void_pull
	cost = 2

	research_tree_icon_frame = 6


/datum/heretic_knowledge/blade_upgrade/void
	name = "Ищущий Клинок"
	desc = "Ваш клинок теперь замораживает врагов. Кроме того, теперь вы можете \
			атаковать далекие отмеченные цели своим Клинком Пустоты, телепортируясь прямо к ним."
	gain_text = "Мимолётные воспоминания, мимолётные шаги. Я шёл среди метели, отмечая свой путь замёрзшей кровью на снегу. Никто не пришел. Моё тело осталось там, под снегом, всеми забытое."

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_void"


/datum/heretic_knowledge/blade_upgrade/void/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.apply_status_effect(/datum/status_effect/void_chill, 2)


/datum/heretic_knowledge/blade_upgrade/void/do_ranged_effects(mob/living/user, atom/target, obj/item/melee/sickly_blade/blade)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(!living_target.has_status_effect(/datum/status_effect/eldritch))
		return

	var/dir = angle2dir(dir2angle(get_dir(user, target)) + 180)
	user.forceMove(get_step(target, dir))

	INVOKE_ASYNC(src, PROC_REF(follow_up_attack), user, target, blade)


/datum/heretic_knowledge/blade_upgrade/void/proc/follow_up_attack(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	blade.melee_attack_chain(user, target)


/datum/heretic_knowledge/void_conduit
	name = "Врата в Пустоту"
	desc = "Наделяет ваш клинок силой разрывать саму ткань пространства.<br>\
			Ударив Клинком Пустоты по космосу, вы откроете врата в Пустоту, \
			наносящие урон и замораживающие ближайших язычников, \
			а также разрушающие окна и шлюзы в округе."
	notice = "Клинок расходуется в процессе. Способность также работает на снегу и на любом тайле в полном вакууме."
	gain_text = "Гул в неподвижном, холодном воздухе превращается в какофонию. \
				Сквозь этот шум не различить стук оконных стёкол и хаотичный бред, проносящийся в моей голове. \
				Врата не закрыть. Теперь я не могу уберечься от холода."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "void_rift"
	cost = 2
	is_final_knowledge = TRUE


/datum/heretic_knowledge/void_conduit/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_BLADE_PREATTACK, PROC_REF(on_blade_preattack))


/datum/heretic_knowledge/void_conduit/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_BLADE_PREATTACK)


/datum/heretic_knowledge/void_conduit/proc/is_valid_turf(turf/affected_turf)
	if(isspaceturf(affected_turf) || issnowturf(affected_turf))
		return TRUE
	var/datum/gas_mixture/air = affected_turf.get_readonly_air()
	if(!air || air.return_pressure() <= 0)
		return TRUE
	return FALSE


/datum/heretic_knowledge/void_conduit/proc/is_turf_still_cold(turf/affected_turf)
	var/datum/gas_mixture/air = affected_turf.get_readonly_air()
	return !air || air.temperature() <= T0C


/datum/heretic_knowledge/void_conduit/proc/is_valid_turf_callback(turf/affected_turf, mob/living/source, obj/item/sword)
	if(!source.is_in_hands(sword))
		return FALSE
	if(!is_valid_turf(affected_turf))
		return FALSE
	if(!is_turf_still_cold(affected_turf))
		return FALSE
	return TRUE


/datum/heretic_knowledge/void_conduit/proc/on_blade_preattack(mob/living/source, atom/target, obj/item/sword)
	SIGNAL_HANDLER
	if(!isturf(target) || iswallturf(target))
		return NONE

	var/turf/affected_turf = target
	if(!is_valid_turf(affected_turf))
		return NONE

	if(is_turf_still_cold(affected_turf))
		INVOKE_ASYNC(src, PROC_REF(create_conduit), affected_turf, source, sword)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	to_chat(source, span_mansus("[DECLENT_RU_CAP(sword, NOMINATIVE)] гудит от силы, но [affected_turf.declent_ru(NOMINATIVE)] недостаточно холодн[GEND_A_O_Y(affected_turf)], чтобы открыть врата!"))
	return NONE


/datum/heretic_knowledge/void_conduit/proc/create_conduit(turf/affected_turf, mob/living/source, obj/item/sword)
	playsound(source, 'sound/magic/voidblink.ogg', 50, TRUE)
	to_chat(source, span_mansus("Вы вонзаете [sword.declent_ru(ACCUSATIVE)] глубоко в [affected_turf.declent_ru(ACCUSATIVE)], пытаясь разорвать проход в Пустоту!"))
	source.visible_message(
		span_mansus("[DECLENT_RU_CAP(source, NOMINATIVE)] вонзает [sword.declent_ru(ACCUSATIVE)] в [affected_turf.declent_ru(ACCUSATIVE)] — и из разлома начинает сочиться тёмная энергия!"),
		ignored_mobs = list(source),
	)
	var/obj/effect/temp_visual/void_conduit_opening/animation = new(affected_turf)
	if(!do_after(source, 5 SECONDS, affected_turf, extra_checks = CALLBACK(src, PROC_REF(is_valid_turf_callback), affected_turf, source, sword)))
		animate(animation, alpha = 0, time = 1 SECONDS)
		QDEL_IN(animation, 1 SECONDS)
		return
	to_chat(source, span_mansus("Врата открываются, высвобождая шторм пустотной энергии! [DECLENT_RU_CAP(sword, NOMINATIVE)] рассыпается на миллион крошечных осколков!"))
	source.visible_message(
		span_mansus("Врата в Пустоту открываются, высвобождая шторм пустотной энергии!"),
		ignored_mobs = list(source),
	)
	new /obj/structure/void_conduit(affected_turf)
	source.drop_item_ground(sword)
	qdel(sword)
	playsound(source, SFX_SHATTER, 50, FALSE)


/datum/looping_sound/void_loop
	mid_sounds = list('sound/music/heretic/VoidsEmbrace.ogg' = 1)
	mid_length = 166.9 SECONDS // exact length of the music in ticks
	extra_range = 30


/datum/heretic_knowledge/ultimate/void_final
	name = "Вальс Конца Времён"
	desc = "Ритуал вознесения Пути Пустоты. \
			Принесите 3 трупа к руне трансмутации при температуре ниже нуля, чтобы завершить ритуал. \
			После завершения вызывает мощную снежную бурю, замораживающую и нанося урон дикарям. \
			Те, кто находится рядом, будут заморожены и обездвижены ещё быстрее. \
			Кроме того, вы становитесь невосприимчивы к эффектам космоса."
	gain_text = "Мир погружается во тьму. Я стою посреди пустоты, с неба падают снежинки.\
				Аристократ стоит передо мной. Аристократ манит меня. Мы сыграем вальс под шёпот умирающей реальности,\
				пока мир разрушается на наших глазах. Всё обратится в ничто, СТАНЬ СВИДЕТЕЛЕМ МОЕГО ВОЗНЕСЕНИЯ!"

	announcement_text = "%SPOOKY% Дворянин пустоты %NAME% прибыл, шагая в Вальсе, который положит конец всему! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_void.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "voidascend"
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm
	///The storm where there are actual effects
	var/datum/proximity_monitor/advanced/void_storm/heavy_storm


/datum/heretic_knowledge/ultimate/void_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/simulated/loc)
	if(loc.get_readonly_air()?.temperature() < T0C)
		return ..()

	loc.balloon_alert(user, "неподходящее место!")
	return FALSE


/datum/heretic_knowledge/ultimate/void_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.add_traits(list(TRAIT_RESIST_COLD, TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING), type)

	sound_loop = new(user, TRUE, TRUE)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(user, COMSIG_HUMAN_TRY_DEFLECT_BULLET, PROC_REF(hit_by_projectile))
	RegisterSignals(user, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_death))
	heavy_storm = new(user, 10)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/ascended_human = user
	ascended_human.update_sight()


/datum/heretic_knowledge/ultimate/void_final/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	on_death(user)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Any non-heretics nearby the heretic ([source])
 * are constantly silenced and battered by the storm.
 *
 * Also starts storms in any area that doesn't have one.
 */
/datum/heretic_knowledge/ultimate/void_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(async_on_life), source, seconds_per_tick, times_fired)


/datum/heretic_knowledge/ultimate/void_final/proc/async_on_life(mob/living/source, seconds_per_tick, times_fired)

	for(var/atom/thing_in_range as anything in range(10, source))
		if(iscarbon(thing_in_range))
			var/mob/living/carbon/close_carbon = thing_in_range
			if(close_carbon.can_block_magic())
				continue
			if(IS_HERETIC_OR_MONSTER(close_carbon))
				close_carbon.apply_status_effect(/datum/status_effect/void_conduit)
				continue

			close_carbon.AdjustSilence(2 SECONDS, 0, 20 SECONDS)
			close_carbon.apply_status_effect(/datum/status_effect/void_chill, 1)
			close_carbon.EyeBlurry(rand(0 SECONDS, 2 SECONDS))
			close_carbon.adjust_bodytemperature(-30 * TEMPERATURE_DAMAGE_COEFFICIENT)

		if(istype(thing_in_range, /obj/machinery/door) || istype(thing_in_range, /obj/structure/door_assembly))
			var/obj/affected_door = thing_in_range
			affected_door.take_damage(rand(60, 80))

		if(is_window(thing_in_range) || istype(thing_in_range, /obj/structure/grille))
			var/obj/structure/affected_structure = thing_in_range
			affected_structure.take_damage(rand(20, 40))

		if(!isturf(thing_in_range))
			continue

		var/turf/affected_turf = thing_in_range
		var/datum/gas_mixture/environment = affected_turf.get_readonly_air()
		environment.set_temperature(environment.temperature() * 0.9) // master220 MILLA: temperature is via getter/setter (runtime: may need a milla_safe write to persist)

	var/list/station_levels = levels_by_trait(STATION_LEVEL)
	if(storm)
		return

	storm = new /datum/weather/void_storm(station_levels)
	storm.telegraph()


/**
 * Signal proc for [COMSIG_LIVING_DEATH].
 *
 * Stop the storm when the heretic passes away.
 */
/datum/heretic_knowledge/ultimate/void_final/proc/on_death(datum/source)
	SIGNAL_HANDLER

	if(sound_loop)
		sound_loop.stop()

	if(storm)
		storm.end()
		QDEL_NULL(storm)

	if(heavy_storm)
		QDEL_NULL(heavy_storm)

	UnregisterSignal(source, list(COMSIG_LIVING_LIFE, COMSIG_HUMAN_TRY_DEFLECT_BULLET, COMSIG_LIVING_DEATH, COMSIG_QDELETING))


///Few checks to determine if we can deflect bullets
/datum/heretic_knowledge/ultimate/void_final/proc/can_deflect(mob/living/ascended_heretic)
	if(!(ascended_heretic.mobility_flags & MOBILITY_USE))
		return FALSE

	if(!isturf(ascended_heretic.loc))
		return FALSE

	return TRUE


/// Signal proc for [COMSIG_HUMAN_TRY_DEFLECT_BULLET] (the port's additive PRE_BULLET_ACT hook):
/// the void storm around the ascended heretic deflects every projectile - 75% straight back at the
/// shooter, otherwise off in a random direction. Returning COMPONENT_BULLET_DEFLECTED makes
/// bullet_act() return -1, so the (re-aimed) projectile keeps flying instead of hitting us.
/datum/heretic_knowledge/ultimate/void_final/proc/hit_by_projectile(mob/living/ascended_heretic, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(!can_deflect(ascended_heretic))
		return NONE

	ascended_heretic.visible_message(
		span_danger("Пустотный шторм отражает [hitting_projectile.declent_ru(ACCUSATIVE)]!"),
		span_userdanger("Пустотный шторм защищает вас от [hitting_projectile.declent_ru(GENITIVE)]!"),
	)
	playsound(ascended_heretic, pick('sound/effects/void_deflect1.ogg', 'sound/effects/void_deflect2.ogg', 'sound/effects/void_deflect3.ogg'), 75, TRUE)
	if(prob(75))
		hitting_projectile.reflect_back(ascended_heretic)
	else
		hitting_projectile.firer = ascended_heretic
		hitting_projectile.set_angle(rand(0, 360)) //SHING
	return COMPONENT_BULLET_DEFLECTED

/datum/weather/void_storm
	name = "пустотный шторм"
	desc = "Редкое и крайне ненормальное событие, часто сопровождаемое неизвестными сущностями, разрывающими пространственно-временной континуум. Вам лучше начать бежать."

	telegraph_duration = 2 SECONDS
	telegraph_overlay = "light_snow"

	weather_message = "<span class='purple'>Вы чувствуете, как воздух вокруг становится холоднее... Вы чувствуете сладкие объятия пустоты...</span>"
	weather_overlay = "light_snow"
	weather_color = COLOR_BLACK
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES
	endless = TRUE
	aesthetic = TRUE

	end_duration = 10 SECONDS

	area_type = /area

