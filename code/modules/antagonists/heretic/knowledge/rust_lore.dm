
/datum/heretic_knowledge_tree_column/main/rust

	route = PATH_RUST
	ui_bgr = "node_rust"
	complexity_color = "#d6a531"
	path_description = list(
		"Путь Ржавчины строится вокруг живучести, порчи и грубого прорыва сквозь препятствия.",
		"Берите этот путь, если любите стоять на своём и заставлять бой приходить к вам.",
	)
	path_pros = list(
		"Стоя на ржавых плитах, вы становитесь крайне живучи: раны затягиваются, а оглушения спадают.",
		"Ржавые плиты ранят и замедляют ваших врагов.",
		"Вы с лёгкостью разрушаете стены, объекты, мехи, постройки и шлюзы.",
		"Ваша \"Хватка Обители\" мгновенно уничтожает силиконовых и синтетических членов экипажа.",
		"Множество способностей контроля облегчают бой на вашей территории.",
	)
	path_cons = list(
		"Крайне заметен; о скрытности можно забыть.",
		"Вне ржавых плит вы становитесь значительно уязвимее.",
		"Привязанность к территории облегчает применение против вас разрушительных средств, например, бомб.",
		"Высокая защита достигается ценой атакующей мощи.",
	)
	path_tips = list(
		"\"Хватка Обители\" мгновенно уничтожает мехи, силиконов и андроидов. Удар клинком по помеченной цели вызывает лёгкое отвращение и рвоту, на мгновение сбивая с ног.",
		"Ваша \"Хватка\" и заклинания ржавят стены и полы — это полезно вам и вредно экипажу и силиконам. Распространяйте ржавчину как можно шире.",
		"Ржавые плиты лечат вас, регулируют температуру крови, дают сопротивление оглушению дубинками и восстанавливают выносливость и кровь.",
		"Всегда сражайтесь на своей территории. Враг, ступивший на вашу ржавчину, оказывается в крайне невыгодном положении.",
		"Ваша способность разрушать объекты и стены растёт с уровнем пассивки — со временем вы прожжёте даже шлюзы, укреплённые и титановые стены.",
		"Распространение ржавчины поначалу медленное. Призовите несколько Ржавых Ходоков, чтобы расширять свои владения.",
		"\"Ржавая Постройка\" создаёт барьеры для укрытия, побега или блокировки чужого отхода. Используйте окружение в своих целях.",
	)
	passive_name = "Ржавая Поступь"
	passive_descriptions = list(
		"Стоя на ржавых плитах, вы исцеляетесь и очищаете тело от химикатов.",
		"Стоя на ржавых плитах, вы затягиваете раны и исцеляете органы; теперь вы можете ржаветь укреплённые полы и стены, а лечение усилено.",
		"Стоя на ржавых плитах, вы восстанавливаете утраченные конечности; теперь вы можете ржаветь титановые и пласттитановые стены, а лечение усилено.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_rust
	knowledge_tier1 = /datum/heretic_knowledge/spell/area_conversion
	knowledge_tier2 = /datum/heretic_knowledge/spell/rust_construction
	robes = /datum/heretic_knowledge/armor/rust
	knowledge_tier3 = /datum/heretic_knowledge/spell/entropic_plume
	blade = /datum/heretic_knowledge/blade_upgrade/rust
	knowledge_tier4 = /datum/heretic_knowledge/spell/rust_charge
	ascension = /datum/heretic_knowledge/ultimate/rust_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/rust_sower
	guaranteed_side_tier2 = /datum/heretic_knowledge/limited_amount/summon/rusty
	guaranteed_side_tier3 = /datum/heretic_knowledge/crucible


/datum/heretic_knowledge/limited_amount/starting/base_rust
	name = "Хозяйка Ржавой Горы" // "Хозяйка Медной горы" from "Малахитовая шкатулка".
	desc = "Открывает вам Путь Ржавчины. \
			Позволяет превратить нож и мусор (например, обёртки) в ржавый клинок. \
			Вы можете создать только два клинка одновременно."
	gain_text = "\"Позволь мне рассказать тебе историю\", — сказал Кузнец, пристально вглядываясь в свой ржавый клинок."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "rust_blade"
	mark_type = /datum/status_effect/eldritch/rust
	passive_type = /datum/status_effect/heretic_passive/rust


/datum/heretic_knowledge/limited_amount/starting/base_rust/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp), override = TRUE)
	if(!mind_transfer)
		our_heretic.increase_rust_strength()


/datum/heretic_knowledge/limited_amount/starting/base_rust/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)


/// Primary grasp: apply our rust mark (via parent), violently corrode any robotic limbs the target has,
/// then instantly crumble silicons/synthetics.
/datum/heretic_knowledge/limited_amount/starting/base_rust/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		for(var/obj/item/organ/external/limb as anything in human_target.bodyparts.Copy())
			if(!isroboticorgan(limb))
				continue
			limb.droplimb(disintegrate = DROPLIMB_BLUNT, nodamage = TRUE)

	if(!issilicon(target))
		return

	source.do_rust_heretic_act(target)


/// Secondary grasp: corrode the turf/structure we grab. Airlocks also lose power so they can't shock us.
/datum/heretic_knowledge/limited_amount/starting/base_rust/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(is_airlock(target))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	source.do_rust_heretic_act(target)
	return COMPONENT_USE_HAND


/datum/heretic_knowledge/spell/rust_construction
	name = "Ржавая Постройка"
	desc = "Даёт вам заклинание \"Ржавая Постройка\", позволяющее создать стену на ржавом полу. \
			Все, кто на нём находились, будут отброшены в стороны (или вверх) и получат урон."
	gain_text = "В голове закружились образы чуждых и зловещих сооружений. \
				Покрытые толстым слоем ржавчины, они больше не выглядели рукотворными. \
				Или, возможно, они никогда не были таковыми."
	research_tree_icon_path = 'icons/mob/actions/actions_spells.dmi'
	research_tree_icon_state = "shield"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/rust_construction
	cost = 2


/datum/heretic_knowledge/spell/area_conversion
	name = "Агрессивное Распространение"
	desc = "Даёт вам \"Агрессивное Распространение\", заклинание, распространяющее ржавчину на близлежащие \
			поверхности. Уже поражённые ржавчиной поверхности уничтожаются."
	gain_text = "Все мудрецы прекрасно знали, что не стоило посещать Ржавые Холмы... \
				И все же рассказ Кузнеца был вдохновляющим."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "corrode"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/rust_conversion
	cost = 2
	research_tree_icon_frame = 5


/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength(TRUE)


/datum/heretic_knowledge/blade_upgrade/rust
	name = "Ядовитый Клинок"
	desc = "Ваш Ржавый Клинок теперь вызывает отвращение у врагов при атаке."
	gain_text = "Кузнец вручает вам свой клинок. \"Клинок проложит тебе дорогу. Дорогу сквозь плоть твоих врагов.\" \
				Тяжёлая ржавчина давит на него. Вы всматриваетесь в него. Вы слышите зов Ржавых Холмов."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_rust"


/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.Disgust(50)


/datum/heretic_knowledge/armor/rust
	name = "Воссозданное Одеяние" // Reassembled Raiment
	desc = "Позволяет преобразовать стол (или верхнюю одежду), противогаз и кусок мусора в Воссозданное Одеяние. \
			Оно обеспечивает отличную защиту и действует в качестве фокуса, пока надет капюшон."
	gain_text = "Кузнец облачился в лохмотья, изъеденные ржавчиной. И всё же они держались крепче любой стали."
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust)


/datum/heretic_knowledge/armor/rust/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..() // Parent grants the tier-2 passive upgrade (+ aura).
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	our_heretic?.increase_rust_strength()


/datum/heretic_knowledge/spell/entropic_plume
	drafting_tier = 5
	name = "Шлейф Разложения"
	desc = "Даёт вам \"Шлейф Разложения\", заклинание, создающее волну ржавчины. \
			Ослепляет, отравляет и выводит из себя любого язычника, которого коснётся, заставляя его яростно бить \
			окружающих существ. Также покрывает ржавчиной, разрушает и повреждает поверхности, по которым ударяет, \
			и усиливает способности домена ржавчины у еретиков других путей."
	gain_text = "Коррозию было не остановить. Ржавчина была повсюду. \
				Кузнец исчез, но его клинок остался с вами. Воины надежды, Ржавеющий уже близко!"
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "entropic_plume"
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	cost = 2


/datum/heretic_knowledge/spell/entropic_plume/on_gain(mob/user)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
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

	announcement_text = "%SPOOKY% Бойтесь, ибо Ржавеющий, %NAME%, вознёсся! Вы слышите рокот Ржавых Холмов! Никто и ничто не избежит коррозии! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_rust.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "rustascend"
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A typepath to an area that we must finish the ritual in.
	var/area/ritual_location = /area/station/command/bridge
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
	INVOKE_ASYNC(src, PROC_REF(trigger), loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	var/obj/effect/proc_holder/spell/aoe/rust_spread_spell = locate() in user.mob_spell_list
	rust_spread_spell?.base_cooldown /= 2


/datum/heretic_knowledge/ultimate/rust_final/proc/trigger(turf/center)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	for(var/turf/transform_turf as anything in GLOB.station_turfs)

		var/dist = get_dist(center, transform_turf)
		if(dist > greatest_dist)
			greatest_dist = dist

		if(!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()

		turfs_to_transform["[dist]"] += transform_turf
		CHECK_TICK

	for(var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue

		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (2 SECONDS) * iterator)


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
		turf.rust_heretic_act(RUST_RESISTANCE_ORGANIC, spawn_rune = prob(5))
		CHECK_TICK


/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic ([source]) buffs if they stand on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		if(!immunities_active)
			source.add_traits(conditional_immunities, type)
			source.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
			immunities_active = TRUE
			return

		return

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
	var/base_heal_amt = 1 * DELTA_WORLD_TIME(SSmobs) // the ascension stacks on the rust passive's own on-rust heal
	need_mob_update += source.adjustBruteLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss(-base_heal_amt, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjustOxyLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss(-base_heal_amt * 4, updating_health = FALSE)
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += base_heal_amt

	if(need_mob_update)
		source.updatehealth()


/datum/heretic_knowledge/spell/rust_charge
	name = "Заряд Ржавчины"
	desc = "Дает заклинание, которое необходимо начать стоя на ржавой плитке. Уничтожит все ржавые \
			объекты, которых вы коснётесь, нанесет большой урон нержавым и покроет ржавчиной всё вокруг."
	gain_text = "Холмы теперь сверкали. Чем ближе я был к ним, тем ужасней были мои мысли. \
				Я быстро собрался с духом и двинулся вперёд: последний отрезок пути был самым опасным."
	research_tree_icon_path = 'icons/mob/actions/actions_items.dmi'
	research_tree_icon_state = "sniper_zoom"
	spell_to_add = /obj/effect/proc_holder/spell/mob_cooldown/charge/rust
	cost = 2


/datum/heretic_knowledge/entropy_pulse
	abstract_type = /datum/heretic_knowledge/entropy_pulse
	name = "Импульс Разложения"
	desc = "Позволяет преобразовать 10 железных листов и мусор (например обертку), \
			заполнив прилегающую к руне область ржавчиной."
	gain_text = "Реальность шепчет мне. Она молит, чтобы это всё закончилось. Я помогу ей вернуться в первозданный вид."
	required_atoms = list(
		/obj/item/stack/sheet/metal = 10,
		/obj/item/trash = 1,
	)

	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "corrode"
	research_tree_icon_frame = 10

	var/rusting_range = 8


/datum/heretic_knowledge/entropy_pulse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	for(var/turf/nearby_turf in view(rusting_range, loc))
		if(get_dist(nearby_turf, loc) <= 1) //tiles on rune should always be rusted
			nearby_turf.rust_heretic_act()

		if(prob(10) || iswallturf(nearby_turf))
			continue

		nearby_turf.rust_heretic_act()

	return TRUE
