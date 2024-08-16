
/mob/living/carbon/alien/larva/regenerate_icons()
	cut_overlays()
	update_icons()


/mob/living/carbon/alien/larva/update_icons()
	var/state = 0
	switch(evolution_points)
		if(-INFINITY to 50)
			state = 0
		if(51 to 150)
			state = 1
		if(151 to INFINITY)
			state = 2

	var/incapacitated = HAS_TRAIT(src, TRAIT_INCAPACITATED)
	if(stat == DEAD)
		icon_state = "larva[state]_dead"
	else if(handcuffed || legcuffed) //This should be an overlay. Who made this an icon_state?
		icon_state = "larva[state]_cuff"
	else if(!incapacitated && body_position == LYING_DOWN)
		icon_state = "larva[state]_sleep"
	else if(incapacitated)
		icon_state = "larva[state]_stun"
	else
		icon_state = "larva[state]"


/mob/living/carbon/alien/larva/update_transform() //All this is handled in update_icons()
	. = ..()
	update_icons()


/mob/living/carbon/alien/larva/lying_angle_on_lying_down(new_lying_angle)
	return // Larvas don't rotate on lying down, they have their own custom icons.

