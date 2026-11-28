/// Causes a fake "electric shock" to the hallucinator.
/datum/hallucination/shock
	random_hallucination_weight = 2
	hallucination_tier = HALLUCINATION_TIER_RARE

	var/electrocution_icon = 'icons/mob/human.dmi'
	var/electrocution_icon_state = "electrocuted_base"
	var/image/electrocution_skeleton_anim

/datum/hallucination/shock/New(mob/living/hallucinator)
	electrocution_icon_state = ishuman(hallucinator) ? "electrocuted_base" : "electrocuted_generic"
	return ..()

/datum/hallucination/shock/Destroy()
	if(electrocution_skeleton_anim)
		hallucinator.client?.images -= electrocution_skeleton_anim
		electrocution_skeleton_anim = null

	return ..()

/datum/hallucination/shock/start()
	electrocution_skeleton_anim = image(electrocution_icon, hallucinator, icon_state = electrocution_icon_state, layer = ABOVE_MOB_LAYER)
	electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART

	SET_PLANE_EXPLICIT(electrocution_skeleton_anim, ABOVE_GAME_PLANE, hallucinator)

	to_chat(hallucinator, span_userdanger("Вы чувствуете мощный разряд, пронзающий ваше тело!"))
	hallucinator.visible_message(span_warning("[hallucinator] падает на землю, сотрясаясь!"), ignored_mobs = hallucinator)
	hallucinator.client?.images |= electrocution_skeleton_anim

	hallucinator.playsound_local(get_turf(src), SFX_SPARKS, 100, TRUE)
	hallucinator.adjustStaminaLoss(50)
	hallucinator.Stun(4 SECONDS)
	hallucinator.do_jitter_animation(300)

	addtimer(CALLBACK(src, PROC_REF(reset_shock_animation)), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(shock_drop)), 2 SECONDS)
	QDEL_IN(src, 4 SECONDS)
	return TRUE

/datum/hallucination/shock/proc/reset_shock_animation()
	if(QDELETED(hallucinator))
		return

	hallucinator.client?.images -= electrocution_skeleton_anim
	electrocution_skeleton_anim = null

/datum/hallucination/shock/proc/shock_drop()
	if(QDELETED(hallucinator))
		return

	hallucinator.AdjustParalysis(6 SECONDS)
