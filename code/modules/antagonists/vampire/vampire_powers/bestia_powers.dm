/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * -----------------------------------------------------------DEFINES------------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/

/// Max general organs vampire can get
#define MAX_TROPHIES_PER_TYPE_GENERAL	10
/// Max critical organs (lungs and heart) vampire can get
#define MAX_TROPHIES_PER_TYPE_CRITICAL	6

/// Percent cap for different damage modifiers.
#define TROPHIES_CAP_PROT_BRUTE			40
#define TROPHIES_CAP_PROT_BURN			40
#define TROPHIES_CAP_PROT_OXY			40
#define TROPHIES_CAP_PROT_TOX			40
#define TROPHIES_CAP_PROT_BRAIN			40
#define TROPHIES_CAP_PROT_CLONE			40
#define TROPHIES_CAP_PROT_STAMINA		40

/// Max blood cost reduce for spell.
#define TROPHIES_CAP_BLOOD_REDUCE		50

/// Amount of trophies required for certain passives.
#define TROPHIES_EYES_FLASH				2
#define TROPHIES_EYES_WELDING			4
#define TROPHIES_EYES_XRAY				8
#define TROPHIES_EARS_BANG_PROT			4

/// Suck rate increase per trophy.
#define TROPHIES_SUCK_BONUS		0.2 SECONDS


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * -----------------------------------------------------------HELPERS------------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/mob/living/proc/get_vampire_bonus(damage_type)
	. = 1
	if(!mind || !damage_type)
		return .

	var/datum/antagonist/vampire/vampire = mind.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire)
		return .

	. = vampire.damage_modifiers[damage_type]


/datum/antagonist/vampire/proc/get_trophies(trophie_type)
	var/datum/vampire_subclass/bestia = subclass
	if(!bestia)
		stack_trace("Geting trophies without defined vampire subclass!")

	if(!trophie_type)
		return

	switch(trophie_type)
		if(INTERNAL_ORGAN_HEART)
			return bestia.trophies[INTERNAL_ORGAN_HEART]
		if(INTERNAL_ORGAN_LUNGS)
			return bestia.trophies[INTERNAL_ORGAN_LUNGS]
		if(INTERNAL_ORGAN_LIVER)
			return bestia.trophies[INTERNAL_ORGAN_LIVER]
		if(INTERNAL_ORGAN_KIDNEYS)
			return bestia.trophies[INTERNAL_ORGAN_KIDNEYS]
		if(INTERNAL_ORGAN_EYES)
			return bestia.trophies[INTERNAL_ORGAN_EYES]
		if(INTERNAL_ORGAN_EARS)
			return bestia.trophies[INTERNAL_ORGAN_EARS]
		else
			stack_trace("Invalid trophie type!")


/datum/antagonist/vampire/proc/adjust_trophies(trophie_type, amount)
	var/datum/vampire_subclass/bestia = subclass
	if(!bestia)
		stack_trace("Adjusting trophies without defined vampire subclass!")

	if(!trophie_type || !amount)
		return

	var/update_spells = TRUE
	var/prev_trophies
	var/new_trophies
	var/new_amount
	switch(trophie_type)
		if(INTERNAL_ORGAN_HEART)
			prev_trophies = bestia.trophies[INTERNAL_ORGAN_HEART]
			new_amount = prev_trophies + amount
			new_trophies = clamp(new_amount, 0, MAX_TROPHIES_PER_TYPE_CRITICAL)
			bestia.trophies[INTERNAL_ORGAN_HEART] = new_trophies

			damage_modifiers[BRUTE] = (100 - CEILING((new_trophies * (TROPHIES_CAP_PROT_BRUTE / MAX_TROPHIES_PER_TYPE_CRITICAL)), 1)) / 100
			damage_modifiers[BURN] = (100 - CEILING((new_trophies * (TROPHIES_CAP_PROT_BURN / MAX_TROPHIES_PER_TYPE_CRITICAL)), 1)) / 100

			if((prev_trophies == 0 && new_amount < 0) || (prev_trophies == MAX_TROPHIES_PER_TYPE_CRITICAL && new_amount > MAX_TROPHIES_PER_TYPE_CRITICAL))
				update_spells = FALSE

		if(INTERNAL_ORGAN_LUNGS)
			prev_trophies = bestia.trophies[INTERNAL_ORGAN_LUNGS]
			new_amount = prev_trophies + amount
			new_trophies = clamp(new_amount, 0, MAX_TROPHIES_PER_TYPE_CRITICAL)
			bestia.trophies[INTERNAL_ORGAN_LUNGS] = new_trophies

			damage_modifiers[OXY] = (100 - CEILING((new_trophies * (TROPHIES_CAP_PROT_OXY / MAX_TROPHIES_PER_TYPE_CRITICAL)), 1)) / 100
			damage_modifiers[STAMINA] = (100 - CEILING((new_trophies * (TROPHIES_CAP_PROT_STAMINA / MAX_TROPHIES_PER_TYPE_CRITICAL)), 1)) / 100

			if((prev_trophies == 0 && new_amount < 0) || (prev_trophies == MAX_TROPHIES_PER_TYPE_CRITICAL && new_amount > MAX_TROPHIES_PER_TYPE_CRITICAL))
				update_spells = FALSE

		if(INTERNAL_ORGAN_LIVER)
			prev_trophies = bestia.trophies[INTERNAL_ORGAN_LIVER]
			new_amount = prev_trophies + amount
			new_trophies = clamp(new_amount, 0, MAX_TROPHIES_PER_TYPE_GENERAL)
			bestia.trophies[INTERNAL_ORGAN_LIVER] = new_trophies

			damage_modifiers[TOX] = (100 - (new_trophies * (TROPHIES_CAP_PROT_TOX / MAX_TROPHIES_PER_TYPE_GENERAL))) / 100

			if((prev_trophies == 0 && new_amount < 0) || (prev_trophies == MAX_TROPHIES_PER_TYPE_GENERAL && new_amount > MAX_TROPHIES_PER_TYPE_GENERAL))
				update_spells = FALSE

		if(INTERNAL_ORGAN_KIDNEYS)
			prev_trophies = bestia.trophies[INTERNAL_ORGAN_KIDNEYS]
			new_amount = prev_trophies + amount
			new_trophies = clamp(new_amount, 0, MAX_TROPHIES_PER_TYPE_GENERAL)
			bestia.trophies[INTERNAL_ORGAN_KIDNEYS] = new_trophies

			damage_modifiers[CLONE] = (100 - (new_trophies * (TROPHIES_CAP_PROT_CLONE / MAX_TROPHIES_PER_TYPE_GENERAL))) / 100
			damage_modifiers[BRAIN] = (100 - (new_trophies * (TROPHIES_CAP_PROT_BRAIN / MAX_TROPHIES_PER_TYPE_GENERAL))) / 100

			suck_rate = clamp(BESTIA_SUCK_RATE - (new_trophies * TROPHIES_SUCK_BONUS), 0.1 SECONDS, BESTIA_SUCK_RATE)

			if((prev_trophies == 0 && new_amount < 0) || (prev_trophies == MAX_TROPHIES_PER_TYPE_GENERAL && new_amount > MAX_TROPHIES_PER_TYPE_GENERAL))
				update_spells = FALSE

		if(INTERNAL_ORGAN_EYES)
			prev_trophies = bestia.trophies[INTERNAL_ORGAN_EYES]
			new_amount = prev_trophies + amount
			bestia.trophies[INTERNAL_ORGAN_EYES] = clamp(new_amount, 0, MAX_TROPHIES_PER_TYPE_GENERAL)

			if((prev_trophies == 0 && new_amount < 0) || (prev_trophies == MAX_TROPHIES_PER_TYPE_GENERAL && new_amount > MAX_TROPHIES_PER_TYPE_GENERAL))
				update_spells = FALSE

		if(INTERNAL_ORGAN_EARS)
			prev_trophies = bestia.trophies[INTERNAL_ORGAN_EARS]
			new_amount = prev_trophies + amount
			bestia.trophies[INTERNAL_ORGAN_EARS] = clamp(new_amount, 0, MAX_TROPHIES_PER_TYPE_GENERAL)

			if((prev_trophies == 0 && new_amount < 0) || (prev_trophies == MAX_TROPHIES_PER_TYPE_GENERAL && new_amount > MAX_TROPHIES_PER_TYPE_GENERAL))
				update_spells = FALSE

		else
			stack_trace("Invalid trophie type!")

	if(update_spells)
		check_vampire_upgrade()
		var/list/all_spells = owner.spell_list + owner.current.mob_spell_list
		for(var/obj/effect/proc_holder/spell/vampire/spell in all_spells)
			spell.on_trophie_update(src, trophie_type)


/obj/effect/proc_holder/spell/vampire/proc/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)


/obj/effect/proc_holder/spell/vampire/proc/do_blood_discount(datum/antagonist/vampire/vampire)
	var/livers_amount = vampire.get_trophies(INTERNAL_ORGAN_LIVER)
	var/blood_cost_init = initial(required_blood)
	var/blood_adjust = livers_amount * (TROPHIES_CAP_BLOOD_REDUCE / MAX_TROPHIES_PER_TYPE_GENERAL)
	required_blood = blood_cost_init - blood_adjust
	QDEL_NULL(custom_handler)
	custom_handler = create_new_handler()
	update_vampire_spell_name()
	if(blood_cost_init - TROPHIES_CAP_BLOOD_REDUCE < 0)
		stack_trace("Bestia Vampire spell [src] has initial cost below [TROPHIES_CAP_BLOOD_REDUCE]!")


/proc/is_vampire_compatible(mob/living/victim, include_dead = FALSE, only_human = FALSE, include_IPC = FALSE, blood_required = FALSE)
	if(!istype(victim))
		return FALSE
	if(only_human && !ishuman(victim))
		return FALSE
	if(!include_IPC && ismachineperson(victim))
		return FALSE
	if(!include_dead && victim.stat == DEAD)
		return FALSE
	if(blood_required && ishuman(victim) && (HAS_TRAIT(victim, TRAIT_NO_BLOOD) || HAS_TRAIT(victim, TRAIT_EXOTIC_BLOOD)))
		return FALSE
	if(issilicon(victim) || isbot(victim) || isswarmer(victim) || isguardian(victim))
		return FALSE
	return TRUE


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * -------------------------------------------------------BESTIA PASSIVES--------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/datum/antagonist/vampire/proc/check_trophies_passives()
	var/t_ears = get_trophies(INTERNAL_ORGAN_EARS)
	var/t_eyes = get_trophies(INTERNAL_ORGAN_EYES)

	if(t_ears >= TROPHIES_EARS_BANG_PROT)
		add_ability(/datum/vampire_passive/ears_bang_protection)

	if(t_eyes >= TROPHIES_EYES_FLASH)
		add_ability(/datum/vampire_passive/eyes_flash_protection)

	if(t_eyes >= TROPHIES_EYES_WELDING)
		add_ability(/datum/vampire_passive/eyes_welding_protection)

	if(t_eyes >= TROPHIES_EYES_XRAY)
		add_ability(/datum/vampire_passive/xray)


/datum/vampire_passive/ears_bang_protection
	gain_desc = "Ваши барабанные перепонки стали прочнее. Вы можете не обращать внимания на высокочастотные звуки."


/datum/vampire_passive/eyes_flash_protection
	gain_desc = "Роговицы ваших глаз адаптировались к ярким вспышкам."


/datum/vampire_passive/eyes_welding_protection
	gain_desc = "Ваши глаза напитались силой собранных трофеев - теперь они невосприимчивы к воздействию яркого света."


/datum/vampire_passive/upgraded_grab
	gain_desc = "Ваши мышцы наполняются силой поглощённой крови - жертвам будет труднее вырваться из захвата."
	/// Time (in deciseconds) required to reinforce aggressive/neck grab to the next state.
	var/grab_speed = 2 SECONDS
	/// Resist chance overrides for the victim.
	var/list/grab_resist_chances = list(
		MARTIAL_GRAB_AGGRESSIVE = 40,
		MARTIAL_GRAB_NECK = 10,
		MARTIAL_GRAB_KILL = 5,
	)


/datum/antagonist/vampire/proc/grab_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/old_grab_state = user.grab_state
	var/grab_success = target.grabbedby(user, supress_message = TRUE)
	if(grab_success && old_grab_state == GRAB_PASSIVE)
		target.grippedby(user) // instant aggressive grab
		add_attack_logs(user, target, "Melee attacked with vampire upgraded grab: aggressively grabbed", ATKLOG_ALL)
	return TRUE


/datum/vampire_passive/dissection_cap/on_apply(datum/antagonist/vampire/vampire)
	vampire.subclass.dissect_cap++
	vampire.subclass.crit_organ_cap += 2
	gain_desc = "Теперь вы можете извлекать ещё один орган у одной и той же жертвы, но не более чем <b>[vampire.subclass.dissect_cap]</b>. Помимо того, новый предел для извлечения критических органов - <b>[vampire.subclass.crit_organ_cap]</b>."


/datum/vampire_passive/dissection_cap/two


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * -----------------------------------------------------------DISSECT------------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/self/dissect
	name = "Препарирование"
	desc = "Точный удар, вырывающий внутренний орган из тела жертвы. Жертва должна быть жива и удерживаться в агрессивном захвате. Органы используются в качестве трофеев, которые пассивно улучшают ваши способности."
	gain_desc = "Теперь вы можете собирать внутренние органы своих жертв, чтобы становиться сильнее."
	action_icon_state = "vampire_claws"
	create_attack_logs = FALSE
	base_cooldown = 5 SECONDS
	required_blood = 10
	deduct_blood_on_cast = FALSE
	var/is_dissecting = FALSE
	var/static/list/vampire_dissect_organs = list(
		INTERNAL_ORGAN_HEART,
		INTERNAL_ORGAN_LUNGS,
		INTERNAL_ORGAN_LIVER,
		INTERNAL_ORGAN_KIDNEYS,
		INTERNAL_ORGAN_EYES,
		INTERNAL_ORGAN_EARS,
	)


/obj/effect/proc_holder/spell/vampire/self/dissect/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!special_check(user, show_message))
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/vampire/self/dissect/proc/special_check(mob/living/user, show_message, ignore_dissect = FALSE)
	if(is_dissecting && !ignore_dissect)
		return FALSE

	if(!user.pulling || user.pull_hand != user.hand)
		if(show_message)
			balloon_alert(user, "удерживающая рука не выбрана!")
		return FALSE

	if(user.grab_state < GRAB_NECK)
		if(show_message)
			balloon_alert(user, "требуется крепкий захват!")
		return FALSE

	var/mob/living/carbon/human/target = user.pulling
	if(!ishuman(target) || is_monkeybasic(target) || ismachineperson(target) || target.stat == DEAD || !target.mind || !target.ckey)
		if(show_message)
			balloon_alert(user, "цель не подходит!")
		return FALSE

	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire.subclass)
		return FALSE

	var/unique_dissect_id = target.UID()
	if((unique_dissect_id in vampire.dissected_humans) && vampire.dissected_humans[unique_dissect_id] >= vampire.subclass.dissect_cap)
		if(show_message)
			balloon_alert(user, "цель уже препарирована!")
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/vampire/self/dissect/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = user.pulling
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/t_hearts = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	var/t_lungs = vampire.get_trophies(INTERNAL_ORGAN_LUNGS)
	var/t_livers = vampire.get_trophies(INTERNAL_ORGAN_LIVER)
	var/t_kidneys = vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS)
	var/t_eyes = vampire.get_trophies(INTERNAL_ORGAN_EYES)
	var/t_ears = vampire.get_trophies(INTERNAL_ORGAN_EARS)
	var/list/all_organs = list()

	for(var/obj/item/organ/internal/organ as anything in target.internal_organs)
		if(!(organ.slot in vampire_dissect_organs) || organ.is_robotic())
			continue
		if(istype(organ, /obj/item/organ/internal/heart) && \
			(t_hearts >= vampire.subclass.crit_organ_cap || t_hearts >= MAX_TROPHIES_PER_TYPE_CRITICAL))
			continue
		if(istype(organ, /obj/item/organ/internal/lungs) && \
			(t_lungs >= vampire.subclass.crit_organ_cap || t_lungs >= MAX_TROPHIES_PER_TYPE_CRITICAL))
			continue
		if(istype(organ, /obj/item/organ/internal/liver) && t_livers >= MAX_TROPHIES_PER_TYPE_GENERAL)
			continue
		if(istype(organ, /obj/item/organ/internal/kidneys) && t_kidneys >= MAX_TROPHIES_PER_TYPE_GENERAL)
			continue
		if(istype(organ, /obj/item/organ/internal/eyes) && t_eyes >= MAX_TROPHIES_PER_TYPE_GENERAL)
			continue
		if(istype(organ, /obj/item/organ/internal/ears) && t_ears >= MAX_TROPHIES_PER_TYPE_GENERAL)
			continue

		all_organs += organ

	if(!length(all_organs))
		balloon_alert(user, "у цели нет допустимых органов!")
		return

	for(var/obj/item/organ/internal/organ as anything in all_organs)
		all_organs -= organ
		all_organs[organ.slot] = organ

	var/obj/item/organ/internal/organ_to_dissect = input("Выберите орган для извлечения:", "Извлечения органа", null, null) as null|anything in all_organs
	if(!organ_to_dissect || !special_check(user, TRUE))
		return

	organ_to_dissect = all_organs[organ_to_dissect]
	var/organ_name = organ_to_dissect.name
	is_dissecting = TRUE

	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				to_chat(user, span_notice("Эта жертва вам подойдёт. Стойте неподвижно..."))

			if(2)
				user.visible_message(span_warning("[user] выпуска[pluralize_ru(user.gender, "ет", "ют")] когти из пальцев!"), \
									span_notice("Вы вытягиваете из пальцев когти."))

			if(3)
				user.visible_message(span_danger("[user] пронза[pluralize_ru(user.gender, "ет", "ют")] когтями [target]!"), \
									span_notice("Вы пронзаете [target] когтями и начинаете процесс вскрытия..."))
				to_chat(target, span_danger("Вы чувствуете острую колющую боль!"))
				target.take_overall_damage(30)
				add_attack_logs(user, target, "Vampire dissection. BRUTE: 30. Skill: [src]")

		if(!do_after(user, 5 SECONDS, target, NONE) || !special_check(user, TRUE, TRUE))
			to_chat(user, span_warning("Процесс вскрытия [target] был прерван!"))
			is_dissecting = FALSE
			return

	is_dissecting = FALSE

	if(!organ_to_dissect)	// organ is magically disappered, what a shame!
		to_chat(user, span_warning("Наша жертва каким-то образом лишилась выбранного органа!"))
		return

	if(target.stat == DEAD)	// grip was too strong mr. vampire
		to_chat(user, span_warning("[target] [genderize_ru(target, "мёртв", "мертва", "мертво", "мертвы")] и больше не [genderize_ru(target, "пригоден", "пригодна", "пригодно", "пригодны")] для вскрытия."))
		return

	var/datum/spell_handler/vampire/handler = custom_handler
	var/blood_cost = handler.calculate_blood_cost(vampire)
	vampire.bloodusable -= blood_cost

	var/obj/item/thing = organ_to_dissect.remove(target)
	qdel(thing)
	target.vomit(50, VOMIT_BLOOD, 0 SECONDS)
	if(target.has_pain())
		target.emote("scream")

	var/unique_dissect_id = target.UID()
	if(!(unique_dissect_id in vampire.dissected_humans))
		vampire.dissected_humans[unique_dissect_id] = 0
	vampire.dissected_humans[unique_dissect_id] += 1

	var/msg
	switch(organ_to_dissect.slot)
		if(INTERNAL_ORGAN_HEART)
			vampire.adjust_trophies(INTERNAL_ORGAN_HEART, 1)
			if(vampire.get_trophies(INTERNAL_ORGAN_HEART) >= MAX_TROPHIES_PER_TYPE_CRITICAL)
				msg = "сердец"
			else if(vampire.get_trophies(INTERNAL_ORGAN_HEART) >= vampire.subclass.crit_organ_cap)
				to_chat(user, span_warning("Мы достигли предела в извлечении критических органов типа <b>сердце</b>!"))
		if(INTERNAL_ORGAN_LUNGS)
			vampire.adjust_trophies(INTERNAL_ORGAN_LUNGS, 1)
			if(vampire.get_trophies(INTERNAL_ORGAN_LUNGS) >= MAX_TROPHIES_PER_TYPE_CRITICAL)
				msg = "лёгких"
			else if(vampire.get_trophies(INTERNAL_ORGAN_LUNGS) >= vampire.subclass.crit_organ_cap)
				to_chat(user, span_warning("Мы достигли предела в извлечении критических органов типа <b>лёгкие</b>!"))
		if(INTERNAL_ORGAN_LIVER)
			vampire.adjust_trophies(INTERNAL_ORGAN_LIVER, 1)
			if(vampire.get_trophies(INTERNAL_ORGAN_LIVER) >= MAX_TROPHIES_PER_TYPE_GENERAL)
				msg = "печени"
		if(INTERNAL_ORGAN_KIDNEYS)
			vampire.adjust_trophies(INTERNAL_ORGAN_KIDNEYS, 1)
			if(vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS) >= MAX_TROPHIES_PER_TYPE_GENERAL)
				msg = "почек"
		if(INTERNAL_ORGAN_EYES)
			vampire.adjust_trophies(INTERNAL_ORGAN_EYES, 1)
			if(vampire.get_trophies(INTERNAL_ORGAN_EYES) >= MAX_TROPHIES_PER_TYPE_GENERAL)
				msg = "глаз"
		if(INTERNAL_ORGAN_EARS)
			vampire.adjust_trophies(INTERNAL_ORGAN_EARS, 1)
			if(vampire.get_trophies(INTERNAL_ORGAN_EARS) >= MAX_TROPHIES_PER_TYPE_GENERAL)
				msg = "ушей"

	if(msg)
		to_chat(user, span_warning("Мы достигли максимально возможного количества <b>[msg]</b> для сбора!"))

	user.visible_message(span_danger("[user] вырыва[pluralize_ru(user, "ет", "ют")] [organ_name] из тела [target]!"),
						span_notice("Вы вырываете <b>[organ_name]</b> из тела [target]."))
	add_attack_logs(user, target, "Vampire removed [organ_name]. Skill: [src]")


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * --------------------------------------------------------CHECK TROPHIES--------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/self/dissect_info
	name = "Посмотреть трофеи"
	desc = "Позволяет узнать количество собранных органов и пассивные способности, которые вы за них получили."
	gain_desc = "Теперь вы можете использовать способность <b>«Посмотреть трофеи»</b>, чтобы отслеживать свой прогресс."
	action_icon_state = "blood_rush"
	human_req = FALSE
	stat_allowed = UNCONSCIOUS
	create_attack_logs = FALSE
	base_cooldown = 1 SECONDS


/obj/effect/proc_holder/spell/vampire/self/dissect_info/can_cast(mob/living/carbon/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.stat == DEAD)
		if(show_message)
			balloon_alert(user, "вы мертвы!")
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/self/dissect_info/cast(list/targets, mob/user = usr)
	ui_interact(user)

/obj/effect/proc_holder/spell/vampire/self/dissect_info/ui_state(mob/user)
	return GLOB.always_state

/obj/effect/proc_holder/spell/vampire/self/dissect_info/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VampireTrophiesStatus", "Посмотреть трофеи")
		ui.set_autoupdate(FALSE)
		ui.open()


/obj/effect/proc_holder/spell/vampire/self/dissect_info/ui_static_data(mob/user)
	var/list/data = list()
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)

	data["organs_icon"] = 'icons/obj/surgery.dmi'
	data["icon_hearts"] = "heart-off"
	data["icon_lungs"] = "lungs"
	data["icon_livers"] = "liver"
	data["icon_kidneys"] = "kidneys"
	data["icon_eyes"] = "eyes"
	data["icon_ears"] = "ears"

	data["trophies_max_gen"] = MAX_TROPHIES_PER_TYPE_GENERAL
	data["trophies_max_crit"] = MAX_TROPHIES_PER_TYPE_CRITICAL
	data["trophies_brute"] = TROPHIES_CAP_PROT_BRUTE
	data["trophies_burn"] = TROPHIES_CAP_PROT_BURN
	data["trophies_oxy"] = TROPHIES_CAP_PROT_OXY
	data["trophies_tox"] = TROPHIES_CAP_PROT_TOX
	data["trophies_brain"] = TROPHIES_CAP_PROT_BRAIN
	data["trophies_clone"] = TROPHIES_CAP_PROT_CLONE
	data["trophies_stamina"] = TROPHIES_CAP_PROT_STAMINA

	data["trophies_blood"] = TROPHIES_CAP_BLOOD_REDUCE

	data["trophies_flash"] = TROPHIES_EYES_FLASH
	data["trophies_welding"] = TROPHIES_EYES_WELDING
	data["trophies_xray"] = TROPHIES_EYES_XRAY
	data["trophies_bang"] = TROPHIES_EARS_BANG_PROT

	data["hearts"] = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	data["lungs"] = vampire.get_trophies(INTERNAL_ORGAN_LUNGS)
	data["livers"] = vampire.get_trophies(INTERNAL_ORGAN_LIVER)
	data["kidneys"] = vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS)
	data["eyes"] = vampire.get_trophies(INTERNAL_ORGAN_EYES)
	data["ears"] = vampire.get_trophies(INTERNAL_ORGAN_EARS)

	data["suck_rate"] = vampire.suck_rate / 10
	data["full_power"] = vampire.get_ability(/datum/vampire_passive/full)

	return data


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * ------------------------------------------------------INFECTED TROPHY---------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/self/infected_trophy
	name = "Заражённый трофей"
	desc = "Призывает деформированный череп, заражающий жертву могильной лихорадкой. Чем больше трофеев вы собрали, тем сильнее будут эффекты."
	gain_desc = "Теперь вы можете заражать жертв могильной лихорадкой. Чем больше вы собрали трофеев, тем сильнее будут эффекты."
	action_icon_state = "infected_trophy"
	base_cooldown = 10 SECONDS
	required_blood = 60
	deduct_blood_on_cast = FALSE


/obj/effect/proc_holder/spell/vampire/self/infected_trophy/can_cast(mob/living/carbon/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incapacitated(INC_IGNORE_GRABBED))
		if(show_message)
			balloon_alert(user, "нельзя использовать сейчас!")
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/self/infected_trophy/cast(list/targets, mob/living/user = usr)
	if(user.get_active_hand())
		balloon_alert(user, "рука занята!")
		revert_cast()
		return FALSE

	var/obj/item/gun/magic/skull_gun/skull_gun = new(null, src)
	user.put_in_active_hand(skull_gun)


/obj/effect/proc_holder/spell/vampire/self/infected_trophy/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)
	if(trophie_type == INTERNAL_ORGAN_LIVER || force)
		do_blood_discount(vampire)


/**
 * SKULL GUN!
 */
/obj/item/gun/magic/skull_gun
	name = "infected skull"
	desc = "Деформированный череп, передающий могильную лихорадку."
	ru_names = list(
        NOMINATIVE = "заражённый череп",
        GENITIVE = "заражённого черепа",
        DATIVE = "заражённому черепу",
        ACCUSATIVE = "заражённый череп",
        INSTRUMENTAL = "заражённым черепом",
        PREPOSITIONAL = "заражённом черепе"
    )
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ashen_skull"
	item_state = "ashen_skull"
	item_flags = ABSTRACT|NOBLUDGEON|DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	fire_sound = 'sound/effects/pierce.ogg'
	ammo_type = /obj/item/ammo_casing/magic/skull_gun_casing
	force = 0
	slot_flags = NONE
	max_charges = 1
	recharge_rate = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/obj/effect/proc_holder/spell/vampire/self/infected_trophy/parent_spell


/obj/item/gun/magic/skull_gun/Initialize(mapload, spell)
	. = ..()
	parent_spell = spell


/obj/item/gun/magic/skull_gun/Destroy()
	parent_spell = null
	return ..()


/obj/item/gun/magic/skull_gun/equip_to_best_slot(mob/user, force = FALSE, drop_on_fail = FALSE, qdel_on_fail = FALSE)
	parent_spell?.revert_cast()
	qdel(src)


/obj/item/gun/magic/skull_gun/run_drop_held_item(mob/user)
	parent_spell?.revert_cast()
	qdel(src)


/obj/item/ammo_casing/magic/skull_gun_casing
	name = "skull gun casing"
	desc = "Что это за..."
	ru_names = list(
    NOMINATIVE = "гильза для черепного пистолета",
    GENITIVE = "гильзы для черепного пистолета",
    DATIVE = "гильзе для черепного пистолета",
    ACCUSATIVE = "гильзу для черепного пистолета",
    INSTRUMENTAL = "гильзой для черепного пистолета",
    PREPOSITIONAL = "гильзе для черепного пистолета"
	)
	icon_state = "skulls"
	projectile_type = /obj/projectile/skull_projectile
	muzzle_flash_effect = null
	caliber = "skulls"


/obj/projectile/skull_projectile
	name = "infected skull"
	ru_names = list(
        NOMINATIVE = "заражённый череп",
        GENITIVE = "заражённого черепа",
        DATIVE = "заражённому черепу",
        ACCUSATIVE = "заражённый череп",
        INSTRUMENTAL = "заражённым черепом",
        PREPOSITIONAL = "заражённом черепе"
    )
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ashen_skull"
	pass_flags = PASSTABLE | PASSGRILLE | PASSFENCE
	speed = 1
	range = 5
	damage = 5
	armour_penetration = 100
	damage_type = BRUTE
	hitsound = null


/obj/projectile/skull_projectile/Destroy()
	QDEL_NULL(chain)
	return ..()


/obj/projectile/skull_projectile/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "sendbeam", time = INFINITY, maxdistance = INFINITY)

		var/obj/item/gun/magic/skull_gun/skull_gun = locate() in firer
		if(skull_gun)
			qdel(skull_gun)

		var/datum/antagonist/vampire/vampire = firer.mind?.has_antag_datum(/datum/antagonist/vampire)
		var/obj/effect/proc_holder/spell/vampire/self/infected_trophy/infected_trophy = locate() in firer.mind?.spell_list
		if(vampire && infected_trophy)
			range += vampire.get_trophies(INTERNAL_ORGAN_EYES) 	// 15 MAX
			var/datum/spell_handler/vampire/handler = infected_trophy.custom_handler
			var/blood_cost = handler.calculate_blood_cost(vampire)
			vampire.bloodusable -= blood_cost

	return ..()


/obj/projectile/skull_projectile/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	var/datum/antagonist/vampire/vampire = firer?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire || QDELETED(vampire.subclass))
		return

	var/t_hearts = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	var/applied_damage = t_hearts * 5	// 30 MAX
	var/stun_amt = (t_hearts / 2) SECONDS	// 3s. MAX
	var/effect_aoe = round(vampire.get_trophies(INTERNAL_ORGAN_EARS) / 4)	// 2 MAX

	for(var/mob/living/victim in view(effect_aoe, get_turf(target)))
		if(victim.loc == firer)	// yeah apparently mobs can see what is inside them
			continue
		if(!victim.affects_vampire(firer))
			continue
		if(!is_vampire_compatible(victim, include_IPC = TRUE))
			continue

		victim.apply_damage(applied_damage, BRUTE, BODY_ZONE_CHEST)
		victim.Stun(stun_amt)
		to_chat(victim, span_userdanger("Вы почувствовали боль в груди!"))

		if(iscarbon(victim))
			var/mob/living/carbon/c_victim = victim
			c_victim.vomit(50, VOMIT_BLOOD, 0 SECONDS)

		if(prob(10 + vampire.get_trophies(INTERNAL_ORGAN_LIVER) * 3))
			new /obj/effect/temp_visual/cult/sparks(get_turf(victim))
			var/datum/disease/vampire/D = new
			D.Contract(victim)	// grave fever


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * -----------------------------------------------------------LUNGE--------------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/lunge
	name = "Рывок"
	desc = "Стремительный рывок в указанное место. Чем больше трофеев вы собрали, тем сильнее будут эффекты."
	gain_desc = "Теперь вы можете делать рывок вперёд, быстро преодолевая расстояние. В зависимости от количества собранных трофеев будут применяться определённые эффекты."
	action_icon_state = "vampire_charge"
	need_active_overlay = TRUE
	human_req = FALSE
	base_cooldown = 15 SECONDS
	required_blood = 55
	var/bonus_range = 0
	var/blood_victim_lose = 0
	var/effect_aoe = 0


/obj/effect/proc_holder/spell/vampire/lunge/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/T = new()
	var/new_range = 5 + bonus_range
	T.range = new_range
	return T


/obj/effect/proc_holder/spell/vampire/lunge/can_cast(mob/living/carbon/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incapacitated(INC_IGNORE_RESTRAINED|INC_IGNORE_GRABBED) || user.buckled || (iscarbon(user) && user.legcuffed))
		if(show_message)
			balloon_alert(user, "нельзя использовать сейчас!")
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/lunge/cast(list/targets, mob/living/user = usr)
	var/target = targets[1]

	user.stop_pulling()
	user.unbuckle_all_mobs(TRUE)
	user.buckled?.unbuckle_mob(user, TRUE)
	user.pulledby?.stop_pulling()

	user.visible_message(span_danger("[user] начина[pluralize_ru(user.gender, "ет", "ют")] двигаться с неестественной скоростью!"), \
						span_notice("Вы бросаетесь в сторону..."))

	var/leap_range = targeting.range

	var/distance = get_dist(user, target)
	if(distance < leap_range)
		leap_range = distance + 1

	user.layer = LOW_LANDMARK_LAYER
	user.pass_flags |= (PASSTABLE|PASSGRILLE|PASSFENCE|PASSMOB)
	user.add_traits(list(TRAIT_MOVE_FLYING, TRAIT_IMMOBILIZED), SPELL_LUNGE_TRAIT)

	var/dir_switch = FALSE
	var/matrix/old_transform = user.transform
	for(var/i in 1 to leap_range)
		if(QDELETED(user))
			return

		var/direction = get_dir(user, target)
		var/turf/next_step = get_step(user, direction)
		user.face_atom(target)

		if(next_step.is_blocked_turf(source_atom = user))
			break

		user.forceMove(next_step)

		var/old_x = user.pixel_x
		var/old_y = user.pixel_y
		var/from_x = user.pixel_x
		var/from_y = user.pixel_y
		var/pixel_shift = rand(24, 32)
		if(direction & (NORTH|SOUTH))
			from_x = dir_switch ? pixel_shift : -pixel_shift
		if(direction & (EAST|WEST))
			from_y = dir_switch ? pixel_shift : -pixel_shift
		if(!direction)
			pixel_shift = rand(8, 12)
			from_y = pixel_shift

		var/matrix/animation_matrix = new(old_transform)
		animation_matrix.Turn(dir_switch ? 10 : -10)
		dir_switch = !dir_switch

		animate(user, time = 0.05 SECONDS, pixel_x = from_x, pixel_y = from_y, transform = animation_matrix, easing = CUBIC_EASING)
		animate(time = 0.05 SECONDS, pixel_x = old_x, pixel_y = old_y, transform = old_transform)

		playsound(next_step, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
		sleep(0.1 SECONDS)

	if(QDELETED(user))
		return

	user.layer = initial(user.layer)
	user.pixel_y = initial(user.pixel_y)
	user.pixel_y = initial(user.pixel_x)
	user.transform = initial(user.transform)
	user.pass_flags &= ~(PASSTABLE|PASSGRILLE|PASSFENCE|PASSMOB)
	user.remove_traits(list(TRAIT_MOVE_FLYING, TRAIT_IMMOBILIZED), SPELL_LUNGE_TRAIT)

	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire)
		return

	var/blood_gained = 0
	var/t_hearts = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	var/t_kidneys = vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS)
	var/confusion_amt = (t_kidneys * 2) SECONDS		// 20s. MAX
	var/weaken_amt = 1 + (t_hearts / 2) SECONDS		// 4s. MAX
	var/blood_vamp_get = t_kidneys					// +10 vampire blood MAX
	var/actual_blood_loss = blood_victim_lose ? blood_victim_lose : t_kidneys * 10	// 100 bloodlose MAX
	var/actual_aoe = effect_aoe ? effect_aoe : 1 + round(vampire.get_trophies(INTERNAL_ORGAN_EARS) / 5)	// 3 MAX

	for(var/mob/living/victim in view(actual_aoe, get_turf(user)))
		if(victim.loc == user)	// yeah apparently mobs can see what is inside them
			continue
		if(!victim.affects_vampire(user))
			continue
		if(!is_vampire_compatible(victim, include_IPC = TRUE))
			continue

		if(weaken_amt)
			victim.Weaken(weaken_amt)
			user.do_item_attack_animation(victim, ATTACK_EFFECT_CLAW)
			playsound(victim.loc, 'sound/weapons/slice.ogg', 40, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			to_chat(victim, span_userdanger("Вы не можете устоять перед внезапным порывом ветра, который швыряет вас на пол!"))

		if(t_kidneys > 0 && ishuman(victim))
			var/mob/living/carbon/human/h_victim = victim
			if(HAS_TRAIT(h_victim, TRAIT_NO_BLOOD))
				continue

			h_victim.bleed(actual_blood_loss)
			h_victim.Confused(confusion_amt)
			h_victim.emote("moan")
			to_chat(h_victim, span_userdanger("Вы чувствуете острую боль и внезапно ощущаете сильную слабость!"))

			if(h_victim.mind && h_victim.ckey && !HAS_TRAIT(h_victim, TRAIT_EXOTIC_BLOOD))
				blood_gained += blood_vamp_get
				vampire.adjust_blood(h_victim, blood_vamp_get)

	if(blood_gained)
		to_chat(user, span_notice("Вы пережимаете артерии жертвы на лету и поглощаете <b>[blood_gained]</b> единиц[declension_ru(blood_gained, "у", "ы", "")] крови!"))


/obj/effect/proc_holder/spell/vampire/lunge/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)
	if(trophie_type == INTERNAL_ORGAN_LUNGS || force)
		var/lungs_amount = vampire.get_trophies(INTERNAL_ORGAN_LUNGS)
		bonus_range = lungs_amount	// +6 MAX
		QDEL_NULL(targeting)
		targeting = create_new_targeting()

	if(trophie_type == INTERNAL_ORGAN_LIVER || force)
		do_blood_discount(vampire)


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * --------------------------------------------------------MARK THE PREY---------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/mark
	name = "Пометить добычу"
	desc = "Пометьте свою жертву, чтобы замедлить её передвижение, уменьшить сопротивление и заставить её совершать спонтанные действия."
	gain_desc = "Вы получили возможность помечать своих жертв. Различные дополнительные эффекты применяются в зависимости от собранных трофеев."
	action_icon_state = "predator_sense"
	need_active_overlay = TRUE
	human_req = FALSE
	base_cooldown = 15 SECONDS
	required_blood = 55
	var/range = 3


/obj/effect/proc_holder/spell/vampire/mark/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living
	T.range = range
	T.click_radius = 0
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/vampire/mark/valid_target(mob/living/target, user)
	return target.affects_vampire(user) && is_vampire_compatible(target, include_IPC = TRUE)


/obj/effect/proc_holder/spell/vampire/mark/cast(list/targets, mob/living/user = usr)
	var/mob/living/target = targets[1]
	var/datum/antagonist/vampire/vampire = user.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire || !vampire.subclass)
		return
	target.apply_status_effect(STATUS_EFFECT_MARK_PREY, vampire)


/obj/effect/proc_holder/spell/vampire/mark/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)
	if(trophie_type == INTERNAL_ORGAN_EYES || force)
		var/eyes_amount = vampire.get_trophies(INTERNAL_ORGAN_EYES)
		range = initial(range) + round(eyes_amount / 2)	// 8 MAX
		QDEL_NULL(targeting)
		targeting = create_new_targeting()

	if(trophie_type == INTERNAL_ORGAN_LIVER || force)
		do_blood_discount(vampire)


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * --------------------------------------------------------METAMORPHOSIS---------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/metamorphosis
	name = "Метаморфоза"
	desc = "Преобразуйтесь и сообщите об этом!"
	gain_desc = "Вы получили возможность быстро сообщить об этом в баг-репорт в Discord."
	action_icon_state = "default"
	sound = 'sound/creatures/wings_flapping.ogg'
	human_req = FALSE
	base_cooldown = 30 SECONDS
	var/sound_on_transform
	var/free_transform_back = FALSE
	var/prev_blood_cost = 0
	var/is_transformed = FALSE
	var/mob/living/carbon/human/original_body
	var/meta_path = /mob/living/simple_animal/hostile/vampire


/obj/effect/proc_holder/spell/vampire/metamorphosis/Destroy()
	original_body = null
	return ..()


/obj/effect/proc_holder/spell/vampire/metamorphosis/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/vampire/metamorphosis/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!ispath(meta_path))
		stack_trace("Bad path in vampire spell [src]!")
		return FALSE

	if(!original_body && is_transformed)
		stack_trace("No original body in vampire spell [src]!")
		return FALSE

	if(!user.mind)
		return

	for(var/obj/effect/proc_holder/spell/vampire/metamorphosis/spell in (user.mind.spell_list - src))
		if(spell?.is_transformed)
			if(show_message)
				balloon_alert(user, "метаморфоза уже используется!")
			return FALSE

	if(user.incapacitated(INC_IGNORE_RESTRAINED|INC_IGNORE_GRABBED))
		if(show_message)
			balloon_alert(user, "нельзя использовать сейчас!")
		return FALSE

	if(ishuman(user) && user.health <= 0)
		if(show_message)
			balloon_alert(user, "вы слишком слабы!")
		return FALSE

	if(!isturf(user.loc))
		if(show_message)
			balloon_alert(user, "нельзя использовать внутри!")
		return FALSE

	return ..()


/obj/effect/proc_holder/spell/vampire/metamorphosis/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!is_transformed && istype(user))
		meta_transform(user)
	else if(is_transformed && original_body)
		meta_transform_back(user)


/obj/effect/proc_holder/spell/vampire/metamorphosis/proc/meta_transform(mob/living/carbon/human/user)
	var/list/restraints = list()
	if(user.handcuffed)
		restraints += user.handcuffed
	if(user.legcuffed)
		restraints += user.legcuffed
	if(user.wear_suit?.breakouttime)
		restraints += user.wear_suit

	for(var/obj/item/thing as anything in restraints)
		user.drop_item_ground(thing, force = TRUE)

	if(free_transform_back)
		prev_blood_cost = required_blood
		required_blood = 0
		QDEL_NULL(custom_handler)
		custom_handler = create_new_handler()
		update_vampire_spell_name()

	new /obj/effect/temp_visual/vamp_mist_out(get_turf(user))
	if(sound_on_transform)
		playsound(user.loc, sound_on_transform, 100, TRUE)


	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/mob/living/simple_animal/hostile/vampire/vampire_animal = new meta_path(user.loc, vampire, user, src)

	user.visible_message(span_warning("Форма [user] становится размытой, прежде чем [genderize_ru(user.gender, "он", "она", "оно", "они")] принима[pluralize_ru(user.gender, "ет", "ют")] форму [vampire_animal]!"), \
						span_notice("Вы начинаете превращаться в [vampire_animal]."), \
						span_italics("Вы слышите жуткий шум множества крыльев..."))

	vampire.stop_sucking()
	original_body = user
	original_body.add_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	vampire_animal.add_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	user.forceMove(vampire_animal)
	user.mind.transfer_to(vampire_animal)
	vampire.draw_HUD()

	var/matrix/animation_matrix = new(vampire_animal.transform)
	vampire_animal.transform = matrix().Scale(0)
	animate(vampire_animal, time = 1 SECONDS, transform = animation_matrix, easing = CUBIC_EASING)

	sleep(1 SECONDS)

	if(QDELETED(src) || QDELETED(vampire_animal))
		return

	vampire_animal.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	is_transformed = TRUE
	var/list/all_spells = vampire_animal.mind.spell_list + vampire_animal.mob_spell_list
	for(var/obj/effect/proc_holder/spell/vampire/spell in all_spells)
		spell.updateButtonIcon()


/obj/effect/proc_holder/spell/vampire/metamorphosis/proc/meta_transform_back(mob/living/simple_animal/hostile/vampire/user, death_provoked = FALSE)
	if(free_transform_back)
		required_blood = prev_blood_cost
		QDEL_NULL(custom_handler)
		custom_handler = create_new_handler()
		update_vampire_spell_name()

	var/self_message = death_provoked ? span_userdanger("В таком состоянии вы не сможете поддерживать форму, она начнёт рассыпаться!") : span_notice("Вы начинаете превращаться обратно в первоначальную форму.")
	user.visible_message(span_warning("Форма [user] становится нечёткой, прежде чем [genderize_ru(user.gender, "он", "она", "оно", "они")] прим[pluralize_ru(user.gender, "ет", "ут")] первоначальный облик!"), self_message, span_italics("Вы слышите жуткий шум множества крыльев..."))

	user.set_density(FALSE)
	original_body.dir = SOUTH
	original_body.forceMove(user.loc)
	user.mind.transfer_to(original_body)
	var/datum/antagonist/vampire/vampire = original_body.mind?.has_antag_datum(/datum/antagonist/vampire)
	vampire?.draw_HUD()

	var/obj/effect/temp_visual/vamp_mist_out/effect = new(user.loc)
	effect.alpha = 0
	animate(effect, time = 0.2 SECONDS, alpha = 255)

	var/matrix/animation_matrix1 = new(user.transform)
	animation_matrix1.Scale(0)
	animate(user, time = 0.5 SECONDS, transform = animation_matrix1, easing = CUBIC_EASING)

	var/matrix/animation_matrix2 = new(original_body.transform)
	original_body.transform = matrix().Scale(0)
	animate(original_body, time = 1 SECONDS, transform = animation_matrix2, easing = CUBIC_EASING)

	sleep(1 SECONDS)

	if(!QDELETED(user))
		qdel(user)
	if(QDELETED(src) || QDELETED(original_body))
		stack_trace("Spell or original_body was qdeled during the [src] work.")
		return

	original_body.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	is_transformed = FALSE
	var/list/all_spells = original_body.mind.spell_list + original_body.mob_spell_list
	for(var/obj/effect/proc_holder/spell/vampire/spell in all_spells)
		spell.updateButtonIcon()
	original_body = null


/obj/effect/proc_holder/spell/vampire/metamorphosis/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)
	if(trophie_type == INTERNAL_ORGAN_LIVER || force)
		do_blood_discount(vampire)


/**
 * Transform - Bats
 */
/obj/effect/proc_holder/spell/vampire/metamorphosis/bats
	name = "Метаморфоза - Летучие мыши"
	desc = "Превратитесь в рой злобных летучих мышей. Они умеют летать, наносят умеренный урон в ближнем бою и могут высасывать кровь при атаках."
	gain_desc = "Вы получили возможность превращаться в рой летучих мышей. У них разные способности, в зависимости от трофеев."
	action_icon_state = "bats_meta"
	free_transform_back = TRUE
	meta_path = /mob/living/simple_animal/hostile/vampire/bats
	required_blood = 75


/**
 * Transform - Hound
 */
/obj/effect/proc_holder/spell/vampire/metamorphosis/hound
	name = "Метаморфоза - Гончая"
	desc = "Превратитесь в страшную ищейку. Это проворные, яростные звери, во всем превосходящие человека."
	gain_desc = "Вы обрели способность превращаться в кровавую гончую. Это высшая форма блюспейс-сущности, овладевшей вами."
	action_icon_state = "blood_hound"
	sound_on_transform = 'sound/creatures/hound_howl.ogg'
	free_transform_back = TRUE
	meta_path = /mob/living/simple_animal/hostile/vampire/hound
	required_blood = 100


/obj/effect/proc_holder/spell/vampire/metamorphosis/hound/can_cast(mob/living/carbon/user = usr, charge_check = TRUE, show_message = FALSE)
	var/obj/effect/proc_holder/spell/vampire/self/lunge_finale/finale = locate() in user.mob_spell_list
	if(finale?.lunge_timer)
		if(show_message)
			to_chat(user, span_warning("Вы не можете трансформироваться, пока длится [finale]!"))
		return FALSE
	return ..()


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * ---------------------------------------------------------RESONANT SHRIEK------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/self/bat_screech
	name = "Оглушительный вопль"
	desc = "Летучие мыши издают высокочастотный звук, который ослабляет и оглушает гуманоидов, перегружает датчики синтетиков, гасит свет и разбивает окна."
	action_icon_state = "bats_shriek"
	sound = 'sound/effects/creepyshriek.ogg'
	human_req = FALSE
	base_cooldown = 20 SECONDS
	required_blood = 70


/obj/effect/proc_holder/spell/vampire/self/bat_screech/cast(list/targets, mob/living/user = usr)

	user.visible_message(span_warning("[user] изда[pluralize_ru(user.gender, "ёт", "ют")] душераздирающий вопль!"), \
						span_notice("Вы громко кричите."), \
						span_italics("Вы слышите мучительно громкий визг!"))

	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/t_hearts = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	var/t_ears = vampire.get_trophies(INTERNAL_ORGAN_EYES)
	var/t_kidneys = vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS)
	var/confusion_amt = (t_kidneys) SECONDS	// 10s. MAX
	var/weaken_amt = (t_hearts / 3) SECONDS	// 2s. MAX
	var/brain_dmg = t_ears * 3				// 30 MAX
	var/effect_aoe = 2 + round(t_ears / 3)	// 5 MAX

	for(var/mob/living/victim in hearers(effect_aoe, user))
		if(!victim.affects_vampire(user))
			continue
		if(victim.stat == DEAD)
			continue

		if(ishuman(victim))
			var/mob/living/carbon/human/h_victim = victim
			if(h_victim.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
				continue

			h_victim.apply_damage(brain_dmg, BRAIN)

		if(issilicon(victim))
			playsound(get_turf(victim), 'sound/weapons/flash.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			victim.Weaken(rand(10 SECONDS, 20 SECONDS))
		else
			victim.Weaken(weaken_amt)
			victim.AdjustConfused(confusion_amt)
			victim.Stuttering(40 SECONDS)
			victim.Deaf(40 SECONDS)
			victim.Jitter(40 SECONDS)

	for(var/object in view(effect_aoe, user))
		if(istype(object, /obj/machinery/light))
			var/obj/machinery/light/lamp = object
			lamp.on = TRUE
			lamp.break_light_tube()

		if(istype(object, /obj/structure/window))
			var/obj/structure/window/window = object
			window.take_damage(rand(80, 100))


/obj/effect/proc_holder/spell/vampire/self/bat_screech/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)
	if(trophie_type == INTERNAL_ORGAN_LIVER || force)
		do_blood_discount(vampire)


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * ---------------------------------------------------------LUNGE FINALE---------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/self/lunge_finale
	name = "Финальный рывок"
	desc = "Серия стремительных выпадов в сторону ближайших жертв. Эффекты сильно зависят от трофеев и не отличаются от эффектов обычного заклинания <b>Рывок</b>."
	action_icon_state = "lunge_finale"
	human_req = FALSE
	base_cooldown = 1 MINUTES
	required_blood = 110
	var/obj/effect/proc_holder/spell/vampire/lunge/lunge
	/// How many lunges will proceed.
	var/lunge_counter = 1
	var/lunge_timer
	/// Used to make lunges work on unique targets first.
	var/list/same_targets = list()


/obj/effect/proc_holder/spell/vampire/self/lunge_finale/Destroy()
	if(lunge_timer)
		deltimer(lunge_timer)
	lunge_timer = null
	QDEL_NULL(lunge)
	same_targets.Cut()
	return ..()


/obj/effect/proc_holder/spell/vampire/self/lunge_finale/can_cast(mob/living/carbon/user = usr, charge_check = TRUE, show_message = FALSE)
	if(lunge_timer)
		if(show_message)
			balloon_alert(user, "уже используется!")
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/self/lunge_finale/cast(list/targets, mob/living/user = usr)
	lunge = new(null)
	QDEL_NULL(lunge.custom_handler)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	lunge.effect_aoe = round(vampire.get_trophies(INTERNAL_ORGAN_EARS) / 5)		// less AOE range
	lunge.blood_victim_lose = vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS) * 5	// 50 MAX half as bad as original
	lunge.bonus_range = round(vampire.get_trophies(INTERNAL_ORGAN_LUNGS) / 2)	// 8 MAX
	lunge.create_new_targeting()

	var/all_trophies = vampire.get_trophies(INTERNAL_ORGAN_HEART) + vampire.get_trophies(INTERNAL_ORGAN_LUNGS) + vampire.get_trophies(INTERNAL_ORGAN_LIVER) + \
						vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS) + vampire.get_trophies(INTERNAL_ORGAN_EYES) + vampire.get_trophies(INTERNAL_ORGAN_EARS)

	lunge_counter += round(all_trophies / 10)	// 6 lunges MAX

	to_chat(user, span_notice("Приготовьтесь наброситься на любую жертву поблизости!"))

	lunge_timer = addtimer(CALLBACK(src, PROC_REF(lunge_callback), user), 1 SECONDS, TIMER_UNIQUE | TIMER_LOOP | TIMER_STOPPABLE | TIMER_DELETE_ME)


/obj/effect/proc_holder/spell/vampire/self/lunge_finale/proc/lunge_callback(mob/living/user)
	if(QDELETED(user) || lunge_counter <= 0)
		lunge_counter = initial(lunge_counter)
		if(lunge_timer)
			deltimer(lunge_timer)
		lunge_timer = null
		QDEL_NULL(lunge)
		same_targets.Cut()
		updateButtonIcon()
		return

	var/list/targets = list()
	for(var/mob/living/victim in view(targeting.range - 1, get_turf(user)))
		if(!victim.mind)
			continue
		if(victim.loc == user)	// yeah apparently mobs can see what is inside them
			continue
		if(!victim.affects_vampire(user))
			continue
		if(!is_vampire_compatible(victim, include_IPC = TRUE))
			continue

		if(is_path_exist(user, victim, PASSTABLE|PASSGRILLE|PASSFENCE|PASSMOB))
			targets += victim

	if(length(targets))
		targets = shuffle(targets)
		for(var/mob/living/victim as anything in targets)
			if((victim.UID() in same_targets) && length(targets) == 1)
				INVOKE_ASYNC(lunge, PROC_REF(cast), list(victim), user)
				break

			if((victim.UID() in same_targets))
				targets -= victim
				continue

			same_targets += victim.UID()
			targets -= victim
			INVOKE_ASYNC(lunge, PROC_REF(cast), list(victim), user)
			break

	lunge_counter--


/obj/effect/proc_holder/spell/vampire/self/lunge_finale/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)
	if(trophie_type == INTERNAL_ORGAN_LIVER || force)
		do_blood_discount(vampire)


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * ---------------------------------------------------------ANABIOSIS------------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/self/anabiosis
	name = "Анабиоз"
	desc = "Блюспейс сущность внутри вас призывает таинственный гроб, который может быстро восстановить вас даже на пороге смерти ценой крайней уязвимости во время лечения. Чем больше трофеев вы собрали, тем эффективнее будет процесс восстановления."
	gain_desc = "Вы получили способность залечивать раны благодаря длительному анабиозу. Собранные трофеи значительно усиливают регенерацию."
	action_icon_state = "vampire_coffin"
	sound = 'sound/magic/vampire_anabiosis.ogg'
	base_cooldown = 3 MINUTES
	required_blood = 100
	var/rejuvenation_time = 30 SECONDS


/obj/effect/proc_holder/spell/vampire/self/anabiosis/can_cast(mob/living/carbon/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incapacitated())
		if(show_message)
			balloon_alert(user, "нельзя использовать сейчас!")
		return FALSE
	if(!isturf(user.loc))
		if(show_message)
			balloon_alert(user, "нельзя использовать внутри!")
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/self/anabiosis/cast(list/targets, mob/living/user = usr)
	user.visible_message(span_warning("Вы видите, как [user] начина[pluralize_ru(user.gender, "ет", "ют")] левитировать!"), \
						span_notice("Блюспейс сущность внутри вас начинает подготовку к ритуалу, заставляя вас левитировать..."))

	var/turf/user_turf = get_turf(user)
	user.dir = SOUTH
	var/obj/effect/abstract/vampire/user_image = new(user_turf)
	user_image.add_overlay(user)
	user_image.set_light(2, 10, "#700000")
	user.forceMove(user_image)
	ADD_TRAIT(user, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))

	animate(user_image, pixel_y = 40, time = 3.7 SECONDS, easing = BOUNCE_EASING|EASE_IN)
	animate(pixel_y = 0, time = 0.3 SECONDS, easing = BOUNCE_EASING|EASE_OUT)

	sleep(2.5 SECONDS)
	if(QDELETED(user))
		return

	user_image.remove_light()
	var/obj/structure/closet/coffin/vampire/coffin = new(user_turf, user)
	coffin.no_manipulation = TRUE
	coffin.alpha = 0
	animate(coffin, alpha = 255, time = 0.5 SECONDS)
	coffin.visible_message(span_warning("Под [user] из ниоткуда появляется жуткий гроб!"))
	to_chat(user, span_notice("Под вами появляется древний вампирский гроб. Вы откуда-то знаете, что именно так ваши сородичи веками излечивались от ран."))

	sleep(1 SECONDS)
	if(QDELETED(user) || QDELETED(coffin))
		return

	coffin.no_manipulation = FALSE
	coffin.open()
	coffin.no_manipulation = TRUE

	sleep(0.4 SECONDS)
	if(QDELETED(user) || QDELETED(coffin))
		return

	new /obj/effect/temp_visual/cult/sparks(user_turf)
	user.forceMove(user_turf)
	qdel(user_image)

	user.set_stat(UNCONSCIOUS)
	user.visible_message(
		span_warning("Внезапно [user] пада[pluralize_ru(user.gender, "ет", "ют")] прямо в гроб, и он закрывается!"),
		span_notice("Блюспейс сущность бросает вас в гроб и запечатывает его. Процесс регенерации начался..."),
	)

	sleep(0.6 SECONDS)
	if(QDELETED(user) || QDELETED(coffin))
		return

	coffin.close()
	REMOVE_TRAIT(user, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))

	// we need no companions inside the coffin
	for(var/mob/living/victim in (coffin.contents - user))
		victim.forceMove(user_turf)

		var/self_msg
		if(isvampire(victim) || isvampirethrall(victim))
			self_msg = span_notice("Блюспейс сущность лёгким прикосновением выталкивает вас из гроба.")
		else
			self_msg = span_userdanger("Невидимая сила с яростью выбрасывает вас из гроба!")
			victim.throw_at(get_edge_target_turf(victim, pick(GLOB.alldirs)), rand(10, 30), 8, user)

		victim.visible_message(span_warning("Таинственная сила выталкивает [victim] из гроба!"), self_msg, \
								span_italics("Вы слышите звук сильного удара!"))

	addtimer(CALLBACK(src, PROC_REF(release_vampire), coffin), rejuvenation_time)


/obj/effect/proc_holder/spell/vampire/self/anabiosis/proc/release_vampire(obj/structure/closet/coffin/vampire/coffin)
	if(QDELETED(src) || QDELETED(coffin) || QDELETED(coffin.human_vampire))
		return

	new /obj/effect/temp_visual/cult/sparks(get_turf(coffin))
	coffin.no_manipulation = FALSE
	coffin.open()
	coffin.no_manipulation = TRUE
	coffin.human_vampire.set_stat(CONSCIOUS)
	coffin.human_vampire.updatehealth("vampire coffin")
	coffin.human_vampire.UpdateAppearance()
	coffin.human_vampire = null
	animate(coffin, alpha = 0, time = 2 SECONDS)
	STOP_PROCESSING(SSobj, coffin)
	QDEL_IN(coffin, 2 SECONDS)


/obj/effect/proc_holder/spell/vampire/self/anabiosis/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)
	if(trophie_type == INTERNAL_ORGAN_LIVER || force)
		do_blood_discount(vampire)


/obj/effect/abstract/vampire
	name = "Flying vampire..."
	invisibility = 0
	layer = LOW_LANDMARK_LAYER
	light_system = STATIC_LIGHT


/**
 * "Mysterious" coffin.
 */
/obj/structure/closet/coffin/vampire
	name = "mysterious coffin"
	desc = "Даже при взгляде на этот гроб волосы встают дыбом."
	ru_names = list(
            NOMINATIVE = "таинственный гроб",
            GENITIVE = "таинственного гроба",
            DATIVE = "таинственному гробу",
            ACCUSATIVE = "таинственный гроб",
            INSTRUMENTAL = "таинственным гробом",
            PREPOSITIONAL = "таинственном гробе"
    )
	max_integrity = 500
	color = "#7F0000"
	anchored = TRUE
	resistance_flags = NONE
	obj_flags = NODECONSTRUCT
	material_drop = null
	open_sound = 'sound/objects/coffin_toggle.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	var/datum/gas_mixture/interior_air
	var/obj/machinery/portable_atmospherics/canister/air/interior_tank
	var/no_manipulation = FALSE
	/// UIDs of brave ones who ignore warnings and will loose their blood
	var/list/lightheaded = list()
	var/mob/living/carbon/human/human_vampire

	var/heal_brute = 4
	var/heal_burn = 4
	var/heal_tox = 4
	var/heal_oxy = 8
	var/heal_clone = 2
	var/heal_blood = 12
	var/heal_organs = 1

	var/amount_reagents_cleansed = 5
	var/chance_mend_fracture = 0
	var/chance_stop_internal_bleeding = 0
	var/chance_regrow_limb = 0

	var/fullpower_unlocked = FALSE
	var/fullpower_heal_done = FALSE


/obj/structure/closet/coffin/vampire/Initialize(mapload, mob/living/carbon/human/_human_vampire)
	. = ..()
	ADD_TRAIT(src, TRAIT_WEATHER_IMMUNE, INNATE_TRAIT)
	create_interior()
	set_light(2, 10, "#700000")
	if(istype(_human_vampire))
		human_vampire = _human_vampire
		var/datum/antagonist/vampire/vampire = human_vampire.mind?.has_antag_datum(/datum/antagonist/vampire)
		if(vampire)
			update_trophies(vampire)
	START_PROCESSING(SSobj, src)


/obj/structure/closet/coffin/vampire/Destroy()
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] исчезает, оставляя после себя лишь кучку пепла..."))
	new /obj/effect/decal/cleanable/ash(loc)
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	if(human_vampire)
		playsound(loc, 'sound/objects/coffin_break.ogg', 50, TRUE)
		vampire_revenge()
		human_vampire = null
	lightheaded.Cut()
	QDEL_NULL(interior_tank)
	QDEL_NULL(interior_air)
	return ..()


/obj/structure/closet/coffin/vampire/proc/create_interior()
	interior_tank = new(null)	// we need to place it to the nullspace since its a closet
	interior_air = new
	interior_air.temperature = T20C
	interior_air.volume = 200
	interior_air.oxygen = O2STANDARD*interior_air.volume/(R_IDEAL_GAS_EQUATION*interior_air.temperature)
	interior_air.nitrogen = N2STANDARD*interior_air.volume/(R_IDEAL_GAS_EQUATION*interior_air.temperature)


/obj/structure/closet/coffin/vampire/proc/update_trophies(datum/antagonist/vampire/vampire)
	heal_brute += vampire.get_trophies(INTERNAL_ORGAN_HEART)						// 150 MAX
	heal_burn += vampire.get_trophies(INTERNAL_ORGAN_HEART)							// 150 MAX
	heal_tox += vampire.get_trophies(INTERNAL_ORGAN_LIVER)							// 210 MAX
	heal_oxy += vampire.get_trophies(INTERNAL_ORGAN_LUNGS) * 2						// 300 MAX
	heal_clone += round(vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS) / 2)			// 105 MAX
	heal_blood += vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS) * 2					// 480 MAX
	heal_organs += round(vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS) / 5)			// 45 MAX

	amount_reagents_cleansed += vampire.get_trophies(INTERNAL_ORGAN_LIVER)			// 15 MAX
	chance_mend_fracture += vampire.get_trophies(INTERNAL_ORGAN_HEART) * 4			// 24% MAX
	chance_stop_internal_bleeding += vampire.get_trophies(INTERNAL_ORGAN_HEART) * 4	// 24% MAX
	chance_regrow_limb += vampire.get_trophies(INTERNAL_ORGAN_LUNGS) * 2			// 12% MAX

	if(vampire.get_ability(/datum/vampire_passive/full))
		fullpower_unlocked = TRUE


/obj/structure/closet/coffin/vampire/proc/vampire_revenge()
	var/turf/source_turf = get_turf(src)
	human_vampire.forceMove(source_turf)
	human_vampire.updatehealth("vampire coffin")
	human_vampire.UpdateAppearance()

	if(human_vampire.stat == DEAD)
		human_vampire.visible_message(span_warning("Мёртвое тело [human_vampire] появляется под останками гроба!"))
		return

	human_vampire.set_stat(CONSCIOUS)

	new /obj/effect/temp_visual/cult/sparks(source_turf)
	playsound(loc, 'sound/effects/creepyshriek.ogg', 100, TRUE)
	human_vampire.visible_message(span_danger("[human_vampire] выход[pluralize_ru(human_vampire.gender, "ит", "ят")] из разрушенного гроба и изда[pluralize_ru(human_vampire.gender, "ёт", "ют")] оглушительный вопль!"), \
								span_userdanger("Ваш гроб разрушен, и вы кричите в неистовой ярости!"), \
								span_italics("Вы слышите чрезвычайно громкий визг!"))

	for(var/mob/living/victim in view(7, src))
		if(!victim.affects_vampire(human_vampire))
			continue
		if(victim.stat)
			continue

		victim.Weaken(4 SECONDS)
		to_chat(victim, span_userdanger("Громкий визг ослабляет вас и заставляет упасть на землю!"))


/obj/structure/closet/coffin/vampire/process()
	if(QDELETED(human_vampire) || human_vampire.stat == DEAD)
		qdel(src)
		return

	regulate_environment()

	if(human_vampire.loc != src)
		return

	if(human_vampire.stat == CONSCIOUS)
		human_vampire.set_stat(UNCONSCIOUS)	// to be sure

	// cleansing reagents
	for(var/datum/reagent/reagent in human_vampire.reagents.reagent_list)
		if(istype(reagent, /datum/reagent/medicine/spaceacillin) || istype(reagent, /datum/reagent/medicine/mutadone))
			continue
		human_vampire.reagents.remove_reagent(reagent.id, amount_reagents_cleansed)

	human_vampire.reagents.add_reagent("spaceacillin", 1)	// FOR
	human_vampire.reagents.add_reagent("mutadone", 1)		// FREE!

	// cures heart attack, heart failure and shock
	human_vampire.set_heartattack(FALSE)
	for(var/datum/disease/critical/crit_virus in human_vampire.diseases)
		crit_virus.cure()

	// a little bit of nutrition for mr. vampire
	human_vampire.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, human_vampire.nutrition + 10))

	// damage types
	var/update = NONE
	update |= human_vampire.heal_overall_damage(heal_brute, heal_burn, updating_health = FALSE, affect_robotic = TRUE)
	update |= human_vampire.heal_damages(tox = heal_tox, oxy = heal_oxy, clone = heal_clone, updating_health = FALSE)
	if(update)
		human_vampire.updatehealth()

	// blood
	if(!HAS_TRAIT(human_vampire, TRAIT_NO_BLOOD_RESTORE))
		human_vampire.setBlood(clamp(human_vampire.blood_volume + heal_blood, 0, BLOOD_VOLUME_NORMAL))

	// internal organs
	for(var/obj/item/organ/internal/organ as anything in human_vampire.internal_organs)
		organ.heal_internal_damage(heal_organs, TRUE)

	// fractures
	if(chance_mend_fracture)
		for(var/obj/item/organ/external/body_part as anything in human_vampire.bodyparts)
			if(QDELETED(body_part))
				continue
			if(!body_part.has_fracture())
				continue
			if(body_part.is_robotic())
				continue
			if(prob(chance_mend_fracture))
				body_part.mend_fracture()
				break

	// internal bleedings
	if(chance_stop_internal_bleeding)
		for(var/obj/item/organ/external/body_part as anything in human_vampire.bodyparts)
			if(QDELETED(body_part))
				continue
			if(!body_part.has_internal_bleeding())
				continue
			if(prob(chance_stop_internal_bleeding))
				body_part.stop_internal_bleeding()
				break

	// regrowing limbs
	if(chance_regrow_limb)
		for(var/index in human_vampire.bodyparts_by_name)
			var/obj/item/organ/external/check_limb = human_vampire.bodyparts_by_name[index]
			if(istype(check_limb))
				continue

			var/list/specie_limbs = human_vampire.dna.species.has_limbs[index]
			var/obj/item/organ/external/limb_path = specie_limbs["path"]
			var/obj/item/organ/external/potential_parent = human_vampire.bodyparts_by_name[initial(limb_path.parent_organ_zone)]
			if(!istype(potential_parent))
				continue

			if(prob(chance_regrow_limb))
				new limb_path(human_vampire, ORGAN_MANIPULATION_DEFAULT)
				break

	// here goes rejuvenate little brother
	if(!fullpower_heal_done && fullpower_unlocked)
		fullpower_heal_done = TRUE

		human_vampire.radiation = 0
		human_vampire.set_bodytemperature(human_vampire.dna ? human_vampire.dna.species.body_temperature : BODYTEMP_NORMAL)
		human_vampire.surgeries.Cut()
		human_vampire.SetDisgust(0)
		human_vampire.SetSlowed(0)
		human_vampire.SetImmobilized(0)
		human_vampire.SetLoseBreath(0)
		human_vampire.SetDizzy(0)
		human_vampire.SetJitter(0)
		human_vampire.SetStuttering(0)
		human_vampire.SetConfused(0)
		human_vampire.SetDrowsy(0)
		human_vampire.SetDruggy(0)
		human_vampire.SetHallucinate(0)
		human_vampire.SetEyeBlind(0)
		human_vampire.SetEyeBlurry(0)
		human_vampire.SetDeaf(0)
		human_vampire.ExtinguishMob()
		human_vampire.fire_stacks = 0
		human_vampire.uncuff()
		human_vampire.remove_all_embedded_objects()

		for(var/obj/item/organ/external/body_part as anything in human_vampire.bodyparts)
			if(QDELETED(body_part))
				continue

			body_part.heal_status_wounds(ORGAN_DISFIGURED|ORGAN_DEAD|ORGAN_MUTATED)
			body_part.germ_level = 0
			body_part.open = ORGAN_CLOSED

			for(var/obj/item/organ/internal/organ as anything in body_part.internal_organs)
				if(QDELETED(organ))
					continue

				organ.germ_level = 0
				if(organ.is_robotic())
					organ.status = ORGAN_ROBOT
				else
					organ.status = NONE

		for(var/datum/disease/virus as anything in human_vampire.diseases)
			if(virus.severity == NONTHREAT)
				continue
			virus.cure(need_immunity = FALSE)

		var/mob/living/simple_animal/borer/borer = human_vampire.has_brain_worms()
		if(borer)
			borer.leave_host()
			borer.throw_at(get_edge_target_turf(borer, pick(GLOB.alldirs)), rand(10, 30), 8, human_vampire)
			borer.visible_message(span_warning("Таинственная сила выталкивает [borer] из гроба!"), \
								span_userdanger("Незримая сила с яростью выбрасывает вас из гроба!"), \
								span_italics("Вы слышите звук сильного удара!"))

		human_vampire.remove_all_parasites(vomit_organs = TRUE)

/**
 * Code is kindly stolen from the mecha. Spaceproof coffin ladies and gentlemen!
 */
/obj/structure/closet/coffin/vampire/proc/regulate_environment()
	if(!interior_tank)
		return

	var/datum/gas_mixture/tank_air = interior_tank.return_air()
	var/release_pressure = ONE_ATMOSPHERE
	var/interior_pressure = interior_air.return_pressure()
	var/pressure_delta = min(release_pressure - interior_pressure, (tank_air.return_pressure() - interior_pressure)/2)
	var/transfer_moles = 0

	if(pressure_delta > 0)
		if(tank_air.return_temperature() > 0)
			transfer_moles = pressure_delta*interior_air.return_volume()/(interior_air.return_temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
			interior_air.merge(removed)

	else if(pressure_delta < 0)
		var/datum/gas_mixture/t_air = return_air()
		pressure_delta = interior_pressure - release_pressure

		if(t_air)
			pressure_delta = min(interior_pressure - t_air.return_pressure(), pressure_delta)

		if(pressure_delta > 0)
			transfer_moles = pressure_delta*interior_air.return_volume()/(interior_air.return_temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = interior_air.remove(transfer_moles)
			if(t_air)
				t_air.merge(removed)
			else
				qdel(removed)


/obj/structure/closet/coffin/vampire/remove_air(amount)
	return interior_air.remove(amount)


/obj/structure/closet/coffin/vampire/return_air()
	return interior_air


/obj/structure/closet/coffin/vampire/proc/return_temperature()
	return interior_air.return_temperature()


/obj/structure/closet/coffin/vampire/proc/return_pressure()
	return interior_air.return_pressure()


/obj/structure/closet/coffin/vampire/can_open()
	if(no_manipulation)
		return FALSE
	return TRUE


/obj/structure/closet/coffin/vampire/toggle(mob/living/carbon/human/user)
	if(!no_manipulation)
		return ..()

	var/datum/antagonist/vampire/vampire = human_vampire?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!istype(user) || !vampire)
		return FALSE

	if(isvampire(user) || isvampirethrall(user))
		to_chat(user, span_notice("В этом гробу лежит один из наших сородичей, было бы разумно защитить его."))
		return FALSE

	if(user.mind?.isholy)
		to_chat(user, span_warning("Вы знаете, что в этом гробу находится один из нечестивых вампиров, было бы разумно уничтожить его!"))
		return FALSE

	var/user_UID = user.UID()
	if(!(user_UID in lightheaded))
		lightheaded += user_UID
		to_chat(user, span_warning("Вы чувствуете, что это не очень хорошая идея..."))
	else
		lightheaded -= user_UID
		new /obj/effect/temp_visual/cult/sparks(get_turf(user))
		user.Weaken(10 SECONDS)	// well, you were warned!
		user.Jitter(20 SECONDS)
		user.visible_message(span_warning("Как только [user] прикаса[pluralize_ru(user.gender, "ет", "ют")]ся к [declent_ru(DATIVE)], [genderize_ru(user.gender, "его", "её", "его", "их")] тело начнет биться в конвульсиях."), \
							span_userdanger("Внутри вас что-то сжимается, и вы начинаете биться в конвульсиях!"))

		if(!HAS_TRAIT(user, TRAIT_NO_BLOOD))
			user.bleed(100)
			to_chat(human_vampire, span_notice("<i>... [span_userdanger("Вы чувствуете внезапный прилив сил")] ...</i>"))
			if(!HAS_TRAIT(user, TRAIT_EXOTIC_BLOOD))
				vampire.bloodusable += 50	// only usable blood, will not affect abilities
				human_vampire.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, human_vampire.nutrition + 50))

	return FALSE


/obj/structure/closet/coffin/vampire/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rcs))
		return ATTACK_CHAIN_PROCEED
	return ..()


/**
 * Magic...
 */
/obj/structure/closet/coffin/vampire/ex_act(severity)
	return
/obj/structure/closet/coffin/vampire/singularity_act()
	return
/obj/structure/closet/coffin/vampire/tesla_act(power)
	return


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * ---------------------------------------------------------SUMMON BATS----------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/obj/effect/proc_holder/spell/vampire/self/bats_spawn
	name = "Призыв летучих мышей"
	desc = "Призовите стаи космических летучих мышей из блюспейс-измерения. Они могут помочь вам в битве и будут тем мощнее, чем больше у вас трофеев. Вы можете поменяться местами с летучими мышами, нажав на них в намерении «ПОМОЩЬ»."
	gain_desc = "Вы получили способность вызывать космических летучих мышей. Численность стаи и боевые показатели будут сильно зависеть от собранных трофеев."
	action_icon_state = "bats_new"
	sound = 'sound/creatures/bats_spawn.ogg'
	human_req = FALSE
	stat_allowed = UNCONSCIOUS
	base_cooldown = 30 SECONDS
	required_blood = 80
	var/num_bats = 1
	var/bats_type = /mob/living/simple_animal/hostile/vampire/bats_summoned


/obj/effect/proc_holder/spell/vampire/self/bats_spawn/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)

	var/all_trophies = vampire.get_trophies(INTERNAL_ORGAN_HEART) + vampire.get_trophies(INTERNAL_ORGAN_LUNGS) + vampire.get_trophies(INTERNAL_ORGAN_LIVER) + \
						vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS) + vampire.get_trophies(INTERNAL_ORGAN_EYES) + vampire.get_trophies(INTERNAL_ORGAN_EARS)
	// 4 bats MAX
	if(all_trophies <= 40)
		num_bats += round(all_trophies / 20)
	else if(all_trophies > 40)
		num_bats += all_trophies < 52 ? 2 : 3

	user.visible_message(span_warning("Внезапно <b>[num_bats] ста[declension_ru(num_bats, "я", "и", "й")]</b> космических летучих мышей появились рядом с [user]!"), \
						span_notice("Вы вызываете <b>[num_bats] ста[declension_ru(num_bats, "ю", "и", "й")]</b> космических летучих мышей, чтобы они помогли вам в бою."), \
						span_italics("Вы слышите жуткий шум множества крыльев и громкие визги..."))

	var/turf/user_turf = get_turf(user)
	for(var/turf/check in orange(1, user_turf))
		if(!num_bats)
			num_bats = initial(num_bats)
			return
		if(check.density)
			continue

		new bats_type(check, vampire, user)
		num_bats--

	if(!num_bats)
		num_bats = initial(num_bats)
		return

	for(var/i in 1 to num_bats)
		new bats_type(user_turf, vampire, user)

	num_bats = initial(num_bats)


/obj/effect/proc_holder/spell/vampire/self/bats_spawn/on_trophie_update(datum/antagonist/vampire/vampire, trophie_type, force = FALSE)
	if(trophie_type == INTERNAL_ORGAN_LIVER || force)
		do_blood_discount(vampire)


/*======================================================================================================================================*\
 * //////////////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ *
 * -------------------------------------------------------VAMPIRE ANIMALS--------------------------------------------------------------- *
 * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////////////////////////////////////////////// *
\*======================================================================================================================================*/
/mob/living/simple_animal/hostile/vampire
	name = "Вампир-животное"
	real_name = "Вампир-животное"
	desc = "Сообщите обо мне!"
	faction = list(ROLE_VAMPIRE)
	response_help = "обнимает"
	response_disarm = "аккуратно отодвигает в сторону"
	response_harm = "бьёт"
	attack_sound = 'sound/effects/bite.ogg'
	attacktext = "кусает"
	friendly = "осматривает"
	stop_automated_movement = TRUE
	wander = FALSE
	AIStatus = AI_OFF
	status_flags = NONE
	sentience_type = SENTIENCE_OTHER
	gold_core_spawnable = NO_SPAWN
	speed = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	harm_intent_damage = 5	// punching transformed vampire is pretty useless
	a_intent = INTENT_HARM
	universal_understand = TRUE	// yeah, we can understand anything now
	universal_speak = TRUE	// and speak to anyone too
	mob_size = MOB_SIZE_LARGE
	nightvision = 8	// full night vision
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)	// we need oxygen only
	AI_delay_max = 0 SECONDS
	var/dead_for_sure = FALSE	// we need this to prevent death() proc to invoke nultiple times
	var/datum/antagonist/vampire/vampire
	var/mob/living/carbon/human/human_vampire
	var/obj/effect/proc_holder/spell/vampire/metamorphosis/parent_spell


/mob/living/simple_animal/hostile/vampire/Initialize(mapload, datum/antagonist/vampire/vamp, mob/living/carbon/human/h_vampire, obj/effect/proc_holder/spell/vampire/metamorphosis/meta_spell)
	. = ..()
	if(vamp)
		vampire = vamp
		addtimer(CALLBACK(src, PROC_REF(add_spells)), 0)	// we need timer to place new spells after initial ones
	if(h_vampire)
		faction |= h_vampire.faction
		human_vampire = h_vampire
	if(meta_spell)
		parent_spell = meta_spell

/mob/living/simple_animal/hostile/vampire/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 600, \
		minbodytemp = 0, \
		heat_damage = 5, \
	)

/mob/living/simple_animal/hostile/vampire/Destroy()
	vampire = null
	human_vampire = null
	parent_spell = null
	return ..()


/mob/living/simple_animal/hostile/vampire/death(gibbed)
	if(dead_for_sure)
		return
	dead_for_sure = TRUE
	if(parent_spell && human_vampire)
		transform_back()
		return
	qdel(src)


/mob/living/simple_animal/hostile/vampire/proc/transform_back()
	var/mob/living/carbon/human/our_vampire = human_vampire
	parent_spell.meta_transform_back(src, death_provoked = TRUE)
	our_vampire.emote("moan")
	our_vampire.Stun(5 SECONDS)
	our_vampire.AdjustConfused(5 SECONDS)
	our_vampire.Jitter(6 SECONDS)


/mob/living/simple_animal/hostile/vampire/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		var/list/msgs = list()
		if(key)
			msgs += span_warning("Его глаза отдают злобным блеском в глазах.")
		if(health > (maxHealth*0.95))
			msgs += span_notice("Судя по всему, он находится в отличном состоянии.")
		else if(health > (maxHealth*0.75))
			msgs += span_notice("У него есть несколько повреждений.")
		else if(health > (maxHealth*0.55))
			msgs += span_warning("У него много травм.")
		else if(health > (maxHealth*0.25))
			msgs += span_warning("Он весь в ранах!")
		. += msgs.Join("<br>")


/mob/living/simple_animal/hostile/vampire/proc/add_spells()


/mob/living/simple_animal/hostile/vampire/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	set_invis_see(initial(see_invisible))
	set_sight(initial(sight))
	lighting_alpha = initial(lighting_alpha)
	nightvision = initial(nightvision)

	var/datum/antagonist/vampire/vamp = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp)
		if(vamp.get_ability(/datum/vampire_passive/xray))
			add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		else if(vamp.get_ability(/datum/vampire_passive/full))
			add_sight(SEE_MOBS)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		else if(vamp.get_ability(/datum/vampire_passive/vision))
			add_sight(SEE_MOBS)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src))
			return

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()


/mob/living/simple_animal/hostile/vampire/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()


/**
 * Mr. Vampire in the bat form.
 */
/mob/living/simple_animal/hostile/vampire/bats
	name = "Рой разъярённых летучих мышей"
	real_name = "Рой разъярённых летучих мышей"
	desc = "Рой злобных, сердитых на вид космических летучих мышей."
	icon = 'icons/mob/bats.dmi'
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	speak_emote = list("rattles")
	move_resist = MOVE_FORCE_NORMAL
	pull_force = MOVE_FORCE_NORMAL
	health = 130
	maxHealth = 130
	force_threshold = 3	// little protection
	melee_damage_lower = 10
	melee_damage_upper = 15
	armour_penetration = 50 	// default security armor is useless
	pass_flags = PASSTABLE | PASSFENCE | PASSGRILLE


/mob/living/simple_animal/hostile/vampire/bats/Initialize(mapload, datum/antagonist/vampire/vamp, mob/living/carbon/human/h_vampire, obj/effect/proc_holder/spell/vampire/metamorphosis/meta_spell)
	. = ..()

	AddElement(/datum/element/simple_flying)

	if(!vampire)
		return

	var/t_hearts = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	health += t_hearts * 20 												// 250 MAX
	maxHealth += t_hearts * 20
	melee_damage_lower += round(t_hearts / 2) 								// 13 MAX
	melee_damage_upper += t_hearts											// 21 MAX
	force_threshold += t_hearts * 2 										// 15 MAX
	set_varspeed(speed - vampire.get_trophies(INTERNAL_ORGAN_LUNGS) * 0.05)	// 30% MAX


/mob/living/simple_animal/hostile/vampire/bats/add_spells()
	var/obj/effect/proc_holder/spell/vampire/self/bat_screech/spell = new(null)
	spell.on_trophie_update(vampire, force = TRUE)
	AddSpell(spell)


/mob/living/simple_animal/hostile/vampire/bats/AttackingTarget()
	. = ..()

	if(!. || !vampire || !isliving(target))
		return

	var/mob/living/l_target = target

	if(l_target.affects_vampire(src) && prob(vampire.get_trophies(INTERNAL_ORGAN_EYES) * 3))	// 30% chance MAX
		l_target.Stun(1 SECONDS)
		l_target.visible_message(span_danger("[src] пугает [l_target]!"))

	if(!is_vampire_compatible(l_target, only_human = TRUE, blood_required = TRUE) || isvampire(l_target) || isvampirethrall(l_target))
		return

	var/t_kidneys = vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS)
	if(t_kidneys)
		var/mob/living/who = src
		if(health >= maxHealth && human_vampire)
			who = human_vampire
		who.heal_ordered_damage(t_kidneys, list(BRUTE, BURN, TOX, OXY, CLONE))	// 10 life-leech on MAX

	var/t_livers = vampire.get_trophies(INTERNAL_ORGAN_LIVER)
	if(t_livers && human_vampire && l_target.mind && l_target.ckey)
		var/blood_amt = round(t_livers / 2)
		vampire.adjust_blood(l_target, blood_amt)	// +5 vampire blood max
		l_target.AdjustBlood(-blood_amt)	// -5 blood MAX
		human_vampire.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, human_vampire.nutrition + 5))


/**
 * Mr. Vampire in the hound form.
 */
/mob/living/simple_animal/hostile/vampire/hound
	name = "Кровавая гончая"
	real_name = "Кровавая гончая"
	desc = "Чёрное клыкастое чудовище демонического вида со светящимися красными глазами и острыми зубами. Кровавые гончие обычно являются воплощением могущественных сущностей блюспейса."
	icon_state = "hellhoundgreater"
	icon_living = "hellhoundgreater"
	icon_dead = "hellhound_dead"
	icon_resting = "hellhoundgreater_sit"
	speak_emote = list("growls", "roars")
	attacktext = "терзает"
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	move_resist = MOVE_FORCE_EXTREMELY_STRONG	// no escape
	pull_force = MOVE_FORCE_EXTREMELY_STRONG	// for the weaked
	maxHealth = 200
	health = 200
	force_threshold = 10
	melee_damage_lower = 15
	melee_damage_upper = 20
	environment_smash = ENVIRONMENT_SMASH_WALLS
	obj_damage = 50
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)	// ultimate form, no need in oxy
	/// How many cycles will be skipped between blood cost apply.
	var/life_cycles_skip = 2
	var/life_cycles_current = 0
	/// Needed to stop warnings spam on low blood.
	var/warning_done = FALSE

/mob/living/simple_animal/hostile/vampire/hound/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 1200, \
	)

/mob/living/simple_animal/hostile/vampire/hound/Initialize(mapload, datum/antagonist/vampire/vamp, mob/living/carbon/human/h_vampire, obj/effect/proc_holder/spell/vampire/metamorphosis/meta_spell)
	. = ..()

	ADD_TRAIT(src, TRAIT_NO_BREATH, INNATE_TRAIT)

	if(!vampire)
		return

	var/t_hearts = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	health += t_hearts * 30													// 380 MAX
	maxHealth += t_hearts * 30
	melee_damage_lower += t_hearts											// 25 MAX
	melee_damage_upper += t_hearts											// 30 MAX
	force_threshold += t_hearts * 3											// 28 MAX
	set_varspeed(speed - vampire.get_trophies(INTERNAL_ORGAN_LUNGS) * 0.05)	// 30% MAX


/mob/living/simple_animal/hostile/vampire/hound/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD || !vampire)
		return

	if(life_cycles_current < life_cycles_skip)
		life_cycles_current++
		return

	life_cycles_current = 0
	var/blood_drain = 15 - vampire.get_trophies(INTERNAL_ORGAN_LIVER)	// from -5 to -15 blood every 6s.
	vampire.bloodusable = clamp(vampire.bloodusable - blood_drain, 0, vampire.bloodusable)

	if(vampire.bloodusable <= 100 && !warning_done)
		warning_done = TRUE
		to_chat(src, span_userdanger("Наши запасы крови на исходе!"))

	if(vampire.bloodusable <= 0)
		death()


/mob/living/simple_animal/hostile/vampire/hound/AttackingTarget()
	. = ..()

	if(!. || !isliving(target) || !vampire)
		return

	var/mob/living/l_target = target

	if(l_target.affects_vampire(src) && prob(vampire.get_trophies(INTERNAL_ORGAN_EYES) * 3))	// 30% chance MAX
		l_target.Stun(1 SECONDS)
		l_target.visible_message(span_danger("[src] пугает [l_target]!"))


/mob/living/simple_animal/hostile/vampire/hound/add_spells()
	var/obj/effect/proc_holder/spell/vampire/self/lunge_finale/spell = new(null)
	spell.on_trophie_update(vampire, force = TRUE)
	AddSpell(spell)


/**
 * Summoned bats.
 */
/mob/living/simple_animal/hostile/vampire/bats_summoned
	name = "Рой разъярённых летучих мышей"
	real_name = "Рой разъярённых летучих мышей"
	desc = "Рой злобных, сердитых на вид космических летучих мышей."
	icon = 'icons/mob/bats.dmi'
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	deathmessage = "падают на землю и выглядят безжизненными!"
	speak_emote = list("rattles")
	emote_taunt = list("flutters")
	taunt_chance = 30
	move_resist = MOVE_FORCE_NORMAL
	pull_force = MOVE_FORCE_NORMAL
	stop_automated_movement = FALSE
	wander = TRUE
	AIStatus = AI_ON
	robust_searching = TRUE
	move_to_delay = 0.1 SECONDS	// fast and furious
	stat_attack = UNCONSCIOUS	// YOU ARE DEAD!
	speed = 1
	force_threshold = 3
	health = 80
	maxHealth = 80
	obj_damage = 30
	melee_damage_lower = 5
	melee_damage_upper = 10
	armour_penetration = 50
	pass_flags = PASSTABLE | PASSFENCE | PASSMOB


/mob/living/simple_animal/hostile/vampire/bats_summoned/Initialize(mapload, datum/antagonist/vampire/vamp, mob/living/carbon/human/h_vampire, obj/effect/proc_holder/spell/vampire/metamorphosis/meta_spell)
	. = ..()

	faction = list(ROLE_VAMPIRE)
	AddElement(/datum/element/simple_flying)

	if(!vampire)
		return

	var/t_hearts = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	health += t_hearts * 10 												// 140 MAX
	maxHealth += t_hearts * 10
	melee_damage_lower += round(t_hearts / 2)								// 11 MAX
	melee_damage_upper += t_hearts											// 16 MAX
	force_threshold += t_hearts												// 9 MAX
	set_varspeed(speed - vampire.get_trophies(INTERNAL_ORGAN_LUNGS) * 0.1)	// 0.4 MAX


/mob/living/simple_animal/hostile/vampire/bats_summoned/AttackingTarget()
	. = ..()

	if(!. || !vampire || !isliving(target))
		return

	var/mob/living/l_target = target

	if(l_target.affects_vampire(src) && prob(round(vampire.get_trophies(INTERNAL_ORGAN_EYES) * 1.5)))	// 15% chance MAX
		l_target.Stun(1 SECONDS)
		l_target.visible_message(span_danger("[src] пугает [l_target]!"))

	if(!is_vampire_compatible(l_target, only_human = TRUE, blood_required = TRUE) || isvampire(l_target) || isvampirethrall(l_target))
		return

	var/t_kidneys = vampire.get_trophies(INTERNAL_ORGAN_KIDNEYS)
	if(t_kidneys)
		heal_ordered_damage(t_kidneys, list(BRUTE, BURN, TOX, OXY, CLONE))	// 10 life-leech on MAX

	var/t_livers = vampire.get_trophies(INTERNAL_ORGAN_LIVER)
	if(t_livers && human_vampire && l_target.mind && l_target.ckey)
		var/blood_amt = round(t_livers / 2)
		vampire.adjust_blood(l_target, blood_amt)	// +5 vampire blood max
		l_target.AdjustBlood(-blood_amt)	// -5 blood MAX
		human_vampire.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, human_vampire.nutrition + 5))


/mob/living/simple_animal/hostile/vampire/bats_summoned/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !isliving(target))
		return .
	var/mob/living/l_target = target
	// will change target on attacker instantly if its current target is unconscious or dead
	if(l_target.stat != CONSCIOUS && (!isvampire(user) && !isvampirethrall(user)))
		GiveTarget(user)


/mob/living/simple_animal/hostile/vampire/bats_summoned/Found(atom/A)
	if(isliving(A))
		var/mob/living/victim = A
		if(victim.mind && victim.stat != DEAD && (!isvampire(victim) && !isvampirethrall(victim)))	// target sentient first
			return TRUE
	return FALSE


/mob/living/simple_animal/hostile/vampire/bats_summoned/attack_hand(mob/living/user)
	if(!istype(user) || user.a_intent != INTENT_HELP || health <= 0 || (!isvampire(user) && !isvampirethrall(user)))
		return ..()

	var/turf/bats_turf = get_turf(src)
	for(var/atom/check in (bats_turf.contents - src))
		if(check.density)
			return ..()

	var/direction = get_dir(src, user)
	step(src, direction)
	step(user, GetOppositeDir(direction))

	visible_message(span_notice("[user] поменял[pluralize_ru(user.gender, "ся", "ись")] местами с [src]."), \
					span_notice("[user] поменял[pluralize_ru(user.gender, "ся", "ись")] с вами местами."))
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)


#undef MAX_TROPHIES_PER_TYPE_GENERAL
#undef MAX_TROPHIES_PER_TYPE_CRITICAL
#undef TROPHIES_CAP_PROT_BRUTE
#undef TROPHIES_CAP_PROT_BURN
#undef TROPHIES_CAP_PROT_OXY
#undef TROPHIES_CAP_PROT_TOX
#undef TROPHIES_CAP_PROT_BRAIN
#undef TROPHIES_CAP_PROT_CLONE
#undef TROPHIES_CAP_PROT_STAMINA
#undef TROPHIES_CAP_BLOOD_REDUCE
#undef TROPHIES_EYES_FLASH
#undef TROPHIES_EYES_WELDING
#undef TROPHIES_EYES_XRAY
#undef TROPHIES_EARS_BANG_PROT
#undef TROPHIES_SUCK_BONUS

