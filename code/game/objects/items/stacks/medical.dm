/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/medicine/packs.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/heal_brute = 0
	var/heal_burn = 0
	var/self_delay = 2 SECONDS
	var/unique_handling = FALSE //some things give a special prompt, do we want to bypass some checks in parent?
	var/stop_bleeding = 0
	var/bleedsuppress = 0
	var/healverb = "bandage"
	var/use_duration = 3 SECONDS
	merge_type = null // do not merge if not defined in subtype


/obj/item/stack/medical/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) && !isanimal(target))
		to_chat(user, span_danger("[capitalize(declent_ru(NOMINATIVE))] не может быть применен к [target]!"))
		return .

	if(!user.IsAdvancedToolUser())
		to_chat(user, span_danger("Вам не хватает навыков чтобы использовать [declent_ru(NOMINATIVE)]!"))
		return .

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/selected_zone = user.zone_selected
		var/obj/item/organ/external/affecting = human_target.get_organ(selected_zone)

		if(isgolem(human_target))
			to_chat(user, span_danger("[capitalize(declent_ru(NOMINATIVE))] нельзя оприменить на големах!"))
			return .

		if(human_target.covered_with_thick_material(selected_zone))
			to_chat(user, span_danger("Здесь слишком толстый слой материала для применения [declent_ru(NOMINATIVE)]."))
			return .

		if(!affecting)
			to_chat(user, span_danger("Часть тела отсутствует!"))
			return .

		if(affecting.is_robotic())
			to_chat(user, span_danger("[capitalize(declent_ru(NOMINATIVE))] нельзя применить на протезе!"))
			return .

		if(human_target == user && !unique_handling)
			user.visible_message(
				span_notice("[human_target] начина[pluralize_ru(human_target.gender,"ет","ют")] применять [declension_ru(NOMINATIVE)] на себе."),
				span_notice("Вы начинаете применять [declent_ru(NOMINATIVE)] на себе..."),
			)
			if(!do_after(human_target, self_delay, human_target, DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_LYING))
				return .

			var/obj/item/organ/external/affecting_rechecked = human_target.get_organ(selected_zone)
			if(!affecting_rechecked)
				to_chat(human_target, span_danger("Часть тела отсутствует!"))
				return .

			if(human_target.covered_with_thick_material(selected_zone))
				to_chat(human_target, span_danger("Здесь слишком толстый слой материала для применения [declent_ru(NOMINATIVE)]."))
				return .

			if(affecting_rechecked.is_robotic())
				to_chat(human_target, span_danger("[capitalize(declent_ru(NOMINATIVE))] нельзя применить на протезе!"))
				return .
		else
			user.visible_message(
				span_notice("[user] применя[pluralize_ru(user.gender,"ет","ют")] [declent_ru(NOMINATIVE)] на [human_target]."),
				span_notice("Вы начинаете применять [declent_ru(NOMINATIVE)] на [human_target]..."),
			)
			if(use_duration && !do_after(user, use_duration, human_target))
				return .
		return .|ATTACK_CHAIN_SUCCESS

	if(isanimal(target))
		var/mob/living/simple_animal/critter = target
		if(!(critter.healable))
			to_chat(user, span_danger("Вы не можете использовать [declent_ru(NOMINATIVE)] на [critter.declent_ru(NOMINATIVE)]!"))
			return .
		if (critter.health == critter.maxHealth)
			to_chat(user, span_danger("[capitalize(critter.declent_ru(NOMINATIVE))] полностью здоров."))
			return .
		if(heal_brute < 1)
			to_chat(user, span_danger("[capitalize(critter.declent_ru(NOMINATIVE))] никак не поможет [critter.declent_ru(DATIVE)]."))
			return .
		if(!use(1))
			return .
		critter.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message(
			span_green("[user] применя[pluralize_ru(user.gender,"ет","ют")] [declent_ru(NOMINATIVE)] на [critter.declent_ru(NOMINATIVE)]."),
			span_green("Вы применяете [declent_ru(NOMINATIVE)] на [critter.declent_ru(NOMINATIVE)]."),
		)

		return .|ATTACK_CHAIN_SUCCESS

	if(!use(1))
		return .

	target.heal_organ_damage(heal_brute, heal_burn)
	user.visible_message(
		span_green("[user] применя[pluralize_ru(user.gender,"ет","ют")] [declent_ru(NOMINATIVE)] к [target]."),
		span_green("Вы применяете [declent_ru(NOMINATIVE)] к [target]."),
	)
	return .|ATTACK_CHAIN_SUCCESS


/obj/item/stack/medical/proc/human_heal(mob/living/carbon/human/target, mob/user)
	var/obj/item/organ/external/affecting = target.get_organ(user.zone_selected)
	user.visible_message(
		span_green("[user] использу[pluralize_ru(user.gender,"ет","ют")] [declent_ru(NOMINATIVE)] на [affecting.declent_ru(ACCUSATIVE)] [target]."),
		span_green("Вы используете [declent_ru(NOMINATIVE)] на [affecting.declent_ru(ACCUSATIVE)] [target]."),
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
			span_green("[user] обрабатыва[pluralize_ru(user.gender,"ет","ют")] раны на [organ.declent_ru(ACCUSATIVE)] [target] остатками медикаментов."),
			span_green("Вы обрабатываете раны на [organ.declent_ru(ACCUSATIVE)] [target] остатками медикаментов."),
		)
	if(should_update_health)
		target.updatehealth("[name] heal")
	if(update_damage_icon)
		target.UpdateDamageIcon()


/obj/item/stack/medical/can_merge(obj/item/stack/check, inhand)
	if(check.type != merge_type)
		return FALSE
	. = ..()

// MARK: Bruise Packs

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "gauze_3"
	item_state = "gauze"
	origin_tech = "biotech=2"
	amount = 6
	max_amount = 6
	heal_brute = 5
	bleedsuppress = 5
	stop_bleeding = 180 SECONDS
	self_delay = 2 SECONDS
	use_duration = 2 SECONDS
	energy_type = /datum/robot_energy_storage/medical
	cost = 1
	merge_type = /obj/item/stack/medical/bruise_pack

/obj/item/stack/medical/bruise_pack/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/bruise_pack/attackby(obj/item/item, mob/user, params)
	if(is_sharp(item))
		add_fingerprint(user)
		var/atom/drop_loc = drop_location()
		if(!use(2))
			to_chat(user, span_warning("Вам нужно минимум 2 кусочка бинтов чтобы сделать это!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/stack/sheet/cloth/cloth = new(drop_loc)
		cloth.add_fingerprint(user)
		user.visible_message(
			span_notice("[user] разрезает [declent_ru(ACCUSATIVE)] на куски ткани при помощи [item.declent_ru(INSTRUMENTAL)]."),
			span_notice("Вы разрезаете [declent_ru(ACCUSATIVE)] на куски ткани при помощи [item.declent_ru(INSTRUMENTAL)]."),
			span_italics("Слышно звук разрезания."),
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
		to_chat(user, span_danger("Не хватает медикаментов!"))
		return ATTACK_CHAIN_PROCEED
	var/obj/item/organ/external/affecting = target.get_organ(user.zone_selected)
	if(affecting.open != ORGAN_CLOSED)
		to_chat(user, span_danger("[capitalize(affecting.declent_ru(NOMINATIVE))] открыта, тут уже не помочь бинтами!"))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	if(stop_bleeding && affecting.bleeding_amount <= affecting.bleedsuppress)	//so you can't stack bleed suppression
		balloon_alert(user, "кровотечения нет")
	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	affecting.germ_level = 0
	if(stop_bleeding && affecting.bleeding_amount > affecting.bleedsuppress)	//so you can't stack bleed suppression
		affecting.suppress_bloodloss(user, target, bleedsuppress, stop_bleeding)
	human_heal(target, user)
	target.UpdateDamageIcon()
	update_icon()


/obj/item/stack/medical/bruise_pack/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	stop_bleeding = 90 SECONDS
	icon_state = "gauze_imp_3"
	merge_type = /obj/item/stack/medical/bruise_pack/improvised

/obj/item/stack/medical/bruise_pack/improvised/update_icon_state()
	icon_state = "gauze_imp_[amount >= 5 ? 3 : (amount >= 3 ? 2 : 1)]"

/obj/item/stack/medical/bruise_pack/military
	name = "military emergency bandage"
	singular_name = "emergency bandage"
	desc = "Специальный комплект для быстрой остановки кровотечения по всему телу. Применяют в основном военными или тем кто работает в опасных условиях."
	icon_state = "bandage"
	item_state = "gauze"
	origin_tech = "biotech=2;combat=1"
	amount = 1
	max_amount = 1
	heal_brute = 0
	bleedsuppress = 5
	stop_bleeding = 300 SECONDS
	energy_type = /datum/robot_energy_storage/medical
	cost = 1
	self_delay = 2 SECONDS
	use_duration = 2 SECONDS

/obj/item/stack/medical/bruise_pack/military/get_ru_names()
	return list(
		NOMINATIVE = "военный перевязочный пакет",
		GENITIVE = "военного перевязочного пакета",
		DATIVE = "военному перевязочному пакету",
		ACCUSATIVE = "военный перевязочный пакет",
		INSTRUMENTAL = "военным перевязочным пакетом",
		PREPOSITIONAL = "военном перевязочном пакете"
	)

/obj/item/stack/medical/bruise_pack/military/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
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
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit_4"
	item_state = "traumakit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 40
	amount = 4
	max_amount = 4
	stop_bleeding = 0
	self_delay = 2 SECONDS
	use_duration = 1.5 SECONDS
	merge_type = /obj/item/stack/medical/bruise_pack/advanced

/obj/item/stack/medical/bruise_pack/advanced/update_icon_state()
	icon_state = "traumakit_[amount]"


/obj/item/stack/medical/bruise_pack/advanced/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/bruise_pack/extended
	name = "extended trauma kit"
	singular_name = "extended trauma kit"
	desc = "An extended trauma kit for severe injuries."
	icon_state = "extended_trauma_kit_5"
	item_state = "extended_trauma_kit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 40
	amount = 10
	max_amount = 10
	stop_bleeding = 0
	use_duration = 0
	self_delay = 1.5 SECONDS
	use_duration = 0.7 SECONDS
	merge_type = /obj/item/stack/medical/bruise_pack/extended

/obj/item/stack/medical/bruise_pack/extended/update_icon_state()
	icon_state = "extended_trauma_kit_[round_down((amount+1) / 2, 1)]"


// MARK: Ointment

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment_3"
	origin_tech = "biotech=2"
	healverb = "salve"
	heal_burn = 10
	amount = 6
	max_amount = 6
	self_delay = 2 SECONDS
	use_duration = 2 SECONDS
	cost = 1
	energy_type = /datum/robot_energy_storage/medical
	merge_type = /obj/item/stack/medical/ointment

/obj/item/stack/medical/ointment/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate


/obj/item/stack/medical/ointment/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .

	if(!get_amount())
		to_chat(user, span_danger("Not enough medical supplies!"))
		return ATTACK_CHAIN_PROCEED

	var/obj/item/organ/external/affecting = target.get_organ(user.zone_selected)
	if(affecting.open != ORGAN_CLOSED)
		to_chat(user, span_danger("[capitalize(affecting.declent_ru(NOMINATIVE))] открыта, тут уже не помочь мазью!"))
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
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit_4"
	item_state = "burnkit"
	belt_icon = "advanced_burn_kit"
	heal_burn = 40
	amount = 4
	max_amount = 4
	use_duration = 1.5 SECONDS
	merge_type = /obj/item/stack/medical/ointment/advanced

/obj/item/stack/medical/ointment/advanced/update_icon_state()
	icon_state = "burnkit_[amount]"

/obj/item/stack/medical/ointment/advanced/syndicate
	energy_type = /datum/robot_energy_storage/medical/syndicate

/obj/item/stack/medical/ointment/extended
	name = "extended burn kit"
	singular_name = "extended burn kit"
	desc = "An extended treatment kit for severe burns."
	icon_state = "extended_burn_kit_5"
	item_state = "extended_burn_kit"
	belt_icon = "advanced_burn_kit"
	heal_burn = 40
	amount = 10
	max_amount = 10
	self_delay = 1.5 SECONDS
	use_duration = 0.7 SECONDS
	merge_type = /obj/item/stack/medical/ointment/extended

/obj/item/stack/medical/ointment/extended/update_icon_state()
	icon_state = "extended_burn_kit_[round_down((amount+1) / 2, 1)]"


// MARK: Medical Herbs

/obj/item/stack/medical/bruise_pack/comfrey
	name = "Comfrey leaf"
	singular_name = "Comfrey leaf"
	desc = "A soft leaf that is rubbed on bruises."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "tea_aspera_leaves"
	color = "#378C61"
	stop_bleeding = 0
	heal_brute = 12
	self_delay = 2 SECONDS
	use_duration = 2 SECONDS
	drop_sound = 'sound/misc/moist_impact.ogg'
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	hitsound = 'sound/misc/moist_impact.ogg'
	merge_type = /obj/item/stack/medical/bruise_pack/comfrey
	var/max_heal = 40

/obj/item/stack/medical/bruise_pack/comfrey/update_icon_state()
	return


/obj/item/stack/medical/ointment/aloe
	name = "Aloe Vera leaf"
	singular_name = "Aloe Vera leaf"
	desc = "A cold leaf that is rubbed on burns."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "aloe"
	color = "#4CC5C7"
	heal_burn = 12
	self_delay = 2 SECONDS
	use_duration = 2 SECONDS
	merge_type = /obj/item/stack/medical/ointment/aloe
	var/max_heal = 40

/obj/item/stack/medical/ointment/aloe/update_icon_state()
	return


// MARK: Splints

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	item_state = "splint"
	unique_handling = TRUE
	self_delay = 10 SECONDS
	use_duration = 3 SECONDS
	energy_type = /datum/robot_energy_storage/splint
	cost = 1
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
	merge_type = /obj/item/stack/medical/splint

/obj/item/stack/medical/splint/attack(mob/living/carbon/human/target, mob/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .

	if(!get_amount())
		to_chat(user, span_danger("No splints left!"))
		return ATTACK_CHAIN_PROCEED

	var/obj/item/organ/external/bodypart = target.get_organ(user.zone_selected)
	var/bodypart_name = bodypart.name

	if(!(bodypart.limb_zone in available_splint_zones))
		to_chat(user, span_danger("You can't apply a splint there!"))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(bodypart.is_splinted())
		to_chat(user, span_danger("[target]'s [bodypart_name] is already splinted!"))
		if(tgui_alert(user, "Would you like to remove the splint from [target]'s [bodypart_name]?", "Splint removal", list("Yes", "No")) != "Yes" || !target.Adjacent(user))
			return ATTACK_CHAIN_BLOCKED_ALL
		bodypart.remove_splint()
		to_chat(user, span_notice("You remove the splint from [target]'s [bodypart_name]."))
		return .

	if((target == user && self_delay > 0) || (target != user && use_duration > 0))
		user.visible_message(
			span_notice("[user] starts to apply [src] to [target == user ? "[user.p_their()]" : "[target]'s"] [bodypart_name]."),
			span_notice("You start to apply [src] to [target == user ? "your" : "[target]'s"] [bodypart_name]."),
			span_italics("You hear something being wrapped."),
		)

	if(target == user && !do_after(user, self_delay, target, NONE))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	else if(use_duration && !do_after(user, use_duration, target, NONE))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	user.visible_message(
		span_notice("[user] applies [src] to [target == user ? "[user.p_their()]" : "[target]'s"] [bodypart_name]."),
		span_notice("You apply [src] to [target == user ? "your" : "[target]'s"] [bodypart_name]."),
	)

	bodypart.apply_splint()


/obj/item/stack/medical/splint/tribal
	name = "tribal splints"
	icon_state = "tribal_splint"
	use_duration = 5 SECONDS
	merge_type = /obj/item/stack/medical/splint/tribal

/obj/item/stack/medical/splint/tribal/get_ru_names()
	return list(
		NOMINATIVE = "племенная шина",
		GENITIVE = "племенной шины",
		DATIVE = "племенной шине",
		ACCUSATIVE = "племенную шину",
		INSTRUMENTAL = "племенной шиной",
		PREPOSITIONAL = "племенной шине"
	)


/obj/item/stack/medical/splint/makeshift
	name = "makeshift splints"
	desc = "Makeshift splint for fixing bones. Better than nothing and more based than others."
	icon_state = "makeshift_splint"
	use_duration = 5 SECONDS
	self_delay = 15 SECONDS
	merge_type = /obj/item/stack/medical/splint/makeshift


// MARK: Suture

/obj/item/stack/medical/suture
	name = "suture kit"
	singular_name = "suture thread"
	desc = "Набор с хирургической иглой и специальной нитью для сшивания ран. Останавливает кровотечение, но лучше использовать под обезбаливающими."
	icon_state = "suture_3"
	item_state = "suture"
	origin_tech = "biotech=3"
	amount = 6
	max_amount = 6
	heal_brute = 0
	stop_bleeding = 0
	var/bleeding_heal = 5
	var/damage = 10
	self_delay = 3 SECONDS
	use_duration = 2 SECONDS
	cost = 1
	energy_type = /datum/robot_energy_storage/medical
	merge_type = /obj/item/stack/medical/suture

/obj/item/stack/medical/suture/get_ru_names()
	return list(
		NOMINATIVE = "набор для зашивания ран",
		GENITIVE = "набора для зашивания ран",
		DATIVE = "набору для зашивания ран",
		ACCUSATIVE = "набор для зашивания ран",
		INSTRUMENTAL = "набором для зашивания ран",
		PREPOSITIONAL = "наборе для зашивания ран"
	)

/obj/item/stack/medical/suture/update_icon_state()
	icon_state = "suture_[round_down((amount+1) / 2, 1)]"

/obj/item/stack/medical/suture/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!ishuman(target))
		return .
	var/obj/item/organ/external/affecting = target.get_organ(user.zone_selected)
	if(affecting.bleeding_amount <= 0)
		user.balloon_alert(user, "нечего зашивать!")
		. &= ~ATTACK_CHAIN_SUCCESS
		return .
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	if(!get_amount())
		to_chat(user, span_danger("Не хватает ниток!"))
		return ATTACK_CHAIN_PROCEED


	if(affecting.open != ORGAN_CLOSED)
		to_chat(user, span_danger("[capitalize(affecting.declent_ru(NOMINATIVE))] открыта, это уже не сшить без помощи хирургических инструментов!"))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .


	if(!use(1))
		. &= ~ATTACK_CHAIN_SUCCESS
		return .

	affecting.germ_level = 0
	if(affecting.bleeding_amount > 0)	//so you can't stack bleed suppression
		affecting.heal_bleeding(user, target, bleeding_heal, damage)
		target.updatehealth("[name] heal")
	user.balloon_alert(user, "зашито!")
	target.UpdateDamageIcon()
	update_icon()


/obj/item/stack/medical/suture/advanced
	name = "advanced suture kit"
	singular_name = "advanced suture thread"
	desc = "Хирургический набор для сшивания ран. Останавливает все виды кровотечений, кроме артериальных или внутренних."
	icon_state = "advanced_suture"
	item_state = "advanced_suture"
	origin_tech = "biotech=5"
	amount = 10
	max_amount = 10
	heal_brute = 10
	stop_bleeding = 0
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
		PREPOSITIONAL = "хирургическому наборе для зашивания ран"
	)

/obj/item/stack/medical/suture/advanced/update_icon_state()
	icon_state = "advanced_suture[amount < max_amount ? "_open" : ""]"


// MARK: Synthflesh kit

/obj/item/stack/medical/bruise_pack/synthflesh_kit
	name = "synthflesh trauma kit"
	singular_name = "synthflesh trauma kit"
	desc = "Продвинутый набор для мех. и терм. повреждений."
	icon_state = "synthkit_4"
	item_state = "traumakit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 20
	heal_burn = 20
	amount = 4
	max_amount = 4
	stop_bleeding = 0
	self_delay = 2 SECONDS
	use_duration = 1.5 SECONDS
	merge_type = /obj/item/stack/medical/bruise_pack/synthflesh_kit

/obj/item/stack/medical/bruise_pack/synthflesh_kit/update_icon_state()
	icon_state = "synthkit_[amount]"
