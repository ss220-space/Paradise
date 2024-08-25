/obj/item/dnascrambler
	name = "dna scrambler"
	desc = "An illegal genetic serum designed to randomize the user's identity."
	icon = 'icons/obj/hypo.dmi'
	item_state = "syringe_0"
	icon_state = "lepopen"
	var/used = FALSE


/obj/item/dnascrambler/update_icon_state()
	if(used)
		icon_state = "lepopen0"
	else
		icon_state = "lepopen"


/obj/item/dnascrambler/update_name(updates = ALL)
	. = ..()
	name = used ? "used [initial(name)]" : initial(name)


/obj/item/dnascrambler/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(used || !ishuman(target) || !ishuman(user))
		return .

	if(HAS_TRAIT(target, TRAIT_NO_DNA))
		to_chat(user, span_warning("You failed to inject [target], as [target.p_they()] [target.p_have()] no DNA to scramble, nor flesh to inject."))
		return .

	if(target == user)
		user.visible_message(span_danger("[user] injects [user.p_them()]self with [src]!"))
		injected(user, user)
		return .|ATTACK_CHAIN_SUCCESS

	user.visible_message(span_danger("[user] is trying to inject [target] with [src]!"))
	if(!do_after(user, 3 SECONDS, target, NONE))
		to_chat(user, span_warning("You failed to inject [target]."))
		return .
	user.visible_message(span_danger("[user] injects [target] with [src]."))
	injected(target, user)
	return .|ATTACK_CHAIN_SUCCESS


/obj/item/dnascrambler/proc/injected(mob/living/carbon/human/target, mob/living/carbon/human/user)
	scramble(TRUE, target, 100)
	target.real_name = random_name(target.gender, target.dna.species.name) //Give them a name that makes sense for their species.
	target.sync_organ_dna(assimilate = TRUE)
	target.update_body()
	target.reset_hair() //No more winding up with hairstyles you're not supposed to have, and blowing your cover.
	target.reset_markings() //...Or markings.
	target.dna.ResetUIFrom(target)
	target.flavor_text = ""
	target.update_icons()
	add_attack_logs(user, target, "injected with [src]")
	used = TRUE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)

