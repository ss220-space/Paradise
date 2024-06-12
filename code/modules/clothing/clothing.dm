/obj/item/clothing
	name = "clothing"
	max_integrity = 200
	integrity_failure = 80
	resistance_flags = FLAMMABLE
	var/list/species_restricted = null //Only these species can wear this kit.
	var/scan_reagents = 0 //Can the wearer see reagents while it's equipped?
	var/gunshot_residue //Used by forensics.
	var/obj/item/slimepotion/clothing/applied_slime_potion = null
	var/list/faction_restricted = null
	var/teleportation = FALSE //used for xenobio potions

	/*
		Sprites used when the clothing item is refit. This is done by setting icon_override.
		For best results, if this is set then sprite_sheets should be null and vice versa, but that is by no means necessary.
		Ideally, sprite_sheets_refit should be used for "hard" clothing items that can't change shape very well to fit the wearer (e.g. helmets, hardsuits),
		while sprite_sheets should be used for "flexible" clothing items that do not need to be refitted (e.g. vox wearing jumpsuits).
	*/
	var/list/sprite_sheets_refit = null
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	/// What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/flash_protect = 0
	/// Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/tint = 0
	/// Tint when its up
	var/tint_up = 0

	/// Whether clothing is currently adjusted.
	var/up = FALSE

	/// Special flags applied to clothing items only
	var/clothing_flags = NONE
	/// Clothing flags that are added/removed when an item is adjusted up/down
	var/visor_clothing_flags = NONE
	/// Same as visor_clothing_flags, but for flags_inv
	var/visor_flags_inv = NONE
	/// What to toggle when toggled with weldingvisortoggle()
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT|VISOR_TINT|VISOR_VISIONFLAGS|VISOR_DARKNESSVIEW|VISOR_INVISVIEW|VISOR_FULL_HUD

	var/can_toggle = FALSE
	var/toggle_on_message
	var/toggle_off_message
	var/active_sound
	var/toggle_sound
	var/toggle_cooldown = 0
	var/cooldown = 0
	var/species_disguise
	var/magical = FALSE
	var/dyeable = FALSE
	var/heal_bodypart = null	//If a bodypart or an organ is specified here, it will slowly regenerate while the clothes are worn. Currently only implemented for eyes, though.
	var/heal_rate = 1
	w_class = WEIGHT_CLASS_SMALL

	/// Trait modification, lazylist of traits to add/take away, on equipment/drop in the correct slot
	var/list/clothing_traits


/obj/item/clothing/update_icon_state()
	if(!can_toggle)
		return FALSE
	// Done as such to not break chameleon gear since you can't rely on initial states
	icon_state = "[replacetext("[icon_state]", "_up", "")][up ? "_up" : ""]"
	return TRUE


/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(user))
		return FALSE

	visor_toggling(user)
	to_chat(user, span_notice("You adjust [src] [up ? "up" : "down"]."))
	update_equipped_item()
	return TRUE


/obj/item/clothing/proc/visor_toggling() //handles all the actual toggling of flags
	if(!can_toggle)
		return FALSE

	. = TRUE
	up = !up
	clothing_flags ^= visor_clothing_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= initial(flags_cover)
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint = up ? tint_up : initial(tint)
	update_icon(UPDATE_ICON_STATE)


// Aurora forensics port.
/obj/item/clothing/clean_blood()
	. = ..()
	gunshot_residue = null


/obj/item/clothing/proc/can_use(mob/user)
	if(isliving(user) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return TRUE
	return FALSE


/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE)
	. = ..()
	if(!.)
		return FALSE

	// For clothing that are faction restricted
	if(faction_restricted && !M.is_general_slot(slot) && faction_check(faction_restricted, M.faction))
		if(!disable_warning)
			to_chat(M, span_warning("[src] не могут использовать такие как Вы."))
		return FALSE


/obj/item/clothing/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	if(!istype(user) || !LAZYLEN(clothing_traits))
		return .

	for(var/trait in clothing_traits)
		REMOVE_CLOTHING_TRAIT(user, src, trait)


/obj/item/clothing/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(!istype(user) || !LAZYLEN(clothing_traits) || !(slot_flags & slot))
		return .

	for(var/trait in clothing_traits)
		ADD_CLOTHING_TRAIT(user, src, trait)


/**
  * Used for any clothing interactions when the user is on fire. (e.g. Cigarettes getting lit.)
  */
/obj/item/clothing/proc/catch_fire() //Called in handle_fire()
	return

//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 2
	slot_flags = ITEM_SLOT_EARS
	resistance_flags = NONE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/ears.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/ears.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/ears.dmi'
		) //We read you loud and skree-er.


/obj/item/proc/make_offear(slot, mob/living/carbon/human/user)
	var/obj/item/clothing/ears/offear/offear = new(user)
	offear.name = name
	offear.desc = desc
	offear.icon = icon
	offear.icon_state = icon_state
	offear.copy_overlays(src)
	offear.original_ear_UID = UID()
	offear.flags |= flags
	if(!user.equip_to_slot(offear, slot, TRUE))
		qdel(offear)
		CRASH("[src] offear was not equipped.")


/obj/item/clothing/ears/offear
	name = "off ear"
	desc = "Say hello to your other ear."
	item_flags = DROPDEL
	sprite_sheets = null
	equip_sound = null
	pickup_sound = null
	drop_sound = null
	/// UID of the original ear ite
	var/original_ear_UID


/obj/item/clothing/ears/offear/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	var/obj/item/original_ear = locateUID(original_ear_UID)
	if(!QDELETED(original_ear))
		user.drop_item_ground(original_ear, force = TRUE)


/obj/item/clothing/ears/offear/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	var/obj/item/original_ear = locateUID(original_ear_UID)
	if(!original_ear)
		CRASH("No original_ear found.")
	return original_ear.MouseDrop(over_object, src_location, over_location, src_control, over_control, params)


/obj/item/clothing/ears/offear/attack_hand(mob/user, pickupfireoverride)
	var/obj/item/original_ear = locateUID(original_ear_UID)
	if(!original_ear)
		CRASH("No original_ear found.")
	return original_ear.attack_hand(user, pickupfireoverride)


//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = GLASSESCOVERSEYES
	slot_flags = ITEM_SLOT_EYES
	materials = list(MAT_GLASS = 250)
	equip_sound = 'sound/items/handling/generic_equip4.ogg'
	var/vision_flags = 0
	var/see_in_dark = 0 //Base human is 2
	var/invis_view = SEE_INVISIBLE_LIVING
	var/invis_override = 0
	var/lighting_alpha

	var/emagged = FALSE
	var/list/color_view = null//overrides client.color while worn
	var/prescription = FALSE
	var/prescription_upgradable = FALSE
	var/over_hat = FALSE
	var/over_mask = FALSE //Whether or not the eyewear is rendered above the mask. Purely cosmetic.
	strip_delay = 20			//	   but seperated to allow items to protect but not impair vision, like space helmets
	put_on_delay = 25
	resistance_flags = NONE

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/


/obj/item/clothing/glasses/update_icon_state()
	if(..())
		item_state = "[replacetext("[item_state]", "_up", "")][up ? "_up" : ""]"


/obj/item/clothing/glasses/verb/adjust_eyewear() //Adjust eyewear to be worn above or below the mask.
	set name = "Adjust Eyewear"
	set category = "Object"
	set desc = "Adjust your eyewear to be worn over or under a mask."
	set src in usr

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //Dead spessmen adjust no glasses. Resting/buckled ones do, though
		return

	var/action_fluff = "You adjust \the [src]"
	if(user.glasses == src)
		if(!user.can_unEquip(src))
			to_chat(usr, "[src] is stuck to you!")
			return
		if(attack_hand(user)) //Remove the glasses for this action. Prevents logic-defying instances where glasses phase through your mask as it ascends/descends to another plane of existence.
			action_fluff = "You remove \the [src] and adjust it"

	over_mask = !over_mask
	to_chat(user, "<span class='notice'>[action_fluff] to be worn [over_mask ? "over" : "under"] a mask.</span>")

//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_GLOVES
	attack_verb = list("challenged")
	var/transfer_prints = FALSE
	var/pickpocket = 0 //Master pickpocket?
	var/clipped = 0
	var/extra_knock_chance = 0 //extra chance to knock down target when disarming
	strip_delay = 20
	put_on_delay = 40

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi'
		)

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(!clipped)
			playsound(src.loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] snips the fingertips off [src].</span>","<span class='warning'>You snip the fingertips off [src].</span>")
			clipped = TRUE
			update_appearance()
		else
			to_chat(user, "<span class='notice'>[src] have already been clipped!</span>")
		return
	else
		return ..()


/obj/item/clothing/gloves/update_name(updates = ALL)
	. = ..()
	name = clipped ? "mangled [initial(name)]" : initial(name)


/obj/item/clothing/gloves/update_desc(updates = ALL)
	. = ..()
	desc = clipped ? "[initial(desc)] They have had the fingertips cut off of them." : initial(desc)


/obj/item/clothing/under/proc/set_sensors(mob/living/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	for(var/obj/item/grab/grabbed in user.grabbed_by)
		if(grabbed.state >= GRAB_NECK)
			to_chat(user, "You can't reach the controls.")
			return
	if(has_sensor >= 2)
		to_chat(user, "The controls are locked.")
		return
	if(has_sensor <= 0)
		to_chat(user, "This suit does not have any sensors.")
		return

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = tgui_input_list(user, "Select a sensor mode:", "Suit Sensor Mode", modes, modes[sensor_mode+1])
	if(!switchMode)
		return
	if(get_dist(user, src) > 1)
		to_chat(user, "You have moved too far away.")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if(src.loc == user)
		switch(sensor_mode)
			if(0)
				to_chat(user, "You disable your suit's remote sensing equipment.")
			if(1)
				to_chat(user, "Your suit will now report whether you are live or dead.")
			if(2)
				to_chat(user, "Your suit will now report your vital lifesigns.")
			if(3)
				to_chat(user, "Your suit will now report your vital lifesigns as well as your coordinate position.")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.w_uniform == src)
				H.update_suit_sensors()

	else if(istype(src.loc, /mob))
		switch(sensor_mode)
			if(0)
				for(var/mob/V in viewers(user, 1))
					V.show_message("<span class='warning'>[user] disables [src.loc]'s remote sensing equipment.</span>", 1)
			if(1)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] turns [src.loc]'s remote sensors to binary.", 1)
			if(2)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] sets [src.loc]'s sensors to track vitals.", 1)
			if(3)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] sets [src.loc]'s sensors to maximum.", 1)
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.w_uniform == src)
				H.update_suit_sensors()

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/GetID()
	if(accessories)
		for(var/obj/item/clothing/accessory/accessory in accessories)
			if(accessory.GetID())
				return accessory.GetID()
	return ..()

/obj/item/clothing/under/GetAccess()
	. = ..()
	if(accessories)
		for(var/obj/item/clothing/accessory/A in accessories)
			. |= A.GetAccess()
//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	var/blockTracking // Do we block AI tracking?
	var/HUDType = null

	var/vision_flags = 0
	var/see_in_dark = 0
	var/lighting_alpha

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
		)


/obj/item/clothing/head/update_icon_state()
	if(..())
		item_state = "[replacetext("[item_state]", "_up", "")][up ? "_up" : ""]"


/obj/item/clothing/head/attack_self(mob/user)
	adjust_headgear(user)


/obj/item/clothing/head/proc/adjust_headgear(mob/living/carbon/human/user)
	if(!can_toggle || user.incapacitated() || world.time < cooldown + toggle_cooldown)
		return FALSE

	. = TRUE

	cooldown = world.time
	up = !up
	update_icon(UPDATE_ICON_STATE)
	if(user.head == src)
		user.update_head(src, forced = TRUE, toggle_off = !up)
		for(var/datum/action/action as anything in actions)
			action.UpdateButtonIcon()
	else
		update_equipped_item()

	if(up && toggle_on_message)
		to_chat(user, span_notice("[toggle_on_message] [src]"))
	else if(!up && toggle_off_message)
		to_chat(user, span_notice("[toggle_off_message] [src]"))

	if(active_sound)
		INVOKE_ASYNC(src, PROC_REF(headgear_loop_sound))

	if(toggle_sound)
		playsound(loc, toggle_sound, 100, FALSE, 4)


/obj/item/clothing/head/proc/headgear_loop_sound()
	set waitfor = FALSE

	while(up)
		playsound(loc, active_sound, 100, FALSE, 4)
		sleep(1.5 SECONDS)


//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_MASK
	strip_delay = 40
	put_on_delay = 40
	var/adjusted_slot_flags = NONE
	var/adjusted_flags_inv = NONE

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
		)


/// Proc that moves gas/breath masks out of the way
/obj/item/clothing/mask/proc/adjustmask(mob/living/carbon/human/user)
	if(!can_toggle || !ishuman(user) || user.incapacitated())
		return FALSE

	. = TRUE

	up = !up
	update_icon(UPDATE_ICON_STATE)

	if(up)
		to_chat(user, span_notice("You push [src] out of the way."))
		gas_transfer_coefficient = null
		permeability_coefficient = null
		if(adjusted_slot_flags)
			slot_flags = adjusted_slot_flags
		if(adjusted_flags_inv)
			flags_inv ^= adjusted_flags_inv
		//Mask won't cover the mouth any more since it's been pushed out of the way. Allows for CPRing with adjusted masks.
		if(flags_cover & MASKCOVERSMOUTH)
			flags_cover &= ~MASKCOVERSMOUTH
		//If the mask was airtight, it won't be anymore since you just pushed it off your face.
		if(clothing_flags & AIRTIGHT)
			clothing_flags &= ~AIRTIGHT

	else
		to_chat(user, span_notice("You push [src] back into place."))
		gas_transfer_coefficient = initial(gas_transfer_coefficient)
		permeability_coefficient = initial(permeability_coefficient)
		slot_flags = initial(slot_flags)
		if(adjusted_flags_inv)
			flags_inv ^= adjusted_flags_inv
		if(clothing_flags != initial(clothing_flags))
			//If the mask is airtight and thus, one that you'd be able to run internals from yet can't because it was adjusted, make it airtight again.
			if(initial(clothing_flags) & AIRTIGHT)
				clothing_flags |= AIRTIGHT
		if(flags_cover != initial(flags_cover))
			//If the mask covers the mouth when it's down and can be adjusted yet lost that trait when it was adjusted, make it cover the mouth again.
			if(initial(flags_cover) & MASKCOVERSMOUTH)
				flags_cover |= MASKCOVERSMOUTH

	// special head and mask slots post handling
	if(user.wear_mask == src || user.head == src)
		user.wear_mask_update(src, toggle_off = up)
		for(var/datum/action/action as anything in actions)
			action.UpdateButtonIcon()
	else
		update_equipped_item()

	// now we are trying to reequip our mask to a new slot, hands or just drop it
	if(!adjusted_slot_flags || !(src in user.get_equipped_items()))
		return .
	user.drop_item_ground(src, force = TRUE)	// we are changing slots, force is a must
	if(!user.equip_to_slot_if_possible(src, slot_flags))
		user.put_in_hands(src)

/obj/item/clothing/mask/proc/force_adjust_mask()
	up = !up
	update_icon(UPDATE_ICON_STATE)
	gas_transfer_coefficient = null
	permeability_coefficient = null
	flags_cover &= ~MASKCOVERSMOUTH
	flags_inv &= ~HIDENAME
	clothing_flags &= ~AIRTIGHT
	w_class = WEIGHT_CLASS_SMALL

// Changes the speech verb when wearing a mask if a value is returned
/obj/item/clothing/mask/proc/change_speech_verb()
    return

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammatically correct text-parsing
	//var/chained = 0
	var/can_cut_open = FALSE
	var/cut_open = FALSE
	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET
	pickup_sound = 'sound/items/handling/shoes_pickup.ogg'
	drop_sound = 'sound/items/handling/shoes_drop.ogg'

	var/silence_steps = 0
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0)

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/shoes.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/shoes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/shoes.dmi'
		)

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/match) && src.loc == user)
		var/obj/item/match/M = I
		if(M.matchignite()) // Match isn't lit, but isn't burnt.
			user.visible_message("<span class='warning'>[user] strikes a [M] on the bottom of [src], lighting it.</span>","<span class='warning'>You strike the [M] on the bottom of [src] to light it.</span>")
			playsound(user.loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, 1)
		else
			user.visible_message("<span class='warning'>[user] crushes the [M] into the bottom of [src], extinguishing it.</span>","<span class='warning'>You crush the [M] into the bottom of [src], extinguishing it.</span>")
			user.drop_item_ground(I)
		return

	if(I.tool_behaviour == TOOL_WIRECUTTER)
		if(can_cut_open)
			if(!cut_open)
				playsound(src.loc, I.usesound, 100, 1)
				user.visible_message("<span class='warning'>[user] cuts open the toes of [src].</span>","<span class='warning'>You cut open the toes of [src].</span>")
				cut_open = TRUE
				update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)
			else
				to_chat(user, "<span class='notice'>[src] have already had [p_their()] toes cut open!</span>")
		return
	else
		return ..()


/obj/item/clothing/shoes/update_name()
	. = ..()
	if(!cut_open)
		return
	name = "mangled [initial(name)]"


/obj/item/clothing/shoes/update_desc()
	. = ..()
	if(!cut_open)
		return
	desc = "[initial(desc)] They have had their toes opened up."


/obj/item/clothing/shoes/update_icon_state()
	if(!cut_open)
		return
	icon_state = "[icon_state]_opentoe"
	item_state = "[item_state]_opentoe"
	update_equipped_item(update_speedmods = FALSE)


//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	slot_flags = ITEM_SLOT_CLOTH_OUTER
	var/blood_overlay_type = "suit"
	var/suit_adjusted = FALSE
	var/ignore_suitadjust = TRUE
	var/adjust_flavour = null
	var/list/hide_tail_by_species = null
	max_integrity = 400
	integrity_failure = 160

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/Initialize(mapload)
	. = ..()
	setup_shielding()

/**
 * Wrapper proc to apply shielding through AddComponent().
 * Called in /obj/item/clothing/suit/Initialize().
 * Override with an AddComponent(/datum/component/shielded, args) call containing the desired shield statistics.
 * See /datum/component/shielded documentation for a description of the arguments
 **/
/obj/item/clothing/suit/proc/setup_shielding()
	return

//Proc that opens and closes jackets.
/obj/item/clothing/suit/proc/adjustsuit(mob/user)
	if(ignore_suitadjust)
		to_chat(user, span_notice("You attempt to button up the velcro on [src], before promptly realising how foolish you are."))
		return
	if(user.incapacitated())
		return

	if((HULK in user.mutations))
		if(user.can_unEquip(src)) //Checks to see if the item can be unequipped. If so, lets shred. Otherwise, struggle and fail.
			for(var/obj/item/thing in src) //AVOIDING ITEM LOSS. Check through everything that's stored in the jacket and see if one of the items is a pocket.
				if(istype(thing, /obj/item/storage/internal)) //If it's a pocket...
					for(var/obj/item/pocket_thing in thing) //Dump the pocket out onto the floor below the user.
						user.drop_item_ground(pocket_thing, force = TRUE)

			user.visible_message("<span class='warning'>[user] bellows, [pick("shredding", "ripping open", "tearing off")] [user.p_their()] jacket in a fit of rage!</span>","<span class='warning'>You accidentally [pick("shred", "rend", "tear apart")] [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")]!</span>")
			user.temporarily_remove_item_from_inventory(src)
			qdel(src) //Now that the pockets have been emptied, we can safely destroy the jacket.
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		else
			to_chat(user, "<span class='warning'>You yank and pull at \the [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")], however you are unable to change its state!</span>")//Yep, that's all they get. Avoids having to snowflake in a cooldown.
		return

	update_icon(UPDATE_ICON_STATE)
	update_equipped_item()

	if(suit_adjusted)
		var/flavour = "close"
		if(adjust_flavour)
			flavour = "[copytext(adjust_flavour, 3, length(adjust_flavour) + 1)] up" //Trims off the 'un' at the beginning of the word. unzip -> zip, unbutton->button.
		to_chat(user, "You [flavour] [src].")
	else
		var/flavour = "open"
		if(adjust_flavour)
			flavour = "[adjust_flavour]"
		to_chat(user, "You [flavour] [src].")

	suit_adjusted = !suit_adjusted


/obj/item/clothing/suit/update_icon_state()
	// Trims the '_open' off the end of the icon state, thus avoiding a case where jackets that start open will
	// end up with a suffix of _open_open if adjusted twice, since their initial state is _open
	var/base_icon_state = copytext(icon_state, 1, findtext(icon_state, "_open"))
	var/base_item_state = copytext(item_state, 1, findtext(item_state, "_open"))

	icon_state = suit_adjusted ? base_icon_state : "[base_icon_state]_open"
	item_state = suit_adjusted ? base_item_state : "[base_item_state]_open"


// Proc used to check if suit storage is limited by item weight
// Allows any suit to have their own weight limit for items that can be equipped into suit storage
/obj/item/clothing/suit/proc/can_store_weighted(obj/item/I, item_weight = WEIGHT_CLASS_BULKY)
	return I.w_class <= item_weight

/obj/item/clothing/suit/equipped(mob/living/carbon/human/user, slot, initial) //Handle tail-hiding on a by-species basis.
	. = ..()

	if(ishuman(user) && hide_tail_by_species && slot == ITEM_SLOT_CLOTH_OUTER)
		if(user.dna.species.name in hide_tail_by_species)
			if(!(flags_inv & HIDETAIL)) //Hide the tail if the user's species is in the hide_tail_by_species list and the tail isn't already hidden.
				flags_inv |= HIDETAIL
				user.update_tail_layer()
		else
			if(!(initial(flags_inv) & HIDETAIL) && (flags_inv & HIDETAIL)) //Otherwise, remove the HIDETAIL flag if it wasn't already in the flags_inv to start with.
				flags_inv &= ~HIDETAIL
				user.update_tail_layer()

/obj/item/clothing/suit/ui_action_click(mob/user) //This is what happens when you click the HUD action button to adjust your suit.
	if(!ignore_suitadjust)
		adjustsuit(user)
	else
		..() //This is required in order to ensure that the UI buttons for items that have alternate functions tied to UI buttons still work.

/obj/item/clothing/suit/proc/special_overlays() // Does it have special overlays when worn?
	return FALSE

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	w_class = WEIGHT_CLASS_NORMAL
	clothing_flags = STOPSPRESSUREDMAGE|THICKMATERIAL
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = parent_type::flags_inv|HIDEHAIR|HIDENAME|HIDEMASK
	item_state = "s_helmet"
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	species_restricted = list("exclude", SPECIES_WRYN, "lesser form")
	flash_protect = 2
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = NONE
	dog_fashion = null


/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	clothing_flags = STOPSPRESSUREDMAGE|THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	slowdown = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | TAIL
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | TAIL
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	put_on_delay = 80
	resistance_flags = NONE
	hide_tail_by_species = null
	species_restricted = list("exclude", SPECIES_WRYN, "lesser form")
	faction_restricted = list("ashwalker")
	var/obj/item/tank/jetpack/suit/jetpack = null
	var/jetpack_upgradable = FALSE


/obj/item/clothing/suit/space/Initialize(mapload)
	. = ..()
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)


/obj/item/clothing/suit/space/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!jetpack)
		to_chat(user, span_warning("[src] has no jetpack installed."))
		return
	if(src == user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER))
		to_chat(user, span_warning("You cannot remove the jetpack from [src] while wearing it."))
		return
	jetpack.turn_off(user)
	jetpack.forceMove(drop_location())
	jetpack = null
	to_chat(user, span_notice("You successfully remove the jetpack from [src]."))


/obj/item/clothing/suit/space/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(jetpack && slot == ITEM_SLOT_CLOTH_OUTER)
		for(var/datum/action/action as anything in jetpack.actions)
			action.Grant(user)


/obj/item/clothing/suit/space/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(jetpack)
		for(var/datum/action/action as anything in jetpack.actions)
			action.Remove(user)


/obj/item/clothing/suit/space/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(!jetpack_upgradable)
			to_chat(user, span_warning("There is no slot for jetpack upgrade in [src]"))
			return
		if(jetpack)
			to_chat(user, span_warning("[src] already has a jetpack installed."))
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, span_warning("You cannot install the upgrade to [src] while wearing it."))
			return

		if(user.drop_transfer_item_to_loc(I, src))
			jetpack = I
			to_chat(user, span_notice("You successfully install the jetpack into [src]."))
			return
	return ..()


// Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = ITEM_SLOT_CLOTH_INNER
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi'
		)

	var/has_sensor = TRUE//For the crew computer 2 = unable to change mode
	var/sensor_mode = SENSOR_OFF
		/*
		SENSOR_OFF		= Report nothing
		SENSOR_LIVING	= Report living/dead
		SENSOR_VITALS	= Report detailed damages
		SENSOR_COORDS	= Report location
		*/
	var/random_sensor = TRUE
	var/displays_id = TRUE
	var/over_shoes = FALSE
	var/rolled_down = FALSE
	var/list/accessories = list()
	var/basecolor


/obj/item/clothing/under/rank/Initialize(mapload)
	. = ..()
	if(random_sensor)
		sensor_mode = pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_VITALS, SENSOR_COORDS)


/obj/item/clothing/under/Destroy()
	QDEL_LIST(accessories)
	return ..()


/obj/item/clothing/under/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_CLOTH_INNER)
		return .

	for(var/obj/item/clothing/accessory/accessory in accessories)
		accessory.attached_unequip()


/obj/item/clothing/under/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user) || slot != ITEM_SLOT_CLOTH_INNER)
		return .

	for(var/obj/item/clothing/accessory/accessory in accessories)
		accessory.attached_equip()


/*
  * # can_attach_accessory
  *
  * Arguments:
  * * A - The accessory object being checked. MUST BE TYPE /obj/item/clothing/accessory
*/
/obj/item/clothing/under/proc/can_attach_accessory(obj/item/clothing/accessory/A)
	if(istype(A))
		. = TRUE
	else
		return FALSE

	if(accessories.len)
		for(var/obj/item/clothing/accessory/AC in accessories)
			if((A.slot in list(ACCESSORY_SLOT_UTILITY, ACCESSORY_SLOT_ARMBAND)) && AC.slot == A.slot)
				return FALSE
			if(!A.allow_duplicates && AC.type == A.type)
				return FALSE

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/accessory) && attach_accessory(I, user, TRUE))
		return TRUE

	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attackby(I, user, params)
		return TRUE

	. = ..()

/obj/item/clothing/under/proc/attach_accessory(obj/item/clothing/accessory/A, mob/user, unequip = FALSE)
	if(can_attach_accessory(A))
		if(unequip && !user.drop_item_ground(A, ignore_pixel_shift = TRUE)) // Make absolutely sure this accessory is removed from hands
			return FALSE

		accessories += A
		A.on_attached(src, user)

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()

		return TRUE
	else
		to_chat(user, span_notice("You cannot attach more accessories of this type to [src]."))

	return FALSE

/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(has_sensor)
		switch(sensor_mode)
			if(0)
				. += span_notice("Its sensors appear to be disabled.")
			if(1)
				. += span_notice("Its binary life sensors appear to be enabled.")
			if(2)
				. += span_notice("Its vital tracker appears to be enabled.")
			if(3)
				. += span_notice("Its vital tracker and tracking beacon appear to be enabled.")
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			. += A.attached_examine()


/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr

	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/owner = usr

	if(!owner.incapacitated() && !HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		if(copytext(item_color,-2) != "_d")
			basecolor = item_color
		var/icon/file = onmob_sheets[ITEM_SLOT_CLOTH_INNER_STRING]
		if(sprite_sheets && sprite_sheets[owner.dna.species.name])
			file = sprite_sheets[owner.dna.species.name]
		if((basecolor + "_d_s") in icon_states(file))
			item_color = item_color == "[basecolor]" ? "[basecolor]_d" : "[basecolor]"
			owner.update_inv_w_uniform()
		else
			to_chat(owner, span_notice("You cannot roll down this uniform!"))
	else
		to_chat(owner, span_notice("You cannot roll down the uniform right now!"))


/obj/item/clothing/under/verb/removetie()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	handle_accessories_removal(usr)


/obj/item/clothing/under/proc/handle_accessories_removal(mob/user)
	if(!isliving(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!accessories.len)
		return
	var/obj/item/clothing/accessory/accessory
	if(accessories.len > 1)
		accessory = input("Select an accessory to remove from [src]") as null|anything in accessories
	else
		accessory = accessories[1]
	if(!accessory || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	remove_accessory(user, accessory)


/obj/item/clothing/under/proc/remove_accessory(mob/user, obj/item/clothing/accessory/accessory)
	if(!(accessory in accessories))
		return
	accessory.on_removed(user)
	accessories -= accessory
	to_chat(user, span_notice("You remove [accessory] from [src]."))
	user.update_inv_w_uniform()


/obj/item/clothing/under/emp_act(severity)
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emp_act(severity)
	..()

/obj/item/clothing/under/AltClick(mob/user)
	if(Adjacent(user))
		handle_accessories_removal(user)

/obj/item/clothing/obj_destruction(damage_flag)
	if(damage_flag == "bomb" || damage_flag == "melee")
		var/turf/T = get_turf(src)
		spawn(1) //so the shred survives potential turf change from the explosion.
			var/obj/effect/decal/cleanable/shreds/Shreds = new(T)
			Shreds.desc = "The sad remains of what used to be [name]."
		deconstruct(FALSE)
	else
		..()

// Neck clothing
/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = UPPER_TORSO
	slot_flags = ITEM_SLOT_NECK

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/neck.dmi'
		)

/obj/item/clothing/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!teleportation)
		return ..()
	if(prob(5))
		var/mob/living/carbon/human/H = owner
		owner.visible_message("<span class='danger'>The teleport slime potion flings [H] clear of [attack_text]!</span>")
		var/list/turfs = new/list()
		for(var/turf/T in orange(3, H))
			if(isspaceturf(T))
				continue
			if(T.density)
				continue
			if(T.x>world.maxx-3 || T.x<3)
				continue
			if(T.y>world.maxy-3 || T.y<3)
				continue
			turfs += T
		if(!turfs.len)
			turfs += pick(/turf in orange(3, H))
		var/turf/picked = pick(turfs)
		if(!isturf(picked))
			return
		H.forceMove(picked)
		return 1
	return ..()


/**
 * Inserts a trait (or multiple traits) into the clothing traits list
 *
 * If worn, then we will also give the wearer the trait as if equipped
 *
 * This is so you can add clothing traits without worrying about needing to equip or unequip them to gain effects
 */
/obj/item/clothing/proc/attach_clothing_traits(trait_or_traits)
	if(!islist(trait_or_traits))
		trait_or_traits = list(trait_or_traits)

	LAZYOR(clothing_traits, trait_or_traits)
	var/mob/wearer = loc
	if(istype(wearer) && (wearer.get_slot_by_item(src) & slot_flags))
		for(var/new_trait in trait_or_traits)
			ADD_CLOTHING_TRAIT(wearer, src, new_trait)


/**
 * Removes a trait (or multiple traits) from the clothing traits list
 *
 * If worn, then we will also remove the trait from the wearer as if unequipped
 *
 * This is so you can add clothing traits without worrying about needing to equip or unequip them to gain effects
 */
/obj/item/clothing/proc/detach_clothing_traits(trait_or_traits)
	if(!islist(trait_or_traits))
		trait_or_traits = list(trait_or_traits)

	LAZYREMOVE(clothing_traits, trait_or_traits)
	var/mob/wearer = loc
	if(istype(wearer))
		for(var/new_trait in trait_or_traits)
			REMOVE_CLOTHING_TRAIT(wearer, src, new_trait)

