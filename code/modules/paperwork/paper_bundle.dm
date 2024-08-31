/obj/item/paper_bundle
	name = "paper bundle"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 2
	resistance_flags = FLAMMABLE
	throw_speed = 1
	layer = 4
	pressure_resistance = 2
	attack_verb = list("bapped")
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/list/papers
	var/amount = 0 //Amount of total items clipped to the paper. Note: If you have 2 paper, this should be 1
	var/photos = 0 //Amount of photos clipped to the paper.
	var/page = 1
	var/screen = 0


/obj/item/paper_bundle/Initialize(mapload, default_papers = TRUE)
	. = ..()
	papers = list()
	if(default_papers) // This is to avoid runtime occuring from a paper bundle being created without a paper in it.
		for(var/i = 1 to 2)
			var/obj/item/paper/paper = new(src)
			papers += paper
		amount++


/obj/item/paper_bundle/Destroy()
	QDEL_LIST(papers)
	return ..()


/obj/item/paper_bundle/attackby(obj/item/I, mob/living/user, params)
	if(resistance_flags & ON_FIRE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_hot(I))
		if(!Adjacent(user)) //to prevent issues as a result of telepathically lighting a paper bundles
			return ATTACK_CHAIN_BLOCKED_ALL

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
		var/obj/item/paper/paper = papers[page]
		if(!istype(paper))	// photo
			return ATTACK_CHAIN_PROCEED
		if(!user.is_literate())
			to_chat(user, span_warning("You don't know how to write!"))
			return ATTACK_CHAIN_PROCEED
		user << browse("", "window=PaperBundle[UID()]") //Closes the dialog
		paper.show_content(user, infolinks = TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/paper))
		add_fingerprint(user)
		if(istype(I, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/carbon_paper = I
			if(!carbon_paper.iscopy && !carbon_paper.copied)
				to_chat(user, span_notice("Take off the carbon copy first."))
				return .
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		amount++
		papers += I
		if(screen == 2)
			screen = 1
		update_appearance(UPDATE_ICON|UPDATE_DESC)
		to_chat(user, span_notice("You add [(I.name == "paper") ? "the paper" : I.name] to [(name == "paper bundle") ? "the paper bundle" : name]."))
		if(winget(user, "PaperBundle[UID()]", "is-visible") == "true") // NOT MY FAULT IT IS A BUILT IN PROC PLEASE DO NOT HIT ME
			attack_self(user) //Update the browsed page.
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/photo))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		amount++
		photos++
		papers += I
		if(screen == 2)
			screen = 1
		update_appearance(UPDATE_ICON|UPDATE_DESC)
		to_chat(user, span_notice("You add [(I.name == "photo") ? "the photo" : I.name] to [(name == "paper bundle") ? "the paper bundle" : name]."))
		if(winget(user, "PaperBundle[UID()]", "is-visible") == "true")
			attack_self(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/lighter))
		burnpaper(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/paper_bundle))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		var/obj/item/paper_bundle/bundle = I
		for(var/obj/item/thing as anything in bundle.papers)
			thing.forceMove(src)
			thing.add_fingerprint(user)
			amount++
			papers += thing
			if(screen == 2)
				screen = 1
		bundle.papers.Cut()
		update_appearance(UPDATE_ICON|UPDATE_DESC)
		to_chat(user, span_notice("You add the [I.name] to [(name == "paper bundle") ? "the paper bundle" : name]."))
		if(winget(user, "PaperBundle[UID()]", "is-visible") == "true")
			attack_self(user)
		qdel(bundle)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/paper_bundle/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		for(var/obj/item/paper/paper in papers)
			paper.info = "<i>Heat-curled corners and sooty words offer little insight. Whatever was once written on this page has been rendered illegible through fire.</i>"


/obj/item/paper_bundle/proc/burnpaper(obj/item/lighter/P, mob/user)
	var/class = "<span class='warning'>"

	if(resistance_flags & FIRE_PROOF)
		return

	if(P.lit && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(istype(P, /obj/item/lighter/zippo))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds [P] up to [src], it looks like [user.p_theyre()] trying to burn it!", \
		"[class]You hold [P] up to [src], burning it slowly.")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.", \
				"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.")

				if(user.is_in_inactive_hand(src))
					user.temporarily_remove_item_from_inventory(src)

				new /obj/effect/decal/cleanable/ash(get_turf(src))
				qdel(src)

			else
				to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")

/obj/item/paper_bundle/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(user.is_literate())
			show_content(user)
		else
			. += "<span class='notice'>You don't know how to read.</span>"
	else
		. += "<span class='notice'>It is too far away.</span>"

/obj/item/paper_bundle/proc/show_content(mob/user)
	var/dat = {"<html><meta charset="UTF-8">"}
	var/obj/item/W = papers[page]
	switch(screen)
		if(0)
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><a href='byond://?src=[UID()];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><a href='byond://?src=[UID()];next_page=1'>Next Page</A></DIV><BR><HR>"
		if(1)
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><a href='byond://?src=[UID()];prev_page=1'>Previous Page</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><a href='byond://?src=[UID()];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><a href='byond://?src=[UID()];next_page=1'>Next Page</A></DIV><BR><HR>"
		if(2)
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><a href='byond://?src=[UID()];prev_page=1'>Previous Page</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><a href='byond://?src=[UID()];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV><BR><HR>"
			dat+= "<DIV STYLE='float;left; text-align:right; with:33.33333%'></DIV>"
	if(istype(papers[page], /obj/item/paper))
		var/obj/item/paper/P = W
		dat += P.show_content(usr, view = 0)
		usr << browse(dat, "window=PaperBundle[UID()];size=[P.paper_width]x[P.paper_height]")
	else if(istype(papers[page], /obj/item/photo))
		var/obj/item/photo/P = W
		usr << browse_rsc(P.img, "tmp_photo.png")
		usr << browse(dat + {"<html><meta charset="UTF-8"><head><title>[P.name]</title></head>"} \
		+ "<body style='overflow:hidden'>" \
		+ "<div> <img src='tmp_photo.png' width = '180'" \
		+ "[P.scribble ? "<div><br> Written on the back:<br><i>[P.scribble]</i>" : ""]"\
		+ "</body></html>", "window=PaperBundle[UID()]")

/obj/item/paper_bundle/attack_self(mob/user)
	show_content(user)
	add_fingerprint(user)
	update_appearance(UPDATE_ICON|UPDATE_DESC)


/obj/item/paper_bundle/Topic(href, href_list)
	..()
	if((src in usr.contents) || (istype(src.loc, /obj/item/folder) && (src.loc in usr.contents)))
		usr.set_machine(src)
		if(href_list["next_page"])
			if(page == amount)
				screen = 2
			else if(page == 1)
				screen = 1
			else if(page == amount+1)
				return
			page++
			playsound(src.loc, "pageturn", 50, 1)
		if(href_list["prev_page"])
			if(page == 1)
				return
			else if(page == 2)
				screen = 0
			else if(page == amount+1)
				screen = 1
			page--
			playsound(src.loc, "pageturn", 50, 1)
		if(href_list["remove"])
			var/obj/item/W = papers[page]
			papers -= W
			W.forceMove_turf()
			usr.put_in_hands(W, ignore_anim = FALSE)
			to_chat(usr, "<span class='notice'>You remove the [W.name] from the bundle.</span>")
			if(amount == 1)
				var/obj/item/paper/P = papers[1]
				papers -= P
				P.forceMove_turf()
				usr.temporarily_remove_item_from_inventory(src, force = TRUE)
				usr.put_in_hands(P, ignore_anim = FALSE)
				usr << browse("", "window=PaperBundle[UID()]")
				qdel(src)
			else if(page == amount)
				screen = 2
			else if(page == amount+1)
				page--

			amount--
			update_appearance(UPDATE_ICON|UPDATE_DESC)
	else
		to_chat(usr, "<span class='notice'>You need to hold it in your hands to change pages.</span>")
	if(!QDELETED(src) && ismob(loc))
		attack_self(loc)
		updateUsrDialog()



/obj/item/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	var/n_name = tgui_input_text(usr, "What would you like to label the bundle?", "Bundle Labelling", name)
	if(!Adjacent(usr) || !n_name || usr.stat)
		return
	name = "[(n_name ? "[n_name]" : "paper bundle")]"
	add_fingerprint(usr)
	return


/obj/item/paper_bundle/verb/remove_all()
	set name = "Loose bundle"
	set category = "Object"
	set src in usr

	to_chat(usr, "<span class='notice'>You loosen the bundle.</span>")
	for(var/obj/O in src)
		O.loc = usr.loc
		O.layer = initial(O.layer)
		O.plane = initial(O.plane)
		O.add_fingerprint(usr)
	usr.temporarily_remove_item_from_inventory(src)
	qdel(src)
	return


/obj/item/paper_bundle/update_desc(updates = ALL)
	. = ..()
	if(amount == (photos - 1))
		desc = "[photos] photos clipped together." // In case you clip 2 photos together and remove the paper
		return

	else if(((amount + 1) - photos) >= 2) // extra papers + original paper - photos
		desc = "[(amount + 1) - photos] papers clipped to each other."

	else
		desc = "A single sheet of paper."
	if(photos)
		desc += "\nThere [photos == 1 ? "is a photo" : "are [photos] photos"] attached to it."


/obj/item/paper_bundle/update_icon_state()
	if(length(contents))
		var/obj/item/paper/P = contents[1]
		icon_state = P.icon_state // must have an icon_state to show up on clipboards


/obj/item/paper_bundle/update_overlays()
	. = ..()
	underlays.Cut()

	var/counter = 0
	for(var/obj/item/thing as anything in papers)
		if(istype(thing, /obj/item/paper))
			if(length(underlays) >= 3)
				continue
			var/image/sheet = image('icons/obj/bureaucracy.dmi', thing.icon_state)
			sheet.pixel_w -= min(1 * counter, 2)
			sheet.pixel_z -= min(1 * counter, 2)
			pixel_w = min(0.5 * counter, 1)
			pixel_z = min(1 * counter, 2)
			underlays += sheet
			counter++

		else if(istype(thing, /obj/item/photo))
			var/obj/item/photo/picture = thing
			. += picture.tiny

	. += "clip"

