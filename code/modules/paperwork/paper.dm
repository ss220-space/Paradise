/*
 * Paper
 * also scraps of paper
 */

/obj/item/paper
	name = "paper"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = 4
	pressure_resistance = 0
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	blocks_emissive = FALSE
	attack_verb = list("стукнул")
	permeability_coefficient = 0.01
	dog_fashion = /datum/dog_fashion/head
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/header //Above the main body, displayed at the top
	var/info		//What's actually written on the paper.
	var/footer 	//The bottom stuff before the stamp but after the body
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields = 0		//Amount of user created fields
	var/language = LANGUAGE_GALACTIC_COMMON //The language of paper. For now using only in case of Thetta
	var/list/stamped
	///Prevents stamp overflow
	var/stamp_limit = 20
	var/list/stamp_overlays
	var/rigged = 0
	var/spam_flag = 0
	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0
	var/contact_poison_poisoner = null
	var/paper_width = 400 //Width of the window that opens
	var/paper_width_big = 600
	var/paper_height = 400 //Height of the window that opens
	var/paper_height_big = 700

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"
	var/time = "00:00"

//lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!

/obj/item/paper/Initialize(mapload)
	. = ..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	base_pixel_x = pixel_x
	base_pixel_y = pixel_y

	spawn(2)
		update_icon()
		updateinfolinks()


/obj/item/paper/update_icon_state()
	icon_state = "paper[info ? "_words" : ""]"


/obj/item/paper/update_overlays()
	return LAZYCOPY(stamp_overlays)


/obj/item/paper/examine(mob/user)
	. = ..()
	. += "<span class='info'><b>Alt-Click</b> the [initial(name)] with a pen in hand to rename it.</span>"
	if(user.is_literate())
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			show_content(user)
		else
			. += "<span class='notice'>You have to go closer if you want to read it.</span>"
	else
		. += "<span class='notice'>You don't know how to read.</span>"


/obj/item/paper/proc/show_content(mob/user, forceshow = FALSE, forcestars = FALSE, infolinks, view = TRUE)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	var/data
	var/stars = (!user.say_understands(null, GLOB.all_languages[language]) && !forceshow) || forcestars
	if(stars) //assuming all paper is written in common is better than hardcoded type checks
		data = "[header][stars(info)][footer][stamps]"
	else
		data = "[header]<div id='markdown'>[infolinks ? info_links : info]</div>[footer][stamps]"
	if(CONFIG_GET(flag/twitch_censor))
		for(var/char in GLOB.twitch_censor_list)
			data = replacetext(data, char, GLOB.twitch_censor_list[char])
	if(view)
		if(!istype(src, /obj/item/paper/form) && length(info) > 1024)
			paper_width = paper_width_big
			paper_height = paper_height_big
		var/datum/browser/popup = new(user, "Paper[UID()]", , paper_width, paper_height)
		popup.include_default_stylesheet = FALSE
		popup.set_content(data)
		if(!stars)
			popup.add_script("marked.js", 'html/browser/marked.js')
			popup.add_script("marked-paradise.js", 'html/browser/marked-paradise.js')
		popup.add_head_content("<title>[name]</title>")
		popup.open()
	return data


/obj/item/paper/click_alt(mob/living/carbon/human/user)
	if(is_pen(user.get_active_hand()))
		rename(user)
		return CLICK_ACTION_SUCCESS
	if(user.is_in_hands(src))
		ProcFoldPlane(user, src)
		return CLICK_ACTION_SUCCESS


/obj/item/paper/proc/rename(mob/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>You cut yourself on the paper.</span>")
		return
	if(!user.is_literate())
		to_chat(user, "<span class='notice'>You don't know how to read.</span>")
		return
	var/n_name = rename_interactive(user)
	if(isnull(n_name))
		return
	if(n_name != "")
		desc = "This is a paper titled '" + name + "'."
	else
		desc = initial(desc)
	add_fingerprint(user)


/obj/item/paper/attack_self(mob/living/user as mob)
	user.examinate(src)
	if(rigged && !spam_flag && (SSholiday.holidays && SSholiday.holidays[APRIL_FOOLS]))
		spam_flag = TRUE
		addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), 3 SECONDS)
		playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)


/obj/item/paper/attack_ai(mob/living/silicon/ai/user)
	var/dist
	if(isAI(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		show_content(user, forceshow = TRUE)
	else
		show_content(user, forcestars = TRUE)


/obj/item/paper/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
		return .

	switch(user.zone_selected)
		if(BODY_ZONE_PRECISE_EYES)
			user.visible_message(
				span_warning("[user] is trying to show the paper to you."),
				span_notice("You hold up a paper and try to show it to [target]."),
			)
			if(!do_after(user, 0.7 SECONDS, target, NONE))
				to_chat(user, span_warning("You fail to show the paper to [target]."))
				return .
			user.visible_message(
				span_notice("[user] shows the paper to you."),
				span_notice("You hold up a paper and show it to [target]."),
			)
			target.examinate(src)

		if(BODY_ZONE_PRECISE_MOUTH)
			if(target == user)
				to_chat(user, span_notice("You wipe off your face with [src]."))
			else
				user.visible_message(
					span_warning("[user] starts to wipe [target]'s face clean with [src]."),
					span_notice("You start to wipe off [target]'s face."),
				)
				if(!do_after(user, 1 SECONDS, target))
					return .
				user.visible_message(
					span_notice("[user] wipes [target]'s face clean with [src]."),
					span_notice("You wipe off [target]'s face."),
				)
			target.lip_style = null
			target.lip_color = null
			target.update_body()


/obj/item/paper/attack_animal(mob/living/simple_animal/pet/dog/doggo)
	if(!isdog(doggo)) // Only dogs can eat homework.
		return
	doggo.changeNext_move(CLICK_CD_MELEE)
	if(world.time < doggo.last_eaten + 30 SECONDS)
		to_chat(doggo, "<span class='warning'>You are too full to try eating [src] now.</span>")
		return

	doggo.visible_message("<span class='warning'>[doggo] starts chewing the corner of [src]!</span>",
		"<span class='notice'>You start chewing the corner of [src].</span>",
		"<span class='warning'>You hear a quiet gnawing, and the sound of paper rustling.</span>")
	playsound(src, 'sound/effects/pageturn2.ogg', 100, TRUE)
	if(!do_after(doggo, 10 SECONDS, src, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		return

	if(world.time < doggo.last_eaten + 30 SECONDS) // Check again to prevent eating multiple papers at once.
		to_chat(doggo, "<span class='warning'>You are too full to try eating [src] now.</span>")
		return
	doggo.last_eaten = world.time

	// 90% chance of a crumpled paper with illegible text.
	if(prob(90))
		var/message_ending = "."
		var/obj/item/paper/crumpled/crumped = new(loc)
		crumped.name = name
		if(info) // Something written on the paper.
			crumped.info = "<i>Whatever was once written here has been made completely illegible by a combination of chew marks and saliva.</i>"
			message_ending = ", the drool making it an unreadable mess!"
		crumped.update_icon()
		qdel(src)

		doggo.visible_message("<span class='warning'>[doggo] finishes eating [src][message_ending]</span>",
			"<span class='notice'>You finish eating [src][message_ending]</span>")
		doggo.emote("bark")

	// 10% chance of the paper just being eaten entirely.
	else
		doggo.visible_message("<span class='warning'>[doggo] swallows [src] whole!</span>", "<span class='notice'>You swallow [src] whole. Tasty!</span>")
		playsound(doggo, 'sound/items/eatfood.ogg', 50, TRUE)
		qdel(src)


/obj/item/paper/proc/addtofield(id, text, links = 0)
	if(id > MAX_PAPER_FIELDS)
		return

	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(locid <= MAX_PAPER_FIELDS)
		var/istart = 0
		if(links)
			istart = findtext_char(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext_char(info, "<span class=\"paper_field\">", laststart)

		if(!istart)
			return // No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext_char(info_links, "</span>", istart)
			else
				iend = findtext_char(info, "</span>", istart)

			textindex = iend
			break

	if(links)
		var/before = copytext_char(info_links, 1, textindex)
		var/after = copytext_char(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext_char(info, 1, textindex)
		var/after = copytext_char(info, textindex)
		info = before + text + after
		updateinfolinks()


/obj/item/paper/proc/updateinfolinks()
	info_links = info
	for(var/i in 1 to fields)
		var/write_1 = "<font face=\"[deffont]\"><a href='byond://?src=[UID()];write=[i]'>write</a></font>"
		var/write_2 = "<font face=\"[deffont]\"><a href='byond://?src=[UID()];auto_write=[i]'><span style=\"color: #409F47; font-size: 10px\">\[a\]</span></a></font>"
		addtofield(i, "[write_1][write_2]", 1)
	info_links = info_links + "<font face=\"[deffont]\"><a href='byond://?src=[UID()];write=end'>write</a></font>" + "<font face=\"[deffont]\"><a href='byond://?src=[UID()];auto_write=end'><span style=\"color: #409F47; font-size: 10px\">\[A\]</span></a></font>"


/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	LAZYNULL(stamped)
	LAZYNULL(stamp_overlays)
	updateinfolinks()
	update_icon()


/obj/item/paper/proc/parsepencode(t, obj/item/pen/P, mob/user as mob)
	t = pencode_to_html(html_encode(t), usr, P, TRUE, TRUE, TRUE, deffont, signfont, crayonfont)
	return t

/obj/item/paper/proc/populatefields()
	//Count the fields
	var/laststart = 1
	while(fields < MAX_PAPER_FIELDS)
		var/i = findtext_char(info, "<span class=\"paper_field\">", laststart)
		if(!i)
			break
		laststart = i+1
		fields++


/obj/item/paper/proc/openhelp(mob/user)
	var/datum/browser/popup = new(user, "paper_help", "Pen Help")
	popup.set_content({"
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[h1\] - \[/h1\] : Makes the text a first level heading<br>
		\[h2\] - \[/h2\] : Makes the text a second level heading<br>
		\[h3\] - \[/h3\] : Makes the text a third level heading<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.
		\[time\] : Inserts the current station time in HH:MM:SS.<br>"})
	popup.open(FALSE)


/obj/item/paper/proc/topic_href_write(mob/user, id, input_element)
	var/obj/item/item_write = user.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
	add_hiddenprint(user) // No more forging nasty documents as someone else, you jerks
	if(!is_pen(item_write) && !istype(item_write, /obj/item/toy/crayon))
		return
	if(loc != user && !Adjacent(user, recurse = 2) && !loc.Adjacent(user))
		return // If paper is not in usr, then it must be near them

	input_element = parsepencode(input_element, item_write, user) // Encode everything from pencode to html

	if(QDELETED(src) || !loc || (loc != user && !Adjacent(user, recurse = 2) && !loc.Adjacent(user)))
		return

	if(id != "end")
		addtofield(text2num(id), input_element) // He wants to edit a field, let him.
	else
		info += input_element // Oh, he wants to edit to the end of the file, let him.

	populatefields()
	updateinfolinks()
	item_write.on_write(src, user)
	show_content(user, forceshow = TRUE, infolinks = TRUE)
	update_icon()


/obj/item/paper/Topic(href, href_list)
	..()
	if(!usr || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(href_list["auto_write"])
		var/id = href_list["auto_write"]

		var/const/sign_text = "\[Поставить подпись\]"
		var/const/account_text = "\[Написать номер аккаунта\]"
		var/const/pin_text = "\[Написать пин-код\]"
		var/const/time_text = "\[Написать текущее время\]"
		var/const/date_text = "\[Написать текущую дату\]"
		var/const/station_text = "\[Написать название станции\]"
		var/const/gender_text = "\[Указать пол\]"
		var/const/species_text = "\[Указать расу\]"

		var/list/menu_list = list()	// text items in the menu

		menu_list.Add(usr.real_name)	// the real name of the character, even if it is hidden

		if(usr.real_name != usr.name && lowertext(usr.name) != "unknown")	// if the player is masked or the name is different a new answer option is added
			menu_list.Add(usr.name)

		if(usr.job)
			menu_list.Add(usr.job)	// job

		menu_list.Add(sign_text)	//signature

		if(usr.mind?.initial_account?.account_number)
			menu_list.Add(account_text)	// account number

		if(usr.mind?.initial_account?.remote_access_pin)
			menu_list.Add(pin_text)	// account pin-code

		menu_list.Add(
			time_text,		// time
			date_text,		// date
			station_text,	// station name
			gender_text,	// gender
		)

		if(usr.dna?.species)
			menu_list.Add(species_text)	//current

		var/input_element = input("Выберите текст который хотите добавить:", "Выбор пункта") as null|anything in menu_list
		if(!input_element)
			return

		switch(input_element)	//format selected menu items in pencode and internal data
			if(sign_text)
				input_element = "\[sign\]"
			if(time_text)
				input_element = "\[time\]"
			if(date_text)
				input_element = "\[date\]"
			if(station_text)
				input_element = "\[station\]"
			if(account_text)
				input_element = usr.mind.initial_account.account_number
			if(pin_text)
				input_element = usr.mind.initial_account.remote_access_pin
			if(gender_text)
				input_element = usr.gender
			if(species_text)
				input_element = usr.dna.species

		topic_href_write(usr, id, input_element)

	if(href_list["write"] )
		var/id = href_list["write"]																			/* Becаuse HTML */
		var/input_element = tgui_input_text(usr, "Enter what you want to write:", "Write", multiline = TRUE, max_length = 3000, encode = FALSE, trim = FALSE)

		topic_href_write(usr, id, input_element)


/obj/item/paper/attackby(obj/item/I, mob/living/user, params)
	if(resistance_flags & ON_FIRE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(I.get_heat())
		if(!Adjacent(user)) //to prevent issues as a result of telepathically lighting a paper
			return ATTACK_CHAIN_BLOCKED_ALL

		add_fingerprint(user)
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message(
				span_warning("[user] accidentally ignites [user.p_them()]self!"),
				span_userdanger("You miss the paper and accidentally light yourself on fire!"),
			)
			user.drop_item_ground(I)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return ATTACK_CHAIN_BLOCKED_ALL

		user.drop_item_ground(src)
		user.visible_message(
			span_danger("[user] lights [src] ablaze with [I]!"),
			span_danger("You light [src] on fire!"),
		)
		fire_act()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_pen(I) || istype(I, /obj/item/toy/crayon))
		add_fingerprint(user)
		if(!user.is_literate())
			to_chat(user, span_warning("You don't know how to write!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/pen/multi/robopen/robopen = I
		if(istype(I, /obj/item/pen/multi/robopen) && robopen.mode == 2)
			robopen.RenamePaper(user,src)
		else
			show_content(user, infolinks = TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stamp))
		if(!Adjacent(user, recurse = 2))
			return ATTACK_CHAIN_PROCEED
		add_fingerprint(user)
		if(istype(I, /obj/item/stamp/clown) && (user.mind && (user.mind.assigned_role != JOB_TITLE_CLOWN)))
			to_chat(user, span_userdanger("You are totally unable to use the stamp. HONK!"))
			return ATTACK_CHAIN_PROCEED
		stamp(I)
		to_chat(user, span_notice("You have stamped the paper with [I]."))
		playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, TRUE)
		return ATTACK_CHAIN_PROCEED

	if(!istype(I, /obj/item/paper) && !istype(I, /obj/item/photo))
		return ..()

	add_fingerprint(user)

	if(istype(I, /obj/item/paper/carbon))
		var/obj/item/paper/carbon/carbon_paper = I
		if(!carbon_paper.iscopy && !carbon_paper.copied)
			to_chat(user, span_notice("Take off the carbon copy first."))
			return .

	if(loc == user && !user.can_unEquip(src))
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_BLOCKED_ALL

	var/obj/item/paper_bundle/bundle = new(drop_location(), FALSE)
	transfer_fingerprints_to(bundle)
	bundle.add_fingerprint(user)

	if(name != "paper")
		bundle.name = name
	else if(I.name != "paper" && I.name != "photo")
		bundle.name = I.name

	to_chat(user, span_notice("You clip the [I.name] to [(name == "paper") ? "the paper" : name]."))

	if(loc == user)
		user.transfer_item_to_loc(src, bundle, silent = TRUE)
		user.put_in_hands(bundle)
	else
		bundle.pixel_x = pixel_x
		bundle.pixel_y = pixel_y
		forceMove(bundle)

	var/datum/browser/popup = new(user, "[istype(I, /obj/item/paper) ? "Paper" : "Photo"][I.UID()]")
	popup.include_default_stylesheet = FALSE
	popup.set_content("")
	popup.open(FALSE)
	var/datum/browser/popup_paper = new(user, "Paper[UID()]")
	popup_paper.include_default_stylesheet = FALSE
	popup_paper.set_content("")
	popup_paper.open(FALSE)
	bundle.papers += src
	bundle.papers += I
	bundle.amount++
	bundle.update_appearance(UPDATE_ICON|UPDATE_DESC)


/obj/item/paper/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		info = "<i>Heat-curled corners and sooty words offer little insight. Whatever was once written on this page has been rendered illegible through fire.</i>"


/obj/item/paper/proc/stamp(obj/item/stamp/stamp, no_pixel_shift = FALSE, special_stamped, special_icon_state)
	var/obj/item/stamp/stamp_path
	if(!ispath(stamp, /obj/item/stamp))
		if(istype(stamp, /obj/item/stamp))
			stamp_path = stamp.type
		else
			CRASH("Wrong argument passed as a stamp value ([stamp]).")
	else
		stamp_path = stamp

	var/stamp_count = LAZYLEN(stamped)
	if(stamp_count >= stamp_limit)
		return //can't fret over every stamp

	LAZYADD(stamped, stamp_path)

	var/new_icon_state = istype(stamp, /obj/item/stamp/chameleon) ? stamp.icon_state : special_icon_state ? special_icon_state : initial(stamp_path.icon_state)

	if(!stamps)
		stamps = "<hr>"
	stamps += special_stamped ? special_stamped : "<img src=large_[new_icon_state].png>"

	var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[new_icon_state]")
	var/stamp_offset_w
	var/stamp_offset_z
	if(no_pixel_shift)
		stamp_offset_w = 0
		stamp_offset_z = 0
	else if(ispath(stamp_path, /obj/item/stamp/captain) || ispath(stamp_path, /obj/item/stamp/centcom))
		stamp_offset_w = rand(-2, 0)
		stamp_offset_z = rand(-1, 2)
	else
		stamp_offset_w = rand(-2, 2)
		stamp_offset_z = rand(-3, 2)
	stampoverlay.pixel_w = stamp_offset_w
	stampoverlay.pixel_z = stamp_offset_z
	LAZYADD(stamp_overlays, stampoverlay)
	update_icon(UPDATE_OVERLAYS)


/*
 * Premade paper
 */
/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<br>\n<br>\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<br>\n\tGrade A Semi-Liquid Plasma:<br>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<br>\n\t\tA gas mask fails to filter plasma after 50 units.<br>\n\t\tWill attempt to diffuse like a gas.<br>\n\t\tFiltered by scrubbers.<br>\n\t\tThere is a bottled version which is very different<br>\n\t\t\tfrom the version found in canisters!<br>\n<br>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<br>\n\t\texcept in a enclosed fire area!<br>\n\t\tWARNING: It is a crime to use this without authorization.<br>\nKnown Onboard Anti-Toxin:<br>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<br>\n\t\tBest if injected directly into bloodstream.<br>\n\t\tA full injection is in every regular Med-Kit.<br>\n\t\tSpecial toxin Kits hold around 7.<br>\n<br>\nKnown Onboard Chemicals (other):<br>\n\tRejuvenation T#001:<br>\n\t\tEven 1 unit injected directly into the bloodstream<br>\n\t\t\twill cure paralysis and sleep plasma.<br>\n\t\tIf administered to a dying patient it will prevent<br>\n\t\t\tfurther damage for about units*3 seconds.<br>\n\t\t\tit will not cure them or allow them to be cured.<br>\n\t\tIt can be administeredd to a non-dying patient<br>\n\t\t\tbut the chemicals disappear just as fast.<br>\n\tSoporific T#054:<br>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<br>\n\t\t\tThe effect are cumulative.<br>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<b>Roles:</b><br>\nThe Detective is basically the investigator and prosecutor.<br>\nThe Staff Assistant can perform these functions with written authority from the Detective.<br>\nThe Captain/HoP/Warden is ct as the judicial authority.<br>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<br>\n<br>\n<b>Investigative Phase:</b><br>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<br>\n<br>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<br>\n<br>\n<b>Pre-Pre-Trial Phase:</b><br>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<br>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<br>\n<b>Possible Motions:</b><br>\n1. <u>Invalidate Evidence-</u> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<br>\n2. <u>Free Movement-</u> Basically the defendant is to be kept uncuffed before and during the trial.<br>\n3. <u>Subpoena Witness-</u> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<br>\n4. <u>Drop the Charges-</u> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<br>\n5. <u>Declare Incompetent-</u> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<br>\n<br>\nALL SIDES MOVE TO A COURTROOM<br>\n<b>Pre-Trial Hearings:</b><br>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<br>\n<br>\n<b>The Trial:</b><br>\nThe trial has three phases.<br>\n1. <b>Opening Arguments</b>- Each side can give a short speech. They may not present ANY evidence.<br>\n2. <b>Witness Calling/Evidence Presentation</b>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<br>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<br>\n3. <b>Closing Arguments</b>- Same as opening.<br>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<br>\n<br>\n<b>Sentencing Phase:</b><br>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <br>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<br>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<br>\n<br>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<br>\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<b>Hey fellow botanist!</b><br>\n<br>\nI didn't trust the station folk so I left<br>\na couple of weeks ago. But here's some<br>\ninstructions on how to operate things here.<br>\nYou can grow plants and each iteration they become<br>\nstronger, more potent and have better yield, if you<br>\nknow which ones to pick. Use your botanist's analyzer<br>\nfor that. You can turn harvested plants into seeds<br>\nat the seed extractor, and replant them for better stuff!<br>\nSometimes if the weed level gets high in the tray<br>\nmutations into different mushroom or weed species have<br>\nbeen witnessed. On the rare occassion even weeds mutate!<br>\n<br>\nEither way, have fun!<br>\n<br>\nBest regards,<br>\nBilly Bob Johnson.<br>\n<br>\nPS.<br>\nHere's a few tips:<br>\nIn nettles, potency = damage<br>\nIn amanitas, potency = deadliness + side effect<br>\nIn Liberty caps, potency = drug power + effect<br>\nIn chilis, potency = heat<br>\n<b>Nutrients keep mushrooms alive!</b><br>\n<b>Water keeps weeds such as nettles alive!</b><br>\n<b>All other plants need both.</b>"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	info = "<b>Welcome new owner!</b><br><br>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = TRUE

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<br>\nThe data will be in the following form.<br>\nGenerally lower ranking positions come first in this list.<br>\n<br>\n<b>Job Name</b>   general access>lab access-engine access-systems access (atmosphere control)<br>\n\tJob Description<br>\nJob Duties (in no particular order)<br>\nTips (where applicable)<br>\n<br>\n<b>Research Assistant</b> 1>1-0-0<br>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<br>\n1. Assist the researchers.<br>\n2. Clean up the labs.<br>\n3. Prepare materials.<br>\n<br>\n<b>Staff Assistant</b> 2>0-0-0<br>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<br>\n1. Patrol ship/Guard key areas<br>\n2. Assist security officer<br>\n3. Perform other security duties.<br>\n<br>\n<b>Technical Assistant</b> 1>0-0-1<br>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<br>\n1. Assist Station technician and Engineers.<br>\n2. Perform general maintenance of station.<br>\n3. Prepare materials.<br>\n<br>\n<b>Medical Assistant</b> 1>1-0-0<br>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<br>\n1. Assist the medical personnel.<br>\n2. Update medical files.<br>\n3. Prepare materials for medical operations.<br>\n<br>\n<b>Research Technician</b> 2>3-0-0<br>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<br>\n1. Inform superiors of research.<br>\n2. Perform research alongside of official researchers.<br>\n<br>\n<b>Detective</b> 3>2-0-0<br>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<br>\n1. Perform crime-scene investigations/draw conclusions.<br>\n2. Store and catalogue evidence properly.<br>\n3. Testify to superiors/inquieries on findings.<br>\n<br>\n<b>Station Technician</b> 2>0-2-3<br>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<br>\n1. Maintain SS13 systems.<br>\n2. Repair equipment.<br>\n<br>\n<b>Atmospheric Technician</b> 3>0-0-4<br>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<br>\n1. Maintain atmosphere on SS13<br>\n2. Research atmospheres on the space station. (safely please!)<br>\n<br>\n<b>Engineer</b> 2>1-3-0<br>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<br>\n1. Upkeep the engine.<br>\n2. Prevent fires in the engine.<br>\n3. Maintain a safe orbit.<br>\n<br>\n<b>Medical Researcher</b> 2>5-0-0<br>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<br>\n1. Make sure the station is kept safe.<br>\n2. Research medical properties of materials studied of Space Station 13.<br>\n<br>\n<b>Scientist</b> 2>5-0-0<br>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<br>\n1. Research plasma<br>\n2. Make sure all plasma is properly handled.<br>\n<br>\n<b>Medical Doctor (Officer)</b> 2>0-0-0<br>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<br>\n1. Heal wounded people.<br>\n2. Perform examinations of all personnel.<br>\n3. Moniter usage of medical equipment.<br>\n<br>\n<b>Security Officer</b> 3>0-0-0<br>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<br>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<br>\n1. Maintain order.<br>\n2. Assist others.<br>\n3. Repair structural problems.<br>\n<br>\n<b>Head of Security</b> 4>5-2-2<br>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<br>\n1. Oversee security.<br>\n2. Assign patrol duties.<br>\n3. Protect the station and staff.<br>\n<br>\n<b>Head of Personnel</b> 4>4-2-2<br>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<br>\n1. Assign duties.<br>\n2. Moderate personnel.<br>\n3. Moderate research. <br>\n<br>\n<b>Captain</b> 5>5-5-5 (unrestricted station wide access)<br>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<br>\n1. Assign all positions on SS13<br>\n2. Inspect the station for any problems.<br>\n3. Perform administrative duties.<br>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	item_state = "paper"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<br>\nBlue- Emergency<br>\n\t1. Caused by fire<br>\n\t2. Caused by manual interaction<br>\n\tAction:<br>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<br>\nRed- Ejection/Self Destruct<br>\n\t1. Caused by module operating computer.<br>\n\tAction:<br>\n\t\tAfter the specified time the module will eject completely.<br>\n<br>\nEngine Maintenance Instructions:<br>\n\tShut off ignition systems:<br>\n\tActivate internal power<br>\n\tActivate orbital balance matrix<br>\n\tRemove volatile liquids from area<br>\n\tWear a fire suit<br>\n<br>\n\tAfter<br>\n\t\tDecontaminate<br>\n\t\tVisit medical examiner<br>\n<br>\nToxin Laboratory Procedure:<br>\n\tWear a gas mask regardless<br>\n\tGet an oxygen tank.<br>\n\tActivate internal atmosphere<br>\n<br>\n\tAfter<br>\n\t\tDecontaminate<br>\n\t\tVisit medical examiner<br>\n<br>\nDisaster Procedure:<br>\n\tFire:<br>\n\t\tActivate sector fire alarm.<br>\n\t\tMove to a safe area.<br>\n\t\tGet a fire suit<br>\n\t\tAfter:<br>\n\t\t\tAssess Damage<br>\n\t\t\tRepair damages<br>\n\t\t\tIf needed, Evacuate<br>\n\tMeteor Shower:<br>\n\t\tActivate fire alarm<br>\n\t\tMove to the back of ship<br>\n\t\tAfter<br>\n\t\t\tRepair damage<br>\n\t\t\tIf needed, Evacuate<br>\n\tAccidental Reentry:<br>\n\t\tActivate fire alarms in front of ship.<br>\n\t\tMove volatile matter to a fire proof area!<br>\n\t\tGet a fire suit.<br>\n\t\tStay secure until an emergency ship arrives.<br>\n<br>\n\t\tIf ship does not arrive-<br>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"


/obj/item/paper/crumpled/update_icon_state()
	if(info)
		icon_state = "scrap_words"

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/fortune
	name = "fortune"
	icon_state = "slip"
	paper_height = 150

/obj/item/paper/fortune/Initialize(mapload)
	. = ..()
	var/fortunemessage = pick(GLOB.fortune_cookie_messages)
	info = "<p style='text-align:center;font-family:[deffont];font-size:120%;font-weight:bold;'>[fortunemessage]</p>"
	info += "<p style='text-align:center;'><strong>Lucky numbers</strong>: [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)]</p>"


/obj/item/paper/fortune/update_icon_state()
	icon_state = initial(icon_state)

/*
 * Premade paper
 */
/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<br>\n<br>\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<br>\n\tGrade A Semi-Liquid Plasma:<br>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<br>\n\t\tA gas mask fails to filter plasma after 50 units.<br>\n\t\tWill attempt to diffuse like a gas.<br>\n\t\tFiltered by scrubbers.<br>\n\t\tThere is a bottled version which is very different<br>\n\t\t\tfrom the version found in canisters!<br>\n<br>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<br>\n\t\texcept in a enclosed fire area!<br>\n\t\tWARNING: It is a crime to use this without authorization.<br>\nKnown Onboard Anti-Toxin:<br>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<br>\n\t\tBest if injected directly into bloodstream.<br>\n\t\tA full injection is in every regular Med-Kit.<br>\n\t\tSpecial toxin Kits hold around 7.<br>\n<br>\nKnown Onboard Chemicals (other):<br>\n\tRejuvenation T#001:<br>\n\t\tEven 1 unit injected directly into the bloodstream<br>\n\t\t\twill cure paralysis and sleep plasma.<br>\n\t\tIf administered to a dying patient it will prevent<br>\n\t\t\tfurther damage for about units*3 seconds.<br>\n\t\t\tit will not cure them or allow them to be cured.<br>\n\t\tIt can be administeredd to a non-dying patient<br>\n\t\t\tbut the chemicals disappear just as fast.<br>\n\tSoporific T#054:<br>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<br>\n\t\t\tThe effect are cumulative.<br>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<b>Roles:</b><br>\nThe Detective is basically the investigator and prosecutor.<br>\nThe Staff Assistant can perform these functions with written authority from the Detective.<br>\nThe Captain/HoP/Warden is ct as the judicial authority.<br>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<br>\n<br>\n<b>Investigative Phase:</b><br>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<br>\n<br>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<br>\n<br>\n<b>Pre-Pre-Trial Phase:</b><br>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<br>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<br>\n<b>Possible Motions:</b><br>\n1. <u>Invalidate Evidence-</u> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<br>\n2. <u>Free Movement-</u> Basically the defendant is to be kept uncuffed before and during the trial.<br>\n3. <u>Subpoena Witness-</u> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<br>\n4. <u>Drop the Charges-</u> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<br>\n5. <u>Declare Incompetent-</u> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<br>\n<br>\nALL SIDES MOVE TO A COURTROOM<br>\n<b>Pre-Trial Hearings:</b><br>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<br>\n<br>\n<b>The Trial:</b><br>\nThe trial has three phases.<br>\n1. <b>Opening Arguments</b>- Each side can give a short speech. They may not present ANY evidence.<br>\n2. <b>Witness Calling/Evidence Presentation</b>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<br>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<br>\n3. <b>Closing Arguments</b>- Same as opening.<br>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<br>\n<br>\n<b>Sentencing Phase:</b><br>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <br>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<br>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<br>\n<br>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<br>\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<b>Hey fellow botanist!</b><br>\n<br>\nI didn't trust the station folk so I left<br>\na couple of weeks ago. But here's some<br>\ninstructions on how to operate things here.<br>\nYou can grow plants and each iteration they become<br>\nstronger, more potent and have better yield, if you<br>\nknow which ones to pick. Use your botanist's analyzer<br>\nfor that. You can turn harvested plants into seeds<br>\nat the seed extractor, and replant them for better stuff!<br>\nSometimes if the weed level gets high in the tray<br>\nmutations into different mushroom or weed species have<br>\nbeen witnessed. On the rare occassion even weeds mutate!<br>\n<br>\nEither way, have fun!<br>\n<br>\nBest regards,<br>\nBilly Bob Johnson.<br>\n<br>\nPS.<br>\nHere's a few tips:<br>\nIn nettles, potency = damage<br>\nIn amanitas, potency = deadliness + side effect<br>\nIn Liberty caps, potency = drug power + effect<br>\nIn chilis, potency = heat<br>\n<b>Nutrients keep mushrooms alive!</b><br>\n<b>Water keeps weeds such as nettles alive!</b><br>\n<b>All other plants need both.</b>"

/obj/item/paper/chef
	name = "Cooking advice from Morgan Ramslay"
	info = "Right, so you're wanting to learn how to feed the teeming masses of the station yeah?<br>\n<br>\nWell I was asked to write these tips to help you not burn all of your meals and prevent food poisonings.<br>\n<br>\nOkay first things first, making a humble ball of dough.<br>\n<br>\nCheck the lockers for a bag or two of flour and then find a glass cup or a beaker, something that can hold liquids. Next pour 15 units of flour into the container and then pour 10 units of water in as well. Hey presto! You've made a ball of dough, which can lead to many possibilities.<br>\n<br>\nAlso, before I forget, KEEP YOUR FOOD OFF THE DAMN FLOOR! Space ants love getting onto any food not on a table or kept away in a closed locker. You wouldn't believe how many injuries have resulted from space ants...<br>\n<br>\nOkay back on topic, let's make some cheese, just follow along with me here.<br>\n<br>\nLook in the lockers again for some milk cartons and grab another glass to mix with. Next look around for a bottle named 'Universal Enzyme' unless they changed the look of it, it should be a green bottle with a red label. Now pour 5 units of enzyme into a glass and 40 units of milk into the glass as well. In a matter of moments you'll have a whole wheel of cheese at your disposal.<br>\n<br>\nOkay now that you've got the ingredients, let's make a classic crewman food, cheese bread.<br>\n<br>\nMake another ball of dough, and cut up your cheese wheel with a knife or something else sharp such as a pair of wire cutters. Okay now look around for an oven in the kitchen and put 2 balls of dough and 2 cheese wedges into the oven and turn it on. After a few seconds a fresh and hot loaf of cheese bread will pop out. Lastly cut it into slices with a knife and serve.<br>\n<br>\nCongratulations on making it this far. If you haven't created a burnt mess of slop after following these directions you might just be on your way to becoming a master chef someday.<br>\n<br>\nBe sure to look up other recipes and bug the Head of Personnel if Botany isn't providing you with crops, wheat is your friend and lifeblood.<br>\n<br>\nGood luck in the kitchen, and try not to burn down the place.<br>\n<br>\n-Morgan Ramslay"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	info = "<b>Welcome new owner!</b><br><br>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/monolithren
	name = "For stalkers"
	info = "Sorry Mario, your wishgranter in another castle. Your Friendly God"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = TRUE

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<br>\nThe data will be in the following form.<br>\nGenerally lower ranking positions come first in this list.<br>\n<br>\n<b>Job Name</b>   general access>lab access-engine access-systems access (atmosphere control)<br>\n\tJob Description<br>\nJob Duties (in no particular order)<br>\nTips (where applicable)<br>\n<br>\n<b>Research Assistant</b> 1>1-0-0<br>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<br>\n1. Assist the researchers.<br>\n2. Clean up the labs.<br>\n3. Prepare materials.<br>\n<br>\n<b>Staff Assistant</b> 2>0-0-0<br>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<br>\n1. Patrol ship/Guard key areas<br>\n2. Assist security officer<br>\n3. Perform other security duties.<br>\n<br>\n<b>Technical Assistant</b> 1>0-0-1<br>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<br>\n1. Assist Station technician and Engineers.<br>\n2. Perform general maintenance of station.<br>\n3. Prepare materials.<br>\n<br>\n<b>Medical Assistant</b> 1>1-0-0<br>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<br>\n1. Assist the medical personnel.<br>\n2. Update medical files.<br>\n3. Prepare materials for medical operations.<br>\n<br>\n<b>Research Technician</b> 2>3-0-0<br>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<br>\n1. Inform superiors of research.<br>\n2. Perform research alongside of official researchers.<br>\n<br>\n<b>Detective</b> 3>2-0-0<br>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<br>\n1. Perform crime-scene investigations/draw conclusions.<br>\n2. Store and catalogue evidence properly.<br>\n3. Testify to superiors/inquieries on findings.<br>\n<br>\n<b>Station Technician</b> 2>0-2-3<br>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<br>\n1. Maintain SS13 systems.<br>\n2. Repair equipment.<br>\n<br>\n<b>Atmospheric Technician</b> 3>0-0-4<br>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<br>\n1. Maintain atmosphere on SS13<br>\n2. Research atmospheres on the space station. (safely please!)<br>\n<br>\n<b>Engineer</b> 2>1-3-0<br>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<br>\n1. Upkeep the engine.<br>\n2. Prevent fires in the engine.<br>\n3. Maintain a safe orbit.<br>\n<br>\n<b>Medical Researcher</b> 2>5-0-0<br>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<br>\n1. Make sure the station is kept safe.<br>\n2. Research medical properties of materials studied of Space Station 13.<br>\n<br>\n<b>Scientist</b> 2>5-0-0<br>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<br>\n1. Research plasma<br>\n2. Make sure all plasma is properly handled.<br>\n<br>\n<b>Medical Doctor (Officer)</b> 2>0-0-0<br>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<br>\n1. Heal wounded people.<br>\n2. Perform examinations of all personnel.<br>\n3. Moniter usage of medical equipment.<br>\n<br>\n<b>Security Officer</b> 3>0-0-0<br>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<br>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<br>\n1. Maintain order.<br>\n2. Assist others.<br>\n3. Repair structural problems.<br>\n<br>\n<b>Head of Security</b> 4>5-2-2<br>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<br>\n1. Oversee security.<br>\n2. Assign patrol duties.<br>\n3. Protect the station and staff.<br>\n<br>\n<b>Head of Personnel</b> 4>4-2-2<br>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<br>\n1. Assign duties.<br>\n2. Moderate personnel.<br>\n3. Moderate research. <br>\n<br>\n<b>Captain</b> 5>5-5-5 (unrestricted station wide access)<br>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<br>\n1. Assign all positions on SS13<br>\n2. Inspect the station for any problems.<br>\n3. Perform administrative duties.<br>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	item_state = "paper"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<br>\nBlue- Emergency<br>\n\t1. Caused by fire<br>\n\t2. Caused by manual interaction<br>\n\tAction:<br>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<br>\nRed- Ejection/Self Destruct<br>\n\t1. Caused by module operating computer.<br>\n\tAction:<br>\n\t\tAfter the specified time the module will eject completely.<br>\n<br>\nEngine Maintenance Instructions:<br>\n\tShut off ignition systems:<br>\n\tActivate internal power<br>\n\tActivate orbital balance matrix<br>\n\tRemove volatile liquids from area<br>\n\tWear a fire suit<br>\n<br>\n\tAfter<br>\n\t\tDecontaminate<br>\n\t\tVisit medical examiner<br>\n<br>\nToxin Laboratory Procedure:<br>\n\tWear a gas mask regardless<br>\n\tGet an oxygen tank.<br>\n\tActivate internal atmosphere<br>\n<br>\n\tAfter<br>\n\t\tDecontaminate<br>\n\t\tVisit medical examiner<br>\n<br>\nDisaster Procedure:<br>\n\tFire:<br>\n\t\tActivate sector fire alarm.<br>\n\t\tMove to a safe area.<br>\n\t\tGet a fire suit<br>\n\t\tAfter:<br>\n\t\t\tAssess Damage<br>\n\t\t\tRepair damages<br>\n\t\t\tIf needed, Evacuate<br>\n\tMeteor Shower:<br>\n\t\tActivate fire alarm<br>\n\t\tMove to the back of ship<br>\n\t\tAfter<br>\n\t\t\tRepair damage<br>\n\t\t\tIf needed, Evacuate<br>\n\tAccidental Reentry:<br>\n\t\tActivate fire alarms in front of ship.<br>\n\t\tMove volatile matter to a fire proof area!<br>\n\t\tGet a fire suit.<br>\n\t\tStay secure until an emergency ship arrives.<br>\n<br>\n\t\tIf ship does not arrive-<br>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/blueshield
	name = "paper- 'Blueshield Mission Briefing'"
	info = "<b>Blueshield Mission Briefing</b><br>You are charged with the defence of any persons of importance within the station. This includes, but is not limited to, The Captain, The Heads of Staff and Central Command staff. You answer directly to the Nanotrasen Representative who will assist you in achieving your mission.<br>When required to achieve your primary responsibility, you should liaise with security and share resources; however, the day to day security operations of the station are outside of your jurisdiction.<br>Monitor the health and safety of your principals, identify any potential risks and threats, then alert the proper departments to resolve the situation. You are authorized to act as bodyguard to any of the station heads that you determine are most in need of protection; however, additional access to their departments shall be granted solely at their discretion.<br>Observe the station alert system and carry your armaments only as required by the situation, or when authorized by the Head of Security or Captain in exceptional cases.<br>Remember, as an agent of Nanotrasen it is your responsibility to conduct yourself appropriately and you will be held to the highest standard. You will be held accountable for your actions. Security is authorized to search, interrogate or detain you as required by their own procedures. Internal affairs will also monitor and observe your conduct, and their mandate applies equally to security and Blueshield operations."

/obj/item/paper/ntrep
	name = "paper- 'Nanotrasen Representative Mission Briefing'"
	info = "<b>Nanotrasen Representative Mission Briefing</b><br><br>Nanotrasen Central Command has dispatched you to this station in order to liaise with command staff on their behalf. As experienced field officers, the staff on the station are experts in handling their own fields. It is your job, however, to consider the bigger picture and to direct the staff towards Nanotrasen's corporate interests.<br>As a civilian, you should consider yourself an advisor, diplomat and intermediary. The command staff do not answer to you directly and are not required to follow your orders, nor do you have disciplinary authority over personnel. In all station internal matters you answer to the Head of Personnel who will direct you in your conduct within the station. However, you also answer to Central Command who may, as required, direct you in acting on company interests.<br>Central Command may dispatch orders to the staff through you which you are responsible to communicate; however, enforcement of these orders is not your mandate and will be handled directly by Central Command or authorized Nanotrasen personnel. When not specifically directed by Central Command, assist the Head of Personnel in evaluation of the station and receiving departmental reports.<br>Your office has been provided with a direct link to Central Command, through which you can issue any urgent reports or requests for Nanotrasen intervention. Remember that any direct intervention is a costly exercise and should be used only when the situation justifies the request. You will be held accountable for any unnecessary usage of Nanotrasen resources.<br>"

/obj/item/paper/armory
	name = "paper- 'Armory Inventory'"
	info = "4 Deployable Barriers<br>4 Portable Flashers<br>1 Mechanical Toolbox<br>2 Boxes of Spare Handcuffs<br>1 Box of Flashbangs<br>1 Box of Spare R.O.B.U.S.T. Cartridges<br>1 Tracking Implant Kit<br>1 Chemical Implant Kit<br>1 Box of Tear Gas Grenades<br>1 Explosive Ordnance Disposal Suit<br>1 Biohazard Suit<br>6 Gas Masks<br>1 Lockbox of Mindshield Implants<br>1 Ion Rifle<br>3 Sets of Riot Equipment<br>2 Sets of Security Hardsuits<br>1 Ablative Armor Vest<br>3 Bulletproof Vests<br>3 Helmets<br><br>2 Riot Shotguns<br>2 Boxes of Beanbag Shells<br>3 Laser Guns<br>3 Energy Guns<br>3 Advanced Tasers"

/obj/item/paper/firingrange
	name = "paper- 'Firing Range Instructions'"
	info = "Directions:<br><i>First you'll want to make sure there is a target stake in the center of the magnetic platform. Next, take an aluminum target from the crates back there and slip it into the stake. Make sure it clicks! Next, there should be a control console mounted on the wall somewhere in the room.<br><br> This control console dictates the behaviors of the magnetic platform, which can move your firing target around to simulate real-world combat situations. From here, you can turn off the magnets or adjust their electromagnetic levels and magnetic fields. The electricity level dictates the strength of the pull - you will usually want this to be the same value as the speed. The magnetic field level dictates how far the magnetic pull reaches.<br><br>Speed and path are the next two settings. Speed is associated with how fast the machine loops through the designated path. Paths dictate where the magnetic field will be centered at what times. There should be a pre-fabricated path input already. You can enable moving to observe how the path affects the way the stake moves. To script your own path, look at the following key:</i><br><br>N: North<br>S: South<br>E: East<br>W: West<br>C: Center<br>R: Random (results may vary)<br>; or &: separators. They are not necessary but can make the path string better visible."

/obj/item/paper/holodeck
	name = "paper- 'Holodeck Disclaimer'"
	info = "Bruises sustained in the holodeck can be healed simply by sleeping."

/obj/item/paper/syndimemo
	name = "paper- 'Memo'"
	info = "GET DAT FUKKEN DISK"

/obj/item/paper/synditele
	name = "Teleporter Instructions"
	info = "<h3>Teleporter Instruction</h3><hr><ol><li>Install circuit board, glass and wiring to complete Teleporter Control Console</li><li>Use a screwdriver, wirecutter and screwdriver again on the Teleporter Station to connect it</li><li>Set destination with Teleporter Control Computer</li><li>Activate Teleporter Hub with Teleporter Station</li></ol>"

/obj/item/paper/russiantraitorobj
	name = "paper- 'Mission Objectives'"
	info = "The Syndicate have cunningly disguised a Syndicate Uplink as your PDA. Simply enter the code \"678 Bravo\" into the ringtone select to unlock its hidden features. <br><br><b>Objective #1</b>. Kill the God damn AI in a fire blast that it rocks the station. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/item/paper/russiannuclearoperativeobj
	name = "paper- 'Objectives of a Nuclear Operative'"
	info = "<b>Objective #1</b>: Destroy the station with a nuclear device."

/obj/item/paper/clownship
	name = "paper- 'Note'"
	info = "The call has gone out! Our ancestral home has been rediscovered! Not a small patch of land, but a true clown nation, a true Clown Planet! We're on our way home at last!"

/obj/item/paper/syndicate
	name = "paper"
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='syndielogo.png' width='220' height='135' /></p><hr />"
	info = ""

/obj/item/paper/nanotrasen
	name = "paper"
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' width='220' height='135' /></p><hr />"
	info =  ""

/obj/item/paper/ussp
	name = "paper"
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ussplogo.png' width='220' height='135' /></p><hr />"
	info =  ""
	language = LANGUAGE_NEO_RUSSIAN

/obj/item/paper/solgov
	name = "paper"
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='solgovlogo.png' width='220' height='135' /></p><hr />"
	info = ""

/obj/item/paper/central_command
	name = "Директива Центрального Командования"
	info = ""

/obj/item/paper/central_command/Initialize(mapload)
	. = ..()
	time = "Время: [station_time_timestamp()]"
	if(!(GLOB.genname))
		GLOB.genname = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
	header ="<font face=\"Verdana\" color=black><table></td><tr><td><img src = ntlogo.png><td><table></td><tr><td><font size = \"1\">Форма NT-CC-DRV</font></td><tr><td><font size=\"1\">[command_name()]</font></td><tr><td><font size=\"1\">[time]</font></td><tr><td></td><tr><td></td><tr><td><b>Директива Центрального Командования</b></td></tr></table></td></tr></table><br><hr><br></font>"
	footer = "<br /><br /><font face=\"Verdana\" size = \"1\"><i>Подпись&#58;</font> <font face=\"[signfont]\" size = \"1\">[GLOB.genname]</font></i><font face=\"Verdana\" size = \"1\">, в должности <i>Nanotrasen Navy Officer</i></font><hr /><p style='font-family:Verdana;'><font size = \"1\"><em>*Содержимое данного документа следует считать конфиденциальным. Если не указано иное, распространение содержащейся в данном документе информации среди третьих лиц и сторонних организаций строго запрещено. </em> <br /> <em>*Невыполнение директив, содержащихся в данном документе, считается нарушением политики корпорации и может привести к наложению различных дисциплинарных взысканий. </em> <br /> <em> *Данный документ считается действительным только при наличии подписи и печати офицера Центрального Командования.</em></font></p>"
	populatefields()


/obj/item/paper/central_command/archive/station_reports
	info = "<font face=\"Verdana\" color=black><center><b>Приветствую Центральное командование</b></center><br>Сообщает вам ██████████ █████████, в должности капитан </span>.<br><br>В данный момент на станции код: Зеленый </span><br>Активные угрозы для станции: <b>Отсуствуют </span></b><br>Потери среди экипажа: Отсуствуют </span><br>Повреждения на станции: Отсуствуют</span><br>Общее состояние станции: Удовлетворительное </span><br>Дополнительная информация: Отсутствует<br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись:  ██████████ █████████ <hr><font size = \"1\">*В данном документе описывается полное состояние станции, необходимо перечислить всю доступную информацию. <br>*Информацию, которую вы считаете нужной, необходимо сообщить в разделе – дополнительная информация. <br>*<b>Данный документ считается официальным только после подписи уполномоченного лица и наличии на документе его печати.</b> </font></font>"

/obj/item/paper/central_command/archive/memes

/obj/item/paper/thief
	name = "Инструкции"
	header = "<font face=\"Verdana\" color=black>\
			<table cellspacing=0 cellpadding=3  align=\"right\">\
			<tr><td><img src= thieflogo.png></td></tr>\
			<br><hr></font>"
	info = "<font face=\"Verdana\"\
	<br><center><h2>Инструкции</h2></center> \
	<br><center><h3>Здравия, товарищ по ремеслу!</h3></center> \
	<br>\n<br>\nДанная инструкция поможет тебе разобраться и сразу не попасться.<br> \
	\nНу... Тут как повезет. Но помни, если тебя поймали - ты никого не знаешь.<br> \
	\nМы постараемся вытащить тебя как только так сразу. \
	\nА до этого момента сиди держи язык за зубами. Гильдия всегда всё знает.<br> \
	<br><hr> \
	<br>\n<b>Начнем с основ.</b><br> \
	\nВ твоих руках находится коробка с твоими личным инструментарием, который ты взял с собой. \
	Надеюсь ты тщательно подумал что берешь. В любом случае, думать уже поздно, теперь работай с тем что есть и что под рукой.<br> \
	\nНадеюсь ты не взял с собой термальные очки. Ты же уважающий себя член нашей гильдии. Ведь так?<br> \
	\nА даже если взял, наверняка мы заменили тебе их на не-хамелеонные и приложили коробку сладостей. Наслаждайся.<br> \
	\nЕсли же не взял - мое личное уважение за знание своего ремесла и уверенность.<br> \
	\nТакже в твой набор вложен портфель и перчатки. \
	\nПортфель позволяет тебе спрятать вещи в него, а после запрятать их где-нибудь под-полом. \
	Конечно ты можешь и без этого спрятать их в бачок унитаза, судить твои методы не буду. Они все хороши.<br> \
	\nНаши фирменные перчатки не оставляют следов и позволяют стащить вещь у твоей цели прямо на её глазах в твои руки. \
	И она даже ничего не заметит. Конечно если ты не снимаешь с неё трусы. Лёгкий ветерок щекочащий булочки вызывает подозрения.<br> \
	<br><hr> \
	<br>\n<b>А теперь по пунктам:</b><br>\
	\n1. Получи информацию по цели.<br> \
	\n2. Найди цель.<br> \
	\n3. Продумай план с использованием своего снаряжения и снаряжения станции.<br> \
	\n\t	3.1 Заполучи дополнительное снаряжение при необходимости.<br> \
	\n\t	3.2 Воспользуйся украденными денежными средствами для получения снаряжения.<br> \
	\n4. Действуй. Не сиди и не жди. Чем дольше ты ждешь, тем больше шансов что цель пострадает до её заполучения.<br> \
	\n\t	4.1 Если цель - предмет, просто не потеряй его после кражи.<br> \
	\n\t	4.2 Если цель - структура, убедись что её не разобрали никакие клоуны.<br> \
	\n\t	4.3 Если цель - питомец, убедись в её безопасности, помести её в переноску, рюкзак или шкаф, свяжи по возможности.<br> \
	\n5. Контролируй сохранность цели во избежания её повреждения или... смерти. Иначе задача будет провалена.<br> \
	\n6. Для успешного выполнения цели необходимо:<br> \
	\n\t	6.1 Предметы: Храни их на себе, в себе, в карманах или рюкзаке. <br> \
	\n\t	6.2 Структура: Держи её возле себя по прибытию. <br> \
	\n\t	6.3 Питомец: Держи его в рюкзаке, в карманах, переноске, шкафу или на голове по прибытию. <br> \
	\n7. ...<br> \
	\n8. Profit!<br></font> \
	<br>\n<br>\n<font size = \"1\"><b>Уничтожь улики, коробку и инструкцию во избежании раскрытия работы гильдии.</b></span> \
	<br>\n\t\t<font size = \"1\">~~~ <b>Твой Куратор:</b> Персональный Управляемый Помощник Согласования ~~~</span>"

/obj/item/paper/dog_detective_explain
	name = "Форма NT-PET-05 - Уведомление агента внутренних дел НаноТрейзен о питомце \"Гав Гавыч\""
	header ="<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' alt='' width='220' height='135' /></p><hr /><h3 style='text-align: center;font-family: Verdana;'><b> Отдел внутренних дел НаноТрейзен по надзору за животными.</h3><p style='text-align: center;font-family:Verdana;'>Официальное Уведомление</p></b><hr />"
	info = "<font face=\"Verdana\" color=black>ᅠᅠАгенство внутренних дел по надзору за домашними животными находящимися на станции сообщает, приставленный к вам питомец \"Гав Гавыч\" почил. Он верно служил ремеслу дознавателей, сыщиков и детективов. Мы будем помнить о его вкладе и сохраним о нём память в анналах истории о домашних питомцах НаноТрейзен.<br><hr>"
	footer = "<center><font size=\"4\"><b>Штампы и данные:</b></font></center><br>Время принятия отчета: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче агенту.<br>*Данный документ может содержать личную информацию. </font></font>"


/obj/item/paper/evilfax
	name = "Centcomm Reply"
	info = ""
	var/mytarget = null
	var/myeffect = null
	var/used = FALSE
	var/countdown = 60
	var/activate_on_timeout = FALSE
	var/faxmachineid = null


/obj/item/paper/evilfax/show_content(mob/user, forceshow = FALSE, forcestars = FALSE, infolinks, view = TRUE)
	if(user == mytarget)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			evilpaper_specialaction(C)
			..()
		else
			// This should never happen, but just in case someone is adminbussing
			evilpaper_selfdestruct()
	else
		if(mytarget)
			to_chat(user,"<span class='notice'>This page appears to be covered in some sort of bizzare code. The only bit you recognize is the name of [mytarget]. Perhaps [mytarget] can make sense of it?</span>")
		else
			evilpaper_selfdestruct()


/obj/item/paper/evilfax/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/paper/evilfax/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(mytarget && !used)
		var/mob/living/carbon/target = mytarget
		var/datum/disease/virus/transformation/corgi/D = new
		D.Contract(target)
	return ..()


/obj/item/paper/evilfax/process()
	if(!countdown)
		if(mytarget)
			if(activate_on_timeout)
				addtimer(CALLBACK(src, PROC_REF(evilpaper_specialaction), mytarget), 3 SECONDS, TIMER_DELETE_ME)
			else
				message_admins("[mytarget] ignored an evil fax until it timed out.")
		else
			message_admins("Evil paper '[src]' timed out, after not being assigned a target.")
		used = TRUE
		evilpaper_selfdestruct()
	else
		countdown--


/obj/item/paper/evilfax/proc/evilpaper_specialaction(mob/living/carbon/target)
	if(!iscarbon(target))
		return

	var/obj/machinery/photocopier/faxmachine/fax = locateUID(faxmachineid)
	if(myeffect == "Borgification")
		to_chat(target,"<span class='userdanger'>You seem to comprehend the AI a little better. Why are your muscles so stiff?</span>")
		var/datum/disease/virus/transformation/robot/D = new
		D.Contract(target)
	else if(myeffect == "Corgification")
		to_chat(target,"<span class='userdanger'>You hear distant howling as the world seems to grow bigger around you. Boy, that itch sure is getting worse!</span>")
		var/datum/disease/virus/transformation/corgi/D = new
		D.Contract(target)
	else if(myeffect == "Death By Fire")
		to_chat(target,"<span class='userdanger'>You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?</span>")
		var/turf/simulated/T = get_turf(target)
		new /obj/effect/hotspot(T)
		target.adjustFireLoss(150) // hard crit, the burning takes care of the rest.
	else if(myeffect == "Total Brain Death")
		to_chat(target,"<span class='userdanger'>You see a message appear in front of you in bright red letters: <b>YHWH-3 ACTIVATED. TERMINATION IN 3 SECONDS</b></span>")
		ADD_TRAIT(target, TRAIT_NO_CLONE, EVIL_FAX_TRAIT)
		target.adjustBrainLoss(125)
	else if(myeffect == "Honk Tumor")
		if(!target.get_int_organ(/obj/item/organ/internal/honktumor))
			new /obj/item/organ/internal/honktumor(target)
			to_chat(target,"<span class='userdanger'>Life seems funnier, somehow.</span>")
	else if(myeffect == "Cluwne")
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			to_chat(H, "<span class='userdanger'>You feel surrounded by sadness. Sadness... and HONKS!</span>")
			H.makeCluwne()
	else if(myeffect == "Demote")
		GLOB.event_announcement.Announce("[target.real_name] настоящим приказом был понижен до Гражданского. Немедленно обработайте этот запрос. Невыполнение этих распоряжений является основанием для расторжения контракта.","ВНИМАНИЕ: Приказ ЦК о понижении в должности.")
		for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
			if(R.fields["name"] == target.real_name)
				R.fields["criminal"] = SEC_RECORD_STATUS_DEMOTE
				R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<br> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
		update_all_mob_security_hud()
	else if(myeffect == "Demote with Bot")
		GLOB.event_announcement.Announce("[target.real_name] настоящим приказом был понижен до Гражданского. Немедленно обработайте этот запрос. Невыполнение этих распоряжений является основанием для расторжения контракта.","ВНИМАНИЕ: Приказ ЦК о понижении в должности.")
		for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
			if(R.fields["name"] == target.real_name)
				R.fields["criminal"] = SEC_RECORD_STATUS_ARREST
				R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<br> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
		update_all_mob_security_hud()
		if(fax)
			var/turf/T = get_turf(fax)
			new /obj/effect/portal(T)
			new /mob/living/simple_animal/bot/secbot(T)
	else if(myeffect == "Revoke Fax Access")
		GLOB.fax_blacklist += target.real_name
		if(fax)
			fax.authenticated = FALSE
	else if(myeffect == "Angry Fax Machine")
		if(fax)
			fax.become_mimic()
	else
		message_admins("Evil paper [src] was activated without a proper effect set! This is a bug.")

	used = TRUE
	evilpaper_selfdestruct()


/obj/item/paper/evilfax/proc/evilpaper_selfdestruct()
	visible_message("<span class='danger'>[src] spontaneously catches fire, and burns up!</span>")
	qdel(src)


/obj/item/paper/pickup(user)
	if(contact_poison && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(contact_poison, contact_poison_volume)
			contact_poison = null
			add_attack_logs(src, user, "Picked up [src], the paper poisoned by [contact_poison_poisoner]")
	. = ..()

/obj/item/paper/researchnotes
	name = "paper - 'Research Notes'"
	info = "<b>The notes appear gibberish to you. Perhaps a destructive analyzer in R&D could make sense of them.</b>"
	origin_tech = "combat=4;materials=4;engineering=4;biotech=4"

/obj/item/paper/researchnotes/Initialize(mapload)
	. = ..()
	var/list/possible_techs = list("materials", "engineering", "plasmatech", "powerstorage", "bluespace", "biotech", "combat", "magnets", "programming", "syndicate")
	var/mytech = pick(possible_techs)
	var/mylevel = rand(7, 9)
	origin_tech = "[mytech]=[mylevel]"
	name = "research notes - [mytech] [mylevel]"

/obj/item/paper/form
	var/id // official form ID
	var/altername // alternative form name
	var/category // category name
	var/confidential = FALSE
	var/from // = "Научная станция Nanotrasen &#34;Cyberiad&#34;"
	var/notice = "Перед заполнением прочтите от начала до конца | Во всех PDA имеется ручка"
	var/access = null //form visible only with appropriate access
	paper_width = 600 //Width of the window that opens
	paper_height = 700 //Height of the window that opens
	var/is_header_needed = TRUE
	var/const/footer_signstampfax = "<br><font face=\"Verdana\" color=black><hr><center><font size = \"1\">Подписи глав являются доказательством их согласия.<br>Данный документ является недействительным при отсутствии релевантной печати.<br>Пожалуйста, отправьте обратно подписанную/проштампованную копию факсом.</font></center></font>"
	var/const/footer_signstamp = "<br><font face=\"Verdana\" color=black><hr><center><font size = \"1\">Подписи глав являются доказательством их согласия.<br>Данный документ является недействительным при отсутствии релевантной печати.</font></center></font>"
	var/const/footer_confidential = "<br><font face=\"Verdana\" color=black><hr><center><font size = \"1\">Данный документ является недействительным при отсутствии печати.<br>Отказ от ответственности: Данный факс является конфиденциальным и не может быть прочтен сотрудниками не имеющего доступа. Если вы получили данный факс по ошибке, просим вас сообщить отправителю и удалить его из вашего почтового ящика или любого другого носителя. И Nanotrasen, и любой её агент не несёт ответственность за любые сделанные заявления, они являются исключительно заявлениями отправителя, за исключением если отправителем является Nanotrasen или один из её агентов. Отмечаем, что ни Nanotrasen, ни один из агентов корпорации не несёт ответственности за наличие вирусов, который могут содержаться в данном факсе или его приложения, и это только ваша прерогатива просканировать факс и приложения на них. Никакие контракты не могут быть заключены посредством факсимильной связи.</font></center></font>"
	footer = footer_signstampfax


/obj/item/paper/form/Initialize(mapload)
	. = ..()
	from = "Научная станция Nanotrasen &#34;[SSmapping.map_datum.station_name]&#34;"
	if(is_header_needed)
		header = "<font face=\"Verdana\" color=black><table></td><tr><td><img src = ntlogo.png><td><table></td><tr><td><font size = \"1\">[name][confidential ? " \[КОНФИДЕНЦИАЛЬНО\]" : ""]</font></td><tr><td></td><tr><td><b><font size=\"4\">[altername]</font></b></td><tr><td><table></td><tr><td>[from]<td>[category]</td></tr></table></td></tr></table></td></tr></table><center><font size = \"1\">[notice]</font></center><br><hr><br></font>"
	populatefields()


//главы станции
/obj/item/paper/form/NT_COM_ORDER
	name = "Форма NT-COM-ORDER"
	id = "NT-COM-ORDER"
	altername = "Приказ"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black>Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, приказываю:<br><br><span class=\"paper_field\"></span><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><br>Подпись инициатора: <span class=\"paper_field\"></span><br>Время подписания приказа: <span class=\"paper_field\"></span><br>Дата подписания приказа: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве должностного лица.</font></font>"
/obj/item/paper/form/NT_COM_ST
	name = "Форма NT-COM-ST"
	id = "NT-COM-ST"
	altername = "Отчет о ситуации на станции"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><center><b>Приветствую Центральное командование</b></center><br>Сообщает вам <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>.<br><br>В данный момент на станции код: <span class=\"paper_field\"></span><br>Активные угрозы для станции: <b><span class=\"paper_field\"></span></b><br>Потери среди экипажа: <span class=\"paper_field\"></span><br>Повреждения на станции: <span class=\"paper_field\"></span><br>Общее состояние станции: <span class=\"paper_field\"></span><br>Дополнительная информация: <span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись: <span class=\"paper_field\"></span><hr><font size = \"1\">*В данном документе описывается полное состояние станции, необходимо перечислить всю доступную информацию. <br>*Информацию, которую вы считаете нужной, необходимо сообщить в разделе – дополнительная информация. <br>*<b>Данный документ считается официальным только после подписи уполномоченного лица и наличии на документе его печати.</b> </font></font>"

/obj/item/paper/form/NT_COM_ACAP
	name = "Форма NT-COM-ACAP"
	id = "NT-COM-ACAP"
	altername = "Заявление о повышении главы отдела до и.о. капитана"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black>Я, <span class=\"paper_field\"></span>, в должности главы отделения <span class=\"paper_field\"></span>, прошу согласовать нынешнее командование станции Керберос, в повышении меня до и.о. капитана.<br><br>⠀⠀⠀При назначении меня на данную должность, я обязуюсь выполнять все рекомендации и правила, согласно стандартным рабочим процедурам капитана. До появления капитана, я обеспечиваю порядок и управление станцией, сохранность и безопасность <i>диска с кодами авторизации ядерной боеголовки, а также самой боеголовки, коды от сейфов и личные вещи капитана</i>.<br><br>⠀⠀⠀При появлении капитана мне необходибо будет сообщить: состояние и статус станции, о своем продвижении до и.о. капитана, и обнулить капитанский доступ при первому требованию капитана.<hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><br>Подпись заявителя: <span class=\"paper_field\"></span><br>Подпись инициатора повышения: <span class=\"paper_field\"></span><br>Время вступления в должность и.о. капитана: <span class=\"paper_field\"></span><br>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><br>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><br>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию повышения, и выдаче заявителю.<br>*Если один (или более) глав отсутствуют, необходимо собрать подписи, действующих глав.<br>*Так же в данном документе, главам, которые согласились с кандидатом, необходимо поставить свою печать и подпись.</font></font>"

/obj/item/paper/form/NT_COM_ACOM
	name = "Форма NT-COM-ACOM"
	id = "NT-COM-ACOM"
	altername = "Заявление о повышении сотрудника до и.о. главы отделения"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><br>ᅠᅠЯ, <span class=\"paper_field\"></span>, в должности сотрудника отделения <b><span class=\"paper_field\"></span></b>, прошу согласовать нынешнее командование станции Керберос, в повышении меня до звания и.о. главы <span class=\"paper_field\"></span>.<br><br>⠀⠀⠀При назначении меня на данную должность, я обязуюсь выполнять все рекомендации, и правила, которые присутствуют на главе отделения <span class=\"paper_field\"></span>. До появления основного главы отделения, я обеспечиваю порядок и управление своим отделом, сохранность и безопасность <i>личных вещей главы отделения</i>.<br><br>⠀⠀⠀При появлении главы отделения, мне неообходимо сообщить: состояние и статус своего отдела, о своем продвижении до и.о. главы отделения, и сдать доступ и.о. главы и взятые вещи при первом требовании прибывшего главы.<br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись заявителя: <span class=\"paper_field\"></span><br>Подпись инициатора повышения: <span class=\"paper_field\"></span><br>Время вступления в и.о. <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><br>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><br>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><br>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию повышения, и выдаче заявителю.<br>*При указании главы, рекомендуется использовать сокращения:<br>*СМО (главврач), СЕ (глав. инженер), РД (дир. исследований), КМ (завхоз), ГСБ (глава СБ), ГП (глава персонала).<br>*Если один (или более) глав отсутствуют, необходимо собрать подписи, действующих глав.<br>*Так же в данном документе, главам, которые согласились с кандидатом, необходимо поставить свою печать и подпись.</font></font>"

/obj/item/paper/form/NT_COM_LCOM
	name = "Форма NT-COM-LCOM"
	id = "NT-COM-LCOM"
	altername = "Заявление об увольнении главы отделения"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><br>ᅠᅠЯ, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю об официальном увольнении действующего главы <span class=\"paper_field\"></span>, отделения <span class=\"paper_field\"></span>. Причина увольнения:<span class=\"paper_field\"></span><br>⠀⠀⠀При наличии иных причин, от других глав, они так же могут написать их в данном документе.<br><span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись инициатора увольнения: <span class=\"paper_field\"></span><br>Подпись увольняемого, о ознакомлении: <span class=\"paper_field\"></span><br>Дата и время увольнения: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию увольнения, и выдаче увольняемому.<br>*Для полной эффективности данного документа, необходимо собрать как можно больше причин для увольнения, и перечислить их. Инициировать увольнение может только <i> капитан или глава персонала. </i></font></font>"

/obj/item/paper/form/NT_COM_REQ
	name = "Форма NT-COM-REQ"
	id = "NT-COM-REQ"
	altername = "Запрос на поставку с Центрального командования"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><br><center><b>Приветствую Центральное командование</b></center><br><br>Сообщает вам <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>.<br><br><b>Текст запроса:</b> <span class=\"paper_field\"></span><br><br><b>Причина запроса:</b><span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><br>Подпись: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*В данном документе описывается запросы на поставку оборудования/ресурсов, необходимо перечислить по пунктно необходимое для поставки. <br>*Данный документ считается, официальным, только после подписи уполномоченного лица, и наличии на документе его печати.</b> </font></font>"

/obj/item/paper/form/NT_COM_OS
	name = "Форма NT-COM-OS"
	id = "NT-COM-OS"
	altername = "Отчёт о выполнении цели"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><br>Цель станции: <span class=\"paper_field\"></span><br>Статус цели: <span class=\"paper_field\"></span><br>Общее состояние станции: <span class=\"paper_field\"></span><br>Активные угрозы: <span class=\"paper_field\"></span><br>Оценка работы экипажа: <span class=\"paper_field\"></span><br>Дополнительные замечания: <span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center>Должность уполномоченного лица: <span class=\"paper_field\"></span><br>Подпись уполномоченного лица: <span class=\"paper_field\"></span><hr><font size = \"1\"><i>*Данное сообщение должно сообщить вам о состоянии цели, установленной Центральным командованием Nanotrasen для ИСН &#34;Керберос&#34;. Убедительная просьба внимательно прочитать данное сообщение для вынесения наиболее эффективных указаний для последующей деятельности станции.<br>*Данный документ считается официальным только при наличии подписи уполномоченного лица и соответствующего его должности штампа. В случае отсутствия любого из указанных элементов данный документ не является официальным и рекомендуется его удалить с любого информационного носителя. <br>ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ: Корпорация Nanotrasen не несёт ответственности, если данный документ не попал в руки первоначального предполагаемого получателя. Однако, корпорация Nanotrasen запрещает использование любой имеющейся в данном документе информации третьими лицами и сообщает, что это преследуется по закону, даже если информация в данном документе не является достоверной. <center></font>"

//Медицинский Отдел

/obj/item/paper/form/NT_MD_01
	name = "Форма NT-MD-01"
	id = "NT-MD-01"
	altername = "Постановление на поставку медикаментов"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашиваю следующие медикаменты на поставку в медбей:<br><b><span class=\"paper_field\"></span></b><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center>Подпись заказчика: <span class=\"paper_field\"></span><br>Подпись грузчика: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче грузчику или производившему поставку.</font></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_MD_02
	name = "Форма NT-MD-02"
	id = "NT-MD-02"
	altername = "Отчёт о вскрытии"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Основная информация</b></font></center><br><table></td><tr><td>Скончавшийся:<td><span class=\"paper_field\"></span><br></td><tr><td>Раса:<td><span class=\"paper_field\"></span><br></td><tr><td>Пол:<td><span class=\"paper_field\"></span><br></td><tr><td>Возраст:<td><span class=\"paper_field\"></span><br></td><tr><td>Группа крови:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность:<td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Отчёт о вскрытии</b></font></center><br><table></td><tr><td>Тип смерти:<td><span class=\"paper_field\"></span><br></td><tr><td>Описание тела:<td><span class=\"paper_field\"></span><br></td><tr><td>Метки и раны:<td><span class=\"paper_field\"></span><br></td><tr><td>Вероятная причина смерти:<td><span class=\"paper_field\"></span><br></td></tr></table><br>Детали:<br><span class=\"paper_field\"></span><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Вскрытие провёл:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_MD_03
	name = "Форма NT-MD-03"
	id = "NT-MD-03"
	altername = "Постановление на изготовление химических препаратов"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашиваю следующие химические медикаменты, для служебного использования в медбее:<br><b><span class=\"paper_field\"></span></b><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center>Подпись заказчика: <span class=\"paper_field\"></span><br>Подпись исполняющего: <span class=\"paper_field\"></span><br>Время заказа: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче лицу исполнившему заказ</font></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_MD_04
	name = "Форма NT-MD-04"
	id = "NT-MD-04"
	altername = "Сводка о вирусе"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><b>Вирус: <span class=\"paper_field\"></span></b></center><br><i>Полное название вируса: <span class=\"paper_field\"></span><br>Свойства вируса: <span class=\"paper_field\"></span><br>Передача вируса: <span class=\"paper_field\"></span><br>Побочные эффекты: <span class=\"paper_field\"></span><br><br>Дополнительная информация: <span class=\"paper_field\"></span><br><br>Лечение вируса: <span class=\"paper_field\"></span><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись вирусолога: <span class=\"paper_field\"></span><hr><font size = \"1\">*В дополнительной информации, указывается вся остальная информация, по поводу данного вируса.</font><br></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_MD_05
	name = "Форма NT-MD-05"
	id = "NT-MD-05"
	altername = "Отчет об психологическом состоянии"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><br>Пациент: <span class=\"paper_field\"></span><br>Раздражители: <span class=\"paper_field\"></span><br>Симптомы и побочные действия: <span class=\"paper_field\"></span><br>Дополнительная информация: <span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись психолога: <span class=\"paper_field\"></span><br>Время обследования: <span class=\"paper_field\"></span><br><hr><i><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче пациенту</i></font></font>"
	footer = footer_signstamp

//Мед-без нумерации
/obj/item/paper/form/NT_MD_VRR
	name = "Форма NT-MD-VRR"
	id = "NT-MD-VRR"
	altername = "Запрос на распространение вируса"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Основная информация</b></font></center><br>Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, запрашиваю право на распространение вируса среди экипажа станции.<br><table></td><tr><td>Название вируса:<td><span class=\"paper_field\"></span><br></td><tr><td>Задачи вируса:<td><span class=\"paper_field\"></span><br></td><tr><td>Лечение:<td><span class=\"paper_field\"></span><br></td><tr><td>Вакцина была произведена<br> и в данный момент находится:<td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Подпись вирусолога:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись глав. Врача:<td><span class=\"paper_field\"></span><br></td></tr></td><tr><td>Подпись капитана:<td><span class=\"paper_field\"></span><br></td></tr></table><hr><small>*Производитель вируса несет полную ответственность за его распространение, изолирование и лечение<br>*При возникновении опасных или смертельных побочных эффектов у членов экипажа, производитель должен незамедлительно предоставить вакцину, от данного вируса.</small></font>"
	footer = footer_signstamp

//Исследовательский отдел
/obj/item/paper/form/NT_RND_01
	name = "Форма NT-RND-01"
	id = "NT-RND-01"
	altername = "Отчет о странном предмете"
	category = "Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black><br>Название предмета: <span class=\"paper_field\"></span><br>Тип предмета: <span class=\"paper_field\"></span><br>Строение: <span class=\"paper_field\"></span><br>Особенности и функционал: <span class=\"paper_field\"></span><br>Дополнительная информация: <span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись производившего осмотр: <span class=\"paper_field\"></span><br><hr><i><font size = \"1\">*В дополнительной информации, рекомендуется указать остальную информацию о предмете, любое взаимодействие с ним, модификации, итоговый вариант после модификации.</i></font></font>"

/obj/item/paper/form/NT_RND_02
	name = "Форма NT-RND-02"
	id = "NT-RND-02"
	altername = "Заявление на киберизацию"
	category = "Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, самовольно подтверждаю согласие на проведение киберизации.<br>⠀⠀⠀ Я полностью доверяю работнику <span class=\"paper_field\"></span> в должности – <span class=\"paper_field\"></span>. Я хорошо осведомлен о рисках, связанных как с операцией, так и с киберизацией, и понимаю, что Nanotrasen не несет ответственности, если эти процедуры вызовут боль, заражение или иные случаи летального характера.<br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись заявителя: <span class=\"paper_field\"></span><br>Подпись уполномоченного: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Если член экипажа мертв, данный документ нету необходимости создавать.<br>*Если член экипажа жив, данный документ сохраняется только у уполномоченного лица.<br>*Данный документ может использоваться как для создания киборгов, так и для ИИ<font size = \"1\"></font>"

/obj/item/paper/form/NT_RND_03
	name = "Форма NT-RND-03"
	id = "NT-RND-03"
	altername = "Заявление на получение и установку импланта"
	category = "Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Заявление</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Требуемый имплантат:<br><font size = \"1\">Может требовать дополнительного согласования</font><td><span class=\"paper_field\"></span><br></td><tr><td>Причина:<br><font size = \"1\">Объясните свои намерения</font><br><span class=\"paper_field\"></span><br><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Дата и время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись Руководителя Исследований:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись выполняющего установку имплантата:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"

//Общие формы
/obj/item/paper/form/NT_BLANK
	name = "Форма NT"
	id = "NT-BLANK"
	altername = "Пустой бланк для любых целей"
	category = "Общие формы"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Основная информация</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Заявление</b></font></center><br><span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись (дополнительная):<td><span class=\"paper_field\"></span></font>"
	footer = null

/obj/item/paper/form/NT_E_112
	name = "Форма NT-E-112"
	id = "NT-E-112"
	altername = "Экстренное письмо"
	category = "Общие формы"
	notice = "Форма предназначена только для экстренного использования."
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Основная информация</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Отчёт о ситуации</b></font></center><br><span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_signstamp

//Отдел кадров
/obj/item/paper/form/NT_HR_00
	name = "Форма NT-HR-00"
	id = "NT-HR-00"
	altername = "Бланк заявления"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Основная информация</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Заявление</b></font></center><br><span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись (дополнительная):<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_HR_01
	name = "Форма NT-HR-01"
	id = "NT-HR-01"
	altername = "Заявление о приеме на работу"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Заявление</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Запрашиваемая должность:<br><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><br></td><tr><td>Список компетенций:<br><span class=\"paper_field\"></span><br><br></td></tr></table></font><font face=\"Verdana\" color=black><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись будущего главы:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"

/obj/item/paper/form/NT_HR_02
	name = "Форма NT-HR-02"
	id = "NT-HR-02"
	altername = "Заявление на смену должности"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Заявление</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Запрашиваемая должность:<br><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><br></td><tr><td>Причина:<br><font size = \"1\">Объясните свои намерения</font><br><span class=\"paper_field\"></span><br><br></td></tr></table><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись будущего главы:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"

/obj/item/paper/form/NT_HR_12
	name = "Форма NT-HR-12"
	id = "NT-HR-12"
	altername = "Приказ на смену должности"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Приказ</b></font></center><br><table></td><tr><td>Имя сотрудника:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта сотрудника:<br><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Запрашиваемая должность:<br><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><br></td><tr><td>Причина:<br><font size = \"1\">Объясните свои намерения</font><br><span class=\"paper_field\"></span><br><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись инициатора:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"

/obj/item/paper/form/NT_HR_03
	name = "Форма NT-HR-03"
	id = "NT-HR-03"
	altername = "Заявление об увольнении"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Заявление</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Причина:<br><font size = \"1\">Объясните свои намерения</font><br><span class=\"paper_field\"></span><br><br></td></tr></table><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"

/obj/item/paper/form/NT_HR_13
	name = "Форма NT-HR-13"
	id = "NT-HR-13"
	altername = "Приказ об увольнении"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Приказ</b></font></center><br><table></td><tr><td>Имя увольняемого:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта увольняемого:<br><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Причина:<br><font size = \"1\">Объясните свои намерения</font><br><span class=\"paper_field\"></span><br><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись инициатора:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"

/obj/item/paper/form/NT_HR_04
	name = "Форма NT-HR-04"
	id = "NT-HR-04"
	altername = "Заявление на выдачу новой ID карты"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Заявление</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Причина:<br><font size = \"1\">Объясните свои намерения</font><br><span class=\"paper_field\"></span><br><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"

/obj/item/paper/form/NT_HR_05
	name = "Форма NT-HR-05"
	id = "NT-HR-05"
	altername = "Заявление на дополнительный доступ"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Заявление</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Требуемый доступ:<br><font size = \"1\">Может требовать дополнительного согласования</font><td><span class=\"paper_field\"></span><br></td><tr><td>Причина:<br><font size = \"1\">Объясните свои намерения</font><br><span class=\"paper_field\"></span><br><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"

/obj/item/paper/form/NT_HR_06
	name = "Форма NT-HR-06"
	id = "NT-HR-06"
	altername = "Лицензия на создание организации/отдела"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size = \"4\"><b>Заявление</b></font></i></center><br><br>Я <b><span class=\"paper_field\"></span></b>, прошу Вашего разрешения на создание <b><span class=\"paper_field\"></span></b> для работы с экипажем.<br><br>Наше Агенство/Отдел займет <b><span class=\"paper_field\"></span></b>.<br><br>Наша Организация обязуется соблюдать Космический Закон. Также я <b><span class=\"paper_field\"></span></b>, как глава отдела, буду нести ответственность за своих сотрудников и обязуюсь наказывать их за несоблюдение Космического Закона. Или же передавать сотрудникам Службы Безопасности.<br><br><hr><br><center><i><font size=\"4\"><b>Подписи и штампы</b></font></i></center><br><i><br>Время: <span class=\"paper_field\"></span><br><br>Подпись заявителя: <span class=\"paper_field\"></span><br><br>Подпись главы персонала: <span class=\"paper_field\"></span></i><br><hr><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан обладателю лицензии.</font><br><br><font size = \"1\">*Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет являться недействительной.</font></font>"

/obj/item/paper/form/NT_HR_07
	name = "Форма NT-HR-07"
	id = "NT-HR-07"
	altername = "Разрешение на перестройку/перестановку"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><font size=\"4\"><b>Разрешение</b></font></i></center><br>Я <b><span class=\"paper_field\"></span></b>, прошу Вашего разрешения на перестройку/перестановку помещения <b><span class=\"paper_field\"></span></b> под свои нужды или нужды организации.<br><br>Должность заявителя: <span class=\"paper_field\"></span><br><br><hr><br><center><i><font size=\"4\"><b>Подписи и штампы</b></font></i></center><br><i><br>Время: <span class=\"paper_field\"></span><br><br>Подпись заявителя: <span class=\"paper_field\"></span><br><br>Подпись главы персонала: <span class=\"paper_field\"></span></i><br><br><hr><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан заявителю.</font></font>"

/obj/item/paper/form/NT_HR_08
	name = "Форма NT-HR-08"
	id = "NT-HR-08"
	altername = "Запрос о постройке меха"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, прошу произвести постройку меха – <b><span class=\"paper_field\"></span></b>, с данными модификациями – <i><span class=\"paper_field\"></span></i>, для выполнения задач: <i><span class=\"paper_field\"></span></i>.<br>⠀⠀⠀Так же я, <span class=\"paper_field\"></span>, обязуюсь соблюдать все правила, законы и предупреждения, а также соглашаюсь выполнять все устные или письменные инструкции, или приказы со стороны командования, представителей или агентов Nanotrasen, и Центрального командования.<br>⠀⠀⠀При получении меха, я становлюсь ответственным за его повреждение, уничтожение, похищение, или попадание в руки людей, относящимся к врагам Nanotrasen.<br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись заявителя: <span class=\"paper_field\"></span><br>Время постройки меха: <span class=\"paper_field\"></span><br>Время передачи меха заявителю: <span class=\"paper_field\"></span><br>Подпись изготовителя меха: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.</font></font>"

/obj/item/paper/form/NT_HR_09
	name = "Форма NT-HR-09"
	id = "NT-HR-09"
	altername = "Квитанция о продаже пода"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span> произвожу передачу транспортного средства на платной основе члену экипажа <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>. Продаваемый под имеет модификации: <span class=\"paper_field\"></span>. Стоимость пода: <b><span class=\"paper_field\"></span></b>.<br>⠀⠀⠀Я, <span class=\"paper_field\"></span>, как покупатель, становлюсь ответственным за его повреждение, уничтожение, похищение, или попадание в руки людей, относящимся к врагам Nanotrasen.<br>⠀⠀⠀Так же я, обязуюсь соблюдать все правила, законы и предупреждения, а также соглашаюсь выполнять все устные или письменные инструкции, или приказы со стороны командования, представителей или агентов Nanotrasen, и Центрального командования.<br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись продавца: <span class=\"paper_field\"></span><br>Подпись покупателя: <span class=\"paper_field\"></span><br>Время сделки: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче покупателю.</font></font>"

//Отдел сервиса
/obj/item/paper/form/NT_MR
	name = "Форма NT-MR"
	id = "NT-MR"
	altername = "Свидетельство о заключении брака"
	category = "Отдел сервиса"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Объявляется, что <span class=\"paper_field\"></span>, и <span class=\"paper_field\"></span>, официально прошли процедуру заключения гражданского брака.<br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись уполномоченного: <span class=\"paper_field\"></span><br>Подпись свидетеля: <span class=\"paper_field\"></span><br>Подпись свидетеля: <span class=\"paper_field\"></span><br><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче одному из представителей брака.<br>*При заявлении о расторжении брака, необходимо наличие двух супругов, и данного документа.</font></font>"

/obj/item/paper/form/NT_MRL
	name = "Форма NT-MRL"
	id = "NT-MRL"
	altername = "Заявление о расторжении брака"
	category = "Отдел сервиса"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Просим произвести регистрацию расторжения брака, подтверждаем взаимное согласие на расторжение брака.<br><br></center><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись супруга: <span class=\"paper_field\"></span><br>Подпись супруги: <span class=\"paper_field\"></span><br><br>Подпись уполномоченного: <span class=\"paper_field\"></span><br><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче каждому, из супругов.</font></font>"

//Отдел снабжения
/obj/item/paper/form/NT_REQ_01
	name = "Форма NT-REQ-01"
	id = "NT-REQ-01"
	altername = "Запрос на поставку"
	category = "Отдел снабжения"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Сторона запроса</b></font></center><br><table></td><tr><td>Имя запросившего:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Способ получения:<br><font size = \"1\">Предпочитаемый способ</font><td><span class=\"paper_field\"></span><br></td><tr><td><br>Причина запроса:<br><span class=\"paper_field\"></span><br><br></td><tr><td>Список запроса:<br><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Сторона поставки</b></font></center><br><table></td><tr><td>Имя поставщика:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td><tr><td>Способ доставки:<br><font size = \"1\">Утверждённый способ</font><td><span class=\"paper_field\"></span><br></td><tr><td><br>Комментарии:<br><span class=\"paper_field\"></span><br><br></td><tr><td>Список поставки и цены:<br><span class=\"paper_field\"></span><br><br></td><tr><td>Итоговая стоимость:<br><font size = \"1\">Пропустите, если бесплатно</font><td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись стороны запроса:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись стороны поставки:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись главы (если требуется):<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_SUP_01
	name = "Форма NT-SUP-01"
	id = "NT-SUP-01"
	altername = "Регистрационная форма для подтверждения заказа"
	category = "Отдел снабжения"
	info = "<font face=\"Verdana\" color=black><center><h3>Отдел снабжения</h3></center><center><b>Регистрационная форма для подтверждения заказа</b></center><br>Имя заявителя: <span class=\"paper_field\"></span><br>Должность заявителя: <span class=\"paper_field\"></span><br>Подробное объяснение о необходимости заказа: <span class=\"paper_field\"></span><br><br>Время: <span class=\"paper_field\"></span><br>Подпись заявителя: <span class=\"paper_field\"></span><br>Подпись руководителя: <span class=\"paper_field\"></span><br>Подпись сотрудника снабжения: <span class=\"paper_field\"></span><br><hr><center><font size = \"1\"><i>Данная форма является приложением для оригинального автоматического документа, полученного с рук заявителя. Для подтверждения заказа заявителя необходимы указанные подписи и соответствующие печати отдела по заказу.<br></font>"
	footer = null

//Служба безопасности
/obj/item/paper/form/NT_SEC_01
	name = "Форма NT-SEC-01"
	id = "NT-SEC-01"
	altername = "Свидетельские показания"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Информация о свидетеле</b></font></center><br><table></td><tr><td>Имя свидетеля:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта свидетеля:<br><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><br></td><tr><td>Должность свидетеля:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Свидетельство </b></font></center><br><span class=\"paper_field\"></span><br><br><font size = \"1\">Я, (подпись свидетеля) <span class=\"paper_field\"></span>, подтверждаю, что приведенная выше информация является правдивой и точной, насколько мне известно, и передана в меру моих возможностей. Подписываясь ниже, я тем самым подтверждаю, что Верховный Суд может признать меня неуважительным или виновным в лжесвидетельстве согласно Закону SolGov 552 (a) (c) и Постановлению корпорации Nanotrasen 7716 (c).</font><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись сотрудника, получающего показания:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_11
	name = "Форма NT-SEC-11"
	id = "NT-SEC-11"
	altername = "Ордер на обыск"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Информация о свидетеле</b></font></center><br><table></td><tr><td>Имя свидетеля:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта свидетеля:<br><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><br></td><tr><td>Должность свидетеля:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Ордер</b></font></center><br><table></td><tr><td>В целях обыска:<br><font size = \"1\">(помещения, имущества, лица)</font><td><span class=\"paper_field\"></span></td></tr></table><br>Ознакомившись с письменными показаниями свидетеля(-ей), у меня появились основания полагать, что на лицах или помещениях, указанных выше, имеются соответствующие доказательства в этой связи или в пределах, в частности:<br><br><span class=\"paper_field\"></span><br><br>и другое имущество, являющееся доказательством уголовного преступления, контрабанды, плодов преступления или предметов, иным образом принадлежащих преступнику, или имущество, спроектированное или предназначенное для использования, или которое используется или использовалось в качестве средства совершения уголовного преступления, в частности заговор с целью совершения преступления, или совершения злонамеренного предъявления ложных и фиктивных претензий к или против корпорации НаноТрейзен или его дочерних компаний.<br><br>Я удовлетворен тем, что показания под присягой и любые записанные показания устанавливают вероятную причину полагать, что описанное имущество в данный момент скрыто в описанных выше помещениях, лицах или имуществе, и устанавливают законные основания для выдачи этого ордера.<br><br>ВЫ НАСТОЯЩИМ КОМАНДИРОВАНЫ для обыска вышеуказанного помещения, имущества или лица в течение <span class=\"paper_field\"></span> минут с даты выдачи настоящего ордера на указанное скрытое имущество, и если будет установлено, что имущество изъято, оставить копию этого ордера в качестве доказательства на реквизированную собственность, в соответствии с требованиями указа корпорации Nanotrasen.<br><br>Слава Корпорации Nanotrasen!<br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_21
	name = "Форма NT-SEC-21"
	id = "NT-SEC-21"
	altername = "Ордер на арест"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Ордер</b></font></center><br><table></td><tr><td>В целях ареста:<br><font size = \"1\">Имя полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Должность:<td><span class=\"paper_field\"></span><br></td></tr></table><br>Сотрудники Службы Безопасности настоящим уполномочены и направлены на задержание и арест указанного лица. Они будут игнорировать любые заявления о неприкосновенности или привилегии со стороны подозреваемого или агентов, действующих от его имени. Сотрудники немедленно доставят указанное лицо в Бриг для отбывать наказание за следующие преступления:<br><br><span class=\"paper_field\"></span><br><br>Предполагается, что подозреваемый будет отбывать наказание в <span class=\"paper_field\"></span> за вышеуказанные преступления.<br><br>Слава Корпорации Nanotrasen!<br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_02
	name = "Форма NT-SEC-02"
	id = "NT-SEC-02"
	altername = "Отчёт по результатам расследования"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Дело <span class=\"paper_field\"></span></b></font></center><br><table></td><tr><td>Тип проишествия/преступления:<td><span class=\"paper_field\"></span><br></td><tr><td>Время проишествия/преступления:<td><span class=\"paper_field\"></span><br></td><tr><td>Местоположение:<td><span class=\"paper_field\"></span><br></td><tr><td>Краткое описание:<td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Участвующие лица</b></font></center><br><table></td><tr><td>Арестованные:<td><span class=\"paper_field\"></span><br></td><tr><td>Подозреваемые:<td><span class=\"paper_field\"></span><br></td><tr><td>Свидетели:<td><span class=\"paper_field\"></span><br></td><tr><td>Раненные:<td><span class=\"paper_field\"></span><br></td><tr><td>Пропавшие:<td><span class=\"paper_field\"></span><br></td><tr><td>Скончавшиеся:<td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Ход расследования</b></font></center><br><span class=\"paper_field\"></span><br><br><table></td><tr><td>Прикреплённые доказательства:<td><span class=\"paper_field\"></span><br></td><tr><td>Дополнительные замечания:<td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_03
	name = "Форма NT-SEC-03"
	id = "NT-SEC-03"
	altername = "Заявление о краже"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, заявляю:<span class=\"paper_field\"></span><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись потерпевшего: <span class=\"paper_field\"></span><br>Подпись принимавшего заявление: <span class=\"paper_field\"></span><br>Время принятия заявления: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче потерпевшему.<br>*При обнаружении предмета кражи (предмет, жидкость или существо), данный предмет необходимо передать детективу, для дальнейшего осмотра и обследования.<br>*После заключения детектива, предмет можно выдать владельцу. </font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_04
	name = "Форма NT-SEC-04"
	id = "NT-SEC-04"
	altername = "Заявление о причинении вреда здоровью или имуществу"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, заявляю:<span class=\"paper_field\"></span><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись пострадавшего: <span class=\"paper_field\"></span><br>Время происшествия: <span class=\"paper_field\"></span><br>Подпись уполномоченного: <span class=\"paper_field\"></span><br>Время принятия заявления: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче пострадавшему.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_05
	name = "Форма NT-SEC-05"
	id = "NT-SEC-05"
	altername = "Разрешение на оружие"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Члену экипажа, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, было выдано разрешение на оружие. Я соглашаюсь с условиями его использования, хранения и применения. Данное оружие я обязуюсь применять только в целях самообороны, защиты своих личных вещей, и рабочего места, а так же для защиты своих коллег.<br>⠀⠀⠀При попытке применения оружия, против остальных членов экипажа не предоставляющих угрозу, или при запугивании данным оружием, я лишаюсь лицензии на оружие, а так же понесу наказания, при нарушении закона.<br><i><b><br>Название и тип оружия: <span class=\"paper_field\"></span></b><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись уполномоченного: <span class=\"paper_field\"></span><br>Подпись получателя: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче получателю.<br>*Документ не является действительным без печати Вардена/ГСБ и его подписи.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_06
	name = "Форма NT-SEC-06"
	id = "NT-SEC-06"
	altername = "Разрешение на присваивание канала связи"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><font size=\"4\"><b>Разрешение</b></font></i></center><br>Я <b><span class=\"paper_field\"></span></b>, прошу Вашего разрешения на присваивание канала связи <b><span class=\"paper_field\"></span></b>, для грамотной работы организации.<br><br>Должность заявителя: <span class=\"paper_field\"></span><br><br><hr><br><center><i><font size=\"4\"><b>Подписи и штампы</b></font></i></center><br><i><br>Время: <span class=\"paper_field\"></span><br><br>Подпись заявителя: <span class=\"paper_field\"></span><br><br>Подпись главы персонала: <span class=\"paper_field\"></span><br><br>Подпись главы службы безопасности: <span class=\"paper_field\"></span></i><br><br><hr><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан заявителю.</font><br><br><font size = \"1\">*Обязательно провести копирование документа для службы безопасности.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_07
	name = "Форма NT-SEC-07"
	id = "NT-SEC-07"
	altername = "Лицензия на использование канала связи и владение дополнительным оборудованием"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><font size=\"4\"><b>Лицензия</b></font></i></center><br>Имя обладателя лицензии: <span class=\"paper_field\"></span><br><br>Должность обладателя лицензии: <span class=\"paper_field\"></span><br><br>Зарегистрированный канал связи: <span class=\"paper_field\"></span><br><br>Перечень зарегистрированной экипировки: <span class=\"paper_field\"></span><br><hr><br><center><i><font size=\"4\"><b>Подписи и штампы</b></font></i></center><br><i><br>Время: <span class=\"paper_field\"></span><br><br>Подпись заявителя: <span class=\"paper_field\"></span><br><br>Подпись главы персонала: <span class=\"paper_field\"></span><br><br>Подпись главы службы безопасности: <span class=\"paper_field\"></span></i><br><hr><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан обладателю лицензии.</font><br><br><font size = \"1\">*Обязательно провести копирование документа для службы безопасности.</font><br><br><font size = \"1\">*Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет являться недействительной.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_08
	name = "Форма NT-SEC-08"
	id = "NT-SEC-08"
	altername = "Лицензирование вооружения и экипировки для исполнения деятельности"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><font size=\"4\"><b>Лицензия</b></font></i></center><br><br>Имя обладателя лицензии: <span class=\"paper_field\"></span><br>Должность обладателя лицензии: <span class=\"paper_field\"></span><br>Перечень зарегистрированного вооружения: <span class=\"paper_field\"></span><br>Перечень зарегистрированной экипировки: <span class=\"paper_field\"></span><br><br><hr><br><center><i><font size=\"4\"><b>Подписи и штампы</b></font></i></center><br><br>Время: <span class=\"paper_field\"></span><br>Подпись обладателя  лицензии: <span class=\"paper_field\"></span><br>Подпись главы службы безопасности: <span class=\"paper_field\"></span><br><br><hr><font size = \"1\"><i> *Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет является недействительной. Обязательно провести копирование документа для службы безопасности, оригинал документа должен быть выдан обладателю лицензии. В случае несоответствия должности обладателя лицензии, можно приступить к процедуре аннулирования лицензии и изъятию вооружения, экипировки.<br></font>"
	footer = footer_confidential

//Юридический отдел
/obj/item/paper/form/NT_LD_00
	name = "Форма NT-LD-00"
	id = "NT-LD-00"
	altername = "Бланк заявления"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Основная информация</b></font></center><br><table></td><tr><td>Имя заявителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Номер аккаунта заявителя:<br><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><br></td><tr><td>Текущая должность:<br><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Заявление</b></font></center><br><span class=\"paper_field\"></span><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного сотрудника:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_LD_01
	name = "Форма NT-LD-01"
	id = "NT-LD-01"
	altername = "Судебный приговор"
	category = "Юридический отдел"
	notice = "Данный документ является законным решением суда.<br>Пожалуйста внимательно прочитайте его и следуйте предписаниям, указанные в нем."
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Дело <span class=\"paper_field\"></span></b></font></center><br><table></td><tr><td>Имя обвинителя:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td><tr><td>Имя обвиняемого:<br><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><br></td></tr></table><br><center><font size=\"4\"><b>Приговор</b></font></center><br><span class=\"paper_field\"></span><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_02
	name = "Форма NT-LD-02"
	id = "NT-LD-02"
	altername = "Смертный приговор"
	category = "Юридический отдел"
	notice = "Любой смертный приговор, выданный человеком, званием младше, чем капитан, является не действительным, и все казни, действующие от этого приговора являются незаконными. Любой, кто незаконно привел в исполнение смертный приговор действую согласно ложному ордену виновен в убийстве первой степени, и должен быть приговорен минимум к пожизненному заключению и максимум к кибернизации. Этот документ или его факс-копия являются Приговором, который может оспорить только Магистрат или Дивизией защиты активов Nanotrasen (далее именуемой «Компанией»)"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Дело <span class=\"paper_field\"></span></b></font></center><br>Принимая во внимание, что <span class=\"paper_field\"></span> <font size = \"1\">(далее именуемый \"подсудимый\")</font>, <br>сознательно совершил преступления статей Космического закона <font size = \"1\">(далее указаны как \"преступления\")</font>, <br>а именно: <span class=\"paper_field\"></span>, <br>суд приговаривает подсудимого к смертной казни через <span class=\"paper_field\"></span>.<br><br>Приговор должен быть приведен в исполнение в течение 15 минут после получения данного приказа. Вещи подсудимого, включая ID-карту, ПДА, униформу и рюкзак, должны быть сохранены и переданы соответствующем органам (ID-карту передать главе персонала или капитану для уничтожения), возвращены в соответсвующий отдел или сложены в хранилище улик. Любая контрабанда должна немедленно помещена в хранилище улик. Любую контрабанду запрещено использовать защитой активов или другими персонами, представляющих компанию или её активы и цели, кроме сотрудников отдела исследований и развития.<br><br>Тело подсудимого должно быть помещено в морг и забальзамировано, только если данное действие не будет нести опасность станции, активам компании или её имуществу. Останки подсудимого должны быть собраны и подготовлены к доставке к близлежащему административному центру компании, всё имущество и активы должны быть переданы семье подсудимого после окончания смены.<br><br>Слава Nanotrasen!<br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_03
	name = "Форма NT-LD-03"
	id = "NT-LD-03"
	altername = "Заявление о нарушении СРП членом экипажа"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black><br>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю, что член экипажа – <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, нарушил один (или несколько) пунктов из <i>Стандартных Рабочих Процедур</i>, а именно:<span class=\"paper_field\"></span><br><br>Примерное время нарушения: <span class=\"paper_field\"></span><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись заявителя: <span class=\"paper_field\"></span><br>Подпись принимающего: <span class=\"paper_field\"></span><br>Время принятия заявления: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.<br>*После вынесения решения в отношении правонарушителя, желательно сообщить о решении заявителю.<br></font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_04
	name = "Форма NT-LD-04"
	id = "NT-LD-04"
	altername = "Заявление о нарушении СРП одним из отделов"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black><br>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю, что сотрудники в отделении <span class=\"paper_field\"></span>, нарушили один (или несколько) пунктов из <i>Стандартных Рабочих Процедур</i>, а именно:<span class=\"paper_field\"></span><br><br>Примерное время нарушения: <span class=\"paper_field\"></span><br>Подпись заявителя: <span class=\"paper_field\"></span><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись принимающего: <span class=\"paper_field\"></span><br>Время принятия заявления: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.<br>*После вынесения решения в отношении правонарушителей, желательно сообщить о решении заявителю.<br></font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_05
	name = "Форма NT-LD-05"
	id = "NT-LD-05"
	altername = "Отчет агента внутренних дел"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black>ᅠᅠЯ, <span class=\"paper_field\"></span>, Как агент внутренних дел, сообщаю:<span class=\"paper_field\"></span><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br>Подпись АВД: <span class=\"paper_field\"></span><br>Подпись уполномоченного: <span class=\"paper_field\"></span><br>Время принятия отчета: <span class=\"paper_field\"></span><br><hr><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче агенту.<br>*Данный документ может содержать нарушения, неправильность выполнения работы, невыполнение правил/сводов/законов/СРП </font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_06
	name = "Форма NT-LD-06"
	id = "NT-LD-06"
	altername = "Бланк жалоб АВД"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black><br><center><i><font size=\"4\"><b>Заявление</b></font></i></center><br><br><br><b>Заявитель: </b><span class=\"paper_field\"></span><br><font size = \"1\">Укажите своё полное имя, должность и номер акаунта.</font><br><b>Предмет жалобы:</b><span class=\"paper_field\"></span><br><font size = \"1\">Укажите на что/кого вы жалуетесь.</font><br><b>Обстоятельства: </b><span class=\"paper_field\"></span><br><font size = \"1\">Укажите подробные обстоятельства произошедшего.</font><br><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><b>Подпись: </b><span class=\"paper_field\"></span><br><font size = \"1\">Ваша подпись.</font><br><b>Жалоба рассмотрена: </b><span class=\"paper_field\"></span><br><font size = \"1\">Имя и фамилия рассмотревшего.</font><br><br><hr><br><font size = \"1\"><i>*Обязательно провести копирование документа для агента внутренних дел, оригинал документа должен быть приложен к отчету о расследовании. Копия документа должна быть сохранена в картотеке офиса агента внутренних дел.</font><br><br><font size = \"1\"><i>*Обязательно донести жалобу до главы отдела, который отвечает за данного сотрудника, если таковой имеется. Если главы отдела нет на смене или он отсуствует по какой то причине, жалобу следует донести до вышестоящего сотрудника станции.</font><br><br><font size = \"1\"><i>*Если жалоба была написана на главу отдела, следует донести жалобу до вышестоящего сотрудника станции.</font><br><br><font size = \"1\"><i>*Глава отдела, которому была донесена жалоба, обязан провести беседу с указаным в жалобе сотрудником станции. В зависимости от тяжести проступка, глава отдела имеет право подать приказ об увольнении.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_DENY
	name = "Форма NT-LD-DENY"
	id = "NT-LD-DENY"
	altername = "Запрет на реанимацию"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black>Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, сообщаю о постановлении запрета на реанимацию в отношении: <span class=\"paper_field\"></span><br><font size=\"1\">Указать имя члена экипажа.</font><br><br>Исходя из того, что вышеупомянутый член экипажа попал под действие особых случаев применения летальной силы, а именно: <span class=\"paper_field\"></span><br><font size=\"1\">Описать особый случай применения летальной силы указанный в СРП СБ.</font><br><br>Тело члена экипажа должно быть помещено в морг, ксерокопия данного документа должна находиться в картотеке патологоанатома, либо приложена к мешку с трупом подсудимого. Служебное оборудование данного члена экипажа должно быть передано вышестоящему главе отдела. Личные вещи не нарушающий Космический Закон должны оставаться вместе с членом экипажа, либо в ячейке морга.<br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Дата и время:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><font size =\"1\">Данный документ является недействительным при отсутствии подписи и печати уполномоченного лица.<br>Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и хранения одного экземпляра в картотеке патологоанатома, либо в мешке для трупов с вышеуказанным членом экипажа.</font></font>"
	footer = null

//Центральное командование
/obj/item/paper/form/NT_COM_01
	name = "Форма NT-COM-01"
	id = "NT-COM-01"
	altername = "Запрос отчёта общего состояния станции"
	category = "Центральное командование"
	from = "Административный корабль Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Запрос</b></font></center><br>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения об общем состоянии станции.<br><br><hr><br><center><font size=\"4\"><b>Ответ</b></font></center><br><table></td><tr><td>Общее состояние станции:<td><span class=\"paper_field\"></span><br></td><tr><td>Криминальный статус:<td><span class=\"paper_field\"></span><br></td></tr></table><br><table></td><tr><td>Повышений:<td><span class=\"paper_field\"></span><br></td><tr><td>Понижений:<td><span class=\"paper_field\"></span><br></td><tr><td>Увольнений:<td><span class=\"paper_field\"></span><br></td></tr></table><br><table></td><tr><td>Раненные:<td><span class=\"paper_field\"></span><br></td><tr><td>Пропавшие:<td><span class=\"paper_field\"></span><br></td><tr><td>Скончавшиеся:<td><span class=\"paper_field\"></span><br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_02
	name = "Форма NT-COM-02"
	id = "NT-COM-02"
	altername = "Запрос отчёта состояния трудовых активов станции"
	category = "Центральное командование"
	from = "Административный корабль Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Запрос</b></font></center><br>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения о состоянии трудовых активов станции.<br><br><hr><br><center><font size=\"4\"><b>Ответ</b></font></center><br><table></td><tr><td>Количество сотрудников:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество гражданских:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество киборгов:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество ИИ:<td><span class=\"paper_field\"></span><br></td></tr></table><br><table></td><tr><td>Заявлений о приёме на работу:<td><span class=\"paper_field\"></span><br></td><tr><td>Заявлений на смену должности:<td><span class=\"paper_field\"></span><br></td><tr><td>Приказов на смену должности:<td><span class=\"paper_field\"></span><br></td><tr><td>Заявлений об увольнении:<td><span class=\"paper_field\"></span><br></td><tr><td>Приказов об увольнении:<td><span class=\"paper_field\"></span><br></td><tr><td>Заявлений на выдачу новой ID карты:<td><span class=\"paper_field\"></span><br></td><tr><td>Заявлений на дополнительный доступ:<td><span class=\"paper_field\"></span><br></td></tr></table><br><table></td><tr><td>Медианный уровень кваллификации смены:<td><span class=\"paper_field\"></span><br></td><tr><td>Уровень взаимодействия отделов:<td><span class=\"paper_field\"></span><br></td><tr><td>Самый продуктивный отдел смены:<td><span class=\"paper_field\"></span><br></td></tr></table><br><table></td><tr><td>Приложите все имеющиеся документы:<td>NT-HR-00<br></td><tr><td><td>NT-HR-01<br></td><tr><td><td>NT-HR-02<br></td><tr><td><td>NT-HR-12<br></td><tr><td><td>NT-HR-03<br></td><tr><td><td>NT-HR-13<br></td><tr><td><td>NT-HR-04<br></td><tr><td><td>NT-HR-05<br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_03
	name = "Форма NT-COM-03"
	id = "NT-COM-03"
	altername = "Запрос отчёта криминального статуса станции"
	category = "Центральное командование"
	from = "Административный корабль Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><b>Запрос</b></font></center>\
	<br>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения о криминальном статусе станции.\
	<br><br><hr><br><center><font size=\"4\"><b>Ответ</b></font></center><br><table></td>\
	<tr><td>Текущий статус угрозы:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество офицеров в отделе:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество раненных офицеров:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество скончавшихся офицеров:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество серъёзных инцидентов:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество незначительных инцидентов:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество раскрытых дел:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество арестованных:<td><span class=\"paper_field\"></span><br></td><tr><td>Количество сбежавших:<td><span class=\"paper_field\"></span><br></td></tr></table><br><table></td><tr><td>Приложите все имеющиеся документы:<td>NT-SEC-01<br></td><tr><td><td>NT-SEC-11<br></td><tr><td><td>NT-SEC-21<br></td><tr><td><td>NT-SEC-02<br></td><tr><td><td>Лог камер заключения<br></td></tr></table><br><hr><br><center><font size=\"4\"><b>Подписи и штампы</b></font></center><br><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><br></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><br></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><br></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_04
	name = "Форма NT-COM-04"
	id = "NT-COM-04"
	altername = "Запрос отчёта здравоохранения станции"
	category = "Центральное командование"
	from = "Административный корабль Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_05
	name = "Форма NT-COM-05"
	id = "NT-COM-05"
	altername = "Запрос отчёта научно-технического прогресса станции"
	category = "Центральное командование"
	from = "Административный корабль Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_06
	name = "Форма NT-COM-06"
	id = "NT-COM-06"
	altername = "Запрос отчёта инженерного обеспечения станции"
	category = "Центральное командование"
	from = "Административный корабль Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_07
	name = "Форма NT-COM-07"
	id = "NT-COM-07"
	altername = "Запрос отчёта статуса снабжения станции "
	category = "Центральное командование"
	from = "Административный корабль Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

//Синдикатские формы

/obj/item/paper/form/syndieform
	name = "ALERT A CODER SYND FORM"
	altername = "ALERT A CODER FORM"
	access = ACCESS_SYNDICATE_COMMAND
	confidential = TRUE
	category = null
	var/const/footer_to_taipan =   "<i><font face=\"Verdana\" color=black size = \"1\">\
									<hr>\
									*Несоблюдение и/или нарушение указаний, содержащихся в данном письме, карается смертью.\
									<br>*Копирование, распространение и использование содержащейся информации карается смертью, за исключением случаев, описанных в письме.\
									<br>*Письмо подлежит уничтожению после ознакомления.\
									</font></i>"
	var/const/footer_from_taipan = "<i><font face=\"Verdana\" color=black size = \"1\">\
									<hr>\
									*Целевым получателем запроса является Синдикат\
									<br>*Копирование, распространение и использование документа и представленной информации \
									за пределами целевого получателя запроса и экипажа станции запрещено.\
									<br>*Оригинал документа после отправки целевому получателю подлежит хранению в защищённом месте, \
									либо уничтожению с соответствующим указанием.\
									<br>*В случае проникновения на объект посторонних лиц или угрозы проникновения документ подлежит уничтожению до или после отправки.\
									</font></i>"
	footer = footer_to_taipan

/obj/item/paper/form/syndieform/Initialize(mapload)
	. = ..()
	if(is_header_needed)
		header = "	<font face=\"Verdana\" color=black>\
					<table cellspacing=0 cellpadding=3  align=\"right\">\
					<tr><td><img src= syndielogo.png></td></tr>\
					</table><br>\
					<table border=10 cellspacing=0 cellpadding=3 width =\"250\" height=\"100\"  align=\"center\" bgcolor=\"#B50F1D\">\
					<td><center><b>[confidential ? "СОВЕРШЕННО СЕКРЕТНО<br>" : ""]</b><b>[id]</b></center></td>\
					</table>\
					<br><hr></font>"
	populatefields()

/obj/item/paper/form/syndieform/SYND_COM_TC
	name = "Форма SYND-COM-TC"
	id = "SYND-COM-TC"
	altername = "Официальное письмо"
	category = "Синдикат"
	access = ACCESS_SYNDICATE_COMMAND
	footer = footer_to_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><h2><u>Официальное письмо объекту</u><br>&#34;ННКСС Тайпан&#34;</h2></center><hr>\
			<span class=\"paper_field\"></span><br>\
			<font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<br>Дата: <span class=\"paper_field\"></span> \
			<br>Время: <span class=\"paper_field\"></span> \
			<br></font></font>"

/obj/item/paper/form/syndieform/SYND_COM_SUP
	name = "Форма SYND-COM-SUP"
	id = "SYND-COM-SUP"
	altername = "Запрос особой доставки"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><h2>Запрос особой доставки на станцию<br>Синдиката</h2></center><hr>\
			<center><table>\
			<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>\
			<td><center><font size=\"4\">Данные<br>для<br>доставки</font></center><td>\
			<center><b><u><font size=\"4\">Получатель</font></u></b></center>\
			<u>Наименование станции</u>: &#34;ННКСС <b>Тайпан</b>&#34;\
			<br><u>Наименование сектора</u>: Эпсилон Лукусты\
			</td></tr></table>\
			</center><br>В связи с отсутствием в стандартном перечени заказов прошу доставить следующее:\
			<br><ul><li><u><span class=\"paper_field\"></span></u></ul>\
			<br>Причина запроса: <b><span class=\"paper_field\"></span></b>\
			<br><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<br>Дата: <span class=\"paper_field\"></span> \
			<br>Время: <span class=\"paper_field\"></span> \
			<br></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO00
	name = "Форма SYND-TAI-№00"
	id = "SYND-TAI-№00"
	altername = "Экстренное письмо"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><h2><u>Экстренное письмо</u><br>ННКСС &#34;Тайпан&#34;</h2></center><hr>\
			<span class=\"paper_field\"></span>\
			<br><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<br>Дата: <span class=\"paper_field\"></span> \
			<br>Время: <span class=\"paper_field\"></span> \
			<br></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO01
	name = "Форма SYND-TAI-№01"
	id = "SYND-TAI-№01"
	altername = "Отчёт о ситуации на станции"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<h3>Отчёт о ситуации на станции</h3><hr>\
			<u>Наименование станции</u>: ННКСС &#34;Тайпан&#34;<br>\
			<br>Общее состояние станции: <span class=\"paper_field\"></span>\
			<br>Численность персонала станции: <span class=\"paper_field\"></span>\
			<br>Общее состояние персонала станции: <span class=\"paper_field\"></span>\
			<br>Непосредственные внешние угрозы: <b><span class=\"paper_field\"></span></b>\
			<br>Подробности: <span class=\"paper_field\"></span>\
			<br>Дополнительная информация: <span class=\"paper_field\"></span><br>\
			<br><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<br>Дата: <span class=\"paper_field\"></span> \
			<br>Время: <span class=\"paper_field\"></span> \
			<br></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO02
	name = "Форма SYND-TAI-№02"
	id = "SYND-TAI-№02"
	altername = "Отчёт о разработке вируса"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<h3>Отчёт о разработке вируса</h3>\
			<hr><u>Наименование вируса</u>: <b><span class=\"paper_field\"></span></b><br>\
			<br>Тип вируса: <span class=\"paper_field\"></span>\
			<br>Способ распространения: <span class=\"paper_field\"></span>\
			<br>Перечень симптомов: <span class=\"paper_field\"></span>\
			<br>Описание: <span class=\"paper_field\"></span><br>\
			<br><u>Наличие вакцины</u>: <b><span class=\"paper_field\"></span></b>\
			<br><u>Наименование вакцины</u>: <span class=\"paper_field\"></span><br>\
			<br>Дополнительная информация***: <span class=\"paper_field\"></span>\
			<br>Указания к хранению вируса***: <span class=\"paper_field\"></span><br>\
			<br><font size = \"1\">Подпись разработчика: <span class=\"paper_field\"></span>, в должности <b><span class=\"paper_field\"></span></b>\
			<br>Подпись Директора Исследований**: <span class=\"paper_field\"></span>\
			<br>Дата: <span class=\"paper_field\"></span> \
			<br>Время: <span class=\"paper_field\"></span> \
			<hr><i><font size = \"1\">**Отчёт недействителен без подписи Директора Исследований. \
			В случае его отсутствия требуется подпись Офицера Телекоммуникаций или заменяющего его лица с указанием должности.\
			<br>***Заполняется Директором Исследований. В случае его отсутствия, заполняется Офицером Телекоммуникаций или заменяющим его лицом</font>"

//======
/obj/item/paper/deltainfo
	name = "Информационный буклет НСС Керберос"
	info = "<font face=\"Verdana\" color=black><center><h1>Буклет нового сотрудника \
			на борту НСС &#34;Керберос&#34;</h1></center>\
			<br><hr><b></b><br><center><h2>Цель</h2></center>\
			<br><font size=\"4\">Данное руководство было создано с целью \
			<b>облегчить процесс</b> введения в работу станции <b>нового экипажа</b>, \
			а также для <b>информирования сотрудников</b> об оптимальных маршрутах \
			передвижения. В данном буклете находится <b>основная карта</b> &#34;Кербероса&#34; \
			и несколько интересных фактов о станции.</font>\
			<br><hr><br><center><h2>Карта Станции</h2></center>\
			<br><font size=\"4\">С точки зрения конструкции, станция состоит из 12 зон:\
			<br><ul><li>Прибытие - <b><b>Серый</b></b> - Отсек прибытия экипажа и ангар космических подов.\
			<br><li>Мостик - <b>Синий</b> - Отсек командования и VIP-персон.\
			<br><li>Двор - <b>Зелёный</b> - Отсек сферы услуг.\
			<br><li>Карго - <b>Оранжевый</b> - Отсек снабжения и поставок.\
			<br><li>Инженерия - <b>Жёлтый</b> - Отсек технического обслуживания и систем станции.\
			<br><li>Бриг - <b>Красный</b> - Отсек службы безопасности.\
			<br><li>Процедурная - <b>Розовый</b> - Юридические зоны и процедурный отсек.\
			<br><li>Дормы - <b>Розовый</b> - Отсек для отдыха и развлечений.\
			<br><li>РнД - <b>Фиолетовый</b> - Отсек научных исследований и разработок.\
			<br><li>Медбей - <b>Голубой</b> - Отсек медицинских услуг и биовирусных разработок.\
			<br><li>Спутник ИИ - <b>Тёмно-синий</b> - Отсек систем искусственного интеллекта станции.\
			<br><li>Отбытие - <b>Салатовый</b> - Отсек отбытия и эвакуационного шаттла.\
			<br><li>Зоны исследователей - <b>Светло-синий</b> - Гейт, ЕВА и экспедиционный склад. \
			<br><li>Технические туннели - <b>Коричневый</b> - Неэксплуатируемые технические помещения.\
			<br><li>Библиотека - <b>Зона и путь в чёрном пунктире</b> - Архив и место для получения новых знаний и СРП.\
			<br><li>Офис Главы Персонала - <b>Зона и путь в белом пунктире</b> - Место для получения работы.\
			<br></ul><hr></font> \
			<img src=\"https://media.discordapp.net/attachments/911024179984347217/1066699505099096144/map2.png?width=600&height=600\">\
			<font face=\"Verdana\" color=black><br><br><hr><br><center><h2>Технические туннели</h2></center>\
			<br> За время строительства проект станции претерпел несколько значительных \
			изменений. Изначально новая станция должна была стать туристическим объектом, \
			но после произошедшей в <b>2549 году</b> серии <b>террористических актов</b> \
			объект вошёл в состав парка научно-исследовательских станций корпорации. В \
			нынешних технических туннелях до сих пор можно найти заброшенные комнаты для \
			гостей, бары и клубы. В связи с плачевным состоянием несущих конструкций \
			посещать эти части станции не рекомендуется, однако неиспользуемые площади \
			могут быть использованы для строительства новых отсеков.\
			<br><hr><br><center><h2>Особенности станции</h2></center>\
			<br>В отличие от большинства других научно-исследовательских станций Nanotrasen, \
			таких как &#34;Кибериада&#34;, <b>НСС &#34;Керберос&#34;</b> имеет менее \
			жёсткую систему контроля за личными вещами экипажа. В частности, в отсеках \
			были построены <b>дополнительные автолаты</b>, в том числе <b>публичные</b> \
			(в карго и РНД). Также, благодаря более высокому бюджету, были возведены \
			<b>новые отсеки</b>, такие как <b>ангар</b> или <b>склад</b> в отсеке РнД.\
			Был расширен отдел <b>вирусологии</b> и возведены <b>новые технические туннели</b> для \
			новых проектов.</font>"
	icon_state = "pamphlet"

/obj/item/paper/deltainfo/update_icon_state()
	return

/obj/item/paper/pamphletdeathsquad
	icon_state = "pamphlet-ds"

/obj/item/paper/pamphletdeathsquad/update_icon_state()
	return
