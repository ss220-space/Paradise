/*
 * Transforming weapon component. For weapons that swap between states.
 * For example: Energy swords, cleaving saws, switch blades.
 *
 * Used to easily make an item that can be attack_self'd to gain force or change mode.
 *
 * Only values passed on initialize will update when the item is activated (except the icon_state).
 * The icon_state of the item will swap between "[icon_state]" and "[icon_state]_on".
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
	/// Item will be sharp only when transformed
	var/sharp_on
	/// Hitsound played when active
	var/hitsound_on
	/// Hitsound played when inactive
	var/hitsound_off
	/// List of the original attack verbs the item has.
	var/list/attack_verb_off
	/// List of attack verbs used when the weapon is enabled
	var/list/attack_verb_on
	/// Whether clumsy people need to succeed an RNG check defined here to turn it on without hurting themselves
	var/clumsy_check_prob
	/// Amount of damage to deal to clumsy people
	var/clumsy_damage
	/// If we get sharpened with a whetstone, save the bonus here for later use if we un/redeploy
	var/sharpened_bonus = 0
	/// Item state, when active
	var/item_state_on
	/// Cooldown in between transforms
	COOLDOWN_DECLARE(transform_cooldown)


/datum/component/transforming/Initialize(
	start_transformed = FALSE,
	transform_cooldown_time = 0 SECONDS,
	force_on = 0,
	throwforce_on = 0,
	throw_speed_on = 2,
	sharp_on = FALSE,
	hitsound_on = 'sound/weapons/blade1.ogg',
	hitsound_off,
	w_class_on = WEIGHT_CLASS_BULKY,
	item_state_on,
	clumsy_check_prob = 50,
	clumsy_damage = 10,
	list/attack_verb_on,
)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent

	src.transform_cooldown_time = transform_cooldown_time
	src.force_on = force_on
	src.throwforce_on = throwforce_on
	src.throw_speed_on = throw_speed_on
	src.sharp_on = sharp_on
	src.hitsound_on = hitsound_on
	src.hitsound_off = hitsound_off
	src.w_class_on = w_class_on
	src.clumsy_check_prob = clumsy_check_prob
	src.clumsy_damage = clumsy_damage

	if(item_state_on)
		src.item_state_on = item_state_on

	if(attack_verb_on)
		src.attack_verb_on = attack_verb_on
		attack_verb_off = item_parent.attack_verb

	if(start_transformed)
		toggle_active(parent)


/datum/component/transforming/RegisterWithParent()
	var/obj/item/item_parent = parent

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_update_icon))
	if(item_parent.sharp || sharp_on)
		RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))


/datum/component/transforming/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ATOM_UPDATE_ICON, COMSIG_ITEM_SHARPEN_ACT))


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
		source.balloon_alert(user, "идёт перезарядка!")
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
 * user - the mob transforming the item
 *
 * returns TRUE.
 */
/datum/component/transforming/proc/do_transform(obj/item/source, mob/user)
	toggle_active(source)
	if(!(SEND_SIGNAL(source, COMSIG_TRANSFORMING_ON_TRANSFORM, user, active) & COMPONENT_NO_DEFAULT_MESSAGE))
		default_transform_message(source, user)

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
		source.balloon_alert(user, "[active ? "активно" : "не активно"]")
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
	if(sharp_on)
		source.set_sharpness(TRUE)
	if(force_on)
		source.force = force_on + (source.sharp ? sharpened_bonus : 0)
	if(throwforce_on)
		source.throwforce = throwforce_on + (source.sharp ? sharpened_bonus : 0)
	if(throw_speed_on)
		source.throw_speed = throw_speed_on

	if(LAZYLEN(attack_verb_on))
		source.attack_verb = attack_verb_on

	source.hitsound = hitsound_on
	source.w_class = w_class_on
	source.update_appearance()
	source.update_equipped_item()


/*
 * Set our transformed item into its inactive state.
 * Updates all the values back to the item's initial values.
 *
 * source - the item being un-transformed / parent
 */
/datum/component/transforming/proc/set_inactive(obj/item/source)
	REMOVE_TRAIT(source, TRAIT_TRANSFORM_ACTIVE, UNIQUE_TRAIT_SOURCE(src))
	if(sharp_on)
		source.set_sharpness(FALSE)
	if(force_on)
		source.force = initial(source.force) + (source.sharp ? sharpened_bonus : 0)
	if(throwforce_on)
		source.throwforce = initial(source.throwforce) + (source.sharp ? sharpened_bonus : 0)
	if(throw_speed_on)
		source.throw_speed = initial(source.throw_speed)

	if(LAZYLEN(attack_verb_on))
		source.attack_verb = attack_verb_off

	source.hitsound = hitsound_off
	source.w_class = initial(source.w_class)
	source.update_appearance()
	source.update_equipped_item()


/*
 * If [clumsy_check_prob] is set to anything but 0, attempt to cause a side effect for clumsy people activating this item.
 * Called after the transform is done, meaning [active] var has already updated.
 *
 * user - the clumsy mob, transforming our item (parent)
 *
 * Returns TRUE if side effects happened, FALSE otherwise
 */
/datum/component/transforming/proc/clumsy_transform_effect(mob/living/user)
	if(!clumsy_check_prob || !isnum(clumsy_check_prob))
		return FALSE

	if(!user || !HAS_TRAIT(user, TRAIT_CLUMSY))
		return FALSE

	if(!active || !prob(clumsy_check_prob))
		return FALSE

	var/obj/item/item_parent = parent
	var/hurt_verb = LAZYLEN(attack_verb_on) ? pick(attack_verb_on) : "hit"
	user.visible_message(
		span_warning("[user] triggers [item_parent] while holding it backwards and [hurt_verb] themself, like a doofus!"),
		span_warning("You trigger [item_parent] while holding it backwards and accidentally [hurt_verb] yourself!"),
	)
	switch(item_parent.damtype)
		if(STAMINA)
			user.adjustStaminaLoss(clumsy_damage)
		if(OXY)
			user.adjustOxyLoss(clumsy_damage)
		if(TOX)
			user.adjustToxLoss(clumsy_damage)
		if(BRUTE)
			user.adjustBruteLoss(clumsy_damage)
		if(BURN)
			user.adjustFireLoss(clumsy_damage)
	return TRUE


/**
 * on_update_icon triggers on call to update parent items icon
 *
 * Updates item's icon_state and item_state if inhand_icon_change is set to `TRUE`
 */
/datum/component/transforming/proc/on_update_icon(obj/item/source)
	SIGNAL_HANDLER

	var/initial_icon_state = replacetext("[source.icon_state]", "_on", "")
	if(active)
		source.icon_state = "[initial_icon_state]_on"
		if(item_state_on)
			source.item_state = item_state_on
	else
		source.icon_state = initial_icon_state
		if(item_state_on)
			source.item_state = initial(source.item_state)

	return COMSIG_ATOM_NO_UPDATE_ICON_STATE


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
	if(active)
		var/obj/item/item_parent = parent
		if(force_on)
			item_parent.force = initial(item_parent.force) + (item_parent.sharp ? sharpened_bonus : 0)
		if(throwforce_on)
			item_parent.throwforce = initial(item_parent.throwforce) + (item_parent.sharp ? sharpened_bonus : 0)
	return COMPONENT_BLOCK_SHARPEN_APPLIED

