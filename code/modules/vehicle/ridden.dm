/obj/vehicle/ridden
	name = "ridden vehicle"
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = 0
	pass_flags_self = PASSTABLE
	COOLDOWN_DECLARE(message_cooldown)

/obj/vehicle/ridden/examine(mob/user)
	. = ..()
	if(key_type)
		if(!inserted_key)
			. += span_notice("Поместите ключ внутрь, кликнув по нему с ключом.")
		else
			. += span_notice("Alt+ЛКМ по [src.declent_ru(DATIVE)] чтобы извлечь ключ.")

/obj/vehicle/ridden/generate_action_type(actiontype)
	var/datum/action/vehicle/ridden/A = ..()
	. = A
	if(istype(A))
		A.vehicle_ridden_target = src

/obj/vehicle/ridden/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	return ..()

/obj/vehicle/ridden/post_buckle_mob(mob/living/M)
	add_occupant(M)
	return ..()

/obj/vehicle/ridden/attackby(obj/item/I, mob/user, params)
	if(!key_type || is_key(inserted_key) || !is_key(I))
		return ..()
	if(!user.transfer_item_to_loc(I, src))
		to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] будто прилип к вашей руке!"))
		return
	to_chat(user, span_notice("Вы вставляете [I.declent_ru(ACCUSATIVE)] в [src.declent_ru(ACCUSATIVE)]."))
	if(inserted_key) //just in case there's an invalid key
		inserted_key.forceMove(drop_location())
	inserted_key = I
	return ATTACK_CHAIN_PROCEED

/obj/vehicle/ridden/click_alt(mob/user)
	if(!inserted_key)
		return NONE
	if(!is_occupant(user))
		to_chat(user, span_warning("Вы должны находиться на [src.declent_ru(PREPOSITIONAL)], чтобы извлечь его ключ!"))
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_notice("Вы извлекаете [inserted_key.declent_ru(ACCUSATIVE)] из [src.declent_ru(GENITIVE)]."))
	inserted_key.forceMove_turf()
	user.put_in_hands(inserted_key)
	inserted_key = null
	return CLICK_ACTION_SUCCESS

/obj/vehicle/ridden/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !in_range(M, src))
		return FALSE
	return ..(M, user, FALSE)

/obj/vehicle/ridden/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!force && occupant_amount() >= max_occupants)
		return FALSE

	var/response = SEND_SIGNAL(M, COMSIG_VEHICLE_RIDDEN, src)
	if(response & EJECT_FROM_VEHICLE)
		return FALSE

	return ..()

