
/datum/heretic_knowledge_tree_column/main/cosmic

	route = PATH_COSMIC
	ui_bgr = "node_cosmos"
	complexity = "Сложный"
	complexity_color = "#c93b3b"
	path_description = list(
		"Путь Космоса строится вокруг контроля территории, телепортации и власти над пространством.",
		"Берите этот путь, если любите подстраиваться под обстановку и мыслить вне (или внутри) коробки.",
	)
	path_pros = list(
		"Управляйте перемещением врагов с помощью космических полей.",
		"Свободно передвигайтесь в открытом космосе.",
		"Молниеносно телепортируйтесь по всей станции.",
		"Сбивайте противников с толку барьерами поверх барьеров.",
	)
	path_cons = list(
		"Чтобы космические поля действовали на врагов, нужно сперва наложить на них звёздную метку.",
		"Относительно низкий урон.",
		"Слабая прямая защита; путь сильно зависит от грамотного применения способностей.",
	)
	path_tips = list(
		"Ваша \"Хватка Обители\" накладывает на противника звёздную метку и оставляет метку, которая при \
		срабатывании телепортирует жертву обратно в точку, где метка была наложена, и ненадолго парализует её.",
		"Космические руны мгновенно перебрасывают вас между двумя точками. Но осторожно: язычники тоже могут \
		проходить сквозь них. Проявите смекалку и заманите противника прямо в ловушку — выйдет он уже со звёздной меткой!",
		"Стоя на космической руне, вы можете активировать её, щёлкнув по себе пустой рукой.",
		"Звёздомеченые враги не могут по своей воле пересекать ваши космические поля. Но их можно протащить силой!",
		"\"Звёздный Взрыв\" - это одновременно прыжок-скачок и средство обездвиживания. Ловите им сразу нескольких \
		человек в свои космические поля.",
		"\"Звёздное Касание\" не даст цели телепортироваться прочь. Если она не разорвёт привязь, её усыпит и притянет \
		к вашим ногам.",
		"Всегда полезно оставить одну космическую руну рядом с ритуальной руной — так вы сможете быстро похищать \
		цели для жертвоприношения.",
	)
	passive_name = "Избранник Звёзд"
	passive_descriptions = list(
		"Космические поля ускоряют вас и восстанавливают выносливость.",
		"Создаваемые вами космические поля выводят из строя гранаты и бомбы поблизости.",
		"Создаваемые вами космические поля замедляют пролетающие сквозь них снаряды.",
	)
	start = /datum/heretic_knowledge/limited_amount/starting/base_cosmic
	knowledge_tier1 = /datum/heretic_knowledge/spell/cosmic_runes
	knowledge_tier2 = /datum/heretic_knowledge/spell/star_blast
	robes = /datum/heretic_knowledge/armor/cosmic
	knowledge_tier3 = /datum/heretic_knowledge/spell/star_touch
	blade = /datum/heretic_knowledge/blade_upgrade/cosmic
	knowledge_tier4 = /datum/heretic_knowledge/spell/cosmic_expansion
	ascension = /datum/heretic_knowledge/ultimate/cosmic_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/eldritch_coin
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/space_phase
	guaranteed_side_tier3 = /datum/heretic_knowledge/essence


/datum/heretic_knowledge/limited_amount/starting/base_cosmic
	name = "Звёздный Путь" // Star Trek
	desc = "Открывает вам Путь Космоса. \
			Позволяет преобразовать лист плазмы и нож в Клинок Космоса. \
			Вы можете создать только два клинка одновременно."
	gain_text = "В небе появилась туманность, вспышка света озарила меня. \
				Это было начало великого возвышения."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/cosmic)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "cosmic_blade"
	mark_type = /datum/status_effect/eldritch/cosmic
	passive_type = /datum/status_effect/heretic_passive/cosmic


/// Mansus Grasp star-marks the victim and drops a cosmic field where you stand (was the "Прикосновение космоса"
/// node). The path's teleport-back mark (/datum/status_effect/eldritch/cosmic) is applied by the parent via mark_type.
/datum/heretic_knowledge/limited_amount/starting/base_cosmic/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()
	to_chat(target, span_danger("Над вашей головой появилось космическое кольцо!"))
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	create_cosmic_field(get_turf(source), source)


/datum/heretic_knowledge/spell/cosmic_runes
	drafting_tier = 5
	name = "Звёздные Руны"
	desc = "Даёт вам \"Звёздные Руны\", заклинание, создающее две руны телепортирующие друг на друга. \
			Только активировавшая руну сущность будет перемещена. Её может использовать любой человек без звёздной метки. \
			Однако люди со звёздной меткой будут перемещены вместе с другим человеком, использующим руну."
	gain_text = "Далёкие звёзды проникли в мои сны, ревя и крича без причины. Я заговорил и \
				услышал эхо собственных слов."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "cosmic_rune"
	spell_to_add = /obj/effect/proc_holder/spell/cosmic_rune
	cost = 2


/datum/heretic_knowledge/spell/star_touch
	name = "Звёздное Касание"
	desc = "Даёт вам \"Звёздное Касание\", заклинание, которое накладывает на вашу цель звёздную метку, \
			создаёт космическое поле у ваших ног и на плитках рядом с вами. Цели, уже имеющие звёздную метку \
			будут усыплены на 4 секунды. При попадании в жертву также создаётся луч, направленный на неё. \
			Луч существует минуту, пока не будет преграждён или пока не будет найдена новая цель."
	gain_text = "Я проснулся в холодном поту из-за того, что почувствовал на голове чью-то ладонь. \
				Мои вены начали излучать странное фиолетовое свечение. Зверь знает, что я превзойду его ожидания."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "star_touch"
	spell_to_add = /obj/effect/proc_holder/spell/touch/star_touch
	cost = 2


/datum/heretic_knowledge/spell/star_blast
	name = "Звёздный Взрыв"
	desc = "Выпускает очень медленный снаряд, поднимающий на своём пути недолговечную стену космических полей. \
			Все, в кого попадает снаряд, будут сбиты с ног, а все в радиусе трёх плиток получат звёздную метку."
	gain_text = "Зверь всегда был позади меня, и с каждой принесенной жертвой я чувствовал его одобрение."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "star_blast"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/projectile/star_blast
	cost = 2


/datum/heretic_knowledge/armor/cosmic
	name = "Звёздотканый Плащ"
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску и лист плазмы в Звёздотканый Плащ. \
			Он защищает владельца от опасностей космоса и позволяет ему левитировать по желанию. \
			Действует в качестве источника фокуса, пока надет капюшон."
	gain_text = "Подобно лучистым нитям, звёзды слились воедино в шелковистой форме струящегося плаща, что \
				одновременно укрывает и не укрывает мои плечи. Взор Зверя остановился на мне — и прошёл сквозь меня."
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic)
	research_tree_icon_state = "cosmic_armor"
	research_tree_icon_frame = 1


/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Клинок Космоса"
	desc = "Ваш клинок теперь накладывает на жертв звёздную метку и позволяет атаковать отмеченных звёздами \
			язычников на расстоянии. Ваши атаки будут накапливать дополнительный урон по одной и той же цели, вплоть до двух предыдущих \
			жертв. Комбо сбрасывается после двух секунд без атаки или если вы атакуете уже отмеченную цель. \
			Сделав три удара комбо, вы получите космический след и увеличите таймер комбо до десяти секунд."
	gain_text = "Зверь взглянул на мои клинки. Я упал на колени, почувствовав острую боль. \
				Клинки сверкали силой. Я упал на землю и заплакал у ног Зверя."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_cosmos"
	/// Storage for the second target.
	var/datum/weakref/second_target
	/// Storage for the third target.
	var/datum/weakref/third_target
	/// When this timer completes we reset our combo.
	var/combo_timer
	/// The active duration of the combo.
	var/combo_duration = 3 SECONDS
	/// The duration of a combo when it starts.
	var/combo_duration_amount = 3 SECONDS
	/// The maximum duration of the combo.
	var/max_combo_duration = 10 SECONDS
	/// The amount the combo duration increases.
	var/increase_amount = 0.5 SECONDS
	/// The hits we have on a mob with a mind.
	var/combo_counter = 0
	/// How much further we can hit star-marked people, modified by ascension.
	var/max_attack_range = 2


/datum/heretic_knowledge/blade_upgrade/cosmic/do_ranged_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!isliving(target) || get_dist(source, target) > max_attack_range || !target.has_status_effect(/datum/status_effect/star_mark))
		return
	source.changeNext_move(blade.attack_speed)
	blade.attack(target, source)


/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.apply_status_effect(/datum/status_effect/star_mark, source)

	if(combo_timer)
		deltimer(combo_timer)

	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = second_target?.resolve()
	var/mob/living/third_target_resolved = third_target?.resolve()
	var/need_mob_update = FALSE
	need_mob_update += target.adjustFireLoss(5, updating_health = FALSE)
	if(need_mob_update)
		target.updatehealth()

	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return

	if(target.mind && target.stat != DEAD)
		combo_counter += 1

	if(second_target_resolved)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
		playsound(get_turf(second_target_resolved), 'sound/magic/cosmic_energy.ogg', 25, FALSE)
		need_mob_update = FALSE
		need_mob_update += second_target_resolved.adjustFireLoss(14, updating_health = FALSE)
		if(need_mob_update)
			second_target_resolved.updatehealth()

		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
			need_mob_update = FALSE
			need_mob_update += third_target_resolved.adjustFireLoss(28, updating_health = FALSE)
			if(need_mob_update)
				third_target_resolved.updatehealth()

			if(combo_counter == 3)
				if(target.mind && target.stat != DEAD)
					increase_combo_duration()
					source.AddElement(cosmic_trail_based_on_passive(source), /obj/effect/forcefield/cosmic_field/fast)

		third_target = second_target

	second_target = WEAKREF(target)


/// Resets the combo.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/reset_combo(mob/living/source)
	second_target = null
	third_target = null
	source.RemoveElement(cosmic_trail_based_on_passive(source), /obj/effect/forcefield/cosmic_field/fast)

	combo_duration = combo_duration_amount
	combo_counter = 0
	new /obj/effect/temp_visual/cosmic_cloud(get_turf(source))
	if(!combo_timer)
		return

	deltimer(combo_timer)


/// Increases the combo duration.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/increase_combo_duration()
	if(combo_duration >= max_combo_duration)
		return

	combo_duration += increase_amount


/datum/heretic_knowledge/spell/cosmic_expansion
	name = "Расширение Территории"
	desc = "Даёт вам \"Расширение территории\", заклинание, создающее вокруг вас область космических полей размером 5x5. \
			Существа поблизости также получат звёздную метку."
	gain_text = "Земля подо мной задрожала. Зверь вселился в меня. Его голос опьянял."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "cosmic_domain"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion
	cost = 2
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Дар Творца"
	desc = "Ритуал вознесения Пути Космоса. \
			Поднесите 3 трупа со звёздной меткой к руне трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы станете владельцем Звёздного Наблюдателя. \
			Вы сможете отдавать ему приказы через способность \"Управлять Звёздным Наблюдателем\" или голосом. \
			Звёздный Наблюдатель — сильный союзник, способный разрушать укреплённые стены. \
			У Звёздного Наблюдателя есть аура, исцеляющая вас и наносящая урон противникам. \
			\"Звёздное Касание\" теперь может телепортировать вас к Звёздному Наблюдателю. \
			Ваше заклинание \"Расширение территории\" и ваши клинки также значительно усиливаются."
	gain_text = "Зверь протянул руку, и я ухватился за неё, и он притянул меня к себе. \
				Его тело возвышалось надо мной, но казалось слишком маленьким и слабым после всех \
				их историй, накопившихся в моей голове. Я вцепился в него: он защитит \
				меня, а я защищу его. Я закрыл глаза, прижавшись головой к его телу. \
				Я был в безопасности. СТАНЬТЕ СВИДЕТЕЛЯМИ МОЕГО ВОЗНЕСЕНИЯ!"

	announcement_text = "%SPOOKY% Звёздный Наблюдатель прервал созерцание космоса и обернул свой взор на станцию. %NAME% вознёсся! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_cosmic.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "cosmicascend"
	/// A static list of command we can use with our mob.
	var/static/list/star_gazer_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/attack/star_gazer
	)
	/// Traits granted to the ascended heretic (low/high pressure = cold/heat resist in master220, + x-ray).
	var/static/list/ascended_traits = list(TRAIT_RESIST_HEAT, TRAIT_RESIST_COLD, TRAIT_XRAY_VISION)
	/// Traits granted to our summoned Star Gazer.
	var/static/list/stargazer_traits = list(TRAIT_RESIST_HEAT, TRAIT_RESIST_COLD, TRAIT_XRAY_VISION, TRAIT_BOMBIMMUNE)


/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return sacrifice.has_status_effect(/datum/status_effect/star_mark)


/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()

	user.add_traits(ascended_traits, type)
	if(ishuman(user))
		user.update_sight()

	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_mob = new(loc, user)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	star_gazer_mob.faction |= FACTION_HERETIC
	star_gazer_mob.add_traits(stargazer_traits, type)
	star_gazer_mob.AddComponent(/datum/component/damage_aura, range = 7, burn_damage = 0.5, simple_damage = 0.5, immune_factions = list(FACTION_HERETIC), current_owner = user)

	star_gazer_mob.AddComponent(/datum/component/obeys_commands, star_gazer_commands, radial_menu_offset = list(30, 0), radial_menu_lifetime = 15 SECONDS, radial_relative_to_user = TRUE)
	star_gazer_mob.befriend(user)
	star_gazer_mob.leash_to(star_gazer_mob, user)
	user.AddComponent(/datum/component/death_linked, star_gazer_mob)

	user.mind.AddSpell(new /obj/effect/proc_holder/spell/open_mob_commands(star_gazer_mob))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/replace_star_gazer(star_gazer_mob))

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/cosmic/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/cosmic)
	blade_upgrade.combo_duration = 10 SECONDS
	blade_upgrade.combo_duration_amount = 10 SECONDS
	blade_upgrade.max_combo_duration = 30 SECONDS
	blade_upgrade.increase_amount = 2 SECONDS
	blade_upgrade.max_attack_range = 3
	var/obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion/cosmic_expansion_spell = locate() in user.mob_spell_list
	cosmic_expansion_spell?.ascended = TRUE
	var/obj/effect/proc_holder/spell/touch/star_touch/star_touch_spell = locate() in user.mob_spell_list
	if(star_touch_spell)
		star_touch_spell.set_star_gazer(star_gazer_mob)
		star_touch_spell.ascended = TRUE


/obj/effect/proc_holder/spell/open_mob_commands
	name = "Управлять Звёздным Наблюдателем"
	desc = "Открывает меню для управления вашим Звёздным Наблюдателем."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "stargazer_menu"
	base_cooldown = 1 SECONDS
	human_req = FALSE
	clothes_req = FALSE
	/// Weakref for storing our stargazer
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/our_mob


/obj/effect/proc_holder/spell/open_mob_commands/New(gazer)
	. = ..()
	our_mob = gazer


/obj/effect/proc_holder/spell/open_mob_commands/cast(list/targets, mob/user)
	open_menu()
	return TRUE


/// Opens the pet command options menu for a mob.
/obj/effect/proc_holder/spell/open_mob_commands/proc/open_menu()
	if(!our_mob)
		return

	var/datum/component/obeys_commands/command_component = our_mob.GetComponent(/datum/component/obeys_commands)
	if(!command_component)
		return

	command_component.display_menu(action.owner)


/obj/effect/proc_holder/spell/replace_star_gazer
	name = "Сменить разум Наблюдателя"
	desc = "Заменяет разум вашего Звёздного Наблюдателя разумом другого призрака."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "stargazer_menu"
	base_cooldown = 5 MINUTES
	human_req = FALSE
	clothes_req = FALSE
	/// The stargazer whose mind we swap out.
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/our_mob


/obj/effect/proc_holder/spell/replace_star_gazer/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/replace_star_gazer/New(gazer)
	. = ..()
	our_mob = gazer


/obj/effect/proc_holder/spell/replace_star_gazer/cast(list/targets, mob/user)
	if(QDELETED(our_mob))
		to_chat(user, span_warning("У вас нет Звёздного Наблюдателя."))
		return FALSE

	to_chat(user, span_hierophant("Вы побуждаете [our_mob.declent_ru(ACCUSATIVE)] сменить свою личность..."))
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите играть за [our_mob.declent_ru(ACCUSATIVE)] [span_danger("[user.real_name]")]?", null, FALSE, poll_time = 10 SECONDS, ignore_respawnability = TRUE, source = our_mob)
	if(!length(candidates))
		to_chat(user, span_hierophant("Никто не откликнулся на ваш зов. Похоже, пока придётся обойтись тем, что есть."))
		return FALSE

	var/mob/dead/observer/observer = pick(candidates)
	if(our_mob.mind)
		to_chat(our_mob, span_hierophant("Хозяин сбросил вас, и ваше тело занял другой призрак. Видимо, он остался недоволен."))
		our_mob.ghostize(FALSE)
	our_mob.key = observer.key
	if(our_mob.mind && !our_mob.mind.has_antag_datum(/datum/antagonist/heretic_monster))
		var/datum/antagonist/heretic_monster/heretic_monster = our_mob.mind.add_antag_datum(/datum/antagonist/heretic_monster)
		heretic_monster.set_owner(user.mind)
	to_chat(user, span_hierophant("Разум [our_mob.declent_ru(GENITIVE)] перекроился под вас."))
	return TRUE
