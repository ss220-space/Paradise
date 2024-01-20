/obj/item/whetstone
	name = "whetstone"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "whetstone"
	desc = "A block of stone used to sharpen things."
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/screwdriver.ogg'
	var/used = 0
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"
	var/requires_sharpness = 1
	var/claw_damage_increase = 2


/obj/item/whetstone/attackby(obj/item/I, mob/user, params)
	if(used)
		to_chat(user, span_warning("The whetstone is too worn to use again!"))
		return

	if(requires_sharpness && !I.sharp)
		to_chat(user, span_warning("You can only sharpen items that are already sharp, such as knives!"))
		return

	I.AddComponent(/datum/component/sharpening)

	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max) //Stores the bitflags returned by SEND_SIGNAL
	if((signal_out & COMPONENT_BLOCK_SHARPEN_MAXED)) //If the item's components enforce more limits on maximum power from sharpening,  we fail
		to_chat(user, span_warning("[I] is much too powerful to sharpen further!"))
		return

	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY)) //No sharpening stuff twice
		to_chat(user, span_warning("[I] has already been refined before. It cannot be sharpened further!"))
		return

	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, span_warning("[I] is not able to be sharpened right now!"))
		return

	if(!requires_sharpness)
		I.sharp = TRUE

	user.visible_message(span_warning("[user] sharpens [I] with [src]!"), \
		span_warning("You sharpen [I], making it much more deadly than before."))
	I.name = "[prefix] [I.name]"
	playsound(get_turf(src), usesound, 50, 1)
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used = TRUE
	update_icon()


/obj/item/whetstone/attack_self(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>The whetstone is too worn to use again!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/unarmed_attack/attack = H.dna.species.unarmed
		if(istype(attack, /datum/unarmed_attack/claws))
			var/datum/unarmed_attack/claws/C = attack
			if(!C.has_been_sharpened)
				C.has_been_sharpened = TRUE
				attack.damage += claw_damage_increase
				H.visible_message("<span class='notice'>[H] sharpens [H.p_their()] claws on [src]!</span>", "<span class='notice'>You sharpen your claws on [src].</span>")
				playsound(get_turf(H), usesound, 50, 1)
				name = "worn out [name]"
				desc = "[desc] At least, it used to."
				used = TRUE
				update_icon()
			else
				to_chat(user, "<span class='warning'>You can not sharpen your claws any further!</span>")

/obj/item/whetstone/super
	name = "super whetstone block"
	desc = "A block of stone that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = 0
	claw_damage_increase = 200
