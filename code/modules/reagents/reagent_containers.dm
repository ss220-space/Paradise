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
	var/has_lid = FALSE // Used for containers where we want to put lids on and off
	var/temperature_min = 0 // To limit the temperature of a reagent container can atain when exposed to heat/cold
	var/temperature_max = 10000
	var/pass_open_check = FALSE // Pass open check in empty verb

/obj/item/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Установить объём перемещения"
	set category = "Object"
	set src in usr

	if(!ishuman(usr) && !isrobot(usr))
		return
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	var/default = null
	if(amount_per_transfer_from_this in possible_transfer_amounts)
		default = amount_per_transfer_from_this
	var/N = input("Объём перемещения отсюда:", "[declent_ru(NOMINATIVE)]", default) as null|anything in possible_transfer_amounts

	if(!N)
		return
	if(!Adjacent(usr))
		balloon_alert(usr, "слишком далеко!")
		return

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		balloon_alert(usr, "руки заблокированы!")
		return

	amount_per_transfer_from_this = N
	to_chat(usr, span_notice("Теперь [declent_ru(NOMINATIVE)] буд[pluralize_ru(gender, "ет", "ут")] перемещать по <b>[N]</b> единиц[declension_ru(N, "у", "ы", "")] вещества за раз."))

/obj/item/reagent_containers/AltClick(mob/user)
	if(Adjacent(user))
		set_APTFT()

/obj/item/reagent_containers/verb/empty()

	set name = "Вылить содержимое"
	set category = "Object"
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
			reagents.reaction(usr.loc)
			reagents.clear_reagents()
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
		var/list/data = list("diseases" = list(F), "blood_color" = "#A10808")
		reagents.add_reagent("blood", disease_amount, data)
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

/obj/item/reagent_containers/examine(mob/user)
	. = ..()
	if(visible_transfer_rate)
		. += span_notice("Объём перемещения содержимого отсюда - <b>[amount_per_transfer_from_this]</b> единиц[declension_ru(amount_per_transfer_from_this, "а", "ы", "")] вещества за раз.")

	if(possible_transfer_amounts)
		. += span_notice("Используйте <b>Alt+ЛКМ</b>, чтобы изменить объём перемещения содержимого.")

