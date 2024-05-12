/****************************************************
			   ORGAN DEFINES
****************************************************/

/obj/item/organ/external/chest
	name = "upper body"
	limb_zone = BODY_ZONE_CHEST
	icon_name = "torso"
	max_damage = 100
	min_broken_damage = 35
	w_class = WEIGHT_CLASS_HUGE
	limb_body_flag = UPPER_TORSO
	vital = TRUE
	amputation_point = "spine"
	gendered_icon = TRUE
	parent_organ_zone = null
	encased = "ribcage"
	convertable_children = list(/obj/item/organ/external/groin)

/obj/item/organ/external/chest/emp_act(severity)
	..()
	if(!is_robotic() || emp_proof || !tough) // Augmented chest suffocates the user on EMP.
		return
	switch(severity)
		if(1)
			owner?.adjustStaminaLoss(20)
		if(2)
			owner?.adjustStaminaLoss(10)
	to_chat(owner, span_userdanger("Ваш [name] выходит из строя, вызывая усталость!"))

/obj/item/organ/external/groin
	name = "lower body"
	limb_zone = BODY_ZONE_PRECISE_GROIN
	icon_name = "groin"
	max_damage = 100
	min_broken_damage = 35
	w_class = WEIGHT_CLASS_BULKY // if you know what I mean ;)
	limb_body_flag = LOWER_TORSO
	vital = TRUE
	parent_organ_zone = BODY_ZONE_CHEST
	amputation_point = "lumbar"
	gendered_icon = TRUE

/obj/item/organ/external/arm
	limb_zone = BODY_ZONE_L_ARM
	name = "left arm"
	icon_name = "l_arm"
	max_damage = 50
	min_broken_damage = 30
	w_class = WEIGHT_CLASS_NORMAL
	limb_body_flag = ARM_LEFT
	parent_organ_zone = BODY_ZONE_CHEST
	amputation_point = "left shoulder"
	can_grasp = TRUE
	convertable_children = list(/obj/item/organ/external/hand)

/obj/item/organ/external/arm/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented arms and hands drop whatever they are holding on EMP.
		return
	var/hand = (limb_zone == BODY_ZONE_L_ARM) ? owner.l_hand : owner.r_hand
	if(hand && owner.can_unEquip(hand))
		owner.drop_item_ground(hand)
		to_chat(owner, span_userdanger("Ваш [name] выходит из строя, бросая то что держал!"))
		owner.custom_emote(EMOTE_VISIBLE, "роня%(ет,ют)% предмет, %(его,её,его,их)% рука выходит из строя!")

/obj/item/organ/external/arm/right
	limb_zone = BODY_ZONE_R_ARM
	name = "right arm"
	icon_name = "r_arm"
	limb_body_flag = ARM_RIGHT
	amputation_point = "right shoulder"
	convertable_children = list(/obj/item/organ/external/hand/right)

/obj/item/organ/external/leg
	limb_zone = BODY_ZONE_L_LEG
	name = "left leg"
	icon_name = "l_leg"
	max_damage = 50
	min_broken_damage = 30
	w_class = WEIGHT_CLASS_NORMAL
	limb_body_flag = LEG_LEFT
	icon_position = LEFT
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	amputation_point = "left hip"
	convertable_children = list(/obj/item/organ/external/foot)


/obj/item/organ/external/leg/replaced(mob/living/carbon/human/target)
	. = ..()
	owner.update_fractures_slowdown()


/obj/item/organ/external/leg/remove(mob/living/carbon/human/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	. = ..()
	user.update_fractures_slowdown()


/obj/item/organ/external/leg/fracture(silent = FALSE)
	. = ..()
	if(!. || !owner)
		return .
	owner.update_fractures_slowdown()


/obj/item/organ/external/leg/mend_fracture()
	. = ..()
	if(!. || !owner)
		return .
	owner.update_fractures_slowdown()


/obj/item/organ/external/leg/apply_splint()
	. = ..()
	if(!. || !owner)
		return .
	owner.update_fractures_slowdown()


/obj/item/organ/external/leg/remove_splint(splint_break = FALSE, silent = FALSE)
	. = ..()
	if(!. || !owner)
		return .
	owner.update_fractures_slowdown()


/obj/item/organ/external/leg/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented legs and feet make the user drop to the floor on EMP.
		return
	if(owner.IsWeakened())
		to_chat(owner, span_userdanger("Ваш [name] выходит из строя, не давая вам встать!"))
		owner.custom_emote(EMOTE_VISIBLE, "не мо%(жет,гут)% встать, %(его,её,его,их)% нога выходит из строя!")
	else
		to_chat(owner, span_userdanger("Ваш [name] выходит из строя, заставив вас упасть на пол!"))
		owner.custom_emote(EMOTE_VISIBLE, "пада%(ет,ют)% на пол, %(его,её,его,их)% нога выходит из строя!")
	switch(severity)
		if(1)
			owner.AdjustWeakened(8 SECONDS)
		if(2)
			owner.AdjustWeakened(4 SECONDS)

/obj/item/organ/external/leg/right
	limb_zone = BODY_ZONE_R_LEG
	name = "right leg"
	icon_name = "r_leg"
	limb_body_flag = LEG_RIGHT
	icon_position = RIGHT
	amputation_point = "right hip"
	convertable_children = list(/obj/item/organ/external/foot/right)

/obj/item/organ/external/foot
	limb_zone = BODY_ZONE_PRECISE_L_FOOT
	name = "left foot"
	icon_name = "l_foot"
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	limb_body_flag = FOOT_LEFT
	icon_position = LEFT
	parent_organ_zone = BODY_ZONE_L_LEG
	amputation_point = "left ankle"


/obj/item/organ/external/foot/replaced(mob/living/carbon/human/target)
	. = ..()
	owner.set_num_legs(owner.num_legs + 1)
	if(is_usable())
		owner.set_usable_legs(owner.usable_legs + 1)
	owner.update_fractures_slowdown()


/obj/item/organ/external/foot/remove(mob/living/carbon/human/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	. = ..()
	user.set_num_legs(user.num_legs - 1)
	if(is_usable())
		user.set_usable_legs(user.usable_legs - 1)
	user.update_fractures_slowdown()
	if(special == ORGAN_MANIPULATION_DEFAULT)
		user.drop_item_ground(user.shoes, force = TRUE)


/obj/item/organ/external/foot/fracture(silent = FALSE)
	. = ..()
	if(!. || !owner)
		return .
	owner.update_fractures_slowdown()


/obj/item/organ/external/foot/mend_fracture()
	. = ..()
	if(!. || !owner)
		return .
	owner.update_fractures_slowdown()


/obj/item/organ/external/foot/apply_splint()
	. = ..()
	if(!. || !owner)
		return .
	owner.update_fractures_slowdown()


/obj/item/organ/external/foot/remove_splint(splint_break = FALSE, silent = FALSE)
	. = ..()
	if(!. || !owner)
		return .
	owner.update_fractures_slowdown()


/obj/item/organ/external/foot/necrotize(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_legs(owner.usable_legs - 1)


/obj/item/organ/external/foot/unnecrotize()
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_legs(owner.usable_legs + 1)


/obj/item/organ/external/foot/mutate(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_legs(owner.usable_legs - 1)


/obj/item/organ/external/foot/unmutate(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_legs(owner.usable_legs + 1)


/obj/item/organ/external/foot/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented legs and feet make the user drop to the floor on EMP.
		return
	if(owner.IsWeakened())
		to_chat(owner, span_userdanger("Ваш [name] выходит из строя, не давая вам встать!"))
		owner.custom_emote(EMOTE_VISIBLE, "не мо%(жет,гут)% встать, %(его,её,его,их)% ступня выходит из строя!")
	else
		to_chat(owner, span_userdanger("Ваш [name] выходит из строя, падая на пол!"))
		owner.custom_emote(EMOTE_VISIBLE, "пада%(ет,ют)% на пол, %(его,её,его,их)% ступня выходит из строя!")
	switch(severity)
		if(1)
			owner.AdjustWeakened(8 SECONDS)
		if(2)
			owner.AdjustWeakened(4 SECONDS)


/obj/item/organ/external/foot/right
	limb_zone = BODY_ZONE_PRECISE_R_FOOT
	name = "right foot"
	icon_name = "r_foot"
	limb_body_flag = FOOT_RIGHT
	icon_position = RIGHT
	parent_organ_zone = BODY_ZONE_R_LEG
	amputation_point = "right ankle"

/obj/item/organ/external/hand
	limb_zone = BODY_ZONE_PRECISE_L_HAND
	name = "left hand"
	icon_name = "l_hand"
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	limb_body_flag = HAND_LEFT
	parent_organ_zone = BODY_ZONE_L_ARM
	amputation_point = "left wrist"
	can_grasp = TRUE


/obj/item/organ/external/hand/replaced(mob/living/carbon/human/target)
	. = ..()
	owner.set_num_hands(owner.num_hands + 1)
	if(is_usable())
		owner.set_usable_hands(owner.usable_hands + 1)


/obj/item/organ/external/hand/remove(mob/living/carbon/human/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	. = ..()
	user.set_num_hands(user.num_hands - 1)
	if(is_usable())
		user.set_usable_hands(user.usable_hands - 1)
	if(special == ORGAN_MANIPULATION_DEFAULT)
		user.drop_item_ground(user.gloves, force = TRUE)
		user.drop_item_ground(user.l_hand, force = TRUE)
		user.drop_item_ground(user.r_hand, force = TRUE)


/obj/item/organ/external/hand/necrotize(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_hands(owner.usable_hands - 1)


/obj/item/organ/external/hand/unnecrotize()
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_hands(owner.usable_hands + 1)


/obj/item/organ/external/hand/mutate(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_hands(owner.usable_hands - 1)


/obj/item/organ/external/hand/unmutate(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_hands(owner.usable_hands + 1)


/obj/item/organ/external/hand/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented arms and hands drop whatever they are holding on EMP.
		return
	var/hand = (limb_zone == BODY_ZONE_L_ARM) ? owner.l_hand : owner.r_hand
	if(hand && owner.can_unEquip(hand))
		owner.drop_item_ground(hand)
		to_chat(owner, span_userdanger("Ваш [name] выходит из строя, dropping what it was holding!"))
		owner.custom_emote(EMOTE_VISIBLE, "роня%(ет,ют)% предмет, %(его,её,его,их)% кисть выходит из строя!")


/obj/item/organ/external/hand/right
	limb_zone = BODY_ZONE_PRECISE_R_HAND
	name = "right hand"
	icon_name = "r_hand"
	limb_body_flag = HAND_RIGHT
	parent_organ_zone = BODY_ZONE_R_ARM
	amputation_point = "right wrist"

/obj/item/organ/external/head
	limb_zone = BODY_ZONE_HEAD
	icon_name = "head"
	name = "head"
	max_damage = 75
	min_broken_damage = 35
	w_class = WEIGHT_CLASS_NORMAL
	limb_body_flag = HEAD
	parent_organ_zone = BODY_ZONE_CHEST
	amputation_point = "neck"
	gendered_icon = TRUE
	encased = "skull"
	var/can_intake_reagents = 1
	var/alt_head = "None"

	//Hair colour and style
	var/hair_colour = "#000000"
	var/sec_hair_colour = "#000000"
	var/h_style = "Bald"
	var/h_grad_style = "None"
	var/h_grad_offset_x = 0
	var/h_grad_offset_y = 0
	var/h_grad_colour = "#000000"
	var/h_grad_alpha = 200

	//Head accessory colour and style
	var/headacc_colour = "#000000"
	var/ha_style = "None"

	//Facial hair colour and style
	var/facial_colour = "#000000"
	var/sec_facial_colour = "#000000"
	var/f_style = "Shaved"


/obj/item/organ/external/head/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	if(owner && special == ORGAN_MANIPULATION_DEFAULT)
		if(!istype(dna))
			dna = owner.dna.Clone()
		get_icon()
		name = "[dna.real_name]'s head"
		owner.drop_item_ground(owner.head, force = TRUE)
		owner.drop_item_ground(owner.wear_mask, force = TRUE)
		owner.drop_item_ground(owner.glasses, force = TRUE)
		owner.drop_item_ground(owner.l_ear, force = TRUE)
		owner.drop_item_ground(owner.r_ear, force = TRUE)
		owner.update_hair()
		owner.update_fhair()
		owner.update_head_accessory()
		owner.update_markings()
	. = ..()


/obj/item/organ/external/head/replaced(mob/living/carbon/human/target)
	name = limb_zone
	. = ..()


/obj/item/organ/external/head/receive_damage(brute, burn, sharp, used_weapon = null, list/forbidden_limbs = list(), ignore_resists = FALSE, updating_health = TRUE, silent = FALSE)
	. = ..()
	if(brute_dam + burn_dam > 50)
		disfigure(silent)


/obj/item/organ/external/head/examine(mob/user)
	. = ..()
	if(in_range(user, src) || istype(user, /mob/dead/observer))
		if(!contents.len)
			. += span_notice("Выглядит пустой.")
		else
			. += span_notice("Выглядит относительно целой, внутри что-то есть.")
	else
		. += span_notice("Вы должны подойти ближе, чтобы осмотреть это.")

/obj/item/organ/external/head/proc/handle_alt_icon()
	if(alt_head && GLOB.alt_heads_list[alt_head])
		var/datum/sprite_accessory/alt_heads/alternate_head = GLOB.alt_heads_list[alt_head]
		if(alternate_head.icon_state)
			icon_name = alternate_head.icon_state
		else //If alternate_head.icon_state doesn't exist, that means alternate_head is "None", so default icon_name back to "head".
			icon_name = initial(icon_name)
	else //If alt_head is null, set it to "None" and default icon_name for sanity.
		alt_head = initial(alt_head)
		icon_name = initial(icon_name)

/obj/item/organ/external/head/robotize(make_tough = FALSE, company, convert_all = TRUE) //Undoes alt_head business to avoid getting in the way of robotization. Make sure we pass all args down the line...
	alt_head = initial(alt_head)
	icon_name = initial(icon_name)
	..()

/obj/item/organ/external/head/update_DNA(datum/dna/new_dna, update_blood = TRUE, use_species_type = TRUE, randomize = FALSE)
	..()
	new_dna?.write_head_attributes(src)

/obj/item/organ/external/head/emp_act(severity)
	..()
	if(!is_robotic() || emp_proof || !tough || !owner) // Augmented head confuses the user on EMP.
		return
	switch(severity)
		if(1)
			owner.AdjustConfused(60 SECONDS)
		if(2)
			owner.AdjustConfused(40 SECONDS)
	to_chat(owner, span_userdanger("Ваш [name] выходит из строя, перегружая ваше управление!"))

/obj/item/organ/external/tail
	limb_zone = BODY_ZONE_TAIL
	name = "tail"
	force_icon = "icons/effects/species.dmi"
	icon_name = "tail"
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	limb_body_flag = TAIL
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	amputation_point = "lower spine"
	var/datum/body_accessory/body_accessory
	var/list/m_styles = list("tail" = "None")
	var/list/m_colours = list("tail" = "#000000")
	s_col = "#000000"

/obj/item/organ/external/tail/New(mob/living/carbon/holder)
	..()
	if(!holder)
		var/icon/tempicon = new/icon("icon" = force_icon, "icon_state" = icon_name)
		var/icon/tempicon2 = new/icon(tempicon,dir=NORTH)
		tempicon2.Flip(SOUTH)
		tempicon.Insert(tempicon2,dir=SOUTH)
		force_icon = tempicon
		icon_name = null
		return

/obj/item/organ/external/tail/sync_colour_to_human(var/mob/living/carbon/human/H)
	..()
	var/datum/sprite_accessory/tail_marking_style = GLOB.marking_styles_list[H.m_styles["tail"]]
	if(body_accessory && (dna.species.name in body_accessory.allowed_species))
		body_accessory = body_accessory
	if(body_accessory)
		if(body_accessory.name in tail_marking_style.tails_allowed)
			m_styles["tail"] = H.m_styles["tail"]
	else
		if(dna.species.name in tail_marking_style.species_allowed)
			m_styles["tail"] = H.m_styles["tail"]
	if(dna.species.bodyflags & HAS_SKIN_COLOR)
		m_colours["tail"] = H.m_colours["tail"]

/obj/item/organ/external/tail/monkey
	species_type = /datum/species/monkey
	name = "monkey tail"
	icon_name = "chimptail_s"
	max_damage = 15
	min_broken_damage = 10

/obj/item/organ/external/tail/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa tail"
	icon_name = "farwatail_s"

/obj/item/organ/external/tail/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin tail"
	icon_name = "wolpintail_s"

/obj/item/organ/external/tail/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok tail"
	icon_name = "stoktail_s"

/obj/item/organ/external/wing
	limb_zone = BODY_ZONE_WING
	name = "wings"
	icon_name = "wing"
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	limb_body_flag = WING
	parent_organ_zone = BODY_ZONE_CHEST
	amputation_point = "spine"
	var/datum/body_accessory/body_accessory
	var/list/m_styles = list("wing" = "None")
	var/list/m_colours = list("wing" = "#000000")
	s_col = "#000000"

/obj/item/organ/external/wing/New(mob/living/carbon/holder)
	..()
	if(!holder)
		var/icon/tempicon = new/icon("icon" = force_icon, "icon_state" = icon_name)
		var/icon/tempicon2 = new/icon(tempicon,dir=NORTH)
		tempicon2.Flip(SOUTH)
		tempicon.Insert(tempicon2,dir=SOUTH)
		force_icon = tempicon
		icon_name = null
		return
