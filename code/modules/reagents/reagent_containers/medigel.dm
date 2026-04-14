#define MEDIGEL_DELAY 30

/obj/item/reagent_containers/medigel
	name = "Medigel"
	desc = "Баночка медицинского геля, предназначенная для точечного нанесения различных жидкостей. Оснащен дозатором и откручивающейся крышкой."
	icon = 'icons/obj/medigel.dmi'
	icon_state = "medigel"
	item_state = "spraycan"
	item_flags = NOBLUDGEON
	container_type = REFILLABLE | AMOUNT_VISIBLE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	temperature_min = 270
	temperature_max = 350
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10)
	volume = 60
	pass_open_check = TRUE
	var/delay = MEDIGEL_DELAY
	var/paint_color
	var/color_overlay = "colour_medigel"
	var/colorable = TRUE
	custom_price = PAYCHECK_CREW * 2

/obj/item/reagent_containers/medigel/get_ru_names()
	return list(
		NOMINATIVE = "медицинский гель",
		GENITIVE = "медицинского геля",
		DATIVE = "медицинскому гелю",
		ACCUSATIVE = "медицинский гель",
		INSTRUMENTAL = "медицинским гелем",
		PREPOSITIONAL = "медицинском геле",
	)

/obj/item/reagent_containers/medigel/proc/update_state()
	if(!colorable)
		return

	remove_filter("medigel_handle")

	if(paint_color)
		var/icon/mask = icon(icon, color_overlay)
		add_filter("medigel_handle", 1, layering_filter(icon = mask, color = paint_color))

	update_icon()

/obj/item/reagent_containers/medigel/update_icon_state()
	if(!colorable)
		return
	icon_state = paint_color ? "medigel_white" : "medigel"

/obj/item/reagent_containers/medigel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/spraycan) && colorable)
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(can.capped)
			balloon_alert(user, "баллончик закрыт!")
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(can.uses < 2)
			balloon_alert(user, "недостаточно краски!")
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		balloon_alert(user, "покрашено")
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		paint_color = can.colour
		can.uses -= 2
		update_state()
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	if(issoap(I) && paint_color)
		add_fingerprint(user)
		balloon_alert(user, "краска смыта")
		paint_color = null
		update_state()
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()

/obj/item/reagent_containers/medigel/attack(mob/living/carbon/target, mob/living/user, def_zone)
	if(!iscarbon(target) || !target.reagents)
		return NONE

	if(!target.can_inject(user, FALSE))
		user.balloon_alert(user, "закрыто одеждой!")
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

	if(!reagents || !reagents.total_volume)
		user.balloon_alert(user, "гель пуст!")
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

	user.changeNext_move(CLICK_CD_MELEE)
	if(target == user)
		target.visible_message(span_notice("[user] пытается нанести гель на себя."))
		if(!do_after(user, delay, target))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(!reagents || !reagents.total_volume)
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		to_chat(target, span_notice("Вы нанесли на себя гель."))

	else
		target.visible_message(
			span_danger("[user] пытается нанести гель на [target]."),
			span_userdanger("[user] пытается нанести гель на вас."),
		)
		if(!do_after(user, delay, target))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(!reagents || !reagents.total_volume)
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		target.visible_message(
			span_danger("[user] наносит гель на [target]."),
			span_userdanger("[user] наносит гель на вас."),
		)

	add_attack_logs(user, target, "applied", src, reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)

	reagents.trans_to(target, amount_per_transfer_from_this)
	return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

/obj/item/reagent_containers/medigel/sterilizine
	name = "Sterilizer gel"
	desc = "Баночка с медицинским гелем, наполненная нетоксичным стерелизином. Используется во время подготовки к хирургической операции."
	icon_state = "medigel_blue"
	colorable = FALSE
	list_reagents = list(/datum/reagent/medicine/sterilizine = 60)

/obj/item/reagent_containers/medigel/sterilizine/get_ru_names()
	return list(
		NOMINATIVE = "стерилизующий гель",
		GENITIVE = "стерилизующего геля",
		DATIVE = "стерилизующему гелю",
		ACCUSATIVE = "стерилизующий гель",
		INSTRUMENTAL = "стерилизующим гелем",
		PREPOSITIONAL = "стерилизующем геле",
	)

#undef MEDIGEL_DELAY
