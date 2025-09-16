
/datum/heretic_knowledge_tree_column/main/rust
	neighbour_type_left = /datum/heretic_knowledge_tree_column/blade_to_rust
	neighbour_type_right = /datum/heretic_knowledge_tree_column/rust_to_cosmic

	route = PATH_RUST
	ui_bgr = "node_rust"

	start = /datum/heretic_knowledge/limited_amount/starting/base_rust
	grasp = /datum/heretic_knowledge/rust_fist
	tier1 = /datum/heretic_knowledge/rust_regen
	mark = /datum/heretic_knowledge/mark/rust_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/rust
	unique_ability = /datum/heretic_knowledge/spell/rust_construction
	tier2 = /datum/heretic_knowledge/spell/area_conversion
	blade = /datum/heretic_knowledge/blade_upgrade/rust
	tier3 =	/datum/heretic_knowledge/spell/entropic_plume
	ascension = /datum/heretic_knowledge/ultimate/rust_final


/datum/heretic_knowledge/limited_amount/starting/base_rust
	name = "Хозяин Ржавой Горы" // "Хозяйка Медной горы" from "Малахитовая шкатулка".
	desc = "Открывает вам Путь Ржавчины. \
			Позволяет превратить нож и мусор (например обертки) в ржавый клинок. \
			Вы можете создать только два клинка одновременно."
	gain_text = "«Позволь мне рассказать тебе историю», — сказал Кузнец, пристально вглядываясь в свой ржавый клинок."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "rust_blade"


/datum/heretic_knowledge/rust_fist
	name = "Прикосновение Ржавчины"
	desc = "Ваше «Прикосновение Мансуса» будет наносить 500 ед. урона неживой материи и вызывать ржавчину на \
			любой поверхности. Уже ржавые поверхности уничтожаются. Ржавчина вызывается альткликом."
	gain_text = "Вокруг Мансуса ржавчина растёт, как мох на камне."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_rust"


/datum/heretic_knowledge/rust_fist/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	our_heretic.increase_rust_strength()


/datum/heretic_knowledge/rust_fist/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY))


/datum/heretic_knowledge/rust_fist/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!issilicon(target)/* && !(target.mob_biotypes & MOB_ROBOTIC)*/)
		return

	source.do_rust_heretic_act(target)


/datum/heretic_knowledge/rust_fist/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// Rusting an airlock causes it to lose power, mostly to prevent the airlock from shocking you.
	// This is a bit of a hack, but fixing this would require the entire wire cut/pulse system to be reworked.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	source.do_rust_heretic_act(target)
	return COMPONENT_USE_HAND


/datum/heretic_knowledge/rust_regen
	name = "Прогулка по Ржавому Мосту"
	desc = "Дает вам пассивное исцеление и сопротивление дубинкам, пока вы стоите на ржавом полу."
	gain_text = "Скорость его была невиданной, сила — нечеловеческой. Кузнец улыбался."
	cost = 1
	research_tree_icon_path = 'icons/effects/eldritch.dmi'
	research_tree_icon_state = "cloud_swirl"


/datum/heretic_knowledge/rust_regen/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	user.AddElement(/datum/element/leeching_walk)


/datum/heretic_knowledge/rust_regen/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	user.RemoveElement(/datum/element/leeching_walk)


/datum/heretic_knowledge/mark/rust_mark
	name = "Метка Ржавчины"
	desc = "Ваше «Прикосновение Мансуса» теперь накладывает Метку Ржавчины. Метка активируется атакой вашим Ржавым Клинком. \
			При срабатывании метки ваша жертва испытает сильное отвращение и замешательство."
	gain_text = "Кузнец смотрит вдаль. На место, что давно забыто. «Ржавые Холмы помогают нуждающимся... за определённую цену»."
	mark_type = /datum/status_effect/eldritch/rust


/datum/heretic_knowledge/mark/rust_mark/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength()


/datum/heretic_knowledge/knowledge_ritual/rust


/datum/heretic_knowledge/spell/rust_construction
	name = "Ржавая Постройка"
	desc = "Даёт вам «Ржавая Постройка» — заклинание, позволяющее создать стену на ржавом полу. \
			Все кто на нём находились, будут отброшен в стороны (или вверх) и получат урон."
	gain_text = "В голове закружились образы чуждых и зловещих сооружений. \
				Покрытые толстым слоем ржавчины, они больше не выглядели рукотворными. \
				Или, возможно, они никогда небыли таковыми."
	research_tree_icon_path = 'icons/mob/actions/actions.dmi'
	research_tree_icon_state = "shield"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/rust_construction
	cost = 1


/datum/heretic_knowledge/spell/area_conversion
	name = "Агрессивное Распространение"
	desc = "Даёт вам «Агрессивное Распространение» — заклинание, распространяющее ржавчину на близлежащие \
			поверхности. Уже поражённые ржавчиной поверхности уничтожаются."
	gain_text = "Все мудрецы прекрасно знали, что не стоило посещать Ржавые Холмы... \
				И все же рассказ Кузнеца был вдохновляющим."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "corrode"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/rust_conversion
	cost = 1
	research_tree_icon_frame = 5


/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength(TRUE)


/datum/heretic_knowledge/blade_upgrade/rust
	name = "Ядовитый Клинок"
	desc = "Ваш Ржавый Клинок теперь вызывает отвращение у врагов при атаке."
	gain_text = "Кузнец вручает вам свой клинок. «Клинок проложит тебе дорогу. Дорогу сквозь плоть твоих врагов.». \
				Тяжёлая ржавчина давит на него. Вы всматриваетесь в него. Вы слышите зов Ржавых Холмов."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_rust"


/datum/heretic_knowledge/blade_upgrade/rust/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength()


/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.Disgust(50)


/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()


/datum/heretic_knowledge/spell/entropic_plume
	name = "Шлейф Разложения"
	desc = "Даёт вам Шлейф Разложения, заклинание, создающее волну Ржавчины. \
			Ослепляет, отравляет и выводит из себя любого язычника, которого коснётся, заставляя его яростно бить \
			окружающих существ. Также покрывает ржавчиной, разрушает и повреждает поверхности, по которым ударяет, \
			и усиливает способности домена ржавчины у еретиков других путей."
	gain_text = "Коррозию было не остановить. Ржавчина была повсюду. \
				Кузнец исчез, но его клинок остался с вами. Воины надежды, Ржавеющий уже близко!"
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "entropic_plume"
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	cost = 1


/datum/heretic_knowledge/spell/entropic_plume/on_gain(mob/user)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
	our_heretic.increase_rust_strength(TRUE)


/datum/heretic_knowledge/ultimate/rust_final
	name = "Клятва Ржавчины"
	desc = "Ритуал вознесения Пути Ржавчины. \
			Принесите 3 трупа к руне трансмутации на мостике, чтобы завершить ритуал. \
			После завершения ритуала ржавчина начнет распространяться от места его проведения. \
			Кроме того, вы станете чрезвычайно живучи пока находитесь на ржавчине, \
			будете восстанавливаться в три раза быстрее и приобретете иммунитет ко многим негативным эффектам. \
			После вознесения вы сможете поражать ржавчиной практически всё."
	gain_text = "Поборник ржавчины. Осквернитель стали. Бойтесь тьмы, ибо пришёл Ржавеющий! \
				Кузнец идёт вперёд! Ржавые Холмы, НАЗОВИТЕ МОЁ ИМЯ! СТАНЬТЕ СВИДЕТЕЛЯМИ МОЕГО ВОЗНЕСЕНИЯ!"

	//ascension_achievement = /datum/award/achievement/misc/rust_ascension
	announcement_text = "%SPOOKY% Бойтесь, ибо Ржавеющий, %NAME%, вознёсся! Никто и ничто не избежит коррозии! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_rust.ogg'
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A typepath to an area that we must finish the ritual in.
	var/area/ritual_location = /area/bridge
	/// A static list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NO_BREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESIST_COLD,
		TRAIT_RESIST_HEAT,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
	)


/datum/heretic_knowledge/ultimate/rust_final/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	// This map doesn't have a Bridge, for some reason??
	// Let them complete the ritual anywhere
	if(!GLOB.areas_by_type[ritual_location])
		ritual_location = null


/datum/heretic_knowledge/ultimate/rust_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!ritual_location)
		return ..()

	var/area/our_area = get_area(loc)
	if(istype(our_area, ritual_location))
		return ..()

	loc.balloon_alert(user, "вы не в [initial(ritual_location.name)]!") // "must be in bridge"
	return FALSE


/datum/heretic_knowledge/ultimate/rust_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	trigger(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	//user.client?.give_award(/datum/award/achievement/misc/rust_ascension, user)
	var/obj/effect/proc_holder/spell/aoe/rust_spread_spell = locate() in user.mob_spell_list
	rust_spread_spell?.base_cooldown /= 2


// I sure hope this doesn't have performance implications
/datum/heretic_knowledge/ultimate/rust_final/proc/trigger(turf/center)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	var/list/stations_z = levels_by_trait(STATION_LEVEL)
	var/list/station_turfs = block(1, 1, stations_z[1], world.maxx, world.maxy, stations_z[length(stations_z)])
	for(var/turf/transform_turf as anything in station_turfs)
		//if(transform_turf.turf_flags & NO_RUST)
		//	continue

		var/dist = get_dist(center, transform_turf)
		if(dist > greatest_dist)
			greatest_dist = dist

		if(!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()

		turfs_to_transform["[dist]"] += transform_turf

	for(var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue

		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (5 SECONDS) * iterator)


/datum/heretic_knowledge/ultimate/rust_final/proc/transform_area(list/turfs)
	turfs = shuffle(turfs)
	var/numturfs = length(turfs)
	var/first_third = turfs.Copy(1, round(numturfs * 0.33))
	var/second_third = turfs.Copy(round(numturfs * 0.33), round(numturfs * 0.66))
	var/third_third = turfs.Copy(round(numturfs * 0.66), numturfs)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), first_third), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), second_third), 5 SECONDS * 0.33)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), third_third), 5 SECONDS * 0.66)


/datum/heretic_knowledge/ultimate/rust_final/proc/delay_transform_turfs(list/turfs)
	for(var/turf/turf as anything in turfs)
		turf.rust_heretic_act(5)
		CHECK_TICK


/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic ([source]) buffs if they stand on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	// If we're on a rusty turf, and haven't given out our traits, buff our guy
	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		if(!immunities_active)
			source.add_traits(conditional_immunities, type)
			source.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
			immunities_active = TRUE
			return

		return

	// If we're not on a rust turf, and we have given out our traits, nerf our guy
	if(!immunities_active)
		return

	source.remove_traits(conditional_immunities, type)
	source.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	immunities_active = FALSE


/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	var/need_mob_update = FALSE
	var/base_heal_amt = 2.5 * DELTA_WORLD_TIME(SSmobs)
	need_mob_update += source.adjustBruteLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss(-base_heal_amt, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjustOxyLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss(-base_heal_amt * 4, updating_health = FALSE)
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += base_heal_amt

	if(need_mob_update)
		source.updatehealth()
