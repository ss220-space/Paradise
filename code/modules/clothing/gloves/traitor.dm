/obj/item/clothing/gloves/color/yellow/stun
	name = "stun gloves"
	desc = "Эти перчатки не защитят ваших врагов от электрического удара."
	var/obj/item/stock_parts/cell/cell = null
	var/stun_strength = 2 SECONDS
	var/stun_cost = 1500

/obj/item/clothing/gloves/color/yellow/stun/get_ru_names()
	return alist(
		NOMINATIVE = "оглушающие перчатки",
		GENITIVE = "оглушающих перчаток",
		DATIVE = "оглушающим перчаткам",
		ACCUSATIVE = "оглушающие перчатки",
		INSTRUMENTAL = "оглушающими перчатками",
		PREPOSITIONAL = "оглушающих перчатках",
	)

/obj/item/clothing/gloves/color/yellow/stun/get_cell()
	return cell

/obj/item/clothing/gloves/color/yellow/stun/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/gloves/color/yellow/stun/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/clothing/gloves/color/yellow/stun/Touch(atom/A, proximity)
	if(!ishuman(loc))
		return FALSE //Only works while worn
	if(!iscarbon(A))
		return FALSE
	if(!proximity)
		return FALSE
	if(cell)
		var/mob/living/carbon/human/H = loc
		if(H.a_intent == INTENT_HARM)
			var/mob/living/carbon/C = A
			if(cell.use(stun_cost))
				do_sparks(5, FALSE, loc)
				playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
				H.do_attack_animation(C)
				visible_message(span_danger("[H] дотрагива[PLUR_ET_YUT(H)]ся [declent_ru(INSTRUMENTAL)] до [C]!"))
				add_attack_logs(H, C, "Touched with stun gloves")
				C.Weaken(stun_strength)
				C.Stuttering(stun_strength)
				C.apply_damage(20, STAMINA)
			else
				balloon_alert(H, "недостаточно заряда!")
			return TRUE
	return FALSE

/obj/item/clothing/gloves/color/yellow/stun/update_overlays()
	. = ..()
	. += "gloves_wire"
	if(cell)
		. += "gloves_cell"

/obj/item/clothing/gloves/color/yellow/stun/attackby(obj/item/I, mob/living/user, params)
	if(iscell(I))
		add_fingerprint(user)
		if(cell)
			balloon_alert(user, "батарея уже установлена!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		balloon_alert(user, "присоединено")
		cell = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/clothing/gloves/color/yellow/stun/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(cell)
		balloon_alert(user, "отсоединено")
		cell.forceMove(get_turf(loc))
		cell = null
		update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/gloves/color/yellow/stun/emp_act()
	if(!ishuman(loc))
		return ..()
	var/mob/living/carbon/human/H = loc
	if(cell?.use(stun_cost))
		H.Weaken(8 SECONDS)
		H.adjustFireLoss(rand(10, 25))
		H.apply_effect(STUTTER, 5 SECONDS)

/obj/item/clothing/gloves/fingerless/rapid
	var/accepted_intents = list(INTENT_HARM)
	var/click_speed_modifier = CLICK_CD_RAPID
	var/mob/living/owner

/obj/item/clothing/gloves/fingerless/rapid/equipped(mob/user, slot, initial)
	owner = user
	if(istype(owner) && slot == ITEM_SLOT_GLOVES)
		owner.dirslash_enabled = TRUE
		ASSIGN_GAME_VERB(owner, /mob/living/carbon/human, dirslash_enabling)
	return ..()

/obj/item/clothing/gloves/fingerless/rapid/dropped(mob/user, slot, silent = FALSE)
	UNASSIGN_GAME_VERB(owner, /mob/living/carbon/human, dirslash_enabling)
	owner.dirslash_enabled = initial(owner.dirslash_enabled)
	return ..()

/obj/item/clothing/gloves/fingerless/rapid/Touch(mob/living/target, proximity = TRUE)
	var/mob/living/M = loc

	if(M.a_intent in accepted_intents)
		if(M.mind.martial_art)
			M.changeNext_move(CLICK_CD_MELEE)//normal attack speed for hulk, CQC and Carp.
		else
			M.changeNext_move(click_speed_modifier)
	.= FALSE

/obj/item/clothing/gloves/fingerless/rapid/admin
	name = "Advanced Interactive Gloves"
	desc = "The gloves are covered in indecipherable buttons and dials, your mind warps by merely looking at them."
	accepted_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	click_speed_modifier = 0
	siemens_coefficient = 0

/obj/item/clothing/gloves/fingerless/rapid/headpat
	name = "Gloves of Headpats"
	desc = "You feel the irresistable urge to give headpats by merely glimpsing these."
	accepted_intents = list(INTENT_HELP)
