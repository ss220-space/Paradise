/*	This code is responsible for the examine tab.  When someone examines something, it copies the examined object's description_info,
	description_fluff, and description_antag, and shows it in a new tab.

	In this file, some atom and mob stuff is defined here.  It is defined here instead of in the normal files, to keep the whole system self-contained.
	This means that this file can be unchecked, along with the other examine files, and can be removed entirely with no effort.
*/


/atom/
	var/description_info = null //Helpful blue text.
	var/ru_description_info
	var/description_fluff = null //Green text about the atom's fluff, if any exists.
	var/ru_description_fluff
	var/description_antag = null //Malicious red text, for the antags.
	var/ru_description_antag

//Override these if you need special behaviour for a specific type.
/atom/proc/get_description_info(translation)
	if(description_info)
		if(translation == "ru" && ru_description_info)
			return ru_description_info
		else
			return description_info
	return

/atom/proc/get_description_fluff(translation)
	if(description_fluff)
		if(translation == "ru" && ru_description_fluff)
			return ru_description_fluff
		else
			return description_fluff
	return

/atom/proc/get_description_antag(translation)
	if(description_antag)
		if(translation == "ru" && ru_description_antag)
			return ru_description_antag
		else
			return description_antag
	return

/mob/living/get_description_fluff()
	if(flavor_text) //Get flavor text for the green text.
		return flavor_text
	else //No flavor text?  Try for hardcoded fluff instead.
		return ..()

/mob/living/carbon/human/get_description_fluff()
	return print_flavor_text()

/* The examine panel itself */

/client/var/description_holders[0]

/client/proc/update_description_holders(atom/A, update_antag_info=0)
	description_holders["info"] = A.get_description_info()
	description_holders["fluff"] = A.get_description_fluff()
	description_holders["antag"] = (update_antag_info)? A.get_description_antag() : ""

	description_holders["name"] = "[A.name]"
	description_holders["icon"] = "\icon[A]" //"[bicon(A)]"
	description_holders["desc"] = A.desc

	if(check_locale(src) == "ru")
		description_holders["info"] = A.get_description_info("ru")
		description_holders["fluff"] = A.get_description_fluff("ru")
		description_holders["antag"] = (update_antag_info)? A.get_description_antag("ru") : ""

		description_holders["name"] = "[A.declent_ru(NOMINATIVE)]"
		description_holders["icon"] = "\icon[A]" //"[bicon(A)]"
		description_holders["desc"] = A.ru_desc || A.desc

/client/Stat()
	. = ..()
	if(usr && statpanel("Examine"))
		stat(null,"[description_holders["icon"]]    <font size='5'>[description_holders["name"]]</font>") //The name, written in big letters.
		stat(null,"[description_holders["desc"]]") //the default examine text.
		if(description_holders["info"])
			stat(null,"<font color='#084B8A'><b>[description_holders["info"]]</b></font>") //Blue, informative text.
		if(description_holders["fluff"])
			stat(null,"<font color='#298A08'><b>[description_holders["fluff"]]</b></font>") //Yellow, fluff-related text.
		if(description_holders["antag"])
			stat(null,"<font color='#8A0808'><b>[description_holders["antag"]]</b></font>") //Red, malicious antag-related text
