// DRONE ABILITIES
/datum/action/innate/mail_tag_drone
	name = "Set Mail Tag"
	desc = "Tag yourself for delivery through the disposals system."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/obj/device.dmi'
	button_icon_state = "dest_tagger"
	background_icon = 'icons/mob/actions/actions.dmi'
	background_icon_state = "bg_tech_blue"

/datum/action/innate/mail_tag_drone/Activate()
	var/mob/living/silicon/robot/drone/user = owner
	var/tag = tgui_input_list(user, "Select the desired destination.", "Set Mail Tag", GLOB.TAGGERLOCATIONS)

	if(!tag || GLOB.TAGGERLOCATIONS[tag])
		user.mail_destination = 0
		return

	to_chat(user, "<span class='notice'>You configure your internal beacon, tagging yourself for delivery to '[tag]'.</span>")
	user.mail_destination = GLOB.TAGGERLOCATIONS.Find(tag)

	//Auto flush if we use this verb inside a disposal chute.
	var/obj/machinery/disposal/D = user.loc
	if(istype(D))
		to_chat(user, "<span class='notice'>\The [D] acknowledges your signal.</span>")
		D.flush_count = D.flush_every_ticks
	return

//Actual picking-up event.
/mob/living/silicon/robot/drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	else
		..()

/mob/living/silicon/robot/drone/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/H = ..()
	if(!istype(H))
		return
	if(resting)
		resting = 0
	if(custom_sprite)
		H.icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		H.icon_override = 'icons/mob/custom_synthetic/custom_head.dmi'
		H.lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		H.righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		H.item_state = "[icon_state]_hand"
	else if(emagged)
		H.item_state = "drone-emagged"
	else
		H.item_state = "drone"
	grabber.put_in_active_hand(H, ignore_anim = FALSE)//for some reason unless i call this it dosen't work
	grabber.update_inv_l_hand()
	grabber.update_inv_r_hand()

	return H
