
/obj/item/organ/internal/cyberimp/tail
	name = "Tail-mounted implant"
	desc = "You shoudn't see this! Immediately report to a coder."
	parent_organ_zone = BODY_ZONE_TAIL
	slot = INTERNAL_ORGAN_TAIL
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/sound_on = 'sound/mecha/mechmove03.ogg'
	var/sound_off = 'sound/mecha/mechmove03.ogg'


/obj/item/organ/internal/cyberimp/tail/blade
	name = "Tail blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."
	origin_tech = "materials=3;engineering=4;biotech=3;powerstorage=4;combat=4"
	var/activated = FALSE
	implant_color = "#585857"
	var/datum/action/innate/tail_lash/implant_ability

/obj/item/organ/internal/cyberimp/tail/blade/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/obj/item/organ/internal/cyberimp/tail/blade/implant = owner.get_organ_slot(INTERNAL_ORGAN_TAIL)
	implant_ability = new(src)
	implant.implant_ability.Grant(owner)

/obj/item/organ/internal/cyberimp/tail/blade/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	var/obj/item/organ/internal/cyberimp/tail/blade/implant = owner.get_organ_slot(INTERNAL_ORGAN_TAIL)
	implant.implant_ability.Remove(owner)
	implant.implant_ability = null
	. = ..()

/obj/item/organ/internal/cyberimp/tail/blade/ui_action_click(mob/user, actiontype, leftclick)
	activated = !activated
	if(activated)

		to_chat(owner, span_notice("You pulled the blades out of your tail."))
	else

		to_chat(owner, span_notice("You retract your tail blades"))

/obj/item/organ/internal/cyberimp/tail/blade/lazer
	name = "Tail lazer blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."

/obj/item/organ/internal/cyberimp/tail/blade/lazer/syndi
	name = "Tail lazer blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."


