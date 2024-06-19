//CONTAINS: Suit fibers and Detective's Scanning Computer

/atom/var/list/suit_fibers
/atom/var/list/time_of_touch

/atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves && istype(M.gloves,/obj/item/clothing/))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(add_blood(G.blood_DNA, G.blood_color)) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands > 1)
		if(add_blood(M.blood_DNA, M.hand_blood_color))
			M.bloody_hands--
	if(!suit_fibers) suit_fibers = list()
	if(!time_of_touch) time_of_touch = list()
	var/fibertext
	var/item_multiplier = istype(src,/obj/item)?1.2:1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && M.wear_suit.can_leave_fibers)
			//log_world("Added fibertext: [fibertext]")
			if(!(fibertext in suit_fibers))
				suit_fibers += fibertext
			time_of_touch.Add("[station_time_timestamp()] — [fibertext]")
			if(time_of_touch.len > 20)
				time_of_touch -= time_of_touch[1]
		if(!(M.wear_suit.body_parts_covered & UPPER_TORSO))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12*item_multiplier) && M.w_uniform.can_leave_fibers) //Wearing a suit means less of the uniform exposed.
					//log_world("Added fibertext: [fibertext]")
					if(!(fibertext in suit_fibers))
						suit_fibers += fibertext
					time_of_touch.Add("[station_time_timestamp()] — [fibertext]")
					if(time_of_touch.len > 20)
						time_of_touch -= time_of_touch[1]
		if(!(M.wear_suit.body_parts_covered & HANDS))
			if(M.gloves)
				fibertext = "Material from a pair of [M.gloves.name]."
				if(prob(20*item_multiplier) && M.gloves.can_leave_fibers)
					//log_world("Added fibertext: [fibertext]")
					if(!(fibertext in suit_fibers))
						suit_fibers += fibertext
					time_of_touch.Add("[station_time_timestamp()] — [fibertext]")
					if(time_of_touch.len > 20)
						time_of_touch -= time_of_touch[1]
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && M.w_uniform.can_leave_fibers)
			// "Added fibertext: [fibertext]"
			if(!(fibertext in suit_fibers))
				suit_fibers += fibertext
			time_of_touch.Add("[station_time_timestamp()] — [fibertext]")
			if(time_of_touch.len > 20)
				time_of_touch -= time_of_touch[1]
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20*item_multiplier) && M.gloves.can_leave_fibers)
				//log_world("Added fibertext: [fibertext]")
				if(!(fibertext in suit_fibers))
					suit_fibers += fibertext
				time_of_touch.Add("[station_time_timestamp()] — [fibertext]")
				if(time_of_touch.len > 20)
					time_of_touch -= time_of_touch[1]
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && M.gloves.can_leave_fibers)
			//log_world("Added fibertext: [fibertext]")
			if(!(fibertext in suit_fibers))
				suit_fibers += fibertext
			time_of_touch.Add("[station_time_timestamp()] — [fibertext]")
			if(time_of_touch.len > 20)
				time_of_touch -= time_of_touch[1]
