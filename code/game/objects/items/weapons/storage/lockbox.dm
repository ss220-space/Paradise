/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(ACCESS_ARMORY)
	var/locked = TRUE
	var/broken = FALSE
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


/obj/item/storage/lockbox/update_icon_state()
	if(broken)
		icon_state = icon_broken
		return
	icon_state = locked ? icon_locked : icon_closed


/obj/item/storage/lockbox/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)	// to allow storing special items
		if(locked)
			add_fingerprint(user)
			to_chat(user, span_warning("It's locked!"))
			return ATTACK_CHAIN_PROCEED
		return ..()

	if(I.GetID())
		add_fingerprint(user)
		if(broken)
			to_chat(user, span_warning("It appears to be broken."))
			return ATTACK_CHAIN_PROCEED
		if(!check_access(I))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED

		locked = !locked
		update_icon()
		if(locked)
			to_chat(user, span_warning("You lock [src]!"))
			if(user.s_active == src)
				user.s_active.close(user)
		else
			to_chat(user, span_warning("You unlock [src]!"))
			origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if((istype(I, /obj/item/card/emag) || (istype(I, /obj/item/melee/energy/blade)) && !broken))
		add_fingerprint(user)
		emag_act(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(locked)
		add_fingerprint(user)
		to_chat(user, span_warning("It's locked!"))
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/storage/lockbox/show_to(mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
	else
		..()
	return


/obj/item/storage/lockbox/can_be_inserted(obj/item/W, stop_messages = 0)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, "<span class='notice'>[src] is locked!</span>")
	return FALSE


/obj/item/storage/lockbox/emag_act(mob/user)
	if(!broken)
		add_attack_logs(user, src, "emagged")
		broken = TRUE
		locked = FALSE
		desc = "It appears to be broken."
		update_icon()
		if(user)
			to_chat(user, "<span class='notice'>You unlock \the [src].</span>")
		origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.


/obj/item/storage/lockbox/hear_talk(mob/living/M, list/message_pieces)

/obj/item/storage/lockbox/hear_message(mob/living/M, msg)

/obj/item/storage/lockbox/mindshield
	name = "Lockbox (Mindshield Implants)"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/mindshield/populate_contents()
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/lockbox/mindshield/ert
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/lockbox/sibyl_system_mod
	name = "lockbox (Sibyl System Mods)"
	desc = "Contains proprietary Sibyl System mods for energy guns."
	max_w_class = WEIGHT_CLASS_TINY
	storage_slots = 10
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/sibyl_system_mod/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/sibyl_system_mod(src)

/obj/item/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/clusterbang/populate_contents()
	new /obj/item/grenade/clusterbuster(src)

/obj/item/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	icon_state = "medalbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 20
	storage_slots = 12
	req_access = list(ACCESS_CAPTAIN)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"

/obj/item/storage/lockbox/medal/populate_contents()
	new /obj/item/clothing/accessory/medal/gold/captain(src)
	new /obj/item/clothing/accessory/medal/silver/leadership(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/heart(src)

/obj/item/storage/lockbox/t4
	name = "lockbox (T4)"
	desc = "Contains three T4 breaching charges."
	req_access = list(ACCESS_CENT_SPECOPS)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/lockbox/t4/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/grenade/plastic/x4/thermite(src)

/obj/item/storage/lockbox/research

/obj/item/storage/lockbox/research/deconstruct(disassembled = TRUE) // Get wrecked, Science nerds
	qdel(src)

/obj/item/storage/lockbox/research/large
	name = "Large lockbox"
	desc = "A large lockbox"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 4 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 1

/obj/item/storage/lockbox/research/mantis
	name = "lockbox(hidden blade implant)"
	req_access = list(ACCESS_ARMORY)

/obj/item/storage/lockbox/research/mantis/populate_contents()
	new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/shellguard(src)
	new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/shellguard/l(src)

/obj/item/storage/lockbox/medal/hardmode_box
	name = "\improper HRD-MDE program medal box"
	desc = "A locked box used to store medals of pride. Use a fauna research disk on the box to transmit the data and print a medal."
	req_access = list(ACCESS_MINING) //No grubby assistant hands on my hard earned medals
	can_hold = list(/obj/item/clothing/accessory, /obj/item/coin) //Whoops almost gave miners boxes that could store 12 legion cores. Scoped to accessory if they want to store neclaces or hope or something in there. Or a coin collection.
	var/list/completed_fauna = list()
	var/number_of_megafauna = 7 //Increase this if new megafauna are added.

/obj/item/storage/lockbox/medal/hardmode_box/Initialize(mapload)
	. = ..()
	number_of_megafauna = length(subtypesof(/obj/item/disk/fauna_research))


/obj/item/storage/lockbox/medal/hardmode_box/populate_contents()
	return


/obj/item/storage/lockbox/medal/hardmode_box/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/disk/fauna_research))
		var/obj/item/disk/fauna_research/disky = I
		if(!user.drop_transfer_item_to_loc(disky, src))
			return ..()
		add_fingerprint(user)
		var/atom/drop_loc = drop_location()
		var/obj/item/pride = new disky.output(drop_loc)
		to_chat(user, span_notice("The [name] accepts [disky], and prints out [pride]."))
		qdel(disky)
		if(!is_type_in_list(pride, completed_fauna))
			completed_fauna += pride.type
			if(length(completed_fauna) == number_of_megafauna)
				to_chat(user, span_notice("The [name] prints out a very fancy medal."))
				var/obj/item/clothing/accessory/medal/gold/heroism/hardmode_full/accomplishment = new(drop_loc)
				user.put_in_hands(accomplishment, ignore_anim = FALSE)
		user.put_in_hands(pride, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

