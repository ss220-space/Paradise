/obj/item/implanter/cling_rejuv
	name = "bio-chip implanter (Rejuvenate)"
	desc = "На боку едва заметная гравировка \"Tiger Cooperative\"."
	imp = /obj/item/implant/cling_rejuv

/obj/item/implant/cling_rejuv
	name = "Rejuvenate Bio-chip"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "revive"
	implant_state = "implant-syndicate"
	origin_tech = "programming=4;biotech=4;bluespace=5;combat=3;syndicate=2"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ONCE
	implant_data = /datum/implant_fluff/cling_rejuv
	uses = 1

/obj/item/implant/cling_rejuv/death_trigger(mob/source, gibbed)
	activate()

/obj/item/implant/cling_rejuv/activate()
	uses--

	do_sparks(10, TRUE, imp_in)
	to_chat(imp_in, span_changeling("We... I have regenerated."))

	if(imp_in.pulledby)
		var/mob/living/carbon/grab_owner = imp_in.pulledby
		imp_in.visible_message(span_warning("[imp_in] suddenly hits [grab_owner] in the face and slips out of their grab!"))
		grab_owner.apply_damage(5, BRUTE, BODY_ZONE_HEAD, grab_owner.run_armor_check(BODY_ZONE_HEAD, MELEE))
		playsound(imp_in.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)
		grab_owner.stop_pulling()

	imp_in.revive()
	imp_in.updatehealth()
	imp_in.update_blind_effects()
	imp_in.update_blurry_effects()
	imp_in.UpdateAppearance()
	imp_in.set_resting(FALSE, instant = TRUE)
	imp_in.get_up(TRUE)
	imp_in.update_revive()

	imp_in.med_hud_set_status()
	imp_in.med_hud_set_health()

	investigate_log("[key_name_log(imp_in)] rejuvenated himself using [name].")

	if(!uses)
		qdel(src)
