/obj/item/hardsuit_shield
	name = "Hardsuit Shield Upgrade module"
	desc = "This upgrade grants shields to any hardsuit."
	icon = 'icons/obj/hardsuits_modules.dmi'
	icon_state = "powersink"
	var/obj/item/clothing/suit/space/hardsuit/hardsuit = null
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 20 SECONDS //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 SECONDS //How quickly the shield recharges once it starts charging
	var/shield_on_icon = "shield-old"
	var/allowed_to_change_color = FALSE

/obj/item/hardsuit_shield/syndi
	allowed_to_change_color = TRUE
	shield_on_icon = "shield-red"

/obj/item/hardsuit_shield/wizard
	current_charges = 15
	max_charges = 15
	recharge_cooldown = INFINITY
	recharge_rate = 0
	shield_on_icon = "shield-red"

/obj/item/hardsuit_shield/wizard/arch
	recharge_cooldown = 0
	recharge_rate = 1 SECONDS

/obj/item/hardsuit_shield/proc/attach_to_suit(obj/item/clothing/suit/space/hardsuit/hardsuit)
	hardsuit.AddComponent(/datum/component/shielded, max_charges = src.max_charges, shield_icon = shield_on_icon, recharge_start_delay = recharge_delay, charge_increment_delay = recharge_rate, starting_charges = src.current_charges)
	qdel(src)

/obj/item/hardsuit_shield/multitool_act(mob/user, obj/item/I)
	if(!allowed_to_change_color)
		return FALSE
	if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume))
		return FALSE

	if(shield_on_icon == "shield-red")
		shield_on_icon = "shield-old"
		to_chat(user, "<span class='warning'>You roll back the hardsuit's software, changing the shield's color!</span>")
	else
		shield_on_icon = "shield-red"
		to_chat(user, "<span class='warning'>You update the hardsuit's hardware, changing the shield's color to red.</span>")
	return TRUE

/obj/item/storage/box/ert_hardsuit_shield_upgrade
	name = "Hardsuit Shield Upgrade Box"
	desc = "A Exclusive and Expensive upgrade for Hardsuits."
	icon_state = "box_ert"

/obj/item/storage/box/ert_hardsuit_shield_upgrade/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/hardsuit_shield(src)
