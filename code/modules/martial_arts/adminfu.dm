/datum/martial_art/adminfu
	name = "Way of the Dancing Admin"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/adminfu/healing_palm)
	weight = 99999999

/datum/martial_art/adminfu/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	if(!D.stat)//do not kill what is dead...
		A.do_attack_animation(D)
		D.visible_message("<span class='warning'>[A] manifests a large glowing toolbox and shoves it in [D]'s chest!</span>", \
							"<spac class='userdanger'>[A] shoves a mystical toolbox in your chest!</span>")
		D.death()

		return TRUE


/datum/martial_art/adminfu/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D)
	D.Weaken(50 SECONDS)
	return TRUE

/datum/martial_art/adminfu/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A,1)
	if(G)
		G.state = GRAB_NECK
	return TRUE

/datum/martial_art/adminfu/explaination_header(user)
	to_chat(user, "<span class='notice'>Grab</span>: Automatic Neck Grab.")
	to_chat(user, "<span class='notice'>Disarm</span>: Stun/weaken")
	to_chat(user, "<span class='notice'>Harm</span>: Death.")

/obj/item/adminfu_scroll
	name = "frayed scroll"
	desc = "An aged and frayed scrap of paper written in shifting runes. There are hand-drawn illustrations of pugilism."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = FALSE


/obj/item/adminfu_scroll/update_icon_state()
	icon_state = used ? "blankscroll" : initial(icon_state)


/obj/item/adminfu_scroll/update_name(updates = ALL)
	. = ..()
	name = used ? "empty scroll" : initial(name)


/obj/item/adminfu_scroll/update_desc(updates = ALL)
	. = ..()
	desc = used ? "It's completely blank." : initial(desc)


/obj/item/adminfu_scroll/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/adminfu/F = new/datum/martial_art/adminfu(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>You have learned the ancient martial art of the Admins.</span>")
		used = TRUE
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)

