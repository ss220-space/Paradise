//////Syndicate Version

/obj/item/clothing/suit/space/hardsuit/syndi/shielded
	desc = "An advanced hardsuit with built in energy shielding and jetpack."
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/shielded
	jetpack = /obj/item/tank/jetpack/suit
	resistance_flags = ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 20, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)

/obj/item/clothing/suit/space/hardsuit/syndi/shielded/setup_shielding()
	AddComponent(/datum/component/shielded, shield_icon = "shield-red")

/obj/item/clothing/head/helmet/space/hardsuit/syndi/shielded
	desc = "An advanced hardsuit helmet with built in energy shielding."
	resistance_flags = ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 20, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)

//////Wizard Versions
/obj/item/clothing/suit/space/hardsuit/wizard/shielded/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 15, recharge_start_delay = 0 SECONDS)

/obj/item/clothing/suit/space/hardsuit/wizard/arch/shielded/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 15, recharge_start_delay = 1 SECONDS, charge_increment_delay = 1 SECONDS)

/obj/item/wizard_armour_charge
	name = "battlemage shield charges"
	desc = "A powerful rune that will increase the number of hits a suit of battlemage armour can take before failing.."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"

/obj/item/wizard_armour_charge/afterattack(obj/item/clothing/suit/space/hardsuit/wizard/W, mob/user, proximity, params)
	. = ..()
	if(!istype(W))
		to_chat(user, "<span class='warning'>The rune can only be used on battlemage armour!</span>")
		return
	var/datum/component/shielded/shielded = W.GetComponent(/datum/component/shielded)
	if(!istype(shielded))
		to_chat(user, "<span class='warning'>No shield detected on this armour!</span>")
		return
	if(W == user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER))
		to_chat(user, "<span class='warning'>You cannot replenish charges to [W] while wearing it.</span>")
		return
	shielded.current_charges += 8
	playsound(loc, 'sound/magic/charge.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>You charge [W]. It can now absorb [shielded.current_charges] hits.</span>")
	qdel(src)
