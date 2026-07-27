///DREAMS

/mob/living/carbon/proc/dream()
	// Additive heretic hook: a listener (the heretic antag datum) may supply a complete replacement
	// dream sequence - if it does, play that narrative in order instead of the random dream pool.
	var/list/special_dreams = list()
	SEND_SIGNAL(src, COMSIG_GET_DREAMS, special_dreams)
	if(length(special_dreams))
		for(var/i in 1 to length(special_dreams))
			dreaming++
			addtimer(CALLBACK(src, PROC_REF(experience_dream), special_dreams[i], FALSE), ((i - 1) * rand(30, 60)))
		return TRUE

	var/list/dreams = custom_dreams(GLOB.dream_strings, src)

	for(var/obj/item/bedsheet/sheet in loc)
		dreams += sheet.dream_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(dreams)
		dreaming++
	for(var/i in 1 to length(dream_images))
		addtimer(CALLBACK(src, PROC_REF(experience_dream), dream_images[i], FALSE), ((i - 1) * rand(30,60)))
	return TRUE

/mob/living/carbon/proc/custom_dreams(list/dreamlist, mob/user)
	var/list/newlist = dreamlist.Copy()
	for(var/i in 1 to length(newlist))
		newlist[i] = replacetext(newlist[i], "\[DREAMER\]", "[user.real_name]")
	return newlist

//NIGHTMARES
/mob/living/carbon/proc/nightmare()
	var/list/nightmares = custom_dreams(GLOB.nightmare_strings, src)

	for(var/obj/item/bedsheet/sheet in loc)
		nightmares += sheet.nightmare_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(nightmares)
		nightmare++
	for(var/i in 1 to length(dream_images))
		addtimer(CALLBACK(src, PROC_REF(experience_dream), dream_images[i], TRUE), ((i - 1) * rand(30,60)))
	return TRUE

/mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(5))
		dream()
	else if(client && !nightmare && prob(2))
		nightmare()
		if(ishuman(src) && prob(10))
			emote("nightmare")

/mob/living/carbon/proc/experience_dream(dream_image, isNightmare)
	if(dreaming > 0 && !isNightmare)
		dreaming--
	if(nightmare > 0 && isNightmare)
		nightmare--
	if(stat != UNCONSCIOUS || InCritical())
		return
	if(isNightmare)
		dream_image = span_cultitalic("[dream_image]")
	to_chat(src, span_notice("<i>... [dream_image] ...</i>"))
