
/datum/heretic_knowledge_tree_column/main/rust
	neighbour_type_left = /datum/heretic_knowledge_tree_column/blade_to_rust
	neighbour_type_right = /datum/heretic_knowledge_tree_column/rust_to_cosmic

	route = PATH_RUST
	ui_bgr = "node_rust"
	complexity = "Средняя"
	complexity_color = "#d6a531"
	path_description = list(
		"Путь Ржавчины строится вокруг живучести, порчи и грубого прорыва сквозь препятствия.",
		"Берите этот путь, если любите стоять на своём и заставлять бой приходить к вам.",
	)
	path_pros = list(
		"Стоя на ржавых плитах, вы становитесь крайне живучи: раны затягиваются, а оглушения спадают.",
		"Ржавые плиты ранят и замедляют ваших врагов.",
		"Вы с лёгкостью разрушаете стены, объекты, мехов, постройки и шлюзы.",
		"Ваше «Прикосновение Мансуса» мгновенно уничтожает силиконовых и синтетических членов экипажа.",
		"Множество способностей контроля облегчают бой на вашей территории.",
	)
	path_cons = list(
		"Крайне заметен; о скрытности можно забыть.",
		"Вне ржавых плит вы становитесь значительно уязвимее.",
		"Привязанность к территории облегчает применение против вас разрушительных средств, например, бомб.",
		"Высокая защита достигается ценой атакующей мощи.",
	)
	path_tips = list(
		"«Прикосновение Мансуса» мгновенно уничтожает мехов, силиконов и андроидов. Удар клинком по помеченной цели вызывает лёгкое отвращение и рвоту, на мгновение сбивая с ног.",
		"Ваше «Прикосновение» и заклинания ржавят стены и полы - это полезно вам и вредно экипажу и силиконам. Распространяйте ржавчину как можно шире.",
		"Ржавые плиты лечат вас, регулируют температуру крови, дают сопротивление оглушению дубинками и восстанавливают выносливость и кровь.",
		"Всегда сражайтесь на своей территории. Враг, ступивший на вашу ржавчину, оказывается в крайне невыгодном положении.",
		"Ваша способность разрушать объекты и стены растёт с уровнем пассивки - со временем вы прожжёте даже шлюзы, укреплённые и титановые стены.",
		"Распространение ржавчины поначалу медленное. Призовите несколько Ржавых Ходоков, чтобы расширять свои владения.",
		"«Ржавая Постройка» создаёт барьеры для укрытия, побега или блокировки чужого отхода. Используйте окружение в своих целях.",
	)
	// "Leeching Walk" passive (on-rust durability that scales). Tiers light up as you grow.
	passive_name = "Ржавая Поступь"
	passive_descriptions = list(
		"Стоя на ржавых плитах, вы исцеляетесь и очищаете тело от химикатов.",
		"Стоя на ржавых плитах, вы затягиваете раны и исцеляете органы; теперь вы можете ржаветь укреплённые полы и стены, а лечение усилено.",
		"Стоя на ржавых плитах, вы восстанавливаете утраченные конечности; теперь вы можете ржаветь титановые и пласттитановые стены, а лечение усилено.",
	)

	// Main line: base_rust -> Aggressive Spread -> Rust Construction -> Reassembled Raiment(robes) ->
	// Entropic Plume -> Toxic Blade -> Rust Charge -> ascension.
	// The grasp (silicon-destroy + secondary turf rust), the rust mark and the on-rust passive are all
	// folded into base_rust, no separate grasp/mark/regen nodes.
	start = /datum/heretic_knowledge/limited_amount/starting/base_rust
	knowledge_tier1 = /datum/heretic_knowledge/spell/area_conversion
	knowledge_tier2 = /datum/heretic_knowledge/spell/rust_construction
	robes = /datum/heretic_knowledge/armor/rust
	knowledge_tier3 = /datum/heretic_knowledge/spell/entropic_plume
	blade = /datum/heretic_knowledge/blade_upgrade/rust
	knowledge_tier4 = /datum/heretic_knowledge/spell/rust_charge
	ascension = /datum/heretic_knowledge/ultimate/rust_final
	// Side knowledges guaranteed to be offered in this path's drafts (TG).
	guaranteed_side_tier1 = /datum/heretic_knowledge/rust_sower
	guaranteed_side_tier2 = /datum/heretic_knowledge/limited_amount/summon/rusty
	guaranteed_side_tier3 = /datum/heretic_knowledge/crucible


/datum/heretic_knowledge/limited_amount/starting/base_rust
	name = "Хозяин Ржавой Горы" // "Хозяйка Медной горы" from "Малахитовая шкатулка".
	desc = "Открывает вам Путь Ржавчины. \
			Позволяет превратить нож и мусор (например обертки) в ржавый клинок. \
			Вы можете создать только два клинка одновременно."
	gain_text = "«Позволь мне рассказать тебе историю», - сказал Кузнец, пристально вглядываясь в свой ржавый клинок."
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
	// Secondary grasp (RMB on a turf/structure/airlock) corrodes it - the base starting knowledge only
	// wires the primary grasp, so register the secondary here.
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

	// Augmented / IPC crew: the grasp wrecks any robotic limbs they carry.
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		for(var/obj/item/organ/external/limb as anything in human_target.bodyparts)
			if(!isroboticorgan(limb))
				continue
			limb.external_receive_damage(500, 0)

	// Silicons (borgs / AI shells) crumble to rust outright. master220 has no mob_biotypes, so
	// issilicon covers the synthetic mobs we can detect.
	if(!issilicon(target))
		return

	source.do_rust_heretic_act(target)


/// Secondary grasp: corrode the turf/structure we grab. Airlocks also lose power so they can't shock us.
/datum/heretic_knowledge/limited_amount/starting/base_rust/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// Rusting an airlock causes it to lose power, mostly to prevent the airlock from shocking you.
	// This is a bit of a hack, but fixing this would require the entire wire cut/pulse system to be reworked.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	source.do_rust_heretic_act(target)
	return COMPONENT_USE_HAND


/datum/heretic_knowledge/spell/rust_construction
	name = "Ржавая Постройка"
	desc = "Даёт вам «Ржавая Постройка», заклинание, позволяющее создать стену на ржавом полу. \
			Все кто на нём находились, будут отброшен в стороны (или вверх) и получат урон."
	gain_text = "В голове закружились образы чуждых и зловещих сооружений. \
				Покрытые толстым слоем ржавчины, они больше не выглядели рукотворными. \
				Или, возможно, они никогда небыли таковыми."
	// Match the ability button: actions_spells.dmi "shield", not actions.dmi "shield" (a blue badge).
	research_tree_icon_path = 'icons/mob/actions/actions_spells.dmi'
	research_tree_icon_state = "shield"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/rust_construction
	cost = 2


/datum/heretic_knowledge/spell/area_conversion
	name = "Агрессивное Распространение"
	desc = "Даёт вам «Агрессивное Распространение», заклинание, распространяющее ржавчину на близлежащие \
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
	gain_text = "Кузнец вручает вам свой клинок. «Клинок проложит тебе дорогу. Дорогу сквозь плоть твоих врагов.». \
				Тяжёлая ржавчина давит на него. Вы всматриваетесь в него. Вы слышите зов Ржавых Холмов."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_rust"


// Rust-strength now climbs to 2 when you CRAFT the robe (see /datum/heretic_knowledge/armor/rust below),
// in lockstep with the passive's tier-2 upgrade - so "rust reinforced walls" unlocks exactly when the
// passive says it does. The blade upgrade no longer touches rust strength.

/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.Disgust(50)


/datum/heretic_knowledge/armor/rust
	name = "Собранный Раймент" // Reassembled Raiment
	desc = "Позволяет преобразовать стол (или верхнюю одежду), противогаз и кусок мусора в Собранный Раймент. \
			Он обеспечивает отличную защиту и действует как амулет, пока надет капюшон."
	gain_text = "Кузнец облачился в лохмотья, изъеденные ржавчиной. И всё же они держались крепче любой стали."
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust)
	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 12


/datum/heretic_knowledge/armor/rust/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..() // Parent grants the tier-2 passive upgrade (+ aura).
	// Keep rust strength in lockstep with the passive tier: reaching tier 2 lets us rust reinforced turfs.
	var/datum/antagonist/heretic/our_heretic = user.mind?.has_antag_datum(/datum/antagonist/heretic)
	our_heretic?.increase_rust_strength()


/datum/heretic_knowledge/spell/entropic_plume
	drafting_tier = 5
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
	cost = 2


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
	research_tree_icon_path = 'icons/ui/achievements/achievements.dmi'
	research_tree_icon_state = "rustascend"
	announcement_text = "%SPOOKY% Бойтесь, ибо Ржавеющий, %NAME%, вознёсся! Никто и ничто не избежит коррозии! %SPOOKY%"
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
		// ORGANIC (4): the ascension corrodes everything short of ABSOLUTE-resistance turfs
		// (space, indestructible), so the station rusts over but the void/hull stays intact.
		turf.rust_heretic_act(RUST_RESISTANCE_ORGANIC)
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
