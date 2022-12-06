/datum/fashion
	var/name
	var/desc
	var/emote_see
	var/emote_hear
	var/speak
	var/speak_emote

	// This isn't applied to the mob, but stores the icon_state of the
	// sprite that the associated item uses
	var/icon_file
	var/obj_icon_state
	var/icon_state
	var/icon_living
	var/icon_dead
	var/obj_alpha
	var/obj_color
	var/is_animated_fashion = FALSE

/datum/fashion/New(mob/M)
	name = replacetext(name, "REAL_NAME", M.real_name)
	desc = replacetext(desc, "NAME", name)

/datum/fashion/proc/apply(mob/living/simple_animal/D)
	if(name)
		D.name = name
	if(desc)
		D.desc = desc
	if(emote_see)
		D.emote_see = emote_see
	if(emote_hear)
		D.emote_hear = emote_hear
	if(speak)
		D.speak = speak
	if(speak_emote)
		D.speak_emote = speak_emote

/datum/fashion/proc/get_overlay(var/dir)
	if(icon_file && obj_icon_state)
		var/image/fashI = image(icon_file, obj_icon_state, dir = dir)
		fashI.alpha = obj_alpha
		fashI.color = obj_color
		return fashI
