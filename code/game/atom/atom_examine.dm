/**
 * Called when a mob examines this atom: [/mob/verb/examinate]
 *
 * Default behaviour is to get the name and icon of the object and its reagents where
 * the [TRANSPARENT] flag is set on the reagents holder
 *
 * Produces a signal [COMSIG_ATOM_EXAMINE], for modifying the list returned from this proc
 */
/atom/proc/examine(mob/user)
	. = list()
	. += get_name_chaser(user)

	if(desc)
		. += desc

	var/list/tags_list = examine_tags(user)
	var/list/post_descriptor = examine_post_descriptor(user)
	var/post_desc_string = length(post_descriptor) ? " [jointext(post_descriptor, " ")]" : ""
	if(length(tags_list))
		var/tag_string = list()
		for(var/atom_tag in tags_list)
			tag_string += (isnull(tags_list[atom_tag]) ? atom_tag : span_tooltip(tags_list[atom_tag], atom_tag))
		// some regex to ensure that we don't add another "and" if the final element's main text (not tooltip) has one
		tag_string = russian_list(tag_string, and_text = (findtext(tag_string[length(tag_string)], regex(@">.*?и .*?<"))) ? " " : " и ")
		. += "Это [tag_string] [examine_descriptor(user)][post_desc_string]."
	else if(post_desc_string)
		. += "Это [examine_descriptor(user)][post_desc_string]."

	if(reagents)
		if(container_type & TRANSPARENT)
			. += span_notice("Содержимое:")
			if(length(reagents.reagent_list))
				if(user.can_see_reagents()) //Show each individual reagent
					for(var/I in reagents.reagent_list)
						var/datum/reagent/R = I
						. += span_notice("<b>[R.name]</b> - <b>[R.volume]</b> единиц[declension_ru(R.volume, "а", "ы", "")].")
				else //Otherwise, just show the total volume
					if(reagents && length(reagents.reagent_list))
						. += span_notice("<b>[reagents.total_volume]</b> единиц[declension_ru(reagents.total_volume, "а", "ы", "")] вещества.")
			else
				. += span_notice("Ничего.")
		else if(container_type & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				. += span_notice("Осталось ещё <b>[reagents.total_volume]</b> единиц[declension_ru(reagents.total_volume, "а", "ы", "")] вещества.")
			else
				. += span_danger("Внутри ничего нет.")

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/**
 * A list of "tags" displayed after atom's description in examine.
 * This should return an assoc list of tags -> tooltips for them. If item is null, then no tooltip is assigned.
 *
 * * TGUI tooltips (not the main text) in chat cannot use HTML stuff at all, so
 * trying something like `<b><big>ffff</big></b>` will not work for tooltips.
 *
 * For example:
 * ```byond
 * . = list()
 * .["small"] = "It is a small item."
 * .["fireproof"] = "It is made of fire-retardant materials."
 * .["and conductive"] = "It's made of conductive materials and whatnot. Blah blah blah." // having "and " in the end tag's main text/key works too!
 * ```
 * will result in
 *
 * It is a *small*, *fireproof* *and conductive* item.
 *
 * where "item" is pulled from [/atom/proc/examine_descriptor]
 */
/atom/proc/examine_tags(mob/user)
	. = list()
	if(abstract_type == type)
		.[span_hypnophrase("abstract")] = "Это абстрактный концепт, который вы не должны были увидеть! Сообщите об этом Высшим Силам!"

	if(resistance_flags & INDESTRUCTIBLE)
		.["неразрушим[genderize_examine_descriptor("ый", "ая")]"] = "Чрезвычайно прочн[genderize_examine_descriptor("ый", "ая")]! Уничтожить практически невозможно."
	else
		if(resistance_flags & LAVA_PROOF)
			.["лавастойк[genderize_examine_descriptor("ий", "ая")]"] = "Чрезвычайно устойчив[genderize_examine_descriptor("ый", "ая")] к экстремальным температурам! Может выдержать даже воздействие лавы!"
		if(resistance_flags & (ACID_PROOF | UNACIDABLE))
			.["кислотостойк[genderize_examine_descriptor("ий", "ая")]"] = "Выглядит очень прочным. Ни одна кислота такое не разъест."
		if(resistance_flags & FREEZE_PROOF)
			.["морозостойк[genderize_examine_descriptor("ий", "ая")]"] = "Сделано из морозостойких материалов."
		if(resistance_flags & FIRE_PROOF)
			.["огнеупорн[genderize_examine_descriptor("ый", "ая")]"] = "Сделано из огнеупорных материалов."
		if(resistance_flags & FLAMMABLE)
			.["легковоспламеняющ[genderize_examine_descriptor("ий", "ая")]ся"] = "Может легко загореться."

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_TAGS, user, .)

/// What this atom should be called in examine tags
/atom/proc/examine_descriptor(mob/user)
	return "объект"

/// Gender of the examine descriptor word
/// For example, "объект" is "male", while "машинерия" is "female"
/atom/proc/examine_descriptor_gender()
	return "male"

/// Returns the correct form of the examine descriptor based on provided gender
/atom/proc/genderize_examine_descriptor(male_word, female_word, gender)
	if(!gender)
		gender = examine_descriptor_gender()
	return gender == "male" ? male_word : female_word

/// Returns a list of strings to be displayed after the descriptor
/// TODO: имплементировать тута custom_materials
/atom/proc/examine_post_descriptor(mob/user)
	return

/**
 * Called when a mob examines (shift click or verb) this atom twice (or more) within EXAMINE_MORE_WINDOW (default 1 second)
 *
 * This is where you can put extra information on something that may be superfluous or not important in critical gameplay
 * moments, while allowing people to manually double-examine to take a closer look
 *
 * Produces a signal [COMSIG_ATOM_EXAMINE_MORE]
 */
/atom/proc/examine_more(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_MORE, user, .)
	SEND_SIGNAL(user, COMSIG_MOB_EXAMINING_MORE, src, .)

/**
 * Get the name of this object for examine
 *
 * You can override what is returned from this proc by registering to listen for the
 * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
 */
/atom/proc/get_examine_name(mob/user)
	var/list/override = list(null, "<em>[get_visible_name()]</em>")
	SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override)

	if(!isnull(override[EXAMINE_POSITION_BEFORE]))
		override -= null // There is no article, don't try to join it
		return "\a [jointext(override, " ")]"
	return "[declent_ru(NOMINATIVE)]"

/mob/living/get_examine_name(mob/user)
	var/visible_name = get_visible_name()
	var/list/name_override = list(visible_name)
	if(SEND_SIGNAL(user, COMSIG_LIVING_PERCEIVE_EXAMINE_NAME, src, visible_name, name_override) & COMPONENT_EXAMINE_NAME_OVERRIDEN)
		return name_override[1]
	return visible_name

/// Icon displayed in examine
/atom/proc/get_examine_icon(mob/user)
	return icon2html(src, user)

/**
 * Formats the atom's name into a string for use in examine (as the "title" of the atom)
 *
 * * user - the mob examining the atom
 * * thats - whether to include "Это" or not
 */
/atom/proc/examine_title(mob/user, thats = FALSE)
	var/examine_icon = get_examine_icon(user)
	return "[examine_icon ? "[examine_icon] " : ""][thats ? "[examine_thats] ":""]<em>[get_examine_name(user)]</em>"

/// Used to insert text after the name but before the description in examine()
/atom/proc/get_name_chaser(mob/user, list/name_chaser = list())
	return name_chaser

/**
 * Used by mobs to determine the name for someone wearing a mask, or with a disfigured or missing face.
 * By default just returns the atom's name.
 *
 * * add_id_name - If TRUE, ID information such as honorifics or name (if mismatched) are appended
 * * force_real_name - If TRUE, will always return real_name and add (as face_name/id_name) if it doesn't match their appearance
 */
/atom/proc/get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
	return name
