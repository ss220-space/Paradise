/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/medicine/packs.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/heal_brute = 0
	var/heal_burn = 0
	var/self_delay = 2 SECONDS
	/// Some things give a special prompt, do we want to bypass some checks in parent?
	var/unique_handling = FALSE
	var/stop_bleeding = 0
	var/bleedsuppress = 0
	var/use_duration = 3 SECONDS
	var/use_flags = DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_LYING
	merge_type = null // do not merge if not defined in subtype

/obj/item/stack/medical/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) && !isanimal(target))
		target.balloon_alert(user, "неподходящая цель!")
		return .

	if(!user.IsAdvancedToolUser())
		target.balloon_alert(user, "вы слишком неуклюжи для этого!")
		return .

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/selected_zone = get_priority_targeting(target, user, def_zone)
		var/obj/item/organ/external/affecting = human_target.get_organ(selected_zone)

		if(isgolem(human_target))
			target.balloon_alert(user, "неподходящая цель!")
			return .

		if(human_target.covered_with_thick_material(selected_zone))
			target.balloon_alert(user, "часть тела чем-то перекрыта!")
			return .

		if(!affecting)
			target.balloon_alert(user, "часть тела отсутствует!")
			return .

		if(affecting.is_robotic())
			target.balloon_alert(user, "часть тела неорганическая!")
			return .

		if(human_target == user && !unique_handling)
			user.visible_message(
				span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(PREPOSITIONAL)]."),
				ignored_mobs = user,
			)
			target.balloon_alert(user, "применение на [GLOB.body_zone[affecting.limb_zone][PREPOSITIONAL]]...")

			if(!do_after(human_target, self_delay, human_target, use_flags, max_interact_count = 1))
				return .

			var/obj/item/organ/external/affecting_rechecked = human_target.get_organ(selected_zone)
			if(!affecting_rechecked)
				target.balloon_alert(user, "часть тела отсутствует!")
				return .

			if(human_target.covered_with_thick_material(selected_zone))
				target.balloon_alert(user, "часть тела чем-то перекрыта!")
				return .

			if(affecting_rechecked.is_robotic())
				target.balloon_alert(user, "часть тела неорганическая!")
				return .
		else
			user.visible_message(
				span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(PREPOSITIONAL)] [human_target.declent_ru(PREPOSITIONAL)]."),
				ignored_mobs = user,
			)
			target.balloon_alert(user, "применение на [GLOB.body_zone[affecting.limb_zone][PREPOSITIONAL]] цели...")

			if(use_duration && !do_after(user, use_duration, human_target))
				return .
		return .|ATTACK_CHAIN_SUCCESS

	if(isanimal(target))
		var/mob/living/simple_animal/critter = target
		if(!(critter.healable))
			target.balloon_alert(user, "неподходящая цель!")
			return .
		if(critter.health == critter.maxHealth)
			target.balloon_alert(user, "цель не нуждается в лечении!")
			return .
		if(heal_brute < 1)
			target.balloon_alert(user, "применение бессмысленно!")
			return .
		if(!use(1))
			return .
		critter.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message(
			span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [critter.declent_ru(PREPOSITIONAL)]."),
			ignored_mobs = user,
		)
		target.balloon_alert(user, "применение на цели...")

		return .|ATTACK_CHAIN_SUCCESS

	if(!use(1))
		return .

	target.heal_organ_damage(heal_brute, heal_burn)

	user.visible_message(
		span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [target.declent_ru(PREPOSITIONAL)]."),
		ignored_mobs = user,
	)
	target.balloon_alert(user, "применено")

	return .|ATTACK_CHAIN_SUCCESS

/obj/item/stack/medical/proc/human_heal(mob/living/carbon/human/target, mob/user)
	var/selected_zone = get_priority_targeting(target, user)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)

	target.balloon_alert(user, "применено")

	var/rembrute = max(0, heal_brute - affecting.brute_dam) // Maxed with 0 since heal_damage let you pass in a negative value
	var/remburn = max(0, heal_burn - affecting.burn_dam) // And deduct it from their health (aka deal damage)
	var/nrembrute = rembrute
	var/nremburn = remburn
	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	var/affecting_brute_was = affecting.brute_dam
	var/affecting_burn_was = affecting.burn_dam
	update_damage_icon |= affecting.heal_damage(heal_brute, heal_burn, updating_health = FALSE)
	if(affecting.brute_dam != affecting_brute_was || affecting.burn_dam != affecting_burn_was)
		should_update_health = TRUE
	var/list/achildlist
	if(LAZYLEN(affecting.children))
		achildlist = affecting.children.Copy()
	var/parenthealed = FALSE
	while(rembrute + remburn > 0) // Don't bother if there's not enough leftover heal
		var/obj/item/organ/external/organ
		if(LAZYLEN(achildlist))
			organ = pick_n_take(achildlist) // Pick a random children and then remove it from the list
		else if(affecting.parent && !parenthealed) // If there's a parent and no healing attempt was made on it
			organ = affecting.parent
			parenthealed = TRUE
		else
			break // If the organ have no child left and no parent / parent healed, break
		if(organ.is_robotic() || organ.open) // Ignore robotic or open limb
			continue
		else if(!organ.brute_dam && !organ.burn_dam) // Ignore undamaged limb
			continue
		nrembrute = max(0, rembrute - organ.brute_dam) // Deduct the healed damage from the remain
		nremburn = max(0, remburn - organ.burn_dam)
		var/brute_was = organ.brute_dam
		var/burn_was = organ.burn_dam
		update_damage_icon |= organ.heal_damage(rembrute, remburn, updating_health = FALSE)
		if(organ.brute_dam != brute_was || organ.burn_dam != burn_was)
			should_update_health = TRUE
		rembrute = nrembrute
		remburn = nremburn
		user.visible_message(
			span_notice("[user] применя[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(PREPOSITIONAL)] [target.declent_ru(GENITIVE)]."),
			ignored_mobs = user,
		)
		target.balloon_alert(user, "применение на [GLOB.body_zone[affecting.limb_zone][PREPOSITIONAL]] цели")
	if(should_update_health)
		target.updatehealth("[name] heal")
	if(update_damage_icon)
		target.UpdateDamageIcon()

/obj/item/stack/medical/can_merge(obj/item/stack/check, inhand)
	if(check.type != merge_type)
		return FALSE
	. = ..()

// MARK: Targeting filter

/obj/item/stack/medical/proc/get_priority_targeting(mob/living/target, mob/living/user)
	return user.zone_selected

/obj/item/stack/medical/proc/get_priority_targeting_by_filter(mob/living/target, mob/living/user, filter_proc)
	. = user.zone_selected
	if(!ishuman(target))
		return

	if(user.client && !(user.client.prefs.toggles2 & PREFTOGGLE_2_AUTO_AIM_MEDICINE))
		return //disabled from preferences

	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/external/target_bodypart = target.get_organ(user.zone_selected)
	var/accept = call(src, filter_proc)(arglist(list(current = target_bodypart, max = null)))
	if(accept) //selected zone are accepted, no auto priority
		return

	for(var/obj/item/organ/external/affecting as anything in human_target.bodyparts)
		accept = call(src, filter_proc)(arglist(list(current = affecting, max = target_bodypart)))
		if(accept)
			target_bodypart = affecting

	if(!target_bodypart)
		return

	return target_bodypart.limb_zone

/obj/item/stack/medical/proc/filter_max_bleeding_bodypart(obj/item/organ/external/current, obj/item/organ/external/max)
	if(current.is_robotic() || current.bleeding_amount <= 0 || current.bleeding_amount <= current.bleedsuppress)
		return FALSE
	if(!max)
		return TRUE
	if(current.bleeding_amount > max.bleeding_amount)
		return TRUE
	return FALSE

/obj/item/stack/medical/proc/filter_max_brute_damage_bodypart(obj/item/organ/external/current, obj/item/organ/external/max)
	if(current.is_robotic() || current.brute_dam <= 0)
		return FALSE
	if(!max)
		return TRUE
	if(current.brute_dam > max.brute_dam)
		return TRUE
	return FALSE

/obj/item/stack/medical/proc/filter_max_burn_damage_bodypart(obj/item/organ/external/current, obj/item/organ/external/max)
	if(current.is_robotic() || current.burn_dam <= 0)
		return FALSE
	if(!max)
		return TRUE
	if(current.burn_dam > max.burn_dam)
		return TRUE
	return FALSE

/obj/item/stack/medical/proc/filter_max_damage_bodypart(obj/item/organ/external/current, obj/item/organ/external/max)
	if(current.is_robotic() || current.burn_dam <= 0 && current.brute_dam <= 0)
		return FALSE
	if(!max)
		return TRUE
	if(current.burn_dam + current.brute_dam > max.burn_dam + max.brute_dam)
		return TRUE
	return FALSE

// MARK: Bruise Packs

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Отрезок марли, скатанный в аккуратный рулон с фиксаторами на конце. \
			Используется для обработки механически повреждённых тканей и остановки кровотечения."
	icon_state = "gauze_3"
	item_state = "gauze"
	origin_tech = "biotech=2"
	heal_brute = 5
	bleedsuppress = 2
	stop_bleeding = 180 SECONDS
	use_duration = 2 SECONDS
	energy_type = /datum/robot_energy_storage/medical
	merge_type = /obj/item/stack/medical/bruise_pack

/obj/item/stack/medical/bruise_pack/get_ru_names()
	return list(
		NOMINATIVE = "рулон марли",
		GENITIVE = "рулона марли",
		DATIVE = "рулону марли",
		ACCUSATIVE = "рулон марли",
		INSTRUMENTAL = "рулоном марли",
		PREPOSITIONAL = "рулоне марли"
	)

/obj/item/stack/medical/bruise_pack/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/bruise_pack/attackby(obj/item/item, mob/user, params)
	if(item.sharp)
		add_fingerprint(user)
		var/atom/drop_loc = drop_location()
		if(!use(2))
			balloon_alert(user, "слишком мало для разрезания!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/stack/sheet/cloth/cloth = new(drop_loc)
		cloth.add_fingerprint(user)
		user.visible_message(
			span_notice("[user] разреза[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на куски ткани, используя [item.declent_ru(ACCUSATIVE)]."),
			blind_message = span_hear("Вы слышите звук рвущейся ткани."),
			ignored_mobs = user,
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/item/stack/medical/bruise_pack/update_icon_state()
	icon_state = "gauze_[amount >= 5 ? 3 : (amount >= 3 ? 2 : 1)]"

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .
	if(!get_amount())
		target.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED
	var/selected_zone = get_priority_targeting(target, user, def_zone)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)
	if(affecting.open != ORGAN_CLOSED)
		target.balloon_alert(user, "неэффективно для такой раны!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	affecting.germ_level = 0
	if(stop_bleeding && affecting.bleeding_amount > affecting.bleedsuppress)	//so you can't stack bleed suppression
		affecting.suppress_bloodloss(user, target, bleedsuppress, stop_bleeding)
		var/obj/item/organ/external/addition_affecting = target.get_affecting_limb_bodypart(affecting)
		if(addition_affecting)
			addition_affecting.suppress_bloodloss(user, target, bleedsuppress, stop_bleeding)
	human_heal(target, user)
	target.UpdateDamageIcon()
	update_icon()

/obj/item/stack/medical/bruise_pack/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_bleeding_bodypart))

/obj/item/stack/medical/bruise_pack/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "Отрезок ткани, скатанный в некое подобие бинта. \
			Способен остановить кровотечение, но не более того."
	stop_bleeding = 90 SECONDS
	icon_state = "gauze_imp_3"
	merge_type = /obj/item/stack/medical/bruise_pack/improvised

/obj/item/stack/medical/bruise_pack/improvised/get_ru_names()
	return list(
		NOMINATIVE = "импровизированный бинт",
		GENITIVE = "импровизированного бинта",
		DATIVE = "импровизированному бинту",
		ACCUSATIVE = "импровизированный бинт",
		INSTRUMENTAL = "импровизированным бинтом",
		PREPOSITIONAL = "импровизированном бинте"
	)

/obj/item/stack/medical/bruise_pack/improvised/update_icon_state()
	icon_state = "gauze_imp_[amount >= 5 ? 3 : (amount >= 3 ? 2 : 1)]"

/obj/item/stack/medical/bruise_pack/military
	name = "military emergency bandage"
	singular_name = "emergency bandage"
	desc = "Специальный комплект для быстрой остановки кровотечения по всему телу. \
			Используется сотрудниками силовых и охранных структур."
	icon_state = "bandage"
	origin_tech = "biotech=2;combat=1"
	amount = 1
	max_amount = 1
	heal_brute = 0
	stop_bleeding = 300 SECONDS
	merge_type = /obj/item/stack/medical/bruise_pack/military

/obj/item/stack/medical/bruise_pack/military/get_ru_names()
	return list(
		NOMINATIVE = "военный перевязочный пакет",
		GENITIVE = "военного перевязочного пакета",
		DATIVE = "военному перевязочному пакету",
		ACCUSATIVE = "военный перевязочный пакет",
		INSTRUMENTAL = "военным перевязочным пакетом",
		PREPOSITIONAL = "военном перевязочном пакете",
	)

/obj/item/stack/medical/bruise_pack/military/attackby(obj/item/I, mob/user, params)
	if(I.sharp)
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/stack/medical/bruise_pack/military/update_icon_state()
	return

/obj/item/stack/medical/bruise_pack/military/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .
	var/list/all_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
	for(var/select_def_zone in all_zones)
		var/obj/item/organ/external/affecting = target.get_organ(select_def_zone)
		if(affecting.open != ORGAN_CLOSED)
			continue
		if(affecting.bleeding_amount <= affecting.bleedsuppress)
			continue
		affecting.germ_level = 0
		if(affecting.bleeding_amount > affecting.bleedsuppress)
			affecting.suppress_bloodloss(user, target, bleedsuppress, stop_bleeding)
	use(1)
	if(!QDELETED(src))
		update_icon()
	return ATTACK_CHAIN_PROCEED

/obj/item/stack/medical/bruise_pack/advanced
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "Стандартный набор первой помощи, предназначенный для лечения повреждений механического характера. \
			Включает в себя комплект гелей, антисептиков, заживляющих мембран и лечебных пластырей."
	icon_state = "traumakit_4"
	item_state = "traumakit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 20
	amount = 8
	max_amount = 8
	stop_bleeding = 0
	use_duration = 1.5 SECONDS
	merge_type = /obj/item/stack/medical/bruise_pack/advanced
	use_flags = DA_IGNORE_LYING

/obj/item/stack/medical/bruise_pack/advanced/get_ru_names()
	return list(
		NOMINATIVE = "набор для лечения травм",
		GENITIVE = "набора для лечения травм",
		DATIVE = "набору для лечения травм",
		ACCUSATIVE = "набор для лечения травм",
		INSTRUMENTAL = "набором для лечения травм",
		PREPOSITIONAL = "наборе для лечения травм"
	)

/obj/item/stack/medical/bruise_pack/advanced/update_icon_state()
	icon_state = "traumakit_[round_down((amount + 1) / 2, 1)]"

/obj/item/stack/medical/bruise_pack/advanced/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/bruise_pack/advanced/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_brute_damage_bodypart))

/obj/item/stack/medical/bruise_pack/extended
	name = "extended trauma kit"
	singular_name = "extended trauma kit"
	desc = "Продвинутый набор первой помощи, предназначенный для лечения тяжёлых повреждений механического характера. \
			Включает в себя комплект гелей, антисептиков, заживляющих мембран, \
			лечебных пластырей, местных обезболивающих и травматических повязок."
	icon_state = "extended_trauma_kit_5"
	item_state = "extended_trauma_kit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 30
	amount = 10
	max_amount = 10
	stop_bleeding = 0
	use_duration = 0
	self_delay = 1.5 SECONDS
	use_duration = 0.7 SECONDS
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/bruise_pack/extended

/obj/item/stack/medical/bruise_pack/extended/get_ru_names()
	return list(
		NOMINATIVE = "продвинутый набор для лечения травм",
		GENITIVE = "продвинутого набора для лечения травм",
		DATIVE = "продвинутому набору для лечения травм",
		ACCUSATIVE = "продвинутый набор для лечения травм",
		INSTRUMENTAL = "продвинутым набором для лечения травм",
		PREPOSITIONAL = "продвинутом наборе для лечения травм"
	)

/obj/item/stack/medical/bruise_pack/extended/update_icon_state()
	icon_state = "extended_trauma_kit_[round_down((amount+1) / 2, 1)]"

/obj/item/stack/medical/bruise_pack/extended/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_brute_damage_bodypart))

// MARK: Ointment

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Тюбик медицинской мази, предназначенной для местного применения при лечении ожогов различного характера. \
			Обладает антисептическим, обезболивающим и охлаждающим действием."
	gender = FEMALE
	singular_name = "ointment"
	icon_state = "ointment_3"
	origin_tech = "biotech=2"
	heal_burn = 10
	use_duration = 2 SECONDS
	energy_type = /datum/robot_energy_storage/medical
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/ointment

/obj/item/stack/medical/ointment/get_ru_names()
	return list(
		NOMINATIVE = "мазь от ожогов",
		GENITIVE = "мази от ожогов",
		DATIVE = "мази от ожогов",
		ACCUSATIVE = "мазь от ожогов",
		INSTRUMENTAL = "мазью от ожогов",
		PREPOSITIONAL = "мази от ожогов"
	)

/obj/item/stack/medical/ointment/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_burn_damage_bodypart))

/obj/item/stack/medical/ointment/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/ointment/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .

	if(!get_amount())
		target.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	var/selected_zone = get_priority_targeting(target, user, def_zone)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)
	if(affecting.open != ORGAN_CLOSED)
		target.balloon_alert(user, "неэффективно для такой раны!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	affecting.germ_level = 0
	human_heal(target, user)
	target.UpdateDamageIcon()
	update_icon()

/obj/item/stack/medical/ointment/update_icon_state()
	icon_state = "ointment_[amount >= 5 ? 3 : (amount >= 3 ? 2 : 1)]"

/obj/item/stack/medical/ointment/advanced
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "Стандартный набор первой помощи, предназначенный для лечения ожогов различного характера. \
			Включает в себя комплект гелей, антисептиков, заживляющих мембран и лечебных пластырей."
	gender = MALE
	icon_state = "burnkit_4"
	item_state = "burnkit"
	belt_icon = "advanced_burn_kit"
	heal_burn = 20
	amount = 8
	max_amount = 8
	use_duration = 1.5 SECONDS
	merge_type = /obj/item/stack/medical/ointment/advanced

/obj/item/stack/medical/ointment/advanced/get_ru_names()
	return list(
		NOMINATIVE = "набор для лечения ожогов",
		GENITIVE = "набора для лечения ожогов",
		DATIVE = "набору для лечения ожогов",
		ACCUSATIVE = "набор для лечения ожогов",
		INSTRUMENTAL = "набором для лечения ожогов",
		PREPOSITIONAL = "наборе для лечения ожогов"
	)

/obj/item/stack/medical/ointment/advanced/update_icon_state()
	icon_state = "burnkit_[round_down((amount + 1) / 2, 1)]"

/obj/item/stack/medical/ointment/advanced/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/ointment/extended
	name = "extended burn kit"
	singular_name = "extended burn kit"
	desc = "Продвинутый набор первой помощи, предназначенный для лечения тяжёлых ожогов различного характера. \
			Включает в себя комплект гелей, антисептиков, заживляющих мембран, \
			лечебных пластырей и местных обезболивающих."
	gender = MALE
	icon_state = "extended_burn_kit_5"
	item_state = "extended_burn_kit"
	belt_icon = "advanced_burn_kit"
	heal_burn = 30
	amount = 10
	max_amount = 10
	self_delay = 1.5 SECONDS
	use_duration = 0.7 SECONDS
	merge_type = /obj/item/stack/medical/ointment/extended

/obj/item/stack/medical/ointment/extended/get_ru_names()
	return list(
		NOMINATIVE = "продвинутый набор для лечения ожогов",
		GENITIVE = "продвинутого набора для лечения ожогов",
		DATIVE = "продвинутому набору для лечения ожогов",
		ACCUSATIVE = "продвинутый набор для лечения ожогов",
		INSTRUMENTAL = "продвинутым набором для лечения ожогов",
		PREPOSITIONAL = "продвинутом наборе для лечения ожогов"
	)

/obj/item/stack/medical/ointment/extended/update_icon_state()
	icon_state = "extended_burn_kit_[round_down((amount+1) / 2, 1)]"

// MARK: Synthflesh kit

/obj/item/stack/medical/bruise_pack/synthflesh_kit
	name = "synthflesh trauma kit"
	singular_name = "synthflesh trauma kit"
	desc = "Набор первой помощи, предназначенный для заживления \
			механических и термических повреждений. Включает в себя комплект \
			гелей, антисептиков, заживляющих мембран и лечебных пластырей на основе синтплоти."
	icon_state = "synthkit_4"
	item_state = "traumakit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 12
	heal_burn = 12
	amount = 8
	max_amount = 8
	stop_bleeding = 0
	use_duration = 1.5 SECONDS
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/bruise_pack/synthflesh_kit

/obj/item/stack/medical/bruise_pack/synthflesh_kit/get_ru_names()
	return list(
		NOMINATIVE = "набор для лечения из синтплоти",
		GENITIVE = "набора для лечения из синтплоти",
		DATIVE = "набору для лечения из синтплоти",
		ACCUSATIVE = "набор для лечения из синтплоти",
		INSTRUMENTAL = "набором для лечения из синтплоти",
		PREPOSITIONAL = "наборе для лечения из синтплоти"
	)

/obj/item/stack/medical/bruise_pack/synthflesh_kit/update_icon_state()
	icon_state = "synthkit_[round_down((amount+1) / 2, 1)]"

/obj/item/stack/medical/bruise_pack/synthflesh_kit/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_damage_bodypart))

// MARK: Medical Herbs

/obj/item/stack/medical/bruise_pack/comfrey
	name = "Comfrey leaf"
	singular_name = "Comfrey leaf"
	desc = "Крупный зелёный лист, покрытый шершавыми волосками. \
			Обладает противовоспалительным и обезболивающим эффектом при локальном применении, \
			ускоряет заживление тканей при механических повреждениях."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "tea_aspera_leaves"
	color = "#378C61"
	stop_bleeding = 0
	heal_brute = 12
	drop_sound = 'sound/misc/moist_impact.ogg'
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	hitsound = 'sound/misc/moist_impact.ogg'
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/bruise_pack/comfrey
	var/max_heal = 30

/obj/item/stack/medical/bruise_pack/comfrey/get_ru_names()
	return list(
		NOMINATIVE = "лист окопника",
		GENITIVE = "листа окопника",
		DATIVE = "листу окопника",
		ACCUSATIVE = "лист окопника",
		INSTRUMENTAL = "листом окопника",
		PREPOSITIONAL = "листе окопника"
	)

/obj/item/stack/medical/bruise_pack/comfrey/update_icon_state()
	return

/obj/item/stack/medical/bruise_pack/comfrey/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_brute_damage_bodypart))

/obj/item/stack/medical/ointment/aloe
	name = "Aloe Vera leaf"
	singular_name = "Aloe Vera leaf"
	desc = "Вытянутый лист зелёного цвета с маленькими колючками на краях. \
			Обладает увлажняющим и противовоспалительным эффектом при локальном применении, \
			ускоряет заживление тканей при термических повреждениях."
	gender = MALE
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "aloe"
	color = "#4CC5C7"
	heal_burn = 12
	merge_type = /obj/item/stack/medical/ointment/aloe
	var/max_heal = 30

/obj/item/stack/medical/ointment/aloe/get_ru_names()
	return list(
		NOMINATIVE = "лист алоэ-вера",
		GENITIVE = "листа алоэ-вера",
		DATIVE = "листу алоэ-вера",
		ACCUSATIVE = "лист алоэ-вера",
		INSTRUMENTAL = "листом алоэ-вера",
		PREPOSITIONAL = "листе алоэ-вера"
	)

/obj/item/stack/medical/ointment/aloe/update_icon_state()
	return

// MARK: Splints

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	desc = "Стандартная медицинская шина, предназначенная для \
			иммобилизации сломанных конечностей до получения полноценной медицинской помощи."
	gender = FEMALE
	icon_state = "splint"
	item_state = "splint"
	unique_handling = TRUE
	self_delay = 10 SECONDS
	energy_type = /datum/robot_energy_storage/splint
	var/static/list/available_splint_zones = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
	)
	use_flags = DA_IGNORE_LYING
	merge_type = /obj/item/stack/medical/splint

/obj/item/stack/medical/splint/get_ru_names()
	return list(
		NOMINATIVE = "медицинская шина",
		GENITIVE = "медицинской шины",
		DATIVE = "медицинской шине",
		ACCUSATIVE = "медицинскую шину",
		INSTRUMENTAL = "медицинской шиной",
		PREPOSITIONAL = "медицинской шине"
	)

/obj/item/stack/medical/splint/attack(mob/living/carbon/human/target, mob/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(target))
		return .

	var/selected_zone = get_priority_targeting(target, user, def_zone)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)

	if(!affecting.has_fracture())
		target.balloon_alert(user, "нечего фиксировать!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	. = ..()

	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	if(!get_amount())
		target.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	if(!(affecting.limb_zone in available_splint_zones))
		target.balloon_alert(user, "не является конечностью!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(affecting.is_splinted())
		target.balloon_alert(user, "здесь уже есть шина!")
		if(tgui_alert(user, "Вы хотите снять шину с [affecting.declent_ru(GENITIVE)] [target.declent_ru(GENITIVE)]?", "Снятие шины", list("Да", "Нет")) != "Да" || !target.Adjacent(user))
			return ATTACK_CHAIN_BLOCKED_ALL
		affecting.remove_splint()
		target.balloon_alert(user, "шина снята")
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	user.visible_message(
		span_notice("[user] накладыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(ACCUSATIVE)][target == user ? "" : " [target.declent_ru(GENITIVE)]"]."),
		ignored_mobs = user,
	)
	target.balloon_alert(user, "шина наложена")

	affecting.apply_splint()

/obj/item/stack/medical/splint/tribal
	name = "tribal splints"
	desc = "Примитивная медицинская шина, созданная из пары костей, перевязанных связками Наблюдателя. \
			Предназначена для иммобилизации сломанных конечностей до получения полноценной медицинской помощи, \
			если таковая вообще возможна в суровых условиях Лазиса."
	icon_state = "tribal_splint"
	use_duration = 5 SECONDS
	merge_type = /obj/item/stack/medical/splint/tribal

/obj/item/stack/medical/splint/tribal/get_ru_names()
	return list(
		NOMINATIVE = "костяная шина",
		GENITIVE = "костяной шины",
		DATIVE = "костяной шине",
		ACCUSATIVE = "костяную шину",
		INSTRUMENTAL = "костяной шиной",
		PREPOSITIONAL = "костяной шине",
	)

/obj/item/stack/medical/splint/makeshift
	name = "makeshift splints"
	desc = "Самодельная медицинская шина, созданная из пары деревянных палок, перевязанных кусками ткани. \
			Предназначена для иммобилизации сломанных конечностей до получения полноценной медицинской помощи. \
			Сильно уступает стандартным аналогам в плане качества."
	icon_state = "makeshift_splint"
	use_duration = 5 SECONDS
	self_delay = 15 SECONDS
	merge_type = /obj/item/stack/medical/splint/makeshift


/obj/item/stack/medical/splint/makeshift/get_ru_names()
	return list(
		NOMINATIVE = "импровизированная шина",
		GENITIVE = "импровизированной шины",
		DATIVE = "импровизированной шине",
		ACCUSATIVE = "импровизированную шину",
		INSTRUMENTAL = "импровизированной шиной",
		PREPOSITIONAL = "импровизированной шине"
	)


// MARK: Suture

/obj/item/stack/medical/suture
	name = "suture kit"
	singular_name = "suture thread"
	desc = "Набор с хирургической иглой и специальной нитью для сшивания ран \
			в полевых условиях. Использование без обезболивающего не рекомендуется."
	icon_state = "suture_3"
	item_state = "suture"
	origin_tech = "biotech=3"
	var/bleeding_heal = 5
	var/damage = 5
	self_delay = 3 SECONDS
	use_duration = 2 SECONDS
	use_flags = DA_IGNORE_LYING
	energy_type = /datum/robot_energy_storage/medical
	merge_type = /obj/item/stack/medical/suture

/obj/item/stack/medical/suture/get_ru_names()
	return list(
		NOMINATIVE = "набор для зашивания ран",
		GENITIVE = "набора для зашивания ран",
		DATIVE = "набору для зашивания ран",
		ACCUSATIVE = "набор для зашивания ран",
		INSTRUMENTAL = "набором для зашивания ран",
		PREPOSITIONAL = "наборе для зашивания ран",
	)

/obj/item/stack/medical/suture/update_icon_state()
	icon_state = "suture_[round_down((amount+1) / 2, 1)]"

/obj/item/stack/medical/suture/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(target))
		return .

	var/selected_zone = get_priority_targeting(target, user, def_zone)
	var/obj/item/organ/external/affecting = target.get_organ(selected_zone)

	if(affecting.bleeding_amount <= 0)
		target.balloon_alert(user, "нечего зашивать!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	. = ..()

	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	if(!get_amount())
		target.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	if(affecting.open != ORGAN_CLOSED)
		target.balloon_alert(user, "неэффективно для такой раны!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	affecting.germ_level = 0
	if(affecting.bleeding_amount > 0)	//so you can't stack bleed suppression
		affecting.heal_bleeding(user, target, bleeding_heal, damage)
		var/obj/item/organ/external/addition_affecting = target.get_affecting_limb_bodypart(affecting)
		if(addition_affecting)
			addition_affecting.heal_bleeding(user, target, bleeding_heal, 0)
		target.updatehealth("[name] heal")
	target.balloon_alert(user, "рана зашита")
	target.UpdateDamageIcon()
	update_icon()

/obj/item/stack/medical/suture/get_priority_targeting(mob/living/target, mob/living/user)
	return get_priority_targeting_by_filter(target, user, PROC_REF(filter_max_bleeding_bodypart))

/obj/item/stack/medical/suture/advanced
	name = "advanced suture kit"
	singular_name = "advanced suture thread"
	desc = "Набор с хирургической иглой и специальной нитью для сшивания ран. \
			Позволяет эффективно устранять открытые кровотечения и механические повреждения."
	icon_state = "advanced_suture"
	item_state = "advanced_suture"
	origin_tech = "biotech=5"
	amount = 10
	max_amount = 10
	heal_brute = 10
	bleeding_heal = 10
	damage = 0
	self_delay = 2 SECONDS
	use_duration = 0.7 SECONDS
	merge_type = /obj/item/stack/medical/suture/advanced

/obj/item/stack/medical/suture/advanced/get_ru_names()
	return list(
		NOMINATIVE = "хирургический набор для зашивания ран",
		GENITIVE = "хирургического набора для зашивания ран",
		DATIVE = "хирургическому набору для зашивания ран",
		ACCUSATIVE = "хирургический набор для зашивания ран",
		INSTRUMENTAL = "хирургическим набором для зашивания ран",
		PREPOSITIONAL = "хирургическому наборе для зашивания ран",
	)

/obj/item/stack/medical/suture/advanced/update_icon_state()
	icon_state = "advanced_suture[amount < max_amount ? "_open" : ""]"

// MARK: Tourniquet
/obj/item/tourniquet
	name = "tourniquet"
	desc = "Медицинский турникет для экстренной остановки артериального и венозного кровотечения на конечностях. \
			Не предназначен для наложения на другие части тела. \
			Длительное использование без последующей медицинской помощи ведёт к некрозу тканей."
	icon = 'icons/obj/medicine/packs.dmi'
	icon_state = "tourniquet"
	item_state = "tourniquet"
	origin_tech = "biotech=3"
	w_class = WEIGHT_CLASS_TINY
	/// Duration to apply self
	var/self_duration = 5 SECONDS
	/// Duration to apply other mobs
	var/other_duration = 3 SECONDS
	/// Removing duration
	var/remove_duration = 3 SECONDS
	/// Bodypart where applied tourniquet
	var/obj/item/organ/external/applied_bodypart = null
	/// Addition bodypart on which tourniquet is applied  (hand for arm, foot for leg)
	var/obj/item/organ/external/applied_addition_bodypart = null
	/// Duration of limb necrotize warning in chat
	var/necrotize_warning_duration = 2 MINUTES
	/// Limb necrotize warning timer identifier
	var/necrotize_warning_timer_id = null
	/// Duration of limb necrotize if apply tourniquet
	var/necrotize_duration = 3 MINUTES
	/// Limb necrotize timer identifier if apply tourniquet
	var/necrotize_timer_id = null

/obj/item/tourniquet/Destroy()
	. = ..()
	applied_bodypart = null
	applied_addition_bodypart = null
	stop_apply_timers()

/obj/item/tourniquet/proc/stop_apply_timers()
	if(necrotize_warning_timer_id)
		deltimer(necrotize_warning_timer_id)
		necrotize_warning_timer_id = null
	if(!necrotize_timer_id)
		return

	deltimer(necrotize_timer_id)
	necrotize_timer_id = null

/obj/item/tourniquet/get_ru_names()
	return list(
		NOMINATIVE = "турникет",
		GENITIVE = "турникета",
		DATIVE = "турникету",
		ACCUSATIVE = "турникет",
		INSTRUMENTAL = "турникетом",
		PREPOSITIONAL = "турникете"
	)

/obj/item/tourniquet/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!ishuman(target))
		return .

	if(!acceptable_zone(user.zone_selected))
		target.balloon_alert(user, "не является конечностью!")
		return .

	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/external/affecting = human_target.get_organ(user.zone_selected)
	var/obj/item/organ/external/addition_affecting = human_target.get_affecting_limb_bodypart(affecting)
	if(affecting.tourniquet)
		target.balloon_alert(user, "уже наложено!")
		return .

	if(human_target == user)
		if(!apply_to_self(human_target, affecting, addition_affecting))
			return .
	else if(!apply_to_other(user, human_target, affecting, addition_affecting))
		return .

	affecting.tourniquet = src
	applied_bodypart = affecting
	if(addition_affecting)
		addition_affecting.tourniquet = src
		applied_addition_bodypart = addition_affecting

	user.drop_item_ground(src)
	src.forceMove(affecting)
	target.balloon_alert(user, "турникет наложен")
	target.UpdateDamageIcon()
	update_icon()
	necrotize_warning_timer_id = addtimer(CALLBACK(src, PROC_REF(necrotize_limbs_warning), target), necrotize_warning_duration, TIMER_STOPPABLE)
	necrotize_timer_id = addtimer(CALLBACK(src, PROC_REF(necrotize_limbs), target), necrotize_duration, TIMER_STOPPABLE)

/obj/item/tourniquet/proc/apply_to_self(mob/living/carbon/human/user, obj/item/organ/external/affecting, obj/item/organ/external/addition_affecting)
	var/selected_zone = user.zone_selected

	user.visible_message(
		span_notice("[user] накладыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(ACCUSATIVE)]."),
		blind_message = span_hear("Вы слышите звук стягивания чего-то."),
		ignored_mobs = user,
	)
	balloon_alert(user, "наложение на [GLOB.body_zone[affecting.limb_zone][ACCUSATIVE]]...")

	if(!do_after(user, self_duration, user, DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_LYING) || applied_bodypart)
		return

	var/obj/item/organ/external/affecting_rechecked = user.get_organ(selected_zone)
	if(!affecting_rechecked)
		balloon_alert(user, "конечность отсутствует!")
		return

	if(affecting_rechecked.tourniquet)
		balloon_alert(user, "турникет уже наложен!")
		return

	if(affecting_rechecked.is_robotic())
		balloon_alert(user, "неорганическая конечность!")
		return

	return TRUE

/obj/item/tourniquet/proc/apply_to_other(mob/living/user, mob/living/carbon/human/human_target, obj/item/organ/external/affecting, obj/item/organ/external/addition_affecting)
	var/selected_zone = user.zone_selected

	user.visible_message(
		span_notice("[user] накладыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] на [affecting.declent_ru(ACCUSATIVE)] [human_target.declent_ru(GENITIVE)]."),
		blind_message = span_hear("Вы слышите звук стягивания чего-то."),
		ignored_mobs = user,
	)
	human_target.balloon_alert(user, "наложение на [GLOB.body_zone[affecting.limb_zone][ACCUSATIVE]]...")

	if(!do_after(user, other_duration, human_target) || applied_bodypart)
		return

	var/obj/item/organ/external/affecting_rechecked = human_target.get_organ(selected_zone)
	if(!affecting_rechecked)
		human_target.balloon_alert(user, "конечность отсутствует!")
		return

	if(affecting_rechecked.tourniquet)
		human_target.balloon_alert(user, "турникет уже наложен!")
		return

	if(affecting_rechecked.is_robotic())
		human_target.balloon_alert(user, "неорганическая конечность!")
		return

	return TRUE

/obj/item/tourniquet/proc/necrotize_limbs_warning(mob/living/user)
	if(!applied_bodypart)
		return

	to_chat(user, span_danger("Ваш[GEND_A_E_I(user)] [applied_bodypart.declent_ru(NOMINATIVE)] неме[PLUR_ET_YUT(applied_bodypart)]!"))

/obj/item/tourniquet/proc/necrotize_limbs(mob/living/target)
	if(applied_bodypart)
		applied_bodypart.necrotize()
	if(!applied_addition_bodypart)
		return

	applied_addition_bodypart.necrotize()

/obj/item/tourniquet/proc/remove_from_bodypart(mob/living/user)
	if(!applied_bodypart)
		return FALSE

	applied_bodypart.owner.balloon_alert(user, "снятие турникета...")
	if(!do_after(user, remove_duration, applied_bodypart.owner) || !applied_bodypart)
		return FALSE

	var/drop_loc = applied_bodypart.drop_location()
	src.forceMove(drop_loc)
	applied_bodypart.owner.balloon_alert(user, "турникет снят")
	applied_bodypart.tourniquet = null
	applied_bodypart = null

	if(applied_addition_bodypart)
		applied_addition_bodypart.tourniquet = null
		applied_addition_bodypart = null

	stop_apply_timers()
	user.put_in_any_hand_if_possible(src)
	return TRUE

/obj/item/tourniquet/proc/acceptable_zone(zone_selected)
	// allow arms
	if(zone_selected == BODY_ZONE_L_ARM || zone_selected == BODY_ZONE_R_ARM)
		return TRUE
	// allow legs
	if(zone_selected == BODY_ZONE_L_LEG || zone_selected == BODY_ZONE_R_LEG)
		return TRUE
	// not accept for chest, groin, head
	return FALSE

/mob/living/carbon/human/proc/exists_tourniquet()
	for(var/obj/item/organ/external/affecting as anything in bodyparts)
		if(affecting.tourniquet)
			return TRUE

	return FALSE

/mob/living/carbon/human/proc/cut_all_tourniquets(mob/living/user)
	for(var/obj/item/organ/external/affecting as anything in bodyparts)
		if(!affecting.tourniquet)
			continue
		var/obj/item/tourniquet/tourniquet = affecting.tourniquet
		var/drop_loc = affecting.drop_location()
		tourniquet.forceMove(drop_loc)
		affecting.tourniquet = null
		tourniquet.applied_bodypart = null

		if(tourniquet.applied_addition_bodypart)
			tourniquet.applied_addition_bodypart.tourniquet = null
			tourniquet.applied_addition_bodypart = null

		tourniquet.stop_apply_timers()

/obj/item/tourniquet/makeshift
	name = "makeshift tourniquet"
	desc = "Импровизированный турникет для временной остановки кровотечения на конечностях. \
			Жутко неудобный, но со своей задачей справится. Не предназначен для длительного использования."
	icon_state = "makeshift_tourniquet"
	item_state = "makeshift_tourniquet"
	self_duration = 8 SECONDS
	other_duration = 5 SECONDS

/obj/item/tourniquet/makeshift/remove_from_bodypart(mob/living/user)
	if(..())
		QDEL_NULL(src)

/obj/item/tourniquet/makeshift/get_ru_names()
	return list(
		NOMINATIVE = "самодельный турникет",
		GENITIVE = "самодельного турникета",
		DATIVE = "самодельному турникету",
		ACCUSATIVE = "самодельный турникет",
		INSTRUMENTAL = "самодельным турникетом",
		PREPOSITIONAL = "самодельном турникете"
	)

/obj/item/tourniquet/advanced
	name = "advanced tourniquet"
	desc = "Медицинский турникет нового поколения для экстренной остановки артериального и венозного кровотечения на конечностях. \
			Оснащён механизмом контроля давления, что повышает удобство применения и его эффективность по сравнению с аналогами. \
			Длительное использование без последующей медицинской помощи ведёт к некрозу тканей."
	icon_state = "advanced_tourniquet"
	item_state = "advanced_tourniquet"
	self_duration = 3 SECONDS
	other_duration = 2 SECONDS
	remove_duration = 1 SECONDS

/obj/item/tourniquet/advanced/get_ru_names()
	return list(
		NOMINATIVE = "продвинутый турникет",
		GENITIVE = "продвинутого турникета",
		DATIVE = "продвинутому турникету",
		ACCUSATIVE = "продвинутый турникет",
		INSTRUMENTAL = "продвинутым турникетом",
		PREPOSITIONAL = "продвинутом турникете"
	)
