/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"
	pass_flags = PASSTABLE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat= 5, /obj/item/stack/sheet/animalhide/xeno = 1)
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/caste = ""
	var/alt_icon = 'icons/mob/alienleap.dmi' //used to switch between the two alien icon files.
	var/next_attack = 0
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 3 SECONDS
	var/leap_on_click = FALSE


//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	if(name == "alien")
		name = text("alien ([rand(1, 1000)])")
	real_name = name
	add_language(LANGUAGE_XENOS)
	add_language(LANGUAGE_HIVE_XENOS)
	..()
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/regurgitate)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 0.5, -11)
	update_icons()


// Determines if mob has and can use his hands like a human
/mob/living/carbon/alien/humanoid/real_human_being()
	return TRUE


///mob/living/carbon/alien/humanoid/bullet_act(var/obj/item/projectile/Proj) taken care of in living

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/ex_act(severity)
	..()

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			gib()
			return

		if(2.0)
			if(!shielded)
				b_loss += 60

			f_loss += 60

			AdjustDeaf(120 SECONDS)
		if(3.0)
			b_loss += 30
			if(prob(50) && !shielded)
				Paralyse(2 SECONDS)
			AdjustDeaf(60 SECONDS)

	take_overall_damage(b_loss, f_loss)


/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)
	user.set_machine(src)

	var/dat = {"<meta charset="UTF-8"><table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_HAND_LEFT]'>[(l_hand && !(l_hand.item_flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_HAND_RIGHT]'>[(r_hand && !(r_hand.item_flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	// No need to even show this right now since its unused.

	/*dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_HEAD]'>[(head && !(head.item_flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_CLOTH_OUTER]'>[(wear_suit && !(wear_suit.item_flags&ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A></td></tr>"*/

	dat += "<tr><td><B>Chitin pouches:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_POCKET_LEFT]'>"
	if(l_store && !(l_store.item_flags&ABSTRACT))
		dat += "Left (Full)"
	else
		dat += "<font color=grey>Left (Empty)</font>"

	dat += "</A>&nbsp;<A href='?src=[UID()];item=[ITEM_SLOT_POCKET_RIGHT]'>"
	if(r_store && !(r_store.item_flags&ABSTRACT))
		dat += "Right (Full)"
	else
		dat += "<font color=grey>Right (Empty)</font>"

	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[UID()];item=[ITEM_SLOT_HANDCUFFED]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=[UID()];item=[ITEM_SLOT_LEGCUFFED]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()


/mob/living/carbon/alien/humanoid/cuff_resist(obj/item/I, cuff_break = FALSE)
	playsound(src, 'sound/voice/hiss5.ogg', 40, TRUE, TRUE)  //Alien roars when starting to break free
	return ..(I, cuff_break = TRUE)


/mob/living/carbon/alien/humanoid/lying_angle_on_lying_down(new_lying_angle)
	set_lying_angle(90)	// it had to be 90, looks silly otherwise


/mob/living/carbon/alien/humanoid/get_permeability_protection()
	return 0.8


/mob/living/carbon/alien/humanoid/toggle_move_intent() //because with movement intent change our pose changes
	..()
	update_icons()


/mob/living/carbon/alien/humanoid/examine(mob/user)
	. = ..()
	if(!key)
		. += span_deadsay("[p_their(TRUE)] eyes have no spark of life.")
		. += "<BR>"

	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable/zipties))
			. += span_warning("[p_they(TRUE)] [p_are()] [bicon(handcuffed)] restrained with zipties!")
		else if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			. += span_warning("[p_they(TRUE)] [p_are()] [bicon(handcuffed)] restrained with cable!")
		else
			. += span_warning("[p_they(TRUE)] [p_are()] [bicon(handcuffed)] handcuffed!")

	if(legcuffed)
		. += span_warning("[p_they(TRUE)] [p_are()] [bicon(legcuffed)] restrained with [legcuffed]!")


/mob/living/carbon/alien/humanoid/get_equipped_items(include_pockets = FALSE, include_hands = FALSE)
	var/list/items = ..()
	if(!include_pockets)
		return items
	if(r_store)
		items += r_store
	if(l_store)
		items += l_store
	return items


/mob/living/carbon/alien/humanoid/get_equipped_slots(include_pockets = FALSE, include_hands = FALSE)
	. = ..()
	if(!include_pockets)
		return .
	if(r_store)
		. |= ITEM_SLOT_POCKET_RIGHT
	if(l_store)
		. |= ITEM_SLOT_POCKET_LEFT

