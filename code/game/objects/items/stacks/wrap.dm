/*
 * Wrapping Paper
 */
/obj/item/stack/wrapping_paper
	name = "wrapping paper"
	desc = "Оберните подарки этой праздничной бумагой."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/stack/wrapping_paper/xmas"
	post_init_icon_state = "wrap_paper"
	greyscale_config = /datum/greyscale_config/wrap_paper
	item_flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/wrapping_paper
	singular_name = "wrapping paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/stack/wrapping_paper/Initialize(mapload)
	. = ..()
	if(!greyscale_colors)
		//Generate random valid colors for paper and ribbon
		var/generated_base_color = "#" + random_color()
		var/generated_ribbon_color = "#" + random_color()
		var/list/base_hsv = rgb2hsv(generated_base_color)
		var/list/ribbon_hsv = rgb2hsv(generated_ribbon_color)

		//If colors are too dark, set to original colors
		if(base_hsv[3] < 50)
			generated_base_color = COLOR_VIBRANT_LIME
		if(ribbon_hsv[3] < 50)
			generated_ribbon_color = COLOR_RED

		//Set layers to these colors, base then ribbon
		set_greyscale_colors(colors = list(generated_base_color, generated_ribbon_color))

/obj/item/stack/wrapping_paper/click_alt(mob/user)
	var/new_base = tgui_input_color(user, "", "Select a base color", color)
	var/new_ribbon = tgui_input_color(user, "", "Select a ribbon color", color)
	if(!new_base || !new_ribbon)
		return CLICK_ACTION_BLOCKING

	set_greyscale_colors(colors = list(new_base, new_ribbon))
	return CLICK_ACTION_SUCCESS

//preset wrapping paper meant to fill the original color configuration
/obj/item/stack/wrapping_paper/xmas
	greyscale_colors = "#00FF00#FF0000"

/obj/item/stack/wrapping_paper/get_ru_names()
	return list(
		NOMINATIVE = "обёрточная бумага",
		GENITIVE = "обёрточной бумаги",
		DATIVE = "обёрточной бумаге",
		ACCUSATIVE = "обёрточную бумагу",
		INSTRUMENTAL = "обёрточной бумагой",
		PREPOSITIONAL = "обёрточной бумаге"
	)

/obj/item/stack/wrapping_paper/attack_self(mob/user)
	to_chat(user, span_notice("Её нужно использовать на уже упакованной посылке!"))
