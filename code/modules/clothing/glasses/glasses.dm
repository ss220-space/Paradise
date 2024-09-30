/obj/item/clothing/glasses/Initialize(mapload)
	. = ..()
	if(prescription_upgradable && prescription)
		// Pre-upgraded upgradable glasses
		upgrade_prescription()


/obj/item/clothing/glasses/attackby(obj/item/I, mob/living/carbon/human/user, params)
	if(!ishuman(user) || user.incapacitated())
		return ..()

	if(istype(I, /obj/item/clothing/glasses/regular))
		add_fingerprint(user)
		if(!prescription_upgradable)
			to_chat(user, span_warning("You cannot add prescription lenses to [src]."))
			return ATTACK_CHAIN_PROCEED
		if(prescription)
			to_chat(user, span_warning("You cannot possibly imagine how adding more lenses would improve [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))	// Store the glasses for later removal
			return ..()
		upgrade_prescription(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/glasses/update_name(updates = ALL)
	. = ..()
	name = prescription ? "prescription [initial(name)]" : initial(name)


/obj/item/clothing/glasses/proc/upgrade_prescription(obj/item/I, mob/living/carbon/human/user)
	if(!I)
		new /obj/item/clothing/glasses/regular(src)
	else if(I.loc != src)
		I.forceMove(src)
	prescription = TRUE
	update_appearance(UPDATE_NAME)
	if(user)
		to_chat(user, span_notice("You fit [src] with lenses from [I]."))
		if(user.glasses == src)
			user.update_nearsighted_effects()


/obj/item/clothing/glasses/proc/remove_prescription(mob/living/carbon/human/user)
	var/obj/item/clothing/glasses/regular/prescription_glasses = locate() in src

	if(!prescription_glasses)
		return

	prescription = FALSE
	update_appearance(UPDATE_NAME)

	prescription_glasses.forceMove(drop_location())

	if(user)
		to_chat(user, span_notice("You salvage the prescription lenses from [src]."))
		user.put_in_hands(prescription_glasses, ignore_anim = FALSE)
		if(user.glasses == src)
			user.update_nearsighted_effects()


/obj/item/clothing/glasses/screwdriver_act(mob/living/user, obj/item/I)
	if(!prescription)
		to_chat(user, span_notice("There are no prescription lenses in [src]."))
		return FALSE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return TRUE
	remove_prescription(user)
	return TRUE


/obj/item/clothing/glasses/visor_toggling(mob/user)
	. = ..()
	if(!.)
		return .
	if(visor_vars_to_toggle & VISOR_VISIONFLAGS)
		vision_flags ^= initial(vision_flags)
	if(visor_vars_to_toggle & VISOR_DARKNESSVIEW)
		see_in_dark ^= initial(see_in_dark)
	if(visor_vars_to_toggle & VISOR_INVISVIEW)
		invis_view ^= initial(invis_view)


/obj/item/clothing/glasses/meson
	name = "Optical Meson Scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	item_state = "meson"
	origin_tech = "magnets=1;engineering=2"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = TRUE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/meson/sunglasses
	name = "Meson Sunglasses"
	desc = "An Optical Meson Scanner that protects your eyes"
	icon_state = "sunmeson"
	item_state = "sunmeson"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/meson/night
	name = "Night Vision Optical Meson Scanner"
	desc = "An Optical Meson Scanner fitted with an amplified visible light spectrum overlay, providing greater visual clarity in darkness."
	icon_state = "nvgmeson"
	item_state = "nvgmeson"
	origin_tech = "magnets=4;engineering=5;plasmatech=4"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/meson/prescription
	prescription = TRUE

/obj/item/clothing/glasses/meson/gar
	name = "gar mesons"
	icon_state = "garm"
	item_state = "garm"
	desc = "Do the impossible, see the invisible!"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = TRUE

/obj/item/clothing/glasses/meson/cyber
	name = "Eye Replacement Implant"
	desc = "An implanted replacement for a left eye with meson vision capabilities."
	icon_state = "cybereye-green"
	item_state = "eyepatch"
	flags_cover = NONE
	prescription_upgradable = FALSE


/obj/item/clothing/glasses/meson/cyber/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "A pair of snazzy goggles used to protect against chemical spills. Fitted with an analyzer for scanning items and reagents."
	icon_state = "purple"
	item_state = "purple"
	origin_tech = "magnets=2;engineering=1"
	prescription_upgradable = FALSE
	examine_extensions = EXAMINE_HUD_SCIENCE
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/glasses/science/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/item/clothing/glasses/science/night
	name = "Night Vision Science Goggle"
	desc = "Now you can science in darkness."
	icon_state = "nvpurple"
	item_state = "purple"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

/obj/item/clothing/glasses/janitor
	name = "Janitorial Goggles"
	desc = "These'll keep the soap out of your eyes."
	icon_state = "purple"
	item_state = "purple"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/night
	name = "Night Vision Goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "materials=4;magnets=4;plasmatech=4;engineering=4"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol
	prescription_upgradable = TRUE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/material
	name = "Optical Material Scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	origin_tech = "magnets=3;engineering=3"
	vision_flags = SEE_OBJS

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/material/cyber
	name = "Eye Replacement Implant"
	desc = "An implanted replacement for a left eye with material vision capabilities."
	icon_state = "cybereye-blue"
	item_state = "eyepatch"
	flags_cover = NONE


/obj/item/clothing/glasses/material/cyber/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/glasses/material/lighting
	name = "Neutron Goggles"
	desc = "These odd glasses use a form of neutron-based imaging to completely negate the effects of light and darkness."
	origin_tech = null
	vision_flags = NONE
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE


/obj/item/clothing/glasses/material/lighting/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	item_state = "glasses"
	prescription = TRUE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

/obj/item/clothing/glasses/threedglasses
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	name = "3D glasses"
	icon_state = "3d"
	item_state = "3d"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/gglasses
	name = "Green Glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)
	prescription_upgradable = TRUE

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	prescription_upgradable = TRUE
	dog_fashion = /datum/dog_fashion/head
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses_fake
	desc = "Cheap, plastic sunglasses. They don't even have UV protection."
	name = "cheap sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses_fake/holo
	desc = "Protects against the holographic UV rays of the holographic sun."
	name = "holographic sunglasses"

/obj/item/clothing/glasses/thermal_fake
	desc = "Cheap plastic sunglasses. Wear thoze if yu are kool."
	name = "Phirmel Soonglesas"
	icon_state = "sunthermal"
	item_state = "sunthermal"

/obj/item/clothing/glasses/sunglasses/noir
	name = "noir sunglasses"
	desc = "Somehow these seem even more out-of-date than normal sunglasses."
	actions_types = list(/datum/action/item_action/noir)

/obj/item/clothing/glasses/sunglasses/noir/attack_self(mob/user)
	toggle_noir(user)

/obj/item/clothing/glasses/sunglasses/noir/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/item/clothing/glasses/sunglasses/noir/proc/toggle_noir(mob/user)
	color_view = color_view ? null : MATRIX_GREYSCALE //Toggles between null and grayscale, with null being the default option.
	user.update_client_colour()

/obj/item/clothing/glasses/sunglasses/yeah
	name = "agreeable glasses"
	desc = "H.C Limited edition."
	var/punused = FALSE
	actions_types = list(/datum/action/item_action/YEEEAAAAAHHHHHHHHHHHHH)

/obj/item/clothing/glasses/sunglasses/yeah/attack_self(mob/user)
	pun(user)

/obj/item/clothing/glasses/sunglasses/yeah/proc/pun(mob/user)
	if(punused) // one per round..
		to_chat(user, "The moment is gone.")
		return

	punused = TRUE
	playsound(loc, 'sound/misc/yeah.ogg', 100, FALSE)
	user.visible_message("<span class='biggerdanger'>YEEEAAAAAHHHHHHHHHHHHH!!</span>")
	if(HAS_TRAIT(user, TRAIT_BADASS)) //unless you're badass
		addtimer(VARSET_CALLBACK(src, punused, FALSE), 5 MINUTES)


/obj/item/clothing/glasses/sunglasses/reagent
	name = "sunscanners"
	desc = "Strangely ancient technology used to help provide rudimentary eye color. Outfitted with apparatus to scan individual reagents."
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/glasses/virussunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses/lasers
	desc = "A peculiar set of sunglasses; they have various chips and other panels attached to the sides of the frames."
	name = "high-tech sunglasses"


/obj/item/clothing/glasses/sunglasses/lasers/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/glasses/sunglasses/lasers/equipped(mob/user, slot, initial = FALSE) //grant them laser eyes upon equipping it.
	. = ..()
	if(slot == ITEM_SLOT_EYES)
		ADD_TRAIT(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
		user.update_mutations()


/obj/item/clothing/glasses/sunglasses/lasers/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_EYES)
		REMOVE_TRAIT(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
		user.update_mutations()


/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	can_toggle = TRUE
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"
	tint = 0

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold_white"
	item_state = "blindfold_white"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 3				//to make them blind
	prescription_upgradable = FALSE
	var/colour = null

/obj/item/clothing/glasses/sunglasses/blindfold/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	add_atom_colour(colour, FIXED_COLOUR_PRIORITY)

/obj/item/clothing/glasses/sunglasses/blindfold/black
	colour = "#2a2a2a"

/obj/item/clothing/glasses/sunglasses/blindfold_fake
	name = "thin blindfold"
	desc = "Covers the eyes, but not thick enough to obscure vision. Mostly for aesthetic."
	icon_state = "blindfold_white"
	item_state = "blindfold_white"
	flash_protect = FLASH_PROTECTION_NONE
	tint = 0
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/sunglasses/blindfold_fake/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)

/obj/item/clothing/glasses/sunglasses/prescription
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/thermal
	name = "Optical Thermal Scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "thermal"
	origin_tech = "magnets=3"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/thermal/emp_act(severity)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		var/obj/item/organ/internal/eyes/eyes = H.get_organ_slot(INTERNAL_ORGAN_EYES)
		if(eyes && H.glasses == src)
			to_chat(H, span_warning("[src] overloads and blinds you!"))
			H.flash_eyes(3, visual = TRUE)
			H.EyeBlind(6 SECONDS)
			H.EyeBlurry(10 SECONDS)
			eyes.internal_receive_damage(5)
	..()

/obj/item/clothing/glasses/thermal/sunglasses
	name = "Thermal Sunglasses"
	desc = "How does it even works?.."
	icon_state = "sunthermal"
	item_state = "sunthermal"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/thermal/monocle
	name = "Thermoncle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	flags_cover = null //doesn't protect eyes because it's a monocle, duh

/obj/item/clothing/glasses/thermal/eyepatch
	name = "Optical Thermal Eyepatch"
	desc = "An eyepatch with built-in thermal optics"
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/glasses/thermal/jensen
	name = "Optical Thermal Implants"
	desc = "A set of implantable lenses designed to augment your vision"
	icon_state = "thermalimplants"
	item_state = "syringe_kit"

/obj/item/clothing/glasses/thermal/cyber
	name = "Eye Replacement Implant"
	desc = "An implanted replacement for a left eye with thermal vision capabilities."
	icon_state = "cybereye-red"
	item_state = "eyepatch"


/obj/item/clothing/glasses/thermal/cyber/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/glasses/hud/godeye
	name = "eye of god"
	desc = "A strange eye, said to have been torn from an omniscient creature that used to roam the wastes."
	icon_state = "godeye"
	item_state = "godeye"
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	examine_extensions = EXAMINE_HUD_SCIENCE
	flags_cover = null
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	var/double_eye = FALSE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)


/obj/item/clothing/glasses/hud/godeye/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/glasses/hud/godeye/update_icon_state()
	icon_state = "[double_eye ? "double" : ""]godeye"
	item_state = "[double_eye ? "double" : ""]godeye"


/obj/item/clothing/glasses/hud/godeye/update_desc(updates = ALL)
	. = ..()
	if(!double_eye)
		desc = initial(desc)
		return
	desc = "A pair of strange eyes, said to have been torn from an omniscient creature that used to roam the wastes. There's no real reason to have two, but that isn't stopping you."


/obj/item/clothing/glasses/hud/godeye/attackby(obj/item/I, mob/user, params)
	if(istype(I, type) && I != src && I.loc == user)
		add_fingerprint(user)
		if(double_eye)
			to_chat(user, span_notice("The eye winks at you and vanishes into the abyss, you feel really unlucky."))
		else
			double_eye = TRUE
			update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
			user.wear_glasses_update(src)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/glasses/tajblind
	name = "embroidered veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes."
	icon_state = "tajblind"
	item_state = "tajblind"
	flags_cover = GLASSESCOVERSEYES
	actions_types = list(/datum/action/item_action/toggle)
	tint = 3

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/tajblind/eng
	name = "industrial veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This ones are with meson scanners and welding shield."
	icon_state = "tajblind_engi"
	item_state = "tajblind_engi"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_WELDER
	var/flash_protect_up = FLASH_PROTECTION_NONE


/obj/item/clothing/glasses/tajblind/eng/sunglasses
	flash_protect_up = FLASH_PROTECTION_FLASH
	tint_up = 1


/obj/item/clothing/glasses/tajblind/eng/toggle_veil(mob/user)
	. = ..()
	if(.)
		flash_protect = up ? flash_protect_up : initial(flash_protect)


/obj/item/clothing/glasses/tajblind/sci
	name = "hi-tech veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This ones are with reagent and research scanners."
	icon_state = "tajblind_sci"
	item_state = "tajblind_sci"
	examine_extensions = EXAMINE_HUD_SCIENCE
	actions_types = list(/datum/action/item_action/toggle_research_scanner,/datum/action/item_action/toggle)

/obj/item/clothing/glasses/tajblind/sci/sunglasses
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/tajblind/cargo
	name = "khaki veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This ones are with meson scanners."
	icon_state = "tajblind_cargo"
	item_state = "tajblind_cargo"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = TRUE

/obj/item/clothing/glasses/tajblind/cargo/sunglasses
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1


/obj/item/clothing/glasses/tajblind/attack_self(mob/user)
	toggle_veil(user)


/obj/item/clothing/glasses/proc/toggle_veil(mob/living/carbon/human/user)
	if(user.incapacitated())
		return FALSE
	. = TRUE
	up = !up
	tint = up ? tint_up : initial(tint)
	if(user.glasses == src)
		to_chat(user, span_notice("[up ? "You activate [src], allowing you to see." : "You deactivate [src], obscuring your vision."]"))
		user.wear_glasses_update(src)


/obj/item/clothing/glasses/sunglasses/blindfold/cucumbermask
	desc = "A simple pair of two cucumber slices. Medically proven to be able to heal your eyes over time."
	name = "cucumber mask"
	heal_bodypart = INTERNAL_ORGAN_EYES
	icon_state = "cucumbermask"
	item_state = "cucumbermask"

/obj/item/clothing/glasses/heart
	name = "heart-shaped glasses"
	desc = "Cheap plastic glasses with a fancy shape."
	icon_state = "heart"
	item_state = "heart"
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		)

/obj/item/clothing/glasses/heart/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
