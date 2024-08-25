/obj/item/scissors
	name = "Scissors"
	desc = "Those are scissors. Don't run with them!"
	icon_state = "scissor"
	item_state = "scissor"
	force = 5
	sharp = 1
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slices", "cuts", "stabs", "jabs")
	toolspeed = 1

/obj/item/scissors/barber
	name = "Barber's Scissors"
	desc = "A pair of scissors used by the barber."
	icon_state = "bscissor"
	item_state = "scissor"
	attack_verb = list("beautifully sliced", "artistically cut", "smoothly stabbed", "quickly jabbed")
	toolspeed = 0.75


/obj/item/scissors/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target) || user.a_intent != INTENT_HELP)
		return ..()

	var/obj/item/organ/external/head/head = target.get_organ(BODY_ZONE_HEAD)
	if(!head)
		return ..()

	. = ATTACK_CHAIN_PROCEED

	//facial hair
	var/f_new_style = tgui_input_list(user, "Select a facial hair style", "Grooming", target.generate_valid_facial_hairstyles())
	//handle normal hair
	var/h_new_style
	if(iswryn(target))
		to_chat(user, span_notice("You cannot do anything with that hair."))
	else
		h_new_style = tgui_input_list(user, "Select a hair style", "Grooming", target.generate_valid_hairstyles())
	if((isnull(f_new_style) && isnull(h_new_style)) || QDELETED(head) || !user.Adjacent(target))
		return .

	user.visible_message(
		span_notice("[user] starts cutting [target]'s hair!"),
		span_notice("You start cutting [target]'s hair!"),
	)
	playsound(loc, 'sound/goonstation/misc/scissor.ogg', 100, TRUE)
	if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL) || QDELETED(head))
		user.visible_message(
			span_notice("[user] stops cutting [target]'s hair."),
			span_notice("You stop cutting [target]'s hair."),
		)
		return .

	. |= ATTACK_CHAIN_SUCCESS

	if(f_new_style)
		head.f_style = f_new_style
		target.update_fhair()

	if(h_new_style)
		head.h_style = h_new_style
		target.update_hair()

	user.visible_message(
		span_notice("[user] finishes cutting [target]'s hair!"),
		span_notice("You have finished cutting [target]'s hair!"),
	)


/obj/item/scissors/safety //Totally safe, I assure you.
	desc = "The blades of the scissors appear to be made of some sort of ultra-strong metal alloy."
	force = 18 //same as e-daggers
	/// To prevent spam clicking this for huge accumulation of losebreath.
	var/is_cutting = FALSE


/obj/item/scissors/safety/attack(mob/living/carbon/human/target, mob/living/carbon/human/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target) || !ishuman(user) || user.a_intent != INTENT_HELP)
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(is_cutting || user == target)
		return .

	is_cutting = TRUE
	user.visible_message(
		span_notice("[user] starts cutting [target]'s hair!"),
		span_notice("You start cutting [target]'s hair!"),
	)
	playsound(loc, 'sound/goonstation/misc/scissor.ogg', 100, TRUE)
	if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL))
		is_cutting = FALSE
		return .

	. |= ATTACK_CHAIN_SUCCESS
	is_cutting = FALSE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	user.visible_message(
		span_danger("[user] abruptly stops cutting [target]'s hair and slices [target.p_their()] throat!"),
		span_danger("You stop cutting [target]'s hair and slice [target.p_their()] throat!"),
	)
	target.AdjustLoseBreath(20 SECONDS) //30 Oxy damage over time
	var/success = target.apply_damage(18, BRUTE, BODY_ZONE_HEAD, sharp = TRUE, used_weapon = src)
	if(!success)
		return .
	target.add_splatter_floor()
	target.bloody_hands(target)
	target.bloody_body(target)
	user.bloody_hands(target)
	user.bloody_body(target)

