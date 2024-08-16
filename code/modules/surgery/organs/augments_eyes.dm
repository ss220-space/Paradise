/obj/item/organ/internal/cyberimp/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality."
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = INTERNAL_ORGAN_EYE_SIGHT_DEVICE
	parent_organ_zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY

	var/vision_flags = 0
	var/see_in_dark = 0
	var/see_invisible = 0
	var/lighting_alpha

	var/eye_colour = "#000000" // Should never be null
	var/old_eye_colour = "#000000"
	var/flash_protect = FLASH_PROTECTION_NONE
	var/aug_message = "Your vision is augmented!"

/obj/item/organ/internal/cyberimp/eyes/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/mob/living/carbon/human/H = M
	if(istype(H) && eye_colour)
		H.update_body() //Apply our eye colour to the target.
	if(aug_message && !special)
		to_chat(owner, span_notice("[aug_message]"))
	M.update_sight()

/obj/item/organ/internal/cyberimp/eyes/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M.update_sight()

/obj/item/organ/internal/cyberimp/eyes/proc/generate_icon(mob/living/carbon/human/HA)
	var/mob/living/carbon/human/H = HA
	if(!istype(H))
		H = owner
	var/icon/cybereyes_icon = new /icon('icons/mob/human_face.dmi', H.dna.species.eyes)
	cybereyes_icon.Blend(eye_colour, ICON_ADD) // Eye implants override native DNA eye color

	return cybereyes_icon

/obj/item/organ/internal/cyberimp/eyes/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(severity > 1)
		if(prob(10 * severity))
			return
	to_chat(owner, span_warning("Static obfuscates your vision!"))
	owner.flash_eyes(3, visual = TRUE)

/obj/item/organ/internal/cyberimp/eyes/meson
	name = "Meson scanner implant"
	desc = "These cybernetic eyes will allow you to see the structural layout of the station, and, well, everything else."
	eye_colour = "#199900"
	icon_state = "mesonhud_implant"
	origin_tech = "materials=4;engineering=4;biotech=4;magnets=4"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	aug_message = "Suddenly, you realize how much of a mess the station really is..."

/obj/item/organ/internal/cyberimp/eyes/xray
	name = "X-ray implant"
	desc = "These cybernetic eye implants will give you X-ray vision. Blinking is futile."
	implant_color = "#000000"
	origin_tech = "materials=4;programming=4;biotech=7;magnets=4"
	vision_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/organ/internal/cyberimp/eyes/thermals
	name = "Thermals implant"
	desc = "These cybernetic eye implants will give you Thermal vision. Vertical slit pupil included."
	icon_state = "thermal_implant"
	eye_colour = "#FFCC00"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE
	origin_tech = "materials=5;programming=4;biotech=4;magnets=4"
	aug_message = "You see prey everywhere you look..."

/obj/item/organ/internal/cyberimp/eyes/thermals/empproof/emp_act(severity)
	return

// HUD implants
/obj/item/organ/internal/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = INTERNAL_ORGAN_EYE_HUD_DEVICE
	var/HUDType = 0
	/// A list of extension kinds added to the examine text. Things like medical or security records.
	var/examine_extensions = EXAMINE_HUD_NONE

/obj/item/organ/internal/cyberimp/eyes/hud/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(HUDType)
		var/datum/atom_hud/H = GLOB.huds[HUDType]
		H.add_hud_to(M)

/obj/item/organ/internal/cyberimp/eyes/hud/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(HUDType)
		var/datum/atom_hud/H = GLOB.huds[HUDType]
		H.remove_hud_from(M)

/obj/item/organ/internal/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	icon_state = "medhud_implant"
	eye_colour = "#0000D0"
	origin_tech = "materials=4;programming=4;biotech=4"
	aug_message = "You suddenly see health bars floating above people's heads..."
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	name = "Diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see."
	icon_state = "diagnosticalhud_implant"
	eye_colour = "#723E02"
	origin_tech = "materials=4;engineering=4;biotech=4"
	aug_message = "You see the diagnostic information of the synthetics around you..."
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/organ/internal/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	icon_state = "sechud_implant"
	eye_colour = "#D00000"
	origin_tech = "materials=4;programming=4;biotech=3;combat=3"
	aug_message = "Job indicator icons pop up in your vision. That is not a certified surgeon..."
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE

/obj/item/organ/internal/cyberimp/eyes/hud/science
	name = "Science HUD implant"
	desc = "These cybernetic eye implants with an analyzer for scanning items and reagents."
	icon_state = "sciencehud_implant"
	item_state = "sciencehud_implant"
	implant_overlay = null
	eye_colour = "#923DAC"
	origin_tech = "materials=4;programming=4;biotech=4"
	aug_message = "You see the technological nature of things around you."
	examine_extensions = EXAMINE_HUD_SCIENCE
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

// Welding shield implant
/obj/item/organ/internal/cyberimp/eyes/shield
	name = "welding shield implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	icon_state = "welding_implant"
	slot = INTERNAL_ORGAN_EYE_SHIELD_DEVICE
	origin_tech = "materials=4;biotech=3;engineering=4;plasmatech=3"
	flash_protect = FLASH_PROTECTION_WELDER
	// Welding with thermals will still hurt your eyes a bit.

/obj/item/organ/internal/cyberimp/eyes/shield/emp_act(severity)
	return
