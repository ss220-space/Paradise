//contractor hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/contractor
	name = "Contractor hardsuit helmet"
	desc = "A top-tier syndicate helmet, a favorite of Syndicate field Contractors. Property of the Gorlex Marauders, with assistance from Cybersun Industries."
	icon_state = "hardsuit0-contractor"
	item_state = "contractor_helm"
	item_color = "contractor"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/suit/space/hardsuit/contractor
	name = "Contractor hardsuit"
	desc = "A top-tier syndicate hardsuit, a favorite of Syndicate field Contractors. Property of the Gorlex Marauders, with assistance from Cybersun Industries."
	icon_state = "hardsuit-contractor"
	item_state = "contractor_hardsuit"
	item_color = "contractor"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	slowdown = 0
	w_class = WEIGHT_CLASS_NORMAL
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/contractor
	jetpack = /obj/item/tank/jetpack/suit
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/advanced/hook_upgrade)
	//working as ninja hook, deleted when droped
	var/obj/item/gun/magic/contractor_hook/scorpion

/obj/item/clothing/suit/space/hardsuit/contractor/Destroy()
	. = ..()
	QDEL_NULL(scorpion)

/obj/item/clothing/suit/space/hardsuit/contractor/ui_action_click(user, action)
	switch(action)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
			return TRUE
		if(/datum/action/item_action/advanced/hook_upgrade)
			toggle_hook()
			return TRUE
	return FALSE

/datum/action/item_action/advanced/hook_upgrade
	name = "Hardsuit SCORPION hook module"
	desc = "A module installed in the wrist of your hardsuit, this highly illegal module uses a hardlight hook to forcefully pull a target towards you at high speed, knocking them down and partially exhausting them."
	charge_type = ADV_ACTION_TYPE_TOGGLE_RECHARGE
	charge_max = 6 SECONDS
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "hook"
	button_icon = 'icons/mob/actions/actions.dmi'

/obj/item/clothing/suit/space/hardsuit/contractor/proc/toggle_hook()
	if(scorpion)
		qdel(scorpion)
		scorpion = null
	else
		scorpion = new
		scorpion.suit = src
		for(var/datum/action/item_action/advanced/hook_upgrade/hook in actions)
			scorpion.hook_action = hook
			hook.action_ready = TRUE
			hook.toggle_button_on_off()
			break
		usr.put_in_hands(scorpion)
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
		to_chat(usr, "<span class='notice'>You engage the [scorpion].</span>")

/datum/action/item_action/advanced/hook_upgrade/toggle_button_on_off()
	if(action_ready)
		background_icon_state = icon_state_active
	else
		background_icon_state = icon_state_disabled
	UpdateButtonIcon()

/obj/item/gun/magic/contractor_hook
	name = "SCORPION hook"
	desc = "A hardlight hook used to non-lethally pull targets much closer to the user."
	ammo_type = /obj/item/ammo_casing/magic/contractor_hook
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "hook_weapon"
	item_state = "gun"
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	recharge_rate = 0
	charge_tick = 1
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = 0
	flags = DROPDEL | ABSTRACT | NOBLUDGEON | NOPICKUP
	force = 0
	var/obj/item/clothing/suit/space/hardsuit/contractor/suit = null
	var/datum/action/item_action/advanced/hook_upgrade/hook_action  = null

/obj/item/gun/magic/contractor_hook/Destroy()
	. = ..()
	suit.scorpion = null
	suit = null
	hook_action.action_ready = FALSE
	hook_action.toggle_button_on_off()
	hook_action = null

/obj/item/gun/magic/contractor_hook/can_trigger_gun(mob/living/user)
	if(!hook_action.IsAvailable(show_message = TRUE, ignore_ready = TRUE))
		return FALSE
	else
		hook_action.use_action()
		return TRUE

/obj/item/gun/magic/contractor_hook/equip_to_best_slot(mob/M)
	qdel(src)

/obj/item/ammo_casing/magic/contractor_hook
	name = "Hardlight hook"
	desc = "a hardlight hook."
	projectile_type = /obj/item/projectile/contractor_hook
	caliber = "hardlight_hook"
	icon_state = "hard_hook"
	muzzle_flash_effect = null

/obj/item/projectile/contractor_hook
	name = "Hardlight hook"
	icon_state = "hard_hook"
	icon = 'icons/obj/weapons/projectiles.dmi'
	pass_flags = PASSTABLE
	damage = 0
	stamina = 25
	hitsound = 'sound/weapons/whip.ogg'
	weaken = 1
	range = 7
	var/chain

/obj/item/projectile/contractor_hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "hard_chain", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
	..()

/obj/item/projectile/contractor_hook/on_hit(atom/target, blocked = 0)
	. = ..()
	if(blocked >= 100)
		return 0
	if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && L.loc)
			L.visible_message("<span class='danger'>[L] is snagged by [firer]'s hook!</span>")

			var/old_density = L.density
			L.density = FALSE // Ensures the hook does not hit the target multiple times
			L.forceMove(get_turf(firer))
			L.density = old_density
			firer.drop_item(src)



/obj/item/projectile/contractor_hook/Destroy()
	QDEL_NULL(chain)
	return ..()
