/obj/item/reagent_containers/applicator
	name = "auto-mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов."
	ru_names = list(
        NOMINATIVE = "авто-мендер",
        GENITIVE = "авто-мендера",
        DATIVE = "авто-мендеру",
        ACCUSATIVE = "авто-мендер",
        INSTRUMENTAL = "авто-мендером",
        PREPOSITIONAL = "авто-мендере"
	)
	icon = 'icons/goonstation/objects/objects.dmi'
	icon_state = "mender"
	item_state = "mender"
	belt_icon = "automender"
	volume = 200
	possible_transfer_amounts = null
	visible_transfer_rate = FALSE
	resistance_flags = ACID_PROOF
	container_type = REFILLABLE | AMOUNT_VISIBLE
	temperature_min = 270
	temperature_max = 350
	pass_open_check = TRUE
	var/ignore_flags = FALSE
	var/emagged = FALSE
	var/applied_amount = 8 // How much it applies
	var/applying = FALSE // So it can't be spammed.


/obj/item/reagent_containers/applicator/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		ignore_flags = TRUE
		if(user)
			balloon_alert(user, "протоколы безопасности взломаны")

/obj/item/reagent_containers/applicator/set_APTFT()
	set hidden = TRUE

/obj/item/reagent_containers/applicator/on_reagent_change()
	if(!emagged)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if(!GLOB.safe_chem_applicator_list.Find(R.id))
				reagents.del_reagent(R.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, span_warning("[capitalize(declent_ru(NOMINATIVE))] определяет и удаляет недопустимое вещество."))
			else
				visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] определяет и удаляет недопустимое вещество."))
	update_icon()


/obj/item/reagent_containers/applicator/update_icon_state()
	icon_state = "mender[applying ? "-active" : ""]"


/obj/item/reagent_containers/applicator/update_overlays()
	. = ..()
	if(reagents.total_volume)
		. += mutable_appearance('icons/goonstation/objects/objects.dmi', "mender-fluid", color = mix_color_from_reagents(reagents.reagent_list))
	var/reag_pct = round((reagents.total_volume / volume) * 100)
	var/mutable_appearance/applicator_bar = mutable_appearance('icons/goonstation/objects/objects.dmi', "app_e")
	switch(reag_pct)
		if(51 to 100)
			applicator_bar.icon_state = "app_hf"
		if(1 to 50)
			applicator_bar.icon_state = "app_he"
		if(0)
			applicator_bar.icon_state = "app_e"
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

	if(!ignore_flags && !target.can_inject(user, TRUE))
		return .

	if(target == user)
		target.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] применять [declent_ru(ACCUSATIVE)] на себе."),
			span_notice("Вы начинаете применять [declent_ru(ACCUSATIVE)] на себе."),
		)
	else
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] применять [declent_ru(ACCUSATIVE)] на [target]."),
			span_notice("Вы начинаете применять [declent_ru(ACCUSATIVE)] на [target]."),
		)

	. |= ATTACK_CHAIN_SUCCESS

	applying = TRUE
	update_icon()
	apply_to(target, user, 0.2, TRUE, def_zone) // We apply a very weak application up front, then loop.
	add_attack_logs(user, target, "Started mending with [src] containing ([reagents.log_list()])", (emagged && !(reagents.harmless_helper())) ? null : ATKLOG_ALMOSTALL)
	var/cycle_count = 0

	var/measured_health = 0
	while(do_after(user, 1 SECONDS, target))
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
	update_icon()


/obj/item/reagent_containers/applicator/proc/apply_to(mob/living/carbon/M, mob/user, multiplier = 1, show_message = TRUE, def_zone)
	var/total_applied_amount = applied_amount * multiplier

	if(reagents && reagents.total_volume)
		var/fractional_applied_amount = total_applied_amount  / reagents.total_volume

		reagents.reaction(M, REAGENT_TOUCH, fractional_applied_amount, show_message, ignore_flags, def_zone)
		reagents.trans_to(M, total_applied_amount * 0.5)
		reagents.remove_any(total_applied_amount * 0.5)

		playsound(get_turf(src), pick('sound/goonstation/items/mender.ogg', 'sound/goonstation/items/mender2.ogg'), 50, 1)

/obj/item/reagent_containers/applicator/brute
	name = "brute auto-mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Эта версия - для заживления механических повреждений."
	ru_names = list(
        NOMINATIVE = "авто-мендер (Мех. Повреждения)",
        GENITIVE = "авто-мендера (Мех. Повреждения)",
        DATIVE = "авто-мендеру (Мех. Повреждения)",
        ACCUSATIVE = "авто-мендер (Мех. Повреждения)",
        INSTRUMENTAL = "авто-мендером (Мех. Повреждения)",
        PREPOSITIONAL = "авто-мендере (Мех. Повреждения)"
	)
	list_reagents = list("styptic_powder" = 200)

/obj/item/reagent_containers/applicator/burn
	name = "burn auto-mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Эта версия - для заживления термических повреждений."
	ru_names = list(
        NOMINATIVE = "авто-мендер (Терм. Повреждения)",
        GENITIVE = "авто-мендера (Терм. Повреждения)",
        DATIVE = "авто-мендеру (Терм. Повреждения)",
        ACCUSATIVE = "авто-мендер (Терм. Повреждения)",
        INSTRUMENTAL = "авто-мендером (Терм. Повреждения)",
        PREPOSITIONAL = "авто-мендере (Терм. Повреждения)"
	)
	list_reagents = list("silver_sulfadiazine" = 200)

/obj/item/reagent_containers/applicator/dual
	name = "dual auto-mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Эта версия - для заживления как механических, так и термических повреждений."
	ru_names = list(
        NOMINATIVE = "авто-мендер (Синт-плоть)",
        GENITIVE = "авто-мендера (Синт-плоть)",
        DATIVE = "авто-мендеру (Синт-плоть)",
        ACCUSATIVE = "авто-мендер (Синт-плоть)",
        INSTRUMENTAL = "авто-мендером (Синт-плоть)",
        PREPOSITIONAL = "авто-мендере (Синт-плоть)"
	)
	list_reagents = list("synthflesh" = 200)

/obj/item/reagent_containers/applicator/dual/syndi // It magically goes through hardsuits. Don't ask how.
	ignore_flags = TRUE
