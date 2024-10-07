/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply."
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT|AIRTIGHT
	flags_inv = HIDEGLASSES|HIDENAME
	flags_cover = MASKCOVERSMOUTH|MASKCOVERSEYES
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	resistance_flags = NONE
	undyeable = TRUE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
	)

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	icon_state = "weldingmask"
	item_state = "weldingmask"
	materials = list(MAT_METAL=4000, MAT_GLASS=2000)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	can_toggle = TRUE
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 55)
	origin_tech = "materials=2;engineering=3"
	actions_types = list(/datum/action/item_action/toggle)
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH
	visor_flags_inv = HIDEGLASSES
	resistance_flags = FIRE_PROOF


/obj/item/clothing/mask/gas/welding/attack_self(mob/user)
	weldingvisortoggle(user)


/obj/item/clothing/mask/gas/welding/adjustmask(mob/living/carbon/human/user)
	return


/obj/item/clothing/mask/gas/explorer
	name = "explorer gas mask"
	desc = "A military-grade gas mask that can be connected to an air supply."
	icon_state = "gas_mining"
	actions_types = list(/datum/action/item_action/adjust)
	armor = list("melee" = 10, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 20, "acid" = 40)
	resistance_flags = FIRE_PROOF
	can_toggle = TRUE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
	)


/obj/item/clothing/mask/gas/explorer/attack_self(mob/user)
	adjustmask(user)


/obj/item/clothing/mask/gas/explorer/adjustmask(mob/living/carbon/human/user)
	. = ..()
	if(.)
		w_class = up ? WEIGHT_CLASS_SMALL : WEIGHT_CLASS_NORMAL


/obj/item/clothing/mask/gas/explorer/force_adjust_mask()
	. = ..()
	w_class = WEIGHT_CLASS_SMALL


/obj/item/clothing/mask/gas/explorer/folded/Initialize(mapload)
	. = ..()
	force_adjust_mask()

//Bane gas mask
/obj/item/clothing/mask/banemask
	name = "bane mask"
	desc = "Only when the station is in flames, do you have my permission to robust."
	icon_state = "bane_mask"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT|AIRTIGHT
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "bane_mask"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01


//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 2, "energy" = 2, "bomb" = 0, "bio" = 75, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	strip_delay = 60

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask. Its form can be changed by using it in your hand."
	icon_state = "clown"
	item_state = "clown_hat"
	flags_inv = parent_type::flags_inv|HIDEHAIR
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	dog_fashion = /datum/dog_fashion/head/clown

/obj/item/clothing/mask/gas/clown_hat/attack_self(mob/living/user)
	var/list/mask_type = list("True Form" = /obj/item/clothing/mask/gas/clown_hat,
							"The Feminist" = /obj/item/clothing/mask/gas/clown_hat/sexy,
							"The Madman" = /obj/item/clothing/mask/gas/clown_hat/joker,
							"The Rainbow Color" = /obj/item/clothing/mask/gas/clown_hat/rainbow)
	var/list/mask_icons = list("True Form" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "clown"),
							"The Feminist" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "sexyclown"),
							"The Madman" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "joker"),
							"The Rainbow Color" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "rainbow"))
	var/mask_choice = show_radial_menu(user, src, mask_icons)
	var/picked_mask = mask_type[mask_choice]

	if(QDELETED(src) || !picked_mask)
		return
	if(user.stat || !in_range(user, src))
		return
	var/obj/item/clothing/mask/gas/clown_hat/new_mask = new picked_mask(get_turf(user))
	qdel(src)
	user.put_in_active_hand(new_mask)
	to_chat(user, "<span class='notice'>Your Clown Mask has now morphed into its new form, all praise the Honk Mother!</span>")
	return TRUE

/obj/item/clothing/mask/gas/clown_hat/sexy
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers. Its form can be changed by using it in your hand."
	icon_state = "sexyclown"
	item_state = "sexyclown"

/obj/item/clothing/mask/gas/clown_hat/joker
	name = "deranged clown wig and mask"
	desc = "A fiendish clown mask that inspires a deranged mirth. Its form can be changed by using it in your hand."
	icon_state = "joker"
	item_state = "joker"

/obj/item/clothing/mask/gas/clown_hat/rainbow
	name = "rainbow clown wig and mask"
	desc = "A colorful clown mask for the clown that loves to dazzle and impress. Its form can be changed by using it in your hand."
	icon_state = "rainbow"
	item_state = "rainbow"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/mask/gas/clownwiz
	name = "wizard clown wig and mask"
	desc = "Some pranksters are truly magical."
	icon_state = "wizzclown"
	item_state = "wizzclown"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDEHAIR
	magical = TRUE


/obj/item/clothing/mask/gas/clown_hat/nodrop


/obj/item/clothing/mask/gas/clown_hat/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE


/obj/item/clothing/mask/gas/mime/equipped(mob/user, slot, initial)
	. = ..()

	if(!user?.mind || slot != ITEM_SLOT_MASK)
		return

	var/obj/effect/proc_holder/spell/mime/speak/mask/mask_spell = null
	for(var/obj/effect/proc_holder/spell/mime/speak/spell in user.mind.spell_list)
		if(istype(spell, /obj/effect/proc_holder/spell/mime/speak/mask))
			mask_spell = spell
			continue
		if(spell)
			return

	if(mask_spell)
		mask_spell.action.enable_invisibility(FALSE)
		return

	user.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak/mask)


/obj/item/clothing/mask/gas/mime/dropped(mob/user, slot, silent = FALSE)
	. = ..()

	if(!user?.mind || slot != ITEM_SLOT_MASK)
		return

	var/obj/effect/proc_holder/spell/mime/speak/mask/spell = locate() in user.mind.spell_list
	if(!spell)
		return

	if(spell.cooldown_handler.is_on_cooldown())
		spell.action.enable_invisibility(TRUE)
		return

	if(user.mind.miming)
		spell.cast(list(user))
	user.mind.RemoveSpell(spell)


/obj/item/clothing/mask/gas/mime/wizard
	name = "magical mime mask"
	desc = "A mime mask glowing with power. Its eyes gaze deep into your soul."
	flags_inv = HIDEHEADSETS|HIDEGLASSES
	magical = TRUE


/obj/item/clothing/mask/gas/mime/nodrop


/obj/item/clothing/mask/gas/mime/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/mime/sexy
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	item_state = "sexymime"

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop"
	icon_state = "death"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/hoot)


/obj/item/clothing/mask/gas/owl_mask/super_hero


/obj/item/clothing/mask/gas/owl_mask/super_hero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/mask/gas/owl_mask/attack_self()
	hoot()

/obj/item/clothing/mask/gas/owl_mask/proc/hoot()
	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		playsound(src.loc, 'sound/creatures/hoot.ogg', 50, 1)
		cooldown = world.time

// ********************************************************************

// **** Security gas mask ****

/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device, plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	icon_state = "sechailer"
	item_state = "sechailer"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDENAME
	flags_cover = MASKCOVERSMOUTH
	clothing_traits = list(TRAIT_SECDEATH)
	var/phrase = 1
	var/aggressiveness = 1
	var/safety = 1
	can_toggle = TRUE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)
	var/phrase_list = list(

								"halt" 			= "HALT! HALT! HALT! HALT!",
								"bobby" 		= "Stop in the name of the Law.",
								"compliance"	= "Compliance is in your best interest.",
								"justice"		= "Prepare for justice!",
								"running"		= "Running will only increase your sentence.",
								"dontmove"		= "Don't move, Creep!",
								"floor"			= "Down on the floor, Creep!",
								"robocop"		= "Dead or alive you're coming with me.",
								"god"			= "God made today for the crooks we could not catch yesterday.",
								"freeze"		= "Freeze, Scum Bag!",
								"imperial"		= "Stop right there, criminal scum!",
								"bash"			= "Stop or I'll bash you.",
								"harry"			= "Go ahead, make my day.",
								"asshole"		= "Stop breaking the law, asshole.",
								"stfu"			= "You have the right to shut the fuck up",
								"shutup"		= "Shut up crime!",
								"super"			= "Face the wrath of the golden bolt.",
								"dredd"			= "I am, the LAW!"
								)


/obj/item/clothing/mask/gas/sechailer/adjustmask(user)
	. = ..()
	if(.)
		w_class = up ? WEIGHT_CLASS_SMALL : WEIGHT_CLASS_NORMAL


/obj/item/clothing/mask/gas/sechailer/force_adjust_mask()
	. = ..()
	w_class = WEIGHT_CLASS_SMALL


/obj/item/clothing/mask/gas/sechailer/folded/Initialize(mapload)
	. = ..()
	force_adjust_mask()


/obj/item/clothing/mask/gas/sechailer/hos
	name = "\improper HOS SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000. It has a tan stripe."
	icon_state = "hosmask"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/warden
	name = "\improper Warden SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000. It has a blue stripe."
	icon_state = "wardenmask"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)


/obj/item/clothing/mask/gas/sechailer/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000."
	icon_state = "officermask"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/blue
	name = "\improper blue SWAT mask"
	desc = "A neon blue swat mask, used for demoralizing Greytide in the wild."
	icon_state = "blue_sechailer"
	item_state = "blue_sechailer"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "security hailer"
	desc = "A set of recognizable pre-recorded messages for cyborgs to use when apprehending criminals."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/halt))
		halt()
	else if(istype(action, /datum/action/item_action/adjust))
		adjustmask(user)
	else if(istype(action, /datum/action/item_action/selectphrase))
		var/key = phrase_list[phrase]
		var/message = phrase_list[key]

		if (!safety)
			to_chat(user, "<span class='notice'>You set the restrictor to: FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND DO SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT.</span>")
			return

		switch(aggressiveness)
			if(1)
				phrase = (phrase < 6) ? (phrase + 1) : 1
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(2)
				phrase = (phrase < 11 && phrase >= 7) ? (phrase + 1) : 7
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(3)
				phrase = (phrase < 18 && phrase >= 12 ) ? (phrase + 1) : 12
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(4)
				phrase = (phrase < 18 && phrase >= 1 ) ? (phrase + 1) : 1
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			else
				to_chat(user, "<span class='notice'>It's broken.</span>")

		var/datum/action/item_action/halt/halt_action = locate() in actions
		if(halt_action)
			halt_action.name = "[uppertext(key)]!"
			halt_action.UpdateButtonIcon()


/obj/item/clothing/mask/gas/sechailer/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	switch(aggressiveness)
		if(1)
			to_chat(user, span_notice("You set the aggressiveness restrictor to the second position."))
			aggressiveness = 2
			phrase = 7
		if(2)
			to_chat(user, span_notice("You set the aggressiveness restrictor to the third position."))
			aggressiveness = 3
			phrase = 13
		if(3)
			to_chat(user, span_notice("You set the aggressiveness restrictor to the fourth position."))
			aggressiveness = 4
			phrase = 1
		if(4)
			to_chat(user, span_notice("You set the aggressiveness restrictor to the first position."))
			aggressiveness = 1
			phrase = 1
		if(5)
			to_chat(user, span_warning("You adjust the restrictor but nothing happens, probably because its broken."))


/obj/item/clothing/mask/gas/sechailer/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(aggressiveness == 5)
		to_chat(user, span_warning("The [name] is already broken."))
		return .
	var/confirm = tgui_alert(user, "Do you want to cut off the voice modulator? Warning: It will destroy mask's functionality.", "Cut voice modulator?", list("Yes", "No"))
	if(confirm != "Yes" || aggressiveness == 5 || !Adjacent(user) || user.incapacitated())
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	aggressiveness = 5
	to_chat(user, span_warning("You have cut off the voice modulator, the mask is broken now."))


/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()

/obj/item/clothing/mask/gas/sechailer/emag_act(mob/user)
	if(safety)
		safety = 0
		if(user)
			to_chat(user, "<span class='warning'>You silently fry [src]'s vocal circuit with the cryptographic sequencer.")

/obj/item/clothing/mask/gas/sechailer/proc/halt()
	var/key = phrase_list[phrase]
	var/message = phrase_list[key]


	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		if(!safety)
			message = "FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND DO SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
			usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[message]</b></font>")
			playsound(src.loc, 'sound/voice/binsult.ogg', 100, 0, 4)
			cooldown = world.time
			return

		usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[message]</b></font>")
		playsound(src.loc, "sound/voice/complionator/[key].ogg", 100, 0, 4)
		cooldown = world.time



// ********************************************************************
