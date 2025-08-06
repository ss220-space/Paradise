
/datum/heretic_knowledge_tree_column/main/blade
	neighbour_type_left = /datum/heretic_knowledge_tree_column/void_to_blade
	neighbour_type_right = /datum/heretic_knowledge_tree_column/blade_to_rust

	route = PATH_BLADE
	ui_bgr = "node_blade"

	start = /datum/heretic_knowledge/limited_amount/starting/base_blade
	grasp = /datum/heretic_knowledge/blade_grasp
	tier1 = /datum/heretic_knowledge/blade_dance
	mark = /datum/heretic_knowledge/mark/blade_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/blade
	unique_ability = /datum/heretic_knowledge/spell/realignment
	tier2 = /datum/heretic_knowledge/spell/furious_steel
	blade = /datum/heretic_knowledge/blade_upgrade/blade
	tier3 = /datum/heretic_knowledge/spell/wolves_among_sheep
	ascension = /datum/heretic_knowledge/ultimate/blade_final


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


/datum/heretic_knowledge/blade_grasp
	name = "Прикосновение клинка"
	desc = "Ваше Прикосновение Мансуса вызовет кратковременное оглушение, если применить его к человеку, \
			лежащему или отвернувшемуся от вас."
	gain_text = "История пехотинца известна с древних времён. Она полна крови и доблести, \
				её верные спутники - меч, сталь и серебро."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_blade"


/datum/heretic_knowledge/blade_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))


/datum/heretic_knowledge/blade_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)


/datum/heretic_knowledge/blade_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!check_behind(source, target))
		return

	// We're officially behind them, apply effects
	target.AdjustParalysis(1.5 SECONDS)
	target.apply_damage(10, BRUTE/*, wound_bonus = CANT_WOUND*/)
	target.balloon_alert(source, "удар в спину!")
	playsound(target, 'sound/weapons/guillotine.ogg', 100, TRUE)


/// The cooldown duration between triggers of blade dance
#define BLADE_DANCE_COOLDOWN (10 SECONDS)


/datum/heretic_knowledge/blade_dance
	name = "Танец Клинка"
	desc = "Если вас атакуют, пока вы держите в любой из рук клинок Еретика, вы нанесёте ответный удар \
			по атакующему. Этот эффект может сработать только раз в 10 секунд."
	gain_text = "Этот пехотинец был известен как грозный дуэлянт. \
				Их генерал даровал ему титул Чемпиона."
	cost = 1
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "shatter"
	/// Whether the counter-attack is ready or not.
	/// Used instead of cooldowns, so we can give feedback when it's ready again
	var/riposte_ready = TRUE


/datum/heretic_knowledge/blade_dance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_shield_reaction))
	if(!HAS_TRAIT(user, TRAIT_RELAYING_ATTACKER))
		user.AddElement(/datum/element/relay_attackers)


/datum/heretic_knowledge/blade_dance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_ATOM_WAS_ATTACKED)


/datum/heretic_knowledge/blade_dance/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	damage = 0,
	attack_text = "атакует",
	attack_type = ITEM_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE,
)

	SIGNAL_HANDLER

	if(attack_type != ITEM_ATTACK)
		return

	if(!riposte_ready)
		return

	//if(INCAPACITATED_IGNORING(source, INCAPABLE_GRAB))
	//	return

	var/mob/living/attacker = isliving(hitby) ? hitby : hitby.loc
	if(!istype(attacker))
		return

	if(!source.Adjacent(attacker))
		return

	// Let's check their held items to see if we can do a riposte
	var/obj/item/main_hand = source.get_active_hand()
	var/obj/item/off_hand = source.get_inactive_hand()
	// This is the item that ends up doing the "blocking" (flavor)
	var/obj/item/striking_with

	// First we'll check if the offhand is valid
	if(!QDELETED(off_hand) && istype(off_hand, /obj/item/melee/sickly_blade))
		striking_with = off_hand

	// Then we'll check the mainhand
	// We do mainhand second, because we want to prioritize it over the offhand
	if(!QDELETED(main_hand) && istype(main_hand, /obj/item/melee/sickly_blade))
		striking_with = main_hand

	// No valid item in either slot? No riposte
	if(!striking_with)
		return

	// And reset after a bit
	riposte_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_riposte), source), BLADE_DANCE_COOLDOWN)

	// If we made it here, deliver the strike
	INVOKE_ASYNC(src, PROC_REF(counter_attack), source, attacker, striking_with, attack_text)


/datum/heretic_knowledge/blade_dance/proc/counter_attack(mob/living/carbon/human/source, mob/living/target, obj/item/melee/sickly_blade/weapon, attack_text)
	playsound(get_turf(source), 'sound/weapons/parry.ogg', 100, TRUE)
	source.balloon_alert(source, "контратака")
	source.visible_message(
		span_warning("[source.declent_ru(NOMINATIVE)] наклоняется к [target.declent_ru(ACCUSATIVE)] и наносит внезапный ответный удар!"),
		span_warning("Вы наклоняетесь и наносите внезапный ответный удар!"),
		span_hear("Вы слышите звон, и тяжелый удар."),
	)
	weapon.melee_attack_chain(source, target)


/datum/heretic_knowledge/blade_dance/proc/reset_riposte(mob/living/carbon/human/source)
	riposte_ready = TRUE
	source.balloon_alert(source, "контратака готова")


#undef BLADE_DANCE_COOLDOWN


/datum/heretic_knowledge/mark/blade_mark
	name = "Метка Клинка"
	desc = "Ваше «Прикосновение Мансуса» теперь накладывает Метку Клинка. Пока метка находится на вас, \
			жертва не сможет покинуть свою комнату, пока метка не истечёт или не сработает. \
			Срабатывание метки призовёт нож, который будет вращаться вокруг вас в течение короткого времени. \
			Нож блокирует любую атаку, направленную в вас, но расходуется при использовании."
	gain_text = "Его генерал хотел положить конец войне, но Чемпион знал, что жизнь без смерти невозможна. \
				Он решил что убьёт труса и любого, кто попытается бежать."
	mark_type = /datum/status_effect/eldritch/blade


/datum/heretic_knowledge/mark/blade_mark/create_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/blade/blade_mark = ..()
	if(!istype(blade_mark))
		return blade_mark

	var/area/to_lock_to = get_area(target)
	blade_mark.locked_to = to_lock_to
	to_chat(target, span_purple("Потусторонняя сила заставляет вас оставаться в [get_area_name(to_lock_to)]!"))
	return blade_mark


/datum/heretic_knowledge/mark/blade_mark/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	source.apply_status_effect(/datum/status_effect/protective_blades, 60 SECONDS, 1, 20, 0 SECONDS)


/datum/heretic_knowledge/knowledge_ritual/blade


/datum/heretic_knowledge/spell/realignment
	name = "Перестройка"
	desc = "Даёт вам «Перестройку» — заклинание, которое быстро перестраивает ваше тело на короткий промежуток времени. \
			Во время этого процесса вы будете быстро восстанавливать выносливость и быстро восстанавливаться от оглушения, \
			однако не сможете атаковать."
	gain_text = "В круговерти смерти он обрёл внутренний покой. Несмотря на непреодолимые препятствия, он продолжал идти вперёд."
	research_tree_icon_path = 'icons/hud/implants.dmi'
	research_tree_icon_state = "adrenal"
	spell_to_add = /obj/effect/proc_holder/spell/realignment
	cost = 1


/datum/heretic_knowledge/spell/wolves_among_sheep
	name = "Волк среди овец"
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
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/wolves_among_sheep


/datum/heretic_knowledge/blade_upgrade/blade
	name = "Усиленные Клинки"
	desc = "Атака с Клинками в обеих руках теперь будет наносить удар обоими руками \
			одновременно. Второй удар будет немного слабее. Вы можете вкладывать силу \
			Мансуса непосредственно в свои клинки, чтобы сделать их более эффективными против строений."
	gain_text = "Я нашел его расколотым надвое, половинки сцепились в бесконечном поединке; \
				Вокруг был шквал клинков, но ни один не достиг цели, ибо Воитель был неукротим."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_blade"
	/// How much force do we apply to the offhand?
	var/offand_force_decrement = 0
	/// How much force was the last weapon we offhanded with? If it's different, we need to re-calculate the decrement
	var/last_weapon_force = -1


/datum/heretic_knowledge/blade_upgrade/blade/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))
	//RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_blade_equipped))
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(do_melee_effects), override = TRUE)


/datum/heretic_knowledge/blade_upgrade/blade/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, list(COMSIG_TOUCH_HANDLESS_CAST/*, COMSIG_MOB_EQUIPPED_ITEM*/, COMSIG_HERETIC_BLADE_ATTACK))


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

	//Infuse our off-hand blade just so it's nicer visually
	var/obj/item/melee/sickly_blade/dark/off_hand_blade = cast_on.get_inactive_hand()
	if(istype(off_hand_blade, /obj/item/melee/sickly_blade/dark))
		off_hand_blade.infused = TRUE
		off_hand_blade.update_appearance(UPDATE_ICON)

	//cast_on.update_held_items()

	return COMPONENT_CAST_HANDLESS


/datum/heretic_knowledge/blade_upgrade/blade/do_melee_effects(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(target == source)
		return

	var/obj/item/off_hand = source.get_inactive_hand()
	if(QDELETED(off_hand) || !istype(off_hand, /obj/item/melee/sickly_blade))
		return

	// If our off-hand is the blade that's attacking,
	// quit out now to avoid an infinite stab combo
	if(off_hand == blade)
		return

	// Give it a short delay (for style, also lets people dodge it I guess)
	addtimer(CALLBACK(src, PROC_REF(follow_up_attack), source, target, off_hand), 0.25 SECONDS)


/datum/heretic_knowledge/blade_upgrade/blade/proc/follow_up_attack(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(QDELETED(source) || QDELETED(target) || QDELETED(blade))
		return

	// Sanity to ensure that the blade we're delivering an offhand attack with is ACTUALLY our offhand
	if(blade != source.get_inactive_hand())
		return

	// And we easily could've moved away
	if(!source.Adjacent(target))
		return

	// Check if we need to recaclulate our offhand force
	// This is just so we don't run this block every attack, that's wasteful
	if(last_weapon_force == blade.force)
		// Perform the offhand attack
		blade.melee_attack_chain(source, target, null, list(FORCE_MODIFIER = -offand_force_decrement))
		return

	offand_force_decrement = 0
	// We want to make sure that the offhand blade increases their hits to crit by one, just about
	// So, let's do some quick math. Yes this'll be inaccurate if their mainhand blade is modified (whetstone), no I don't care
	// Find how much force we need to detract from the second blade
	var/hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2))
	while(hits_to_crit_on_average <= 3) // 3 hits and beyond is a bit too absurd
		if(offand_force_decrement + 2 > blade.force * 0.5) // But also cutting the force beyond half is absurd
			break

		offand_force_decrement += 2
		hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2 - offand_force_decrement))

	// Perform the offhand attack
	blade.melee_attack_chain(source, target, null, list(FORCE_MODIFIER = -offand_force_decrement))


/*
///Modifies our blade demolition modifier so we can take down doors with it
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_blade_equipped(mob/user, obj/item/equipped, slot)
	SIGNAL_HANDLER
	if(istype(equipped, /obj/item/melee/sickly_blade/dark))
		equipped.demolition_mod = 1.5
*/

/datum/heretic_knowledge/spell/furious_steel
	name = "Яростная сталь"
	desc = "Даёт вам «Яростную сталь», направляемое заклинание. При его использовании вокруг \
			вас появятся три вращающихся клинка. Эти клинки защитят вас от атак, \
			но расходуются при использовании. Кроме того, вы можете, выстрелить клинками \
			в цель, нанося урон и вызывая кровотечение."
	gain_text = "Не раздумывая, я схватил нож павшего солдата и метнул его со всей силы. \
				Мои тренировки меня не подвели! Поверженный воин улыбнулся, \
				впервые почувствовав боль. Его клинки стали моими."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "furious_steel"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/projectile/furious_steel
	cost = 1


/datum/heretic_knowledge/ultimate/blade_final
	name = "Серебрянный водоворот"
	desc = "Ритуал вознесения Пути Клинка. \
			Принесите 3 безголовых трупа к руне трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы будете окружены множеством клинков. \
			Эти клинки защитят вас от всех атак, но расходуются при использовании. \
			Ваше заклинание «Неистовая сталь» также будет перезаряжаться быстрее. \
			Кроме того, вы становитесь мастером боя, получая полную невосприимчивость \
			к переломам и способность игнорировать кратковременные оглушения. \
			Ваши клинки наносят дополнительный урон и исцеляют вас при \
			атаке на часть нанесенного урона."
	gain_text = "Я достиг вершины боевого мастерства! МНЕ НЕТ РАВНЫХ! ДА НАГНЕТАЕТ МОИХ ВРАГОВ БУРЯ ИЗ СТАЛИ И СЕРЕБРА! СТАНЬТЕ СВИДЕТЕЛЯМИ МОЕГО ВОЗНЕСЕНИЯ!"

	//ascension_achievement = /datum/award/achievement/misc/blade_ascension
	announcement_text = "%SPOOKY% Мастер Клинка, %NAME% вознесся! Сталь клинков рассечет реальность в серебрянном водовороте! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_blade.ogg'


/datum/heretic_knowledge/ultimate/blade_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return !sacrifice.get_bodypart(BODY_ZONE_HEAD)// || HAS_TRAIT(sacrifice, TRAIT_HAS_CRANIAL_FISSURE)


/datum/heretic_knowledge/ultimate/blade_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	//ADD_TRAIT(user, TRAIT_NEVER_WOUNDED, type)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))
	user.apply_status_effect(/datum/status_effect/protective_blades/recharging, null, 8, 30, 0.25 SECONDS, /obj/effect/floating_blade, 30 SECONDS)
	user.add_stun_absorption(
		source = name,
		message = span_warning("%EFFECT_OWNER выдерживает оглушение!"),
		self_message = span_warning("Вы выдерживаете оглушение!"),
		examine_message = span_purple("%EFFECT_OWNER слегка покачивается."),
		// flashbangs are like 5-10 seoncds,
		// a banana peel is ~5 seconds, depending on botany
		// body throws and tackles are less than 5 seconds,
		// stun baton / stamcrit detracts no time,
		// and worst case: beepsky / tasers are 10 seconds.
		max_seconds_of_stuns_blocked = 45 SECONDS,
		delete_after_passing_max = FALSE,
		recharge_time = 2 MINUTES,
	)
	var/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/steel_spell = locate() in user.mob_spell_list
	steel_spell?.base_cooldown /= 2

	var/mob/living/carbon/human/heretic = user
	heretic.physiology.knockdown_mod = 0.75 // Otherwise knockdowns would probably overpower the stun absorption effect.


/datum/heretic_knowledge/ultimate/blade_final/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	if(!istype(target))
		return

	if(target == source)
		return

	// Turns your heretic blades into eswords, pretty much.
	var/bonus_damage = clamp(30 - blade.force, 0, 12)

	target.apply_damage(
		damage = bonus_damage,
		damagetype = BRUTE,
		spread_damage = TRUE,
		//wound_bonus = 5,
		sharp = TRUE,
		//attack_direction = get_dir(source, target),
	)

	if(target.stat != DEAD)
		// And! Get some free healing for a portion of the bonus damage dealt.
		source.heal_overall_damage(bonus_damage / 2, bonus_damage / 2)


///Checks to see if `atom/source` is behind `atom/target`
/proc/check_behind(atom/source, atom/target)
	// Let's see if source is behind target
	// "Behind" is defined as 3 tiles directly to the back of the target
	// x . .
	// x > .
	// x . .

	// No tactical spinning allowed
	//if(HAS_TRAIT(target, TRAIT_SPINNING))
	//	return TRUE

	// We'll take "same tile" as "behind" for ease
	if(target.loc == source.loc)
		return TRUE

	// We'll also assume lying down is behind, as mob directions when lying are unclear
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.body_position == LYING_DOWN)
			return TRUE

	// Exceptions aside, let's actually check if they're, yknow, behind
	return source.dir == get_dir(source, target)
