/obj/item/stack/medical
	name = "medical pack"
	gender = MALE
	icon = 'icons/obj/items.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	material_stack = FALSE
	var/heal_brute = 0
	var/heal_burn = 0
	var/self_delay = 20
	var/unique_handling = FALSE //some things give a special prompt, do we want to bypass some checks in parent?
	var/stop_bleeding = 0
	var/healverb = ""
	var/healverb_self = ""


/obj/item/stack/medical/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) && !isanimal(target))
		user.balloon_alert(user, "неподходящая цель!")
		return .

	if(!user.IsAdvancedToolUser())
		user.balloon_alert(user, "вы слишком неуклюжи для этого!")
		return .

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/selected_zone = user.zone_selected
		var/obj/item/organ/external/affecting = human_target.get_organ(selected_zone)

		if(isgolem(human_target))
			user.balloon_alert(user, "неподходящая цель!")
			return .

		if(human_target.covered_with_thick_material(selected_zone))
			user.balloon_alert(user, "часть тела чем-то перекрыта!")
			return .

		if(!affecting)
			user.balloon_alert(user, "часть тела отсутствует!")
			return .

		if(affecting.is_robotic())
			user.balloon_alert(user, "часть тела неорганическая!")
			return .

		if(human_target == user && !unique_handling)
			user.visible_message(
				span_notice("[human_target] начина[pluralize_ru(human_target.gender, "ет", "ют")] использовать [declent_ru(ACCUSATIVE)] на себе."),
				span_notice("Вы начинаете использовать [declent_ru(ACCUSATIVE)] на себе."),
			)
			if(!do_after(human_target, self_delay, human_target, NONE))
				return .

			var/obj/item/organ/external/affecting_rechecked = human_target.get_organ(selected_zone)
			if(!affecting_rechecked)
				user.balloon_alert(user, "часть тела отсутствует!")
				return .

			if(human_target.covered_with_thick_material(selected_zone))
				user.balloon_alert(user, "часть тела чем-то перекрыта!")
				return .

			if(affecting_rechecked.is_robotic())
				user.balloon_alert(user, "часть тела неорганическая!")
				return .

		return .|ATTACK_CHAIN_SUCCESS

	if(isanimal(target))
		var/mob/living/simple_animal/critter = target
		if(!(critter.healable))
			user.balloon_alert(user, "неподходящая цель!")
			return .
		if (critter.health == critter.maxHealth)
			user.balloon_alert(user, "цель не нуждается в лечении!")
			return .
		if(heal_brute < 1)
			user.balloon_alert(user, "использование на этой цели бессмысленно!")
			return .
		if(!use(1))
			return .
		critter.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message(
			span_green("[user] использу[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] на [critter.declent_ru(PREPOSITIONAL)]."),
			span_green("Вы используете [declent_ru(ACCUSATIVE)] на [critter.declent_ru(PREPOSITIONAL)]."),
		)

		return .|ATTACK_CHAIN_SUCCESS

	if(!use(1))
		return .

	target.heal_organ_damage(heal_brute, heal_burn)
	user.visible_message(
		span_green("[user] использу[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] на [target.declent_ru(PREPOSITIONAL)]."),
		span_green("Вы используете [declent_ru(ACCUSATIVE)] на [target.declent_ru(PREPOSITIONAL)]."),
	)
	return .|ATTACK_CHAIN_SUCCESS


/obj/item/stack/medical/proc/human_heal(mob/living/carbon/human/H, mob/user)
	var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)
	user.visible_message(
		span_green("[user] [genderize_decode(user, healverb)] на [affecting.declent_ru(PREPOSITIONAL)] [H]."),
		span_green("Вы [healverb_self] на [affecting.declent_ru(PREPOSITIONAL)] [H].")
	)

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
		var/obj/item/organ/external/E
		if(LAZYLEN(achildlist))
			E = pick_n_take(achildlist) // Pick a random children and then remove it from the list
		else if(affecting.parent && !parenthealed) // If there's a parent and no healing attempt was made on it
			E = affecting.parent
			parenthealed = TRUE
		else
			break // If the organ have no child left and no parent / parent healed, break
		if(E.is_robotic() || E.open) // Ignore robotic or open limb
			continue
		else if(!E.brute_dam && !E.burn_dam) // Ignore undamaged limb
			continue
		nrembrute = max(0, rembrute - E.brute_dam) // Deduct the healed damage from the remain
		nremburn = max(0, remburn - E.burn_dam)
		var/brute_was = E.brute_dam
		var/burn_was = E.burn_dam
		update_damage_icon |= E.heal_damage(rembrute, remburn, updating_health = FALSE)
		if(E.brute_dam != brute_was || E.burn_dam != burn_was)
			should_update_health = TRUE
		rembrute = nrembrute
		remburn = nremburn
		user.visible_message(
			span_green("[user] [genderize_decode(user, healverb)] на [E.declent_ru(PREPOSITIONAL)] [H]."),
			span_green("Вы [healverb_self] на [E.declent_ru(PREPOSITIONAL)] [H].")
		)
	if(should_update_health)
		H.updatehealth("[name] heal")
	if(update_damage_icon)
		H.UpdateDamageIcon()

//Bruise Packs//
/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	desc = "Отрезок марли, скатанный в аккуратный рулон с фиксаторами на конце. \
			Используется в качестве бинта для лечения механически повреждённых тканей и остановки кровотечения."
	ru_names = list(
		NOMINATIVE = "рулон марли",
		GENITIVE = "рулона марли",
		DATIVE = "рулону марли",
		ACCUSATIVE = "рулон марли",
		INSTRUMENTAL = "рулоном марли",
		PREPOSITIONAL = "рулон марли"
	)
	icon_state = "gauze"
	item_state = "gauze"
	origin_tech = "biotech=2"
	healverb = "бинту%(ет,ют)% раны рулоном марли"
	healverb_self = "бинтуете раны рулоном марли"
	heal_brute = 10
	stop_bleeding = 1800
	energy_type = /datum/robot_energy_storage/medical
	cost = 1

/obj/item/stack/medical/bruise_pack/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/bruise_pack/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
		add_fingerprint(user)
		var/atom/drop_loc = drop_location()
		if(!use(2))
			user.balloon_alert(user, "слишком мало для разрезания!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/stack/sheet/cloth/cloth = new(drop_loc)
		cloth.add_fingerprint(user)
		user.visible_message(
			span_notice("[user] разреза[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] на куски ткани, используя [I.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы разрезаете [declent_ru(ACCUSATIVE)] на куски ткани, используя [I.declent_ru(ACCUSATIVE)]."),
			span_italics("Вы слышите звук рвущейся ткани."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .

	if(!get_amount())
		user.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	var/obj/item/organ/external/affecting = target.get_organ(user.zone_selected)
	if(affecting.open != ORGAN_CLOSED)
		user.balloon_alert(user, "неэффективно для такой раны!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	affecting.germ_level = 0

	if(stop_bleeding && !target.bleedsuppress)	//so you can't stack bleed suppression
		target.suppress_bloodloss(stop_bleeding)

	human_heal(target, user)
	target.UpdateDamageIcon()


/obj/item/stack/medical/bruise_pack/improvised
	name = "improvised gauze"
	desc = "Отрезок ткани, скатанный в некое подобие бинта. \
			Способен остановить кровотечение, но не подойдёт для лечения механических повреждений."
	ru_names = list(
		NOMINATIVE = "импровизированный бинт",
		GENITIVE = "импровизированного бинта",
		DATIVE = "импровизированному бинту",
		ACCUSATIVE = "импровизированный бинт",
		INSTRUMENTAL = "импровизированным бинтом",
		PREPOSITIONAL = "импровизированном бинте"
	)
	healverb = "бинту%(ет,ют)% раны импровизированным бинтом"
	healverb_self = "бинтуете раны импровизированным бинтом"
	stop_bleeding = 900

/obj/item/stack/medical/bruise_pack/advanced
	name = "advanced trauma kit"
	desc = "Стандартный набор первой помощи, предназначенный для лечения повреждений механического характера. \
			Включает в себя набор гелей, антисептиков, заживляющих мембран и лечебных пластырей."
	ru_names = list(
		NOMINATIVE = "набор для лечения травм",
		GENITIVE = "набора для лечения травм",
		DATIVE = "набору для лечения травм",
		ACCUSATIVE = "набор для лечения травм",
		INSTRUMENTAL = "набором для лечения травм",
		PREPOSITIONAL = "наборе для лечения травм"
	)
	icon_state = "traumakit"
	item_state = "traumakit"
	belt_icon = "advanced_trauma_kit"
	healverb = "заживля%(ет,ют)% раны набором для лечения травм"
	healverb_self = "заживляете раны набором для лечения травм"
	heal_brute = 25
	stop_bleeding = 0


/obj/item/stack/medical/bruise_pack/advanced/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/bruise_pack/extended
	name = "extended trauma kit"
	desc = "Продвинутый набор первой помощи, предназначенный для лечения тяжёлых повреждений механического характера. \
			Включает в себя набор гелей, антисептиков, заживляющих мембран, \
			лечебных пластырей, местных обезболивающих и травматических повязок."
	ru_names = list(
		NOMINATIVE = "продвинутый набор для лечения травм",
		GENITIVE = "продвинутого набора для лечения травм",
		DATIVE = "продвинутому набору для лечения травм",
		ACCUSATIVE = "продвинутый набор для лечения травм",
		INSTRUMENTAL = "продвинутым набором для лечения травм",
		PREPOSITIONAL = "продвинутом наборе для лечения травм"
	)
	icon_state = "extended_trauma_kit"
	item_state = "extended_trauma_kit"
	belt_icon = "advanced_trauma_kit"
	healverb = "заживля%(ет,ют)% раны продвинутым набором для лечения травм"
	healverb_self = "заживляете раны продвинутым набором для лечения травм"
	heal_brute = 30
	stop_bleeding = 0
	amount = 12
	max_amount = 12


//Ointment//
/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Тюбик медицинской мази, предназначенной для местного применения при лечении ожогов различного характера. \
			Обладает антисептическим, обезболивающим и охлаждающим действием."
	ru_names = list(
		NOMINATIVE = "тюбик мази от ожогов",
		GENITIVE = "тюбика мази от ожогов",
		DATIVE = "тюбику мази от ожогов",
		ACCUSATIVE = "тюбик мази от ожогов",
		INSTRUMENTAL = "тюбиком мази от ожогов",
		PREPOSITIONAL = "тюбике мази от ожогов"
	)
	icon_state = "ointment"
	origin_tech = "biotech=2"
	healverb = "нанос%(ит,ят)% на ожоги противоожоговую мазь из тюбика"
	healverb_self = "наносите на ожоги противоожоговую мазь из тюбика"
	heal_burn = 10
	cost = 1
	energy_type = /datum/robot_energy_storage/medical

/obj/item/stack/medical/ointment/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate


/obj/item/stack/medical/ointment/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .

	if(!get_amount())
		user.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	var/obj/item/organ/external/affecting = target.get_organ(user.zone_selected)
	if(affecting.open != ORGAN_CLOSED)
		user.balloon_alert(user, "неэффективно для такой раны!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	affecting.germ_level = 0
	human_heal(target, user)
	target.UpdateDamageIcon()


/obj/item/stack/medical/ointment/advanced
	name = "advanced burn kit"
	desc = "Стандартный набор первой помощи, предназначенный для лечения ожогов различного характера. \
			Включает в себя набор гелей, антисептиков, заживляющих мембран и лечебных пластырей."
	ru_names = list(
		NOMINATIVE = "набор для лечения ожогов",
		GENITIVE = "набора для лечения ожогов",
		DATIVE = "набору для лечения ожогов",
		ACCUSATIVE = "набор для лечения ожогов",
		INSTRUMENTAL = "набором для лечения ожогов",
		PREPOSITIONAL = "наборе для лечения ожогов"
	)
	icon_state = "burnkit"
	item_state = "burnkit"
	belt_icon = "advanced_burn_kit"
	healverb = "заживля%(ет,ют)% ожоги набором для лечения ожогов"
	healverb_self = "заживляете ожоги набором для лечения ожогов"
	heal_burn = 25

/obj/item/stack/medical/ointment/advanced/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/ointment/extended
	name = "extended burn kit"
	desc = "Продвинутый набор первой помощи, предназначенный для лечения тяжёлых ожогов различного характера. \
			Включает в себя набор гелей, антисептиков, заживляющих мембран, \
			лечебных пластырей и местных обезболивающих."
	ru_names = list(
		NOMINATIVE = "продвинутый набор для лечения ожогов",
		GENITIVE = "продвинутого набора для лечения ожогов",
		DATIVE = "продвинутому набору для лечения ожогов",
		ACCUSATIVE = "продвинутый набор для лечения ожогов",
		INSTRUMENTAL = "продвинутым набором для лечения ожогов",
		PREPOSITIONAL = "продвинутом наборе для лечения ожогов"
	)
	icon_state = "extended_burn_kit"
	item_state = "extended_burn_kit"
	belt_icon = "advanced_burn_kit"
	healverb = "заживля%(ет,ют)% ожоги продвинутым набором для лечения ожогов"
	healverb_self = "заживляете ожоги продвинутым набором для лечения ожогов"
	heal_burn = 30
	amount = 12
	max_amount = 12

//Medical Herbs//
/obj/item/stack/medical/bruise_pack/comfrey
	name = "\improper Comfrey leaf"
	desc = "Крупный зелёный лист, покрытый шершавыми волосками. \
			Обладает противовоспалительным и обезболивающим эффектом при локальном применении, \
			ускоряет заживление тканей при механических повреждениях."
	ru_names = list(
		NOMINATIVE = "лист окопника",
		GENITIVE = "листа окопника",
		DATIVE = "листу окопника",
		ACCUSATIVE = "лист окопника",
		INSTRUMENTAL = "листом окопника",
		PREPOSITIONAL = "листе окопника"
	)
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "tea_aspera_leaves"
	color = "#378C61"
	stop_bleeding = 0
	healverb = "прикладыва%(ет,ют)% лист окопника к ранам"
	healverb_self = "прикладываете лист окопника к ранам"
	heal_brute = 12
	drop_sound = 'sound/misc/moist_impact.ogg'
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	hitsound = 'sound/misc/moist_impact.ogg'


/obj/item/stack/medical/ointment/aloe
	name = "\improper Aloe Vera leaf"
	desc = "Вытянутый лист зелёного цвета с маленькими колючками на краях. \
			Обладает увлажняющим и противовоспалительным эффектом при локальном применении, \
			ускоряет заживление тканей при термических повреждениях."
	ru_names = list(
		NOMINATIVE = "лист алоэ-вера",
		GENITIVE = "листа алоэ-вера",
		DATIVE = "листу алоэ-вера",
		ACCUSATIVE = "лист алоэ-вера",
		INSTRUMENTAL = "листом алоэ-вера",
		PREPOSITIONAL = "листе алоэ-вера"
	)
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "aloe"
	color = "#4CC5C7"
	healverb = "прикладыва%(ет,ют)% лист алоэ-вера к ожогам"
	healverb_self = "прикладываете лист алоэ-вера к ожогам"
	heal_burn = 12


// Splints
/obj/item/stack/medical/splint
	name = "medical splints"
	desc = "Стандартная медицинская шина, предназначенная для \
			иммобилизации сломанных конечностей до получения полноценной медицинской помощи."
	ru_names = list(
		NOMINATIVE = "медицинская шина",
		GENITIVE = "медицинской шины",
		DATIVE = "медицинской шине",
		ACCUSATIVE = "медицинскую шину",
		INSTRUMENTAL = "медицинской шиной",
		PREPOSITIONAL = "медицинской шине"
	)
	gender = FEMALE
	icon_state = "splint"
	item_state = "splint"
	unique_handling = TRUE
	self_delay = 10 SECONDS
	energy_type = /datum/robot_energy_storage/splint
	cost = 1
	var/other_delay = 0
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

/obj/item/stack/medical/splint/attack(mob/living/carbon/human/target, mob/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .

	if(!get_amount())
		user.balloon_alert(user, "недостаточно!")
		return ATTACK_CHAIN_PROCEED

	var/obj/item/organ/external/bodypart = target.get_organ(user.zone_selected)

	if(!(bodypart.limb_zone in available_splint_zones))
		user.balloon_alert(user, "не является конечностью!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(bodypart.is_splinted())
		user.balloon_alert(user, "здесь уже есть шина!")
		if(tgui_alert(user, "Вы хотите снять шину с [bodypart.declent_ru(GENITIVE)] [target]?", "Снятие шины", list("Да", "Нет")) != "Да" || !target.Adjacent(user))
			return ATTACK_CHAIN_BLOCKED_ALL
		bodypart.remove_splint()
		to_chat(user, span_notice("Вы снимаете шину с [bodypart.declent_ru(GENITIVE)] [target]."))
		return .

	if((target == user && self_delay > 0) || (target != user && other_delay > 0))
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] накладывать [declent_ru(ACCUSATIVE)] на [target == user ? "сво[genderize_ru(bodypart.gender, "й", "ю", "ё", "и")] [bodypart.declent_ru(ACCUSATIVE)]" : "[bodypart.declent_ru(ACCUSATIVE)] [target]"]."),
			span_notice("Вы начинаете накладывать [declent_ru(ACCUSATIVE)] на [target == user ? "сво[genderize_ru(bodypart.gender, "й", "ю", "ё", "и")] [bodypart.declent_ru(ACCUSATIVE)]" : "[bodypart.declent_ru(ACCUSATIVE)] [target]"]."),
			span_italics("Вы слышите, как что-то оборачивают вокруг чего."),
		)

	if(target == user && !do_after(user, self_delay, target, NONE))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	else if(!do_after(user, other_delay, target, NONE))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	user.visible_message(
			span_notice("[user] наклыдва[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] на [target == user ? "сво[genderize_ru(bodypart.gender, "й", "ю", "ё", "и")] [bodypart.declent_ru(ACCUSATIVE)]" : "[bodypart.declent_ru(ACCUSATIVE)] [target]"]."),
			span_notice("Вы накладываете [declent_ru(ACCUSATIVE)] на [target == user ? "сво[genderize_ru(bodypart.gender, "й", "ю", "ё", "и")] [bodypart.declent_ru(ACCUSATIVE)]" : "[bodypart.declent_ru(ACCUSATIVE)] [target]"]."),
	)

	bodypart.apply_splint()


/obj/item/stack/medical/splint/tribal
	name = "tribal splints"
	desc = "Примитивная медицинская шина, созданная из пары костей, перевязанных связками Наблюдателя. \
			Предназначена для иммобилизации сломанных конечностей до получения полноценной медицинской помощи, \
			если таковая вообще возможна в суровых условиях Лаваленда."
	ru_names = list(
		NOMINATIVE = "примитивная шина",
		GENITIVE = "примитивной шины",
		DATIVE = "примитивной шине",
		ACCUSATIVE = "примитивную шину",
		INSTRUMENTAL = "примитивной шиной",
		PREPOSITIONAL = "примитивной шине"
	)
	icon_state = "tribal_splint"
	other_delay = 5 SECONDS


/obj/item/stack/medical/splint/makeshift
	name = "makeshift splints"
	desc = "Самодельная медицинская шина, созданная из пары деревянных палок, перевязанных кусками ткани. \
			Предназначена для иммобилизации сломанных конечностей до получения полноценной медицинской помощи. \
			Сильно уступает стандартным вариантам в плане качества."
	ru_names = list(
		NOMINATIVE = "импровизированная шина",
		GENITIVE = "импровизированной шины",
		DATIVE = "импровизированной шине",
		ACCUSATIVE = "импровизированную шину",
		INSTRUMENTAL = "импровизированной шиной",
		PREPOSITIONAL = "импровизированной шине"
	)
	icon_state = "makeshift_splint"
	other_delay = 3 SECONDS
	self_delay = 15 SECONDS

