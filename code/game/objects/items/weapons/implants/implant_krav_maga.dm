/obj/item/implant/krav_maga
	name = "krav maga bio-chip"
	desc = "Teaches you the arts of Krav Maga in 5 short instructional videos beamed directly into your eyeballs."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	implant_state = "implant-default"
	origin_tech = "materials=2;biotech=4;combat=5;syndicate=4"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/krav_maga
	var/datum/martial_art/krav_maga/style = new


/obj/item/implant/krav_maga/activate(cause)
	var/mob/living/carbon/human/human_owner = imp_in
	if(!ishuman(human_owner) || !human_owner.mind)
		return
	if(istype(human_owner.mind.martial_art, /datum/martial_art/krav_maga))
		style.remove(human_owner)
	else
		style.teach(human_owner, TRUE)


/obj/item/implanter/krav_maga
	name = "bio-chip implanter (krav maga)"
	imp = /obj/item/implant/krav_maga


/obj/item/implantcase/krav_maga
	name = "bio-chip case - 'Krav Maga'"
	desc = "A glass case containing a bio-chip that can teach the user the art of Krav Maga."
	imp = /obj/item/implant/krav_maga

