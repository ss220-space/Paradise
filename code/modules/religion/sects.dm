#define SECT_ALTAR_REPAIR_TIME (20 SECONDS)
#define SECT_PORTABLE_ALTAR_DEPLOY_TIME (4 SECONDS)
#define SECT_SHRINE_PRANA_PER_SECOND 2
#define SECT_DEFAULT_DEITY_NAME "Безымянный бог"
#define SECT_SACRIFICE_TIME (5 SECONDS)
#define SECT_ALTAR_PLACE_TIME (2 SECONDS)
#define SECT_DEAD_BODY_PRANA 500
#define SECT_LIVING_BODY_PRANA 1000
#define SECT_SIMPLE_ANIMAL_PRANA 250
#define SECT_TECHNICISM_BIBLE_CHARGE 100
#define SECT_BIBLE_HEAL_AMOUNT 10
#define SECT_MERCONICISM_BIBLE_HEAL_AMOUNT 20
#define SECT_MERCONICISM_CREDITS_PER_HEAL 10
#define SECT_FLAGELLANT_BIBLE_SPEED_TIME (5 SECONDS)
#define SECT_FLAGELLANT_BIBLE_HAND_TIME (15 SECONDS)

/datum/movespeed_modifier/sect_flagellant_bible
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -0.5

/proc/is_holy_person(mob/living/user)
	return istype(user) && user.mind?.isholy

/proc/get_religion_sect(mob/living/user)
	if(!istype(user) || !user.mind)
		return null
	if(user.mind.holy_sect)
		return user.mind.holy_sect
	return user.mind.devoted_sect

/proc/can_join_religion_sect(mob/living/user, as_holy = FALSE, silent = FALSE)
	if(!istype(user) || !user.mind)
		return FALSE

	var/fail_message
	if(iscultist(user))
		fail_message = "Тёмная вера не даёт вам принять это благословение."
	else
		switch(user.mind.special_role)
			if(SPECIAL_ROLE_CULTIST, SPECIAL_ROLE_VAMPIRE, SPECIAL_ROLE_VAMPIRE_THRALL, SPECIAL_ROLE_SHADOWLING, SPECIAL_ROLE_SHADOWLING_THRALL)
				fail_message = "Ваша сущность отвергает это благословение."

	if(!fail_message && user.mind.has_antag_datum(/datum/antagonist/vampire))
		fail_message = "Ваша сущность отвергает это благословение."
	else if(!fail_message && is_shadow_or_thrall(user))
		fail_message = "Тень внутри вас отвергает это благословение."
	else if(!fail_message && as_holy && user.mind.has_antag_datum(/datum/antagonist/changeling))
		fail_message = "Вы можете быть посвящённым, но не святым."

	if(fail_message)
		if(!silent)
			to_chat(user, span_warning(fail_message))
		return FALSE

	return TRUE

/datum/religion_sect
	var/name = "Неспециализированная вера"
	var/desc = "Вера ещё не обрела конкретное направление."
	var/deity_name = SECT_DEFAULT_DEITY_NAME
	var/prana = 0
	var/bible_icon_state = "bible"
	var/sacrifice_desc = "Подходят мёртвые или беспомощные тела на алтаре."
	var/obj/structure/sect_altar/altar
	var/list/ritual_types = list()
	var/list/holy_minds = list()
	var/list/devotee_minds = list()
	var/list/temporary_hand_speed_mobs = list()
	var/founder_species

/datum/religion_sect/New(obj/structure/sect_altar/new_altar, new_deity_name)
	. = ..()
	altar = new_altar
	if(length(new_deity_name))
		deity_name = new_deity_name

/datum/religion_sect/Destroy(force)
	for(var/datum/mind/holy_mind as anything in holy_minds)
		if(holy_mind.holy_sect == src)
			holy_mind.holy_sect = null
	for(var/datum/mind/devotee_mind as anything in devotee_minds)
		if(devotee_mind.devoted_sect == src)
			devotee_mind.devoted_sect = null
	altar = null
	holy_minds.Cut()
	devotee_minds.Cut()
	temporary_hand_speed_mobs.Cut()
	return ..()

/datum/religion_sect/proc/get_status()
	return "[name], бог: [deity_name], прана: [round(prana, 0.1)]"

/datum/religion_sect/proc/get_ritual_ui_data(obj/structure/sect_altar/source_altar, mob/user)
	var/list/rituals = list()
	for(var/datum/religion_ritual/ritual_type as anything in ritual_types)
		var/datum/religion_ritual/ritual = new ritual_type
		rituals += list(ritual.get_ui_data(src, source_altar, user))
		qdel(ritual)
	return rituals

/datum/religion_sect/proc/adjust_prana(amount)
	prana = max(0, prana + amount)
	return prana

/datum/religion_sect/proc/get_sacrifice_ui_data(obj/structure/sect_altar/source_altar, mob/user)
	var/mob/living/living_user = isliving(user) ? user : null
	var/atom/movable/offering = source_altar?.get_sacrifice_target(living_user)
	var/list/check_result = get_sacrifice_check_result(source_altar, living_user, offering)
	return list(
		"desc" = sacrifice_desc,
		"target_name" = offering ? DECLENT_RU_CAP(offering, NOMINATIVE) : null,
		"value" = offering ? get_sacrifice_value(offering, living_user) : 0,
		"can_sacrifice" = check_result["can_sacrifice"],
		"failure_reason" = check_result["failure_reason"],
	)

/datum/religion_sect/proc/get_sacrifice_check_result(obj/structure/sect_altar/source_altar, mob/living/user, atom/movable/offering)
	if(!source_altar || !source_altar.activated)
		return list("can_sacrifice" = FALSE, "failure_reason" = "Алтарь не активирован.")
	if(!is_holy_person(user))
		return list("can_sacrifice" = FALSE, "failure_reason" = "Требуется святость.")
	if(!offering)
		return list("can_sacrifice" = FALSE, "failure_reason" = "На алтаре нет подходящей жертвы.")
	var/sacrifice_value = get_sacrifice_value(offering, user)
	if(sacrifice_value <= 0)
		return list("can_sacrifice" = FALSE, "failure_reason" = "Эта жертва не подходит выбранной вере.")
	return list("can_sacrifice" = TRUE, "failure_reason" = "")

/datum/religion_sect/proc/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(!isliving(offering))
		return 0
	var/mob/living/living_offering = offering
	if(living_offering == user)
		return 0
	if(living_offering.mind && (living_offering.mind in devotee_minds))
		return 0
	if(living_offering.stat == CONSCIOUS)
		return 0
	if(istype(living_offering, /mob/living/simple_animal))
		return SECT_SIMPLE_ANIMAL_PRANA
	if(living_offering.stat == DEAD)
		return SECT_DEAD_BODY_PRANA
	return SECT_LIVING_BODY_PRANA

/datum/religion_sect/proc/consume_sacrifice(atom/movable/offering, mob/living/user)
	if(isliving(offering))
		var/mob/living/living_offering = offering
		add_attack_logs(user, living_offering, "Sacrificed to sect altar")
		living_offering.dust()
		return
	qdel(offering)

/datum/religion_sect/proc/can_initiate(mob/living/user, as_holy = FALSE, silent = FALSE)
	return can_join_religion_sect(user, as_holy, silent)

/datum/religion_sect/proc/initiate(mob/living/user, as_holy = FALSE)
	if(!can_initiate(user, as_holy))
		return FALSE

	var/datum/mind/user_mind = user.mind
	if(user_mind.devoted_sect && user_mind.devoted_sect != src)
		LAZYREMOVE(user_mind.devoted_sect.devotee_minds, user_mind)
	if(as_holy && user_mind.holy_sect && user_mind.holy_sect != src)
		LAZYREMOVE(user_mind.holy_sect.holy_minds, user_mind)

	LAZYADD(devotee_minds, user_mind)
	user_mind.isblessed = TRUE
	user_mind.devoted_sect = src
	ADD_TRAIT(user, TRAIT_HEALS_FROM_HOLY_PYLONS, INNATE_TRAIT)

	if(as_holy)
		LAZYADD(holy_minds, user_mind)
		user_mind.isholy = TRUE
		user_mind.holy_sect = src
		grant_holy_spell(user)

	on_initiated(user, as_holy)
	return TRUE

/datum/religion_sect/proc/grant_holy_spell(mob/living/user)
	for(var/obj/effect/proc_holder/spell/spell as anything in user.mob_spell_list)
		if(istype(spell, /obj/effect/proc_holder/spell/chaplain_bless))
			return
	user.AddSpell(new /obj/effect/proc_holder/spell/chaplain_bless(null))

/datum/religion_sect/proc/on_bible_bless(obj/item/storage/bible/bible, mob/living/target, mob/living/carbon/human/user)
	return FALSE

/datum/religion_sect/proc/on_bible_bind(obj/item/storage/bible/bible, mob/user)
	return

/datum/religion_sect/proc/on_initiated(mob/living/user, as_holy)
	return

/datum/religion_sect/proc/heal_bodyparts(mob/living/carbon/human/target, heal_amount = SECT_BIBLE_HEAL_AMOUNT, robotic_only = FALSE, robo_repair = FALSE, max_healed = INFINITY)
	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	var/healed_damage = 0
	for(var/obj/item/organ/external/bodypart as anything in target.bodyparts)
		if(healed_damage >= max_healed)
			break
		if(robotic_only && !bodypart.is_robotic())
			continue
		var/brute_was = bodypart.brute_dam
		var/burn_was = bodypart.burn_dam
		var/remaining_heal = max_healed - healed_damage
		var/brute_heal = min(heal_amount, bodypart.brute_dam, remaining_heal)
		var/burn_heal = min(heal_amount, bodypart.burn_dam, max(0, remaining_heal - brute_heal))
		if(!brute_heal && !burn_heal)
			continue
		update_damage_icon |= bodypart.heal_damage(brute_heal, burn_heal, robo_repair = robo_repair, updating_health = FALSE)
		healed_damage += max(0, brute_was - bodypart.brute_dam)
		healed_damage += max(0, burn_was - bodypart.burn_dam)
		if(bodypart.brute_dam != brute_was || bodypart.burn_dam != burn_was)
			should_update_health = TRUE
	if(should_update_health)
		target.updatehealth("sect bible heal")
	if(update_damage_icon)
		target.UpdateDamageIcon()
	return healed_damage

/datum/religion_sect/proc/heal_robotic_bodyparts(mob/living/carbon/human/target, heal_amount = SECT_BIBLE_HEAL_AMOUNT)
	return heal_bodyparts(target, heal_amount, TRUE, TRUE)

/datum/religion_sect/proc/get_species_name(mob/living/target)
	if(!ishuman(target))
		return null
	var/mob/living/carbon/human/human_target = target
	return human_target.dna?.species?.name

/datum/religion_sect/proc/is_same_species_as_founder(mob/living/target)
	return founder_species && get_species_name(target) == founder_species

/datum/religion_sect/proc/close_external_bleeding(mob/living/carbon/human/target)
	var/closed_any = FALSE
	for(var/obj/item/organ/external/bodypart as anything in target.bodyparts)
		if(bodypart.bleeding_amount <= 0)
			continue
		bodypart.stop_bleeding()
		closed_any = TRUE
	if(closed_any)
		target.calculate_current_bleeding()
	return closed_any

/datum/religion_sect/proc/remove_flagellant_bible_speed(mob/living/target)
	if(QDELETED(target))
		return
	target.remove_movespeed_modifier(/datum/movespeed_modifier/sect_flagellant_bible)

/datum/religion_sect/proc/remove_flagellant_bible_hand_speed(mob/living/target)
	LAZYREMOVE(temporary_hand_speed_mobs, target)
	if(QDELETED(target))
		return
	target.next_move_modifier /= 0.5

/datum/religion_sect/technicism
	name = "Техницизм"
	desc = "Секта, сосредоточенная на киборгах, роботических конечностях и электрической пране."
	bible_icon_state = "bible_technicism"
	sacrifice_desc = "Принимает синтетиков, роботические конечности и металл."
	ritual_types = list(
		/datum/religion_ritual/technicism/metalification,
		/datum/religion_ritual/technicism/transformation,
		/datum/religion_ritual/technicism/ascension,
	)

/datum/religion_sect/technicism/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(ismachineperson(offering))
		return ..() * 2
	if(issilicon(offering))
		var/mob/living/silicon/silicon_offering = offering
		if(silicon_offering == user || silicon_offering.stat == CONSCIOUS)
			return 0
		return silicon_offering.stat == DEAD ? SECT_DEAD_BODY_PRANA * 2 : SECT_LIVING_BODY_PRANA * 2
	if(istype(offering, /obj/item/organ/external))
		var/obj/item/organ/external/bodypart = offering
		return bodypart.is_robotic() ? 300 : 0
	if(istype(offering, /obj/item/stack/sheet/metal))
		var/obj/item/stack/metal_stack = offering
		return metal_stack.get_amount() * 10
	if(istype(offering, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/plasteel_stack = offering
		return plasteel_stack.get_amount() * 25
	return 0

/datum/religion_sect/technicism/on_bible_bless(obj/item/storage/bible/bible, mob/living/target, mob/living/carbon/human/user)
	if(issilicon(target))
		target.adjustBruteLoss(-SECT_BIBLE_HEAL_AMOUNT)
		target.adjustFireLoss(-SECT_BIBLE_HEAL_AMOUNT)
		if(isrobot(target))
			var/mob/living/silicon/robot/robot_target = target
			if(robot_target.cell)
				robot_target.cell.give(SECT_TECHNICISM_BIBLE_CHARGE)
		return TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(heal_robotic_bodyparts(human_target))
			return TRUE
		return SECT_BIBLE_BLESS_BLOCKED
	return TRUE

/datum/religion_sect/pyromania
	name = "Пиромания"
	desc = "Секта огня, жара и очищающего пламени."
	bible_icon_state = "bible_pyromania"
	sacrifice_desc = "Принимает тела, плазму и огнеопасные материалы."
	ritual_types = list(
		/datum/religion_ritual/pyromania/fire_resistance,
		/datum/religion_ritual/pyromania/flame_enchant,
		/datum/religion_ritual/pyromania/holy_flame,
		/datum/religion_ritual/pyromania/flame_absorption,
	)

/datum/religion_sect/pyromania/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(isliving(offering))
		return ..()
	if(istype(offering, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/plasma_stack = offering
		return plasma_stack.get_amount() * 30
	if(istype(offering, /obj/item/reagent_containers/food/drinks/bottle/molotov))
		return 250
	return 0

/datum/religion_sect/pyromania/on_bible_bless(obj/item/storage/bible/bible, mob/living/target, mob/living/carbon/human/user)
	target.ExtinguishMob()
	target.adjust_bodytemperature(-200)
	return TRUE

/datum/religion_sect/merconicism
	name = "Мерконицизм"
	desc = "Секта сделок, кредитов и доказанной успешности."
	bible_icon_state = "bible_merconicism"
	sacrifice_desc = "Принимает наличные, монеты и богатые жертвы."
	ritual_types = list(
		/datum/religion_ritual/merconicism/divine_stall,
		/datum/religion_ritual/merconicism/universal_discount,
		/datum/religion_ritual/merconicism/proof_of_success,
	)

/datum/religion_sect/merconicism/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(istype(offering, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/cash = offering
		return cash.get_amount()
	if(istype(offering, /obj/item/coin))
		return 100
	if(isliving(offering))
		var/mob/living/living_offering = offering
		var/datum/money_account/account = living_offering.mind?.initial_account
		if(!account || account.suspended)
			return 0
		return min(..(), account.money)
	return 0

/datum/religion_sect/merconicism/on_bible_bless(obj/item/storage/bible/bible, mob/living/target, mob/living/carbon/human/user)
	if(user == target)
		to_chat(user, span_warning("Мерконицизм не позволяет лечить себя за собственный счёт."))
		return SECT_BIBLE_BLESS_BLOCKED

	if(!ishuman(target))
		return SECT_BIBLE_BLESS_BLOCKED

	var/mob/living/carbon/human/human_target = target
	var/datum/money_account/target_account = human_target.mind?.initial_account
	if(!target_account || target_account.suspended)
		to_chat(user, span_warning("У [target] нет доступного счёта для оплаты благословения."))
		return SECT_BIBLE_BLESS_BLOCKED

	if(target_account.money < SECT_MERCONICISM_CREDITS_PER_HEAL)
		to_chat(user, span_warning("На счету [target] недостаточно кредитов для благословения."))
		return SECT_BIBLE_BLESS_BLOCKED

	if(human_target.client)
		var/choice = tgui_alert(human_target, "[user] предлагает платное благословение: [SECT_MERCONICISM_CREDITS_PER_HEAL] кредитов за единицу исцеления. Принять?", "Платное благословение", list("Да", "Нет"), timeout = 10 SECONDS)
		if(choice != "Да")
			to_chat(user, span_warning("[target] отказыва[PLUR_ET_YUT(target)]ся от платного благословения."))
			return SECT_BIBLE_BLESS_BLOCKED

	var/heal_limit = floor(target_account.money / SECT_MERCONICISM_CREDITS_PER_HEAL)
	var/healed_damage = heal_bodyparts(human_target, SECT_MERCONICISM_BIBLE_HEAL_AMOUNT, max_healed = heal_limit)
	if(!healed_damage)
		to_chat(user, span_notice("Платное благословение не находит ран, достойных счёта."))
		return SECT_BIBLE_BLESS_BLOCKED

	var/credits_spent = round(healed_damage * SECT_MERCONICISM_CREDITS_PER_HEAL)
	target_account.credit(-credits_spent, "Платное благословение", "Алтарь [deity_name]", name)
	adjust_prana(credits_spent)
	to_chat(human_target, span_warning("С вашего счёта списано [credits_spent] кредит[DECL_CREDIT(credits_spent)] за благословение."))
	to_chat(user, span_notice("Благословение приносит [credits_spent] пран[DECL_CREDIT(credits_spent)] вере \"[name]\"."))
	return TRUE

/datum/religion_sect/dogmatism
	name = "Догматизм"
	desc = "Секта клятв, честных дуэлей и великих битв."
	bible_icon_state = "bible_dogmatism"
	sacrifice_desc = "Принимает тела врагов, оружие и броню."
	ritual_types = list(
		/datum/religion_ritual/dogmatism/oath,
		/datum/religion_ritual/dogmatism/speed_gift,
		/datum/religion_ritual/dogmatism/hardened_armor,
		/datum/religion_ritual/dogmatism/last_stand,
	)

/datum/religion_sect/dogmatism/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(isliving(offering))
		return ..()
	if(isitem(offering))
		var/obj/item/item_offering = offering
		var/melee_armor = item_offering.armor ? item_offering.armor["melee"] : 0
		if(item_offering.force <= 0 && melee_armor <= 0)
			return 0
		return max(item_offering.force * 20, melee_armor * 15)
	return 0

/datum/religion_sect/dogmatism/on_bible_bless(obj/item/storage/bible/bible, mob/living/target, mob/living/carbon/human/user)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		close_external_bleeding(human_target)
	return FALSE

/datum/religion_sect/protestantism
	name = "Протестантизм"
	desc = "Секта трудолюбия, ремесла и награды за работу."
	bible_icon_state = "bible_protestantism"
	sacrifice_desc = "Принимает материалы, инструменты и сделанные руками вещи."
	ritual_types = list(
		/datum/religion_ritual/protestantism/masterpiece,
		/datum/religion_ritual/protestantism/labor_blessing,
		/datum/religion_ritual/protestantism/labor_reward,
	)

/datum/religion_sect/protestantism/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(istype(offering, /obj/item/stack))
		var/obj/item/stack/stack_offering = offering
		return stack_offering.get_amount() * 15
	if(isitem(offering))
		var/obj/item/item_offering = offering
		return item_offering.w_class * 50
	return 0

/datum/religion_sect/protestantism/on_bible_bind(obj/item/storage/bible/bible, mob/user)
	bible.storage_slots = 7
	bible.max_w_class = WEIGHT_CLASS_NORMAL
	bible.max_combined_w_class = 21
	bible.can_hold = list()
	to_chat(user, span_notice("[DECLENT_RU_CAP(bible, NOMINATIVE)] раскрывает скрытые отделения для инструментов и материалов."))

/datum/religion_sect/neodruidism
	name = "Неодруидизм"
	desc = "Секта сохранения природы и общения с её обитателями."
	bible_icon_state = "bible_neodruidism"
	sacrifice_desc = "Принимает растения, семена, древесину и животных."
	ritual_types = list(
		/datum/religion_ritual/neodruidism/greening,
		/datum/religion_ritual/neodruidism/summon_animal,
		/datum/religion_ritual/neodruidism/animal_instincts,
		/datum/religion_ritual/neodruidism/nature_avatar,
	)

/datum/religion_sect/neodruidism/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(istype(offering, /mob/living/simple_animal))
		return ..()
	if(istype(offering, /obj/item/seeds))
		return 75
	if(istype(offering, /obj/item/grown))
		return 100
	if(istype(offering, /obj/item/reagent_containers/food/snacks/grown))
		return 100
	if(istype(offering, /obj/item/stack/sheet/wood))
		var/obj/item/stack/wood_stack = offering
		return wood_stack.get_amount() * 15
	return 0

/datum/religion_sect/neodruidism/on_bible_bless(obj/item/storage/bible/bible, mob/living/target, mob/living/carbon/human/user)
	if(!istype(target, /mob/living/simple_animal))
		return FALSE
	target.adjustBruteLoss(-SECT_BIBLE_HEAL_AMOUNT)
	target.adjustFireLoss(-SECT_BIBLE_HEAL_AMOUNT)
	return TRUE

/datum/religion_sect/flagellantism
	name = "Флагеллантизм"
	desc = "Секта искупления через боль и самоистязание."
	bible_icon_state = "bible_flagellantism"
	sacrifice_desc = "Принимает беспомощные тела, органы и острое оружие."
	ritual_types = list(
		/datum/religion_ritual/flagellantism/scarring,
		/datum/religion_ritual/flagellantism/iron_robes,
		/datum/religion_ritual/flagellantism/sin_weapon,
		/datum/religion_ritual/flagellantism/martyr_retribution,
	)

/datum/religion_sect/flagellantism/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(isliving(offering))
		return ..()
	if(istype(offering, /obj/item/organ/external))
		return 200
	if(isitem(offering))
		var/obj/item/item_offering = offering
		return item_offering.sharp ? max(100, item_offering.force * 20) : 0
	return 0

/datum/religion_sect/flagellantism/on_bible_bless(obj/item/storage/bible/bible, mob/living/target, mob/living/carbon/human/user)
	target.adjustBruteLoss(15)
	target.add_movespeed_modifier(/datum/movespeed_modifier/sect_flagellant_bible)
	addtimer(CALLBACK(src, PROC_REF(remove_flagellant_bible_speed), target), SECT_FLAGELLANT_BIBLE_SPEED_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	if(!(target in temporary_hand_speed_mobs))
		LAZYADD(temporary_hand_speed_mobs, target)
		target.next_move_modifier *= 0.5
	addtimer(CALLBACK(src, PROC_REF(remove_flagellant_bible_hand_speed), target), SECT_FLAGELLANT_BIBLE_HAND_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	return TRUE

/datum/religion_sect/community
	name = "Община"
	desc = "Секта единства одной расы и превосходства общины."
	bible_icon_state = "bible_community"
	sacrifice_desc = "Принимает тела не-членов общины и подношения членов той же расы."
	ritual_types = list(
		/datum/religion_ritual/community/common_trouble,
		/datum/religion_ritual/community/fortified_temple,
		/datum/religion_ritual/community/mouth_of_truth,
		/datum/religion_ritual/community/faith_imposition,
	)

/datum/religion_sect/community/on_initiated(mob/living/user, as_holy)
	if(!as_holy || founder_species)
		return
	founder_species = get_species_name(user)

/datum/religion_sect/community/on_bible_bless(obj/item/storage/bible/bible, mob/living/target, mob/living/carbon/human/user)
	if(!target.mind)
		to_chat(user, span_warning("Община не слышит безвольную цель."))
		return SECT_BIBLE_BLESS_BLOCKED
	if(!(target.mind in devotee_minds))
		if(!is_same_species_as_founder(target) || !initiate(target))
			to_chat(user, span_warning("Община не признаёт [target] своим членом."))
			return SECT_BIBLE_BLESS_BLOCKED
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		bible.bless(human_target)
	target.adjustBruteLoss(-5, affect_robotic = FALSE)
	target.adjustFireLoss(-5, affect_robotic = FALSE)
	return TRUE

/datum/religion_sect/community/get_sacrifice_value(atom/movable/offering, mob/living/user)
	if(isliving(offering))
		return ..()
	if(isitem(offering) && is_same_species_as_founder(user))
		var/obj/item/item_offering = offering
		return item_offering.w_class * 25
	return 0

/datum/religion_ritual
	var/id = "ritual"
	var/name = "Ритуал"
	var/desc = "Ритуал ещё не описан."
	var/cost = 0
	var/target_desc = "Цель не требуется."
	var/requires_atom_on_altar = FALSE
	var/implemented = FALSE

/datum/religion_ritual/proc/get_ui_data(datum/religion_sect/sect, obj/structure/sect_altar/altar, mob/user)
	var/list/check_result = get_check_result(sect, altar, user)
	return list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"cost" = cost,
		"target_desc" = target_desc,
		"can_run" = check_result["can_run"],
		"failure_reason" = check_result["failure_reason"],
		"implemented" = implemented,
	)

/datum/religion_ritual/proc/get_check_result(datum/religion_sect/sect, obj/structure/sect_altar/altar, mob/user)
	if(!sect || !altar || !altar.activated)
		return list("can_run" = FALSE, "failure_reason" = "Алтарь не активирован.")
	if(!is_holy_person(user))
		return list("can_run" = FALSE, "failure_reason" = "Требуется святость.")
	if(sect.prana < cost)
		return list("can_run" = FALSE, "failure_reason" = "Недостаточно праны.")
	if(requires_atom_on_altar && !get_target(altar, user))
		return list("can_run" = FALSE, "failure_reason" = "На алтаре нет подходящей цели.")
	return list("can_run" = TRUE, "failure_reason" = "")

/datum/religion_ritual/proc/get_target(obj/structure/sect_altar/altar, mob/user)
	if(!requires_atom_on_altar || !altar)
		return null
	return altar.get_ritual_target(src, user)

/datum/religion_ritual/proc/is_valid_target(atom/movable/target, mob/user)
	return !isnull(target)

/datum/religion_ritual/proc/is_organic_target(atom/movable/target)
	return iscarbon(target) && !ismachineperson(target)

/datum/religion_ritual/proc/is_item_target(atom/movable/target)
	return isitem(target)

/datum/religion_ritual/proc/try_run(datum/religion_sect/sect, obj/structure/sect_altar/altar, mob/living/user)
	var/list/check_result = get_check_result(sect, altar, user)
	if(!check_result["can_run"])
		to_chat(user, span_warning(check_result["failure_reason"]))
		return FALSE
	if(!implemented)
		to_chat(user, span_warning("Эффект ритуала \"[name]\" ещё не реализован. Проверки стоимости и цели пройдены."))
		return FALSE
	sect.adjust_prana(-cost)
	to_chat(user, span_notice("Вы проводите ритуал \"[name]\"."))
	return TRUE

/datum/religion_ritual/technicism/metalification
	id = "metalification"
	name = "Металлификация"
	desc = "Аугментирует доступные части органика на алтаре."
	cost = 1000
	target_desc = "Органик на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/technicism/metalification/is_valid_target(atom/movable/target, mob/user)
	return is_organic_target(target)

/datum/religion_ritual/technicism/transformation
	id = "transformation"
	name = "Преображение"
	desc = "Дарует сопротивление электричеству и святой статус синтетикам."
	cost = 2500
	target_desc = "Существо на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/technicism/transformation/is_valid_target(atom/movable/target, mob/user)
	return isliving(target)

/datum/religion_ritual/technicism/ascension
	id = "ascension"
	name = "Вознесение"
	desc = "Радикально перестраивает тело и волю цели."
	cost = 10000
	target_desc = "Согласная цель на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/technicism/ascension/is_valid_target(atom/movable/target, mob/user)
	return isliving(target)

/datum/religion_ritual/pyromania/fire_resistance
	id = "fire_resistance"
	name = "Сопротивление огню"
	desc = "Дарует сопротивление огню священнику или органику на алтаре."
	cost = 1000

/datum/religion_ritual/pyromania/flame_enchant
	id = "flame_enchant"
	name = "Зачарование пламенем"
	desc = "Зачаровывает предмет на алтаре."
	cost = 2500
	target_desc = "Предмет на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/pyromania/flame_enchant/is_valid_target(atom/movable/target, mob/user)
	return is_item_target(target)

/datum/religion_ritual/pyromania/holy_flame
	id = "holy_flame"
	name = "Священное пламя"
	desc = "Дарует заклинание священного пламени."
	cost = 5000

/datum/religion_ritual/pyromania/flame_absorption
	id = "flame_absorption"
	name = "Поглощение пламени"
	desc = "Бёрн урон начинает лечить брут с частичной конвертацией."
	cost = 10000
	target_desc = "Органик на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/pyromania/flame_absorption/is_valid_target(atom/movable/target, mob/user)
	return is_organic_target(target)

/datum/religion_ritual/merconicism/divine_stall
	id = "divine_stall"
	name = "Божественный ларёк"
	desc = "Призывает передвижной торгомат."
	cost = 1000

/datum/religion_ritual/merconicism/universal_discount
	id = "universal_discount"
	name = "Универсальная скидка"
	desc = "Улучшает конвертацию кредитов в прану."
	cost = 2500

/datum/religion_ritual/merconicism/proof_of_success
	id = "proof_of_success"
	name = "Доказательство успешности"
	desc = "Дарует случайный небезопасный предмет и объявляет об успехе."
	cost = 10000

/datum/religion_ritual/dogmatism/oath
	id = "oath"
	name = "Клятва"
	desc = "Даёт священнику испытание с возвратом стоимости при успехе."
	cost = 1000

/datum/religion_ritual/dogmatism/speed_gift
	id = "speed_gift"
	name = "Дар скорости"
	desc = "Дарует ген скорости."
	cost = 2500
	target_desc = "Существо на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/dogmatism/speed_gift/is_valid_target(atom/movable/target, mob/user)
	return isliving(target)

/datum/religion_ritual/dogmatism/hardened_armor
	id = "hardened_armor"
	name = "Закалённый доспех"
	desc = "Создаёт тяжёлый священный комплект брони."
	cost = 5000

/datum/religion_ritual/dogmatism/last_stand
	id = "last_stand"
	name = "Последний бой"
	desc = "Призывает конструктов за живых посвящённых."
	cost = 10000

/datum/religion_ritual/protestantism/masterpiece
	id = "masterpiece"
	name = "Шедевр"
	desc = "Создаёт заказанную конструкцию из ресурсов на алтаре."
	cost = 1000
	target_desc = "Ресурсы на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/protestantism/masterpiece/is_valid_target(atom/movable/target, mob/user)
	return istype(target, /obj/item/stack)

/datum/religion_ritual/protestantism/labor_blessing
	id = "labor_blessing"
	name = "Благословение на труд"
	desc = "Создаёт одну из трудовых реликвий."
	cost = 5000

/datum/religion_ritual/protestantism/labor_reward
	id = "labor_reward"
	name = "Награда за труды"
	desc = "Даёт новый нулрод или облегчённый доспех крестоносца."
	cost = 10000

/datum/religion_ritual/neodruidism/greening
	id = "greening"
	name = "Озеленение"
	desc = "Даёт росток, способный вырастить дерево и распространить растительный пол."
	cost = 1000

/datum/religion_ritual/neodruidism/summon_animal
	id = "summon_animal"
	name = "Призыв животного"
	desc = "Призывает случайное нейтральное животное."
	cost = 2500

/datum/religion_ritual/neodruidism/animal_instincts
	id = "animal_instincts"
	name = "Животные инстинкты"
	desc = "Даёт мобу без души собачий ИИ для приказов."
	cost = 5000
	target_desc = "Моб без души на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/neodruidism/animal_instincts/is_valid_target(atom/movable/target, mob/user)
	if(!isliving(target))
		return FALSE
	var/mob/living/living_target = target
	return !living_target.mind

/datum/religion_ritual/neodruidism/nature_avatar
	id = "nature_avatar"
	name = "Аватар природы"
	desc = "Пробуждает разум выбранного животного и усиливает его тело."
	cost = 10000
	target_desc = "Животное на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/neodruidism/nature_avatar/is_valid_target(atom/movable/target, mob/user)
	return istype(target, /mob/living/simple_animal)

/datum/religion_ritual/flagellantism/scarring
	id = "scarring"
	name = "Шрамирование"
	desc = "Повреждает конечность и превращает её в источник праны."
	cost = 1000
	target_desc = "Органик на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/flagellantism/scarring/is_valid_target(atom/movable/target, mob/user)
	return is_organic_target(target)

/datum/religion_ritual/flagellantism/iron_robes
	id = "iron_robes"
	name = "Железные одеяния"
	desc = "Призывает тяжёлый плащ, превращающий урон в прану."
	cost = 2500

/datum/religion_ritual/flagellantism/sin_weapon
	id = "sin_weapon"
	name = "Орудие греха"
	desc = "Зачаровывает острое оружие."
	cost = 5000
	target_desc = "Острое оружие на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/flagellantism/sin_weapon/is_valid_target(atom/movable/target, mob/user)
	if(!is_item_target(target))
		return FALSE
	var/obj/item/item_target = target
	return item_target.sharp

/datum/religion_ritual/flagellantism/martyr_retribution
	id = "martyr_retribution"
	name = "Воздаяние мученика"
	desc = "Связывает священника с посвящённым и перенаправляет урон."
	cost = 10000
	target_desc = "Посвящённый рядом с алтарём."

/datum/religion_ritual/community/common_trouble
	id = "common_trouble"
	name = "Общая беда"
	desc = "Позволяет узнать расположение и состояние члена общины."
	cost = 1000

/datum/religion_ritual/community/fortified_temple
	id = "fortified_temple"
	name = "Неприступный храм"
	desc = "Создаёт защитное поле против не-членов общины."
	cost = 2500

/datum/religion_ritual/community/mouth_of_truth
	id = "mouth_of_truth"
	name = "Уста истины"
	desc = "Открывает канал связи от священника к посвящённым."
	cost = 5000

/datum/religion_ritual/community/faith_imposition
	id = "faith_imposition"
	name = "Насаждение веры"
	desc = "Превращает карбона на алтаре в расу священника и даёт задачу служить храму."
	cost = 10000
	target_desc = "Карбон на алтаре."
	requires_atom_on_altar = TRUE

/datum/religion_ritual/community/faith_imposition/is_valid_target(atom/movable/target, mob/user)
	return iscarbon(target)

/obj/structure/sect_altar
	name = "altar"
	desc = "Каменный алтарь, ожидающий веры."
	icon = 'icons/obj/religion.dmi'
	icon_state = "sect_altar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	max_integrity = 200
	pass_flags_self = PASSTABLE | LETPASSTHROW
	can_astar_pass = CANASTARPASS_ALWAYS_PROC
	resistance_flags = FIRE_PROOF
	interaction_flags_click = NEED_HANDS | NEED_DEXTERITY | ALLOW_RESTING
	var/datum/religion_sect/sect
	var/preselected_sect_type
	var/activated = FALSE
	var/static/list/selectable_sects

/obj/structure/sect_altar/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/climb_walkable)
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)

/obj/structure/sect_altar/Initialize(mapload)
	. = ..()
	if(!selectable_sects)
		selectable_sects = list(
			"Техницизм" = /datum/religion_sect/technicism,
			"Пиромания" = /datum/religion_sect/pyromania,
			"Мерконицизм" = /datum/religion_sect/merconicism,
			"Догматизм" = /datum/religion_sect/dogmatism,
			"Протестантизм" = /datum/religion_sect/protestantism,
			"Неодруидизм" = /datum/religion_sect/neodruidism,
			"Флагеллантизм" = /datum/religion_sect/flagellantism,
			"Община" = /datum/religion_sect/community,
		)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/sect_altar/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!Adjacent(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SectAltar", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/structure/sect_altar/ui_data(mob/user)
	var/list/data = list()
	data["activated"] = activated
	data["can_activate"] = can_use_altar(user, silent = TRUE)
	data["preselected_sect"] = preselected_sect_type ? "[preselected_sect_type]" : null
	data["sects"] = get_selectable_sect_ui_data()
	if(sect)
		data["sect_name"] = sect.name
		data["sect_desc"] = sect.desc
		data["deity_name"] = sect.deity_name
		data["prana"] = round(sect.prana, 0.1)
		data["rituals"] = sect.get_ritual_ui_data(src, user)
		data["sacrifice"] = sect.get_sacrifice_ui_data(src, user)
	else
		data["sect_name"] = null
		data["sect_desc"] = null
		data["deity_name"] = null
		data["prana"] = 0
		data["rituals"] = list()
		data["sacrifice"] = null
	return data

/obj/structure/sect_altar/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/mob/living/user = usr
	if(!can_use_altar(user))
		return
	switch(action)
		if("activate")
			if(activated)
				return
			var/sect_type = text2path(params["sect_type"])
			var/deity_name = copytext("[params["deity_name"]]", 1, MAX_NAME_LEN)
			activate_altar(user, sect_type, deity_name)
			return TRUE
		if("run_ritual")
			if(!activated || !sect)
				return
			var/datum/religion_ritual/ritual = get_ritual_by_id(params["ritual_id"])
			if(!ritual)
				return
			ritual.try_run(sect, src, user)
			qdel(ritual)
			return TRUE
		if("sacrifice")
			if(!activated || !sect)
				return
			return try_sacrifice(user)

/obj/structure/sect_altar/Destroy(force)
	QDEL_NULL(sect)
	return ..()

/obj/structure/sect_altar/get_ru_names()
	return list(
		NOMINATIVE = "алтарь",
		GENITIVE = "алтаря",
		DATIVE = "алтарю",
		ACCUSATIVE = "алтарь",
		INSTRUMENTAL = "алтарём",
		PREPOSITIONAL = "алтаре",
	)

/obj/structure/sect_altar/examine(mob/user)
	. = ..()
	if(sect)
		. += span_notice("На алтаре закреплена вера: [sect.get_status()].")
	else if(preselected_sect_type)
		var/datum/religion_sect/preselected_sect = preselected_sect_type
		. += span_notice("Алтарь хранит старую веру: [initial(preselected_sect.name)].")
	else
		. += span_notice("Алтарь можно активировать человеку со святостью.")

/obj/structure/sect_altar/update_icon_state()
	icon_state = activated ? "sect_altar_active" : "sect_altar"

/obj/structure/sect_altar/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags == PASSEVERYTHING || (pass_info.pass_flags & PASSTABLE))
		return TRUE
	return FALSE

/obj/structure/sect_altar/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(place_pulled_on_altar(user, user.pulling))
		return
	if(place_pulled_atom_on_altar(user, user.pulling))
		return
	if(!can_use_altar(user))
		return
	if(!activated)
		var/datum/religion_sect/user_sect = get_religion_sect(user)
		if(user_sect)
			convert_to_shrine(user, user_sect)
			return
		ui_interact(user)
		return
	ui_interact(user)

/obj/structure/sect_altar/attackby(obj/item/item, mob/user, list/modifiers)
	if(istype(item, /obj/item/storage/bible))
		bind_bible(item, user)
		return ATTACK_CHAIN_BLOCKED_ALL
	if(user.a_intent == INTENT_HARM || (item.item_flags & ABSTRACT) || item.is_robot_module())
		return ..()
	if(!user.transfer_item_to_loc(item, loc))
		return ..()
	. = ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return .
	item.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - (ICON_SIZE_X / 2), - (ICON_SIZE_X / 2), ICON_SIZE_X / 2)
	item.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - (ICON_SIZE_Y / 2), - (ICON_SIZE_Y / 2), ICON_SIZE_Y / 2)
	item_placed(item)
	SEND_SIGNAL(item, COMSIG_ITEM_PLACED_ON_TABLE, user, src)

/obj/structure/sect_altar/proc/item_placed(atom/movable/placed)
	return

/obj/structure/sect_altar/proc/place_held_item_on_altar(obj/item/item, mob/user)
	if(user.get_active_hand() != item)
		return FALSE
	if(isrobot(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return TRUE
	if(istype(item, /obj/item/storage/bag/tray))
		return TRUE
	if(!user.drop_item_ground(item))
		return TRUE
	if(item.loc != loc)
		add_fingerprint(user)
		step(item, get_dir(item, src))
		return TRUE
	add_fingerprint(user)
	item_placed(item)
	SEND_SIGNAL(item, COMSIG_ITEM_PLACED_ON_TABLE, user, src)
	return TRUE

/obj/structure/sect_altar/proc/place_pulled_atom_on_altar(mob/living/user, atom/movable/pulled)
	if(!istype(user) || !pulled || isliving(pulled) || !(pulled.pass_flags & PASSTABLE) || !Adjacent(user))
		return FALSE
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE
	user.Move_Pulled(src)
	if(pulled.loc != loc)
		return FALSE
	user.visible_message(
		span_notice("[DECLENT_RU_CAP(user, NOMINATIVE)] клад[PLUR_ET_YUT(user)] [pulled.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы кладёте [pulled.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]."),
	)
	user.stop_pulling()
	add_fingerprint(user)
	return TRUE

/obj/structure/sect_altar/shove_impact(mob/living/target, mob/living/attacker)
	if(locate(/obj/structure/sect_altar) in get_turf(target))
		return FALSE
	var/pass_flags_cache = target.pass_flags
	target.pass_flags |= PASSTABLE
	if(target.Move(loc))
		. = TRUE
		target.Knockdown(4 SECONDS)
		add_attack_logs(attacker, target, "pushed onto [src]", ATKLOG_ALL)
	else
		. = FALSE
	target.pass_flags = pass_flags_cache

/obj/structure/sect_altar/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(isitem(grabbed_thing))
		if(step(grabbed_thing, get_dir(grabbed_thing.loc, loc)))
			grabber.stop_pulling()
		return .
	if(place_pulled_on_altar(grabber, grabbed_thing))
		return .
	return ..()

/obj/structure/sect_altar/mouse_drop_receive(atom/movable/dropped, mob/user, params)
	if(isitem(dropped))
		var/obj/item/item = dropped
		if(place_held_item_on_altar(item, user))
			return
	if(!isliving(user))
		return ..()
	var/mob/living/living_user = user
	if(place_pulled_on_altar(living_user, dropped))
		return
	return ..()

/obj/structure/sect_altar/proc/can_use_altar(mob/living/user, silent = FALSE)
	if(!istype(user) || !Adjacent(user) || user.incapacitated())
		return FALSE
	if(!is_holy_person(user))
		if(!activated && get_religion_sect(user))
			return TRUE
		if(!activated && preselected_sect_type && user.mind)
			return can_join_religion_sect(user, TRUE, silent)
		if(!silent)
			to_chat(user, span_warning("Алтарь не откликается на вашу веру."))
		return FALSE
	return TRUE

/obj/structure/sect_altar/proc/activate_altar(mob/living/user, sect_type, new_deity_name)
	if(activated || !can_use_altar(user))
		return FALSE
	if(preselected_sect_type)
		sect_type = preselected_sect_type
	else if(!is_selectable_sect_type(sect_type))
		to_chat(user, span_warning("Алтарь не узнаёт эту веру."))
		return FALSE
	if(!length(new_deity_name))
		new_deity_name = SECT_DEFAULT_DEITY_NAME
	sect = new sect_type(src, new_deity_name)
	activated = TRUE
	update_icon(UPDATE_ICON_STATE)
	sect.initiate(user, TRUE)
	if(SSticker)
		SSticker.Bible_deity_name = sect.deity_name
	visible_message(span_notice("[user] закрепля[PLUR_ET_YUT(user)] веру в [declent_ru(PREPOSITIONAL)]."))
	return TRUE

/obj/structure/sect_altar/proc/place_pulled_on_altar(mob/living/user, atom/movable/pulled)
	if(!istype(user) || !isliving(pulled) || pulled == user || !Adjacent(user))
		return FALSE
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE
	var/mob/living/victim = pulled
	if(!can_place_living_on_altar(user, victim))
		if(!QDELETED(victim) && victim.buckled)
			return TRUE
		return FALSE
	visible_message(
		span_notice("[user] начинает укладывать [victim.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете укладывать [victim.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]."),
	)
	if(!do_after(user, SECT_ALTAR_PLACE_TIME, victim))
		return TRUE
	if(!can_place_living_on_altar(user, victim, silent = TRUE))
		return TRUE
	victim.forceMove(get_turf(src))
	victim.set_resting(TRUE, instant = TRUE)
	item_placed(victim)
	user.stop_pulling()
	visible_message(span_notice("[user] укладыва[PLUR_ET_YUT(user)] [victim.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]."))
	to_chat(user, span_notice("Вы укладываете [victim.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]."))
	add_fingerprint(user)
	add_attack_logs(user, victim, "Placed onto [src]")
	return TRUE

/obj/structure/sect_altar/proc/can_place_living_on_altar(mob/living/user, mob/living/victim, silent = FALSE)
	if(QDELETED(src) || QDELETED(user) || QDELETED(victim))
		return FALSE
	if(!istype(user) || !istype(victim) || victim == user || !Adjacent(user))
		return FALSE
	if(!user.Adjacent(victim) && user.loc != victim.loc)
		return FALSE
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE
	if(victim.buckled)
		if(!silent)
			to_chat(user, span_warning("[DECLENT_RU_CAP(victim, NOMINATIVE)] уже пристёгнут к [victim.buckled.declent_ru(DATIVE)]!"))
		return FALSE
	return TRUE

/obj/structure/sect_altar/proc/get_selectable_sect_ui_data()
	var/list/sects = list()
	for(var/sect_name in selectable_sects)
		var/datum/religion_sect/sect_type = selectable_sects[sect_name]
		sects += list(list(
			"name" = sect_name,
			"desc" = initial(sect_type.desc),
			"type" = "[sect_type]",
			"preselected" = preselected_sect_type == sect_type,
		))
	return sects

/obj/structure/sect_altar/proc/is_selectable_sect_type(sect_type)
	for(var/sect_name in selectable_sects)
		if(selectable_sects[sect_name] == sect_type)
			return TRUE
	return FALSE

/obj/structure/sect_altar/proc/get_ritual_by_id(ritual_id)
	if(!sect)
		return null
	for(var/datum/religion_ritual/ritual_type as anything in sect.ritual_types)
		if(initial(ritual_type.id) != ritual_id)
			continue
		return new ritual_type
	return null

/obj/structure/sect_altar/proc/get_ritual_target(datum/religion_ritual/ritual, mob/user)
	var/turf/altar_turf = get_turf(src)
	if(!altar_turf)
		return null
	if(ritual)
		for(var/mob/living/target as anything in altar_turf)
			if(target.stat != DEAD && target.body_position != LYING_DOWN)
				continue
			if(ritual.is_valid_target(target, user))
				return target
		for(var/mob/living/target as anything in altar_turf)
			if(target == user)
				continue
			if(ritual.is_valid_target(target, user))
				return target
		for(var/mob/living/target as anything in altar_turf)
			if(ritual.is_valid_target(target, user))
				return target
		for(var/atom/movable/target as anything in altar_turf)
			if(target == src || istype(target, /obj/structure/sect_shrine) || isliving(target))
				continue
			if(ritual.is_valid_target(target, user))
				return target
		return null
	for(var/mob/living/target as anything in altar_turf)
		if(target.stat == DEAD || target.body_position == LYING_DOWN)
			return target
	for(var/atom/movable/target as anything in altar_turf)
		if(target == src || istype(target, /obj/structure/sect_shrine) || isliving(target))
			continue
		return target
	for(var/atom/movable/target as anything in altar_turf)
		if(target == src || istype(target, /obj/structure/sect_shrine))
			continue
		return target
	return null

/obj/structure/sect_altar/proc/get_sacrifice_target(mob/living/user)
	if(!sect)
		return get_ritual_target()
	var/turf/altar_turf = get_turf(src)
	if(!altar_turf)
		return null
	for(var/mob/living/target as anything in altar_turf)
		if(sect.get_sacrifice_value(target, user) > 0)
			return target
	for(var/atom/movable/target as anything in altar_turf)
		if(target == src || istype(target, /obj/structure/sect_shrine) || isliving(target))
			continue
		if(sect.get_sacrifice_value(target, user) > 0)
			return target
	return get_ritual_target()

/obj/structure/sect_altar/proc/try_sacrifice(mob/living/user)
	if(!sect)
		return FALSE
	var/atom/movable/offering = get_sacrifice_target(user)
	var/list/check_result = sect.get_sacrifice_check_result(src, user, offering)
	if(!check_result["can_sacrifice"])
		to_chat(user, span_warning(check_result["failure_reason"]))
		return FALSE
	var/sacrifice_value = sect.get_sacrifice_value(offering, user)
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] жертвоприношение на [declent_ru(PREPOSITIONAL)]."),
		span_notice("Вы начинаете жертвоприношение на [declent_ru(PREPOSITIONAL)]."),
	)
	if(!do_after(user, SECT_SACRIFICE_TIME, src))
		return FALSE
	if(QDELETED(offering) || offering.loc != get_turf(src))
		to_chat(user, span_warning("Жертва больше не лежит на алтаре."))
		return FALSE
	check_result = sect.get_sacrifice_check_result(src, user, offering)
	if(!check_result["can_sacrifice"])
		to_chat(user, span_warning(check_result["failure_reason"]))
		return FALSE
	sacrifice_value = sect.get_sacrifice_value(offering, user)
	sect.consume_sacrifice(offering, user)
	sect.adjust_prana(sacrifice_value)
	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощает жертву, наполняясь [sacrifice_value] ед. праны."))
	SStgui.update_uis(src)
	return TRUE

/obj/structure/sect_altar/proc/convert_to_shrine(mob/living/user, datum/religion_sect/new_sect)
	if(!new_sect || QDELETED(new_sect))
		return
	new /obj/structure/sect_shrine(get_turf(src), new_sect)
	visible_message(span_notice("[user] превраща[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] в святилище [new_sect.deity_name]."))
	qdel(src)

/obj/structure/sect_altar/proc/bind_bible(obj/item/storage/bible/bible, mob/user)
	if(!activated || !sect)
		to_chat(user, span_warning("Сначала нужно закрепить веру на алтаре."))
		return FALSE
	if(!bible.bind_to_sect(sect, user))
		return FALSE
	to_chat(user, span_notice("[DECLENT_RU_CAP(bible, NOMINATIVE)] привязана к вере \"[sect.name]\"."))
	return TRUE

/obj/structure/sect_shrine
	name = "shrine"
	desc = "Святилище, направляющее прану к выбранной вере."
	icon = 'icons/obj/religion.dmi'
	icon_state = "sect_shrine"
	density = TRUE
	anchored = TRUE
	max_integrity = 140
	resistance_flags = FIRE_PROOF
	var/datum/religion_sect/sect

/obj/structure/sect_shrine/Initialize(mapload, datum/religion_sect/new_sect)
	. = ..()
	sect = new_sect
	if(sect)
		START_PROCESSING(SSobj, src)

/obj/structure/sect_shrine/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	sect = null
	return ..()

/obj/structure/sect_shrine/get_ru_names()
	return list(
		NOMINATIVE = "святилище",
		GENITIVE = "святилища",
		DATIVE = "святилищу",
		ACCUSATIVE = "святилище",
		INSTRUMENTAL = "святилищем",
		PREPOSITIONAL = "святилище",
	)

/obj/structure/sect_shrine/examine(mob/user)
	. = ..()
	if(sect)
		. += span_notice("Святилище копит прану для веры: [sect.get_status()].")

/obj/structure/sect_shrine/process(seconds_per_tick)
	if(sect)
		sect.adjust_prana(SECT_SHRINE_PRANA_PER_SECOND * seconds_per_tick)

/obj/structure/sect_altar/broken
	name = "broken altar"
	desc = "Разбитый алтарь, который ещё можно восстановить."
	icon_state = "sect_altar_broken"
	density = FALSE
	activated = FALSE

/obj/structure/sect_altar/broken/attack_hand(mob/living/user, list/modifiers)
	if(!is_holy_person(user))
		return ..()
	to_chat(user, span_notice("Вы начинаете восстанавливать [declent_ru(ACCUSATIVE)]."))
	if(!do_after(user, SECT_ALTAR_REPAIR_TIME, src))
		return
	new /obj/structure/sect_altar(get_turf(src))
	qdel(src)

/obj/structure/sect_altar/old_faith/technicism
	preselected_sect_type = /datum/religion_sect/technicism

/obj/structure/sect_altar/old_faith/pyromania
	preselected_sect_type = /datum/religion_sect/pyromania

/obj/structure/sect_altar/old_faith/merconicism
	preselected_sect_type = /datum/religion_sect/merconicism

/obj/structure/sect_altar/old_faith/dogmatism
	preselected_sect_type = /datum/religion_sect/dogmatism

/obj/structure/sect_altar/old_faith/protestantism
	preselected_sect_type = /datum/religion_sect/protestantism

/obj/structure/sect_altar/old_faith/neodruidism
	preselected_sect_type = /datum/religion_sect/neodruidism

/obj/structure/sect_altar/old_faith/flagellantism
	preselected_sect_type = /datum/religion_sect/flagellantism

/obj/structure/sect_altar/old_faith/community
	preselected_sect_type = /datum/religion_sect/community

/datum/uplink_item/stealthy_tools/sect_dedication_kit
	name = "Набор посвящения"
	desc = "Компактный кейс с переносным алтарём и одноразовым вероучением. Позволяет агенту основать собственную церковь без помощи штатного священника."
	item = /obj/item/storage/briefcase/sect_dedication_kit
	cost = 25
	surplus = 0

/obj/item/storage/briefcase/sect_dedication_kit
	name = "suspicious briefcase"
	desc = "Плотный чемодан с замаскированным религиозным оборудованием."

/obj/item/storage/briefcase/sect_dedication_kit/populate_contents()
	new /obj/item/sect_doctrine(src)
	new /obj/item/sect_portable_altar_case(src)

/obj/item/sect_doctrine
	name = "basic doctrine"
	desc = "Одноразовая книга, раскрывающая путь к святой вере."
	icon = 'icons/obj/library.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/sect_doctrine/attack_self(mob/living/user)
	if(!istype(user) || !user.mind)
		return
	if(is_holy_person(user))
		to_chat(user, span_warning("Вы уже связаны со святой верой."))
		return
	if(!can_join_religion_sect(user, TRUE))
		return
	user.mind.isholy = TRUE
	ADD_TRAIT(user, TRAIT_HEALS_FROM_HOLY_PYLONS, INNATE_TRAIT)
	to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] рассыпается пеплом, оставляя в вас право основывать веру."))
	qdel(src)

/obj/item/sect_portable_altar_case
	name = "portable altar case"
	desc = "Складной алтарь, который можно развернуть на полу."
	icon = 'icons/obj/storage.dmi'
	icon_state = "briefcase"
	w_class = WEIGHT_CLASS_BULKY
	var/stored_activated = FALSE
	var/datum/religion_sect/stored_sect

/obj/item/sect_portable_altar_case/Destroy(force)
	stored_sect = null
	return ..()

/obj/item/sect_portable_altar_case/attack_self(mob/living/user)
	if(!istype(user) || user.incapacitated())
		return
	if(!is_holy_person(user))
		to_chat(user, span_warning("Кейс не поддаётся вашим рукам."))
		return
	to_chat(user, span_notice("Вы начинаете раскладывать переносной алтарь."))
	if(!do_after(user, SECT_PORTABLE_ALTAR_DEPLOY_TIME, user))
		return
	var/obj/structure/sect_altar/new_altar = new(get_turf(user))
	new_altar.activated = stored_activated
	new_altar.sect = stored_sect
	if(new_altar.sect)
		new_altar.sect.altar = new_altar
	stored_sect = null
	new_altar.update_icon(UPDATE_ICON_STATE)
	qdel(src)

/obj/structure/sect_altar/click_alt(mob/living/user)
	if(!is_holy_person(user))
		return ..()
	to_chat(user, span_notice("Вы начинаете складывать [declent_ru(ACCUSATIVE)]."))
	if(!do_after(user, SECT_PORTABLE_ALTAR_DEPLOY_TIME, user))
		return
	var/obj/item/sect_portable_altar_case/altar_case = new(get_turf(src))
	altar_case.stored_activated = activated
	altar_case.stored_sect = sect
	if(sect)
		sect.altar = null
	sect = null
	user.put_in_hands(altar_case)
	qdel(src)
