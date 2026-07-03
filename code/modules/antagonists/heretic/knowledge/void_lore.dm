
/datum/heretic_knowledge_tree_column/main/void
	neighbour_type_left = /datum/heretic_knowledge_tree_column/flesh_to_void
	neighbour_type_right = /datum/heretic_knowledge_tree_column/void_to_blade

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
		"«Прикосновение Мансуса» заглушает жертву — идеально для бесшумных убийств (учтите: датчики костюма оно не отключает, не забудьте выключить их после убийства). Прикосновение также накладывает метку: сработав от удара Клинком Пустоты, она накладывает максимум зарядов пустотного озноба, замедляя жертву до предела.",
		"Плащ Пустоты с опущенным капюшоном прячет один из ваших клинков и Кодекс Цикатрикс, а с поднятым — служит амулетом.",
		"Пустотный озноб — дебафф, накладываемый вашими заклинаниями, прикосновением, меткой и (после улучшения) клинком. Каждый заряд замедляет цель на 10% и постепенно охлаждает её; максимум 5 зарядов.",
		"На 5 зарядах пустотный озноб не даёт жертве согреться.",
		"С самого начала смены вы невосприимчивы к низкому давлению и холоду. Улучшите пассивную способность до 2 уровня, чтобы перестать нуждаться в дыхании. Используйте это с умом.",
		"«Пустотная Тюрьма» запирает цель в шаре на десяток секунд. Идеально, чтобы изолировать одного противника, сражаясь с несколькими.",
		"«Врата в Пустоту» — ваша визитная карточка. Они постепенно уничтожают окна и шлюзы вокруг зоны действия. Используйте их для разгерметизации станции и расширения своих владений.",
	)
	// "Aristocrat's Way" passive (see /datum/status_effect/heretic_passive/void): tiers light up as you grow.
	passive_name = "Путь Аристократа"
	passive_descriptions = list(
		"Иммунитет к холоду и низкому давлению.",
		"Вам больше не нужно дышать.",
		"Вода, лёд и скользкие поверхности вам не страшны.",
	)

	// TG-format column (1:1 with tgstation Void). Main line:
	// base_void -> Void Phase -> Void Prison -> Hollow Weave(robes) -> Void Pull -> Seeking Blade -> Void Conduit -> ascension.
	// The grasp (silence + chill) and the void mark are folded into base_void (matching TG, no separate nodes).
	start = /datum/heretic_knowledge/limited_amount/starting/base_void
	knowledge_tier1 = /datum/heretic_knowledge/spell/void_phase
	knowledge_tier2 = /datum/heretic_knowledge/spell/void_prison
	robes = /datum/heretic_knowledge/armor/void
	knowledge_tier3 = /datum/heretic_knowledge/spell/void_pull
	blade = /datum/heretic_knowledge/blade_upgrade/void
	knowledge_tier4 = /datum/heretic_knowledge/spell/void_conduit
	ascension = /datum/heretic_knowledge/ultimate/void_final
	// Side knowledges guaranteed to be offered in this path's drafts (TG).
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
	// TG folds the grasp (silence + chill), the void mark and the path passive into the starting knowledge.
	mark_type = /datum/status_effect/eldritch/void
	passive_type = /datum/status_effect/heretic_passive/void


/datum/heretic_knowledge/limited_amount/starting/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/simulated/loc)
	if(loc.get_readonly_air()?.temperature() < T0C)
		return ..()

	loc.balloon_alert(user, "слишком тепло!")
	return FALSE


/// Folded from the old "Понимание пустоты" grasp node (TG parity): the parent applies our mark,
/// then we silence and chill carbon victims.
/datum/heretic_knowledge/limited_amount/starting/base_void/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	// TG adjust_silence(10 SECONDS): stacks on top of any existing silence, unlike Silence() which only maxes.
	carbon_target.AdjustSilence(10 SECONDS)
	carbon_target.apply_status_effect(/datum/status_effect/void_chill, 2)


/datum/heretic_knowledge/spell/void_phase
	name = "Пустотный Сдвиг"
	desc = "Дарует вам «Пустотный Сдвиг» — заклинание телепортации на большие расстояния. \
			Кроме того, наносит урон врагам вокруг вашей исходной и целевой точки назначения."
	gain_text = "Я был в пустоте. Я видел сущность называющую себя Аристократом. \
				Она летела оставляя после себя резкий, холодный ветер. Я следовал за ней, но \
				она исчезла, оставив меня посреди метели."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "voidblink"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_phase
	cost = 2 // TG: void_phase costs 2
	research_tree_icon_frame = 7


/datum/heretic_knowledge/spell/void_prison
	drafting_tier = 5 // TG: each path's signature spell is a cross-path tier-5 draftable
	name = "Пустотная Тюрьма"
	desc = "Даёт вам «Пустотную Тюрьму» — заклинание, заключающее вашу жертву в шар, \
			лишая её возможности что-либо делать или говорить. После накладывает пустотный озноб."
	gain_text = "Я вижу себя, вальсирующего по заснеженной улице. \
				Я пытаюсь кричать, пытаюсь схватить этого дурака, пытаюсь сказать ему, чтобы он бежал. \
				Моё улыбающееся лицо поворачивается ко мне, отражая в остекленевших глазах пустоту - путь по которому я шел."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "voidball"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_prison
	cost = 2 // TG: void_prison costs 2


/datum/heretic_knowledge/armor/void
	name = "Полое Плетение" // Hollow Weave
	desc = "Позволяет преобразовать стол (или верхнюю одежду) и маску при температуре ниже нуля в Полое Плетение. \
			Эта броня периодически полностью поглощает атаки, даруя вам краткую маскировку, чтобы сменить позицию. \
			Действует как амулет, пока поднят капюшон."
	gain_text = "Ступая сквозь холодный воздух, я ощутил нечто новое. \
				Тысячи почти неразличимых нитей льнут к моему телу. \
				С каждым шагом я словно плыву по течению. \
				Я слышу хруст снега под ногой — но не чувствую ничего."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/void)
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
	)
	// The void robe sprite was spliced into the shared suits.dmi (matches tg's suits/armor.dmi "void_armor").
	// The /armor parent asks for frame 12 (eldritch_armor is a 14-frame anim); void_armor is single-frame.
	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "void_armor"
	research_tree_icon_frame = 1


/datum/heretic_knowledge/armor/void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/simulated/loc)
	if(loc.get_readonly_air()?.temperature() < T0C)
		return ..()

	loc.balloon_alert(user, "слишком тепло!")
	return FALSE


/datum/heretic_knowledge/spell/void_pull
	name = "Притяжение Пустоты"
	desc = "Дает вам Притяжение Пустоты — заклинание, притягивающее к вам всех находящихся поблизости язычников, ненадолго оглушая их."
	gain_text = "Всё мимолётно, но что же ещё остаётся? Я близок к завершению начатого. \
				Аристократы снова открываются мне. Они говорят, что я опоздал. \
				Их притяжение огромно, я не могу повернуть назад."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "voidpull"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/void_pull
	cost = 2 // TG: void_pull costs 2

	research_tree_icon_frame = 6


/datum/heretic_knowledge/blade_upgrade/void
	name = "Ищущий Клинок"
	desc = "Ваш клинок теперь замораживает врагов. Кроме того, теперь вы можете \
			атаковать далекие отмеченные цели своим Клинком Пустоты, телепортируясь прямо к ним."
	gain_text = "Мимолетные воспоминания, мимолетные шаги. Я шел среди метели отмечая свой путь замёрзшей кровью на снегу. Никто не пришел. Моё тело осталось там, под снегом, всеми забытое."

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_void"


/datum/heretic_knowledge/blade_upgrade/void/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.apply_status_effect(/datum/status_effect/void_chill, 2)


/datum/heretic_knowledge/blade_upgrade/void/do_ranged_effects(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!target.has_status_effect(/datum/status_effect/eldritch))
		return

	var/dir = angle2dir(dir2angle(get_dir(user, target)) + 180)
	user.forceMove(get_step(target, dir))

	INVOKE_ASYNC(src, PROC_REF(follow_up_attack), user, target, blade)


/datum/heretic_knowledge/blade_upgrade/void/proc/follow_up_attack(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	blade.melee_attack_chain(user, target)


/datum/heretic_knowledge/spell/void_conduit
	name = "Врата в Пустоту"
	desc = "Даёт вам «Врата в Пустоту» — заклинание, создающее пульсирующие врата в саму Пустоту. Каждый импульс разбивает окна и шлюзы, нанося вашим врагам жуткий холод и защищая еретиков от низкого давления."
	gain_text = "Гул в неподвижном, холодном воздухе превращается в какофонию. \
				Сквозь этот шум не различить стук оконных стёкол и хаотичный бред проносящийся в моей голове. \
				Врата не закрыть. Теперь я не могу уберечься от холода."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "void_rift"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/conjure/void_conduit
	cost = 2 // TG: void_conduit costs 2
	is_final_knowledge = TRUE


// The endless waltz that plays around the ascended nobleman of void (tg's void_loop, adapted paths).
/datum/looping_sound/void_loop
	mid_sounds = list('sound/music/heretic/VoidsEmbrace.ogg' = 1)
	mid_length = 166.9 SECONDS // exact length of the music in ticks
	volume = 100
	extra_range = 30


/datum/heretic_knowledge/ultimate/void_final
	name = "Вальс Конца Времен"
	desc = "Ритуал вознесения Пути Пустоты. \
			Принесите 3 трупа к руне трансмутации при температуре ниже нуля, чтобы завершить ритуал. \
			После завершения вызывает мощную снежную бурю, замораживающую и нанося урон дикарям. \
			Те, кто находится рядом, будут заморожены и обездвижены ещё быстрее. \
			Кроме того, вы становитесь невосприимчивы к эффектам космоса."
	gain_text = "Мир погружается во тьму. Я стою посреди пустоты, с неба падают снежинки.\
				Аристократ стоит передо мной. Аристократ манит меня. Мы сыграем вальс под шёпот умирающей реальности,\
				пока мир разрушается на наших глазах. Всё обратится в ничто, СТАНЬ СВИДЕТЕЛЕМ МОЕГО ВОЗНЕСЕНИЯ!"

	//ascension_achievement = /datum/award/achievement/misc/void_ascension
	announcement_text = "%SPOOKY% Дворянин пустоты %NAME% прибыл, шагая в Вальсе, который положит конец всему! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_void.ogg'
	// tg parity: the research-tree node wears the path's ascension achievement sprite.
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "voidascend"
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm
	///The storm where there are actual effects
	var/datum/component/proximity_monitor/advanced/void_storm/heavy_storm


/datum/heretic_knowledge/ultimate/void_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/simulated/loc)
	if(loc.get_readonly_air()?.temperature() < T0C)
		return ..()

	loc.balloon_alert(user, "не подходящее место!")
	return FALSE


/datum/heretic_knowledge/ultimate/void_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	// TG grants TRAIT_RESISTLOWPRESSURE; master220 gates low-pressure damage on TRAIT_RESIST_COLD
	// (see human/life.dm), which the void passive already provides - re-add it under our own source anyway
	// so losing the passive can never strip the ascension's space immunity.
	// (TRAIT_FREE_HYPERSPACE_MOVEMENT has no master220 equivalent.)
	user.add_traits(list(TRAIT_RESIST_COLD, TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING), type)

	// Let's get this show on the road!
	sound_loop = new(user, TRUE, TRUE)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(user, COMSIG_HUMAN_TRY_DEFLECT_BULLET, PROC_REF(hit_by_projectile))
	RegisterSignals(user, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_death))
	// NB: this is a tg-style COMPONENT - a bare new(user, 10) hands the mob to New(list/raw_args) and
	// runtimes on raw_args[1]; components must be created through AddComponent.
	heavy_storm = user.AddComponent(/datum/component/proximity_monitor/advanced/void_storm, 10)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/ascended_human = user
	//var/obj/item/organ/internal/eyes/heretic_eyes = ascended_human.get_organ_slot(INTERNAL_ORGAN_EYES)
	//heretic_eyes?.color_cutoffs = list(30, 30, 30) // master220 eyes have no color_cutoffs
	ascended_human.update_sight()


/datum/heretic_knowledge/ultimate/void_final/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	on_death(user) // Losing is pretty much dying. I think

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

			// TG adjust_silence_up_to(2 SECONDS, 20 SECONDS): each tick stacks silence, capped at 20s.
			close_carbon.AdjustSilence(2 SECONDS, 0, 20 SECONDS)
			close_carbon.apply_status_effect(/datum/status_effect/void_chill, 1)
			close_carbon.EyeBlurry(rand(0 SECONDS, 2 SECONDS))
			close_carbon.adjust_bodytemperature(-30 * TEMPERATURE_DAMAGE_COEFFICIENT)

		if(istype(thing_in_range, /obj/machinery/door) || istype(thing_in_range, /obj/structure/door_assembly))
			var/obj/affected_door = thing_in_range
			affected_door.take_damage(rand(60, 80))

		if(istype(thing_in_range, /obj/structure/window) || istype(thing_in_range, /obj/structure/grille))
			var/obj/structure/affected_structure = thing_in_range
			affected_structure.take_damage(rand(20, 40))

		if(!isturf(thing_in_range))
			continue

		var/turf/affected_turf = thing_in_range
		var/datum/gas_mixture/environment = affected_turf.get_readonly_air()
		environment.set_temperature(environment.temperature() * 0.9) // master220 MILLA: temperature is via getter/setter (runtime: may need a milla_safe write to persist)



	// Telegraph the storm in every area on the station.
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
		// Back where you came from (reflect_back re-aims at the projectile's starting turf and sets us as firer).
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

	//use_glow = FALSE
	weather_duration = 60 HOURS

	end_duration = 10 SECONDS

	area_type = /area
	//target_trait = ZTRAIT_VOIDSTORM

	//weather_flags = (WEATHER_INDOORS | WEATHER_BAROMETER)
