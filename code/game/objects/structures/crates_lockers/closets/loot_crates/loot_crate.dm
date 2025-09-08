/obj/structure/closet/loot_crate
	icon = 'icons/obj/supplypods.dmi'
	locked = TRUE
	pixel_x = -16
	var/datum/loot_tier/tier

/obj/structure/closet/loot_crate/Initialize(mapload)
	. = ..()
	if(!GLOB.loot_tiers[tier])
		GLOB.loot_tiers[tier] = new tier()
	tier = GLOB.loot_tiers[tier]

/obj/structure/closet/loot_crate/obj_destruction(damage_flag)
	if(locked)
		explosion(get_turf(src), devastation_range = 0, heavy_impact_range = 0, light_impact_range = 3, flame_range = 4)
		qdel(src)
		return
	. = ..()

/obj/structure/closet/loot_crate/Destroy(force)
	tier = null
	. = ..()

/obj/structure/closet/loot_crate/update_overlays()
	. = list()
	if(!opened)
		. += mutable_appearance(icon, "[icon_state]_door")
	. += mutable_appearance(icon, "box_[locked? "locked" : "unlocked"]")
	return .

/obj/structure/closet/loot_crate/attack_hand(mob/user)
	if(!locked)
		return ..()

	to_chat(user, span_notice("Вы начинаете взламывать кодовый замок"))

	if(!do_after(user, tier.open_time, src))
		return

	balloon_alert(user, "взлом окончен")
	tier.on_start_open(user, src)
	locked = FALSE
	update_icon()

/obj/structure/closet/loot_crate/crowbar_act(mob/living/user, obj/item/I)
	if(locked || opened)
		return ..()

	if(!do_after(user, 5 SECONDS, src))
		return

	open()
	return TRUE

/obj/structure/closet/loot_crate/toggle(mob/user)
	return


/obj/structure/closet/loot_crate/green
	icon_state = "box_green"
	tier = /datum/loot_tier/first

/obj/structure/closet/loot_crate/blue
	icon_state = "box_blue"
	tier = /datum/loot_tier/second

/obj/structure/closet/loot_crate/red
	icon_state = "box_orange"
	tier = /datum/loot_tier/third

/obj/structure/closet/loot_crate/gamma
	icon_state = "box_yellow"
	max_integrity = 500
	tier = /datum/loot_tier/fourth

/obj/structure/closet/loot_crate/epsilon
	icon_state = "box_purple"
	max_integrity = 1000
	tier = /datum/loot_tier/fifth

/obj/structure/closet/loot_crate/med
	icon_state = "box_med"
	tier = /datum/loot_tier/medical

/obj/structure/closet/loot_crate/ammo
	icon_state = "box_cian"
	tier = /datum/loot_tier/ammo
