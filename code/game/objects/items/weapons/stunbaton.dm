// One and only
/obj/item/melee/baton/security
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	base_icon_state = "stunbaton"
	item_state = "baton"
	belt_icon = "stunbaton"
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	active = FALSE
	allows_stun_in_harm = TRUE
	force_say_chance = 50
	stamina_damage = 55
	knockdown_time = 5 SECONDS
	clumsy_knockdown_time = 15 SECONDS
	cooldown = 2.5 SECONDS
	on_stun_sound = 'sound/weapons/egloves.ogg'
	on_stun_volume = 50
	/// Time passed between a hit and knockdown effect.
	var/knockdown_delay_time = 2 SECONDS
	/// Chance for the baton to stun when thrown at someone.
	var/throw_stun_chance = 50
	/// Cell to use, can be a path, to start loaded.
	var/obj/item/stock_parts/cell/cell
	/// How much power does it cost to stun someone.
	var/cell_hit_cost = 500


/obj/item/melee/baton/security/Initialize(mapload)
	. = ..()
	link_new_cell()
	update_icon()


/obj/item/melee/baton/security/loaded
	cell = /obj/item/stock_parts/cell/high


/obj/item/melee/baton/security/Destroy()
	if(cell?.loc == src)
		QDEL_NULL(cell)
	return ..()


/obj/item/melee/baton/security/get_cell()
	return cell


/**
 * Updates the linked power cell on the baton.
 *
 * If the baton is held by a cyborg, link it to their internal cell.
 * Else, spawn a new cell and use that instead.
 * Arguments:
 * * unlink - If TRUE, sets the `cell` variable to `null` rather than linking it to a new one.
 */
/obj/item/melee/baton/security/proc/link_new_cell(unlink = FALSE)
	if(unlink)
		cell = null
		update_appearance(UPDATE_ICON_STATE)
		return
	var/mob/living/silicon/robot/robot = get(loc, /mob/living/silicon/robot)
	if(robot)
		cell = robot.cell
	else if(ispath(cell))
		cell = new cell(src)
	update_appearance(UPDATE_ICON_STATE)


/obj/item/melee/baton/security/update_icon_state()
	if(active)
		icon_state = "[base_icon_state]_active"
	else if(!cell)
		icon_state = "[base_icon_state]_nocell"
	else
		icon_state = "[base_icon_state]"


/obj/item/melee/baton/security/examine(mob/user)
	. = ..()
	if(isrobot(loc))
		. += span_notice("This baton is drawing power directly from your own internal charge.")
	if(cell)
		. += span_notice("The baton is [round(cell.percent())]% charged.")
	else
		. += span_warning("The baton does not have a power source installed.")


/obj/item/melee/baton/security/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide."))
	return FIRELOSS


/obj/item/melee/baton/security/proc/deductcharge(amount)
	if(!cell)
		return FALSE
	var/cell_rigged = cell.rigged
	. = cell.use(amount)
	if(cell_rigged)
		cell = null
		active = FALSE
		update_icon(UPDATE_ICON_STATE)
		return .

	if(cell.charge < cell_hit_cost) // If after the deduction the baton doesn't have enough charge for a stun hit it turns off.
		//we're below minimum, turn off
		active = FALSE
		update_icon(UPDATE_ICON_STATE)
		playsound(src, "sparks", 75, TRUE, -1)


/obj/item/melee/baton/security/clumsy_check(mob/living/carbon/human/user, mob/living/intented_target)
	. = ..()
	if(.)
		deductcharge(cell_hit_cost)


/obj/item/melee/baton/security/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/new_cell = I
		if(cell)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(new_cell.maxcharge < cell_hit_cost)
			balloon_alert(user, "энергоёмкость недостаточна!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(new_cell, src))
			return ..()
		cell = new_cell
		balloon_alert(user, "установлено")
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/melee/baton/security/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!cell)
		balloon_alert(user, "батарейка отсутствует!")
		return .
	if(isrobot(loc))
		balloon_alert(user, "дурацкая идея!")
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .

	cell.forceMove_turf()
	user.put_in_hands(cell, ignore_anim = FALSE)
	balloon_alert(user, "батарейка извлечена")
	cell.update_icon()
	cell = null
	active = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/melee/baton/security/attack_self(mob/user)
	if(cell?.charge >= cell_hit_cost)
		active = !active
		balloon_alert(user, "[active ? "включено" : "выключено"]")
		playsound(src, "sparks", 75, TRUE, -1)
	else
		if(isrobot(loc))
			balloon_alert(user, "недостаточно заряда!")
		else if(!cell)
			balloon_alert(user, "отсутствует батарейка!")
		else
			balloon_alert(user, "разряжено!")
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)


/obj/item/melee/baton/security/baton_effect(mob/living/target, mob/living/user, stun_override)
	if(!deductcharge(cell_hit_cost))
		return FALSE
	stun_override = 0 //Avoids knocking people down prematurely.
	return ..()


/*
 * After a target is hit, we apply some status effects.
 * After a period of time, we then check to see what stun duration we give.
 */
/obj/item/melee/baton/security/additional_effects_non_cyborg(mob/living/carbon/target, mob/living/user)
	target.AdjustJitter(40 SECONDS, bound_upper = 40 SECONDS)
	target.AdjustStuttering(16 SECONDS, bound_upper = 16 SECONDS)
	target.AdjustConfused(10 SECONDS, bound_upper = 10 SECONDS)

	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	if(iscarbon(target))
		target.shock_internal_organs(33)

	addtimer(CALLBACK(src, PROC_REF(apply_stun_effect_end), target), knockdown_delay_time)


/// After the initial stun period, we check to see if the target needs to have the stun applied.
/obj/item/melee/baton/security/proc/apply_stun_effect_end(mob/living/target)
	if(!target.IsKnockdown())
		to_chat(target, span_warning("Your muscles seize, making you collapse!"))
	target.Knockdown(knockdown_time)


/obj/item/melee/baton/security/get_wait_description()
	return span_danger("The baton is still charging!")


/obj/item/melee/baton/security/get_stun_description(mob/living/target, mob/living/user)
	. = list()
	.["visible"] = span_danger("[user] stuns [target] with [src]!")
	.["local"] = span_userdanger("[user] stuns you with [src]!")


/obj/item/melee/baton/security/get_unga_dunga_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()
	.["visible"] = span_danger("[user] tries to stun [target] with [src], and predictably fails!")
	.["local"] = span_userdanger("[user] tries to... stun you with [src]?")


/obj/item/melee/baton/security/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!. && active && prob(throw_stun_chance) && isliving(hit_atom))
		finalize_baton_attack(hit_atom, locateUID(thrownby), in_attack_chain = FALSE)


/obj/item/melee/baton/security/emp_act(severity)
	. = ..()
	deductcharge(1000 / severity)


/obj/item/melee/baton/security/wash(mob/living/user, atom/source)
	if(active && cell?.charge)
		flick("baton_active", source)
		finalize_baton_attack(user, user, in_attack_chain = FALSE)
		user.visible_message(
			span_warning("[user] shocks [user.p_themselves()] while attempting to wash the active [src]!"),
			span_userdanger("You unwisely attempt to wash [src] while it's still on."),
		)
		playsound(src, "sparks", 50, TRUE)
		deductcharge(cell_hit_cost)
		return TRUE
	return ..()


// Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/security/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	base_icon_state = "stunprod"
	item_state = "prod"
	force = 3
	throwforce = 5
	stamina_damage = 35
	knockdown_time = 3 SECONDS
	throw_stun_chance = 40
	slot_flags = ITEM_SLOT_BACK
	/// Our prescious sparks holder
	var/obj/item/assembly/igniter/sparkler


/obj/item/melee/baton/security/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new(src)


/obj/item/melee/baton/security/cattleprod/Destroy()
	QDEL_NULL(sparkler)
	return ..()


/obj/item/melee/baton/security/cattleprod/baton_effect(mob/living/target, mob/living/user, stun_override)
	if(!sparkler.activate())
		return BATON_ATTACK_DONE
	return ..()


// Teleprod
/obj/item/melee/baton/security/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	icon_state = "teleprod_nocell"
	base_icon_state = "teleprod"
	item_state = "teleprod"
	origin_tech = "combat=2;bluespace=4;materials=3"


/obj/item/melee/baton/security/cattleprod/teleprod/clumsy_check(mob/living/carbon/human/user, mob/living/intented_target)
	. = ..()
	if(!.)
		return .
	var/turf/user_turf = get_turf(user)
	do_teleport(user, user_turf, 50)	// honk honk
	user.investigate_log("[key_name_log(user)] teleprodded himself from [COORD(user_turf)].", INVESTIGATE_TELEPORTATION)


/obj/item/melee/baton/security/cattleprod/teleprod/baton_effect(mob/living/target, mob/living/user, stun_override)
	. = ..()
	if(!. || target.move_resist >= MOVE_FORCE_OVERPOWERING)
		return .
	var/turf/target_turf = get_turf(target)
	do_teleport(target, target_turf, 15)
	user.investigate_log("[key_name_log(user)] teleprodded [key_name_log(target)] from [COORD(target_turf)] to [COORD(target)].", INVESTIGATE_TELEPORTATION)

