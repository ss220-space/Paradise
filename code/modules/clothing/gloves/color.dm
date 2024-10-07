/obj/item/clothing/gloves/color
	dying_key = DYE_REGISTRY_GLOVES

/obj/item/clothing/gloves/color/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	belt_icon = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	item_color="yellow"
	resistance_flags = NONE

/obj/item/clothing/gloves/color/yellow/power
	description_antag = "These are a pair of power gloves, and can be used to fire bolts of electricity while standing over powered power cables."
	var/old_mclick_override
	var/datum/middleClickOverride/power_gloves/mclick_override = new /datum/middleClickOverride/power_gloves
	var/last_shocked = 0
	var/shock_delay = 40
	var/unlimited_power = FALSE // Does this really need explanation?


/obj/item/clothing/gloves/color/yellow/power/equipped(mob/living/carbon/human/user, slot, initial)
	. = ..()

	if(!ishuman(user) || slot != ITEM_SLOT_GLOVES)
		return .

	if(user.middleClickOverride)
		old_mclick_override = user.middleClickOverride
	user.middleClickOverride = mclick_override
	if(!unlimited_power)
		to_chat(user, span_notice("You feel electricity begin to build up in [src]."))
	else
		to_chat(user, span_dangerbigger("You feel like you have UNLIMITED POWER!!!"))


/obj/item/clothing/gloves/color/yellow/power/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()

	if(!ishuman(user) || slot != ITEM_SLOT_GLOVES || user.middleClickOverride != mclick_override)
		return .

	if(old_mclick_override)
		user.middleClickOverride = old_mclick_override
		old_mclick_override = null
	else
		user.middleClickOverride = null


/obj/item/clothing/gloves/color/yellow/power/unlimited
	name = "UNLIMITED POWER gloves"
	desc = "These gloves possess UNLIMITED POWER."
	shock_delay = 0
	unlimited_power = TRUE

/obj/item/clothing/gloves/color/yellow/fake
	siemens_coefficient = 1

/obj/item/clothing/gloves/color/yellow/fake/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += span_notice("They don't feel like rubber...")


/obj/item/clothing/gloves/color/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "fyellow"
	item_state = "ygloves"
	siemens_coefficient = 0			//Set to a default of 0
	belt_icon = "ygloves"
	permeability_coefficient = 0.05
	item_color="yellow"
	resistance_flags = NONE
	toolspeedmod = 0.2
	clothing_traits = list(TRAIT_NO_GUNS)


/obj/item/clothing/gloves/color/fyellow/old
	desc = "Old and worn out insulated gloves, hopefully they still work."
	name = "worn out insulated gloves"

/obj/item/clothing/gloves/color/fyellow/old/New()
	..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/color/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	item_color="black"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	var/can_be_cut = 1


/obj/item/clothing/gloves/color/black/hos
	item_color = "hosred"		//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/color/black/ce
	item_color = "chief"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/color/black/thief
	pickpocket = TRUE


/obj/item/clothing/gloves/color/black/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!can_be_cut || icon_state != initial(icon_state))	// only if not dyed
		to_chat(user, span_warning("You cannot cut off [src]!"))
		return .
	if(loc == user)
		to_chat(user, span_warning("You cut off [src]'s fingertips while wearing it!"))
		return .
	var/confirm = tgui_alert(user, "Do you want to cut off the gloves fingertips? Warning: It might destroy their functionality.", "Cut tips?", list("Yes", "No"))
	if(confirm != "Yes" || icon_state != initial(icon_state) || !Adjacent(user) || user.incapacitated())
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You snip the fingertips off of [src]."))
	var/obj/item/clothing/gloves/fingerless/new_gloves = new(loc)
	transfer_fingerprints_to(new_gloves)
	new_gloves.add_fingerprint(user)
	if(pickpocket)
		new_gloves.pickpocket = FALSE
	qdel(src)


/obj/item/clothing/gloves/color/black/goliath
	name = "goliath gloves"
	desc = "Rudimentary gloves that aid in carrying."
	icon_state = "goligloves"
	item_state = "goligloves"
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 5, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 50, "acid" = 50)
	can_be_cut = FALSE

/obj/item/clothing/gloves/color/black/ballistic
	name = "armored gloves"
	desc = "Pair of gloves with some protection"
	icon_state = "armored_gloves"
	item_state = "armored_gloves"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	can_be_cut = FALSE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi'
		)

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"
	item_color="orange"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"
	item_color = "red"

/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "These gloves will protect the wearer from electric shock."
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	item_color = "rainbow"

/obj/item/clothing/gloves/color/rainbow/clown
	item_color = "clown"

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"
	item_color="blue"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"
	item_color="purple"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"
	item_color="green"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"
	item_color="grey"

/obj/item/clothing/gloves/color/grey/rd
	item_color = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/color/grey/hop
	item_color = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	item_color="light brown"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"
	item_color="brown"

/obj/item/clothing/gloves/color/brown/cargo
	name = "cargo gloves"
	item_color = "cargo"				//Exists for washing machines. Is not different from brown gloves in any way.

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex."
	icon_state = "latex"
	item_state = "lgloves"
	belt_icon = "latex_gloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	item_color="white"
	transfer_prints = TRUE
	resistance_flags = NONE

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "Pricy sterile gloves that are stronger than latex."
	icon_state = "nitrile"
	item_state = "nitrilegloves"
	transfer_prints = FALSE
	item_color = "medical"

/obj/item/clothing/gloves/color/latex/modified
	name = "modified medical gloves"
	desc = "They are very soft and light to the touch and do not hinder movement at all."
	icon_state = "modified"
	item_state = "modified"
	item_color = "modified"
	surgeryspeedmod = -0.3

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	item_state = "wgloves"
	item_color="mime"

/obj/item/clothing/gloves/color/white/redcoat
	item_color = "redcoat"		//Exists for washing machines. Is not different from white gloves in any way.


/obj/item/clothing/gloves/color/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "egloves"
	item_color = "captain"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 50)
