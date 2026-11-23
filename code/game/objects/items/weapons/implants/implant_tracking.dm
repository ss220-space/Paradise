/obj/item/implant/tracking
	name = "tracking bio-chip"
	desc = "Track with this."
	activated = BIOCHIP_ACTIVATED_PASSIVE
	origin_tech = "materials=2;magnets=2;programming=2;biotech=2"
	implant_data = /datum/implant_fluff/tracking
	implant_state = "implant-nanotrasen"
	/// Used to customize user gps tag.
	var/gps_tag = "TAG0"
	var/warn_cooldown = 0
	var/obj/item/gps/internal_gps = /obj/item/gps/internal/tracking_implant

/obj/item/implant/tracking/Initialize(mapload)
	. = ..()
	GLOB.tracked_implants += src

/obj/item/implant/tracking/Destroy()
	if(!ispath(internal_gps))
		QDEL_NULL(internal_gps)
	GLOB.tracked_implants -= src
	return ..()

/obj/item/implant/tracking/implant(mob/target)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/organ/internal/anchor = human_target.get_int_organ(/obj/item/organ/internal/cyberimp/chest/bluespace_anchor)
		if(anchor)
			target.visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] искр[PLUR_IT_YAT(src)] и уничтожа[PLUR_ET_YUT(src)]ся [anchor.declent_ru(INSTRUMENTAL)] внутри [human_target.declent_ru(GENITIVE)]!"))
			qdel(src)
			return FALSE
	. = ..()
	if(. && ispath(internal_gps, /obj/item/gps))
		internal_gps = new internal_gps(src)
		internal_gps.gpstag = gps_tag

/obj/item/implant/tracking/removed(mob/target)
	. = ..()
	if(.)
		QDEL_NULL(internal_gps)
		internal_gps = initial(internal_gps)

/obj/item/gps/internal/tracking_implant
	gpstag = "TRACK0"
	local = FALSE

/obj/item/implanter/tracking
	name = "bio-chip implanter (tracking)"
	imp = /obj/item/implant/tracking

/obj/item/implantcase/tracking
	name = "bio-chip case - 'Tracking'"
	desc = "A glass case containing a tracking bio-chip."
	imp = /obj/item/implant/tracking

