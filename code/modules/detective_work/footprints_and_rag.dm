/obj/item/clothing/gloves
	var/transfer_blood = 0

/obj/item/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	volume = 5
	item_flags = NOBLUDGEON
	container_type = OPENCONTAINER
	has_lid = FALSE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	var/wipespeed = 3 SECONDS


/obj/item/reagent_containers/glass/rag/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!target.reagents || !reagents.total_volume || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			to_chat(user, span_warning("Your face is obscured."))
		else
			to_chat(user, span_warning("[target.name]'s face is obscured."))
		return .

	user.visible_message(
		span_warning("[user] starts to smoother down [target] with [src]."),
		span_notice("You start to smoother down [target] with [src]..."),
	)
	if(!do_after(user, wipespeed, target) || !get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH) || !reagents.total_volume)
		return .

	. |= ATTACK_CHAIN_SUCCESS

	add_attack_logs(user, target, "Smoothed with [src] containing ([reagents.log_list()])", ATKLOG_ALMOSTALL)
	user.visible_message(
		span_danger("[user] has smothered [target] with [src]!"),
		span_danger("You smoother [target] with [src]!"),
		span_italics("You hear some struggling and muffled cries of surprise"),
	)
	reagents.reaction(target, REAGENT_TOUCH)
	reagents.clear_reagents()


/obj/item/reagent_containers/glass/rag/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity) return
	if(ismob(A) && user.zone_selected != "mouth") return
	if(istype(A) && (src in user) && reagents.total_volume)
		user.visible_message("[user] starts to wipe down [A] with [src]!")
		if(do_after(user, wipespeed, A))
			user.visible_message("[user] finishes wiping off the [A]!")
			A.clean_blood()
	return
