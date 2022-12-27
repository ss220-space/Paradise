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
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	attack_verb = list("bapped")
	dog_fashion = /datum/dog_fashion/head
	var/header //Above the main body, displayed at the top
	var/info		//What's actually written on the paper.
	var/footer 	//The bottom stuff before the stamp but after the body
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields		//Amount of user created fields
	var/list/stamped
	var/ico[0]      //Icons and
	var/offset_x[0] //offsets stored for later
	var/offset_y[0] //usage by the photocopier
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

//lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!

/obj/item/paper/New()
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)

	spawn(2)
		update_icon()
		updateinfolinks()

/obj/item/paper/update_icon()
	..()
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"

/obj/item/paper/examine(mob/user)
	. = ..()
	if(user.is_literate())
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			show_content(user)
		else
			. += "<span class='notice'>You have to go closer if you want to read it.</span>"
	else
		. += "<span class='notice'>You don't know how to read.</span>"

/obj/item/paper/proc/show_content(var/mob/user, var/forceshow = 0, var/forcestars = 0, var/infolinks = 0, var/view = 1)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	var/data
	var/stars = (!user.say_understands(null, GLOB.all_languages["Galactic Common"]) && !forceshow) || forcestars
	if(stars) //assuming all paper is written in common is better than hardcoded type checks
		data = "[header][stars(info)][footer][stamps]"
	else
		data = "[header]<div id='markdown'>[infolinks ? info_links : info]</div>[footer][stamps]"
	if(config.twitch_censor)
		for(var/char in config.twich_censor_list)
			data = replacetext(data, char, config.twich_censor_list[char])
	if(view)
		if(!istype(src, /obj/item/paper/form) && length(info) > 1024)
			paper_width = paper_width_big
			paper_height = paper_height_big
		var/datum/browser/popup = new(user, "Paper[UID()]", , paper_width, paper_height)
		popup.stylesheets = list()
		popup.set_content(data)
		if(!stars)
			popup.add_script("marked.js", 'html/browser/marked.js')
			popup.add_script("marked-paradise.js", 'html/browser/marked-paradise.js')
		popup.add_head_content("<title>[name]</title>")
		popup.open()
	return data

/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if((CLUMSY in usr.mutations) && prob(50))
		to_chat(usr, "<span class='warning'>You cut yourself on the paper.</span>")
		return
	if(!usr.is_literate())
		to_chat(usr, "<span class='notice'>You don't know how to read.</span>")
		return
	var/n_name = rename_interactive(usr)
	if(isnull(n_name))
		return
	if(n_name != "")
		desc = "This is a paper titled '" + name + "'."
	else
		desc = initial(desc)
	add_fingerprint(usr)
	return

/obj/item/paper/attack_self(mob/living/user as mob)
	user.examinate(src)
	if(rigged && (SSholiday.holidays && SSholiday.holidays[APRIL_FOOLS]))
		if(spam_flag == 0)
			spam_flag = 1
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
	return

/obj/item/paper/attack_ai(var/mob/living/silicon/ai/user as mob)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		show_content(user, forceshow = 1)
	else
		show_content(user, forcestars = 1)
	return

/obj/item/paper/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_selected == "eyes")
		user.visible_message("<span class='notice'>You show the paper to [M]. </span>", \
			"<span class='notice'> [user] holds up a paper and shows it to [M]. </span>")
		M.examinate(src)

	else if(user.zone_selected == "mouth")
		if(!istype(M, /mob))	return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>You wipe off your face with [src].</span>")
				H.lip_style = null
				H.update_body()
			else
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s face clean with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s face.</span>")
				if(do_after(user, 10, target = H) && do_after(H, 10, 0))	//user needs to keep their active hand, H does not.
					user.visible_message("<span class='notice'>[user] wipes [H]'s face clean with \the [src].</span>", \
										 "<span class='notice'>You wipe off [H]'s face.</span>")
					H.lip_style = null
					H.update_body()
	else
		..()

/obj/item/paper/proc/addtofield(var/id, var/text, var/links = 0)
	if(id > MAX_PAPER_FIELDS)
		return

	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(locid <= MAX_PAPER_FIELDS)
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart==0)
			return // No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()

/obj/item/paper/proc/updateinfolinks()
	info_links = info
	var/i = 0
	for(i=1,i<=fields,i++)
		var/write_1 = "<font face=\"[deffont]\"><A href='?src=[UID()];write=[i]'>write</A></font>"
		var/write_2 = "<font face=\"[deffont]\"><A href='?src=[UID()];auto_write=[i]'><span style=\"color: #409F47; font-size: 10px\">\[A\]</span></A></font>"
		addtofield(i, "[write_1][write_2]", 1)
	info_links = info_links + "<font face=\"[deffont]\"><A href='?src=[UID()];write=end'>write</A></font>"


/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	stamped = list()
	overlays.Cut()
	updateinfolinks()
	update_icon()


/obj/item/paper/proc/parsepencode(var/t, var/obj/item/pen/P, mob/user as mob)
	t = pencode_to_html(html_encode(t), usr, P, TRUE, TRUE, TRUE, deffont, signfont, crayonfont)
	return t

/obj/item/paper/proc/populatefields()
		//Count the fields
	var/laststart = 1
	while(fields < MAX_PAPER_FIELDS)
		var/i = findtext(info, "<span class=\"paper_field\">", laststart)
		if(i==0)
			break
		laststart = i+1
		fields++


/obj/item/paper/proc/openhelp(mob/user as mob)
	user << browse({"<HTML><meta charset="UTF-8"><HEAD><TITLE>Pen Help</TITLE></HEAD>
	<BODY>
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
		\[time\] : Inserts the current station time in HH:MM:SS.<br>
	</BODY></HTML>"}, "window=paper_help")

/obj/item/paper/proc/topic_href_write(var/id, var/input_element)
	var/obj/item/item_write = usr.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
	add_hiddenprint(usr) // No more forging nasty documents as someone else, you jerks
	if(!istype(item_write, /obj/item/pen))
		if(!istype(item_write, /obj/item/toy/crayon))
			return

	// if paper is not in usr, then it must be near them, or in a clipboard or folder, which must be in or near usr
	if(src.loc != usr && !src.Adjacent(usr) && !((istype(src.loc, /obj/item/clipboard) || istype(src.loc, /obj/item/folder)) && (src.loc.loc == usr || src.loc.Adjacent(usr)) ) )
		return

	input_element = parsepencode(input_element, item_write, usr) // Encode everything from pencode to html

	if(id!="end")
		addtofield(text2num(id), input_element) // He wants to edit a field, let him.
	else
		info += input_element // Oh, he wants to edit to the end of the file, let him.

	populatefields()
	updateinfolinks()

	item_write.on_write(src,usr)

	show_content(usr, forceshow = 1, infolinks = 1)

	update_icon()

/obj/item/paper/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return

	if(href_list["auto_write"])
		var/id = href_list["auto_write"]

		var/const/sign_text = "\[Поставить подпись\]"
		var/const/time_text = "\[Написать текущее время\]"
		var/const/date_text = "\[Написать текущую дату\]"
		var/const/num_text = "\[Написать номер аккаунта\]"
		var/const/pin_text = "\[Написать пин-код\]"
		var/const/station_text = "\[Написать название станции\]"

		//пункты текста в меню
		var/list/menu_list = list()
		menu_list.Add(usr.real_name) //настоящее имя персонажа, даже если оно спрятано

		//если игрок маскируется или имя отличается, добавляется новый вариант ответа
		if (usr.real_name != usr.name || usr.name != "unknown")
			menu_list.Add("[usr.name]")

		menu_list.Add(usr.job,		//текущая работа
			num_text,		//номер аккаунта
			pin_text,		//номер пин-кода
			sign_text,  	//подпись
			time_text,  	//время
			date_text,  	//дата
			station_text, 	//название станции
			usr.gender,		//пол
			usr.dna.species	//раса
		)

		var/input_element = input("Выберите текст который хотите добавить:", "Выбор пункта") as null|anything in menu_list

		//форматируем выбранные пункты меню в pencode и внутренние данные
		switch(input_element)
			if (sign_text)
				input_element = "\[sign\]"
			if (time_text)
				input_element = "\[time\]"
			if (date_text)
				input_element = "\[date\]"
			if (station_text)
				input_element = "\[station\]"
			if (num_text)
				input_element = usr.mind.initial_account.account_number
			if (pin_text)
				input_element = usr.mind.initial_account.remote_access_pin

		topic_href_write(id, input_element)


	if(href_list["write"] )
		var/id = href_list["write"]
		var/input_element =  input("Enter what you want to write:", "Write", null, null)  as message

		topic_href_write(id, input_element)


/obj/item/paper/attackby(obj/item/P, mob/living/user, params)
	..()

	if(resistance_flags & ON_FIRE)
		return

	var/clown = 0
	if(user.mind && (user.mind.assigned_role == "Clown"))
		clown = 1

	if(istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
		if(istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if(!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return
		var/obj/item/paper_bundle/B = new(src.loc, default_papers = FALSE)
		if(name != "paper")
			B.name = name
		else if(P.name != "paper" && P.name != "photo")
			B.name = P.name
		user.unEquip(P)
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/h_user = user
			if(h_user.r_hand == src)
				h_user.unEquip(src)
				h_user.put_in_r_hand(B)
			else if(h_user.l_hand == src)
				h_user.unEquip(src)
				h_user.put_in_l_hand(B)
			else if(h_user.l_store == src)
				h_user.unEquip(src)
				B.loc = h_user
				B.layer = ABOVE_HUD_LAYER
				B.plane = ABOVE_HUD_PLANE
				h_user.l_store = B
				h_user.update_inv_pockets()
			else if(h_user.r_store == src)
				h_user.unEquip(src)
				B.loc = h_user
				B.layer = ABOVE_HUD_LAYER
				B.plane = ABOVE_HUD_PLANE
				h_user.r_store = B
				h_user.update_inv_pockets()
			else if(h_user.head == src)
				h_user.unEquip(src)
				h_user.put_in_hands(B)
			else if(!istype(src.loc, /turf))
				src.loc = get_turf(h_user)
				if(h_user.client)	h_user.client.screen -= src
				h_user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You clip the [P.name] to [(src.name == "paper") ? "the paper" : src.name].</span>")
		src.loc = B
		P.loc = B
		B.amount++
		B.update_icon()

	else if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(user.is_literate())
			var/obj/item/pen/multi/robopen/RP = P
			if(istype(P, /obj/item/pen/multi/robopen) && RP.mode == 2)
				RP.RenamePaper(user,src)
			else
				show_content(user, infolinks = 1)
			//openhelp(user)
			return
		else
			to_chat(user, "<span class='warning'>You don't know how to write!</span>")

	else if(istype(P, /obj/item/stamp))
		if((!in_range(src, usr) && loc != user && !( istype(loc, /obj/item/clipboard) ) && loc.loc != user && user.get_active_hand() != P))
			return

		if(istype(P, /obj/item/stamp/clown))
			if(!clown)
				to_chat(user, "<span class='notice'>You are totally unable to use the stamp. HONK!</span>")
				return

		stamp(P)

		to_chat(user, "<span class='notice'>You stamp the paper with your rubber stamp.</span>")

	if(is_hot(P))
		if((CLUMSY in user.mutations) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
								"<span class='userdanger'>You miss the paper and accidentally light yourself on fire!</span>")
			user.unEquip(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!Adjacent(user)) //to prevent issues as a result of telepathically lighting a paper
			return

		user.unEquip(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()

	add_fingerprint(user)

/obj/item/paper/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		info = "<i>Heat-curled corners and sooty words offer little insight. Whatever was once written on this page has been rendered illegible through fire.</i>"

/obj/item/paper/proc/stamp(var/obj/item/stamp/S)
	stamps += (!stamps || stamps == "" ? "<HR>" : "") + "<img src=large_[S.icon_state].png>"

	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	var/x
	var/y
	if(istype(S, /obj/item/stamp/captain) || istype(S, /obj/item/stamp/centcom))
		x = rand(-2, 0)
		y = rand(-1, 2)
	else
		x = rand(-2, 2)
		y = rand(-3, 2)
	offset_x += x
	offset_y += y
	stampoverlay.pixel_x = x
	stampoverlay.pixel_y = y

	if(!ico)
		ico = new
	ico += "paper_[S.icon_state]"
	stampoverlay.icon_state = "paper_[S.icon_state]"

	if(!stamped)
		stamped = new
	stamped += S.type
	overlays += stampoverlay

	playsound(S, pick(S.stamp_sounds), 35, 1, -1)

/*
 * Premade paper
 */
/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep plasma.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSoporific T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = 1.0

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	item_state = "paper"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alarms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/paper/crumpled/update_icon()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/fortune
	name = "fortune"
	icon_state = "slip"
	paper_height = 150

/obj/item/paper/fortune/New()
	..()
	var/fortunemessage = pick(GLOB.fortune_cookie_messages)
	info = "<p style='text-align:center;font-family:[deffont];font-size:120%;font-weight:bold;'>[fortunemessage]</p>"
	info += "<p style='text-align:center;'><strong>Lucky numbers</strong>: [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)]</p>"

/obj/item/paper/fortune/update_icon()
	..()
	icon_state = initial(icon_state)
/*
 * Premade paper
 */
/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep plasma.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSoporific T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/paper/chef
	name = "Cooking advice from Morgan Ramslay"
	info = "Right, so you're wanting to learn how to feed the teeming masses of the station yeah?<BR>\n<BR>\nWell I was asked to write these tips to help you not burn all of your meals and prevent food poisonings.<BR>\n<BR>\nOkay first things first, making a humble ball of dough.<BR>\n<BR>\nCheck the lockers for a bag or two of flour and then find a glass cup or a beaker, something that can hold liquids. Next pour 15 units of flour into the container and then pour 10 units of water in as well. Hey presto! You've made a ball of dough, which can lead to many possibilities.<BR>\n<BR>\nAlso, before I forget, KEEP YOUR FOOD OFF THE DAMN FLOOR! Space ants love getting onto any food not on a table or kept away in a closed locker. You wouldn't believe how many injuries have resulted from space ants...<BR>\n<BR>\nOkay back on topic, let's make some cheese, just follow along with me here.<BR>\n<BR>\nLook in the lockers again for some milk cartons and grab another glass to mix with. Next look around for a bottle named 'Universal Enzyme' unless they changed the look of it, it should be a green bottle with a red label. Now pour 5 units of enzyme into a glass and 40 units of milk into the glass as well. In a matter of moments you'll have a whole wheel of cheese at your disposal.<BR>\n<BR>\nOkay now that you've got the ingredients, let's make a classic crewman food, cheese bread.<BR>\n<BR>\nMake another ball of dough, and cut up your cheese wheel with a knife or something else sharp such as a pair of wire cutters. Okay now look around for an oven in the kitchen and put 2 balls of dough and 2 cheese wedges into the oven and turn it on. After a few seconds a fresh and hot loaf of cheese bread will pop out. Lastly cut it into slices with a knife and serve.<BR>\n<BR>\nCongratulations on making it this far. If you haven't created a burnt mess of slop after following these directions you might just be on your way to becoming a master chef someday.<BR>\n<BR>\nBe sure to look up other recipes and bug the Head of Personnel if Botany isn't providing you with crops, wheat is your friend and lifeblood.<BR>\n<BR>\nGood luck in the kitchen, and try not to burn down the place.<BR>\n<BR>\n-Morgan Ramslay"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/monolithren
	name = "For stalkers"
	info = "Sorry Mario, your wishgranter in another castle. Your Friendly God"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = 1.0

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	item_state = "paper"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alarms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

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
	info = "Brusies sustained in the holodeck can be healed simply by sleeping."

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

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/paper/syndicate
	name = "paper"
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='syndielogo.png' width='220' height='135' /></p><hr />"
	info = ""

/obj/item/paper/nanotrasen
	name = "paper"
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' width='220' height='135' /></p><hr />"
	info =  ""

/obj/item/paper/central_command
	name = "paper"
	header ="<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' alt='' width='220' height='135' /></p><hr /><h3 style='text-align: center;font-family: Verdana;'><b> Центральное командование Nanotrasen</h3><p style='text-align: center;font-family:Verdana;'>Официальный Меморандум</p></b><hr />"
	info = ""
	footer = "<hr /><p style='font-family:Verdana;'><em>Несоблюдение указаний, содержащихся в данном документе, считается нарушением политики компании; Дисциплинарное взыскание за нарушения может быть применено на месте или в конце смены в Центральном командовании. </em> <br /> <em>*Получатель(и) данного меморандума подтверждает(ют), что он(она/они) несут ответственность за любой ущерб, который может возникнуть в результате игнорирования приведенных здесь директив или рекомендаций. </em> <br /> <em> *Все отчеты должны храниться конфиденциально их предполагаемым получателем и любой соответствующей стороной. Несанкционированное распространение данного меморандума может привести к дисциплинарным взысканиям</em></p>"


/obj/item/paper/crumpled/update_icon()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/evilfax
	name = "Centcomm Reply"
	info = ""
	var/mytarget = null
	var/myeffect = null
	var/used = 0
	var/countdown = 60
	var/activate_on_timeout = 0
	var/faxmachineid = null

/obj/item/paper/evilfax/show_content(var/mob/user, var/forceshow = 0, var/forcestars = 0, var/infolinks = 0, var/view = 1)
	if(user == mytarget)
		if(istype(user, /mob/living/carbon))
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


/obj/item/paper/evilfax/New()
	..()
	START_PROCESSING(SSobj, src)


/obj/item/paper/evilfax/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(mytarget && !used)
		var/mob/living/carbon/target = mytarget
		target.ForceContractDisease(new /datum/disease/transformation/corgi(0))
	return ..()


/obj/item/paper/evilfax/process()
	if(!countdown)
		if(mytarget)
			if(activate_on_timeout)
				evilpaper_specialaction(mytarget)
			else
				message_admins("[mytarget] ignored an evil fax until it timed out.")
		else
			message_admins("Evil paper '[src]' timed out, after not being assigned a target.")
		used = 1
		evilpaper_selfdestruct()
	else
		countdown--

/obj/item/paper/evilfax/proc/evilpaper_specialaction(var/mob/living/carbon/target)
	spawn(30)
		if(istype(target, /mob/living/carbon))
			var/obj/machinery/photocopier/faxmachine/fax = locateUID(faxmachineid)
			if(myeffect == "Borgification")
				to_chat(target,"<span class='userdanger'>You seem to comprehend the AI a little better. Why are your muscles so stiff?</span>")
				target.ForceContractDisease(new /datum/disease/transformation/robot(0))
			else if(myeffect == "Corgification")
				to_chat(target,"<span class='userdanger'>You hear distant howling as the world seems to grow bigger around you. Boy, that itch sure is getting worse!</span>")
				target.ForceContractDisease(new /datum/disease/transformation/corgi(0))
			else if(myeffect == "Death By Fire")
				to_chat(target,"<span class='userdanger'>You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?</span>")
				var/turf/simulated/T = get_turf(target)
				new /obj/effect/hotspot(T)
				target.adjustFireLoss(150) // hard crit, the burning takes care of the rest.
			else if(myeffect == "Total Brain Death")
				to_chat(target,"<span class='userdanger'>You see a message appear in front of you in bright red letters: <b>YHWH-3 ACTIVATED. TERMINATION IN 3 SECONDS</b></span>")
				target.mutations.Add(NOCLONE)
				target.adjustBrainLoss(125)
			else if(myeffect == "Honk Tumor")
				if(!target.get_int_organ(/obj/item/organ/internal/honktumor))
					var/obj/item/organ/internal/organ = new /obj/item/organ/internal/honktumor
					to_chat(target,"<span class='userdanger'>Life seems funnier, somehow.</span>")
					organ.insert(target)
			else if(myeffect == "Cluwne")
				if(istype(target, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = target
					to_chat(H, "<span class='userdanger'>You feel surrounded by sadness. Sadness... and HONKS!</span>")
					H.makeCluwne()
			else if(myeffect == "Demote")
				GLOB.event_announcement.Announce("[target.real_name] is hereby demoted to the rank of Civilian. Process this demotion immediately. Failure to comply with these orders is grounds for termination.","CC Demotion Order")
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
					if(R.fields["name"] == target.real_name)
						R.fields["criminal"] = SEC_RECORD_STATUS_DEMOTE
						R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<BR> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
				update_all_mob_security_hud()
			else if(myeffect == "Demote with Bot")
				GLOB.event_announcement.Announce("[target.real_name] is hereby demoted to the rank of Civilian. Process this demotion immediately. Failure to comply with these orders is grounds for termination.","CC Demotion Order")
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
					if(R.fields["name"] == target.real_name)
						R.fields["criminal"] = SEC_RECORD_STATUS_ARREST
						R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<BR> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
				update_all_mob_security_hud()
				if(fax)
					var/turf/T = get_turf(fax)
					new /obj/effect/portal(T)
					new /mob/living/simple_animal/bot/secbot(T)
			else if(myeffect == "Revoke Fax Access")
				GLOB.fax_blacklist += target.real_name
				if(fax)
					fax.authenticated = 0
			else if(myeffect == "Angry Fax Machine")
				if(fax)
					fax.become_mimic()
			else
				message_admins("Evil paper [src] was activated without a proper effect set! This is a bug.")
		used = 1
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

/obj/item/paper/researchnotes/New()
	..()
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
	var/from // = "NSS &#34;Cyberiad&#34;"
	var/date = "01.01.2370"
	var/notice = "Перед заполнением прочтите от начала до конца | Во всех PDA имеется ручка"
	var/access = null //form visible only with appropriate access
	paper_width = 600 //Width of the window that opens
	paper_height = 700 //Height of the window that opens
	var/is_header_needed = TRUE
	var/const/footer_signstampfax = ""
	var/const/footer_signstamp = ""
	var/const/footer_confidential = "<BR><font face=\"Verdana\" color=black><HR><center><font size = \"1\">Данный документ является недействительным при отсутствии печати.<BR>Отказ от ответственности: Данный факс является конфиденциальным и не может быть прочтен сотрудниками не имеющего доступа. Если вы получили данный факс по ошибке, просим вас сообщить отправителю и удалить его из вашего почтового ящика или любого другого носителя. И Nanotrasen, и любой её агент не несёт ответственность за любые сделанные заявления, они являются исключительно заявлениями отправителя, за исключением если отправителем является Nanotrasen или один из её агентов. Отмечаем, что ни Nanotrasen, ни один из агентов корпорации не несёт ответственности за наличие вирусов, который могут содержаться в данном факсе или его приложения, и это только ваша прерогатива просканировать факс и приложения на них. Никакие контракты не могут быть заключены посредством факсимильной связи.</font></center></font>"
	footer = footer_signstampfax

/obj/item/paper/form/New()
	from = "NSS [MAP_NAME]"
	date = "Дата: [GLOB.current_date_string]"
	if(is_header_needed)
		header = "<font face=\"Verdana\" color=black><table></td><tr><td><img src = ntlogo.png><td><table></td><tr><td><font size = \"1\">[name][confidential ? " \[КОНФИДЕНЦИАЛЬНО\]" : ""]</font></td><tr><td><font size=\"1\">[from]</font></td><tr><td><font size=\"1\">[date]</font></td><tr><td></td><tr><td></td><tr><td><B>[altername]</B></td></tr></table></td></tr></table><BR><HR><BR></font>"
	populatefields()
	return ..()

//NT-COM
/obj/item/paper/form/NT_COM_ST
	name = "Форма NT-COM-ST"
	id = "NT-COM-ST"
	altername = "Отчёт о статусе смены."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Отчёт</B></large></i></center><BR><B><span class=\"paper_field\"></span></B> в должности <B><span class=\"paper_field\"></span></B> приветствует офицеров Центрального Командования.<BR><BR><B>Код:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Актуальный код на станции.</font><BR><BR><B>Действующие угрозы:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Активные угрозы существованию станции.</font><BR><BR><B>Возможные угрозы:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Временно неподтверждённая информация об угрозах.</font><BR><BR><B>Потери среди экипажа:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Неклонируемые или пропавшие без вести члены экипажа.</font><BR><BR><B>Повреждения на станции:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Значимые структурные и/или технические повреждения.</font><BR><BR><B>Оценка работы командного состава:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Эффективность работы командования.</font><BR><BR><B>Оценка работы отделов:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Эффективность работы экипажа.</font><BR><BR><B>Прогресс выполнения цели:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Процентный показатель готовности цели текущей смены.</font><BR><BR><B>Дополнительно:</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Любая важная информация, не относящаяся к предыдущим пунктам.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица:</B> <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись лица, составившего отчёт, из числа командного состава.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font></font>"

/obj/item/paper/form/NT_COM_ACAP
	name = "Форма NT-COM-ACAP"
	id = "NT-COM-ACAP"
	altername = "Заявление о переводе на должность Капитана."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление о переводе</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, выдвигаю свою кандидатуру на пост исполняющего обязанности Капитана станции <station>.<BR><BR>При назначении меня на данную должность я обязуюсь следовать соответствующим Стандартным Рабочим Процедурам, обеспечивать сохранность закреплённых за этой должностью особо ценных предметов и личных вещей, а также осуществлять управление станцией до прибытия легитимного Капитана.<BR><BR>Полностью соглашаюсь с тем, что при прибытии на борт Капитана мне необходимо сдать капитанский доступ и экипировку, а затем запросить перевод на занимаемую прежде должность.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись кандидата на повышение.</font><BR><B>Подпись ГП</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Главы Персонала.</font><BR><B>Подпись ГСБ</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Главы Службы Безопасности.</font><BR><B>Подпись СМО</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Главного Врача.</font><BR><B>Подпись СЕ</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Главного Инженера.</font><BR><B>Подпись РД</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Директора Исследований.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Заявление должно быть одобрено подписью и штампом как минимум 3-х Глав Отделов, а так же содержать подпись заявителя, в противном случае назначение будет считаться недействительным.</font><BR><font size = \"1\">*В случае присутствия на борту Глав Отделов в кол-ве менее 3-х, для одобрения заявления требуется наличие подписи и штампа от всех присутствующих на данный момент Глав.</font><BR><font size = \"1\">*Подписи или кандидатура лиц, исполняющих обязанности Главы Отдела, не являются действительными. Подпись самого кандидата в строке Главы Отдела также не является действительной.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_COM_ACOM
	name = "Форма NT-COM-ACOM"
	id = "NT-COM-ACOM"
	altername = "Заявление о переводе на должность Главы Отдела."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление о переводе</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, выдвигаю свою кандидатуру на пост исполняющего обязанности <B><span class=\"paper_field\"></span></B>.<BR><BR>При назначении меня на данную должность я обязуюсь следовать соответствующим Стандартным Рабочим Процедурам, обеспечивать сохранность закреплённых за должностью особо ценных предметов и личных вещей, а также осуществлять управление отделом до прибытия легитимного руководителя.<BR><BR>Полностью соглашаюсь с тем, что при прибытии главы департамента с АСН \"Трурль\" мне необходимо сдать доступ и экипировку главы, а затем запросить перевод на занимаемую прежде должность.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись кандидата на повышение.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Капитана станции.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*В случае отсутствия на борту Капитана, для одобрения заявления требуется наличие подписи и штампа Главы Персонала.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_COM_LCOM
	name = "Форма NT-COM-LCOM"
	id = "NT-COM-LCOM"
	altername = "Приказ о понижении Главы Отдела."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Приказ о понижении</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности Капитана станции <station> приказываю: понизить <B><span class=\"paper_field\"></span></B> с занимаемой им должности <B><span class=\"paper_field\"></span></B> на должность <B><span class=\"paper_field\"></span></B>.<BR><font size = \"1\">Понижение возможно на любую из гражданских должностей, либо на низшую должность соответствующего департамента.</font><BR><BR>Достаточной причиной понижения считаю: <span class=\"paper_field\"></span>.<BR><BR>Пониженный сотрудник обязан вернуть в место хранения или передать инициатору понижения закреплённые за его должностью особо ценные предметы и личные вещи, а затем добровольно сдать карту для прохождения процедуры смены должности.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Капитана или лица, исполняющего обязанности Капитана.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font></font>"

/obj/item/paper/form/NT_COM_REQ
	name = "Форма NT-COM-REQ"
	id = "NT-COM-REQ"
	altername = "Запрос поставки с АСН \"Трурль\"."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Запрос поставки</B></large></i></center><BR><B>Запрашивает</B>: <span class=\"paper_field\"></span> в должности <span class=\"paper_field\"></span>.<BR><BR><B>Необходимое обеспечение</B>: <span class=\"paper_field\"></span>.<BR><BR><B>Причина запроса</B>: <span class=\"paper_field\"></span>.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица:</B> <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись составителя запроса из числа командного состава.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Если Вы запрашиваете саму печать - для утверждения документа может быть использован штамп любого члена командования.</font></font>"

/obj/item/paper/form/NT_COM_OBJ
	name = "Форма NT-COM-OBJ"
	id = "NT-COM-OBJ"
	altername = "Отчёт о завершении цели."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Отчёт</B></large></i></center><BR>Данным документом уведомляю Вас о том, что установленная Вами цель текущей смены, а именно <B><span class=\"paper_field\"></span></B>, успешно завершена.<BR><BR>Учитывая состояние станции и/или экипажа в данный момент, запрашиваю <B><span class=\"paper_field\"></span></B>.<BR><font size = \"1\">Вы можете запросить дополнительную цель, либо разрешение на вызов эвакуационного шаттла \"Харон\".</font><BR><BR>В случае отсутствия ответа на данный запрос, беру на себя ответственность за вызов эвакуационного шаттла \"Харон\" для доставки экипажа на борт АСН \"Трурль\".<BR><BR>С уважением,<BR><B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись составителя отчёта из числа командного состава станции.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font></font>"
	
/obj/item/paper/form/NT_COM_VOTE
	name = "Форма NT-COM-VOTE"
	id = "NT-COM-VOTE"
	altername = "Голосование о понижении члена командования."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Голосование</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, инициирую процедуру понижения члена командования <B><span class=\"paper_field\"></span></B>, занимающего должность <B><span class=\"paper_field\"></span></B>, на должность <B><span class=\"paper_field\"></span></B> в связи со следующими причинами: <span class=\"paper_field\"></span>.<BR><BR>В случае одобрения поставьте Вашу подпись и штамп в соответствующих местах ниже. Отсутствие подписи и/или штампа в соответсвующих местах при условии наличия данного члена командования на станции считается выражением его неодобрения.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><BR><B>Подпись ГП</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Главы Персонала.</font><BR><B>Подпись ГСБ</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Главы Cлужбы Безопасности.</font><BR><B>Подпись СМО</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Главного Врача.</font><BR><B>Подпись СЕ</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Главного Инженера.</font><BR><B>Подпись РД</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">*Директора Исследований.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Голосование считается успешным при единогласном одобрении всеми присутствующими на смене главами отделов, однако требуется не менее 3-х голосов.</font><BR></font>"
	
/obj/item/paper/form/NT_COM_RET
	name = "Форма NT-COM-RET"
	id = "NT-COM-RET"
	altername = "Заявление о сложении полномочий."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, прошу об освобождении меня от занимаемой должности <B><span class=\"paper_field\"></span></B>, с переводом на гражданскую должность или низшую должность моего департамента, по причине <span class=\"paper_field\"></span>.<BR><BR>Перед сложением полномочий обязуюсь найти себе замену, а также вернуть все закреплённые за мной особо ценные предметы и личные вещи в места их изначального хранения, либо передать на временное хранение другому члену командования.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись слагающего полномочия лица.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Капитана или лица, исполняющего обязанности капитана.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*В случае сложения полномочий самим Капитаном, заявление должно быть рассмотрено Главой Персонала.</font></font>"
	
/obj/item/paper/form/NT_COM_OCOM
	name = "Форма NT-COM-OCOM"
	id = "NT-COM-OCOM"
	altername = "Приказ о назначении Главы Отдела."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Приказ</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, ввиду отсутствия соответствующего должностного лица на смене, с целью улучшения организации и эффективности работы отдела, приказываю: перевести <B><span class=\"paper_field\"></span></B> с должности <B><span class=\"paper_field\"></span></B> на пост исполняющего обязанности <B><span class=\"paper_field\"></span></B>.<BR><BR>Указанный сотрудник обязуется соблюдать соответствующие новой должности Стандартные Рабочие Процедуры, а также обеспечить сохранность особо ценных предметов и личных вещей, закреплённых за ней.<BR><BR>В случае прибытия официального руководителя на борт, исполняющему обязанности сотруднику необходимо сдать снаряжение и доступ главы, а затем запросить перевод на прежде занимаемую, либо иную свободную должность в пределах своего отдела.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись инициатора повышения</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Капитана или лица, исполняющего обязанности Капитана.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"
	
/obj/item/paper/form/NT_COM_MSG
	name = "Форма NT-COM-MSG"
	id = "NT-COM-MSG"
	altername = "Приоритетное сообщение."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Сообщение</B></large></i></center><BR>Приветствую Вас, офицеры Центрального Командования.<BR><BR><span class=\"paper_field\"></span>.<BR><BR>С уважением,<BR>Член командного состава <station>, <B><span class=\"paper_field\"></span></B>.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись отправителя из числа командного состава.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*В контексте данного документа Представитель НТ считается членом командного состава, не путать с цепочкой командования.</font></font>"
	
/obj/item/paper/form/NT_COM_MDL
	name = "Форма NT-COM-MDL"
	id = "NT-COM-MDL"
	altername = "Удостоверение к медали."
	category = "NT-COM - Командный состав"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Удостоверение</B></large></i></center><BR>От имени Капитана станции ИСН \"Керберос\", а также всего командования, <B><span class=\"paper_field\"></span></B> был(а) награжден(а) следующей медалью: <B><span class=\"paper_field\"></span></B>, за такие заслуги перед станцией и её экипажем: <span class=\"paper_field\"></span>.<BR><BR>Мы гордимся наличием такого достойного сотрудника в наших рядах, и желаем Вам успехов на будущих сменах. Слава Nanotrasen!<BR><BR>С уважением,<BR>Командование ИСН \"Керберос\".<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись утвердителя награждения из числа командного состава.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font></font>"

//NT-MED

/obj/item/paper/form/NT_MD_VRR
	name = "Форма NT-MD-VRR"
	id = "NT-MD-VRR"
	altername = "Запрос на распространение вируса."
	category = "NT-MED - Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Запрос</B></large></i></center><BR><B>Вирусолог</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Имя ответственного вирусолога.</font><BR><BR><B>Название вируса</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Обозначение, под которым вирус будет выпущен на станцию.</font><BR><BR><B>Путь распространения</B> <span class=\"paper_field\"></span>.<BR><font size = \"1\">Гемоконтактный (Blood) / Контактный (Contact) / Воздушно-капельный (Airborne).</font><BR><BR><B>Симптомы вируса</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Названия эффектов, вызываемых вирусом в организме.</font><BR><BR><B>Лечение</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Вещество, способное нейтрализовать вирус в организме.</font><BR><BR><B>Причина распространения</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Причина, по которой требуется выпустить данный вирус.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись вирусолога.</font><BR><B>Подпись СМО</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главного врача.</font><BR><B>Подпись Капитана</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Опциональна, обратитесь к п.3 СРП Вирусолога.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_MD_PSY
	name = "Форма NT-MD-PSY"
	id = "NT-MD-PSY"
	altername = "Отчёт о результате психиатрического осмотра."
	category = "NT-MED - Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Отчёт</B></large></i></center><BR><B>Лечащий врач</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Имя врача, проводившего осмотр.</font><BR><BR><B>Пациент</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Имя пациента, проходившего осмотр.</font><BR><BR><B>Характеристика пациента</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Опишите детали поведения, характера, а также жалобы пациента.</font><BR><BR><B>Возможные нарушения</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Опишите отклонения от нормы, обнаруженные в ходе осмотра (если имеются).</font><BR><BR><B>Рекомендации</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Препараты или лечебные процедуры, которые помогут выздоровлению пациента (если необходимы).</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись лечащего врача.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_MD_HRT
	name = "Форма NT-MD-HRT"
	id = "NT-MD-HRT"
	altername = "Справка о предоставлении медицинской помощи."
	category = "NT-MED - Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Справка</B></large></i></center><BR><B>Лечащий врач</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Имя врача, проводившего лечение.</font><BR><BR><B>Пациент</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Имя пациента, проходившего лечение.</font><BR><BR><B>Состояние пациента</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Опишите все присущие пациенту симптомы, или полученные им повреждения.</font><BR><BR><B>Назначенное лечение</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Опишите манипуляции, проведённые над пациентом с целью его излечения.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись лечащего врача.</font><BR><B>Время поступления пациента</B>: <span class=\"paper_field\"></span><BR><B>Время выписки пациента</B>: <span class=\"paper_field\"></span><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_MD_CHM
	name = "Форма NT-MD-CHM"
	id = "NT-MD-CHM"
	altername = "Запрос на изготовление препаратов."
	category = "NT-MED - Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Запрос</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, запрашиваю производство следующих медикаментов для служебного использования: <span class=\"paper_field\"></span>.<BR><font size = \"1\">При указании необходимого препарата, его дозировки и формы можете использовать такой пример: Perfluordecalin (3u/pill); Styptic Powder (20u/patch); Hydrocodone (50u/bottle) и т.д.</font><BR><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главного врача.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_MD_AUT
	name = "Форма NT-MD-AUT"
	id = "NT-MD-AUT"
	altername = "Отчёт о результатах аутопсии."
	category = "NT-MED - Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Отчёт</B></large></i></center><BR><B>Умерший</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Полное имя умершего.</font><BR><BR><B>Информация об умершем</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Раса / Пол / Должность.</font><BR><BR><B>Предполагаемая причина смерти</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Обстоятельство, вероятно окончательно приведшее к смерти.</font><BR><BR><B>Заключение</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Изложите информацию о теле умершего, которую считаете важной.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись коронера.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.<BR>*При нахождении признаков обстоятельств смерти, нарушающих действующий Космический Закон, результаты аутопсии следует передать детективу.</font></font>"

//NT-RND
/obj/item/paper/form/NT_RND_MEC
	name = "Форма NT-RND-MEC"
	id = "NT-RND-MEC"
	altername = "Запрос постройки мехи."
	category = "NT-RND - Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Запрос</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, прошу произвести постройку гражданской мехи <B><span class=\"paper_field\"></span></B> для рабочих задач, со следующими модулями: <span class=\"paper_field\"></span>.<BR><BR>Подписав этот документ, я обязуюсь соблюдать связанные с эксплуатацией мехи правила и законы, а также соглашаюсь выполнять все инструкции или приказы со стороны членов Командования и Службы Безопасности, касающиеся её эксплуатации.<BR><BR>В случае угона мехи или передачи её в пользование третьему лицу, я несу ответственность за все противозаконные действия, совершённые с её использованием.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Робототехника.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_RND_IMP
	name = "Форма NT-RND-IMP"
	id = "NT-RND-IMP"
	altername = "Заявление на получение и установку имплантов."
	category = "NT-RND - Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, прошу выдать и установить мне следующие импланты: <span class=\"paper_field\"></span>.<BR><BR>Данные импланты необходимы мне для <span class=\"paper_field\"></span>, их установку прошу провести в <span class=\"paper_field\"></span>.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись лица, запрашивающего импланты.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись сотрудника выдачи.</font><BR><B>Дополнительная подпись</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">(Опционально) Подпись необходимого главы отдела, установленная в СРП Имплантов.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_RND_GRN
	name = "Форма NT-RND-GRN"
	id = "NT-RND-GRN"
	altername = "Техническая документация к гранате."
	category = "NT-RND - Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black><B>Тип корпуса</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Пример: Advanced Release Grenade.</font><BR><BR><B>Способ активации</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Пример: Проводной.</font><BR><BR><B>Содержимое бикера #1</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Пример: Chlorine (1u), Oxygen (1u), Nitrogen (1u).</font><BR><BR><B>Содержимое бикера #2</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Пример: Ammonia (1u), Sodium (1u), Silver (1u).</font><BR><BR><B>Принцип действия</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Пример: Вещества из двух бикеров смешиваются между собой, создавая азид, который вызывает мощный взрыв.</font><BR><BR><B>Количество</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Пример: Всего создано N гранат с идентичной конфигурацией.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Директора исследований.</font><BR><B>Подпись исследователя химии</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись создателя гранаты.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"
	
/obj/item/paper/form/NT_RND_CBR
	name = "Форма NT-RND-CBR"
	id = "NT-RND-CBR"
	altername = "Заявление на киборгизацию."
	category = "NT-RND - Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, прошу сотрудника робототехнического отдела <B><span class=\"paper_field\"></span></B> осуществить операцию по моей киборгизации с целью <span class=\"paper_field\"></span>.<BR><BR>Я полностью осведомлён о рисках, связанных с операцией по киборгизации, а также соглашаюсь с тем, что Nanotrasen не несёт ответственности в случае провала операции и/или последующих побочных эффектов и летального исхода, также связанных с ней.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись кандидата на киборгизацию.</font><BR><B>Подпись робототехника</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись сотрудника, проводящего операцию.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Директора исследований.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Как минимум одна копия заявления должна храниться в отделе робототехники, ещё одну копию следует передать патологоанатому.<BR>*Данная форма документа может использоваться как для создания киборга, так и для создания ядра ИИ.</font></font>"

//NT-HR
/obj/item/paper/form/NT_HR_00
	name = "Форма NT-HR-BLC"
	id = "NT-HR-BLC"
	altername = "Бланк заявления."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Основная информация</B></large></i></center><BR><B>Имя заявителя</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Ваше полное имя.</font><BR><BR><B>Номер аккаунта заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваш персональный шестизначный номер.</font><BR><BR><B>Текущая должность</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Указана на Вашей ID-карте.</font><BR><hr><center><i><large><B>Заявление</B></large></i></center><BR><span class=\"paper_field\"></span>.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Персонала.</font><BR><B>Дополнительная подпись</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Необходимость данной подписи устанавливает Глава Персонала.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_HR_JOB
	name = "Форма NT-HR-JOB"
	id = "NT-HR-JOB"
	altername = "Заявление о приёме на работу."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR><B>Имя заявителя</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Ваше полное имя.</font><BR><BR><B>Номер аккаунта</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваш персональный шестизначный номер.</font><BR><BR><B>Желаемая должность</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Требует наличия квалификации.</font><BR><BR><B>Квалификация</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Укажите навыки, которыми вы обладаете в данной сфере.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Отдела, в котором будет числиться заявитель.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_HR_CHG
	name = "Форма NT-HR-CHG"
	id = "NT-HR-CHG"
	altername = "Заявление на смену должности."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR><B>Имя заявителя</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Ваше полное имя.</font><BR><BR><B>Текущая должность</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Указана на Вашей ID-карте.</font><BR><BR><B>Желаемая должность</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Требует наличия квалификации.</font><BR><BR><B>Квалификация</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Укажите навыки, которыми вы обладаете в данной сфере.</font><BR><BR><B>Причина</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Укажите причину перевода.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Подпись текущего главы отдела</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Отдела, в котором числится заявитель.</font><BR><B>Подпись будущего главы отдела</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Отдела, в котором будет числиться заявитель.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Персонала.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_HR_CNG
	name = "Форма NT-HR-CNG"
	id = "NT-HR-CNG"
	altername = "Приказ на смену должности."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Приказ</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, приказываю перевести сотрудника по имени <B><span class=\"paper_field\"></span></B>, с должности <B><span class=\"paper_field\"></span></B> на должность <B><span class=\"paper_field\"></span></B> по следующим причинам: <span class=\"paper_field\"></span>.<BR><BR>Перевод возможен исключительно в рамках одного отдела, переводить сотрудников в другие отделы без согласия Главы этого отдела и Главы Персонала строго запрещено.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Отдела, совершающего перевод.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_HR_03
	name = "Форма NT-HR-DMS"
	id = "NT-HR-DMS"
	altername = "Заявление об увольнении."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, добровольно прошу освободить меня от занимаемой должности <B><span class=\"paper_field\"></span></B>, с последующим переводом в статус гражданского лица, по следующей причине: <span class=\"paper_field\"></span>.<BR><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Отдела, в котором числится заявитель.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_HR_DSS
	name = "Форма NT-HR-DSS"
	id = "NT-HR-DSS"
	altername = "Приказ на увольнение."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Приказ</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, приказываю уволить сотрудника по имени <B><span class=\"paper_field\"></span></B> с должности <B><span class=\"paper_field\"></span></B> по следующим причинам: <span class=\"paper_field\"></span>.<BR><BR><font size = \"1\">Для увольнения воспользуйтесь кнопкой \"<B>Demote</B>\" в Вашей ID-консоли.</font><BR><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Отдела, совершающего увольнение.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_HR_IDC
	name = "Форма NT-HR-IDC"
	id = "NT-HR-IDC"
	altername = "Заявление на выдачу новой ID-карты."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR><B>Имя заявителя</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Ваше полное имя.</font><BR><BR><B>Номер аккаунта</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваш персональный шестизначный номер.</font><BR><BR><B>Текущая должность</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Должность, указанная на старой ID-карте.</font><BR><BR><B>Причина</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Укажите необходимость получения новой ID-карты.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Подпись главы отдела</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Отдела, в котором числится заявитель.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Персонала.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_HR_ACC
	name = "Форма NT-HR-ACC"
	id = "NT-HR-ACC"
	altername = "Заявление на получение дополнительного доступа."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR><B>Имя заявителя</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Ваше полное имя.</font><BR><BR><B>Текущая должность</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Указана на Вашей ID-карте.</font><BR><BR><B>Требуемый доступ</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Необходимо устное разрешение соответствующего Главы Отдела.</font><BR><BR><B>Причина</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Укажите необходимость получения доступа.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Подпись главы отдела</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Отдела, в котором числится заявитель.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Персонала.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font><BR><font size = \"1\">*В случае невозможности получить подпись Главы Отдела, в котором числится заявитель, Глава Персонала может утвердить документ без соответствующей подписи.</font></font>"

/obj/item/paper/form/NT_HR_ORG
	name = "Форма NT-HR-ORG"
	id = "NT-HR-ORG"
	altername = "Лицензия на создание организации."
	category = "NT-HR - Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Лицензия</B></large></i></center><BR><B>Глава организации</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Полное имя формального Главы Организации.</font><BR><BR><B>Название организации</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Полное название создаваемой Организации.</font><BR><BR><B>Вид деятельности</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Какую работу с экипажем будет проводить Организация.</font><BR><BR><B>Место расположения</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Отсек, выделенный под нужды Организации.</font><BR><BR><B>Процент отчислений</B>: <span class=\"paper_field\"></span>%<BR><font size = \"1\">Отчисления от прибыли на счёт станции, если Организация является коммерческой.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись создателя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись формального Главы Организации.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Персонала.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

//NT-SRV
/obj/item/paper/form/NT_SRV_MAR
	name = "Форма NT-SRV-MAR"
	id = "NT-SRV-MAR"
	altername = "Свидетельство о заключении брака."
	category = "NT-SRV - Отдел обслуживания"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Свидетельство</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, объявляю, что члены экипажа <B><span class=\"paper_field\"></span></B> и <B><span class=\"paper_field\"></span></B> прошли официальную процедуру регистрации брака и, с момента утверждения документа, являются полноправными супругами.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись супруга #1</B>: <span class=\"paper_field\"></span><BR><B>Подпись супруга #2</B>: <span class=\"paper_field\"></span><BR><B>Подпись ответственного лица</B> <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Персонала.</font><BR><B>Подпись священника</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">(Опционально) Может быть затребована по желанию супругов.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font></font>"

/obj/item/paper/form/NT_SRV_DIV
	name = "Форма NT-SRV-DIV"
	id = "NT-SRV-DIV"
	altername = "Свидетельство о расторжении брака."
	category = "NT-SRV - Отдел обслуживания"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Свидетельство</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, объявляю, что члены экипажа <B><span class=\"paper_field\"></span></B> и <B><span class=\"paper_field\"></span></B> прошли официальную процедуру расторжения брака и, с момента утверждения документа, более не являются полноправными супругами.<BR><BR>Данным документом аннулируется утверждённое ранее свидетельство о заключении брака в отношении вышеуказанных лиц.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись супруга #1</B>: <span class=\"paper_field\"></span><BR><B>Подпись супруга #2</B>: <span class=\"paper_field\"></span><BR><B>Подпись ответственного лица</B> <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главы Персонала.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font></font>"
	
/obj/item/paper/form/NT_SRV_DND
	name = "Форма NT-SRV-DND"
	id = "NT-SRV-DND"
	altername = "Лист персонажа для игры в D&D."
	category = "NT-SRV - Отдел обслуживания"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Общая информация</B></large></i></center><BR><B>Имя персонажа</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Дайте имя Вашему персонажу.</font><BR><B>Раса</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Воспользуйтесь фантазией, в случае отсутствия идей - выберите человека.</font><BR><B>Класс</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Воин, варвар, паладин, бард, следопыт, плут, монах, друид, волшебник, жрец, колдун, чародей. Список может быть изменён Мастером.</font><BR><B>Уровень</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Рекомендуется уровень от 1-го до 3-го, однако окончательное решение остаётся за Мастером.</font><BR><hr><center><i><large><B>Основные характеристики</B></large></i></center><BR><B>Сила</B>: <span class=\"paper_field\"></span> (<span class=\"paper_field\"></span>). <B>Ловкость</B>: <span class=\"paper_field\"></span> (<span class=\"paper_field\"></span>). <B>Интеллект</B>: <span class=\"paper_field\"></span> (<span class=\"paper_field\"></span>). <B>Телосложение</B>: <span class=\"paper_field\"></span> (<span class=\"paper_field\"></span>). <B>Мудрость</B>: <span class=\"paper_field\"></span> (<span class=\"paper_field\"></span>). <B>Харизма</B>: <span class=\"paper_field\"></span> (<span class=\"paper_field\"></span>).<BR><font size = \"1\">Число доступных очков для распределения назначается Мастером, эти очки вы должны распределить по желаемым характеристикам. В скобках должен быть указан модификатор Вашей характеристики, для его получения отнимите от очков характеристики 10 и разделите полученное число на 2.</font><BR><hr><center><i><large><B>Вторичные характеристики</B></large></i></center><BR><B>Кость хитов</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Варвар - 1d12; Воин, следопыт, паладин - 1d10; Друид, жрец, колдун, монах, бард, плут - 1d8; Волшебник, чародей - 1d6.</font><BR><B>Хиты</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Ваше здоровье. Увеличивается за каждый уровень путём броска кости хитов с прибавлением к результату модификатора телосложения.</font><BR><B>КЗ</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Класс Защиты. Имеет изначальный показатель в 10, меняется в зависимости от модификатора ловкости.</font><BR><B>Мастерство</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Зависит от уровня: 1-4 (+2); 5-8 (+3); 9-12 (+4); 13-16 (+5); 17-20 (+6).</font><BR><B>Инициатива</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Характеристика, влияющая на очерёдность ходов, равная модификатору ловкости.</font></font>"

//NT-SUP
/obj/item/paper/form/NT_SUP_RES
	name = "Форма NT-SUP-RES"
	id = "NT-SUP-RES"
	altername = "Запрос предоставления ресурсов."
	category = "NT-SUP - Отдел снабжения"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Запрос</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, прошу предоставить мне следующие ресурсы из печи отдела снабжения: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Пример: Metal (50), Plasma (25) и т.д.</font><BR><BR>Данные ресурсы необходимы мне для <span class=\"paper_field\"></span>. За ресурсы будут уплачены денежные средства в размере <B><span class=\"paper_field\"></span></B> кредитов.<BR><font size = \"1\">Заказы от следующих лиц не подлежат оплате, поставьте \"0\" в вышеуказанном поле: сотрудники инженерного отдела, отдела РнД, робототехники.</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись лица, запрашивающего ресурсы.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись сотрудника отдела снабжения.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_SUP_ORD
	name = "Форма NT-SUP-ORD"
	id = "NT-SUP-ORD"
	altername = "Форма регистрации поставки."
	category = "NT-SUP - Отдел снабжения"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заказ</B></large></i></center><BR><B>Имя заказчика</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Укажите полное имя лица, осуществляющего заказ поставки.</font><BR><BR><B>Необходимая поставка</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Пример: Medical Vending Crate (4), Medical Supplies Crate (2).</font><BR><BR><B>Место доставки</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Укажите часть станции, в которую необходимо осуществить доставку.</font><BR><BR><B>Причина запроса</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">Опишите необходимость получения вышеуказанной поставки.</font><BR><BR><B>Взимаемая плата</B>: <span class=\"paper_field\"></span>.<BR><font size = \"1\">(Опционально) Установленная Квартирмейстером плата в кредитах за осуществление поставки.</font><BR><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заказчика</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись лица, осуществляющего заказ поставки.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись сотрудника отдела снабжения.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.<BR>*Денежные средства за поставку должны быть перечислены в полном размере на счёт отдела до начала их использования, для этого воспользуйтесь ATM или EFTPOS.</font></font>"
	
//NT-ENG
/obj/item/paper/form/NT_ENG_POD
	name = "Форма NT-ENG-POD"
	id = "NT-ENG-POD"
	altername = "Квитанция о покупке челнока."
	category = "NT-ENG - Инженерный отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Квитанция</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, подтверждаю, что членом экипажа по имени <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, за сумму в <B><span class=\"paper_field\"></span></B> кредитов был приобретён космический челнок со следующими установленными модулями: <span class=\"paper_field\"></span>.<BR><BR>Покупатель космического челнока обязуется соблюдать пункты 1, 3, 4 Стандартных Рабочих Процедур механика по отношению к космическому челноку, а также все правила и законы, связанные с его эксплуатацией.<BR><BR>В случае угона челнока или передачи его в пользование третьему лицу, покупатель несёт ответственность за все противозаконные действия, совершённые с его использованием.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><BR><B>Подпись покупателя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Механика.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.</font><BR><font size = \"1\">*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_ENG_RCS
	name = "Форма NT-ENG-RCS"
	id = "NT-ENG-RCS"
	altername = "Запрос разрешения на строительство."
	category = "NT-ENG - Инженерный отдел"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Запрос</B></large></i></center><BR>Я, <B><span class=\"paper_field\"></span></B>, в должности <B><span class=\"paper_field\"></span></B>, прошу Главного инженера предоставить мне разрешение на строительство (Construction Permit) для расширения следующего помещения за счёт ближайшего космического пространства: <span class=\"paper_field\"></span>.<BR><BR>Осуществлением указанных работ согласен заниматься сотрудник инженерного отдела <B><span class=\"paper_field\"></span></B>.<BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B>Подпись заявителя</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись лица, запрашивающего разрешение.</font><BR><B>Подпись инженера</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись согласного на осуществление работ инженера.</font><BR><B>Подпись ответственного лица</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Главного инженера.</font><BR><B>Время подписания документа</B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><BR><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.</font></font>"

//NT-SEC
/obj/item/paper/form/NT_SEC_WIT
	name = "Форма NT-SEC-WIT"
	id = "NT-SEC-WIT"
	altername = "Свидетельские показания."
	category = "NT-SEC - Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Свидетельство</B></large></i></center><BR><large><B>Полное имя свидетеля:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите Ваше полное имя.</font><BR><BR><large><B>Полное имя пострадавшего:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите полное имя жертвы, если таковая имелась.</font><BR><BR><large><B>Полное имя подозреваемого:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите имя подозреваемого, если Вы о нем осведомлены.</font><BR><BR><large><B>Совершенные нарушения:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Опишите увиденные Вами нарушения.</font><BR><BR><large><B>Примерное время происшествия:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите наиболее приближенное время.</font><BR><BR><large><B>Место происшествия:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите то, где именно было совершено нарушение.</font><BR><BR><large><B>Дополнительная информация:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите любую информацию, которая, с Вашей точки зрения, будет полезной. </font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись свидетеля:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B><large>Подпись ответственного лица</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись уполномоченного лица, принявшего заявление. </font><BR><B><large>Время подписания документа</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_SEC_SRCH
	name = "Форма NT-SEC-SRCH"
	id = "NT-SEC-SRCH"
	altername = "Ордер на обыск."
	category = "NT-SEC - Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Ордер</B></large></i></center><BR>⠀⠀<BR>Я, <span class=\"paper_field\"></span>,  в должности <span class=\"paper_field\"></span>, даю разрешение на проведение обыска члена экипажа по имени <span class=\"paper_field\"></span> из-за подозрения в следующих нарушениях: <span class=\"paper_field\"></span><BR><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись ответственного лица</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Магистрата, Капитана или Главы Службы Безопасности.</font><BR><large><B>Время подписания документа</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_SEC_ARST
	name = "Форма NT-SEC-ARST"
	id = "NT-SEC-ARST"
	altername = "Ордер на арест."
	category = "NT-SEC - Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Ордер</B></large></i></center>⠀⠀<BR>Я, <span class=\"paper_field\"></span>,  в должности <span class=\"paper_field\"></span>, даю разрешение на проведение ареста члена экипажа по имени <span class=\"paper_field\"></span> из-за обвинения в следующих нарушениях: <span class=\"paper_field\"></span><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><large><B>Подпись ответственного лица</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Магистрата, Капитана или Главы Службы Безопасности.</font><BR><large><B>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_SEC_CASE
	name = "Форма NT-SEC-CASE"
	id = "NT-SEC-CASE"
	altername = "Отчёт по результатам расследования."
	category = "NT-SEC - Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><large><B>Отчет</B></large></center><BR><large><B>Полное имя обвиняемого: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите полное имя члена экипажа, которому выдвигаются обвинения.</font><BR><BR><large><B>Выдвигаемые обвинения: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите те статьи Космического Закона, которые были нарушены обвиняемым.</font><BR><BR><large><B>Время совершения преступления: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите наиболее приближенное время если нет возможности указать точное. </font><BR><BR><large><B>Мотив преступления: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите установленную причину, по которой было совершено преступление.</font><BR><BR><large><B>Собранные доказательства: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите перечень улик, которые будут прикреплены к данному отчету или перемещены в комнату для хранения улик.</font><BR><BR><large><B>Картина произошедшего: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">На основе собранных доказательств, опишите то, как именно происходило преступление.</font><BR><BR><large><B>Дополнительная информация: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите сведения, которые Вы считаете важными для дела. </font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><large><B>Подпись детектива</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><large><B>Подпись ответственного лица</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Магистрата, Капитана, Главы Службы Безопасности или Смотрителя.</font><BR><B><large>Время подписания документа</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><BR><font size = \"1\"> *Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font>"

/obj/item/paper/form/NT_SEC_STL
	name = "Форма NT-SEC-STL"
	id = "NT-SEC-STL"
	altername = "Заявление о краже."
	category = "NT-SEC - Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR><large><B>Полное имя обвиняемого:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите имя преступника, если Вы о нем осведомлены.</font><BR><BR><large><B>Наименование украденного имущества:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите что именно было украдено. </font><BR><BR><large><B>Примерно время происшествия:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите наиболее приближенное время.</font><BR><BR><large><B>Место происшествия:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите то, где именно была совершена кража.</font><BR><BR><large><B>Полные имена потенциальных свидетелей:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите имена тех, кто являлся свидетелем кражи.</font><BR><BR><large><B>Дополнительная информация:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите любую информацию, которая, с Вашей точки зрения, будет полезной. </font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись заявителя</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B><large>Подпись ответственного лица</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись уполномоченного лица, принявшего заявление. </font><BR><large><B>Время подписания документа</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font></large><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_SEC_HARM
	name = "Форма NT-SEC-HARM"
	id = "NT-SEC-HARM"
	altername = "Заявление о причинении вреда здоровью."
	category = "NT-SEC - Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR><large><B>Полное имя нападавшего:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите имя преступника, если Вы о нем осведомлены.</font><BR><BR><large><B>Тяжесть вреда здоровью:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите то, насколько серьезными были повреждения. </font><BR><BR><large><B>Полное имя врача, что оказал помощь:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите имя того, кто оказался Вам медицинскую помощь.</font><BR><BR><large><B>Орудие преступления:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите то, чем именно наносились повреждения. </font><BR><BR><large><B>Примерно время происшествия:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите наиболее приближенное время.</font><BR><BR><large><B>Место происшествия:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите то, где именно было совершено нападение.</font><BR><BR><large><B>Полные имена потенциальных свидетелей:</B><large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите имена тех, кто являлся свидетелем нападения.</font><BR><BR><large><B>Дополнительная информация:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите любую информацию, которая, с Вашей точки зрения, будет полезной. </font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись свидетеля</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B><large>Подпись ответственного лица</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись уполномоченного лица, принявшего заявление. </font><BR><B><large>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font></large><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_SEC_WPN
	name = "Форма NT-SEC-WPN"
	id = "NT-SEC-WPN"
	altername = "Лицензия на оружие."
	category = "NT-SEC - Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Лицензия</B></large></i></center><BR>Я, <span class=\"paper_field\"></span>,  в должности <span class=\"paper_field\"></span>, даю разрешение члену экипажа по имени <span class=\"paper_field\"></span> на ношение следующего оружия, а так же боеприпасов к нему: <B><span class=\"paper_field\"></span></B><BR>Данное оружие может применяться только в целях самообороны, защиты своих личных вещей, и рабочего места, а так же для защиты своих коллег.<BR><BR>Лицензия может разрешить только одно наименование оружия, только в одном экземпляре, и может быть аннулирована согласно Стандартным Рабочим Процедурам Службы Безопасности, подразделу \"Лицензии на оружие\". Лицензия так же разрешает хранение и использование стандартных боеприпасов, подходящих для данного оружия. <BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись получателя</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись того, кому выдается разрешение.</font><BR><B><large>Подпись ответственного лица</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Капитана, Главы Службы Безопасности или Смотрителя. </font><BR><B><large>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

//NT-LD
/obj/item/paper/form/NT_LD_SMT
	name = "Форма NT-LD-SMT"
	id = "NT-LD-SMT"
	altername = "Исковое заявление."
	category = "NT-LD - Отдел юриспруденции"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Заявление</B></large></i></center><BR>Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, заявляю о желании проведения cуда мелких тяжб в отношении члена экипажа по имени <span class=\"paper_field\"></span> в должности <span class=\"paper_field\"></span>. <BR><BR>Я выдвигаю следующие обвинения по отношению к ответчику: <span class=\"paper_field\"></span><BR><BR>По окончанию судебного разбирательства, я желаю, чтобы к ответчику было применено следующее наказание: <span class=\"paper_field\"></span><BR><BR>Мои интересы на заседании суда будет представлять следующий член экипажа: <span class=\"paper_field\"></span> <BR><font size = \"1\">(истец в праве указать свое имя и тем самым представлять себя сам)</font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись истца:</large></B> <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись подающего заявление</font><BR><B><large>Подпись ответственного лица</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись председательствующего судьи (магистрата, представителя Nanotrasen или капитана)</font><BR><B><large>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_LD_STT
	name = "Форма NT-LD-STT"
	id = "NT-LD-STT"
	altername = "Отчет сотрудника юридического отдела."
	category = "NT-LD - Отдел юриспруденции"
	info = "<font face=\"Verdana\" color=black><center><large><B>Отчет</B></large></center>ᅠᅠ<BR>Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, сообщаю: <span class=\"paper_field\"></span><BR><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><large><B>Подпись ответственного лица:</large></B> <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><large><B>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><BR><font size = \"1\"> *Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font>"

/obj/item/paper/form/NT_LD_SUD
	name = "Форма NT-LD-SUD"
	id = "NT-LD-SUD"
	altername = "Судебное постановление."
	category = "NT-LD - Отдел юриспруденции"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Постановление</B></large></i></center><BR><B><large>Сторона обвинения:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите полное имя истца или его представителя.</font><BR><BR><B><large>Имя ответчика:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите полное имя обвиняемого.</font><BR><BR><B><large>Выдвинутые обвинения:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите полный список выдвинутых истцом обвинений.</font><BR><BR><B><large>Окончательный приговор:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите то, была ли доказана вина, и соответствующее доказанным обвинением наказание. </font><BR><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись ответственного лица</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись лица, проводившего судебное заседание. </font><BR><B><large>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_LD_RPRT
	name = "Форма NT-LD-RPRT"
	id = "NT-LD-RPRT"
	altername = "Отчет о нарушении."
	category = "NT-LD - Отдел юриспруденции"
	info = "<font face=\"Verdana\" color=black><center><large><B>Отчет</B></large></center><BR><large><B>Полное имя нарушителя: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите полное имя члена экипажа, совершившего нарушения.</font><BR><BR><large><B>Совершенные нарушения: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите, какие именно нарушения были произведены.</font><BR><BR><large><B>Время совершения нарушения: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите наиболее приближенное время если нет возможности указать точное. </font><BR><BR><large><B>Причина нарушения: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите то, из-за чего было совершено нарушение.</font><BR><BR><large><B>Собранные доказательства: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите перечень улик, которые будут прикреплены к данному отчету.</font><BR><BR><large><B>Дополнительная информация: </B></large><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите сведения, которые Вы считаете важными для дела. </font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><large><B>Подпись ответственного лица</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><large><B>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><BR><font size = \"1\"> *Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font>"

/obj/item/paper/form/NT_LD_EXC
	name = "Форма NT-LD-EXC"
	id = "NT-LD-EXC"
	altername = "Постановление о казни."
	category = "NT-LD - Отдел юриспруденции"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Постановление</B></large></i></center><BR>ᅠᅠЯ, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, приговариваю к смертной казни следующего члена экпиажа: <B><span class=\"paper_field\"></span></B><BR>Вышеупомянутый член экипажа признан виновным в совершении следующих нарушений: <span class=\"paper_field\"></span><BR>Приговоренный будет лишен жизни при помощи следующего вида казни: <span class=\"paper_field\"></span><BR>После окончания процедуры казни, тело подлежит <span class=\"paper_field\"></span><BR><i>Дополнительные сведения</i>: <span class=\"paper_field\"></span><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись ответственного лица</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Магистрата или Капитана. </font><BR><B><large>Время подписания документа</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\"> *Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

/obj/item/paper/form/NT_LD_CON
	name = "Форма NT-LD-CON"
	id = "NT-LD-CON"
	altername = "Лицензия на контрабанду."
	category = "NT-LD - Отдел юриспруденции"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Лицензия</B></large></i></center><BR>Я, <span class=\"paper_field\"></span>,  в должности <span class=\"paper_field\"></span>, даю разрешение сотруднику Службы Безопасности по имени <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, на владение следующей контрабандой: <B><span class=\"paper_field\"></span></B><BR>Данная контрабанда может применяться только в целях исполнения должностных обязанностей. При использовании её для превышения полномочий, лицензия автоматически аннулируется,  получатель должен быть обвинен в нарушении 306 статьи Космического Закона Nanotrasen, а контрабанда возвращена на склад для улик. <BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись получателя</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись того, кому выдается разрешение.</font><BR><B><large>Подпись ответственного лица</B></large>: <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись Магистрата или Капитана. </font><BR><B><large>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки заявителю обязательно, а также может быть осуществлено по запросу главы данного отдела, сотрудников юр. отдела и службы безопасности.</font></font>"

/obj/item/paper/form/NT_LD_CLM
	name = "Форма NT-LD-CLM"
	id = "NT-LD-CLM"
	altername = "Жалоба АВД."
	category = "NT-LD - Отдел юриспруденции"
	info = "<font face=\"Verdana\" color=black><center><i><large><B>Жалоба</B></large></i></center><BR><large><B>Полное имя подателя:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите Ваше полное имя.</font><BR><BR><large><B>Полное имя потенциального нарушителя:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите имя члена экипажа, совершившего нарушения.</font><BR><BR><large><B>Совершенные нарушения:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Опишите увиденные Вами нарушения.</font><BR><BR><large><B>Примерное время происшествия:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите наиболее приближенное время.</font><BR><BR><large><B>Место происшествия:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите то, где именно было совершено нарушение.</font><BR><BR><large><B>Имена потенциальных свидетелей:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите полные имена тех, кто также видел совершение нарушения.</font><BR><BR><large><B>Дополнительная информация:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите любую информацию, которая, с Вашей точки зрения, будет полезной. </font><BR><hr><center><i><large><B>Подписи и штампы</B></large></i></center><BR><B><large>Подпись подателя:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B><large>Подпись ответственного лица:</B></large> <span class=\"paper_field\"></span><BR><font size = \"1\">Подпись принимающего жалобу. </font><BR><B><large>Время подписания документа</large></B>: <span class=\"paper_field\"></span><BR><font size = \"1\">Укажите время выставления последней необходимой подписи в документе.</font><hr><font size = \"1\">*Документ вступает в силу только при наличии всех необходимых подписей, а также штампа ответственного лица, в противном случае он считается недействительным.<BR>*Оригинал должен храниться в отделе, соответствующем коду формы. Копирование документа для выдачи на руки разрешено исключительно в отношении главы данного отдела, сотрудников юр. отдела и службы безопасности по их запросу.</font></font>"

//NT-CC
/obj/item/paper/form/NT_COM_01
	name = "Форма NT-COM-01"
	id = "NT-COM-01"
	altername = "Запрос отчёта общего состояния станции"
	category = "NT-CC - Центральное Командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center><BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения об общем состоянии станции.<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td><tr><td>Общее состояние станции:<td><span class=\"paper_field\"></span><BR></td><tr><td>Криминальный статус:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Повышений:<td><span class=\"paper_field\"></span><BR></td><tr><td>Понижений:<td><span class=\"paper_field\"></span><BR></td><tr><td>Увольнений:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Раненные:<td><span class=\"paper_field\"></span><BR></td><tr><td>Пропавшие:<td><span class=\"paper_field\"></span><BR></td><tr><td>Скончавшиеся:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_02
	name = "Форма NT-COM-02"
	id = "NT-COM-02"
	altername = "Запрос отчёта состояния трудовых активов станции"
	category = "NT-CC - Центральное Командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center><BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения о состоянии трудовых активов станции.<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td><tr><td>Количество сотрудников:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество гражданских:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество киборгов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество ИИ:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Заявлений о приёме на работу:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на смену должности:<td><span class=\"paper_field\"></span><BR></td><tr><td>Приказов на смену должности:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений об увольнении:<td><span class=\"paper_field\"></span><BR></td><tr><td>Приказов об увольнении:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на выдачу новой ID карты:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на дополнительный доступ:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Медианный уровень кваллификации смены:<td><span class=\"paper_field\"></span><BR></td><tr><td>Уровень взаимодействия отделов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Самый продуктивный отдел смены:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Приложите все имеющиеся документы:<td>NT-HR-00<BR></td><tr><td><td>NT-HR-01<BR></td><tr><td><td>NT-HR-02<BR></td><tr><td><td>NT-HR-12<BR></td><tr><td><td>NT-HR-03<BR></td><tr><td><td>NT-HR-13<BR></td><tr><td><td>NT-HR-04<BR></td><tr><td><td>NT-HR-05<BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_03
	name = "Форма NT-COM-03"
	id = "NT-COM-03"
	altername = "Запрос отчёта криминального статуса станции"
	category = "NT-CC - Центральное Командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center>\
	<BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения о криминальном статусе станции.\
	<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td>\
	<tr><td>Текущий статус угрозы:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество офицеров в отделе:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество раненных офицеров:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество скончавшихся офицеров:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество серъёзных инцидентов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество незначительных инцидентов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество раскрытых дел:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество арестованных:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество сбежавших:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Приложите все имеющиеся документы:<td>NT-SEC-01<BR></td><tr><td><td>NT-SEC-11<BR></td><tr><td><td>NT-SEC-21<BR></td><tr><td><td>NT-SEC-02<BR></td><tr><td><td>Лог камер заключения<BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_04
	name = "Форма NT-COM-04"
	id = "NT-COM-04"
	altername = "Запрос отчёта здравоохранения станции"
	category = "NT-CC - Центральное Командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_05
	name = "Форма NT-COM-05"
	id = "NT-COM-05"
	altername = "Запрос отчёта научно-технического прогресса станции"
	category = "NT-CC - Центральное Командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_06
	name = "Форма NT-COM-06"
	id = "NT-COM-06"
	altername = "Запрос отчёта инженерного обеспечения станции"
	category = "NT-CC - Центральное Командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_07
	name = "Форма NT-COM-07"
	id = "NT-COM-07"
	altername = "Запрос отчёта статуса снабжения станции "
	category = "NT-CC - Центральное Командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
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
	var/const/footer_to_taipan =   "<I><font face=\"Verdana\" color=black size = \"1\">\
									<HR>\
									*Несоблюдение и/или нарушение указаний, содержащихся в данном письме, карается смертью.\
									<BR>*Копирование, распространение и использование содержащейся информации карается смертью, за исключением случаев, описанных в письме.\
									<BR>*Письмо подлежит уничтожению после ознакомления.\
									</font></I>"
	var/const/footer_from_taipan = "<I><font face=\"Verdana\" color=black size = \"1\">\
									<HR>\
									*Целевым получателем запроса является Синдикат\
									<BR>*Копирование, распространение и использование документа и представленной информации \
									за пределами целевого получателя запроса и экипажа станции запрещено.\
									<BR>*Оригинал документа после отправки целевому получателю подлежит хранению в защищённом месте, \
									либо уничтожению с соответствующим указанием.\
									<BR>*В случае проникновения на объект посторонних лиц или угрозы проникновения документ подлежит уничтожению до или после отправки.\
									</font></I>"
	footer = footer_to_taipan

/obj/item/paper/form/syndieform/New()
	. = ..()
	if(is_header_needed)
		header = "	<font face=\"Verdana\" color=black>\
					<table cellspacing=0 cellpadding=3  align=\"right\">\
					<tr><td><img src= syndielogo.png></td></tr>\
					</table><br>\
					<table border=10 cellspacing=0 cellpadding=3 width =\"250\" height=\"100\"  align=\"center\" bgcolor=\"#B50F1D\">\
					<td><center><B>[confidential ? "СОВЕРШЕННО СЕКРЕТНО<BR>" : ""]</B><B>[id]</B></center></td>\
					</table>\
					<br><HR></font>"
	populatefields()

/obj/item/paper/form/syndieform/SYND_COM_TC
	name = "Форма SYND-COM-TC"
	id = "SYND-COM-TC"
	altername = "Официальное письмо"
	category = "Синдикат"
	access = ACCESS_SYNDICATE_COMMAND
	footer = footer_to_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><H2><U>Официальное письмо объекту</U><BR>&#34;ННКСС Тайпан&#34;</H2></center><HR>\
			<span class=\"paper_field\"></span><BR>\
			<font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<BR></font></font>"

/obj/item/paper/form/syndieform/SYND_COM_SUP
	name = "Форма SYND-COM-SUP"
	id = "SYND-COM-SUP"
	altername = "Запрос особой доставки"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><H2>Запрос особой доставки на станцию<BR>Синдиката</H2></center><HR>\
			<center><table>\
			<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>\
			<td><center><font size=\"4\">Данные<BR>для<BR>доставки</font></center><td>\
			<center><B><U><font size=\"4\">Получатель</font></U></B></center>\
			<U>Наименование станции</U>: &#34;ННКСС <B>Тайпан</B>&#34;\
			<BR><U>Наименование сектора</U>: Эпсилон Эридана\
			</td></tr></table>\
			</center><BR>В связи с отсутствием в стандартном перечени заказов прошу доставить следующее:\
			<BR><ul><li><U><span class=\"paper_field\"></span></U></ul>\
			<BR>Причина запроса: <B><span class=\"paper_field\"></span></B>\
			<BR><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<BR></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO00
	name = "Форма SYND-TAI-№00"
	id = "SYND-TAI-№00"
	altername = "Экстренное письмо"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><H2><U>Экстренное письмо</U><BR>ННКСС &#34;Тайпан&#34;</H2></center><HR>\
			<span class=\"paper_field\"></span>\
			<BR><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<BR></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO01
	name = "Форма SYND-TAI-№01"
	id = "SYND-TAI-№01"
	altername = "Отчёт о ситуации на станции"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<H3>Отчёт о ситуации на станции</H3><HR>\
			<U>Наименование станции</U>: ННКСС &#34;Тайпан&#34;<BR>\
			<BR>Общее состояние станции: <span class=\"paper_field\"></span>\
			<BR>Численность персонала станции: <span class=\"paper_field\"></span>\
			<BR>Общее состояние персонала станции: <span class=\"paper_field\"></span>\
			<BR>Непосредственные внешние угрозы: <B><span class=\"paper_field\"></span></B>\
			<BR>Подробности: <span class=\"paper_field\"></span>\
			<BR>Дополнительная информация: <span class=\"paper_field\"></span><BR>\
			<BR><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<BR></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO02
	name = "Форма SYND-TAI-№02"
	id = "SYND-TAI-№02"
	altername = "Отчёт о разработке вируса"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<H3>Отчёт о разработке вируса</H3>\
			<HR><U>Наименование вируса</U>: <B><span class=\"paper_field\"></span></B><BR>\
			<BR>Тип вируса: <span class=\"paper_field\"></span>\
			<BR>Способ распространения: <span class=\"paper_field\"></span>\
			<BR>Перечень симптомов: <span class=\"paper_field\"></span>\
			<BR>Описание: <span class=\"paper_field\"></span><BR>\
			<BR><U>Наличие вакцины</U>: <B><span class=\"paper_field\"></span></B>\
			<BR><U>Наименование вакцины</U>: <span class=\"paper_field\"></span><BR>\
			<BR>Дополнительная информация***: <span class=\"paper_field\"></span>\
			<BR>Указания к хранению вируса***: <span class=\"paper_field\"></span><BR>\
			<BR><font size = \"1\">Подпись разработчика: <span class=\"paper_field\"></span>, в должности <B><span class=\"paper_field\"></span></B>\
			<BR>Подпись Директора Исследований**: <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<HR><I><font size = \"1\">**Отчёт недействителен без подписи Директора Исследований. \
			В случае его отсутствия требуется подпись Офицера Телекоммуникаций или заменяющего его лица с указанием должности.\
			<BR>***Заполняется Директором Исследований. В случае его отсутствия, заполняется Офицером Телекоммуникаций или заменяющим его лицом</font>"

//======
/obj/item/paper/deltainfo
	name = "Информационный буклет НСС Керберос"
	info = "<font face=\"Verdana\" color=black><center><H1>Буклет нового сотрудника \
			на борту НСС &#34;Керберос&#34;</H1></center>\
			<BR><HR><B></B><BR><center><H2>Цель</H2></center>\
			<BR><font size=\"4\">Данное руководство было создано с целью \
			<B>облегчить процесс</B> введения в работу станции <B>нового экипажа</B>, \
			а также для <B>информирования сотрудников</B> об оптимальных маршрутах \
			передвижения. В данном буклете находится <B>основная карта</B> &#34;Кербероса&#34; \
			и несколько интересных фактов о станции.</font>\
			<BR><HR><BR><center><H2>Карта Станции</H2></center>\
			<BR><font size=\"4\">С точки зрения конструкции, станция состоит из 12 зон:\
			<BR><ul><li>Прибытие - <B><B>Серый</B></B> - Отсек прибытия экипажа и ангар космических подов.\
			<BR><li>Мостик - <B>Синий</B> - Отсек командования и VIP-персон.\
			<BR><li>Двор - <B>Зелёный</B> - Отсек сферы услуг.\
			<BR><li>Карго - <B>Оранжевый</B> - Отсек снабжения и поставок.\
			<BR><li>Инженерия - <B>Жёлтый</B> - Отсек технического обслуживания и систем станции.\
			<BR><li>Бриг - <B>Красный</B> - Отсек службы безопасности и юристов.\
			<BR><li>Дормы - <B>Розовый</B> - Отсек для отдыха и развлечений.\
			<BR><li>РнД - <B>Фиолетовый</B> - Отсек научных исследований и разработок.\
			<BR><li>Медбей - <B>Голубой</B> - Отсек медицинских услуг и разработок.\
			<BR><li>Спутник ИИ - <B>Тёмно-синий</B> - Отсек систем искусственного интеллекта станции.\
			<BR><li>Отбытие - <B>Салатовый</B> - Отсек церкви и эвакуационного шаттла.\
			<BR><li>Технические туннели - <B>Коричневый</B> - Неэксплуатируемые технические помещения.\
			<BR></ul><HR></font> \
			<img src=\"https://media.discordapp.net/attachments/699091773389144125/800399248486957086/Test4.png?width=461&height=338\">\
			<font face=\"Verdana\" color=black><BR><BR><HR><BR><center><H2>Технические туннели</H2></center>\
			<BR> За время строительства проект станции претерпел несколько значительных \
			изменений. Изначально новая станция должна была стать туристическим объектом, \
			но после произошедшей в <B>2549 году</B> серии <B>террористических актов</B> \
			объект вошёл в состав парка научно-исследовательских станций корпорации. В \
			нынешних технических туннелях до сих пор можно найти заброшенные комнаты для \
			гостей, бары и клубы. В связи с плачевным состоянием несущих конструкций \
			посещать эти части станции не рекомендуется, однако неиспользуемые площади \
			могут быть использованы для строительства новых отсеков.\
			<BR><HR><BR><center><H2>Особенности станции</H2></center>\
			<BR>В отличие от большинства других научно-исследовательских станций НТ, \
			таких как &#34;Кибериада&#34;, <B>НСС &#34;Керборос&#34;</B> имеет менее \
			жёсткую систему контроля за личными вещами экипажа. В частности, в отсеках \
			были построены <B>дополнительные автолаты</B>, в том числе <B>публичные</B> \
			(в карго и РНД). Также, благодаря более высокому бюджету, были возведены \
			<B>новые отсеки</B>, такие как <B>ангар</B> или <B>склад</B> в отсеке РнД.</font>"
	icon_state = "pamphlet"

/obj/item/paper/deltainfo/update_icon()
	return

/obj/item/paper/pamphletdeathsquad
	icon_state = "pamphlet-ds"

/obj/item/paper/pamphletdeathsquad/update_icon()
	return
