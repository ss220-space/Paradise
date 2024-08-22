/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "muzzle"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90
	put_on_delay = 20
	var/resist_time = 0 //deciseconds of how long you need to gnaw to get rid of the gag, 0 to make it impossible to remove
	var/mute = MUZZLE_MUTE_ALL
	var/radio_mute = FALSE
	var/security_lock = FALSE // Requires brig access to remove 0 - Remove as normal
	var/locked = FALSE //Indicates if a mask is locked, should always start as 0.

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
	)

// Clumsy folks can't take the mask off themselves.
/obj/item/clothing/mask/muzzle/attack_hand(mob/user)
	if(user.wear_mask == src && !user.IsAdvancedToolUser())
		return 0
	else if(security_lock && locked)
		if(do_unlock(user))
			visible_message("<span class='danger'>[user] unlocks [user.p_their()] [src.name].</span>", \
								"<span class='userdanger'>[user] unlocks [user.p_their()] [src.name].</span>")
	..()
	return 1

/obj/item/clothing/mask/muzzle/proc/do_break()
	if(security_lock)
		security_lock = FALSE
		locked = FALSE
		REMOVE_TRAIT(src, TRAIT_NODROP, MUZZLE_TRAIT)
		desc += " This one appears to be broken."
		return TRUE
	else
		return FALSE

/obj/item/clothing/mask/muzzle/proc/do_unlock(mob/living/carbon/human/user)
	if(istype(user.get_inactive_hand(), /obj/item/card/emag))
		to_chat(user, "<span class='warning'>The lock vibrates as the card forces its locking system open.</span>")
		do_break()
		return TRUE
	else if(ACCESS_BRIG in user.get_access())
		to_chat(user, "<span class='warning'>The muzzle unlocks with a click.</span>")
		locked = FALSE
		REMOVE_TRAIT(src, TRAIT_NODROP, MUZZLE_TRAIT)
		return TRUE

	to_chat(user, "<span class='warning'>You must be wearing a security ID card or have one in your inactive hand to remove the muzzle.</span>")
	return FALSE

/obj/item/clothing/mask/muzzle/proc/do_lock(mob/living/carbon/human/user)
	if(security_lock)
		locked = TRUE
		ADD_TRAIT(src, TRAIT_NODROP, MUZZLE_TRAIT)
		return TRUE
	return FALSE

/obj/item/clothing/mask/muzzle/tapegag
	name = "tape gag"
	desc = "MHPMHHH!"
	icon_state = "tapegag"
	item_state = null
	w_class = WEIGHT_CLASS_TINY
	resist_time = 150
	mute = MUZZLE_MUTE_MUFFLE
	item_flags = DROPDEL
	var/trashtype = /obj/item/trash/tapetrash

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
		)


/obj/item/clothing/mask/muzzle/tapegag/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(slot != ITEM_SLOT_MASK)
		return .
	var/obj/item/trash/tapetrash/trash_gag = new trashtype(get_turf(src))
	transfer_fingerprints_to(trash_gag)
	user.transfer_fingerprints_to(trash_gag)
	user.put_in_active_hand(trash_gag, ignore_anim = FALSE)
	playsound(user, 'sound/items/poster_ripped.ogg', 40, TRUE)
	if(user.has_pain())
		// we have to use timer, since an item is still on user, while this proc is called
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, emote), "scream"), 0)


/obj/item/clothing/mask/muzzle/tapegag/thick
	name = "thick tape gag"
	desc = "MHPMHHH!"
	icon_state = "thicktapegag"
	resist_time = 15 SECONDS
	mute = MUZZLE_MUTE_MUFFLE
	radio_mute = TRUE
	trashtype = /obj/item/trash/tapetrash/thick

/obj/item/clothing/mask/muzzle/safety
	name = "safety muzzle"
	desc = "A muzzle designed to prevent biting."
	icon_state = "muzzle_secure"
	item_state = "muzzle_secure"
	resist_time = 0
	mute = MUZZLE_MUTE_NONE
	security_lock = TRUE
	locked = FALSE
	materials = list(MAT_METAL=500, MAT_GLASS=50)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
		)

/obj/item/clothing/mask/muzzle/safety/shock
	name = "shock muzzle"
	desc = "A muzzle designed to prevent biting.  This one is fitted with a behavior correction system."
	var/obj/item/assembly/trigger = null
	origin_tech = "materials=1;engineering=1"
	materials = list(MAT_METAL=500, MAT_GLASS=50)


/obj/item/clothing/mask/muzzle/safety/shock/attackby(obj/item/I, mob/user, params)
	if(issignaler(I) || istype(I, /obj/item/assembly/voice))
		add_fingerprint(user)
		if(trigger)
			to_chat(user, span_warning("The [name] already has [trigger] attached."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		trigger = I
		trigger.master = src
		trigger.holder = src
		AddComponent(/datum/component/proximity_monitor)
		to_chat(user, span_notice("You have attached [I] to [src]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(isassembly(I))
		add_fingerprint(user)
		to_chat(user, span_notice("The [I.name] will not fit in [src]. Perhaps a signaler or voice analyzer would?"))
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/clothing/mask/muzzle/safety/shock/screwdriver_act(mob/user, obj/item/I)
	if(!trigger)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You remove [trigger] from [src].</span>")
	trigger.forceMove(get_turf(user))
	trigger.master = null
	trigger.holder = null
	trigger = null
	qdel(GetComponent(/datum/component/proximity_monitor))

/obj/item/clothing/mask/muzzle/safety/shock/proc/can_shock(obj/item/clothing/C)
	if(istype(C))
		if(isliving(C.loc))
			return C.loc
	else if(isliving(loc))
		return loc
	return FALSE

/obj/item/clothing/mask/muzzle/safety/shock/proc/process_activation(obj/D, normal = 1, special = 1)
	visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	var/mob/living/L = can_shock(loc)
	if(!L)
		return
	to_chat(L, "<span class='danger'>You feel a sharp shock!</span>")
	do_sparks(3, 1, L)

	L.Weaken(10 SECONDS)
	L.Stuttering(2 SECONDS)
	L.Jitter(40 SECONDS)

/obj/item/clothing/mask/muzzle/safety/shock/HasProximity(atom/movable/AM)
	if(trigger)
		trigger.HasProximity(AM)


/obj/item/clothing/mask/muzzle/safety/shock/hear_talk(mob/living/M, list/message_pieces)
	if(trigger)
		trigger.hear_talk(M, message_pieces)

/obj/item/clothing/mask/muzzle/safety/shock/hear_message(mob/living/M, msg)
	if(trigger)
		trigger.hear_message(M, msg)



/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	can_toggle = TRUE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 25, "rad" = 0, "fire" = 0, "acid" = 0)
	actions_types = list(/datum/action/item_action/adjust)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
		)


/obj/item/clothing/mask/surgical/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/fakemoustache
	name = "completely real moustache"
	desc = "moustache is totally real."
	icon_state = "fake-moustache"
	flags_inv = HIDENAME
	actions_types = list(/datum/action/item_action/pontificate)
	dog_fashion = /datum/dog_fashion/head/not_ian

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
		)

/obj/item/clothing/mask/fakemoustache/attack_self(mob/user)
	pontificate(user)

/obj/item/clothing/mask/fakemoustache/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_MASK)
		return TRUE

/obj/item/clothing/mask/fakemoustache/proc/pontificate(mob/user)
	user.visible_message("<span class='danger'>\ [user] twirls [user.p_their()] moustache and laughs [pick("fiendishly","maniacally","diabolically","evilly")]!</span>")

//scarves (fit in in mask slot)

/obj/item/clothing/mask/bluescarf
	name = "blue neck scarf"
	desc = "A blue neck scarf."
	icon_state = "blueneckscarf"
	item_state = "blueneckscarf"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90


/obj/item/clothing/mask/redscarf
	name = "red scarf"
	desc = "A red and white checkered neck scarf."
	icon_state = "redwhite_scarf"
	item_state = "redwhite_scarf"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/greenscarf
	name = "green scarf"
	desc = "A green neck scarf."
	icon_state = "green_scarf"
	item_state = "green_scarf"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDENAME|HIDEHAIR
	flags_cover = MASKCOVERSMOUTH|MASKCOVERSEYES
	w_class = WEIGHT_CLASS_SMALL


/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags_inv = HIDENAME|HIDEHAIR
	w_class = WEIGHT_CLASS_SMALL
	var/voicechange = FALSE
	var/temporaryname = " the Horse"
	var/originalname = ""

	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
	)

/obj/item/clothing/mask/horsehead/equipped(mob/user, slot, initial)
	. = ..()

	if(HAS_TRAIT_FROM(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type)))	//cursed masks only
		originalname = user.real_name
		if(!user.real_name || user.real_name == "Unknown")
			user.real_name = "A Horse With No Name" //it felt good to be out of the rain
		else
			user.real_name = "[user.name][temporaryname]"

/obj/item/clothing/mask/horsehead/dropped(mob/user, slot, silent = FALSE) //this really shouldn't happen, but call it extreme caution
	if(slot == ITEM_SLOT_MASK && HAS_TRAIT_FROM(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type)))
		goodbye_horses(loc)
	. = ..()

/obj/item/clothing/mask/horsehead/Destroy()
	if(HAS_TRAIT_FROM(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type)))
		goodbye_horses(loc)
	return ..()

/obj/item/clothing/mask/horsehead/proc/goodbye_horses(mob/user) //I'm flying over you
	if(!ismob(user))
		return
	if(user.real_name == "[originalname][temporaryname]" || user.real_name == "A Horse With No Name") //if it's somehow changed while the mask is on it doesn't revert
		user.real_name = originalname

/obj/item/clothing/mask/horsehead/change_speech_verb()
	if(voicechange)
		return pick("whinnies", "neighs", "says")

/obj/item/clothing/mask/face
	flags_inv = HIDENAME
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/face/rat
	name = "rat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a rat."
	icon_state = "rat"
	item_state = "rat"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/face/fox
	name = "fox mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a fox."
	icon_state = "fox"
	item_state = "fox"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/face/bee
	name = "bee mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bee."
	icon_state = "bee"
	item_state = "bee"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/face/bear
	name = "bear mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bear."
	icon_state = "bear"
	item_state = "bear"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/face/bat
	name = "bat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bat."
	icon_state = "bat"
	item_state = "bat"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/face/raven
	name = "raven mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a raven."
	icon_state = "raven"
	item_state = "raven"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/face/jackal
	name = "jackal mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a jackal."
	icon_state = "jackal"
	item_state = "jackal"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/face/tribal
	name = "tribal mask"
	desc = "A mask carved out of wood, detailed carefully by hand."
	icon_state = "bumba"
	item_state = "bumba"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/face/fawkes
	name = "Guy Fawkes mask"
	desc = "A mask designed to help you remember a specific date."
	icon_state = "fawkes"
	item_state = "fawkes"
	w_class = WEIGHT_CLASS_SMALL
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/gas/clown_hat/pennywise
	name = "Pennywise Mask"
	desc = "It's the eater of worlds, and of children."
	icon_state = "pennywise_mask"
	item_state = "pennywise_mask"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)


/obj/item/clothing/mask/gas/clown_hat/rockso
	name = "Rockso Mask"
	desc = "THE ROCK AND ROLL CLOWN!"
	icon_state = "rocksomask"
	item_state = "rocksomask"
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_KIDAN = 'icons/mob/clothing/species/kidan/mask.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/mask.dmi'
	)


// Bandanas
/obj/item/clothing/mask/bandana
	name = "bandana"
	desc = "A colorful bandana."
	icon_state = "bandbotany"
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDENAME|HIDEFACIALHAIR
	adjusted_slot_flags = ITEM_SLOT_HEAD
	adjusted_flags_inv = HIDENAME|HIDEFACIALHAIR|HIDEHEADHAIR
	can_toggle = TRUE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
		)
	actions_types = list(/datum/action/item_action/adjust)
	dying_key = DYE_REGISTRY_BANDANA


/obj/item/clothing/mask/bandana/attack_self(mob/user)
	adjustmask(user)


/obj/item/clothing/mask/bandana/adjustmask(mob/living/user)
	. = ..()
	if(.)
		undyeable = up ? TRUE : initial(undyeable)


/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	icon_state = "bandred"
	item_color = "red"
	desc = "It's a red bandana."

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	icon_state = "bandblue"
	item_color = "blue"
	desc = "It's a blue bandana."

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	icon_state = "bandgold"
	item_color = "yellow"
	desc = "It's a gold bandana."

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	icon_state = "bandgreen"
	item_color = "green"
	desc = "It's a green bandana."

/obj/item/clothing/mask/bandana/orange
	name = "orange bandana"
	icon_state = "bandorange"
	item_color = "orange"
	desc = "It's an orange bandana."

/obj/item/clothing/mask/bandana/purple
	name = "purple bandana"
	icon_state = "bandpurple"
	item_color = "purple"
	desc = "It's a purple bandana."

/obj/item/clothing/mask/bandana/botany
	name = "botany bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "bandbotany"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "It's a black bandana with a skull pattern."
	icon_state = "bandskull"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	icon_state = "bandblack"
	item_color = "black"
	desc = "It's a black bandana."

/obj/item/clothing/mask/bandana/durathread
	name = "durathread bandana"
	desc =  "A bandana made from durathread, you wish it would provide some protection to its wearer, but it's far too thin..."
	icon_state = "banddurathread"

/obj/item/clothing/mask/cursedclown
	name = "cursed clown mask"
	desc = "This is a very, very odd looking mask."
	icon = 'icons/goonstation/objects/clothing/mask.dmi'
	icon_state = "cursedclown"
	item_state = "cclown_hat"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	onmob_sheets = list(
		ITEM_SLOT_MASK_STRING = 'icons/goonstation/mob/clothing/mask.dmi'
	)
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	clothing_flags = AIRTIGHT
	flags_cover = MASKCOVERSMOUTH


/obj/item/clothing/mask/cursedclown/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/mask/cursedclown/equipped(mob/user, slot, initial)
	. = ..()

	var/mob/living/carbon/human/H = user
	if(istype(H) && slot == ITEM_SLOT_MASK)
		to_chat(H, "<span class='danger'>[src] grips your face!</span>")
		if(H.mind && H.mind.assigned_role != "Cluwne")
			H.makeCluwne()

/obj/item/clothing/mask/cursedclown/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] gazes into the eyes of [src]. [src] gazes back!</span>")
	spawn(10)
		if(user)
			user.gib()
	return OBLITERATION

//voice modulator

/obj/item/clothing/mask/gas/voice_modulator
	name = "modified gas mask"
	desc = "The usual gas mask for firefighters with attached voice change sensor."
	icon_state = "voice_modulator"
	item_state = "voice_modulator"

	var/obj/item/voice_changer/voice_modulator/voice_modulator

/obj/item/clothing/mask/gas/voice_modulator/Initialize(mapload)
	. = ..()
	voice_modulator = new(src)

/obj/item/clothing/mask/gas/voice_modulator/Destroy()
	QDEL_NULL(voice_modulator)
	return ..()

/obj/item/clothing/mask/gas/voice_modulator/change_speech_verb()
	if(voice_modulator.active)
		return pick("modulates", "drones", "hums", "buzzes")

//sec scarf

/obj/item/clothing/mask/secscarf
	name = "security scarf"
	desc = "Bleck security snood. Excellent replacement for a balaclava."
	icon_state = "secscarf"
	item_state = "secscarf"
	icon = 'icons/obj/clothing/masks.dmi'
	flags_inv = HIDENAME|HIDEFACIALHAIR
	flags_cover = MASKCOVERSMOUTH
	can_toggle = TRUE
	strip_delay = 20
	put_on_delay = 20
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.90
	actions_types = list(/datum/action/item_action/adjust)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
	)

/obj/item/clothing/mask/secscarf/attack_self(mob/user)
	adjustmask(user)
