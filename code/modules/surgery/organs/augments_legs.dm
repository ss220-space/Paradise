/obj/item/organ/internal/cyberimp/leg
	name = "leg implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	parent_organ_zone = BODY_ZONE_R_LEG
	icon_state = "implant-leg"
	w_class = WEIGHT_CLASS_NORMAL

	//to determine what type of implant for checking if both legs are the same
	var/implant_type = "leg implant"
	COOLDOWN_DECLARE(emp_notice)

/obj/item/organ/internal/cyberimp/leg/Initialize(mapload)
	. = ..()
	update_icon()
	slot = parent_organ_zone + "_device"

/obj/item/organ/internal/cyberimp/leg/emp_act(severity)
	. = ..()
	if(emp_proof)
		return

	var/obj/item/organ/external/E = owner.get_organ(parent_organ_zone)
	if(!E)	//how did you get an implant in a limb you don't have?
		return

	owner.apply_damage(5, def_zone = E)	//always take a least a little bit of damage to the leg

	if(prob(50))	//you're forced to use two of these for them to work so let's give em a chance to not get completely fucked
		if(COOLDOWN_FINISHED(src, emp_notice))
			to_chat(owner, span_warning("ЭМИ вызывает вызывает сбои в работе [src.declent_ru(GENITIVE)] в [GLOB.body_zone[parent_organ_zone][PREPOSITIONAL]]!"))
			COOLDOWN_START(src, emp_notice, 30 SECONDS)
		return

	if(severity & EMP_HEAVY && prob(25) )	//put probabilities into a calculator before you try fucking with this
		to_chat(owner, span_warning("ЭМИ заставляет ваш [src.declent_ru(ACCUSATIVE)] дико дёргать [GLOB.body_zone[parent_organ_zone][ACCUSATIVE]], ломая его!"))
		owner.apply_damage(40, def_zone = E)
	else if(COOLDOWN_FINISHED(src, emp_notice))
		to_chat(owner, span_warning("ЭМИ вызывает заклинивание [src.declent_ru(ACCUSATIVE)], блокируя движение [GLOB.body_zone[parent_organ_zone][GENITIVE]]!"))
		COOLDOWN_START(src, emp_notice, 30 SECONDS)


/obj/item/organ/internal/cyberimp/leg/examine(mob/user)
	. = ..()
	. += span_notice("[capitalize(src.declent_ru(NOMINATIVE))] собран для [parent_organ_zone == BODY_ZONE_R_LEG ? "правой" : "левой"] ноги. Можно пересобрать с помощью отвёртки.")
	. += span_notice("Для правильной работы потребуется два импланта одного типа.")


/obj/item/organ/internal/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(parent_organ_zone == BODY_ZONE_R_LEG)
		parent_organ_zone = BODY_ZONE_L_LEG
		transform = matrix(-1, 0, 0, 0, 1, 0)	// Mirroring the icon
	else
		parent_organ_zone = BODY_ZONE_R_LEG
		transform = null
	SetSlot()
	to_chat(user, span_notice("Вы модифицировали [src.declent_ru(ACCUSATIVE)] для установки на [parent_organ_zone == BODY_ZONE_R_LEG ? "правую" : "левую"] ногу."))


/obj/item/organ/internal/cyberimp/leg/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(HasBoth())
		AddEffect()

/obj/item/organ/internal/cyberimp/leg/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	RemoveEffect()
	. = ..()

/obj/item/organ/internal/cyberimp/leg/proc/HasBoth()
	if(owner.get_organ_slot(INTERNAL_ORGAN_R_LEG_DEVICE) && owner.get_organ_slot(INTERNAL_ORGAN_L_LEG_DEVICE))
		var/obj/item/organ/internal/cyberimp/leg/left = owner.get_organ_slot(INTERNAL_ORGAN_R_LEG_DEVICE)
		var/obj/item/organ/internal/cyberimp/leg/right = owner.get_organ_slot(INTERNAL_ORGAN_L_LEG_DEVICE)
		if(left.implant_type == right.implant_type)
			return TRUE
	return FALSE

/obj/item/organ/internal/cyberimp/leg/proc/AddEffect()
	return

/obj/item/organ/internal/cyberimp/leg/proc/RemoveEffect()
	return

/obj/item/organ/internal/cyberimp/leg/proc/SetSlot()
	switch(parent_organ_zone)
		if(BODY_ZONE_L_LEG)
			slot = INTERNAL_ORGAN_L_LEG_DEVICE
		if(BODY_ZONE_R_LEG)
			slot = INTERNAL_ORGAN_R_LEG_DEVICE
		else
			CRASH("Invalid zone for [type]")

//100 lines of code for only one fucking implant

//------------dash boots implant
/obj/item/organ/internal/cyberimp/leg/jumpboots
	name = "jumpboots implant"
	desc = "An implant with a specialized propulsion system for rapid foward movement."
	implant_type = "jumpboots"
	var/datum/action/bhop/implant_ability

/obj/item/organ/internal/cyberimp/leg/jumpboots/l
	parent_organ_zone = BODY_ZONE_L_LEG

/obj/item/organ/internal/cyberimp/leg/jumpboots/AddEffect()
	var/obj/item/organ/internal/cyberimp/leg/jumpboots/left = owner.get_organ_slot(INTERNAL_ORGAN_R_LEG_DEVICE) //leading leg or somethin
	if(!left.implant_ability)
		left.implant_ability = new(src)
		left.implant_ability.Grant(owner)

/obj/item/organ/internal/cyberimp/leg/jumpboots/RemoveEffect()
	var/obj/item/organ/internal/cyberimp/leg/jumpboots/left = owner.get_organ_slot(INTERNAL_ORGAN_R_LEG_DEVICE)
	if(left?.implant_ability)
		left.implant_ability.Remove(owner)
		left.implant_ability = null

/datum/action/bhop
	name = "Activate Jump Boots"
	desc = "Activates the jump boot's implant internal propulsion system, allowing the user to dash over 4-wide gaps."
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "jetboot"
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash
	var/datum/callback/last_jump = null
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_IMMOBILE //lying jumps is real


/datum/action/bhop/Trigger(left_click = TRUE)
	if(!IsAvailable())
		return

	if(recharging_time > world.time)
		to_chat(owner, span_warning("Встроенный двигатель ботинка ещё не перезарядился!"))
		return

	if(owner.no_gravity())
		to_chat(owner, span_warning("Нельзя прыгать без гравитации!"))
		return

	if(owner.throwing)
		to_chat(owner, span_warning("Нельзя прыгать во время другого прыжка!"))
		return

	var/atom/target = get_edge_target_turf(owner, owner.dir) //gets the user's direction

	if(last_jump) //in case we are trying to perfom jumping while first jump was not complete
		last_jump.Invoke()
	ADD_TRAIT(owner, TRAIT_MOVE_FLYING, IMPLANT_JUMP_BOOTS_TRAIT)
	var/after_jump_callback = CALLBACK(src, PROC_REF(after_jump), owner)
	if(owner.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = after_jump_callback))
		last_jump = after_jump_callback
		playsound(owner.loc, 'sound/effects/stealthoff.ogg', 50, TRUE, 1)
		owner.visible_message(span_warning("[owner] стремительно взмывает в воздух!"))
		recharging_time = world.time + recharging_rate
	else
		to_chat(owner, span_warning("Что-то мешает вам сделать рывок вперёд!"))
		after_jump(owner)


/datum/action/bhop/proc/after_jump(mob/owner)
	REMOVE_TRAIT(owner, TRAIT_MOVE_FLYING, IMPLANT_JUMP_BOOTS_TRAIT)
	last_jump = null


