// admin spawn only

/obj/item/pen/intel_data/proc/upgrade(obj/item/uplink/U)
	if(!istype(U) || QDELETED(U))
		return

	if(U.get_intelligence_data)
		usr.balloon_alert(usr, "Уже улучшено")
		return ATTACK_CHAIN_PROCEED

	usr.balloon_alert(usr, "Улучшено")
	playsound(src, "sound/machines/boop.ogg", 50, TRUE)
	U.get_intelligence_data = TRUE
	SStgui.update_uis(U)
	qdel(src)

/obj/item/pen/intel_data/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(target != user)
		return

	for(var/obj/item/implant/uplink/uplink_imp in user)
		if(uplink_imp.imp_in != user)
			continue

		to_chat(user, span_notice("You press [src] onto yourself and upgraded [uplink_imp.hidden_uplink]."))
		upgrade(uplink_imp.hidden_uplink)
		return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/pen/intel_data/afterattack(obj/item/I, mob/user, proximity, params)
	if(!proximity)
		return

	if(istype(I) && I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
		upgrade(I.hidden_uplink)

