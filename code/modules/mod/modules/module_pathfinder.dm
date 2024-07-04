///Pathfinder - Can fly the suit from a long distance to an implant installed in someone.
/obj/item/mod/module/pathfinder
	name = "MOD pathfinder module"
	desc = "This module, brought to you by Paizo Productions, has two components. \
		The first component is a series of thrusters and a computerized location subroutine installed into the \
		very control unit of the suit, allowing it flight at highway speeds using the suit's access locks \
		to navigate through the station, and to be able to locate the second part of the system; \
		a pathfinding implant installed into the base of the user's spine, \
		broadcasting their location to the suit and allowing them to recall it to their person at any time. \
		The implant is stored in the module and needs to be injected in a human to function. \
		Paizo Productions swears up and down there's airbrakes."
	icon_state = "pathfinder"
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 200
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	/// The pathfinding implant.
	var/obj/item/implant/mod/implant

/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)

/obj/item/mod/module/pathfinder/Destroy()
	implant = null
	return ..()

/obj/item/mod/module/pathfinder/examine(mob/user)
	. = ..()
	if(implant)
		. += span_notice("Use it on a human to implant them.")
	else
		. += span_warning("The implant is missing.")

/obj/item/mod/module/pathfinder/attack(mob/living/target, mob/living/user, params)
	if(!ishuman(target) || !implant)
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		return
	if(!implant.implant(target, user))
		to_chat(user, span_warning("Unable to implant [target]!"))
		return
	if(target == user)
		to_chat(user, span_notice("You implant yourself with [implant]."))
	else
		target.visible_message(span_notice("[user] implants [target]."), span_notice("[user] implants you with [implant]."))
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	icon_state = "pathfinder_empty"
	implant = null

/obj/item/mod/module/pathfinder/proc/attach(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.get_item_by_slot(ITEM_SLOT_BACK) && !human_user.drop_item_ground(human_user.get_item_by_slot(ITEM_SLOT_BACK)))
		return
	if(!human_user.equip_to_slot_if_possible(mod, ITEM_SLOT_BACK, disable_warning = TRUE))
		return
	mod.quick_deploy(user)
	human_user.update_action_buttons(TRUE)
	playsound(mod, 'sound/machines/ping.ogg', 50, TRUE)
	drain_power(use_power_cost)
