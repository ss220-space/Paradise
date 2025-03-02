/****************************************************
			   ORGAN DEFINES
****************************************************/

/obj/item/organ/external/chest
	name = "upper body"
	desc = "Верхняя часть туловища."
	ru_names = list(
		NOMINATIVE = "грудь",
		GENITIVE = "груди",
		DATIVE = "груди",
		ACCUSATIVE = "грудь",
		INSTRUMENTAL = "грудью",
		PREPOSITIONAL = "груди"
	)
	gender = FEMALE
	limb_zone = BODY_ZONE_CHEST
	icon_name = "torso"
	max_damage = 100
	min_broken_damage = 35
	w_class = WEIGHT_CLASS_HUGE
	limb_body_flag = UPPER_TORSO
	vital = TRUE
	gendered_icon = TRUE
	parent_organ_zone = null
	amputation_point = "спину"
	encased = "грудную клетку"
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
	to_chat(owner, span_userdanger("Ваша [declent_ru(NOMINATIVE)] выходит из строя, вызывая сильное истощение!"))

/obj/item/organ/external/groin
	name = "lower body"
	desc = "Нижняя часть туловища."
	ru_names = list(
		NOMINATIVE = "живот",
		GENITIVE = "живота",
		DATIVE = "животу",
		ACCUSATIVE = "живот",
		INSTRUMENTAL = "животом",
		PREPOSITIONAL = "животе"
	)
	gender = MALE
	limb_zone = BODY_ZONE_PRECISE_GROIN
	icon_name = "groin"
	max_damage = 100
	min_broken_damage = 35
	w_class = WEIGHT_CLASS_BULKY // if you know what I mean ;)
	limb_body_flag = LOWER_TORSO
	vital = TRUE
	parent_organ_zone = BODY_ZONE_CHEST
	amputation_point = "поясницу"
	gendered_icon = TRUE

/obj/item/organ/external/arm
	name = "left arm"
	desc = "Левая рука."
	ru_names = list(
		NOMINATIVE = "левая рука",
		GENITIVE = "левой руки",
		DATIVE = "левой руке",
		ACCUSATIVE = "левую руку",
		INSTRUMENTAL = "левой рукой",
		PREPOSITIONAL = "левой руке"
	)
	gender = FEMALE
	icon_name = "l_arm"
	limb_zone = BODY_ZONE_L_ARM
	max_damage = 50
	min_broken_damage = 30
	w_class = WEIGHT_CLASS_NORMAL
	limb_body_flag = ARM_LEFT
	parent_organ_zone = BODY_ZONE_CHEST
	amputation_point = "левое плечо"
	can_grasp = TRUE
	convertable_children = list(/obj/item/organ/external/hand)

/obj/item/organ/external/arm/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented arms and hands drop whatever they are holding on EMP.
		return
	var/hand = (limb_zone == BODY_ZONE_L_ARM) ? owner.l_hand : owner.r_hand
	if(hand && owner.can_unEquip(hand))
		owner.drop_item_ground(hand)
		to_chat(owner, span_userdanger("Ваша [declent_ru(NOMINATIVE)] выходит из строя, выбрасывая удерживаемый предмет!"))
		owner.custom_emote(EMOTE_VISIBLE, "роня%(ет,ют)% удерживаемый предмет, %(его,её,его,их)% рука выходит из строя!")

/obj/item/organ/external/arm/right
	name = "right arm"
	desc = "Правая рука."
	ru_names = list(
		NOMINATIVE = "правая рука",
		GENITIVE = "правой руки",
		DATIVE = "правой руке",
		ACCUSATIVE = "правую руку",
		INSTRUMENTAL = "правой рукой",
		PREPOSITIONAL = "правой руке"
	)
	icon_name = "r_arm"
	limb_zone = BODY_ZONE_R_ARM
	limb_body_flag = ARM_RIGHT
	amputation_point = "правое плечо"
	convertable_children = list(/obj/item/organ/external/hand/right)

/obj/item/organ/external/leg
	name = "left leg"
	desc = "Левая нога."
	ru_names = list(
		NOMINATIVE = "левая нога",
		GENITIVE = "левой ноги",
		DATIVE = "левой ноге",
		ACCUSATIVE = "левую ногу",
		INSTRUMENTAL = "левой ногой",
		PREPOSITIONAL = "левой ноге"
	)
	gender = FEMALE
	icon_name = "l_leg"
	limb_zone = BODY_ZONE_L_LEG
	max_damage = 50
	min_broken_damage = 30
	w_class = WEIGHT_CLASS_NORMAL
	limb_body_flag = LEG_LEFT
	icon_position = LEFT
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	amputation_point = "левое бедро"
	convertable_children = list(/obj/item/organ/external/foot)


/obj/item/organ/external/leg/replaced(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
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
		to_chat(owner, span_userdanger("Ваша [declent_ru(NOMINATIVE)] выходит из строя, не давая вам встать!"))
		owner.custom_emote(EMOTE_VISIBLE, "не мо%(жет,гут)% встать, %(его,её,его,их)% нога выходит из строя!")
	else
		to_chat(owner, span_userdanger("Ваша [declent_ru(NOMINATIVE)] выходит из строя, заставляя вас упасть с ног!"))
		owner.custom_emote(EMOTE_VISIBLE, "пада%(ет,ют)% на пол, %(его,её,его,их)% нога выходит из строя!")
	switch(severity)
		if(1)
			owner.AdjustWeakened(8 SECONDS)
		if(2)
			owner.AdjustWeakened(4 SECONDS)

/obj/item/organ/external/leg/right
	name = "right leg"
	desc = "Правая нога."
	ru_names = list(
		NOMINATIVE = "правая нога",
		GENITIVE = "правой ноги",
		DATIVE = "правой ноге",
		ACCUSATIVE = "правую ногу",
		INSTRUMENTAL = "правой ногой",
		PREPOSITIONAL = "правой ноге"
	)
	icon_name = "r_leg"
	limb_zone = BODY_ZONE_R_LEG
	limb_body_flag = LEG_RIGHT
	icon_position = RIGHT
	amputation_point = "правое бедро"
	convertable_children = list(/obj/item/organ/external/foot/right)

/obj/item/organ/external/foot
	name = "left foot"
	desc = "Левая ступня."
	ru_names = list(
		NOMINATIVE = "левая ступня",
		GENITIVE = "левой ступни",
		DATIVE = "левой ступне",
		ACCUSATIVE = "левую ступню",
		INSTRUMENTAL = "левой ступнёй",
		PREPOSITIONAL = "левой ступне"
	)
	gender = FEMALE
	icon_name = "l_foot"
	limb_zone = BODY_ZONE_PRECISE_L_FOOT
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	limb_body_flag = FOOT_LEFT
	icon_position = LEFT
	parent_organ_zone = BODY_ZONE_L_LEG
	amputation_point = "левую лодыжку"


/obj/item/organ/external/foot/replaced(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	owner.set_num_legs(owner.num_legs + 1)
	if(is_usable())
		owner.set_usable_legs(owner.usable_legs + 1, special)
	owner.update_fractures_slowdown()


/obj/item/organ/external/foot/remove(mob/living/carbon/human/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	. = ..()
	user.set_num_legs(user.num_legs - 1)
	if(is_usable())
		user.set_usable_legs(user.usable_legs - 1, special)
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
		to_chat(owner, span_userdanger("Ваша [declent_ru(NOMINATIVE)] выходит из строя, не давая вам встать!"))
		owner.custom_emote(EMOTE_VISIBLE, "не мо%(жет,гут)% встать, %(его,её,его,их)% ступня выходит из строя!")
	else
		to_chat(owner, span_userdanger("Ваша [declent_ru(NOMINATIVE)] выходит из строя, заставляя вас упасть!"))
		owner.custom_emote(EMOTE_VISIBLE, "пада%(ет,ют)%, %(его,её,его,их)% ступня выходит из строя!")
	switch(severity)
		if(1)
			owner.AdjustWeakened(8 SECONDS)
		if(2)
			owner.AdjustWeakened(4 SECONDS)


/obj/item/organ/external/foot/right
	name = "right foot"
	desc = "Правая ступня."
	ru_names = list(
		NOMINATIVE = "правая ступня",
		GENITIVE = "правой ступни",
		DATIVE = "правой ступне",
		ACCUSATIVE = "правую ступню",
		INSTRUMENTAL = "правой ступнёй",
		PREPOSITIONAL = "правой ступне"
	)
	icon_name = "r_foot"
	limb_zone = BODY_ZONE_PRECISE_R_FOOT
	limb_body_flag = FOOT_RIGHT
	icon_position = RIGHT
	parent_organ_zone = BODY_ZONE_R_LEG
	amputation_point = "правую лодыжку"

/obj/item/organ/external/hand
	name = "left hand"
	desc = "Левая кисть."
	ru_names = list(
		NOMINATIVE = "левая кисть",
		GENITIVE = "левой кисти",
		DATIVE = "левой кисти",
		ACCUSATIVE = "левую кисть",
		INSTRUMENTAL = "левой кистью",
		PREPOSITIONAL = "левой кисти"
	)
	gender = FEMALE
	icon_name = "l_hand"
	limb_zone = BODY_ZONE_PRECISE_L_HAND
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	limb_body_flag = HAND_LEFT
	parent_organ_zone = BODY_ZONE_L_ARM
	amputation_point = "левое запястье"
	can_grasp = TRUE


/obj/item/organ/external/hand/replaced(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	owner.set_num_hands(owner.num_hands + 1)
	if(is_usable())
		owner.set_usable_hands(owner.usable_hands + 1, special, limb_zone)


/obj/item/organ/external/hand/remove(mob/living/carbon/human/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	. = ..()
	user.set_num_hands(user.num_hands - 1)
	if(is_usable())
		user.set_usable_hands(user.usable_hands - 1, special, limb_zone)
	if(special == ORGAN_MANIPULATION_DEFAULT)
		user.drop_item_ground(user.gloves, force = TRUE)
		user.drop_item_ground(limb_zone == BODY_ZONE_PRECISE_L_HAND ? user.l_hand : user.r_hand, force = TRUE)


/obj/item/organ/external/hand/necrotize(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_hands(owner.usable_hands - 1, hand_index = limb_zone)


/obj/item/organ/external/hand/unnecrotize()
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_hands(owner.usable_hands + 1, hand_index = limb_zone)


/obj/item/organ/external/hand/mutate(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_hands(owner.usable_hands - 1, hand_index = limb_zone)


/obj/item/organ/external/hand/unmutate(silent = FALSE)
	. = ..()
	if(isnull(.) || !owner)
		return .

	if(. != is_usable())
		owner.set_usable_hands(owner.usable_hands + 1, hand_index = limb_zone)


/obj/item/organ/external/hand/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented arms and hands drop whatever they are holding on EMP.
		return
	var/hand = (limb_zone == BODY_ZONE_PRECISE_L_HAND) ? owner.l_hand : owner.r_hand
	if(hand && owner.can_unEquip(hand))
		owner.drop_item_ground(hand)
		to_chat(owner, span_userdanger("Ваша [declent_ru(NOMINATIVE)] выходит из строя, выбрасывая удерживаемый предмет!"))
		owner.custom_emote(EMOTE_VISIBLE, "роня%(ет,ют)% удерживаемый предмет,, %(его,её,его,их)% кисть выходит из строя!")


/obj/item/organ/external/hand/right
	name = "right hand"
	desc = "Правая кисть."
	ru_names = list(
		NOMINATIVE = "правая кисть",
		GENITIVE = "правой кисти",
		DATIVE = "правой кисти",
		ACCUSATIVE = "правую кисть",
		INSTRUMENTAL = "правой кистью",
		PREPOSITIONAL = "правой кисти"
	)
	icon_name = "r_hand"
	limb_zone = BODY_ZONE_PRECISE_R_HAND
	limb_body_flag = HAND_RIGHT
	parent_organ_zone = BODY_ZONE_R_ARM
	amputation_point = "right wrist"

/obj/item/organ/external/head
	name = "head"
	desc = "Голова."
	ru_names = list(
		NOMINATIVE = "голова",
		GENITIVE = "головы",
		DATIVE = "голове",
		ACCUSATIVE = "голову",
		INSTRUMENTAL = "головой",
		PREPOSITIONAL = "голове"
	)
	gender = FEMALE
	limb_zone = BODY_ZONE_HEAD
	icon_name = "head"
	max_damage = 75
	min_broken_damage = 35
	w_class = WEIGHT_CLASS_NORMAL
	limb_body_flag = HEAD
	parent_organ_zone = BODY_ZONE_CHEST
	gendered_icon = TRUE
	amputation_point = "шею"
	encased = "череп"
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
		if(ru_names)
			for(var/i = 1; i <= 6; i++)
				ru_names[i] += " [dna.real_name]"
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


/obj/item/organ/external/head/replaced(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	name = limb_zone
	. = ..()


/obj/item/organ/external/head/external_receive_damage(
	brute = 0,
	burn = 0,
	blocked = 0,
	sharp = FALSE,
	used_weapon = null,
	list/forbidden_limbs = list(),
	forced = FALSE,
	updating_health = TRUE,
	silent = FALSE,
)
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
	to_chat(owner, span_userdanger("Ваша [declent_ru(NOMINATIVE)] выходит из строя, вызывая перегрузку управления!"))

/obj/item/organ/external/tail
	name = "tail"
	desc = "Хвост."
	ru_names = list(
		NOMINATIVE = "хвост",
		GENITIVE = "хвоста",
		DATIVE = "хвосту",
		ACCUSATIVE = "хвост",
		INSTRUMENTAL = "хвостом",
		PREPOSITIONAL = "хвосте"
	)
	force_icon = "icons/effects/species.dmi"
	limb_zone = BODY_ZONE_TAIL
	icon_name = "tail"
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	limb_body_flag = TAIL
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	amputation_point = "нижнюю часть спины"
	var/datum/body_accessory/body_accessory
	var/list/m_styles = list("tail" = "None")
	var/list/m_colours = list("tail" = "#000000")
	s_col = "#000000"

/obj/item/organ/external/tail/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	if(!ishuman(loc))
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
	name = "monkey tail"
	desc = "Хвост обезьяны."
	ru_names = list(
		NOMINATIVE = "хвост обезьяны",
		GENITIVE = "хвоста обезьяны",
		DATIVE = "хвосту обезьяны",
		ACCUSATIVE = "хвост обезьяны",
		INSTRUMENTAL = "хвостом обезьяны",
		PREPOSITIONAL = "хвосте обезьяны"
	)
	icon_name = "chimptail_s"
	species_type = /datum/species/monkey
	max_damage = 15
	min_broken_damage = 10

/obj/item/organ/external/tail/monkey/tajaran
	name = "farwa tail"
	desc = "Хвост фарвы."
	ru_names = list(
		NOMINATIVE = "хвост фарвы",
		GENITIVE = "хвоста фарвы",
		DATIVE = "хвосту фарвы",
		ACCUSATIVE = "хвост фарвы",
		INSTRUMENTAL = "хвостом фарвы",
		PREPOSITIONAL = "хвосте фарвы"
	)
	icon_name = "farwatail_s"
	species_type = /datum/species/monkey/tajaran

/obj/item/organ/external/tail/monkey/vulpkanin
	name = "wolpin tail"
	desc = "Хвост вульпина."
	ru_names = list(
		NOMINATIVE = "хвост вульпина",
		GENITIVE = "хвоста вульпина",
		DATIVE = "хвосту вульпина",
		ACCUSATIVE = "хвост вульпина",
		INSTRUMENTAL = "хвостом вульпина",
		PREPOSITIONAL = "хвосте вульпина"
	)
	icon_name = "wolpintail_s"
	species_type = /datum/species/monkey/vulpkanin

/obj/item/organ/external/tail/monkey/unathi
	name = "stok tail"
	desc = "Хвост стока."
	ru_names = list(
		NOMINATIVE = "хвост стока",
		GENITIVE = "хвоста стока",
		DATIVE = "хвосту стока",
		ACCUSATIVE = "хвост стока",
		INSTRUMENTAL = "хвостом стока",
		PREPOSITIONAL = "хвосте стока"
	)
	icon_name = "stoktail_s"
	species_type = /datum/species/monkey/unathi

/obj/item/organ/external/wing
	name = "wings"
	desc = "Крылья."
	ru_names = list(
		NOMINATIVE = "крылья",
		GENITIVE = "крыльев",
		DATIVE = "крыльям",
		ACCUSATIVE = "крылья",
		INSTRUMENTAL = "крыльями",
		PREPOSITIONAL = "крыльях"
	)
	gender = PLURAL
	icon_name = "wing"
	limb_zone = BODY_ZONE_WING
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	limb_body_flag = WING
	parent_organ_zone = BODY_ZONE_CHEST
	amputation_point = "спину"
	var/datum/body_accessory/body_accessory
	var/list/m_styles = list("wing" = "None")
	var/list/m_colours = list("wing" = "#000000")
	s_col = "#000000"

/obj/item/organ/external/wing/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	if(!ishuman(loc))
		var/icon/tempicon = new/icon("icon" = force_icon, "icon_state" = icon_name)
		var/icon/tempicon2 = new/icon(tempicon,dir=NORTH)
		tempicon2.Flip(SOUTH)
		tempicon.Insert(tempicon2,dir=SOUTH)
		force_icon = tempicon
		icon_name = null
		return
