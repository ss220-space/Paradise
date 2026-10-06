/*
 * Transforming weapon component. For weapons that swap between states.
 * For example: Energy swords, cleaving saws, switch blades.
 *
 * Used to easily make an item that can be attack_self'd to gain force or change mode.
 *
 * Only values passed on initialize will update when the item is activated (except the icon_state).
 * The icon_state of the item will swap between "[icon_state]" and "[icon_state]_on" (if manual_icon_state_change FALSE as it is by default)
 */
/datum/component/transforming
	/// Whether the weapon is transformed
	var/active = FALSE
	/// Cooldown on transforming this item back and forth
	var/transform_cooldown_time
	/// Force of the weapon when active
	var/force_on
	/// Throwforce of the weapon when active
	var/throwforce_on
	/// Throw speed of the weapon when active
	var/throw_speed_on
	/// Weight class of the weapon when active
	var/w_class_on
	/// The sharpness of the weapon when active
	var/sharpness_on
	/// Hitsound played when active
	var/hitsound_on
	/// Force when the weapon is inactive
	var/force_off
	/// Throwforce when the weapon is inactive
	var/throwforce_off
	/// Throw speed of the weapon when inactive
	var/throw_speed_off
	/// Weight class of the weapon when inactive
	var/w_class_off
	/// The sharpness of the weapon when inactive
	var/sharpness_off
	/// List of the original simple attack verbs the item has.
	var/list/attack_verb_off
	/// List of simple attack verbs used when the weapon is enabled
	var/list/attack_verb_on
	/// Whether clumsy people need to succeed an RNG check to turn it on without hurting themselves
	var/clumsy_check
	/// Amount of damage to deal to clumsy people
	var/clumsy_damage
	/// If we get sharpened with a whetstone, save the bonus here for later use if we un/redeploy
	var/sharpened_bonus = 0
	/// Disable auto "_on" adding for **item state** if TRUE (FALSE by default). Use on_transform proc for icon_state change.
	var/manual_item_state_change = FALSE
	/// Disable auto "_on" adding for **icon state** if TRUE (FALSE by default). Use on_transform proc for icon_state change.
	var/manual_icon_state_change = FALSE
	/// Cooldown in between transforms
	COOLDOWN_DECLARE(transform_cooldown)

/datum/component/transforming/Initialize(
	start_transformed = FALSE,
	transform_cooldown_time = 0 SECONDS,
	force_on = 0,
	throwforce_on = 0,
	throw_speed_on = 2,
	sharpness_on = NONE,
	hitsound_on = 'sound/weapons/blade1.ogg',
	w_class_on = WEIGHT_CLASS_BULKY,
	clumsy_check = TRUE,
	clumsy_damage = 10,
	list/attack_verb_on,
	manual_item_state_change = FALSE,
	manual_icon_state_change = FALSE,
)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent

	src.transform_cooldown_time = transform_cooldown_time
	src.force_on = force_on
	src.throwforce_on = throwforce_on
	src.throw_speed_on = throw_speed_on
	src.sharpness_on = sharpness_on
	src.hitsound_on = hitsound_on
	src.w_class_on = w_class_on
	src.clumsy_check = clumsy_check
	src.clumsy_damage = clumsy_damage
	src.manual_item_state_change = manual_item_state_change
	src.manual_icon_state_change = manual_icon_state_change

	src.force_off = item_parent.force
	src.throwforce_off = item_parent.throwforce
	src.throw_speed_off = item_parent.throw_speed
	//src.sharpness_off = item_parent.sharpness // Raw value, not via the getter
	src.w_class_off = item_parent.w_class

	if(attack_verb_on)
		src.attack_verb_on = attack_verb_on
		attack_verb_off = item_parent.attack_verb

	if(start_transformed)
		toggle_active(parent)

/datum/component/transforming/RegisterWithParent()
	// var/obj/item/item_parent = parent

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	// if(item_parent.sharpness || sharpness_on)
	// 	RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))
	if(sharpness_on)
		RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))

	//RegisterSignal(parent, COMSIG_DETECTIVE_SCANNED, PROC_REF(on_scan))
	//RegisterSignal(parent, COMSIG_ITEM_APPLY_FANTASY_BONUSES, PROC_REF(apply_fantasy_bonuses))
	//RegisterSignal(parent, COMSIG_ITEM_REMOVE_FANTASY_BONUSES, PROC_REF(remove_fantasy_bonuses))
	//RegisterSignal(parent, COMSIG_ATOM_FINALIZE_MATERIAL_EFFECTS, PROC_REF(on_materials_updated))
	//RegisterSignal(parent, COMSIG_ATOM_FINALIZE_REMOVE_MATERIAL_EFFECTS, PROC_REF(on_materials_updated))
	//RegisterSignal(parent, COMSIG_ATOM_SINGLE_MATERIAL_EFFECT_APPLY, PROC_REF(on_material_apply))
	//RegisterSignal(parent, COMSIG_ATOM_SINGLE_MATERIAL_EFFECT_REMOVE, PROC_REF(on_material_remove))

/// Not ported stuff.

// /datum/component/transforming/proc/apply_fantasy_bonuses(obj/item/source, bonus)
// 	SIGNAL_HANDLER
// 	active = FALSE
// 	set_inactive(source)
// 	force_on = source.modify_fantasy_variable("force_on", force_on, bonus)
// 	throwforce_on = source.modify_fantasy_variable("throwforce_on", throwforce_on, bonus)

// /datum/component/transforming/proc/remove_fantasy_bonuses(obj/item/source, bonus)
// 	SIGNAL_HANDLER
// 	active = FALSE
// 	set_inactive(source)
// 	force_on = source.reset_fantasy_variable("force_on", force_on)
// 	throwforce_on = source.reset_fantasy_variable("throwforce_on", throwforce_on)

// /datum/component/transforming/proc/on_material_apply(obj/item/source, datum/material/material, amount, multiplier)
// 	SIGNAL_HANDLER
// 	// Opposite state's force needs to be calculated for each material's effect
// 	if (active)
// 		force_off *= GET_MATERIAL_MODIFIER(source.get_material_force_modifier(material, initial(source.sharpness)), multiplier)
// 		throwforce_off *= GET_MATERIAL_MODIFIER(source.get_material_throwforce_modifier(material, initial(source.sharpness)), multiplier)
// 	else
// 		force_on *= GET_MATERIAL_MODIFIER(source.get_material_force_modifier(material, sharpness_on), multiplier)
// 		throwforce_on *= GET_MATERIAL_MODIFIER(source.get_material_throwforce_modifier(material, sharpness_on), multiplier)

// /datum/component/transforming/proc/on_material_remove(obj/item/source, datum/material/material, amount, multiplier)
// 	SIGNAL_HANDLER
// 	// Same as appliation but inversed
// 	if (active)
// 		force_off /= GET_MATERIAL_MODIFIER(source.get_material_force_modifier(material, initial(source.sharpness)), multiplier)
// 		throwforce_off /= GET_MATERIAL_MODIFIER(source.get_material_throwforce_modifier(material, initial(source.sharpness)), multiplier)
// 	else
// 		force_on /= GET_MATERIAL_MODIFIER(source.get_material_force_modifier(material, sharpness_on), multiplier)
// 		throwforce_on /= GET_MATERIAL_MODIFIER(source.get_material_throwforce_modifier(material, sharpness_on), multiplier)

// /datum/component/transforming/proc/on_materials_updated(obj/item/source, list/materials, datum/material/main_material)
// 	SIGNAL_HANDLER
// 	// Current force can be set directly
// 	if (active)
// 		force_on = source.force
// 		throwforce_on = source.throwforce
// 	else
// 		force_off = source.force
// 		throwforce_off = source.throwforce

// /datum/component/transforming/proc/on_scan(datum/source, mob/user, datum/detective_scanner_log/entry)
// 	SIGNAL_HANDLER

// 	entry.add_data_entry(DETSCAN_CATEGORY_NOTES, "Readings suggest some form of state changing.")

/datum/component/transforming/UnregisterFromParent()
	//UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_SHARPEN_ACT, COMSIG_DETECTIVE_SCANNED, COMSIG_ATOM_FINALIZE_MATERIAL_EFFECTS, COMSIG_ATOM_FINALIZE_REMOVE_MATERIAL_EFFECTS))
	UnregisterSignal(parent, list(COMSIG_ITEM_SHARPEN_ACT, COMSIG_ITEM_ATTACK_SELF))


/*
 * Called on [COMSIG_ITEM_ATTACK_SELF].
 *
 * Check if we can transform our weapon, and if so, call [do_transform].
 * Sends signal [COMSIG_TRANSFORMING_PRE_TRANSFORM], and stops the transform action if it returns [COMPONENT_BLOCK_TRANSFORM].
 * And, if [do_transform] was successful, do a clumsy effect from [clumsy_transform_effect].
 *
 * source - source of the signal, the item being transformed / parent
 * user - the mob transforming the weapon
 */
/datum/component/transforming/proc/on_attack_self(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, transform_cooldown))
		to_chat(user, span_warning("Wait a bit before trying to use [source] again!"))
		return

	if(SEND_SIGNAL(source, COMSIG_TRANSFORMING_PRE_TRANSFORM, user, active) & COMPONENT_BLOCK_TRANSFORM)
		return

	if(do_transform(source, user))
		clumsy_transform_effect(user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/*
 * Transform the weapon into its alternate form, calling [toggle_active].
 *
 * Sends signal [COMSIG_TRANSFORMING_ON_TRANSFORM], and calls [default_transform_message] if it does not return [COMPONENT_NO_DEFAULT_MESSAGE].
 * Also starts the [transform_cooldown] if we have a set [transform_cooldown_time].
 *
 * source - the item being transformed / parent
 * user - the mob transforming the item (can be null)
 *
 * returns TRUE.
 */
/datum/component/transforming/proc/do_transform(obj/item/source, mob/user)
	toggle_active(source)
	if(!(SEND_SIGNAL(source, COMSIG_TRANSFORMING_ON_TRANSFORM, user, active) & COMPONENT_NO_DEFAULT_MESSAGE))
		default_transform_message(source, user)
	// if(!isnull(user))
	// 	SEND_SIGNAL(user, COMSIG_MOB_TRANSFORMING_ITEM, source, active)
	if(isnum(transform_cooldown_time))
		COOLDOWN_START(src, transform_cooldown, transform_cooldown_time)
	if(user)
		source.add_fingerprint(user)
	return TRUE

/*
 * The default feedback message and sound effect for an item transforming.
 *
 * source - the item being transformed / parent
 * user - the mob transforming the item
 */
/datum/component/transforming/proc/default_transform_message(obj/item/source, mob/user)
	if(user)
		source.balloon_alert(user, "[active ? "активно" : "не активно"] [source]")
	playsound(source, 'sound/weapons/batonextend.ogg', 50, TRUE)

/*
 * Toggle active between true and false, and call
 * either set_active or set_inactive depending on whichever state is toggled.
 *
 * source - the item being transformed / parent
 */
/datum/component/transforming/proc/toggle_active(obj/item/source)
	active = !active
	if(active)
		set_active(source)
	else
		set_inactive(source)

/*
 * Set our transformed item into its active state.
 * Updates all the values that were passed from init and the icon_state.
 *
 * source - the item being transformed / parent
 */
/datum/component/transforming/proc/set_active(obj/item/source)
	ADD_TRAIT(source, TRAIT_TRANSFORM_ACTIVE, UNIQUE_TRAIT_SOURCE(src))
	// if(!isnull(sharpness_on))
	// 	source.sharpness = sharpness_on
	if(sharpness_on)
		source.set_sharpness(TRUE)
	if(!isnull(force_on))
		source.force = force_on
	if(!isnull(throwforce_on))
		source.throwforce = throwforce_on
	if(!isnull(throw_speed_on))
		source.throw_speed = throw_speed_on
	if(!isnull(w_class_on))
		source.w_class = w_class_on
	if(LAZYLEN(attack_verb_on))
		source.attack_verb = attack_verb_on

	source.hitsound = hitsound_on
	if(!manual_icon_state_change)
		source.icon_state = "[source.icon_state]_on"
	// if(inhand_icon_change && source.inhand_icon_state)
	// 	source.inhand_icon_state = "[source.inhand_icon_state]_on"
	if(!manual_item_state_change)
		source.item_state = "[source.item_state]_on"
	source.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON)
	//source.update_inhand_icon()

/*
 * Set our transformed item into its inactive state.
 * Updates all the values back to the item's initial values.
 *
 * source - the item being un-transformed / parent
 */
/datum/component/transforming/proc/set_inactive(obj/item/source)
	REMOVE_TRAIT(source, TRAIT_TRANSFORM_ACTIVE, UNIQUE_TRAIT_SOURCE(src))
	// if(!isnull(sharpness_on))
	// 	source.sharpness = sharpness_off

	/// No TG sharpness system so doing this
	if(sharpness_on)
		source.set_sharpness(FALSE)

	if(!isnull(force_on))
		source.force = force_off
	if(!isnull(throwforce_on))
		source.throwforce = throwforce_off
	if(!isnull(throw_speed_on))
		source.throw_speed = throw_speed_off
	if(!isnull(w_class_on))
		source.w_class = w_class_off
	if(LAZYLEN(attack_verb_off))
		source.attack_verb = attack_verb_off

	source.hitsound = initial(source.hitsound)
	source.icon_state = source.base_icon_state ? source.base_icon_state : initial(source.icon_state)
	// source.inhand_icon_state = initial(source.inhand_icon_state)
	source.item_state = initial(source.item_state)
	source.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON)
	//source.update_inhand_icon()

/*
 * If [clumsy_check] is set to TRUE, attempt to cause a side effect for clumsy people activating this item.
 * Called after the transform is done, meaning [active] var has already updated.
 *
 * user - the clumsy mob, transforming our item (parent)
 *
 * Returns TRUE if side effects happened, FALSE otherwise
 */
/datum/component/transforming/proc/clumsy_transform_effect(mob/living/user)
	if(!clumsy_check)
		return FALSE

	if(!user || !HAS_TRAIT(user, TRAIT_CLUMSY))
		return FALSE

	if(active && prob(50))
		var/hurt_self_verb = LAZYLEN(attack_verb_on) ? pick(attack_verb_on) : "вмазал"
		user.visible_message(
			span_warning("[user] triggers [parent] while holding it backwards and [hurt_self_verb] themself, like a doofus!"),
			span_warning("You trigger [parent] while holding it backwards and [hurt_self_verb] yourself, like a doofus!"),
		)
		var/obj/item/item_parent = parent
		user.apply_damage(clumsy_damage, item_parent.damtype)
		return TRUE

	return FALSE

/*
 * Called on [COMSIG_ITEM_SHARPEN_ACT].
 * We need to track our sharpened bonus here, so we correctly apply and unapply it
 * if our item's sharpness state changes from transforming.
 *
 * source - the item being sharpened / parent
 * increment - the amount of force added
 * max - the maximum force that the item can be adjusted to.
 *
 * Does not return naturally [COMPONENT_BLOCK_SHARPEN_APPLIED] as this is only to track our sharpened bonus between transformation.
 */
/datum/component/transforming/proc/on_sharpen(obj/item/source, increment, max)
	SIGNAL_HANDLER

	if(sharpened_bonus)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	if(force_on + increment > max)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	sharpened_bonus = increment
	force_on += sharpened_bonus
	throwforce_on += sharpened_bonus
	force_off += sharpened_bonus
	throwforce_off += sharpened_bonus
	/// Mimics base whetstone effect for the on state
	//sharpness_on = SHARP_EDGED
	if(!active)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED
