/**
 * Spell-system extensions needed by the heretic's tg-derived spells.
 *
 * master220's /obj/effect/proc_holder/spell already provides the modern targeting /
 * cooldown / click-intercept infrastructure (targeting, cooldown_handler, base_cooldown,
 * before_cast/after_cast, add/remove_mousepointer, InterceptClickOn, choose_targets, ...).
 * This file only adds the few pieces the heretic spells rely on that master220 lacks:
 *   - get_things_to_cast_on() helpers
 *   - on_spell_loss() / can_add() / update_status_on_signal() base hooks
 *   - the /pointed and /pointed/projectile spell subclasses
 *   - can_block_magic() / can_cast_magic() antimagic compat shims
 *
 * Kept self-contained in the heretic module so the core spell.dm is untouched.
 */

/obj/effect/proc_holder/spell/proc/get_things_to_cast_on(mob/user)
	return targeting.choose_targets(user, src)

/obj/effect/proc_holder/spell/aoe/get_things_to_cast_on(atom/center, radius_override)
	return targeting.choose_targets(action.owner, src, null, center, radius_override)

/// Called when a spell is removed from a mob.
/obj/effect/proc_holder/spell/proc/on_spell_loss(mob/user = usr)
	return

/// Returns whether the spell can be added to the given mob.
/obj/effect/proc_holder/spell/proc/can_add(mob/granted)
	return TRUE

/// Relays a status-update request to the backing action button, if any.
/obj/effect/proc_holder/spell/proc/update_status_on_signal()
	return

/**
 * ## Pointed spells
 *
 * These spells override the caster's click, allowing them to cast the spell on whatever
 * is clicked on. To add effects on cast, override cast(). targets[1] is the clicked atom.
 */
/obj/effect/proc_holder/spell/pointed
	/// Message shown to the spell owner upon activating the pointed spell.
	var/active_msg
	/// Message shown to the spell owner upon deactivating the pointed spell.
	var/deactive_msg
	/// The casting range of our spell.
	var/cast_range = 7
	/// If aim assist is used. Disable to disable.
	var/aim_assist = TRUE


/obj/effect/proc_holder/spell/pointed/New(Target)
	. = ..()
	if(!active_msg)
		active_msg = "You prepare to use [src] on a target..."
	if(!deactive_msg)
		deactive_msg = "You dispel [src]."


/obj/effect/proc_holder/spell/pointed/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/spell_targeting = new()
	spell_targeting.range = cast_range
	return spell_targeting


/obj/effect/proc_holder/spell/pointed/add_mousepointer(client/on_who)
	. = ..()
	on_activation(on_who.eye)


// Note: Destroy() calls Remove(), Remove() calls remove_mousepointer() if our spell is active.
/obj/effect/proc_holder/spell/pointed/remove_mousepointer(client/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!on_who)
		return
	on_deactivation(on_who.eye, refund_cooldown = refund_cooldown)


// Merged from the two duplicate before_cast() defs in the selfharm source (which would not compile):
// handles both the cancel-cleanup and the out-of-range check.
/obj/effect/proc_holder/spell/pointed/before_cast(list/targets)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		on_deactivation(action.owner, refund_cooldown = FALSE)
		return
	var/atom/cast_on = length(targets) ? targets[1] : null
	if(!action?.owner || !cast_on || get_dist(get_turf(action.owner), get_turf(cast_on)) <= cast_range)
		return
	cast_on.balloon_alert(action.owner, "слишком далеко!")
	return . | SPELL_CANCEL_CAST


/// Called when the spell is activated / the click ability is set to our spell.
/obj/effect/proc_holder/spell/pointed/proc/on_activation(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)
	to_chat(on_who, span_notice("[active_msg] <B>Left-click to cast the spell on a target!</B>"))
	action?.UpdateButtonIcon()
	return TRUE


/// Called when the spell is deactivated / the click ability is unset from our spell.
/obj/effect/proc_holder/spell/pointed/proc/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(refund_cooldown)
		// Only send the "deactivation" message if they're willingly disabling the ability.
		to_chat(on_who, span_notice("[deactive_msg]"))
	action?.UpdateButtonIcon()
	return TRUE


/obj/effect/proc_holder/spell/pointed/InterceptClickOn(mob/living/clicker, params, atom/target)
	var/atom/aim_assist_target
	if(aim_assist)
		aim_assist_target = aim_assist(clicker, target)
	return ..(clicker, params, aim_assist_target || target)


/obj/effect/proc_holder/spell/pointed/proc/aim_assist(mob/living/clicker, atom/target)
	if(!isturf(target))
		return
	// Find any human, or if that fails, any living target.
	return (locate(/mob/living/carbon/human) in target) || (locate(/mob/living) in target)


/**
 * ### Pointed projectile spells
 *
 * Pointed spells that, instead of casting directly on the clicked target, fire a projectile
 * in the target's direction.
 */
/obj/effect/proc_holder/spell/pointed/projectile
	should_recharge_after_cast = FALSE
	/// What projectile we create when we shoot our spell.
	var/obj/projectile/projectile_type = /obj/projectile/magic/teleport
	/// How many projectiles we can fire per cast (like charges).
	var/projectile_amount = 1
	/// How many projectiles we have yet to fire, based on projectile_amount.
	var/current_amount = 0
	/// How many projectiles we fire every fire_projectile() call.
	var/projectiles_per_fire = 1


/obj/effect/proc_holder/spell/pointed/projectile/should_remove_click_intercept(mob/user)
	return !current_amount


/obj/effect/proc_holder/spell/pointed/projectile/valid_target(atom/cast_on)
	return TRUE


/obj/effect/proc_holder/spell/pointed/projectile/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return
	current_amount = projectile_amount


/obj/effect/proc_holder/spell/pointed/projectile/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(projectile_amount < 1 || projectile_amount == current_amount)
		return
	cooldown_handler.start_recharge(base_cooldown * ((projectile_amount - current_amount) / projectile_amount))
	current_amount = 0


// targets[1] is a turf, or atom target, that we clicked on to fire at.
/obj/effect/proc_holder/spell/pointed/projectile/cast(list/targets)
	. = ..()
	if(!isturf(action.owner.loc))
		return FALSE
	var/atom/cast_on = targets[1]
	var/turf/caster_turf = get_turf(action.owner)
	// Get the tile in front of the caster, based on their direction.
	var/turf/caster_front_turf = get_step(action.owner, action.owner.dir)
	fire_projectile(cast_on)
	action.owner.newtonian_move(get_angle(caster_front_turf, caster_turf))
	if(current_amount <= 0)
		remove_mousepointer(action.owner.client, refund_cooldown = FALSE)
	return TRUE


/obj/effect/proc_holder/spell/pointed/projectile/after_cast(atom/cast_on)
	. = ..()
	if(current_amount != 0)
		return
	cooldown_handler.start_recharge()
	remove_mousepointer(action.owner.client)


/obj/effect/proc_holder/spell/pointed/projectile/proc/fire_projectile(atom/target)
	current_amount--
	for(var/i in 1 to projectiles_per_fire)
		var/obj/projectile/to_fire = new projectile_type()
		ready_projectile(to_fire, target, action.owner, i)
		to_fire.fire()
	return TRUE


/obj/effect/proc_holder/spell/pointed/projectile/proc/ready_projectile(obj/item/projectile/to_fire, atom/target, mob/user, iteration)
	var/turf/source_turf = get_turf(user)
	to_fire.firer = action.owner
	var/turf/target_turf = get_turf(target)
	to_fire.preparePixelProjectile(target, target_turf, user, targeting.click_params)
	to_fire.fire()
	user.newtonian_move(get_dir(target_turf, source_turf))


// --- Antimagic compatibility shims ---
// master220 has no unified antimagic check (anti_magic_check is only a vestigial signal comment),
// so these default to "no antimagic". Proper antimagic mapping (null rod / holy) is a later refinement.

/mob/proc/can_block_magic(magic_flags = MAGIC_RESISTANCE, charge_cost = 0)
	return FALSE

/mob/proc/can_cast_magic(magic_flags = MAGIC_RESISTANCE)
	return !can_block_magic(magic_flags)

// --- Touch spell hand helper ---
// Removes the touch hand without refunding the spell's cooldown (tg's godhand proc, not in master220).
/obj/item/melee/touch_attack/proc/remove_hand_with_no_refund(mob/holder)
	var/obj/effect/proc_holder/spell/touch/hand_spell = attached_spell
	if(!QDELETED(hand_spell))
		hand_spell.discharge_hand(holder)
		return
	// No spell associated for some reason, just delete us as normal.
	holder.drop_item_ground(src, force = TRUE)
	qdel(src)
