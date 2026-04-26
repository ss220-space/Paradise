/// How much of the overall reagent gets applied before loop
#define APPLICATOR_PRE_LOOP_RATIO 0.2

/obj/item/reagent_containers/applicator
	name = "auto-mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов."
	gender = MALE
	icon = 'icons/map_icons/items/_item.dmi'
	greyscale_config = /datum/greyscale_config/mender
	greyscale_config_inhand_left = /datum/greyscale_config/mender_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/mender_inhand_right
	greyscale_config_belt = /datum/greyscale_config/mender_belt
	greyscale_colors = COLOR_WHITE
	post_init_icon_state = "mender"
	icon_state = "/obj/item/reagent_containers/applicator"
	item_state = "mender"
	belt_icon = "mender"
	volume = 200
	possible_transfer_amounts = null
	visible_transfer_rate = FALSE
	resistance_flags = ACID_PROOF
	container_type = REFILLABLE | AMOUNT_VISIBLE
	temperature_min = 270
	temperature_max = 350
	pass_open_check = TRUE
	custom_premium_price = PAYCHECK_LOWER
	// used for emagged version
	var/ignore_flags = FALSE
	// How much reagents it applies per cycle.
	var/applied_amount = 8
	// to prevent from spamming
	var/applying = FALSE
	// list of sound to play when applying reagents
	var/apply_sounds = SFX_MENDER

/obj/item/reagent_containers/applicator/get_ru_names()
	return list(
		NOMINATIVE = "авто-мендер",
		GENITIVE = "авто-мендера",
		DATIVE = "авто-мендеру",
		ACCUSATIVE = "авто-мендер",
		INSTRUMENTAL = "авто-мендером",
		PREPOSITIONAL = "авто-мендере",
	)

/obj/item/reagent_containers/applicator/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		ignore_flags = TRUE
		if(user)
			balloon_alert(user, "протоколы безопасности взломаны")

/obj/item/reagent_containers/applicator/on_reagent_change()
	if(!emagged)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/chem in reagents.reagent_list)
			if(!GLOB.safe_chem_applicator_list.Find(chem.id))
				reagents.del_reagent(chem.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] определяет и удаляет недопустимое вещество."))
			else
				visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] определяет и удаляет недопустимое вещество."))
	update_appearance(UPDATE_OVERLAYS)

/obj/item/reagent_containers/applicator/update_overlays()
	. = ..()
	var/overlay_icon = 'icons/obj/chemical.dmi'
	if(reagents.total_volume)
		. += mutable_appearance(overlay_icon, "mender_liquid_overlay", color = get_color_matrix_from_reagents(reagents.reagent_list))

	if(applying)
		var/mutable_appearance/applying_overlay = mutable_appearance(overlay_icon, "mender_applying_overlay", color = greyscale_colors)
		flick_overlay_view(applying_overlay, 1 SECONDS)

	var/reag_pct = round((reagents.total_volume / volume) * 100)
	var/mutable_appearance/applicator_bar = mutable_appearance(overlay_icon, "app_e")
	switch(reag_pct)
		if(51 to 100)
			applicator_bar.icon_state = "mender_ind_full"
		if(1 to 50)
			applicator_bar.icon_state = "mender_ind_low"
		if(0)
			applicator_bar.icon_state = "mender_ind_empty"

	. += applicator_bar

/obj/item/reagent_containers/applicator/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) || !target.reagents)
		return .

	if(!reagents || !reagents.total_volume)
		balloon_alert(user, "пусто!")
		return .

	if(applying)
		balloon_alert(user, "уже используется!")
		return .

	var/protection = 0
	if(!ignore_flags)
		if(!target.can_inject(user, FALSE))
			return .

		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			protection = 1 - human_target.get_permeability_protection_organ(human_target.get_organ(def_zone))
		else
			protection = target.get_permeability_protection()

	var/clothing_pen = reagents.get_average_clothing_pen()
	var/reacting_volume = applied_amount * clamp(1 - protection + clothing_pen, 0, 1)

	var/reacting_to_applied_ratio = reacting_volume / applied_amount

	if(target == user)
		target.visible_message(
			span_notice("[user] начина[PLUR_ET_YUT(user)] применять [declent_ru(ACCUSATIVE)] на себе."),
			span_notice("Вы начинаете применять [declent_ru(ACCUSATIVE)] на себе."),
		)
	else
		user.visible_message(
			span_notice("[user] начина[PLUR_ET_YUT(user)] применять [declent_ru(ACCUSATIVE)] на [target]."),
			span_notice("Вы начинаете применять [declent_ru(ACCUSATIVE)] на [target]."),
		)

	. |= ATTACK_CHAIN_SUCCESS

	applying = TRUE
	update_appearance(UPDATE_OVERLAYS)
	apply_to(target, user, APPLICATOR_PRE_LOOP_RATIO * reacting_to_applied_ratio, TRUE, def_zone) // We apply a very weak application up front, then loop.
	add_attack_logs(user, target, "Started mending with [src] containing ([reagents.log_list()])", (emagged && !(reagents.harmless_helper())) ? null : ATKLOG_ALMOSTALL)
	var/cycle_count = 0

	var/measured_health = 0
	var/cycle_delay = (2 - reacting_to_applied_ratio) * (1 SECONDS)
	while(do_after(user, cycle_delay, target))
		measured_health = target.health
		apply_to(target, user, 1, FALSE, def_zone)
		if(measured_health == target.health)
			balloon_alert(user, "авто-мендер выключен!")
			break
		if(!reagents.total_volume)
			balloon_alert(user, "содержимое закончилось!")
			break
		cycle_count++

	add_attack_logs(user, target, "Stopped mending after [cycle_count] cycles with [src] containing ([reagents.log_list()])", (emagged && !(reagents.harmless_helper())) ? null : ATKLOG_ALMOSTALL)
	applying = FALSE
	update_appearance(UPDATE_OVERLAYS)

/obj/item/reagent_containers/applicator/proc/apply_to(mob/living/carbon/target, mob/user, multiplier = 1, show_message = TRUE, def_zone)
	var/total_applied_amount = applied_amount * multiplier

	if(reagents?.total_volume)
		var/fractional_applied_amount = total_applied_amount  / reagents.total_volume

		reagents.reaction(target, REAGENT_TOUCH, fractional_applied_amount, show_message, TRUE, def_zone)
		reagents.trans_to(target, total_applied_amount * 0.5)
		reagents.remove_any(total_applied_amount * 0.5)

		playsound(get_turf(src), pick(apply_sounds), 50, TRUE)

/obj/item/reagent_containers/applicator/brute
	name = "brute auto-mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Эта версия — для заживления механических повреждений."
	icon_state = "/obj/item/reagent_containers/applicator/brute"
	greyscale_colors = COLOR_MENDER_BRUTE
	list_reagents = list("styptic_powder" = 200)

/obj/item/reagent_containers/applicator/brute/get_ru_names()
	return list(
		NOMINATIVE = "авто-мендер (Мех. Повреждения)",
		GENITIVE = "авто-мендера (Мех. Повреждения)",
		DATIVE = "авто-мендеру (Мех. Повреждения)",
		ACCUSATIVE = "авто-мендер (Мех. Повреждения)",
		INSTRUMENTAL = "авто-мендером (Мех. Повреждения)",
		PREPOSITIONAL = "авто-мендере (Мех. Повреждения)",
	)

/obj/item/reagent_containers/applicator/burn
	name = "burn auto-mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Эта версия — для заживления термических повреждений."
	greyscale_colors = COLOR_MENDER_BURN
	icon_state = "/obj/item/reagent_containers/applicator/burn"
	list_reagents = list("silver_sulfadiazine" = 200)

/obj/item/reagent_containers/applicator/burn/get_ru_names()
	return list(
		NOMINATIVE = "авто-мендер (Терм. Повреждения)",
		GENITIVE = "авто-мендера (Терм. Повреждения)",
		DATIVE = "авто-мендеру (Терм. Повреждения)",
		ACCUSATIVE = "авто-мендер (Терм. Повреждения)",
		INSTRUMENTAL = "авто-мендером (Терм. Повреждения)",
		PREPOSITIONAL = "авто-мендере (Терм. Повреждения)",
	)

/obj/item/reagent_containers/applicator/dual
	name = "dual auto-mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Эта версия — для заживления как механических, так и термических повреждений."
	greyscale_colors = COLOR_MENDER_DUAL
	icon_state = "/obj/item/reagent_containers/applicator/dual"
	list_reagents = list("synthflesh" = 200)

/obj/item/reagent_containers/applicator/dual/get_ru_names()
	return list(
		NOMINATIVE = "авто-мендер (Синт-плоть)",
		GENITIVE = "авто-мендера (Синт-плоть)",
		DATIVE = "авто-мендеру (Синт-плоть)",
		ACCUSATIVE = "авто-мендер (Синт-плоть)",
		INSTRUMENTAL = "авто-мендером (Синт-плоть)",
		PREPOSITIONAL = "авто-мендере (Синт-плоть)",
	)

/obj/item/reagent_containers/applicator/dual/syndi // It magically goes through hardsuits. Don't ask how.
	ignore_flags = TRUE

#undef APPLICATOR_PRE_LOOP_RATIO
