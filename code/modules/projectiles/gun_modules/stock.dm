/**
 * MARK: Stock
 */
/obj/item/gun_module/stock
	name = "telescopic stock"
	desc = "Телескопический приклад. Позволяет лучше контролировать отдачу, повышая кучность при стрельбе."
	icon_state = "stock"
	item_state = "stock"
	overlay_state = "stock_o"
	overlay_offset = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)
	slot = ATTACHMENT_SLOT_STOCK
	class = GUN_MODULE_CLASS_SMG_STOCK
	custom_price = 2 * PAYCHECK_LOWER
	/// State flag
	var/unfolded = FALSE
	/// How many spread decrease with unfold stock
	var/spread_compensation_mod = 0.5
	/// How many recoil decrease with unfold stock
	var/recoil_compensation_mod = 0.5
	/// Buffer variable for unfolded stock overlay
	var/mutable_appearance/buffered_overlay_unfold
	/// Default gun weight class buffer variable
	var/gun_w_class

/obj/item/gun_module/stock/Destroy()
	QDEL_NULL(buffered_overlay_unfold)
	return ..()

/obj/item/gun_module/stock/on_attach(obj/item/gun/target_gun, mob/user)
	RegisterSignal(target_gun, COMSIG_ITEM_ATTACK_SELF_SECONDARY, PROC_REF(toggle_stock))

/obj/item/gun_module/stock/on_detach(obj/item/gun/target_gun, mob/user)
	UnregisterSignal(target_gun, COMSIG_ITEM_ATTACK_SELF_SECONDARY)
	fold_stock(user)

/obj/item/gun_module/stock/proc/toggle_stock(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!gun)
		return

	if(unfolded)
		fold_stock(user)
	else
		unfold_stock(user)
	gun.add_attachment_overlay(src)

/obj/item/gun_module/stock/proc/unfold_stock(mob/user)
	if(unfolded)
		return
	unfolded = TRUE
	gun_w_class = gun.w_class
	gun.w_class = WEIGHT_CLASS_BULKY
	gun.accuracy.min_spread -= initial(gun.accuracy.min_spread) * spread_compensation_mod
	gun.accuracy.max_spread -= initial(gun.accuracy.max_spread) * spread_compensation_mod
	gun.recoil.strength -= initial(gun.recoil.strength) * recoil_compensation_mod
	playsound(gun.loc, 'sound/weapons/gun_interactions/stock_unfold.ogg', 100, TRUE)

/obj/item/gun_module/stock/proc/fold_stock(mob/user)
	if(!unfolded)
		return
	unfolded = FALSE
	gun.w_class = gun_w_class
	gun.accuracy.min_spread += initial(gun.accuracy.min_spread) * spread_compensation_mod
	gun.accuracy.max_spread += initial(gun.accuracy.max_spread) * spread_compensation_mod
	gun.recoil.strength += initial(gun.recoil.strength) * recoil_compensation_mod
	playsound(gun.loc, 'sound/weapons/gun_interactions/stock_fold.ogg', 100, TRUE)

/obj/item/gun_module/stock/create_overlay()
	if(!unfolded)
		return ..()
	if(!buffered_overlay_unfold)
		buffered_overlay_unfold = mutable_appearance(icon, overlay_state + "_on", layer = FLOAT_LAYER - 1)
	return buffered_overlay_unfold
