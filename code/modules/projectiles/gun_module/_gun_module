/**
 * MARK: Basic module
 */
/obj/item/gun_module
	name = "unknown gun module"
	desc = "Неизвестный модуль для оружия."
	gender = MALE
	icon = 'icons/obj/weapons/attachments.dmi'
	lefthand_file = 'icons/mob/inhands/attachments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/attachments_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 100, MAT_GLASS = 50)
	var/slot
	var/class
	var/overlay_state = "comp"
	var/overlay_offset
	var/buffered_overlay = null
	//attached state variables
	var/obj/item/gun/gun = null
	/// Is module can detached
	var/can_detach = TRUE

/obj/item/gun_module/Destroy()
	. = ..()
	gun = null
	if(buffered_overlay)
		QDEL_NULL(buffered_overlay)

/// Try attach module to gun, return TRUE if success
/obj/item/gun_module/proc/try_attach(obj/item/gun/target_gun, mob/user)
	if(!isgun(target_gun))
		user.balloon_alert(user, "несовместимо с модулями")
		return FALSE
	var/obj/item/gun/gun = target_gun
	var/allowed = gun.attachable_allowed & class
	if(!allowed)
		user.balloon_alert(user, "несовместимое оружие")
		return FALSE
	if(gun.attachments_by_slot[slot] != null)
		user.balloon_alert(user, "слот для модуля занят")
		return FALSE
	return attach_without_check(gun, user)

/// Attaching module to gun without check, use try_attach(/obj/item/gun/target, mob/user) for checks
/obj/item/gun_module/proc/attach_without_check(obj/item/gun/target_gun, mob/user)
	if(!do_after(user, 1 SECONDS, target_gun))
		return FALSE
	target_gun.attachments_by_slot[slot] = src
	target_gun.add_attachment_overlay(src)
	user.drop_transfer_item_to_loc(src, target_gun)
	gun = target_gun
	src.on_attach(target_gun, user)
	SEND_SIGNAL(target_gun, COMSIG_GUN_MODULE_ATTACH, user, target_gun, src)
	user.balloon_alert(user, "модуль установлен")
	return TRUE

/// Detaching module from gun without check, use try_detach(/obj/item/gun/target, mob/user) for checks
/obj/item/gun_module/proc/detach_without_check(obj/item/gun/target_gun, mob/user, force = FALSE, put_in_hands = TRUE, silence = FALSE)
	if(!force && !do_after(user, 1 SECONDS, target_gun))
		return FALSE
	src.on_detach(target_gun, user)
	target_gun.attachments_by_slot[slot] = null
	target_gun.remove_attachment_overlay(src)
	SEND_SIGNAL(target_gun, COMSIG_GUN_MODULE_DETACH, user, target_gun, src)
	if(put_in_hands)
		user.put_in_hands(src)
	else
		src.forceMove(target_gun.drop_location())
	gun = null
	if(!silence)
		user.balloon_alert(user, "модуль снят")
	return TRUE

/obj/item/gun_module/proc/create_overlay()
	if(!buffered_overlay)
		buffered_overlay = mutable_appearance(icon, overlay_state, layer = FLOAT_LAYER - 1)
	return buffered_overlay

/obj/item/gun_module/proc/on_attach(obj/item/gun/target_gun, mob/user)
	return

/obj/item/gun_module/proc/on_detach(obj/item/gun/target_gun, mob/user)
	return
