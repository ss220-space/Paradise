
/datum/heretic_knowledge_tree_column/main/cosmic
	neighbour_type_left = /datum/heretic_knowledge_tree_column/rust_to_cosmic
	neighbour_type_right = /datum/heretic_knowledge_tree_column/cosmic_to_ash

	route = PATH_COSMIC
	ui_bgr = "node_cosmos"

	start = /datum/heretic_knowledge/limited_amount/starting/base_cosmic
	grasp = /datum/heretic_knowledge/cosmic_grasp
	tier1 = /datum/heretic_knowledge/spell/cosmic_runes
	mark = /datum/heretic_knowledge/mark/cosmic_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/cosmic
	unique_ability = /datum/heretic_knowledge/spell/star_touch
	tier2 = /datum/heretic_knowledge/spell/star_blast
	blade = /datum/heretic_knowledge/blade_upgrade/cosmic
	tier3 =	 /datum/heretic_knowledge/spell/cosmic_expansion
	ascension = /datum/heretic_knowledge/ultimate/cosmic_final


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


/datum/heretic_knowledge/cosmic_grasp
	name = "Прикосновение космоса"
	desc = "Ваше Прикосновение Мансуса даст людям звёздную метку и создаст космическое поле там, где вы стоите. \
			Люди со звёздной меткой не могут проходить сквозь космические поля."
	gain_text = "Некоторые звёзды потускнели, другие засияли ярче. \
				Обретя новые силы, я смог направить силу туманности в себя."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_cosmos"


/datum/heretic_knowledge/cosmic_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))


/datum/heretic_knowledge/cosmic_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)


/// Aplies the effect of the mansus grasp when it hits a target.
/datum/heretic_knowledge/cosmic_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	to_chat(target, span_danger("Над вашей головой появилось космическое кольцо!"))
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	new /obj/effect/forcefield/cosmic_field(get_turf(source))


/datum/heretic_knowledge/spell/cosmic_runes
	name = "Звёздные Руны"
	desc = "Даёт вам \"Звёздные Руны\" — заклинание, создающее две руны телепортирующие друг на друга. \
			Только активировавшая руну сущность будет перемещена. Её может использовать любой человек без звёздной метки. \
			Однако люди со звёздной меткой будут перемещены вместе с другим человеком, использующим руну."
	gain_text = "Далёкие звёзды проникли в мои сны, ревя и крича без причины. Я заговорил и \
				услышал эхо собственных слов."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "cosmic_rune"
	spell_to_add = /obj/effect/proc_holder/spell/cosmic_rune
	cost = 1


/datum/heretic_knowledge/mark/cosmic_mark
	name = "Метка Космоса"
	desc = "Ваше «Прикосновение Мансуса» теперь накладывает Метку Космоса. Метка активируется атакой \
			вашим клинком. При срабатывании метки жертва возвращается в место, где эта метка изначально была \
			наложена, оставляя на своём месте космическое поле. После перемещения жертва будет парализована на 2 секунды."
	gain_text = "Зверь изредка нашептывал мне отрывочные подробности их жизни. \
				Я могу им помочь, я должен им помочь."
	mark_type = /datum/status_effect/eldritch/cosmic


/datum/heretic_knowledge/knowledge_ritual/cosmic


/datum/heretic_knowledge/spell/star_touch
	name = "Звёздное Касание"
	desc = "Даёт вам Звёздное Касание — заклинание, которое накладывает на вашу цель звёздную метку, \
			создаёт космическое поле у ваших ног и на плитках рядом с вами. Цели, уже имеющие звёздную метку \
			будут усыплены на 4 секунды. При попадании в жертву также создаётся луч, направленный на неё. \
			Луч существует минуту, пока не будет преграждён или пока не будет найдена новая цель."
	gain_text = "Я проснулся в холодном поту из-за того, что почувствовал на голове чью-то ладонь. \
				Мои вены начали излучать странное фиолетовое свечение. Зверь знает, что я превзойду его ожидания."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "star_touch"
	spell_to_add = /obj/effect/proc_holder/spell/touch/star_touch
	cost = 1


/datum/heretic_knowledge/spell/star_blast
	name = "Звёздный взрыв"
	desc = "Выпускает снаряд, создающий стену космических полей. \
			Любой, в кого попал снаряд, будет сбит с ног и получит звёздную метку."
	gain_text = "Зверь всегда был позади меня, и с каждой принесенной жертвой я чувствовал его одобрение."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "star_blast"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/projectile/star_blast
	cost = 1


/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Клинок Космоса"
	desc = "Ваш клинок теперь наносит урон органам людей космическим излучением. \
			Ваши атаки будут наносить дополнительный урон предыдущим жертвам. \
			Комбо сбрасывается после двух секунд без атаки, \
			или после атаки по той же цели. Если вы выполните более четырёх таких атак подрят, вы получите \
			метку космоса и увеличите время комбо до десяти секунд."
	gain_text = "Зверь взглянул на мои клинки. Я упал на колени почувствовав острую боль. \
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


/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	var/static/list/valid_organ_slots = list(
		INTERNAL_ORGAN_HEART,
		INTERNAL_ORGAN_LUNGS,
		INTERNAL_ORGAN_STOMACH,
		INTERNAL_ORGAN_EYES,
		INTERNAL_ORGAN_EARS,
		INTERNAL_ORGAN_LIVER,
		INTERNAL_ORGAN_BRAIN
	)
	if(source == target || !isliving(target))
		return

	if(combo_timer)
		deltimer(combo_timer)

	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = second_target?.resolve()
	var/mob/living/third_target_resolved = third_target?.resolve()
	var/need_mob_update = FALSE
	need_mob_update += target.adjustFireLoss(5, updating_health = FALSE)
	need_mob_update += target.adjustOrganLoss(pick(valid_organ_slots), 8)
	if(need_mob_update)
		target.updatehealth()

	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return

	if(target.mind && target.stat != DEAD)
		combo_counter += 1

	if(!second_target_resolved)
		second_target = WEAKREF(target)
		return

	new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
	playsound(get_turf(second_target_resolved), 'sound/magic/cosmic_energy.ogg', 25, FALSE)
	need_mob_update = FALSE
	need_mob_update += second_target_resolved.adjustFireLoss(14, updating_health = FALSE)
	need_mob_update += second_target_resolved.adjustOrganLoss(pick(valid_organ_slots), 12)
	if(need_mob_update)
		second_target_resolved.updatehealth()

	if(!third_target_resolved)
		third_target = second_target
		second_target = WEAKREF(target)
		return

	new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
	playsound(get_turf(third_target_resolved), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
	need_mob_update = FALSE
	need_mob_update += third_target_resolved.adjustFireLoss(28, updating_health = FALSE)
	need_mob_update += third_target_resolved.adjustOrganLoss(pick(valid_organ_slots), 14)
	if(need_mob_update)
		third_target_resolved.updatehealth()

	if(combo_counter < 3)
		third_target = second_target
		second_target = WEAKREF(target)
		return

	target.apply_status_effect(/datum/status_effect/star_mark, source)
	if(!target.mind || target.stat == DEAD)
		third_target = second_target
		second_target = WEAKREF(target)
		return

	increase_combo_duration()
	if(combo_counter == 4)
		source.AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)

	third_target = second_target
	second_target = WEAKREF(target)


/// Resets the combo.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/reset_combo(mob/living/source)
	second_target = null
	third_target = null
	if(combo_counter > 3)
		source.RemoveElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)

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
	name = "Расширение территории"
	desc = "Даёт вам «Расширение территории» — заклинание, создающее вокруг вас область космических полей размером 3x3. \
			Существа поблизости получат звёздную метку."
	gain_text = "Земля подо мной задрожала. Зверь вселился в меня. Его голос опьянял."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "cosmic_domain"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion
	cost = 1


/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Дар Творца"
	desc = "Ритуал вознесения Пути Космоса. \
			Поднесите 3 трупа с плазмой внутри к руне трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы станете владельцем Звёздного Глашатоя. \
			Звёздный Наблюдатель — сильный союзник, способный разрушать укреплённые стены. \
			У Звёздного Глашатоя есть аура, исцеляющая вас и наносящая урон противникам. \
			Звёздное Касание теперь может телепортировать вас к Звёздному Наблюдателю. \
			Ваше заклинание «Расширение территории» и ваши клинки также значительно усиливаются."
	gain_text = "Зверь протянул руку, и я ухватился за неё, и он притянул меня к себе. \
				Его тело возвышалось надо мной, но казалось слишком маленьким и слабыми после всех \
				их историй, накопившихся в моей голове. Я вцепился в него, он защитит \
				меня, а я защищу его. Я закрыл глаза, прижавшись головой к его телу. \
				Я был в безопасности. СТАНЬТЕ СВИДЕТЕЛЯМИ МОЕГО ВОЗНЕСЕНИЯ!"

	//ascension_achievement = /datum/award/achievement/misc/cosmic_ascension
	announcement_text = "%SPOOKY% Звёздный Наблюдатель прибыл на станцию, %NAME% вознесся! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_cosmic.ogg'
	/// A static list of command we can use with our mob.
	var/static/list/star_gazer_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/attack/star_gazer
	)


/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return sacrifice.reagents.has_reagent("plasma") || sacrifice.reagents.has_reagent("plasma_dust")


/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_mob = new /mob/living/simple_animal/hostile/heretic_summon/star_gazer(loc)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	user.AddComponent(/datum/component/death_linked, star_gazer_mob)
	star_gazer_mob.AddComponent(/datum/component/obeys_commands, star_gazer_commands, radial_menu_offset = list(30,0), radial_menu_lifetime = 15 SECONDS, radial_relative_to_user = TRUE)
	star_gazer_mob.AddComponent(/datum/component/damage_aura, range = 7, burn_damage = 0.5, simple_damage = 0.5, immune_factions = list(FACTION_HERETIC), current_owner = user)
	star_gazer_mob.befriend(user)
	user.AddSpell(new /obj/effect/proc_holder/spell/open_mob_commands(star_gazer_mob))
	var/obj/effect/proc_holder/spell/touch/star_touch/star_touch_spell = locate() in user.mob_spell_list
	if(star_touch_spell)
		star_touch_spell.set_star_gazer(star_gazer_mob)
		star_touch_spell.ascended = TRUE

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/cosmic/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/cosmic)
	blade_upgrade.combo_duration = 10 SECONDS
	blade_upgrade.combo_duration_amount = 10 SECONDS
	blade_upgrade.max_combo_duration = 30 SECONDS
	blade_upgrade.increase_amount = 2 SECONDS

	var/obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion/cosmic_expansion_spell = locate() in user.mob_spell_list
	cosmic_expansion_spell?.ascended = TRUE


/obj/effect/proc_holder/spell/open_mob_commands
	name = "Управлять Звёздным Глашатаем"
	desc = "Открывает меню для управления вашим Звёздным Глашатаем."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "stargazer_menu"
	base_cooldown = 1 SECONDS
	human_req = FALSE
	clothes_req = FALSE
	//check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_PHASED
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
