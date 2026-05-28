/*
 * Returns:
 *	#RRGGBB(AA) on success, null on failure
 */
GLOBAL_LIST_INIT(random_color_list, list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700"))

/proc/mix_color_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/color
	var/reagent_color
	var/vol_counter = 0
	var/vol_temp
	// see libs/IconProcs/IconProcs.dm
	for(var/datum/reagent/reagent in reagent_list)
		if(reagent.id == "blood" && reagent.data && reagent.data["blood_color"])
			reagent_color = reagent.data["blood_color"]
		else
			reagent_color = reagent.color

		vol_temp = reagent.volume
		vol_counter += vol_temp

		if(isnull(color))
			color = reagent.color
		else if(length(color) >= length(reagent_color))
			color = BlendRGB(color, reagent_color, vol_temp/vol_counter)
		else
			color = BlendRGB(reagent_color, color, vol_temp/vol_counter)
	return color

/proc/get_color_matrix_from_reagents(reagents)
	var/color_str = mix_color_from_reagents(reagents)
	var/list/mixed_color = rgb2num(color_str)

	var/r = mixed_color[1] / 255
	var/g = mixed_color[2] / 255
	var/b = mixed_color[3] / 255

	return list(
		0.5, 0,   0,   0,
		0,   0.5, 0,   0,
		0,   0,   0.5, 0,
		0,   0,   0,   1,
		r, g, b, 0
	)
