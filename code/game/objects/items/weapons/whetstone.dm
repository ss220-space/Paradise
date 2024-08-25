/obj/item/whetstone
	name = "whetstone"
	desc = "A block of stone used to sharpen things."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "whetstone"
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/screwdriver.ogg'
	/// Amount of uses the whetstone has. Set to -1 for functionally infinite uses.
	var/uses = 1
	/// How much force the whetstone can add to an item.
	var/increment = 4
	/// How much force the whetstone can add to humanoid claws.
	var/claws_increment = 2
	/// Maximum force sharpening items with the whetstone can result in.
	var/max = 30
	/// The prefix a whetstone applies when an item is sharpened with it.
	var/prefix = "sharpened"
	/// If TRUE, the whetstone will only sharpen already sharp items.
	var/requires_sharpness = TRUE


/obj/item/whetstone/attackby(obj/item/I, mob/user, params)
	. = ATTACK_CHAIN_BLOCKED_ALL
	if(!uses)
		to_chat(user, span_warning("The sharpening block is too worn to use again!"))
		return .
	if(I.item_flags & NOSHARPENING)
		to_chat(user, span_warning("You don't think [I] will be the thing getting modified if you use it on [src]!"))
		return .
	if(I.force >= max || I.throwforce >= max) //So the whetstone never reduces force or throw_force
		to_chat(user, span_warning("[I] is much too powerful to sharpen further!"))
		return .
	if(requires_sharpness && !I.sharp)
		to_chat(user, span_warning("You can only sharpen items that are already sharp, such as knives!"))
		return .

	//This block is used to check more things if the item has a relevant component.
	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max) //Stores the bitflags returned by SEND_SIGNAL
	if(signal_out & COMPONENT_BLOCK_SHARPEN_MAXED) //If the item's components enforce more limits on maximum power from sharpening,  we fail
		to_chat(user, span_warning("[I] is much too powerful to sharpen further!"))
		return .
	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, span_warning("[I] is not able to be sharpened!"))
		return .
	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (!signal_out && I.force > initial(I.force))) //No sharpening stuff twice
		to_chat(user, span_warning("[I] has already been refined before. It cannot be sharpened further!"))
		return .
	//If component returns nothing and sharpen_act() returns FALSE we are out
	if(!(signal_out & COMPONENT_BLOCK_SHARPEN_APPLIED) && !I.sharpen_act(src, user))
		return .

	user.visible_message(
		span_notice("[user] sharpens [I] with [src]!"),
		span_notice("You sharpen [I], making it much more deadly than before."),
	)
	playsound(src, usesound, 50, TRUE)
	uses--
	update_appearance()


/obj/item/whetstone/update_name(updates = ALL)
	. = ..()
	name = "[!uses ? "worn out " : ""][initial(name)]"


/obj/item/whetstone/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)][!uses ? " At least, it used to." : ""]"


/obj/item/whetstone/attack_self(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user) || !istype(user.dna.species.unarmed, /datum/unarmed_attack/claws))
		return .
	if(!uses)
		to_chat(user, span_warning("The sharpening block is too worn to use again!"))
		return .
	var/datum/unarmed_attack/claws/claws = user.dna.species.unarmed
	if(claws.damage > initial(claws.damage))
		to_chat(user, span_warning("You cannot sharpen your claws any further!"))
		return .

	claws.damage = clamp(claws.damage + claws_increment, 0, max)
	user.visible_message(
		span_notice("[user] sharpens [user.p_their()] claws on [src]!"),
		span_notice("You sharpen your claws on [src]."),
	)
	playsound(src, usesound, 50, TRUE)
	uses--
	update_appearance()


/obj/item/whetstone/super
	name = "super whetstone block"
	desc = "A block of stone that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = FALSE
	claws_increment = 200

