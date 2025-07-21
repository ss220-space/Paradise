
/datum/heretic_knowledge_tree_column/main/void
	neighbour_type_left = /datum/heretic_knowledge_tree_column/flesh_to_void
	neighbour_type_right = /datum/heretic_knowledge_tree_column/void_to_blade

	route = PATH_VOID
	ui_bgr = "node_void"

	start = /datum/heretic_knowledge/limited_amount/starting/base_void
	grasp = /datum/heretic_knowledge/void_grasp
	tier1 = /datum/heretic_knowledge/cold_snap
	mark = 	/datum/heretic_knowledge/mark/void_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/void
	unique_ability = /datum/heretic_knowledge/spell/void_conduit
	tier2 = /datum/heretic_knowledge/spell/void_phase
	blade = /datum/heretic_knowledge/blade_upgrade/void
	tier3 =	/datum/heretic_knowledge/spell/void_pull
	ascension = /datum/heretic_knowledge/ultimate/void_final


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


/datum/heretic_knowledge/limited_amount/starting/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!is_space_or_openspace(loc))
		loc.balloon_alert(user, "не подходящее место!")
		return FALSE

	loc.balloon_alert(user, "слишком тепло!")
	return FALSE


/datum/heretic_knowledge/void_grasp
	name = "Понимание пустоты"
	desc = "Ваше Прикосновение Мансуса временно заглушит и охладит жертву."
	gain_text = "Я увидел Его. Он наблюдает за мной. В Его глазах холод. Холод пробирающий до костей. \
				Они молчат. Это ещё не конец тайны."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_void"


/datum/heretic_knowledge/void_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))


/datum/heretic_knowledge/void_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)


/datum/heretic_knowledge/void_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.Silence(10 SECONDS)
	carbon_target.apply_status_effect(/datum/status_effect/void_chill, 2)


/datum/heretic_knowledge/cold_snap
	name = "Путь аристократа"
	desc = "Даёт вам иммунитет к холоду и избавляет от необходимости дышать."
	gain_text = "Я почувствовал чье-то холодное дыхание. Оно привело меня к странному святилищу, целиком сделанному из кристаллов. \
				В нём я нашел полупрозрачное и белое изображение знатного человека."
	cost = 1
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "the_freezer"

	/// Traits we apply to become immune to the environment
	var/static/list/gain_traits = list(TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE)


/datum/heretic_knowledge/cold_snap/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	user.add_traits(list(TRAIT_NO_BREATH, TRAIT_RESIST_COLD), type)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(check_environment))


/datum/heretic_knowledge/cold_snap/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	user.remove_traits(list(TRAIT_RESIST_COLD, TRAIT_NO_BREATH), type)
	UnregisterSignal(user, COMSIG_LIVING_LIFE)


///Checks if our traits should be active
/datum/heretic_knowledge/cold_snap/proc/check_environment(mob/living/user)
	SIGNAL_HANDLER

	var/datum/gas_mixture/environment = user.loc?.return_air()
	if(isnull(environment))
		return

	var/affected_temperature = environment.return_temperature()
	var/affected_pressure = environment.return_pressure()
	if(affected_temperature <= T0C || affected_pressure < ONE_ATMOSPHERE)
		user.add_traits(gain_traits, type)
		return

	user.remove_traits(gain_traits, type)


/datum/heretic_knowledge/mark/void_mark
	name = "Метка Пустоты"
	desc = "Ваше «Прикосновение Мансуса» теперь накладывает Метку Пустоты. Метка активируется атакой вашим Клинком Пустоты. \
			При срабатывании на длительный срок заглушает жертву и быстро понижает температуру её тела и воздуха вокруг неё."
	gain_text = "Порыв ветра? Мерцание в воздухе? ЗДЕСЬ КТО-ТО ЕСТЬ! ОНО ОБМАНЫВАЕТ МОИ ЧУВСТВА! \
				МОЙ РАЗУМ МНЕ ЛЖЕТ!"
	mark_type = /datum/status_effect/eldritch/void


/datum/heretic_knowledge/knowledge_ritual/void


/datum/heretic_knowledge/spell/void_conduit
	name = "Канал Пустоты"
	desc = "Даёт вам «Канал Пустоты» — заклинание, создающее пульсирующие врата в саму Пустоту. Каждый импульс разбивает окна и шлюзы, нанося вашим врагам жуткий холод и защищая еретиков от низкого давления."
	gain_text = "Гул в неподвижном, холодном воздухе превращается в какофонию. \
				Сквозь этот шум не различить стук оконных стёкол и хаотичный бред проносящийся в моей голове. \
				Врата не закрыть. Теперь я не могу уберечься от холода."
	spell_to_add = /obj/effect/proc_holder/spell/aoe/conjure/void_conduit
	cost = 1


/datum/heretic_knowledge/spell/void_phase
	name = "Пустотный Сдвиг"
	desc = "Дарует вам «Пустотный Сдвиг» — заклинание телепортации на большие расстояния. \
			Кроме того, наносит урон врагам вокруг вашей исходной и целевой точки назначения."
	gain_text = "Я был в пустоте. Я видел сущность называющую себя Аристократом. \
				Она летела оставляя после себя резкий, холодный ветер. Я следовал за ней, но \
				она исчезла, оставив меня посреди метели."
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_phase
	cost = 1
	research_tree_icon_frame = 7


/datum/heretic_knowledge/blade_upgrade/void
	name = "Ищущий Клинок"
	desc = "Ваш клинок теперь замораживает врагов. Кроме того, теперь вы можете \
			атаковать далекие отмеченные цели своим Клинцем Пустоты, телепортируясь прямо к ним."
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


/datum/heretic_knowledge/spell/void_pull
	name = "Притяжение Пустоты"
	desc = "Дает вам Притяжение Пустоты — заклинание, притягивающее к вам всех находящихся поблизости язычников, ненадолго оглушая их."
	gain_text = "Всё мимолётно, но что же ещё остаётся? Я близок к завершению начатого. \
				Аристократы снова открываются мне. Они говорят, что я опоздал. \
				Их притяжение огромно, я не могу повернуть назад."
	spell_to_add = /obj/effect/proc_holder/spell/aoe/void_pull
	cost = 1

	research_tree_icon_frame = 6


/datum/heretic_knowledge/ultimate/void_final
	name = "Вальс Конца Времен"
	desc = "Ритуал вознесения Пути Пустоты. \
			Принесите 3 трупа к руне трансмутации при температуре ниже нуля, чтобы завершить ритуал. \
			После завершения вызывает мощную снежную бурю, замораживающую и нанося урон дикарям. \
			Те, кто находится рядом, будут заморожены и обездвижены ещё быстрее."
	gain_text = "Мир погружается во тьму. Я стою посреди пустоты, с неба падают снежинки.\
				Аристократ стоит передо мной. Аристократ манит меня. Мы сыграем вальс под шёпот умирающей реальности,\
				пока мир разрушается на наших глазах. Всё обратится в ничто, СТАНЬ СВИДЕТЕЛЕМ МОЕГО ВОЗНЕСЕНИЯ!"

	//ascension_achievement = /datum/award/achievement/misc/void_ascension
	announcement_text = "%SPOOKY% Дворянин пустоты %NAME% прибыл, шагая в Вальсе, который положит конец всему! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_void.ogg'
	///soundloop for the void theme
	//var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm
	///The storm where there are actual effects
	var/datum/component/proximity_monitor/advanced/void_storm/heavy_storm


/datum/heretic_knowledge/ultimate/void_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!is_space_or_openspace(loc))
		loc.balloon_alert(user, "не подходящее место!")
		return FALSE

	return ..()


/datum/heretic_knowledge/ultimate/void_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.add_traits(list(TRAIT_RESIST_COLD, TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING/*, TRAIT_FREE_HYPERSPACE_MOVEMENT*/), type)

	// Let's get this show on the road!
	//sound_loop = new(user, TRUE, TRUE)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(user, COMSIG_ATOM_BULLET_ACT, PROC_REF(hit_by_projectile))
	RegisterSignal(user, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_death))
	heavy_storm = new(user, 10)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/ascended_human = user
	//var/obj/item/organ/internal/eyes/heretic_eyes = ascended_human.get_organ_slot(INTERNAL_ORGAN_EYES)
	//heretic_eyes?.color_cutoffs = list(30, 30, 30)
	ascended_human.update_sight()


/datum/heretic_knowledge/ultimate/void_final/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	on_death() // Losing is pretty much dying. I think

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
			if(IS_HERETIC_OR_MONSTER(close_carbon))
				close_carbon.apply_status_effect(/datum/status_effect/void_conduit)
				continue

			close_carbon.Silence(2 SECONDS, 20 SECONDS)
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
		var/datum/gas_mixture/environment = affected_turf.return_air()
		environment.temperature *= 0.9



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

	//if(sound_loop)
	//	sound_loop.stop()

	if(storm)
		storm.end()
		QDEL_NULL(storm)

	if(heavy_storm)
		QDEL_NULL(heavy_storm)

	UnregisterSignal(source, list(COMSIG_LIVING_LIFE, COMSIG_ATOM_BULLET_ACT, COMSIG_LIVING_DEATH, COMSIG_QDELETING))


///Few checks to determine if we can deflect bullets
/datum/heretic_knowledge/ultimate/void_final/proc/can_deflect(mob/living/ascended_heretic)
	if(!(ascended_heretic.mobility_flags & MOBILITY_USE))
		return FALSE

	if(!isturf(ascended_heretic.loc))
		return FALSE

	return TRUE


/datum/heretic_knowledge/ultimate/void_final/proc/hit_by_projectile(mob/living/ascended_heretic, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(!can_deflect(ascended_heretic))
		return NONE

	ascended_heretic.visible_message(
		span_danger("Пустотный шторм отражает [hitting_projectile.declent_ru(ACCUSATIVE)]!"),
		span_userdanger("Пустотный шторм защищает вас от [hitting_projectile.declent_ru(GENITIVE)]!"),
	)
	//playsound(ascended_heretic, SFX_VOID_DEFLECT, 75, TRUE)
	hitting_projectile.firer = ascended_heretic
	if(prob(75))
		hitting_projectile.set_angle(get_angle(hitting_projectile.firer, hitting_projectile.firer))
		return

	hitting_projectile.set_angle(rand(0, 360))//SHING



/datum/weather/void_storm
	name = "пустотный шторм"
	desc = "Редкое и крайне ненормальное событие, часто сопровождаемое неизвестными сущностями, разрывающими пространственно-временной континуум. Вам лучше начать бежать."

	telegraph_duration = 2 SECONDS
	telegraph_overlay = "light_snow"

	weather_message = span_hypnophrase("Вы чувствуете, как воздух вокруг становится холоднее... Вы чувствуете сладкие объятия пустоты...")
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
