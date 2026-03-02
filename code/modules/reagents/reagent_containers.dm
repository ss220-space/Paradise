/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = WEIGHT_CLASS_TINY
	var/amount_per_transfer_from_this = 5
	var/visible_transfer_rate = TRUE
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30
	var/list/list_reagents = null
	var/spawned_disease = null
	var/disease_amount = 20
	/// Used for containers where we want to put lids on and off
	var/has_lid = FALSE
	var/temperature_min = 0 // To limit the temperature of a reagent container can atain when exposed to heat/cold
	var/temperature_max = 10000
	/// Pass open check in empty verb
	var/pass_open_check = FALSE
	var/chem_master_made = FALSE

/obj/item/reagent_containers/get_ru_names_cached()
	if(chem_master_made)
		return
	return ..()

/obj/item/reagent_containers/get_short_name()
	if(!length(reagents.reagent_list))
		return declent_ru(NOMINATIVE)

	var/datum/reagent/reagent = reagents.reagent_list[1]
	return reagent.name

/// Set amount_per_transfer_from_this
/obj/item/reagent_containers/verb/set_APTFT()
	set name = "Установить объём перемещения"
	set category = VERB_CATEGORY_OBJECT
	set src in usr

	if(!ishuman(usr) && !isrobot(usr))
		return
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	var/default = null
	if(amount_per_transfer_from_this in possible_transfer_amounts)
		default = amount_per_transfer_from_this
	var/N = tgui_input_list(usr, "Объём перемещения отсюда:", "[declent_ru(NOMINATIVE)]", possible_transfer_amounts, default)

	if(!N)
		return
	if(!Adjacent(usr))
		balloon_alert(usr, "слишком далеко!")
		return

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		balloon_alert(usr, "руки заблокированы!")
		return

	amount_per_transfer_from_this = N
	to_chat(usr, span_notice("Теперь [declent_ru(NOMINATIVE)] буд[PLUR_ET_UT(src)] перемещать по <b>[N]</b> единиц[DECL_SEC_MIN(N)] вещества за раз."))

/obj/item/reagent_containers/click_alt(mob/user)
	set_APTFT()
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/verb/empty()

	set name = "Вылить содержимое"
	set category = VERB_CATEGORY_OBJECT
	set src in usr

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(tgui_alert(usr, "Вы уверены?", "Вылить содержимое", list("Да", "Нет")) != "Да")
		return
	if(!usr.Adjacent(src) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(isturf(usr.loc) && loc == usr)
		if(!is_open_container() && !pass_open_check)
			balloon_alert(usr, "сначала откройте!")
			return
		if(reagents.total_volume)
			balloon_alert(usr, "содержимое вылито")
			make_splashes(usr.loc)
		else
			balloon_alert(usr, "пусто, нечего выливать!")

/obj/item/reagent_containers/New()
	create_reagents(volume, temperature_min, temperature_max)
	..()
	if(!possible_transfer_amounts)
		verbs -= /obj/item/reagent_containers/verb/set_APTFT

/obj/item/reagent_containers/Initialize(mapload)
	. = ..()
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease
		var/list/data = list("diseases" = list(F), "blood_color" = BLOOD_COLOR_RED)
		reagents.add_reagent("blood", disease_amount, data)
	if(list_reagents)
		list_reagents = string_assoc_list(list_reagents)
	add_initial_reagents()
	update_icon()

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()

/obj/item/reagent_containers/proc/add_lid()
	if(has_lid)
		container_type ^= REFILLABLE | DRAINABLE
		update_icon()

/obj/item/reagent_containers/proc/remove_lid()
	if(has_lid)
		container_type |= REFILLABLE | DRAINABLE
		update_icon()

/obj/item/reagent_containers/attack_self(mob/user = usr)
	if(has_lid)
		if(is_open_container())
			balloon_alert(user, "крышка надета")
			add_lid()
		else
			balloon_alert(user, "крышка снята")
			remove_lid()

/obj/item/reagent_containers/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent != INTENT_HARM)
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/reagent_containers/wash(mob/user, atom/source)
	if(is_open_container())
		if(reagents.total_volume >= volume)
			balloon_alert(user, "нет места!")
			return
		else
			reagents.add_reagent("water", min(volume - reagents.total_volume, amount_per_transfer_from_this))
			to_chat(user, span_notice("Вы наполняете [declent_ru(ACCUSATIVE)] из [source.declent_ru(GENITIVE)]."))
			return
	..()

/obj/item/reagent_containers/proc/get_sound_for_reagent_containers()
	switch(amount_per_transfer_from_this)
		if(0 to 9)
			return SFX_BEAKERPOUR_0_10
		if(10 to 24)
			return SFX_BEAKERPOUR_10_25
		if(25 to 50)
			return SFX_BEAKERPOUR_25_50

	return SFX_BEAKERPOUR_50_INF

/obj/item/reagent_containers/proc/after_transfer(atom/target)
	if(!target)
		return FALSE

	playsound(target, get_sound_for_reagent_containers(), rand(5, 25), TRUE)

/obj/item/reagent_containers/proc/make_splashes(atom/target)
	if(!target)
		return FALSE

	reagents.reaction(target)
	reagents.clear_reagents()
	playsound(target, SFX_LIQUID_SPLASH, 50, TRUE)

/obj/item/reagent_containers/examine(mob/user)
	. = ..()
	if(visible_transfer_rate)
		. += span_notice("Объём перемещения содержимого отсюда - <b>[amount_per_transfer_from_this]</b> единиц[declension_ru(amount_per_transfer_from_this, "а", "ы", "")] вещества за раз.")

	if(possible_transfer_amounts)
		. += span_notice("Используйте <b>Alt+ЛКМ</b>, чтобы изменить объём перемещения содержимого.")

