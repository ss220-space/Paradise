/obj/item/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	var/base_icon = "stunbaton"
	item_state = "baton"
	belt_icon = "stunbaton"
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	/// Stamina damage
	var/staminaforce = 20
	/// How many life ticks does the stun last for
	var/stunforce = 2 SECONDS
	/// Is the baton currently turned on
	var/turned_on = FALSE
	/// How much power does it cost to stun someone
	var/hitcost = 500
	/// Chance for the baton to stun when thrown at someone
	var/throw_hit_chance = 50
	var/obj/item/stock_parts/cell/high/cell
	/// the initial cooldown tracks the time between swings. tracks the world.time when the baton is usable again.
	var/cooldown = 0.8 SECONDS


/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	update_icon()


/obj/item/melee/baton/loaded/Initialize(mapload) //this one starts with a cell pre-installed.
	link_new_cell()
	. = ..()


/obj/item/melee/baton/Destroy()
	if(cell?.loc == src)
		QDEL_NULL(cell)
	return ..()


/obj/item/melee/baton/get_cell()
	return cell


/**
 * Updates the linked power cell on the baton.
 *
 * If the baton is held by a cyborg, link it to their internal cell.
 * Else, spawn a new cell and use that instead.
 * Arguments:
 * * unlink - If TRUE, sets the `cell` variable to `null` rather than linking it to a new one.
 */
/obj/item/melee/baton/proc/link_new_cell(unlink = FALSE)
	if(unlink)
		cell = null
		return
	var/mob/living/silicon/robot/robot = get(loc, /mob/living/silicon/robot)
	cell = robot ? robot.cell : new(src)


/obj/item/melee/baton/update_icon_state()
	if(turned_on)
		icon_state = "[base_icon]_active"
	else if(!cell)
		icon_state = "[base_icon]_nocell"
	else
		icon_state = "[base_icon]"


/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(isrobot(loc))
		. += span_notice("This baton is drawing power directly from your own internal charge.")
	if(cell)
		. += span_notice("The baton is [round(cell.percent())]% charged.")
	if(!cell)
		. += span_warning("The baton does not have a power source installed.")


/obj/item/melee/baton/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide."))
	return FIRELOSS


/obj/item/melee/baton/proc/deductcharge(amount)
	if(!cell)
		return
	var/cell_rigged = cell.rigged
	cell.use(amount)
	if(cell_rigged)
		cell = null
		turned_on = FALSE
		update_icon(UPDATE_ICON_STATE)
		return

	if(cell.charge < hitcost) // If after the deduction the baton doesn't have enough charge for a stun hit it turns off.
		turned_on = FALSE
		update_icon(UPDATE_ICON_STATE)
		playsound(src, "sparks", 75, TRUE, -1)


/obj/item/melee/baton/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/new_cell = I
		if(cell)
			to_chat(user, span_notice("[src] already has a cell."))
			return
		if(new_cell.maxcharge < hitcost)
			to_chat(user, span_notice("[src] requires a higher capacity cell."))
			return
		if(!user.drop_transfer_item_to_loc(new_cell, src))
			return
		cell = new_cell
		to_chat(user, span_notice("You install a cell in [src]."))
		update_icon(UPDATE_ICON_STATE)


/obj/item/melee/baton/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, span_warning("There's no cell installed!"))
		return
	if(isrobot(loc))
		to_chat(user, span_warning("That was dumb idea!"))
		return
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	cell.forceMove_turf()
	user.put_in_hands(cell, ignore_anim = FALSE)
	to_chat(user, span_notice("You remove [cell] from [src]."))
	cell.update_icon()
	cell = null
	turned_on = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/melee/baton/attack_self(mob/user)
	if(cell?.charge >= hitcost)
		turned_on = !turned_on
		to_chat(user, span_notice("[src] is now [turned_on ? "on" : "off"]."))
		playsound(src, "sparks", 75, TRUE, -1)
	else
		if(isrobot(loc))
			to_chat(user, span_warning("You do not have enough reserve power to charge [src]!"))
		else if(!cell)
			to_chat(user, span_warning("[src] does not have a power source!"))
		else
			to_chat(user, span_warning("[src] is out of charge."))
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)


/obj/item/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(turned_on && prob(throw_hit_chance) && isliving(hit_atom) && !issilicon(hit_atom))
		baton_stun(hit_atom, throwingdatum.thrower)


/obj/item/melee/baton/attack(mob/living/target, mob/living/user)
	if(turned_on && (CLUMSY in user.mutations) && prob(50))
		if(baton_stun(user, user, skip_cooldown = TRUE)) // for those super edge cases where you clumsy baton yourself in quick succession
			user.visible_message(
				span_danger("[user] accidentally hits [user.p_themselves()] with [src]!"),
				span_userdanger("You accidentally hit yourself with [src]!"),
			)
		return

	if(issilicon(target)) // Can't stunbaton borgs and AIs
		return ..()

	if(ishuman(target))
		var/mob/living/carbon/human/h_target = target
		if(check_martial_counter(h_target, user))
			return

	if(!isliving(target))
		return

	if(user.a_intent == INTENT_HARM)
		if(turned_on)
			baton_stun(target, user)
		return ..() // Whack them too if in harm intent

	if(!turned_on)
		target.visible_message(
			span_warning("[user] has prodded [target] with [src]. Luckily it was off."),
			span_danger("[target == user ? "You prod yourself" : "[user] has prodded you"] with [src]. Luckily it was off."),
		)
		return

	if(baton_stun(target, user))
		user.do_attack_animation(target)


/// returning false results in no baton attack animation, returning true results in an animation.
/obj/item/melee/baton/proc/baton_stun(mob/living/carbon/human/target, mob/user, skip_cooldown = FALSE)
	if(cooldown > world.time && !skip_cooldown)
		return FALSE

	cooldown = world.time + initial(cooldown) // tracks the world.time when hitting will be next available.

	if(ishuman(target))
		if(target.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(target, 'sound/weapons/genhit.ogg', 50, TRUE)
			return FALSE
		target.forcesay(GLOB.hit_appends)

	if(iscarbon(target))
		target.shock_internal_organs(33)

	target.Weaken(stunforce)
	target.SetStuttering(stunforce)
	target.adjustStaminaLoss(staminaforce)

	if(user)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		target.visible_message(
			span_danger("[user] has stunned [target] with [src]!"),
			span_userdanger("[target == user ? "You stun yourself" : "[user] has stunned you"] with [src]!"),
		)
		add_attack_logs(user, target, "stunned")
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	deductcharge(hitcost)
	return TRUE


/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if(cell)
		deductcharge(1000 / severity)


/obj/item/melee/baton/wash(mob/living/user, atom/source)
	if(turned_on && cell?.charge)
		flick("baton_active", source)
		baton_stun(user, user, skip_cooldown = TRUE)
		user.visible_message(
			span_warning("[user] shocks [user.p_themselves()] while attempting to wash the active [src]!"),
			span_userdanger("You unwisely attempt to wash [src] while it's still on."),
		)
		playsound(src, "sparks", 50, TRUE)
		deductcharge(hitcost)
		return TRUE
	..()


//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	base_icon = "stunprod"
	item_state = "prod"
	w_class = WEIGHT_CLASS_NORMAL
	force = 3
	throwforce = 5
	staminaforce = 25
	stunforce = 0.5 SECONDS
	hitcost = 500
	throw_hit_chance = 50
	slot_flags = SLOT_BACK


/obj/item/melee/baton/cattleprod/baton_stun(mob/living/carbon/human/target, mob/user, skip_cooldown = FALSE)
	do_sparks(1, 1, src)
	playsound(src.loc, "sparks", 20, TRUE)
	. = ..()

