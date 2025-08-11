#define MORPHED_SPEED 2.5
#define ITEM_EAT_COST 5
#define MORPHS_ANNOUNCE_THRESHOLD 5

/mob/living/simple_animal/hostile/morph
	name = "morph"
	ru_names = list(
		NOMINATIVE = "морф",
		GENITIVE = "морфа",
		DATIVE = "морфу",
		ACCUSATIVE = "морфа",
		INSTRUMENTAL = "морфом",
		PREPOSITIONAL = "морфе"
	)
	real_name = "morph"
	desc = "Отвратительная пульсирующая масса плоти."
	speak_emote = list("булькает", "клокочет")
	emote_hear = list("булькает", "клокочет")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 1.5
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	move_resist = MOVE_FORCE_STRONG // Fat being
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	tts_seed = "Treant"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	environment_smash = 1
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = 0
	attacktext = "кусает"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)

	var/playstyle_string = "<b><font size=3 color='red'>Вы — морф.</font><br>Как мерзость, созданная в основном из клеток генокрада, \
								вы можете принимать форму любого объекта поблизости, Shift-ЛКМ по нему. Этот процесс предупредит всех \
								наблюдателей поблизости и может выполняться только раз в пять секунд.<br> В изменённой форме вы двигаетесь \
								быстрее, но наносите меньше урона. Кроме того, любой, кто находится в радиусе трёх тайлов, заметит \
								нечто странное, если осмотрит вас. Вы можете вернуться в свою изначальную форму, Shift-ЛКМ по себе.<br> \
								Наконец, вы можете атаковать любой предмет или мёртвое существо, чтобы поглотить его — существа восстановят \
								1/3 вашего максимального здоровья.</b>"

	/// If the morph can reproduce or not
	var/can_reproduce = FALSE
	/// If the morph is disguised or not
	var/morphed = FALSE
	/// If the morph is ready to perform an ambush
	var/ambush_prepared = FALSE
	/// How much damage a successful ambush attack does
	var/ambush_damage = 25
	/// How much weaken a successful ambush attack applies
	var/ambush_weaken = 6 SECONDS
	/// The spell the morph uses to morph
	var/obj/effect/proc_holder/spell/mimic/morph/mimic_spell
	/// The ambush action used by the morph
	var/obj/effect/proc_holder/spell/morph_spell/ambush/ambush_spell
	/// The spell the morph uses to pass through airlocks
	var/obj/effect/proc_holder/spell/morph_spell/pass_airlock/pass_airlock_spell

	/// How much the morph has gathered in terms of food. Used to reproduce and such
	var/gathered_food = 20 // Start with a bit to use abilities


/mob/living/simple_animal/hostile/morph/proc/check_morphs()
	if((length(GLOB.morphs_alive_list) >= MORPHS_ANNOUNCE_THRESHOLD) && (!GLOB.morphs_announced))
		GLOB.major_announcement.announce("Зафиксированы множественные биоугрозы 6 уровня на [station_name()]. Необходима ликвидация угрозы для продолжения безопасной работы.",
										ANNOUNCE_BIOHAZARD_RU,
										'sound/AI/commandreport.ogg',
										new_sound2 = 'sound/effects/siren-spooky.ogg'
		)
		GLOB.morphs_announced = TRUE
		SSshuttle.emergency.cancel()


/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	. = ..()
	mimic_spell = new
	AddSpell(mimic_spell)
	ambush_spell = new
	AddSpell(ambush_spell)
	AddSpell(new /obj/effect/proc_holder/spell/morph_spell/open_vent)
	pass_airlock_spell = new
	AddSpell(pass_airlock_spell)
	GLOB.morphs_alive_list += src
	check_morphs()

/mob/living/simple_animal/hostile/morph/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/**
 * This proc enables or disables morph reproducing ability
 *
 * Arguments
 * * boolean - TRUE = enabled, FALSE = disabled
 */
/mob/living/simple_animal/hostile/morph/proc/enable_reproduce(boolean)
	if(boolean)
		can_reproduce = TRUE
		AddSpell(new /obj/effect/proc_holder/spell/morph_spell/reproduce)
	else
		can_reproduce = FALSE
		RemoveSpell(/obj/effect/proc_holder/spell/morph_spell/reproduce)

/mob/living/simple_animal/hostile/morph/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Food Stored:", "[gathered_food]")

/mob/living/simple_animal/hostile/morph/wizard
	name = "magical morph"
	ru_names = list(
		NOMINATIVE = "магический морф",
		GENITIVE = "магического морфа",
		DATIVE = "магическому морфу",
		ACCUSATIVE = "магического морфа",
		INSTRUMENTAL = "магическим морфом",
		PREPOSITIONAL = "магическом морфе"
	)
	real_name = "magical morph"
	desc = "Отвратительная пульсирующая масса плоти. Выглядит несколько... магически."

/mob/living/simple_animal/hostile/morph/wizard/New()
	. = ..()
	var/obj/effect/proc_holder/spell/smoke/smoke = new
	var/obj/effect/proc_holder/spell/forcewall/forcewall = new
	smoke.human_req = FALSE
	forcewall.human_req = FALSE
	AddSpell(smoke)
	AddSpell(forcewall)


/mob/living/simple_animal/hostile/morph/proc/try_eat(atom/movable/item)
	var/food_value = calc_food_gained(item)
	if(food_value + gathered_food < 0)
		to_chat(src, span_warning("Ваш организм отторгает эту массу. Нужен свежий труп!"))
		return
	var/eat_self_message
	if(food_value < 0)
		eat_self_message = span_warning("Вы начинаете [pick("жрать", "поглощать")] [item.declent_ru(ACCUSATIVE)]... отвратительно...")
	else
		eat_self_message = span_notice("Вы начинаете [pick("жрать", "поглощать")] [item.declent_ru(ACCUSATIVE)].")
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает [pick("жрать", "поглощать")] [target]!"), eat_self_message, "Вы слышите громкий хруст!")
	if(do_after(src, 3 SECONDS, item))
		if(food_value + gathered_food < 0)
			to_chat(src, span_warning("Ваш организм отторгает эту массу. Нужен свежий труп!"))
			return
		eat(item)

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/item)
	if(item && item.loc != src)
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] проглатывает [item.declent_ru(ACCUSATIVE)] целиком!"))

		item.extinguish_light()
		item.forceMove(src)
		var/food_value = calc_food_gained(item)
		add_food(food_value)
		if(food_value > 0)
			adjustHealth(-food_value)
		add_attack_logs(src, item, "morph ate")
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/proc/calc_food_gained(mob/living/living)
	if(!istype(living))
		return -ITEM_EAT_COST // Anything other than a tasty mob will make me sad ;(
	var/gained_food = max(5, 10 * living.mob_size) // Tiny things are worth less
	if(ishuman(living) && !is_monkeybasic(living))
		gained_food += 10 // Humans are extra tasty

	return gained_food

/mob/living/simple_animal/hostile/morph/proc/use_food(amount)
	if(amount > gathered_food)
		return FALSE
	add_food(-amount)
	return TRUE

/**
 * Adds the given amount of food to the gathered food and updates the actions.
 * Does not include a check to see if it goes below 0 or not
 */
/mob/living/simple_animal/hostile/morph/proc/add_food(amount)
	gathered_food += amount
	update_action_buttons_icon()

/mob/living/simple_animal/hostile/morph/proc/assume()
	morphed = TRUE

	//Morph is weaker initially when disguised
	melee_damage_lower = 5
	melee_damage_upper = 5
	set_varspeed(MORPHED_SPEED)
	ambush_spell.updateButtonIcon()
	pass_airlock_spell.updateButtonIcon()
	move_resist = MOVE_FORCE_DEFAULT // They become more fragile and easier to move

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		return
	morphed = FALSE

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	set_varspeed(initial(speed))
	if(ambush_prepared)
		to_chat(src, span_warning("Потенциал засады исчез, когда вы принимаете свою истинную форму."))
	failed_ambush()
	pass_airlock_spell.updateButtonIcon()
	move_resist = MOVE_FORCE_STRONG // Return to their fatness


/mob/living/simple_animal/hostile/morph/proc/prepare_ambush()
	ambush_prepared = TRUE
	to_chat(src, span_sinister("Вы готовы к внезапной атаке. Ваш следующий удар нанесёт больше урона и ослабит цель! Движение прервёт концентрацию. Бездействие улучшит маскировку."))
	apply_status_effect(/datum/status_effect/morph_ambush)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/mob/living/simple_animal/hostile/morph/proc/failed_ambush()
	ambush_prepared = FALSE
	ambush_spell.updateButtonIcon()
	mimic_spell.perfect_disguise = FALSE // Reset the perfect disguise
	remove_status_effect(/datum/status_effect/morph_ambush)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/mob/living/simple_animal/hostile/morph/proc/perfect_ambush()
	mimic_spell.perfect_disguise = TRUE // Reset the perfect disguise
	to_chat(src, span_sinister("Вы стали совершенной копией... Они даже не заподозрят подмену."))


/mob/living/simple_animal/hostile/morph/proc/on_move()
	failed_ambush()
	to_chat(src, span_warning("Вы покинули место засады!"))


/mob/living/simple_animal/hostile/morph/death(gibbed)
	. = ..()
	if(stat == DEAD && gibbed)
		for(var/atom/movable/eaten_thing in src)
			eaten_thing.forceMove(loc)
			if(prob(90))
				step(eaten_thing, pick(GLOB.alldirs))
	// Only execute the below if we successfully died
	if(!.)
		return FALSE
	GLOB.morphs_alive_list -= src

/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/carbon/human/attacker)
	if(ambush_prepared)
		to_chat(attacker, span_warning("[capitalize(declent_ru(NOMINATIVE))] кажется немного другим, чем обычно... он кажется более... ") + span_userdanger("СЛИЗИСТЫМ?!"))
		ambush_attack(attacker, TRUE)
		return TRUE
	else if (!morphed)
		to_chat(attacker, span_warning("Прикосновение к [declent_ru(DATIVE)] руками причиняет вам боль!"))
		attacker.apply_damage(20, def_zone = attacker.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		add_food(5)

	restore_form()
	return ..()

/mob/living/simple_animal/hostile/morph/proc/restore_form()
	if (morphed)
		return mimic_spell.restore_form(src);


/mob/living/simple_animal/hostile/morph/attackby(obj/item/item, mob/living/user)
	if(stat == DEAD)
		restore_form()
		return ..()

	if(user.a_intent == INTENT_HELP && ambush_prepared)
		to_chat(user, span_warning("Вы пытаетесь использовать [item.declent_ru(ACCUSATIVE)] на [capitalize(declent_ru(NOMINATIVE))]... он кажется другим, чем раньше..."))
		ambush_attack(user, TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!morphed && isrobot(user))
		var/food_value = calc_food_gained(item)
		if(food_value + gathered_food > 0)
			to_chat(user, span_warning("Атака [declent_ru(GENITIVE)] повреждает ваши системы!"))
			user.apply_damage(70)
			add_food(-5)
		return ..()

	if(!morphed && prob(50))
		var/food_value = calc_food_gained(item)
		if(food_value + gathered_food > 0 && !(item.item_flags & ABSTRACT) && user.drop_item_ground(item))
			to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] только что съел ваш [item.declent_ru(ACCUSATIVE)]!"))
			eat(item)
			return ATTACK_CHAIN_BLOCKED_ALL
		return ..()

	restore_form()
	return ..()


/mob/living/simple_animal/hostile/morph/attack_animal(mob/living/simple_animal/animal)
	if(animal.a_intent == INTENT_HELP && ambush_prepared)
		to_chat(animal, span_notice("Вы трётесь о [declent_ru(GENITIVE)].") + span_danger(" И [declent_ru(NOMINATIVE)] трётся в ответ!"))

		ambush_attack(animal, TRUE)
		return TRUE
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_larva(mob/living/carbon/alien/larva/L)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_alien(mob/living/carbon/alien/humanoid/M)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_tk(mob/user)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_slime(mob/living/simple_animal/slime/M)
	restore_form()


/mob/living/simple_animal/hostile/morph/proc/ambush_attack(mob/living/dumbass, touched)
	ambush_prepared = FALSE
	var/total_weaken = ambush_weaken
	var/total_damage = ambush_damage
	if(touched) // Touching a morph while he's ready to kill you is a bad idea
		total_weaken *= 2
		total_damage *= 2

	dumbass.Weaken(total_weaken)
	dumbass.apply_damage(total_damage, BRUTE)
	add_attack_logs(src, dumbass, "morph ambush attacked")
	do_attack_animation(dumbass, ATTACK_EFFECT_BITE)
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] внезапно прыгает на [dumbass.declent_ru(ACCUSATIVE)]!"), span_warning("Вы атакуете [dumbass.declent_ru(ACCUSATIVE)], когда [genderize_ru(dumbass.gender,"он","она","оно","они")] меньше всего этого ожидает!"), "Вы слышите ужасный хруст!")

	restore_form()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/item)
	var/list/not_allowed = list(/atom/movable/screen, /obj/singularity, /mob/living/simple_animal/hostile/morph)
	return !is_type_in_list(item, not_allowed)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(list/possible_targets)
	. = ..()
	if(. && !morphed)
		var/list/things = list()
		for(var/atom/movable/item_in_view in view(src))
			if(isobj(item_in_view) && allowed(item_in_view))
				things += item_in_view
		var/atom/movable/picked_thing = pick(things)
		if (picked_thing)
			mimic_spell.take_form(new /datum/mimic_form(picked_thing, src), src)
			prepare_ambush() // They cheat okay

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(isliving(target)) // Eat Corpses to regen health
		var/mob/living/living = target
		if(living.stat == DEAD)
			try_eat(living)
			return TRUE
		if(ambush_prepared)
			ambush_attack(living)
			return TRUE // No double attack
	else if(isitem(target)) // Eat items just to be annoying
		var/obj/item/item = target
		if(!item.anchored)
			try_eat(item)
			return TRUE
	. = ..()
	if(. && morphed)
		restore_form()


/mob/living/simple_animal/hostile/morph/proc/make_morph_antag(give_default_objectives = TRUE)
	enable_reproduce(TRUE)
	mind.assigned_role = SPECIAL_ROLE_MORPH
	mind.special_role = SPECIAL_ROLE_MORPH
	SSticker.mode.morphs |= mind

	var/list/messages = list()
	messages.Add(span_fontsize3(span_red("<b>Вы — морф.<br></b>")))
	messages.Add(span_sinister("Вы жаждете съесть живых существ и желаете размножаться. Достигните этой цели, устраивая засады на ничего не подозревающую добычу, используя свои способности."))
	messages.Add(span_specialnotice("Будучи мерзостью, созданным в основном из клеток генокрада, вы можете принимать форму любого объекта поблизости, используя свою способность \"Мимикрия\""))
	messages.Add(span_specialnotice("Преобразование не останется незамеченным для наблюдателей."))
	messages.Add(span_specialnotice("В изменённой форме вы двигаетесь медленнее и наносите меньше урона."))
	messages.Add(span_specialnotice("Кроме того, любой, кто находится в радиусе трёх тайлов, заметит нечто странное, если осмотрит вас."))
	messages.Add(span_specialnotice("В этой форме вы можете \"Подготовить засаду\", используя свою способность."))
	messages.Add(span_specialnotice("Это позволит вам нанести огромный урон при первом ударе."))
	messages.Add(span_specialnotice("Если они коснутся вас, то ещё больше."))
	messages.Add(span_specialnotice("Наконец, вы можете атаковать любой предмет или мёртвое существо, чтобы поглотить его — это 1/3 вашего максимального здоровья и добавят к вашему запасу пищи."))
	messages.Add(span_specialnotice("Поедание предметов уменьшит ваш запас пищи.\n"))
	messages.Add(span_motd("<b>С полной информацией вы можете ознакомиться на вики: <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Morph\">Морф</a></b>\n"))

	SEND_SOUND(src, sound('sound/magic/mutate.ogg'))
	if(give_default_objectives)
		var/datum/objective/eat = new /datum/objective
		eat.owner = mind
		eat.explanation_text = "Съешьте как можно больше живых существ, чтобы утолить голод внутри вас."
		eat.completed = TRUE
		eat.needs_target = FALSE
		mind.objectives += eat
		var/datum/objective/procreate = new /datum/objective
		procreate.owner = mind
		procreate.explanation_text = "Породите как можно больше себе подобных!"
		procreate.completed = TRUE
		procreate.needs_target = FALSE
		mind.objectives += procreate
		messages.Add(mind.prepare_announce_objectives(FALSE))

	to_chat(src, chat_box_red(messages.Join("<br>")))


/mob/living/simple_animal/hostile/morph/get_examine_time()
	return morphed ? mimic_spell.selected_form.examine_time : ..()


/mob/living/simple_animal/hostile/morph/get_visible_gender()
	return morphed ? mimic_spell.selected_form.examine_gender : ..()


/mob/living/simple_animal/hostile/morph/get_visible_species()
	return morphed ? mimic_spell.selected_form.examine_species : ..()


#undef MORPHED_SPEED
#undef ITEM_EAT_COST
#undef MORPHS_ANNOUNCE_THRESHOLD
